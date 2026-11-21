# Canonical focused compiler CLI, 2026-11-20

**Both real canonical CLI checks passed on reviewed implementation
`f0a773fbcb9eea9574b037812e888029b7f970cb`: the whole `Decimal` subprogram and
its containing `Silver_Numbers` unit.** These are actual GNATprove executions on
Linux x86-64, not fixture, mock or retained historical producer results. They
exercise focused selection, report validation, policy classification, retained
resource reasons and managed summaries. Complete final native and Lean assurance
remain separate root-owned checks; these successes do not establish assurance
for unrelated helpers or replace complete final audits.

| Selection | Managed run | Selected entity count | Flow checks | Proof checks | Managed seconds | Wrapper seconds |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| `--subprogram silver_numbers.ads:11` | `20261120T161257-f32638bcdacc` | 1 (`Silver_Numbers.Decimal`) | 2 | 6 | 24.091366006 | 25.083964111996465 |
| `--unit silver_numbers.ads` | `20261120T161351-6de9c718e3ad` | 3 | 4 | 14 | 12.091264975 | 13.43822609000199 |

Each command returned zero, reported all selected checks proved (eight and 18),
and finished with managed `focused_policy: final-policy` and the
`focused_report` counts above. The exact unit selection uses its body when the
spec is supplied. The subprogram selection identifies the declaration at line
11 and passed exact coverage validation without contextual inlining expansion.
The unit's three entities are coverage entities, not a claim of three separately
selected helper contracts.

[Final managed summary](status-final.json), per-run compressed events/native logs,
wrappers and actual producer-report archives retain the inputs and results. See
[structured summary](focused-summary.json) and
[producer file inventory](producer-report-inventory.json). Each producer archive
contains the runner-retained `focused-evidence/` tree, including `.spark` reports,
`gnatprove.out` and the exact SARIF invocation. Auxiliary reports do not broaden
the selected assurance scope. Only each successful run's retained snapshots are
used; the shared workspace's later summaries do not substitute for the earlier
subprogram result.

## Policy, setup and isolation

The commands were `python3 scripts/dev.py prove` with the selections above,
`--jobs 3`, task `#379-focused-smoke`, and this retained resource reason:

> Reserve CPU and memory alongside the root native proof and dense Lean rebuild; this small selected unit needs only a small worker allocation.

All three workers were requested and granted; eight were automatically available
on a host exposing 22 CPUs after concurrent root reservations. Native allocation
uses the supported `--jobs` flag. The solver policy remained the complete
compiler policy: `--mode=all --report=all --warnings=error --checks-as-errors=on
--level=2 --prover=cvc5,z3,altergo --timeout=30`. Unit selection changes the
all-unit selector to its whole-unit form; subprogram selection adds
`--limit-subp`. No forwarded budget/output overrides were supplied.

The integration worktree received **independent ordinary copies** of the root's
pinned Alire archive/cache/toolchain/settings trees using `cp -a --reflink=auto`.
Before any Alire launch, only copied settings' absolute cache/toolchain paths
were relocated to integration. [Copy verification](setup-copy.json) checked
**14,676 regular files** with no shared root/destination inode and **80 relative
symlinks**, all resolving within the independent copied tree. Source tools were
untouched. No root file/tool/cache, native job or Lean job was modified or
controlled. No compiler or proof cache was copied.

Normal `scripts/bootstrap.py` then succeeded in the integration worktree; its
[log](bootstrap.log), [timing](bootstrap.timing.json) and [zero exit](bootstrap.exit)
are retained. Bootstrap generated installation-specific bindings/settings and
the standard private Image overlay against the integration-local vendor tools.
It did not build the whole compiler. Alire archive SHA-256 matched its pinned
`09c66bcd8c35dd4b97b72c3d9b76e44caa6964a2db35aba069f396f00f1f64c7` digest.
Resolved packages were GNAT 16.1.0, GNATprove 16.1.0 and GPRbuild 26.0.1; the
GPRbuild executable's own banner reports 26.0.0. This distinction is retained.

The focused runner created its own canonical-policy namespace
`compiler/obj/focused/4a9057104dad17e3/`, with a lock-keyed sibling file cache,
without imported compiler/proof state. The first subprogram check initialized
this namespace through the normal empty-store/marker path. The later whole-unit
check could reuse its same-policy sessions/cache; both generated fresh selected
summaries. The [policy marker](proof-options.json) is retained. These runs are not
whole-compiler cold validation, optional independent kernel replay or a controlled
fresh-versus-cached timing experiment. Their different scopes and cache states
support no speedup claim.

[Source/tool identities](source-tool-identities.json.gz) retain the two runs'
identical prepared inventory of **2,634 input hashes**, 12 selected tool identities
and canonical options. Evidence assembly rechecked all **154 non-tool input
hashes**, all **12 selected tool binary hashes**, and all **148 captured tracked
inputs against the reviewed `f0a773fbcb` Git blobs**. The selected source files
and generated setup snapshots are retained under `setup-inputs/`; runtime binding
paths target this integration installation. Compiler source and runner bytes
were unchanged throughout the successful checks.

## Timing and limits

The subprogram wrapper observed 34.486417 child user seconds, 16.393029 child
system seconds and 338,760 KiB maximum child RSS. The unit wrapper observed
8.835717 child user seconds, 3.129843 child system seconds and 253,652 KiB maximum
child RSS. Each wrapper explicitly set and captured an invoking stack soft limit
of **16,384 KiB**, with unlimited hard limit. `RUSAGE_CHILDREN` maximum child RSS
is not a simultaneous process-tree or host-memory peak. Managed and wrapper
elapsed intervals have different boundaries. Root native/Lean workloads were
concurrent; these are bounded validation observations, not comparative benchmarks.

[Archive manifest](archive-manifest.json) records source paths, sizes and hashes
of copied originals. The producer tar archives use normalized metadata and gzip
mtime zero; their exact member bytes are checked against the inventory. The
managed history was read before launch and its before/after summaries retained.
No full compiler proof, full Lean run, regression rerun, code/test/source edit,
GitHub write, Worca action, commit or CLI memory update was performed by this
subthread. Selected role: GPT-6.1 Sol / High; independent runtime, token and cost
telemetry were unavailable.
