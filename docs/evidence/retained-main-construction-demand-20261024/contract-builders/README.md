# Main contract-builder request partition

Continuation of #202 under #119 after clone-caller freeze
`b5cfa9c1a501eefdd5db89670ca60ccbc399e036`, accepted by independent review
`600455e678775d3ae84d22040e972dc0425bb5f2`.
See the appended [research argument](../../../research/retained-main-construction-demand.md).
Earlier packets and their receipts are unchanged.

`builders.py` turns source-attached entries into internal request vectors for:

- Flat, monomorphic `create_cty`, retaining actual external effects, source
  free-variable restoration, saved-image/type walks, freeze maps, intermediate
  records and defensive resets. Context cases are inspected without opening.
- Saturated applications with closed pure snapshot parameters/results and no
  ghost promotion, including the five ordinary APIs with external state.
- Ordinary Unit tuple replacement, after the preceding application prefix.

`sites.py` joins the six Main origins to their eleven-module clone ancestry
and four explicit executable definitions. `sites.json` retains all other
58 fixed origins and the finite residual native site/branch inventory.
Reference applications, polymorphic signatures, nonzero tuples and the
remaining fixed clone builders are not erased by the current partition.

`exports.json` contains ten focused diagrams. They include twenty applications
with eleven external state keys, aliased actuals, context cases, dead saved
images, empty posts, a reference result, repeated Unit construction and failed
prefixes. These are checkable diagrams, not whole-Main measurements or a new
admission interface. Actual source-fold records supply the production-facing
mathematical inputs and entry multiplicities.

The export carries the accepted term/map byte subtotal, new source helper and
constructor-family candidates, top-level builder map cardinalities, memo
reads and Ident/Hsty/Hsity requests/endpoints. **Complete native bytes remain
open:** new Ity local closures/frames and shared hashcons backing/hash/equality
services are not assigned the accepted term kernel's 4,096-byte coefficient.
Kode/SP/WP and later printing/failure continuations remain separate.

Run only the new focused checker from the repository root:

```sh
python3 docs/evidence/retained-main-construction-demand-20261024/contract-builders/check.py
```

Initial author result: **276 counted checks passed in 1.157710 seconds**, Linux
x86_64. The earlier 270-check success preceded added source questions about
ordinary-record tuple-table lookups and Unit's discarded rho preid. No native,
compiler, prover, solver, Lean or predecessor-checker main was executed.
Model/effort, elapsed time and
unavailable runtime/token/cost measurements are recorded in `round.json`.

Independent review `7fe4a33a75b5ed9346ca5cff4f72b14aa8bcf511` found R1 (#213) in
the initial freeze `49c18b7ef37967c8b6f486721fd006d61857a8fb`: a failed
argument's map add was omitted even though sibling native arguments permit
it to run before the type match fails. The repair charges the current
nonidentity add before the possible failure, giving an upper envelope for
either evaluation order. Earlier adds remain spent and later pairs, term-map
Tvars and completed contracts remain absent.

The first-pair regression failed against the original builder, as retained
in `failure-before-r1.txt`. The repaired checker passed **299 counted checks
in 1.224688 seconds**, Linux x86_64, including first-pair and second-of-three
mismatches and exact comparison of all ten original exports. The original
`exports.json`, `sites.json`, `result.json` and `round.json` are unchanged.
The command above now writes the two new diagrams to `exports-r1.json` and
its result to `result-r1.json`; `round-r1.json` records the repair inputs and
timing. No native or predecessor-checker execution was added. Independent
review of the repair remains pending.

Oracle, admission, tool/source pins, process-wide `e <= 2`, two save-entering
callbacks and three saves are unchanged. #202/#119 remain open; production
#88–#94 remains unstarted.
