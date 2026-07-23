import { describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc, updateDoc, deleteField } from 'firebase/firestore';

import {
  dbFor,
  pendingEnrollment,
  seed,
  seedUser,
  sharedRouteDraft,
} from './support/firestore_rules_test_support.mjs';

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

  it('denies owner updates and deletes of an existing draft route, including self-publishing', async () => {
    await seed('sharedRoutes/route-draft', sharedRouteDraft);

    const route = doc(dbFor('alice'), 'sharedRoutes/route-draft');

    // sharedRoutes has no update/delete allow: an owner cannot flip their
    // own draft to published, mutate any other field, or delete the doc.
    await assertFails(updateDoc(route, { visibilityStatus: 'published' }));
    await assertFails(updateDoc(route, { title: 'Renamed Synthetic Loop' }));
    await assertFails(updateDoc(route, { updatedAt: 2 }));
    await assertFails(deleteDoc(route));
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
