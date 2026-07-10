# Token Contract Tests Template

Scaffold these three suites on first sync in a project (Step 4.5). Examples
use vitest for a two-dim (brand x mode) TypeScript project — adapt import
paths, dim names, and test runner to the target project's config. The suite
doubles as `verify-command`. Suggested location: next to the token files,
e.g. `src/theme/tokens/token-contract.test.ts` + `token-pins.test.ts`.

## Suite 1 — Contract/schema (design-independent; never changes when design changes)

```ts
import { describe, expect, it } from 'vitest';
import { colorTokens } from './generated/color-tokens';

const BRANDS = ['alpha', 'beta'] as const;   // from config rules
const MODES = ['light', 'dark'] as const;
const HEX = /^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$/;

describe('token contract', () => {
  it('every combo has identical key sets', () => {
    const ref = Object.keys(colorTokens[BRANDS[0]][MODES[0]]).sort();
    for (const b of BRANDS) for (const m of MODES)
      expect(Object.keys(colorTokens[b][m]).sort()).toEqual(ref);
  });

  it('all values are concrete hex (no leftover $refs)', () => {
    for (const b of BRANDS) for (const m of MODES)
      for (const [k, v] of Object.entries(colorTokens[b][m]))
        expect(v, `${b}/${m}/${k}`).toMatch(HEX);
  });

  it('only consumer-tier keys exported', () => {
    for (const k of Object.keys(colorTokens.alpha.light))
      expect(k, 'forbidden tier leaked').toMatch(/^c-/);   // prefix from config rules
  });
});
```

## Suite 2 — Cross-file consistency (JSON snapshot ↔ code)

```ts
import { describe, expect, it } from 'vitest';
import designTokens from './design-tokens.json';
import { colorTokens } from './generated/color-tokens';

describe('snapshot/code consistency', () => {
  it('consumer color keys in JSON equal keys in code', () => {
    const jsonKeys = Object.entries(designTokens.variables)
      .filter(([k, v]) => k.startsWith('c-') && (v as { type: string }).type === 'color')
      .map(([k]) => k).sort();
    expect(Object.keys(colorTokens.alpha.light).sort()).toEqual(jsonKeys);
  });
});
```

## Suite 3 — Pinned values (intentional anchors; the skill updates these FIRST on sync)

```ts
import { describe, expect, it } from 'vitest';
import { colorTokens } from './generated/color-tokens';

// PINNED DESIGN VALUES — updating a pin is an explicit design-change confirmation.
// bi-pencil-token-to-code updates pins BEFORE syncing code (RED), then syncs (GREEN).
describe('pinned design values', () => {
  it('brand primaries', () => {
    expect(colorTokens.alpha.light['c-primary-main']).toBe('#FF5252');
    expect(colorTokens.beta.light['c-primary-main']).toBe('#4FAF50');
  });
  it('core text/surface anchors', () => {
    expect(colorTokens.alpha.light['c-text-primary']).toBe('#000000');
    expect(colorTokens.alpha.dark['c-bg-paper']).toBe('#1E1E1E');
  });
});
```

## Scaffolding rules

- Pick 3-6 pins max: brand primaries + 1-2 text/surface anchors. Too many
  pins = churn on every design tweak.
- Non-color groups (spacing, radii, typography sizes): add a schema check
  per group (numeric, expected key count) in Suite 1 style; pin only
  load-bearing values (e.g. `r-md = 8`).
- Project without a test runner: add one as devDependency + a `test` script
  (ask permission — this touches package.json outside token-files).
- TDD gate flow: update pins → run (expect RED) → sync code → run (must be
  GREEN). A pin that stays green in the RED phase means design did not
  actually change that value — report it.
