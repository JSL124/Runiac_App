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
  nicknameKey: 'runner',
  dateOfBirth: '2002-06-28',
  ageYears: 24,
  weightKg: 58.5,
  locationLabel: 'Jurong East, Singapore',
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

export const generatedPlanDocument = {
  planId: 'local-onboarding-beginner-plan',
  planKind: 'onboardingBased',
  title: 'Return to Movement',
  subtitle: 'A gentle restart plan focused on comfort and consistency.',
  sourceLabel: 'Onboarding based',
  durationWeeks: 4,
  safetyBand: 'highCaution',
  templateKind: 'veryGentleStart',
  family: 'returnToMovement',
  familyCategory: 'starter',
  familyReason: 'Beginner-safe starter plan',
  supportStyleLabel: 'Gentle reminders',
  weeklyFrequencyLabel: '3 sessions / week',
  preferredScheduleLabel: 'Mon · Wed · Fri',
  sessionDurationLabel: '20 min',
  safetyNote: 'Start gently and keep effort comfortable.',
  clientDisplayStatus: 'generatedPlan',
  weeks: [
    {
      weekNumber: 1,
      title: 'Week 1',
      focus: 'Keep movement easy and comfortable',
      workouts: [
        {
          dayLabel: 'Mon',
          title: 'Easy Walk',
          durationMinutes: 20,
          kind: 'recoveryWalk',
          intensity: 'veryGentle',
          description: 'Choose a familiar park loop.',
          steps: ['Easy walk · 15 min', 'Slow finish · 5 min'],
          supportiveNote: 'Keep this light.',
          detail: {
            metrics: [
              { label: 'Duration', value: '20 min' },
              { label: 'Type', value: 'Recovery walk' },
              { label: 'Effort', value: 'Very gentle' },
              { label: 'Source', value: 'Generated' },
            ],
            breakdown: [
              { kind: 'walk', title: 'Easy walk', detail: '15 min' },
              { kind: 'mobility', title: 'Slow finish', detail: '5 min' },
            ],
            effortGuide: 'Choose a familiar park loop.',
            coachNotes: [
              'Keep this light.',
              'Build confidence before adding intensity.',
              'Use an easier effort if anything feels uncomfortable.',
            ],
          },
        },
      ],
    },
  ],
  updatedAt: 1,
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
