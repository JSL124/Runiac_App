import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore, type Firestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  leaderboardContributionId,
  writeLeaderboardContribution,
} from "../leaderboard/monthlyLeaderboard.js";
import {
  coolDownProgressionEventData,
  profileProgressionData,
  progressionDisplayFromEvent,
  type ProgressionAudit,
} from "../progression/progressionAudit.js";
import {
  isPremiumSubscription,
  readTotalXp,
  sumDailyXp,
  sumMonthlyXp,
} from "../progression/progressionAuditHelpers.js";
import {
  applyDailyXpCap,
  calculateCoolDownBonus,
  dailyCapDateForCompletedAt,
  monthlyPeriodForCompletedAt,
  resolveLevelProgression,
} from "../progression/progressionCalculator.js";
import {
  coolDownProgressionEventId,
  deterministicIds,
} from "./runCompletionArtifacts.js";
import type { CompleteCoolDownResult, ProgressionDisplay } from "./runCompletionTypes.js";
import { parseCoolDownCompletionPayload } from "./validateCoolDownPayload.js";

type CallableCoolDownRequest = {
  readonly auth?: {
    readonly uid: string;
  };
  readonly data: unknown;
};

if (getApps().length === 0) {
  initializeApp();
}

export const completeCoolDown = onCall({ region: "asia-southeast1" }, async (request) =>
  completeCoolDownForCallable(request, getFirestore()),
);

