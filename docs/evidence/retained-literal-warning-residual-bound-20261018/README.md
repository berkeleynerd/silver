# Original-gigi warning residual evidence

Research for [#119](https://github.com/berkeleynerd/silver/issues/119),
independent review pending. The
[source argument](../../research/retained-literal-warning-residual-bound.md)
derives **R <= 5**, including replacement puts, for the selected literal
family from the prefix stop through entry to Main's `gimplify_body`.
It accounts for the complete selected constructor frontier and gives zero
puts from both size-helper initial gimplifications using plain reserved
locations, without assuming an empty warning map.

`derive.py` hash-checks and calls the frozen warning transfer with R=5.
It exports I=2C+N+5, J=2C+1, occupancy ceilings 4098+2C+N and
4099+4C+N, and at most 4C+N+7 post-prefix map GGC events. It reports the
new source argument closed and review pending while preserving the open
complete-gimplifier, collector, imported-capacity and pipeline flags.
It neither edits the predecessor nor treats the predecessor's historical
unresolved flag as a contradictory claim about this later result.

`interface.json` separately records the generated-body frontier and the
empty elaboration procedure: one function structure, one persistent
function-definition increment, no finalization/gimplification/ordinary
lowering/IPA/RTL/emission. Together with the exact two String helpers,
the non-Main function-definition increment is three. No other generated
FUNCTION_DECL body is admitted by this frontier; the two helpers are
discarded under the frozen premise, so it adds no emitted function.
Allocator totals, empty-elaboration symbol registration and aggregate
counter/label joins are not computed here.

`source-manifest.json` pins 35 complete GCC/Ada files at GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` against existing retained
identities. Thirteen historical Silver inputs are pinned at base
`bd15740afc3453be73f176887724bfbe78da60df`. They include the accepted
warning-map transfer, exact two-helper source/interface, selected frontend
argv, local metadata result and library specification.

```sh
python3 -B docs/evidence/retained-literal-warning-residual-bound-20261018/check.py
python3 -B docs/evidence/retained-literal-warning-residual-bound-20261018/derive.py 1 0
```

`check.py` accepts `--gcc-root`, `--ada-root` and `--output`. It checks full
source/historical identities, route landmarks, the direct Ada warning-site
inventory, retained interfaces, formulas, invalid inputs and the sufficient
occupancy boundary. Its 32 checks pass. The handwritten control-flow and
location exhaustion still requires review; matching source text is not a
mechanical C++ proof. The previous successful warning hash-table exercises
and native evidence were reused, not rerun. `result.json` is the computed
C=1,N=0 example: I=7,J=3, eleven events, occupancies 4100/4103, backbone
capacity ceilings 16381/16381.

Selected model/effort: GPT-6 Astra / Extra High, assigned by parent;
runtime confirmation and token/cost measurements are unavailable.
Start: 2026-10-18 20:20:35 UTC. `check-results.json` records completion
at 20:30:59 UTC (624 seconds elapsed), separately from checker runtime.
Intended and achieved result: close R and make its composition computable;
also answer the parent's generated-body and empty-elaboration counter
question. Checker development corrected literal source-landmark expectations
and a sample-only capacity error (8191 to 16381). The R bound and general
formulas were unchanged. Independent review remains pending.

Actual host: Linux 7.0.14 x86-64/LP64. Native executions: zero; no worker
reservation was required. Only this directory and its research note were
edited. No production, aggregate, Oracle, option, GitHub or CLI-memory
state was changed. Parent owns review and integration.
