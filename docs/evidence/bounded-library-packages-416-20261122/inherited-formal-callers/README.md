# Inherited formal caller and source repairs

Root explicitly assigned these current-primary #416 failures on 2026-11-27.
Selected proof role: Astra Max; live model/effort is not independently exposed.
No Ada implementation, native contract, source pin or proof budget changed.

- `FunctionFrameValidity` proves the zero qualifier spans installed by the
  original scalar and Boolean formal aggregates. Full input and result domains
  remain unchanged.
- `FunctionDeclarationInitialDomain` retains the default `Names.ValidContext`
  clause of the original `initialState` construction.
- `FunctionDeclarationNative` and `ProcedureDeclarationSyntax` now render all
  eight scalar fields and seven Boolean fields present in the original Ada.
  The procedure scalar named aggregate includes both zero qualifier fields.
  The procedure syntax evaluator retains those same zero scalar fields.

The aggregate order, names, defaults and mutable-mode expressions were compared
with `src/silver_output_profile.adb` lines 7089 and 7250. The new rendered items
are constants, so no variable scope or operator rule changes. The existing
typed-tree well-formedness and scoping theorems passed in the helper batch.

The complete affected helper targets passed in
`20261127T222907-db9fa93ccbcf`, fresh audit 81,608 declarations; retained with
the [native leaf evidence](../completion-native-leaves/README.md). The two
unchanged source-check targets then passed in
`20261127T222949-017cd9e2c593` with a fresh audit of 18,702 declarations:
`FunctionSourceParts.DeclarationExpressionAppendParameter` and
`ProcedureDeclarationHelperWholeSourceParts.AppendProcedureParameter`.
They derive expected tokens from the repaired renderer and compare them with
the current complete reviewed source shape, rather than updating expected pins.

Both checks ran on Linux x86-64 / Lean 4.34.1, affinity 4–5, two workers, two
threads/process and 8192 MiB/process. The source batch reused 240 artifacts
for 15 byte-matching source-certificate/shape modules from the idle support
workspace's successful authoritative batch `20261127T215103-4a33f22a63ac`.
All available private/server/IR objects, hashes and Lake traces were transferred
while both workspaces were idle and revalidated by the managed runner. See the
transfer record. OutputBody was not recomputed. The prior authoritative
source-to-reviewed-shape join remains separate retained evidence.

All captured hashes match locally; shared-primary differences are exactly the
four assigned files. Initial caller failures are retained. These focused
repairs do not establish complete #416 or repository assurance.
