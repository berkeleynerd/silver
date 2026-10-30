# Boolean header and program integration

Issue #291, Linux x86_64, 2026-10-30. Implementation commit `65ce0d6d54`
depends on the ordered declaration trace in `4e460c00e2` and the earlier
per-initializer/frozen-value proofs in `1b0c2a295a`.

`BooleanHeaderAt` connects the actual mixed declaration region in the accepted
header to its unique ordered Boolean declarations and original initializer
checks. The header proves the initial Boolean count is zero and derives exactly
the final initialized-name and mutability analysis. `decodePrefix` and
`SourceMeaning` retain both lists; source meaning, uniqueness, validity and
execution/discharge theorems now include that trace. `Program.checks` retains
both raw and frozen Boolean initializer obligations and the body's Boolean
analysis. Boolean assignment participates in source and statement selectors.

The integration replay also repaired a previously missed loop connection:
`LoopAt` now retains `context.elaborating` in both bound readings, matching the
producer. Its semantic proof retains the explicit `bodyMode = false` premise
and no longer simplifies just one side of the range equality prematurely.

Validation: managed run `20261030T112011-d69c83717868`, Lean 4.34.1,
`--target Silver.Current --target Silver.PredicateSelectors --workers 2
--threads 1 --memory-mb 8192`. The incremental build passed in 46.179 seconds;
the fresh transitive axiom audit passed in 7.105 seconds, covering 156 modules
and 17,972 declarations with only `propext`, `Classical.choice` and `Quot.sound`.
`git diff --check` also passed. Exact touched-file hashes, the runner's captured
input digest, phase times and full log are retained alongside this record.

This is focused validation with retained successful dependencies. It is not a
clean build, independent kernel replay, complete source-correspondence audit,
native proof run or independent review. Earlier failed attempts remain in the
managed ledger; the substantive failure and repair are recorded against
`20261030T110818-e1c575689ff7`. No obligation suppression, axiom or unfinished
proof was introduced.

The subthread continued with its inherited model and effort after a context
handoff; the handoff did not retain their selected names, and runtime
confirmation and token/cost measurements are unavailable. No setting change is
claimed. The measured times above describe this final focused run, not total
subthread elapsed time. The next required work remains the actual native/source
Boolean declaration bridge and complete integration validation.
