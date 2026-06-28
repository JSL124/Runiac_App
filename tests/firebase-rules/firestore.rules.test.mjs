import { describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteField, doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

import {
  activityDraft,
  dbFor,
  notificationPrefs,
  profileFields,
  seed,
} from './support/firestore_rules_test_support.mjs';

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
