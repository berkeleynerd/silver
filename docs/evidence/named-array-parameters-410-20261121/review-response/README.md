# External review response evidence — 2026-11-22

The [response](../../../reviews/review-pr412-claude-response-20261122.md) retains
all ten finding dispositions. `original-review-{request,launch,exit,monitor-result}.json`
are copied from the completed review directory without rewriting the original
report's approximate timeline. They identify the selected/observed model,
explicit effort selection, fixed source, two-CPU allocation and actual duration.

The repair commits alter only tests, the Horner sample tag and records. Complete
native and Lean evidence retains its original platform/cache/audit scope. The
[input comparison](input-applicability.json) found no mismatch in 145 native
source entries, 1,191 Lean shared inputs, 1,085 workspace-equivalent sources and
2,635 build-captured inputs (including generated/tool files). Independent review
separately confirms the 148 tracked build inputs. No protected source or script
changed. Affected regression results and the final review are recorded separately.

Focused timeout controls passed in managed run `20261122T104832-971d15ff5a61`
on `fix/review-timeout-repair-412`, subsequently committed as `7dd8c1bfb2` and
integrated as `39c6ff1baf`. Two test identities cover success/failure output and
return codes, actual child termination, compiler reaping and preservation of a
partial UTF-8 timeout diagnostic. Test time was 1.027 s; managed duration 2.855 s,
one worker on guest CPU 2 under the host's eight-CPU allocation. The affected
full maximal-expression route remains pending. Independent repair review then
identified that Why3's solvers use separate process groups within the same
session. This first successful control covered only the inherited group and is
not validation of the final required cleanup. Its result remains preserved;
the session-wide repair and corresponding separate-group control subsequently
passed in `20261122T105339-12d0cd057611`: two identities, 1.045 test seconds,
2.862 managed seconds, one worker on CPU 2. Independent review accepted the exact
test-file hash `df8939c8470e50730597866e9c0d2364a37e644495a3f5e09531a3c60f6d7e56`,
integrated as `3258c573a7`. Cleanup covers the actual installed Why3 topology:
separate solver groups within the compiler's isolated session, using supported
host POSIX process inspection.

The fresh maximal-expression route `20261122T105525-650db3ffe211` started from
its launcher at 10:55:24 UTC with six workers,
16 MiB invoking stack and the same reviewed test bytes; [launch metadata](maximal-launch.json)
records its exact command. It is still running. Previous 72–116 minute durations
are estimates for this run, not a measured result. The three-hour test deadline
and production solver limits remain unchanged.

The expanded callable stack regression passed in managed run
`20261122T104947-be031f0bee17`, 41.652 test seconds on the installed primary
worktree, six workers on CPUs 2–7. It sets/restores its own 16 MiB Linux soft stack and audits all declared
callables, while executing the empty Main body. Reviewer admission-only minima
and exact inputs stay in the [stack packet](../stack/README.md).

The [independent applicability review](../../../reviews/review-pr412-repair-applicability-20261122.md)
establishes 783 applicable retained passes plus three fresh passes out of the
787 final identities. Only the maximal-expression result remains outstanding
for regression coverage. The manifest tag deletion changes no executable test
selection, expected output or audit policy; it needs no unrelated aggregate rerun.

The separate focused Claude proof review is running against unchanged
production/proof source `5a4b0ad8ac`. Its eventual report must be considered before
closing this response. No cold proof rebuild or independent kernel replay is
claimed by any record in this packet.