export async function completeCoolDownForCallable(
  request: CallableCoolDownRequest,
  firestore: Firestore,
): Promise<CompleteCoolDownResult> {
  const uid = request.auth?.uid;
  if (uid === undefined || uid.length === 0) {
    throw new HttpsError("unauthenticated", "Authentication is required to complete a cool-down stretch.");
  }

  const payload = parseCoolDownCompletionPayload(request.data);
  const ids = deterministicIds(uid, payload.clientRunSessionId);
  if (payload.activityId !== ids.activityId) {
    throw new HttpsError("invalid-argument", "activityId does not match the completed run session.");
  }

  const coolDownEventId = coolDownProgressionEventId(uid, payload.clientRunSessionId);
  const dailyCapDate = dailyCapDateForCompletedAt(payload.completedAt);
  const monthlyPeriod = monthlyPeriodForCompletedAt(payload.completedAt);

  let progressionDisplay: ProgressionDisplay | undefined;
  let alreadyAwarded = false;

  await firestore.runTransaction(async (transaction) => {
    const activityRef = firestore.collection("activities").doc(ids.activityId);
    const baseProgressionRef = firestore.collection("progressionEvents").doc(ids.progressionEventId);
    const coolDownProgressionRef = firestore.collection("progressionEvents").doc(coolDownEventId);
    const userRef = firestore.collection("users").doc(uid);
    const profileRef = firestore.collection("userProfiles").doc(uid);
    const leaderboardContributionRef = firestore
      .collection("leaderboardContributions")
      .doc(leaderboardContributionId(uid, monthlyPeriod));
    const sameDayProgressionEventsQuery = firestore
      .collection("progressionEvents")
      .where("ownerUid", "==", uid)
      .where("dailyCapDate", "==", dailyCapDate);
    const sameMonthProgressionEventsQuery = firestore
      .collection("progressionEvents")
      .where("ownerUid", "==", uid)
      .where("monthlyPeriod", "==", monthlyPeriod);

    const [
      activitySnapshot,
      baseProgressionSnapshot,
      coolDownProgressionSnapshot,
      userSnapshot,
      profileSnapshot,
      leaderboardContributionSnapshot,
      sameDayProgressionEventSnapshots,
      sameMonthProgressionEventSnapshots,
    ] = await Promise.all([
      transaction.get(activityRef),
      transaction.get(baseProgressionRef),
      transaction.get(coolDownProgressionRef),
      transaction.get(userRef),
      transaction.get(profileRef),
      transaction.get(leaderboardContributionRef),
      transaction.get(sameDayProgressionEventsQuery),
      transaction.get(sameMonthProgressionEventsQuery),
    ]);

    const activityData = activitySnapshot.data();
    if (activityData === undefined) {
      throw new HttpsError("not-found", "No validated run was found for this cool-down completion.");
    }
    if (activityData["ownerUid"] !== uid) {
      throw new HttpsError("permission-denied", "This run does not belong to the authenticated user.");
    }
    if (activityData["validationStatus"] !== "validated") {
      throw new HttpsError(
        "failed-precondition",
        "The run must be validated before a cool-down bonus can be awarded.",
      );
    }

    if (activityData["coolDownXpAwarded"] === true || coolDownProgressionSnapshot.exists) {
      progressionDisplay = progressionDisplayFromEvent(coolDownProgressionSnapshot.data());
      alreadyAwarded = true;
      return;
    }

    const baseEventData = baseProgressionSnapshot.data();
    const baseEarnedXp = baseEventData?.["xpDelta"];
    if (baseEventData === undefined || typeof baseEarnedXp !== "number") {
      throw new HttpsError("failed-precondition", "The completed run's XP could not be read.");
    }

    const isPremium = isPremiumSubscription(userSnapshot.data()) || isPremiumSubscription(profileSnapshot.data());
    const bonusBeforeDailyCap = isPremium ? 0 : calculateCoolDownBonus(baseEarnedXp);
    const dailyXpBefore = sumDailyXp(
      sameDayProgressionEventSnapshots.docs.map((document) => document.data()),
      dailyCapDate,
    );
    const capped = applyDailyXpCap({ xpDeltaBeforeDailyCap: bonusBeforeDailyCap, dailyXpBefore });
    const monthlyXpBefore = sumMonthlyXp(
      sameMonthProgressionEventSnapshots.docs.map((document) => document.data()),
      monthlyPeriod,
    );

    const previousTotalXp = readTotalXp(profileSnapshot.data());
    const previousProgression = resolveLevelProgression(previousTotalXp);
    const nextTotalXp = previousTotalXp + capped.xpDelta;
    const nextProgression = resolveLevelProgression(nextTotalXp);
    const monthlyXpAfter = monthlyXpBefore + capped.xpDelta;

    const reason: ProgressionDisplay["reason"] =
      capped.xpDelta > 0
        ? "cool_down_stretch_bonus_awarded"
        : isPremium
          ? "premium_no_progression"
          : bonusBeforeDailyCap > 0
            ? "cool_down_daily_cap_reached"
            : "low_data_no_xp";
    const status: ProgressionDisplay["status"] = capped.xpDelta > 0 ? "awarded" : "not_awarded";
    const countsTowardLeaderboard = !isPremium && capped.xpDelta > 0;

    progressionDisplay = {
      xpDelta: capped.xpDelta,
      countsTowardLeaderboard,
      status,
      reason,
      totalXp: nextTotalXp,
      level: nextProgression.level,
      divisionKey: nextProgression.divisionKey,
      previousTotalXp,
      previousLevel: previousProgression.level,
      previousLevelProgressPercent: previousProgression.levelProgressPercent,
      levelProgressPercent: nextProgression.levelProgressPercent,
      nextLevelXp: nextProgression.nextLevelXp,
      xpToNextLevel: nextProgression.xpToNextLevel,
    };

    transaction.set(
      coolDownProgressionRef,
      coolDownProgressionEventData({
        uid,
        activityId: ids.activityId,
        payload,
        baseEarnedXp,
        bonusBeforeDailyCap,
        dailyCapDate,
        monthlyPeriod,
        dailyXpBefore,
        dailyXpAfter: capped.dailyXpAfter,
        dailyCapApplied: capped.dailyCapApplied,
        monthlyXpBefore,
        monthlyXpAfter,
        previousTotalXp,
        nextTotalXp,
        previousProgression,
        nextProgression,
        countsTowardLeaderboard,
        reason,
        status,
        xpDelta: capped.xpDelta,
      }),
    );

    const audit: ProgressionAudit = {
      progressionDisplay,
      baseCompletionXp: 0,
      distanceXp: 0,
      durationXp: 0,
      planCompletionBonusXp: 0,
      rawXpBeforeActivityCap: bonusBeforeDailyCap,
      rawXpBeforeDailyCap: bonusBeforeDailyCap,
      activityCapApplied: false,
      dailyCapDate,
      monthlyPeriod,
      dailyXpBefore,
      dailyXpAfter: capped.dailyXpAfter,
      monthlyXpBefore,
      monthlyXpAfter,
      dailyCapApplied: capped.dailyCapApplied,
      xpDelta: capped.xpDelta,
      previousTotalXp,
      nextTotalXp,
      previousProgression,
      nextProgression,
      reason,
    };
    transaction.set(profileRef, profileProgressionData(audit, payload.completedAt), { merge: true });

    writeLeaderboardContribution({
      transaction,
      firestore,
      uid,
      progressionEventId: coolDownEventId,
      completedAt: payload.completedAt,
      periodKey: monthlyPeriod,
      scoreXp: capped.xpDelta,
      divisionKey: nextProgression.divisionKey,
      divisionLabel: nextProgression.divisionLabel,
      levelLabel: nextProgression.levelLabel,
      profileData: profileSnapshot.data(),
      existingContributionData: leaderboardContributionSnapshot.data(),
    });

    transaction.set(
      activityRef,
      {
        coolDownXpAwarded: true,
        coolDownXpAwardedAt: payload.completedAt,
        coolDownProgressionEventId: coolDownEventId,
      },
      { merge: true },
    );
  });

  if (progressionDisplay === undefined) {
    throw new HttpsError("internal", "Cool-down completion did not produce a progression display.");
  }

  return {
    activityId: ids.activityId,
    coolDownProgressionEventId: coolDownEventId,
    alreadyAwarded,
    progressionDisplay,
  };
}
