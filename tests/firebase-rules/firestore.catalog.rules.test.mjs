import { describe, it } from 'node:test';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc } from 'firebase/firestore';

import {
  dbFor,
  profileFields,
  seed,
  seedUser,
} from './support/firestore_rules_test_support.mjs';

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
      setDoc(doc(alice, 'progressionEvents/event-streak-001'), {
        ownerUid: 'alice',
        previousStreak: 1,
        nextStreak: 2,
        previousStreakRunDate: '2026-06-14',
        nextStreakRunDate: '2026-06-15',
      }),
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
