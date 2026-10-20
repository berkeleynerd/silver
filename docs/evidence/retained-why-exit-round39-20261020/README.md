# Round 39 exit timing integration

2026-10-20 UTC, #119 / #153. This reconciliation preserves the exact timing
[format](../../research/retained-why-exit-timing-format.md) and
[growth](../../research/retained-why-exit-timing-growth.md) freezes and their
independent reviews. It checks retained input identities and unchanged native
pins without replaying either component checker.

Under the format's normal numeric-service premises, at most 26 timing callbacks
and 1,051 total key bytes give `1051 + 26*348 = 10099` template data bytes and
at most 26 explicit newline requests. This is not complete formatter output:
indentation, prequeued output, callback effects and global formatter state
remain separate. Complete exit/save capacity remains false.

Run `python3 docs/evidence/retained-why-exit-round39-20261020/check.py` from the
repository root to check the frozen integration result. The round ledger
records review scope, measured checks, publication and remaining work.
