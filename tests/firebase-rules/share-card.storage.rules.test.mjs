import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { getBytes, ref, uploadBytes } from 'firebase/storage';

import { assertFeedEmulatorContract } from './feed.emulator.guard.mjs';

const RULES_PATH = new URL('../../storage.rules', import.meta.url);
const PROJECT_ID = 'demo-runiac-feed';
const PNG_BYTES = new Uint8Array([137, 80, 78, 71, 13, 10, 26, 10]);
const PNG_METADATA = { contentType: 'image/png' };
const CARD_PATH = 'share-cards/alice/rank-card.png';
const ACTIVITY_CARD_PATH = 'share-cards/alice/activity-card.png';

let testEnv;

function storageFor(uid) {
  return testEnv.authenticatedContext(uid).storage();
}

async function seedObject(path) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(ref(context.storage(), path), PNG_BYTES, PNG_METADATA);
  });
}

describe('Share card Storage Rules', () => {
  before(async () => {
    assertFeedEmulatorContract();
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      storage: {
        host: '127.0.0.1',
        port: 9199,
        rules: readFileSync(RULES_PATH, 'utf8'),
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearStorage();
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it('allows the owner to upload a valid PNG card', async () => {
    await assertSucceeds(
      uploadBytes(ref(storageFor('alice'), CARD_PATH), PNG_BYTES, PNG_METADATA),
    );
  });

  it('denies uploading to another user path', async () => {
    await assertFails(
      uploadBytes(
        ref(storageFor('mallory'), CARD_PATH),
        PNG_BYTES,
        PNG_METADATA,
      ),
    );
  });

  it('denies an unauthenticated upload', async () => {
    const anon = testEnv.unauthenticatedContext().storage();
    await assertFails(
      uploadBytes(ref(anon, CARD_PATH), PNG_BYTES, PNG_METADATA),
    );
  });

  it('rejects a non-PNG content type', async () => {
    await assertFails(
      uploadBytes(ref(storageFor('alice'), CARD_PATH), PNG_BYTES, {
        contentType: 'image/jpeg',
      }),
    );
  });

  it('rejects an oversized upload', async () => {
    const oversized = new Uint8Array(4 * 1024 * 1024 + 1);
    oversized.set(PNG_BYTES);
    await assertFails(
      uploadBytes(ref(storageFor('alice'), CARD_PATH), oversized, PNG_METADATA),
    );
  });

  it('rejects a non-png filename', async () => {
    await assertFails(
      uploadBytes(
        ref(storageFor('alice'), 'share-cards/alice/rank-card.gif'),
        PNG_BYTES,
        PNG_METADATA,
      ),
    );
  });

  it('lets the owner read but denies a non-owner', async () => {
    await seedObject(CARD_PATH);
    await assertSucceeds(getBytes(ref(storageFor('alice'), CARD_PATH)));
    await assertFails(getBytes(ref(storageFor('mallory'), CARD_PATH)));
  });

  it('allows the owner to upload and read a run-activity card', async () => {
    await assertSucceeds(
      uploadBytes(
        ref(storageFor('alice'), ACTIVITY_CARD_PATH),
        PNG_BYTES,
        PNG_METADATA,
      ),
    );
    await assertSucceeds(getBytes(ref(storageFor('alice'), ACTIVITY_CARD_PATH)));
  });
});
