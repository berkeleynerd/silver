# Procedure integration checks, 2026-11-10

These are focused Linux x86-64 development checks on the integration branch.
The adjacent compressed events and logs are original runner output; this README
and `summary.json` are lead-authored indexes. The events retain the captured
input inventories. Each compressed payload was compared with its original.

| Managed run | Result | Scope |
| --- | --- | --- |
| `20261110T002855-07d248dec12d` | Failed: four methods passed and two failed | Literal alias controls and report policy/capacity. Both failures came from a native test fixture missing the required `with Silver_IO;` context; they occurred at the fixture's admission assertion. |
| `20261110T003131-8ba08182f350` | Two methods passed | Native procedure/output coverage and initialization-policy mutations after fixture-only repair `9b577b042d`. Function termination remains required. |
| `20261110T003417-d9fd8ac62af0` | Two methods passed | Compiler driver accepts the exact 64 MiB report boundary, rejects the next byte, and preserves full original reports while projecting opaque proof trees. |
| `20261110T003856-52403809587f` | All 21 admission-only methods passed | Complete current procedure admission inventory, including full declared output ranges, prefix initialization, aliases, literal spelling, hiding, calls, copy-back and source/operator boundaries. |

The native policy fixtures reserved two workers; the admission-only run reserved
one. The latter completed in 33.244 managed seconds (26.788 unittest seconds).
The earlier failed run remains failed. Its repaired fixture and the separate
literal-fixture repair `56359b4e3d` do not change compiler behavior.

These checks do not establish complete native obligation discharge, application
proof/build/execution, Lean source correspondence or final regression coverage.
Those remain pending for #370.
