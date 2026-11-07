# Function report producer account, #298, 2026-11-07

Selected setting: GPT-6 Astra / Extra High, as assigned by the lead. Independent
live-model telemetry and token/cost measurements are unavailable. The source
review below establishes producer routes under the existing pinned-tool premise;
it does not establish application admission, compiler correspondence, automatic
discharge, or completed native compiler proof.

Pinned SPARK revision: 42554fc241fcd1fdf08d3a2feccb3f86912acbc0. Files are retained
compressed in sibling `producer/` and match the following SHA256 hashes:

- flow-analysis.adb: 10dab62c866ca03c5fd9dfefc2f70ea348797f18fb4703ffa69be1ceb9ff9c94
- flow-control_flow_graph.adb: d6d903a8f15e645e1de51c2b74c8b61288885b34c88e9b2ac1f5469a801684b7
- gnat2why-expr.adb: 750ed73091af62c0b522077c2e59e10f496b91a4bee323b3b822fba15094dd14
- gnat2why-subprograms.adb: d9f5f4ecb398741e747e9167df89464c54f7dd1f6e54516280d998e5c56eb736
- spark_definition.adb: d8d9203d847f4673be7be8bef8f006d90e5d0da9365e30e2eed311540bda934e
- gnat2why-assumptions.adb: c8ad7264625b572c6405319d599a9381c2cc1000dc51dea1e06e4301f54d01cf
- assumptions.adb: c27cf3aefe1df294ed1e466a814eec071ea0f01d94dbad4ee932ed6bf98e59c7
- assumption_types.ads: f8aff92f29a9e51ea2262620b5272de06caecef4b89524510032f7cb73136e77
- assumption_types.adb: e30b9da4d2c164ebf69a7f9d5caa2999b6e487dd80bb28d8b8591b4f0d79bc31
- flow-analysis-assumptions.adb: f3c3cf150b16a6b8fbdd0592205179c6f6eba7c5fd94457c432ab99bf7687f44

## Checks and termination

`gnat2why-expr.adb:4394–4816` computes each formal's actual exactly once;
`4582–4590` transforms the ordinary scalar actual with `Expected_Type => Formal_T`.
`4818` instantiates parameter iteration, used at `4877`. Functions are pure
scalar, explicit `in`; the self/out/aliasing/validity/specialized-call routes are
excluded. Parameter conversion is the existing checked scalar conversion, with
arithmetic/index checks inside each actual independently retained.

`Transform_Function_Call` at `26365–26689` invokes the computed actual list and
ordinary program function once. The selected grammar excludes explicit contracts,
variants, access, dispatch, private invariants, invalid values, allocation and
side effects, so the extra precondition, invariant, tag, variant, validity and
resource checks guarded by those features do not arise. Calls are ordinary bodies
under `--no-inlining`, not contextual body expansion.

`Transform_Simple_Return_Expression` at `29243–29358` invokes
`Transform_Prog (Expr, Return_Type, Params)` once (`29270`) and assigns the result.
The scalar return has no deep/tagged/validity/access branches. Its conversion is
an existing range-check root. `N_Simple_Return_Statement` at `29570–29606` selects
this route once. Assignment of a function result has its separate existing
assignment conversion root; use the declared result subtype, not a hidden
caller-specific return fact.

`flow-analysis.adb:6442–6725` checks implicit Always_Terminates. The accepted
full-domain bodies have finite loops, no exceptional-only return path, no direct
or mutual recursion, dispatch, indirect equality or potentially nonreturning
callee. The procedure emits exactly one successful info/flow
SUBPROGRAM_TERMINATION record at `6712–6722`, after all these checks. Its message
is `implicit aspect Always_Terminates on "<source function>" has been proved,
subprogram will terminate`. The report policy requires one witness per source
function, including unused functions, and retains every emitted check.

The source review additionally exposed unused-parameter/local diagnostics at
`1277–1364` and ineffective-import diagnostics at `1372–1445`; native corroboration
and exact source-applicable classification are still required. Do not treat this
note as evidence that the first report-policy draft handles these diagnostics.

## Identity and dependency multiplicity

`gnat2why-assumptions.adb:48–69` uses hashed claim sets and a map from claims to
assumption sets. `Register_Claim` at `110` uses Include; `133–136` unions the
assumptions for each caller claim. Repeating a call does not duplicate an edge.
`142–156` adds one callee EFFECTS token to the caller EFFECTS claim and two
callee EFFECTS/AORTE tokens to the caller AORTE claim. A callee POST token exists
only for an explicit postcondition (`147`); local function contracts are excluded.
Only established claims are serialized (`88–103`), and `163–190` establishes
AORTE with a POST claim only for explicit postconditions. Thus a local static
call contributes at most three dependency tokens; each local function contributes
at most two emitted claim headers (EFFECTS and AORTE).

`assumptions.adb:93–111` serializes each dependency as predicate plus numeric arg.
`assumption_types.adb:266–276` interns and emits numeric IDs; `282–299` emits the
full name once in the entity map. Locations are one main.adb declaration because
source instantiations remain excluded. The selected native report also shows
numeric IDs in flow/proof, coverage and timing maps. The function spelling occurs
in entity.name and its one termination message; names are not multiplied through
call dependencies. Timing keys and cardinality retain the existing reviewed
prover/counterexample-driver closure: docs/report-capacity.md:139–152 bounds
32 keys * 160 bytes per owned entity, not one additional timing map per call.

## Combined envelope proposed to the lead

Existing check-site reservations extend to each Integer actual using its preceding
call `(` or `,` plus a byte of its leftmost value token; Integer actuals contain
no Boolean comparisons, and nested array access uses its own parentheses. A
terminal return conversion uses two bytes from its `return` keyword. Result
assignment retains its own `:=`. Boolean actual/result conversion adds no scalar
range check; its internal expressions retain the existing checks. No inlining
multiplies body checks per call. The inherited 5,689-check envelope therefore
remains a conservative allowance for the shared 4,096-byte source.

Let F <= floor(4096/32) = 128 functions and C <= floor(4096/8) = 512 static
calls (`A:=F(B);` is the shortest selected call statement). Retain the old complete
31,822,336-byte bound, including its conservative overlaps. Add fixed per-function
charges of 1,024 termination bytes, 512 entity/coverage bytes, 2*256 claim-header
bytes, and 32*160 timing bytes, plus 3*256 dependency bytes per static call and
4*S name bytes. The 256-byte token/header choices dominate the existing inspected
89/133-byte encodings; entity/coverage 512 dominates 229+32 excluding the separately
charged variable function names. The unchanged 1,024 flow allowance dominates
the termination record's fixed portion. All source names are ASCII identifiers.

Added = 128*(1024+512+2*256+32*160) + 512*(3*256) + 4*4096
      = 1,327,104 bytes.
Combined = 33,149,440 bytes < 33,554,432, leaving 404,992 bytes.

This proposed feature-local account still needs integration review, especially
applicability of the existing fixed formatting/timing premises and classification
of the unused-formal/local diagnostic routes. It is not a capacity rewrite,
allocation increase, empirical peak-memory claim or proof-completion bound.
