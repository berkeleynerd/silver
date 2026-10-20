# Round 40 Debug hook integration

2026-10-20 UTC, #119 / #153. This reconciliation preserves the exact accepted
[first-use/control](../../research/retained-why-debug-formatter-control.md) and
[hook capacity](../../research/retained-why-debug-hook-capacity.md) freezes and
their independent reviews. It checks author/reviewer identities, retained
repository inputs and unchanged native pins without replaying component checks.

The first-use argument supplies GNAT's distinct Debug escape formatter, Buffer
position zero/capacity 42, one dummy queue token, two scan entries and one newline
wrapper. It does not exclude earlier signal saves that failed before exit or
give stdout/stderr fresh state. The once gate prevents the hook from restarting
after partial work. The accepted hook capacity includes those abandoned prefixes.

Under the named source/runtime and normal-service premises, the one hook offers
at most 26,619 bytes, requests at most 684,672 new OCaml object bytes, and adds
at most 16,272 caller stack bytes to explicit service frontiers. Initial plus
new owned objects have a 686,128-byte no-reclamation envelope. The global
three-save/two-callback budget does not restart. These remain conditional caller
results: standard formatter state, complete save/exit, ambient/runtime services
and physical adequacy are not established.

Run `python3 docs/evidence/retained-why-debug-round40-20261020/check.py` from the
repository root to reconcile the frozen integration result. The round ledger
records review scope, measured checks and residual work. Passing reconciliation
does not mechanically prove the source/control argument accepted by the reviews.
