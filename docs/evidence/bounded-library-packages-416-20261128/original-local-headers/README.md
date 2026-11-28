# Original routine-local declaration headers

Authorized bounded #416 complete-obligation follow-up, 2026-11-28. This stream
owns only `ApplicationPackageOriginalLocalHeaders.lean` and this evidence packet.
The selected policy category is Astra Max for contract/source-correspondence
design. The available tools do not independently expose this live agent's model,
effort, token usage or cost; those actual settings and measurements are unconfirmed.

The endpoint review found that routine initializer phases retain original RHS
expressions and normalized declared intervals but omit the raw expressions in
local Integer range declarations. Those endpoint expressions have independent
arithmetic obligations. The existing `local_objects_inventory` theorem derives
their source inventory and complete discharge; the new module lifts that result
to every original routine in the accepted package.

`RoutineLocalHeader` stores the original completion row, signature metadata,
entry frame and ordered `(LocalObject, ObjectSyntax)` inventory.
`RoutineLocalHeader.SourceAt` binds those fields to an original `CompletionFrames`
witness, preserves every local object in order, and relates its raw range and RHS
syntax to that declaration's actual incoming frame. `RoutineLocalHeadersAt`
preserves the full completion order, including empty headers and unused routines.
Neither source relation stores a checker, discharge or semantic safety fact.

`RoutineEntriesAt.local_headers` constructs the inventory and separately derives
`Predicate.discharged (routineLocalHeaderObligations text headers) = true` from
the existing native reader domains. `original_package_local_headers` derives
those per-routine domains through `original_frame_facts` and
`history_frame_facts`. It uses the complete original declaration contracts,
without narrowing a source or runtime domain. The module imports
`ApplicationPackageOriginalRoutineEntries`, below the final assembly and assurance
modules. The integration stream owns the `PackageSyntax` and endpoint join.

Focused run `20261128T024621-f1cb69c23bcf` passed on Linux x86-64 with Lean
4.34.1 and a fresh 84,529-declaration foundation axiom audit. All 1,750 captured
source inputs matched after the run. The owned workspace copy and four compiled
artifacts are recorded in `input-verification.json`. The managed command was:

```sh
taskset -c 4,5 python3 scripts/check_lean.py \
  --target Silver.ApplicationPackageOriginalLocalHeaders \
  --memory-mb 8192 --task packages-416-original-local-headers
```

The host is Linux x86-64 with an allowed eight-CPU mask. The assigned CPUs 4–5
yield automatic two Lake workers and two threads per process, with an 8192 MiB
per-process threshold. The managed summary was read before the run. Native source,
shared proof files, scripts, publication and GitHub are outside this stream's
scope. Focused validation does not establish the complete feature checkpoint.

The successful run took 19.817 seconds including setup, with 5.383 seconds for
the build and 4.317 seconds for the fresh audit. The first draft, run
`20261128T024459-f451cd2c75f4`, failed on a missing namespace opening and an
unimported prefix-validity helper. Opening `Compose.Expressions` and deriving
the prefix's validity directly from the existing bundle bounds fixed both.
No checker contract, input domain or proof budget changed. The failed build log
is retained alongside the final run's events, log and evidence.

The integration worktree's audited imported modules differ only in
`PackageEffectSummaries.lean`: its version adds an import and previously checked
effect-agreement/append lemmas, without changing existing definitions. This
standalone evidence describes this worktree's exact inputs; the integration
stream's endpoint check covers the combined closure. The owned module's SHA256
is `1d4b355e06e26c7128ec8446e3935e852d30eccb942b94492e17fe73ea91d0d5`.

The managed run is finished and CPUs 4–5 are released. No complete native run,
source-certificate build, independent kernel replay or publication was performed.
The lead retains the final aggregate join and complete capability validation.
