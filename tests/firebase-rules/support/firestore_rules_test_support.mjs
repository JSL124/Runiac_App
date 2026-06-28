import { readFileSync } from 'node:fs';
import { after, before, beforeEach } from 'node:test';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';

const RULES_PATH = new URL('../../../firestore.rules', import.meta.url);
let testEnv;

export const profileFields = {
  displayName: 'Synthetic Runner',
  fullName: 'Synthetic Runner',
  nickname: 'Runner',
  avatarInitials: 'SR',
  ageYears: 24,
  weightKg: 58.5,
  locationLabel: 'Synthetic Region',
  fitnessLevel: 'beginner',
  goals: ['habit'],
  availability: {
    weeklySessions: '3',
    preferredDays: ['Mon', 'Wed', 'Fri'],
    preferredTime: 'morning',
    sessionLengthMinutes: '20',
  },
  planCautiousness: 'balanced',
  healthSafetyReadiness: {
    comfort: 'ready',
    activitySymptoms: ['none'],
    recentRunningConsistency: 'none',
    currentWeeklyRunFrequency: '0',
    continuousRunCapacity: 'walk',
    runningPlace: 'park',
    motivationStyle: 'reminders',
  },
  updatedAt: 1,
};

export const activityDraft = {
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

export const notificationPrefs = {
  ownerUid: 'alice',
  runReminderEnabled: true,
  restReminderEnabled: true,
  streakRiskEnabled: false,
  reminderTime: '07:00',
  quietHoursStart: '22:00',
  quietHoursEnd: '06:00',
  updatedAt: 1,
};

export const sharedRouteDraft = {
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

export const pendingEnrollment = {
  ownerUid: 'alice',
  planId: 'first-5k',
  planType: 'expert',
  status: 'pending',
  requestedAt: 1,
};

before(async () => {
  const rules = readFileSync(RULES_PATH, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId: `runiac-firestore-rules-test-${process.pid}`,
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

export function dbFor(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

export async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

export async function seedUser(uid, subscriptionStatus) {
  await seed(`users/${uid}`, {
    subscriptionStatus,
    userRole: 'Basic User',
  });
}
