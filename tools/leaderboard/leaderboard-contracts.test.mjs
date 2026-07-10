import assert from "node:assert/strict";
import { describe, it } from "node:test";
import {
  generatedOutputs,
  loadAndValidateContracts,
} from "./generate_leaderboard_contracts.mjs";

describe("Leaderboard shared contracts", () => {
  it("matches all GeoJSON areas and preserves the supported 37-area boundary", async () => {
    const { planning } = await loadAndValidateContracts();
    assert.equal(planning.planningAreas.length, 55);
    assert.equal(
      planning.planningAreas.filter((area) => area.supported).length,
      37,
    );
    assert.equal(
      planning.planningAreas.filter((area) => !area.supported).length,
      18,
    );
  });

  it("defines the current ten UI leagues in contiguous level bands", async () => {
    const { leagues } = await loadAndValidateContracts();
    assert.deepEqual(
      leagues.tiers.map((tier) => tier.name),
      [
        "Iron",
        "Bronze",
        "Silver",
        "Gold",
        "Platinum",
        "Emerald",
        "Diamond",
        "Master",
        "Grandmaster",
        "Challenger",
      ],
    );
  });

  it("generates both Functions and Flutter contracts", async () => {
    const outputs = await generatedOutputs();
    assert.equal(outputs.size, 4);
    for (const content of outputs.values()) {
      assert.match(content, /GENERATED FILE/);
    }
  });
});
