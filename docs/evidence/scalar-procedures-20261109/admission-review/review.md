# Scalar procedure admission: bounded adversarial review

Review interval: **2026-11-10 07:16:54–07:24:39 UTC**. Selected settings:
**GPT-6 Astra / Max**; live runtime model/effort were not independently exposed.
The actual host reports **Linux**. This was a static, read-only review; no Lean,
GNATprove, compiler, build, regression, or application run was started.

Target: issue **#370**, draft PR **#371**, milestone **23**, under the owner's
authorization for #29 and the next bounded language capability. Worktree:
`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-procedures-370`.
Reviewed HEAD: **`bea9085ed82e6669ae73ca60c1bf3e12e2370b81`**.
[input-manifest.json](input-manifest.json) records SHA-256 identities for 51
selected review inputs. Native procedure files had no tracked working-tree diff
at the closing source check. The high-library/bridge drafts that were untracked
at review start were excluded as accepted evidence.

## Finding C1 — incomplete catalogue word-token inventory

**Actionable catalogue/compiler drift; no admitted-program safety counterexample.**
`catalogue/silver.json:1699` omits `out`, although the selected procedure grammar
requires it and `src/silver_output_profile.adb:44–52` and
`src/silver_output_profile.ads:34–44` classify it as a word token. The same
inventory also omits the inherited scalar-function tokens `function` and
`return`. `src/silver_catalogue.adb:1785–1810` exports a manually selected subset
plus a hardcoded tail ending at `character`, so regenerating the catalogue alone
will preserve the omission.

Read-only extraction of the native `Token_Kind`, `Is_Word_Token`, and `Spelling`
definitions confirms that **exactly `function`, `out`, and `return`** are missing
from the output-profile word-token inventory; none is missing from
`Silver_Profile`. See [word-token-inventory.json](word-token-inventory.json).
The lead acknowledged this finding and plans the bounded exporter/catalogue
repair after the native input freeze. This review did not inspect a repair.

The procedure construct descriptions at `catalogue/silver.json:1461–1529`
otherwise match the selected language scope examined here.

## Reviewed scope and result

**No additional material semantic or source-domain finding was derived in the
reviewed scope.** This is a bounded review result, not a feature completion verdict.

- **Modes, closed frames, and initialization.** The native header requires
  explicit modes, one or more formals, and a writable formal. It preserves
  case-insensitive declaration/type hiding. `Procedure_Input_Frame` appends only
  `in`/`in out` values; `Procedure_Prefix_Step` reads the fixed pre-output frame,
  checks the required assignment target and subtype containment, and then appends
  the initialized `out` binding. Ordinary body analysis restores full declared
  writable ranges. No-output-prefix bodies require an ordinary statement. See
  `src/silver_output_profile.adb:6194–6469` and `6584–6685`.
- **Input/copy-back and facts.** `Procedure_Actuals_After` checks all inputs before
  updates. The update pass retains the same original `Scan.Facts` for every
  subsequent actual. Integer writable targets are mutable bare bindings with
  whole-formal-range containment in their declared ranges; `in out` also checks
  incoming nonempty containment. Written Integer refinements are replaced with
  the formal range; Boolean results retain no predicate relation. The remaining
  path facts and stores are preserved. See native lines `5135–5407`,
  `ScalarProcedureChecking.lean`, `ScalarProcedureExecution.lean`, and
  `PredicateProcedureUpdatesMeaning.lean`.
- **Alias and lexical exclusions.** Each writable spelling is excluded from the
  other actual spans. Complete numeric, String, Character, and attribute tokens
  are handled separately. The source-reading argument connects these lexical
  scans to pairwise semantic target/read separation, including nested Boolean,
  String/Image, indexed, and array actual forms. `ProcedureNameActualsApart.lean`
  derives `actualsApart`; it does not assume it. The completed scanner law is
  derived from the native step equation, recursive equation, and checked loop
  contract over the native domain, including failure/zero cursors, in
  `ProcedureNameNative.lean` and `ProcedureNameFreeNative.lean`.
- **Mixed calls and composition.** Completed declarations append signatures only
  after the closing name succeeds. Procedure bodies receive earlier function and
  procedure tables; function bodies receive an empty procedure table. Native
  `Basic_Body` retains assignment dispatch before procedure dispatch. Recursive
  branches/loops pass both tables, and immutable loop bindings remain excluded
  as writable actuals. Closed procedure contexts exclude captures, arrays,
  effects, and argument queries; Main actuals retain their existing array and
  argument grammar. See native lines `5410–5517`, `5534–5899`, and `6508–6685`.
- **Constructed semantics and obligations.** `ScalarProcedureDefinition.lean`
  constructs outputs from the actual prefix and body. `ProcedurePrefixMeaning`
  relates sequential source assignments to frozen-frame evaluation through
  derived noninterference. Parameter layout separates input and output storage
  while preserving formal-order copy-back. `ProcedureDeclarationMeaning` derives
  checked definitions from source readings. `ScalarProcedureComposition`
  constructs earlier-prefix environments and includes unused definitions and
  their obligations; `PredicateComposition`/`PredicateChecks` include procedure
  definitions and calls. No caller-specialized formal-domain premise or assumed
  result oracle was found in these reviewed paths.
- **Source-tree structural controls.** The reviewed call/declaration/metadata
  trees carry scoped binders and recursive guards for Ada precedence, homogeneous
  logical chains, arithmetic association, and selected/indexed prefixes.
  `not` requires a primary, arithmetic right children cannot silently regroup a
  chain, and grouping is explicit in rendered source. Source candidate checks
  require those guards alongside rendered-token equality. No M1-style precedence
  fail-open was found in these reviewed trees.

## Limits and handoff

The Oracle, selected language sections, capability record, and procedure report
capacity account were read. The producer/capacity source investigation was not
independently repeated; no new capacity finding is claimed. Existing tests were
read for coverage, not executed. The 51-file identity manifest identifies selected
inputs, not a claim that every proof line in those files was independently
reproved or exhaustively audited.

The lead reported focused native/Lean successes, with authoritative certificates,
endpoint integration, remaining native obligations, and complete validation still
pending. Those known incomplete items are **not new findings** in this report.
Final integration/evidence deltas and C1's repair require a later review update
before any final acceptance statement. Only this scratch directory was written;
no source, tests, scripts, proof inputs, artifacts, commits, or GitHub state were
changed by this review.
