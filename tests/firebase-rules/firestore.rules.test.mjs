import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  limit,
  orderBy,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

import {
  adaptivePlanEstimateReadModel,
  activityDraft,
  dbFor,
  generatedPlanDocument,
  notificationPrefs,
  planProgressReadModel,
  profileFields,
  seed,
} from './support/firestore_rules_test_support.mjs';

describe('owner-owned client records', () => {
  it('allows an owner to write safe user profile fields', async () => {
    const alice = dbFor('alice');

    await seed('nicknameClaims/runner', {
      ownerUid: 'alice',
      nickname: 'Runner',
      nicknameKey: 'runner',
      updatedAt: 1,
    });
    await assertSucceeds(setDoc(doc(alice, 'userProfiles/alice'), profileFields));
    await assertSucceeds(getDoc(doc(alice, 'userProfiles/alice')));
    await assertFails(getDoc(doc(dbFor('bob'), 'userProfiles/alice')));
  });

  it('denies deleting backend-owned fields during profile updates', async () => {
    await seed('userProfiles/alice', {
      ...profileFields,
      xp: 10,
      level: 2,
    });

    const profile = doc(dbFor('alice'), 'userProfiles/alice');

    await assertSucceeds(updateDoc(profile, { displayName: 'Updated Runner' }));
    await assertFails(updateDoc(profile, { xp: deleteField() }));
    await assertFails(updateDoc(profile, { level: 3 }));
  });

  it('denies userRole and subscriptionStatus writes from clients', async () => {
    const alice = dbFor('alice');

    await assertFails(
      setDoc(doc(alice, 'users/alice'), {
        userRole: 'Platform Administrator',
        subscriptionStatus: 'Premium',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        userRole: 'Platform Administrator',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        subscriptionStatus: 'Premium',
      }),
    );
  });

  it('denies profile email persistence and invalid personal profile fields', async () => {
    const alice = dbFor('alice');

    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        email: 'alice@example.test',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        ageYears: 12,
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        weightKg: 251,
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        nickname: 'Line\nBreak',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        dateOfBirth: 'not-a-date',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        locationLabel: 'London, United Kingdom',
      }),
    );
  });

  it('allows nickname claims only for the authenticated owner', async () => {
    const alice = dbFor('alice');

    await assertSucceeds(
      setDoc(doc(alice, 'nicknameClaims/runner'), {
        ownerUid: 'alice',
        nickname: 'Runner',
        nicknameKey: 'runner',
        updatedAt: 1,
      }),
    );
    await assertSucceeds(getDoc(doc(alice, 'nicknameClaims/runner')));
    await assertFails(
      setDoc(doc(dbFor('bob'), 'nicknameClaims/runner'), {
        ownerUid: 'bob',
        nickname: 'Runner',
        nicknameKey: 'runner',
        updatedAt: 1,
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'nicknameClaims/other-key'), {
        ownerUid: 'alice',
        nickname: 'Runner',
        nicknameKey: 'runner',
        updatedAt: 1,
      }),
    );
    await assertSucceeds(deleteDoc(doc(alice, 'nicknameClaims/runner')));
  });

  it('allows only the owner to read and write generated plans', async () => {
    const alice = dbFor('alice');

    await assertSucceeds(
      setDoc(doc(alice, 'generatedPlans/alice'), generatedPlanDocument),
    );
    await assertSucceeds(getDoc(doc(alice, 'generatedPlans/alice')));
    await assertFails(getDoc(doc(dbFor('bob'), 'generatedPlans/alice')));
    await assertFails(
      setDoc(doc(dbFor('bob'), 'generatedPlans/alice'), generatedPlanDocument),
    );
  });

  it('allows owner to write a full generated plan payload', async () => {
    const alice = dbFor('alice');
    const baseWorkout = generatedPlanDocument.weeks[0].workouts[0];

    await assertSucceeds(
      setDoc(doc(alice, 'generatedPlans/alice'), {
        ...generatedPlanDocument,
        weeks: Array.from({ length: 4 }, (_, weekIndex) => ({
          weekNumber: weekIndex + 1,
          title: `Week ${weekIndex + 1}`,
          focus: `Week ${weekIndex + 1} focus`,
          workouts: ['Mon', 'Fri', 'Sat'].map((dayLabel, sessionIndex) => ({
            ...baseWorkout,
            dayLabel,
            title: `${baseWorkout.title} ${sessionIndex + 1}`,
          })),
        })),
      }),
    );
  });

  it('denies backend-owned and unapproved generated plan fields', async () => {
    const alice = dbFor('alice');
    const plan = doc(alice, 'generatedPlans/alice');

    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        xp: 10,
      }),
    );
    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        leaderboardScore: 100,
      }),
    );
    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        completedRunCount: 1,
      }),
    );
  });

  it('denies nested backend-owned and unapproved generated plan fields', async () => {
    const alice = dbFor('alice');
    const plan = doc(alice, 'generatedPlans/alice');
    const baseWeek = generatedPlanDocument.weeks[0];
    const baseWorkout = baseWeek.workouts[0];

    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        weeks: [
          {
            ...baseWeek,
            workouts: [
              {
                ...baseWorkout,
                completedRunCount: 1,
              },
            ],
          },
        ],
      }),
    );
    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        weeks: [
          {
            ...baseWeek,
            workouts: [
              {
                ...baseWorkout,
                detail: {
                  ...baseWorkout.detail,
                  validationStatus: 'approved',
                },
              },
            ],
          },
        ],
      }),
    );
    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        weeks: [
          {
            ...baseWeek,
            workouts: [
              {
                ...baseWorkout,
                steps: [{ xp: 1 }],
              },
            ],
          },
        ],
      }),
    );
    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        weeks: [
          {
            ...baseWeek,
            workouts: [
              {
                ...baseWorkout,
                detail: {
                  ...baseWorkout.detail,
                  coachNotes: [{ validationStatus: 'approved' }],
                },
              },
            ],
          },
        ],
      }),
    );
    await assertFails(
      setDoc(plan, {
        ...generatedPlanDocument,
        weeks: [
          {
            ...baseWeek,
            workouts: [
              {
                ...baseWorkout,
                scheduleTimeLabel: { userRole: 'Platform Administrator' },
              },
            ],
          },
        ],
      }),
    );
  });

  it('allows owner to write safety readiness generated plan display', async () => {
    const alice = dbFor('alice');

    await assertSucceeds(
      setDoc(doc(alice, 'generatedPlans/alice'), {
        ...generatedPlanDocument,
        title: 'Safety Readiness Plan',
        subtitle: 'Check readiness before starting workouts.',
        sourceLabel: 'Onboarding safety',
        durationWeeks: 0,
        family: null,
        familyCategory: null,
        familyReason: 'Medical clearance recommended before workouts.',
        weeklyFrequencyLabel: '0 sessions / week',
        preferredScheduleLabel: 'After clearance',
        sessionDurationLabel: 'No workouts yet',
        clientDisplayStatus: 'safetyReadiness',
        weeks: [],
      }),
    );
  });

  it('allows only the owner to read backend-owned plan progress', async () => {
    await seed('planProgress/alice', planProgressReadModel);

    const aliceProgress = await assertSucceeds(
      getDoc(doc(dbFor('alice'), 'planProgress/alice')),
    );
    assert.equal(aliceProgress.data().ownerUid, 'alice');

    await assertFails(getDoc(doc(dbFor('bob'), 'planProgress/alice')));
  });

  it('denies all client writes to backend-owned plan progress', async () => {
    const aliceProgress = doc(dbFor('alice'), 'planProgress/alice');

    await assertFails(setDoc(aliceProgress, planProgressReadModel));

    await seed('planProgress/alice', planProgressReadModel);
    await assertFails(updateDoc(aliceProgress, { completedWorkoutCount: 2 }));
    await assertFails(deleteDoc(aliceProgress));
  });

  it('allows only the owner to read backend-owned adaptive plan estimates', async () => {
    await seed('adaptivePlanEstimates/alice', adaptivePlanEstimateReadModel);

    const aliceEstimate = await assertSucceeds(
      getDoc(doc(dbFor('alice'), 'adaptivePlanEstimates/alice')),
    );
    assert.equal(aliceEstimate.data().ownerUid, 'alice');

    await assertFails(getDoc(doc(dbFor('bob'), 'adaptivePlanEstimates/alice')));
  });

  it('denies all client writes to backend-owned adaptive plan estimates', async () => {
    const aliceEstimate = doc(dbFor('alice'), 'adaptivePlanEstimates/alice');

    await assertFails(setDoc(aliceEstimate, adaptivePlanEstimateReadModel));
    await assertFails(
      setDoc(aliceEstimate, {
        ownerUid: 'alice',
        completedRunCount: 1,
        averageRecentPaceSecondsPerKm: 500,
        readinessBand: 'building',
        latestAcceptedActivityId: 'activity-client-write',
        source: 'client',
        updatedAt: 22,
      }),
    );

    await seed('adaptivePlanEstimates/alice', adaptivePlanEstimateReadModel);
    await assertFails(updateDoc(aliceEstimate, { completedRunCount: 2 }));
    await assertFails(
      updateDoc(aliceEstimate, {
        averageRecentPaceSecondsPerKm: 480,
        readinessBand: 'ready',
      }),
    );
    await assertFails(deleteDoc(aliceEstimate));
  });

  it('requires a matching owner nickname claim before profile nickname writes', async () => {
    const alice = dbFor('alice');

    await assertFails(setDoc(doc(alice, 'userProfiles/alice'), profileFields));
    await seed('nicknameClaims/runner', {
      ownerUid: 'alice',
      nickname: 'Runner',
      nicknameKey: 'runner',
      updatedAt: 1,
    });
    await assertSucceeds(setDoc(doc(alice, 'userProfiles/alice'), profileFields));

    await seed('nicknameClaims/maya', {
      ownerUid: 'bob',
      nickname: 'Maya',
      nicknameKey: 'maya',
      updatedAt: 1,
    });
    await assertFails(
      updateDoc(doc(alice, 'userProfiles/alice'), {
        displayName: 'Maya',
        nickname: 'Maya',
        nicknameKey: 'maya',
      }),
    );
  });

  it('denies unapproved nested profile fields', async () => {
    const alice = dbFor('alice');

    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        availability: {
          ...profileFields.availability,
          subscriptionStatus: 'premium',
        },
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        healthSafetyReadiness: {
          ...profileFields.healthSafetyReadiness,
          userRole: 'Platform Administrator',
        },
      }),
    );
  });

  it('denies auth bootstrap writes to users and backend-owned fields', async () => {
    const alice = dbFor('alice');
    const authBootstrapPayload = {
      email: 'alice@example.test',
      displayName: 'Synthetic Runner',
      userRole: 'Platform Administrator',
      subscriptionStatus: 'premium',
      subscriptionPrivilegeState: 'active',
      xp: 100,
      weeklyXP: 100,
      monthlyXP: 200,
      streak: 7,
      streakCount: 7,
      lastStreakRunDate: '2026-06-14',
      streakUpdatedAt: 1,
      level: 3,
      rank: 1,
      leaderboardScore: 500,
      validationStatus: 'validated',
      countsTowardProgression: true,
      validatedActivityContributionState: 'accepted',
      expertPlanPublicationState: 'published',
    };

    await assertFails(setDoc(doc(alice, 'users/alice'), authBootstrapPayload));
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        userRole: 'Basic User',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        subscriptionStatus: 'basic',
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        xp: 0,
        weeklyXP: 0,
        monthlyXP: 0,
        streak: 0,
        streakCount: 0,
        lastStreakRunDate: '2026-06-14',
        streakUpdatedAt: 1,
        level: 1,
        rank: 0,
        leaderboardScore: 0,
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        validationStatus: 'pending',
        countsTowardProgression: false,
        validatedActivityContributionState: 'none',
        expertPlanPublicationState: 'draft',
      }),
    );
  });

  it('allows an owner to create a raw pending activity only', async () => {
    await assertSucceeds(
      setDoc(doc(dbFor('alice'), 'activities/activity-001'), activityDraft),
    );

    await assertFails(
      setDoc(doc(dbFor('bob'), 'activities/activity-002'), {
        ...activityDraft,
        ownerUid: 'alice',
      }),
    );
  });

  it('denies activity validation and progression contribution flags', async () => {
    const alice = dbFor('alice');
    const activity = doc(alice, 'activities/activity-001');

    await assertFails(
      setDoc(activity, {
        ...activityDraft,
        validationStatus: 'validated',
      }),
    );
    await assertFails(
      setDoc(activity, {
        ...activityDraft,
        countsTowardProgression: true,
      }),
    );
  });

  it('denies overwriting or resetting backend-processed activities', async () => {
    await seed('activities/processed-001', {
      ...activityDraft,
      status: 'validated',
      validationStatus: 'validated',
      countsTowardProgression: true,
      validatedActivityContributionState: 'accepted',
    });

    const activity = doc(dbFor('alice'), 'activities/processed-001');

    await assertFails(setDoc(activity, activityDraft));
    await assertFails(updateDoc(activity, { status: 'pending' }));
    await assertFails(updateDoc(activity, { validationStatus: deleteField() }));
  });

  it('denies client writes to backend-owned streak profile fields', async () => {
    await seed('userProfiles/alice', {
      ...profileFields,
      streakCount: 2,
      lastStreakRunDate: '2026-06-15',
      streakUpdatedAt: 1,
    });

    const profile = doc(dbFor('alice'), 'userProfiles/alice');

    await assertFails(
      setDoc(profile, {
        ...profileFields,
        streakCount: 1,
        lastStreakRunDate: '2026-06-14',
        streakUpdatedAt: 1,
      }),
    );
    await assertFails(updateDoc(profile, { streakCount: 3 }));
    await assertFails(updateDoc(profile, { lastStreakRunDate: '2026-06-16' }));
    await assertFails(updateDoc(profile, { streakUpdatedAt: 2 }));
    await assertFails(updateDoc(profile, { streakCount: deleteField() }));
  });

  it('activity owner history list supports latest-first bounded queries', async () => {
    await seed('activities/alice-older', {
      ...activityDraft,
      ownerUid: 'alice',
      endedAt: 20,
      updatedAt: 21,
    });
    await seed('activities/alice-newer', {
      ...activityDraft,
      ownerUid: 'alice',
      endedAt: 40,
      updatedAt: 41,
    });
    await seed('activities/bob-activity', {
      ...activityDraft,
      ownerUid: 'bob',
      endedAt: 60,
      updatedAt: 61,
    });

    const aliceHistory = query(
      collection(dbFor('alice'), 'activities'),
      where('ownerUid', '==', 'alice'),
      orderBy('endedAt', 'desc'),
      limit(30),
    );
    const aliceHistorySnapshot = await assertSucceeds(getDocs(aliceHistory));
    assert.deepEqual(
      aliceHistorySnapshot.docs.map((activity) => activity.id),
      ['alice-newer', 'alice-older'],
    );

    await assertFails(
      getDocs(
        query(
          collection(dbFor('bob'), 'activities'),
          where('ownerUid', '==', 'alice'),
          orderBy('endedAt', 'desc'),
          limit(30),
        ),
      ),
    );
  });

  it('run summary owner history reads', async () => {
    await seed('runSummaries/alice-summary', {
      ownerUid: 'alice',
      activityId: 'activity-alice',
      status: 'validated',
      startedAt: 10,
      endedAt: 20,
      durationSeconds: 600,
      distanceMeters: 1200,
      averagePaceSecondsPerKm: 500,
      routePrivacy: 'private',
      createdAt: 21,
    });
    await seed('runSummaries/bob-summary', {
      ownerUid: 'bob',
      activityId: 'activity-bob',
      status: 'validated',
      startedAt: 30,
      endedAt: 40,
      durationSeconds: 900,
      distanceMeters: 1800,
      averagePaceSecondsPerKm: 500,
      routePrivacy: 'private',
      createdAt: 41,
    });

    const alice = dbFor('alice');

    const aliceSummary = await assertSucceeds(
      getDoc(doc(alice, 'runSummaries/alice-summary')),
    );
    assert.equal(aliceSummary.data().ownerUid, 'alice');

    const aliceHistory = query(
      collection(alice, 'runSummaries'),
      where('ownerUid', '==', 'alice'),
      orderBy('endedAt', 'desc'),
      limit(30),
    );
    const aliceHistorySnapshot = await assertSucceeds(getDocs(aliceHistory));
    assert.deepEqual(
      aliceHistorySnapshot.docs.map((summary) => summary.id),
      ['alice-summary'],
    );
  });

  it('denies unbounded run summary history list queries', async () => {
    await seed('runSummaries/alice-summary', {
      ownerUid: 'alice',
      activityId: 'activity-alice',
      status: 'validated',
      startedAt: 10,
      endedAt: 20,
      durationSeconds: 600,
      distanceMeters: 1200,
      averagePaceSecondsPerKm: 500,
      routePrivacy: 'private',
      createdAt: 21,
    });

    const unboundedHistory = query(
      collection(dbFor('alice'), 'runSummaries'),
      where('ownerUid', '==', 'alice'),
      orderBy('endedAt', 'desc'),
    );

    await assertFails(getDocs(unboundedHistory));
  });

  it('run summary history denies cross-owner and client writes', async () => {
    await seed('runSummaries/alice-summary', {
      ownerUid: 'alice',
      activityId: 'activity-alice',
      status: 'validated',
      startedAt: 10,
      endedAt: 20,
      durationSeconds: 600,
      distanceMeters: 1200,
      averagePaceSecondsPerKm: 500,
      routePrivacy: 'private',
      createdAt: 21,
    });
    await seed('runSummaries/bob-summary', {
      ownerUid: 'bob',
      activityId: 'activity-bob',
      status: 'validated',
      startedAt: 30,
      endedAt: 40,
      durationSeconds: 900,
      distanceMeters: 1800,
      averagePaceSecondsPerKm: 500,
      routePrivacy: 'private',
      createdAt: 41,
    });

    const bob = dbFor('bob');

    await assertFails(getDoc(doc(bob, 'runSummaries/alice-summary')));
    await assertFails(
      getDocs(
        query(
          collection(bob, 'runSummaries'),
          where('ownerUid', '==', 'alice'),
          orderBy('endedAt', 'desc'),
          limit(30),
        ),
      ),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'runSummaries/client-summary'), {
        ownerUid: 'alice',
        activityId: 'activity-client',
        status: 'validated',
        startedAt: 50,
        endedAt: 60,
        durationSeconds: 600,
        distanceMeters: 1200,
        averagePaceSecondsPerKm: 500,
        routePrivacy: 'private',
        createdAt: 61,
      }),
    );
  });

  it('allows report creation but denies client resolution', async () => {
    const report = doc(dbFor('alice'), 'reports/report-001');

    await assertSucceeds(
      setDoc(report, {
        reporterUid: 'alice',
        targetType: 'route',
        targetId: 'synthetic-route',
        reason: 'unsafe_surface',
        description: 'Synthetic report text only.',
        createdAt: 1,
      }),
    );
    await assertFails(updateDoc(report, { status: 'resolved' }));
  });

  it('allows owners to write notification preferences only for themselves', async () => {
    await assertSucceeds(
      setDoc(doc(dbFor('alice'), 'notificationPreferences/alice'), notificationPrefs),
    );
    await assertFails(
      setDoc(doc(dbFor('bob'), 'notificationPreferences/alice'), notificationPrefs),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'notificationPreferences/alice'), {
        ...notificationPrefs,
        backendSchedulingStatus: 'scheduled',
      }),
    );
  });

  it('denies deleting backend-owned notification scheduling fields', async () => {
    await seed('notificationPreferences/alice', {
      ...notificationPrefs,
      backendSchedulingStatus: 'scheduled',
      lastScheduledAt: 2,
      deliveryState: 'queued',
      serverManagedTokenState: 'active',
    });

    const prefs = doc(dbFor('alice'), 'notificationPreferences/alice');

    await assertSucceeds(updateDoc(prefs, { runReminderEnabled: false }));
    await assertFails(updateDoc(prefs, { backendSchedulingStatus: deleteField() }));
    await assertFails(updateDoc(prefs, { lastScheduledAt: deleteField() }));
    await assertFails(updateDoc(prefs, { deliveryState: 'sent' }));
    await assertFails(updateDoc(prefs, { serverManagedTokenState: deleteField() }));
  });
});
