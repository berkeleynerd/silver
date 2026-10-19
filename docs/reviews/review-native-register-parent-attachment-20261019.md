# Independent review: native parent design and register attachment

2026-10-19 UTC, owner-authorized research [#145](https://github.com/berkeleynerd/silver/issues/145)
within [#119](https://github.com/berkeleynerd/silver/issues/119), including the
collector correction [#146](https://github.com/berkeleynerd/silver/issues/146).

**Accept both bounded inputs; no material findings or candidate rework.**
The parent packet supplies a concrete finite-state materialization/process
design. The register adapter attaches the accepted conditional source arguments
and makes the corrected 51-owner ledger and 408-condition maps authoritative.
Neither establishes complete native capacity or a production implementation.
The parent's SPARK/Bronze/Silver/Lean implementation and source correspondence
remain mandatory in [#89](https://github.com/berkeleynerd/silver/issues/89).

## Frozen inputs

| Input | Original implementation | Local integration |
| --- | --- | --- |
| Native materialization and parent design | `4438f8c92ae8a709e0ffa683dfa9d791cdd1925d` | `9e3efd03969544af838d2c6d24986c12c816559b` |
| Register and corrected collector attachment | `0b34651ded7b3bbc0c792595d5db8073df1689f6` | `0d5ffa5d9559aa179396c80875191af208d98997` |

Reviewed the [parent note](../research/retained-literal-native-materialization.md)
and complete [seven-file packet](../evidence/retained-literal-native-materialization-20261019/README.md),
and the [register note](../research/retained-literal-register-completion.md)
and complete [seven-file packet](../evidence/retained-literal-register-completion-20261019/README.md).
All **16 files**, including both notes, matched original Git bytes. Python
syntax, JSON records and nine round-artifact identities passed checks.
Worktree: `tmp/native-source-completion-review-20261019`; final implementation
input: `0d5ffa5d9559aa179396c80875191af208d98997`.

Reused the accepted [register source review](review-native-register-source-completion-20261019.md)
`9967a422b62db99a2e759a962dc5fcce366e9285`. Its recognition, outer-IRA and
LRA source arguments were not reopened or replayed. This review challenged the
new algorithms, joins, collector ownership and current predicate propagation.
Selected source/configuration, coherent-filesystem and Linux ABI premises remain.

## Parent argument challenged

The copier's prefix invariant and `Pending = Loaded - Cursor <= Remaining`
justify partial reads/writes and checked arithmetic for arbitrary lengths
through INT64_MAX. Positive writes decrease Remaining; reads decrease the
phase in the lexicographic progress measure. EINTR preserves state without a
retry counter. Explicit external progress/error assumptions cover indefinite
interruption. Zero/error operations and an extra byte at the final exact-EOF
probe cannot report success. Fixed arrays use a bounded reader, not an opaque
Silver-owned materializer.

The immutable recognized source handle is seeked and copied without pathname
reopen. Exclusive outputs, checked closes and fixed-source timestamp/extent
checks support same-source induction under the stated filesystem premises.
Generated Main/binder outputs remain actual producer outputs. Linux interrupted
close is not retried on a potentially reused descriptor.

The graph has twelve input files, six directories, eight generated outputs
and four jobs. Eleven fixed payloads occupy 18998 bytes; Main alone streams.
Checked appends prevent overflow before indexing or addition. The disjoint
State payload is **53100 bytes**, plus a conservative 2048-byte alignment
allowance, below 65536. U16 offsets, U8 counts, signed interfaces and record
strides fit the selected representation. ABI realization and correspondence
remain implementation obligations; this is no RSS or available-memory claim.

Any supplied invocation must equal a fresh accepted actual-source invocation.
The exact argv/environment maxima are 1493/563 bytes. Bounded C vectors include
string NULs and null pointer terminators; path components and full paths have
separate bounds. Four direct fork/chdir/execve/waitpid jobs use absolute
executables, exact environment replacement and stable arenas. There is no
shell, inherited-environment merge, diagnostic capture or unbounded collection.
Only status zero advances the job ordinal. Wait failure retains the unresolved
PID and cannot report completion. Producer/consumer edges preserve actual
artifacts but do **not** prove child compiler, binder, assembler, driver or
linker capacities. `production_launcher_adopted` correctly stays false.

## Register and collector argument challenged

The public route freshly evaluates the accepted recognition predecessor;
there is no arbitrary-prior attachment API. Full source/count/configuration/
owner validation and exact schemas precede prerequisite branching. False/null
prerequisites skip transfers, preserve old conditions, add 41 nulls and leave
the current verdict false. Successful prerequisites import 18 outer checks
plus conjunction and 21 LRA checks plus conjunction: **408 current names**.
All six imported LRA implications must follow from retained guards; failure
is an invalid join rather than a silently added admission restriction.

The new owner is exactly two REG, one SET and one detached INSN constructors.
Fifty distinct historical rows remain unchanged; one disjoint four-event row
is appended after validating old sums, rounding and page/vector arithmetic.
These constructors introduce no finalizer, pseudo, UID or chain event.
For old event count E, the adapter recomputes E+4 active pages,
`next_power_of_two(max(128, E+4))` pointer capacity, pointer bytes, four affected
representation checks and their collector conjunction. This covers growth
thresholds and individual pointer-request capacity, not just a displayed sum.

Both current maps and the 51-row ledger are authoritative. The exact old
367-condition/50-owner result is explicitly retained as superseded historical
GGC evidence. A failed corrected guard blocks both map conjunctions and all
current capacity summaries even when the historical predecessor succeeded.
Disjoint owner completeness remains distinct from capacity. Broad native,
parent, proof, pipeline and admission flags remain false.

## New evidence and disposition

Parent probes passed **113 checks in 0.8072200119931949 seconds**. A fresh
physical C=3/N=4 source (three `Put_Line("review")`, four nulls) was 188 bytes,
SHA256 `2ff7ec03e66731129e3a7c7d3583986e5ca9410cba02c52af1b77d48da3e9dff`.
Checks covered exact state/vectors, source/invocation mutations, byte-exact
partial copying, max-offset/tail arithmetic, zero/error/extra-byte behavior,
C-vector capacity, and failure at all four job positions.

Register probes passed **39 checks in 7.415583972004242 seconds**. A fresh
physical C=7/N=5 source (seven `Put_Line("register")`, five nulls) was 328 bytes,
SHA256 `7498604b49cad3ed860a520edca3a9346a6d87cacd51007e982eeab6dd34dbf9`.
Its actual old/current event bounds were **62121/62125**. Checks covered false/
null skips, corrupt source counts before skipping, ten synthetic page/index/
pointer-byte boundaries, malformed ledgers and corrected-failure propagation.
Synthetic substitutions test interfaces, not source-admission results.

One initial negative fixture put null in an original219 boolean-only slot;
the predecessor correctly rejected it. The fixture was corrected to use a
helper-group null condition and the interrupted script rerun. No candidate
changed. The successful duration measures the complete rerun; the failed-run
duration was not retained. Nine artifact identities passed an additional
0.004936761004501022-second check. Owned TMPDIR avoided the known full `/tmp`
overlay; no shared artifacts were deleted.

Retained author successes were inspected without replay: parent 44768 checks/
15436 reduced states/1.0438260729861213 seconds; register 55 checks/
11.407329016001313 seconds; Hello evaluation/6.979032948991517 seconds.
No native compiler/target, build/capture, prover/Lean, predecessor suite, corpus
or aggregate replay ran. Fresh offline predecessor evaluations served only the
new attachment probes. Finite probes support the design/source argument;
they do not prove the future SPARK implementation.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned. Runtime settings,
tokens and monetary cost are unavailable. Source/check interval:
**14:30:57–14:37:50 UTC, 413 seconds**, including second-input handoff and
fixture repair, excluding report preparation/commit; Linux 7.0.14 x86_64.
Clock time is not model compute time. The subthread harness goal was null;
none was created or changed.

Only this report is committed; scratch remains in `tmp/native-parent-review/`.
No candidate, earlier review, governing document, installation, root index,
GitHub issue, session memory or CLI memory changed. Remaining native integration,
child capacities and production implementation stay with the lead. No new
source task was started in this review.
