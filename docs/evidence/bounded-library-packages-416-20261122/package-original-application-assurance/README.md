# Original native application assurance for every runtime argument list

Refs #416. `ApplicationPackageOriginalAssurance.interpreted_bound_assurance`
starts with acceptance by the checked native Analyze interpretation, arbitrary
caller locals and the full native Bundle representation. It derives a source-only
`SourceMeaning` for the original selected specification, package body and Main,
plus separate native domains, complete checking, library semantics, original
initializer-value correspondence and runtime execution safety.

`SourceMeaning.runtime_sound` derives the original argument declaration and
fallback, constructs Main's String/Integer/Boolean stores from its source
inventory, and invokes the existing application execution theorem. Its result
quantifies over every runtime argument list, including no argument, invalid input
and empty input. It proves checked/executable agreement, valid observable
effects, no output for invalid input, final String/scalar/declared ranges and
the package-state invariant. All package routines, including unused ones,
remain checked over their declared domains; every original function preserves
globals at its actual completion prefix.

The endpoint derives specification/state/routine/Main obligation discharge and
original constant/state RHS evaluation separately from `SourceMeaning`.
`ReaderEffectsImports.bound` discharges all remaining primitive effect equations
from the canonical native source dictionaries. No successful semantic decoder,
checker, coverage or safety certificate is an additional admission premise.

Focused Linux validation of `Silver.ApplicationPackageOriginalAssurance`
passed with a fresh 95,942-declaration transitive axiom audit. CPUs 0–1,
automatic two workers and two threads per process, 8192 MiB per process. Every
captured source input was rehashed with none missing or changed. The two owned
endpoint modules and both new imported adapters also match their protected
proof-workspace copies byte for byte; `source-recheck.json` records those hashes.
The first run exposed missing copies of checked native composition imports in
this private worktree; the complete checked closure was synchronized before
the successful run. No proof contract, domain or budget repair was needed.

New external prerequisites are checked `a76db780b2` (Main runtime initialization)
and `584a446186` (canonical effect-reader imports), plus the earlier effects
closure through `4a1f575243`. They were synchronized as baseline and are not
included as owned changes in this commit. The complete import closure is
recorded by the retained managed evidence.

This is the focused original semantic endpoint, not whole-project or native
validation. The literal authoritative-source companion (`SourceActual`) and
complete native/whole-project checkpoints remain the lead's integration work.
No native/source/script edit, OutputBody/SourceActual launch, merge, publication
or feature-completion claim was made.
