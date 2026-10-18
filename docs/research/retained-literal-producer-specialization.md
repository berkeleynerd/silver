# Literal Main: source-selected absence of JSON emission

2026-10-18, research #119, Linux x86-64. This joins the already reviewed
[zero-check source argument](retained-producer-zero-check-sources.md) to the
[general producer core](retained-producer-composition.md). The literal-output
aggregate had applied the general hypothetical JSON-size condition even though
its Main source family never reaches that serializer. Removing that condition
is a source-path specialization. No tool limit, required obligation or production
admission rule is changed. Whole literal-pipeline capacity remains unfinished.

## Source and consumer join

The callable recognizes the complete direct-literal shell: qualified Put and
Put_Line calls, optional null statements, the ordinary Main/SPARK wrapper, and
no declarations, branches, loops or other actual expressions. It enforces the
current ASCII alphabet and an ordinary String's static last index. Comments,
case and doubled quotes are handled by the existing complete recognizer.
Unsupported syntax cannot select the zero-check branch through a caller-supplied
Boolean. All producer counters are derived from the same source bytes.

For each literal of decoded length L, its lower bound is 1 and last index is L;
0 <= L <= Integer'Last includes the null String case. The literal translator's
static-bound arm leaves Checks true: the known-high-bound assertion checks
1+(L-1) <= Positive'Last. The nonstatic range-check constructor is not selected
(`gnat2why-expr.adb:30604–30623,30650–30661`). The earlier source argument covers
the unconstrained parent String conversion, no-precondition Put/Put_Line call,
generated literal type and enclosing Main wrapper. A sequence sums zero new
registered Why3 checks; its global-effect roots remain the same fixed set.
These exclusions depend on syntax and contracts, not on successful execution.
The argument is independent of the old 4096-byte source cap; native frontend
capacity and all remaining construction bounds must still hold separately.

The driver snapshots Num_Registered_VCs_In_Why3 before entity translation
(`gnat2why-driver.adb:507–508`). Both Print_GNAT_Json_File and Run_Gnatwhy3 are
inside the strict-increase guard at lines 598–606. The generated ordinary types
introduce no additional checked entity. Therefore this Main process emits zero
`.gnat-json` files and starts zero Why3/solver processes. Its per-file JSON
column-count condition is vacuous. This does not remove producer tree building,
imports, intern pools, undo state, flow processing or final `.spark` output.

The original zero-check identity file predates the indexed-Main repair. This
packet retains its unchanged external SPARK source identities and pins the
current local driver and IO specification separately. The current driver still
selects output verification with `-U`; indexed unit discovery changes neither
the library contracts nor the SPARK driver's emission guard. This packet does
not claim the older local-source hash matches the current driver.

## Exact predicate change

The general producer callable supplies its original bounds. The specialization
retains every conjunct except `json_bytes <= 2147483646`: node/list/element
capacities, the conservative occurrence envelope, both intern pools, symbol-map
and source-node domains, conservative String bounds, and scoped undo peak.
An executable equality check detects divergence between this partition and the
pinned general predicate. The old JSON estimate is retained and explicitly
labelled hypothetical; actual Main JSON output is zero.

Keeping the conservative occurrence and quoted-String conditions avoids
claiming any further arithmetic refinement. Their removal is unnecessary for
this join. Five fixed-library Why3 inputs remain selected; neither their JSON
budgets nor their Why3/solver capacity arguments are waived. A source shape
outside this literal family must use its own applicable general argument.

## Evidence and scope

The [offline packet](../evidence/retained-literal-producer-specialization-20261018/README.md)
checks source identities, the emission guard, syntax boundaries, retained
conditions and arithmetic on actual source bytes. The 8,192-character literal
and 5,000-call cases previously failed the hypothetical JSON envelope while
their remaining core inequalities passed. The specialized core passes those
cases without changing any live representation bound. These are arithmetic
results for an incomplete pipeline, not native acceptance or expanded support.

No compiler, GNATprove, Why3, solver or Lean run is required for this join.
The existing relevant-source-behavior premise remains explicit. Independent
review must assess the source argument and its attachment to the aggregate;
hash checks and successful example arithmetic alone are not that review.
