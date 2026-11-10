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
| `20261110T012615-5f6273a4685d` | Build passed | Integration compiler rebuilt after prefix-refinement repair `d18b7adf6c` (author `51752014fc`). |
| `20261110T012642-4eb88a60f0f1` | One method with five controls passed | Prefix `in` refinement agrees with ordinary-body and `in out` refinement, both short-circuit operators admit the guarded division, and unguarded division remains rejected. |

The native policy fixtures reserved two workers; the admission-only run reserved
one. The latter completed in 33.244 managed seconds (26.788 unittest seconds).
The earlier failed run remains failed. Its repaired fixture and the separate
literal-fixture repair `56359b4e3d` do not change compiler behavior.

The later build and prefix checks each reserved two workers, alongside the
coordinated native and Lean streams. The prior 21-method run predates this
new regression and is retained with its original scope; it is not relabelled
as a complete final regression run.

These checks do not establish complete native obligation discharge, application
proof/build/execution, Lean source correspondence or final regression coverage.
Those remain pending for #370.
