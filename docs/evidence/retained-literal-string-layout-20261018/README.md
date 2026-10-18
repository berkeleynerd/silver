# Cold String layout evidence

Research for #119/#131; independent review pending. See the
[source argument](../../research/retained-literal-string-layout.md).

`interface.json` exports the concrete two-helper creation/gimplification,
discard boundary and persistent +2 counters for one cold String conversion.
It explicitly leaves warning-map R and helper allocation quantities null.
It does not alter the aggregate's unknown conditions.

`source-manifest.json` pins 21 complete GCC/Ada source files against retained
identities at GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, and nine
historical Silver input files at base
`6b6e6bea3edc819434893bf496242dd2728830b9`.
`check.py` verifies the bytes, hashes, retained pins, selected argv, source
landmarks/order and the interface's open obligations. These checks support
the manual fold/layout/reachability argument. They are neither a native
compiler observation nor a proof that string matches establish C++ behavior.

```sh
python3 -B docs/evidence/retained-literal-string-layout-20261018/check.py
```

The checker accepts `--gcc-root`, `--ada-root`, `--match-path` and `--output`.
It uses no network; its only subprocess reads historical Git inputs. No
compiler, prover, debugger, expensive capture or native workload was run.
No native worker reservation was needed. The actual host was inspected:
Linux 7.0.14 x86-64. No previous successful native evidence was rerun.

Selected settings: GPT-6 Astra / Extra High, assigned by parent. Runtime
confirmation and token/cost evidence are unavailable. Start 20:01:46 UTC on
2026-10-18; completion and elapsed wall time are in `check-results.json`,
separately from checker runtime. Intended outcome: resolve the first cold
String layout decision and its directly bounded continuation. Achieved:
two helpers, zero canonical/XUT/XVE multiplier, initial gimplification,
discard after Main's initial lowering but before IPA/emission, and +2
symbol UID/order/function-definition/private-name increments. Review is
pending. Allocation and warning residual work was deliberately left at
its named interface, not relabeled as complete.

Owned edits are this directory and the research note only. No aggregate,
Oracle, admission, tool option, GitHub or CLI-memory state was changed.
The parent owns review/integration and the remaining #119/#131 joins.
