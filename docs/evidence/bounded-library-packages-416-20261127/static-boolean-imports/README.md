# Static Boolean imported-source closure — 2026-11-27

Four new proof modules connect the original static Boolean reader trees to the
source libraries already shared by object declarations. They do not change Ada,
the language domain, a native precondition, or a result contract.

- `ApplicationStaticBooleanLeafImports` selects the actual lexical, qualified
  reference/lookup, name, context, scalar, comparison and chain callees from
  `ObjectLibraries`. All nine `Native.Imports` meanings follow from the existing
  raw source equations. The original `Context_Of` call is retained. Scalar calls
  retain native default masks, sign/array arguments and `Elaborating => True`.
  The chain adapter preserves every native enum value, including `No_Chain`.
- `ApplicationStaticBooleanBodyImports` establishes every leaf call domain in
  the original primary, factor, relation and condition execution. Failure and
  cursor zero remain included. Recursive readers supply only their exact native
  cursor postconditions. Loop normalization transfers finite executions and
  derives each next operand's cursor bound; it introduces no execution cutoff.
- `ApplicationStaticBooleanScalarImports` closes the additional
  `Scalars.Is_Empty` primitive in the relation tree. `scalarOperandsFrame`
  executes the original declarations and Right assignment with arbitrary
  initial locals. Both actual scalar reads have bounded intervals, including
  rejected reads. The checked source-library `scalarEmpty` equation therefore
  identifies each actual call with the primitive expression in that same tree.
- `ApplicationStaticBooleanReaderImports` retains the actual recursive family,
  original typed body equations and exact native result contracts in `Library`.
  It derives `BodyReads`, then reuses `BodyReads.determined` over the original
  source variant. The exported `.condition` is the very reader passed to
  `ObjectLibraries.object`; equality to `closedReader` and the accepted source
  expression are conclusions, never library premises.

The full input domain is `SourceChecks.Domain`: native valid text, the original
frame subtype/validity and the cursor bound. No allowed-source, accepted-input,
initial-local-value or model-reader-equality premise was added.

Run `20261127T212948-73c26a2026c3` passed the complete
`Silver.ApplicationStaticBooleanReaderImports` target, including all four new
modules and a fresh axiom audit of 72,030 declarations. All 1,588 captured inputs
hash-match the retained final worktree. The earlier three-module success is
retained separately and does not stand in for the scalar-empty extension.
This is focused Linux x86_64 validation using Lean 4.34.1, two Lake workers,
two threads per process, 8,192 MiB per process, and affinity CPUs 4–5 within the
host's shared eight-CPU allocation. Matching dependency caches were reused.
Neither a clean build nor independent kernel replay was performed.

Three failed proof drafts and the interrupted cache-seeding attempt remain
recorded as such. The drafts exposed token-validity decidability, explicit
projection/let normalization and an underdetermined recursion-record field;
repairs did not narrow a domain or increase a proof budget. The first attempt
omitted the copied cache's tool marker, so the runner correctly invalidated that
cache. It was interrupted; its log and partial cache were preserved, then a
complete matching cache/marker was copied read-only from the idle visibility
workspace. One rejected worker-budget launch is also retained. The successful
managed checks revalidated their own source and tool identities.

The final source integration must instantiate `SourceChecks.Checked` on actual
Output_Profile tokens and connect `Library.bodies` and `Library.contracts` to
that source interpretation and the complete native proof evidence. Those are
explicit proof boundaries, not discharged by copied candidate tokens. The
active Output_Profile containing-unit proof and complete application assurance
remain separate gates. No full native audit was launched here.

The implementation review checked the native call arguments, default scalar
arguments, full frame domain, qualified lookup spans, the original Context_Of
projection, both interval primitive operands, arbitrary initial locals, and
the absence of an assumed reader/model equality. Root owns independent review,
authoritative extraction and final integration.
