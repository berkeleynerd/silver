# Remaining Lean disk estimate while resource-suspended

2026-11-17, read-only assessment requested by the lead while complete run
`20261117T040626-c2b89a81f8a6` remained SIGSTOP-preserved. No proof/source
mutation, compilation, cache/donor change or relocation was performed.

The current approximately 1.74-GiB free margin probably accommodates the remaining
Lean output. A working allowance of **0.5 GiB** is reasonable for affected output
and transient files, but it would take free space below the lead's 1.5-GiB alert
level if the native writer used no additional space. This is an estimate, not a
guarantee or a reason to alter the current SIGCONT gate.

The existing upper overlay already holds the largest output objects:
`OutputBodyCertificate` is 336,837,119 bytes across its artifacts,
`ReviewedOutputShape` 172,422,293 bytes, and all eight output chunk artifacts are
complete. The prior dense composition candidates produce small artifacts despite
their large live heaps: contract 448,796 bytes; declaration 252,534; expression
170,400. Prior Predicate dense candidates are similarly small (about 0.13 to
2.8 MB each). These sizes include both `lib/lean` and `ir` artifact families.

A current-versus-retained-donor source comparison found 68 changed/new source
modules, including 26 additions. Its reverse import closure plus the authoritative
native source binding roots contains 611 modules. Of these, 320 lack a complete
set of upper artifacts by a conservative file-count heuristic. Their prior
artifacts total **341,437,948 logical bytes / 356,929,536 allocated bytes**
(about 340 MiB allocated). Allowing 20% growth and temporary serial output still
fits the 0.5-GiB working allowance. The largest such prior module is about 16 MB.
The heuristic is deliberately not a freshness or successful-validation claim;
Lake determines actual rebuilds. Some counted modules may remain valid in the
lower cache, while newly changed proofs can grow beyond their prior sizes.

As a broader conservative comparison, every lower module lacking complete upper
artifacts totals **995,841,388 logical / 1,031,958,528 allocated bytes**, even
including unaffected cached modules. Re-materializing that entire set with growth
would use materially more than the working estimate. It is not expected from the
observed affected closure, and it is not a rigorous upper bound. Continued native
report growth and temporary files also consume the same filesystem.

For additional headroom, any one of these inactive source-only checkout backings
could recover roughly 0.62 GiB after a separately verified relocation preserving
its original path. Read-only inventory found no active managed lease references,
process cwd/command references or mount/overlay references to these paths, and no
root `.silver` or `.tools` directories. Their only nested `.silver` is a historical
five-file gzip evidence snapshot (6,289 bytes), not a live tool or proof cache.
Their untracked material must be preserved with every file, mode and Git state.

| Candidate under recovery-volume | Estimated allocated bytes, including directories | Retained Git state |
| --- | ---: | --- |
| `rosetta` | 669,659,136 | `549a4d3c99d9b021ce2e38e724266df08443b06c`; untracked `tmp/` |
| `delivery-review` | 671,563,776 | `8671d0955c29677c18ab0cfd33b6037a5fedc44e`; untracked `tmp/` |
| `stack` | 679,116,800 | `cd8cba92a16338d128b91011d3585a576056d02b`; untracked evidence `tmp/` |

The first two are preferable candidates because the stack checkout holds specific
retained recovery scratch. Final selection still needs the lead's full hash/mode/
symlink/Git-state preservation procedure and a live reference recheck. Nothing
has been moved or deleted. The active source overlay, its donor, native canonical
artifacts, and all tool caches remain excluded from relocation consideration.
