# Original package aliases and state reset — 2026-11-27

Run `20261127T225332-f38a22fe6828` passed 73,368 audited declarations across
464 imported modules. All 1,639 captured inputs match locally. Before integration,
the only missing inputs within the imported closure are the two new modules.
Five newer inherited caller/trace repairs on primary are outside that closure;
the complete captured-input comparison records these differences explicitly.

The original actual scan derives bounds for every stored/default row, including
the positive writable-target name span required by Actual_Name_Free. The alias
fold consumes those derived bounds and retains every rejection test. State
reset derives lookup preconditions from its original visibility guard, for
arbitrary metadata; the complete finishing fold then matches the model.
No valid-metadata or completed-safety assumption is added. Final Valid_Body
import closure and the enclosing native call composition remain outstanding.

The first bounds draft needed an explicit initial frame to resolve Lean's
argument inference. The first finish draft needed the imported name-reader
projection exposed and an explicit transitive span bound. Failed logs are
retained; no native source, theorem domain or budget changed. Linux x86_64,
Lean 4.34.1, two workers/two threads, 8192 MiB per process. Bounds used borrowed
CPUs 4–5; the final batch used borrowed CPUs 6–7. Both shares were returned.
Incremental focused build/fresh audit within the host's eight-CPU allocation,
no copied cache, kernel replay or complete feature assurance. Selected proof
role Astra Max; runtime settings are not independently exposed.
