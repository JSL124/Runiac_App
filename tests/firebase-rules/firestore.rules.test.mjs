import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { deleteDoc, deleteField, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const PROJECT_ID = 'runiac-firestore-rules-test';
const RULES_PATH = new URL('../../firestore.rules', import.meta.url);

let testEnv;

const profileFields = {
  displayName: 'Synthetic Runner',
  avatarInitials: 'SR',
  locationLabel: 'Synthetic Region',
  fitnessLevel: 'beginner',
  goals: ['habit'],
  availability: ['monday'],
  planCautiousness: 'gentle',
  healthSafetyReadiness: 'ready',
  updatedAt: 1,
};

const activityDraft = {
  ownerUid: 'alice',
  status: 'pending',
  source: 'mobile',
  activityType: 'run',
  startedAt: 1,
  endedAt: 2,
  durationSeconds: 1200,
  distanceMeters: 1800,
  averagePaceSecondsPerKm: 420,
  routePrivacy: 'private',
  createdAt: 3,
  updatedAt: 4,
};

const notificationPrefs = {
  ownerUid: 'alice',
  runReminderEnabled: true,
  restReminderEnabled: true,
  streakRiskEnabled: false,
  reminderTime: '07:00',
  quietHoursStart: '22:00',
  quietHoursEnd: '06:00',
  updatedAt: 1,
};

const sharedRouteDraft = {
  ownerUid: 'alice',
  title: 'Masked Synthetic Park Loop',
  description: 'Synthetic public-area route metadata only.',
  distanceMeters: 1800,
  estimatedDurationSeconds: 900,
  difficulty: 'easy',
  regionLabel: 'Synthetic Region',
  visibilityStatus: 'draft',
  createdAt: 1,
  updatedAt: 1,
};

const pendingEnrollment = {
  ownerUid: 'alice',
  planId: 'first-5k',
  planType: 'expert',
  status: 'pending',
  requestedAt: 1,
};

before(async () => {
  const rules = readFileSync(RULES_PATH, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

function dbFor(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

async function seedUser(uid, subscriptionStatus) {
  await seed(`users/${uid}`, {
    subscriptionStatus,
    userRole: 'Basic User',
  });
}

describe('owner-owned client records', () => {
  it('allows an owner to write safe user profile fields', async () => {
    const alice = dbFor('alice');

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

describe('backend-owned read models and public catalogue records', () => {
  it('denies client writes to trusted progression and leaderboard fields', async () => {
    const alice = dbFor('alice');

    await assertFails(
      setDoc(doc(alice, 'runSummaries/summary-001'), { ownerUid: 'alice' }),
    );
    await assertFails(
      setDoc(doc(alice, 'progressionEvents/event-001'), { ownerUid: 'alice' }),
    );
    await assertFails(
      setDoc(doc(alice, 'leaderboardSnapshots/weekly-sg'), { rank: 1 }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), { ...profileFields, xp: 10 }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        streak: 2,
      }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), { ...profileFields, level: 3 }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), { ...profileFields, rank: 4 }),
    );
    await assertFails(
      setDoc(doc(alice, 'userProfiles/alice'), {
        ...profileFields,
        leaderboardScore: 5,
      }),
    );
  });

  it('allows premium users to read published expert plans and denies basic users', async () => {
    await seedUser('alice', 'premium');
    await seedUser('bob', 'basic');
    await seed('expertPlans/first-5k', {
      status: 'published',
      title: 'Synthetic First 5K',
      difficulty: 'beginner',
    });
    await seed('expertPlans/draft-10k', {
      status: 'draft',
      title: 'Synthetic Draft 10K',
    });

    await assertSucceeds(getDoc(doc(dbFor('alice'), 'expertPlans/first-5k')));
    await assertFails(getDoc(doc(dbFor('bob'), 'expertPlans/first-5k')));
    await assertFails(getDoc(doc(dbFor('alice'), 'expertPlans/draft-10k')));
    await assertFails(
      setDoc(doc(dbFor('alice'), 'expertPlans/new-plan'), {
        status: 'published',
        title: 'Client Published Plan',
      }),
    );
    await assertFails(deleteDoc(doc(dbFor('alice'), 'expertPlans/first-5k')));
  });
});

describe('shared route privacy and plan enrollment boundaries', () => {
  it('allows owners to create draft route metadata without precise GPS traces', async () => {
    await assertSucceeds(
      setDoc(doc(dbFor('alice'), 'sharedRoutes/route-001'), sharedRouteDraft),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'sharedRoutes/route-002'), {
        ...sharedRouteDraft,
        rawCoordinates: [{ latitude: 1.2345, longitude: 6.789 }],
      }),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'sharedRoutes/route-003'), {
        ...sharedRouteDraft,
        moderationStatus: 'approved',
      }),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'sharedRoutes/route-004'), {
        ...sharedRouteDraft,
        visibilityStatus: 'published',
      }),
    );
  });

  it('enforces private and published shared route read boundaries', async () => {
    await seed('sharedRoutes/private-route', sharedRouteDraft);
    await seed('sharedRoutes/published-route', {
      ...sharedRouteDraft,
      visibilityStatus: 'published',
      moderationStatus: 'approved',
    });

    await assertSucceeds(getDoc(doc(dbFor('alice'), 'sharedRoutes/private-route')));
    await assertFails(getDoc(doc(dbFor('bob'), 'sharedRoutes/private-route')));
    await assertSucceeds(getDoc(doc(dbFor('bob'), 'sharedRoutes/published-route')));
  });

  it('allows premium users to create minimal pending enrollments only', async () => {
    await seedUser('alice', 'premium');
    await seedUser('bob', 'basic');
    await seed('expertPlans/first-5k', {
      status: 'published',
      title: 'Synthetic First 5K',
    });
    await seed('expertPlans/draft-10k', {
      status: 'draft',
      title: 'Synthetic Draft 10K',
    });

    await assertSucceeds(
      setDoc(doc(dbFor('alice'), 'planEnrollments/enrollment-001'), pendingEnrollment),
    );
    await assertFails(
      setDoc(doc(dbFor('bob'), 'planEnrollments/enrollment-002'), {
        ...pendingEnrollment,
        ownerUid: 'bob',
      }),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'planEnrollments/enrollment-003'), {
        ...pendingEnrollment,
        ownerUid: 'bob',
      }),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'planEnrollments/enrollment-004'), {
        ...pendingEnrollment,
        planId: 'draft-10k',
      }),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'planEnrollments/enrollment-005'), {
        ...pendingEnrollment,
        status: 'active',
      }),
    );
    await assertFails(
      setDoc(doc(dbFor('alice'), 'planEnrollments/enrollment-006'), {
        ...pendingEnrollment,
        completionPercent: 50,
      }),
    );
  });

  it('denies client enrollment updates and backend-owned enrollment mutation', async () => {
    await seedUser('alice', 'premium');
    await seed('planEnrollments/enrollment-001', {
      ...pendingEnrollment,
      status: 'active',
      completionPercent: 10,
      validatedActivityContributionState: 'backend-managed',
    });

    const enrollment = doc(dbFor('alice'), 'planEnrollments/enrollment-001');

    await assertFails(updateDoc(enrollment, { status: 'pending' }));
    await assertFails(updateDoc(enrollment, { completionPercent: 20 }));
    await assertFails(
      updateDoc(enrollment, { validatedActivityContributionState: deleteField() }),
    );
  });
});
