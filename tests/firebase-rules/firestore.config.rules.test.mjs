import { describe, it } from 'node:test';
import { assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

import { dbFor, seed, seedUser } from './support/firestore_rules_test_support.mjs';

describe('backend-owned admin config collections', () => {
  it('denies an authenticated non-admin client read/write access to config docs', async () => {
    await seedUser('alice', 'basic');
    await seed('config/progression', { minLevel: 1 });
    await seed('config/featureAccess', { premiumOnly: ['expertPlans'] });

    const alice = dbFor('alice');

    await assertFails(getDoc(doc(alice, 'config/progression')));
    await assertFails(
      setDoc(doc(alice, 'config/progression'), { minLevel: 99 }),
    );

    await assertFails(getDoc(doc(alice, 'config/featureAccess')));
    await assertFails(
      setDoc(doc(alice, 'config/featureAccess'), { premiumOnly: [] }),
    );
  });

  it('denies an authenticated non-admin client read/write access to badgeConfigs', async () => {
    await seedUser('alice', 'basic');
    await seed('badgeConfigs/distance_10k', {
      badgeId: 'distance_10k',
      title: '10K Distance Badge',
    });

    const alice = dbFor('alice');

    await assertFails(getDoc(doc(alice, 'badgeConfigs/distance_10k')));
    await assertFails(
      setDoc(doc(alice, 'badgeConfigs/distance_10k'), { title: 'Hacked' }),
    );
  });
});
