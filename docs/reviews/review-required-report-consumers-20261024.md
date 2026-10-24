# Required-report consumer review

2026-10-24 UTC, independent review for #194 under #119. Selected reviewer:
GPT-6 Astra / Extra High; runtime model confirmation and token/cost telemetry
are unavailable. The first recorded review clock is 02:24:53 UTC, after the
isolated worktree checkout. No native compiler, prover, solver, provider or
predecessor checker run is authorized or used in this review.

Final author target: **`10604f4d219df703499abf7049aa35a91657ec1a`**.
Accepted as a complete conditional #194 consumer interface after the two
medium-severity repairs #203/#205 and low-severity repair #204 below. No
remaining scoped correctness blocker was found. The initial author was
`0a0c4b7ab7bc3ae1a30c5445f94067985b3e1f06`; `299d796eef` increased the
conservative VSS allowance to 512, `d229298028` repaired the output/path
owners, `7ec7ab5d7a` clarified controlled adjustment stages, and the final
commit corrected the parent's summary-output encoding. All preceded the
single independent audit. Exact frozen files and inputs are in the
[audit record](../evidence/review-required-report-consumers-20261024/audit.json).

The accepted #193 dependencies include the actual projected-whitespace
correction `97ee9e21d7` and five-statistics-key correction `df1972ae38`.
This review does not rerun or reopen their accepted writer argument.
The conclusion covers source-derived consumer functions under their explicit
providers and guards. Actual source/configuration/clock/UTF-8 bindings, fixed
library fits, parent descriptor positions and complete #119 composition remain
separate. A false sufficient guard is neither demonstrated overflow nor a
new language restriction. Production #88/#89 work is not implemented here.

## Source and lifetime review

GNATprove's report call follows its data-representation, ALI and GNAT2Why
steps; the recoverable-failure path also reports, then fails. The ordinary
caller propagates reporter errors and the checks-as-errors status. SARIF is
unconditional on that reporter success path. Silver checks Prove success
before inspecting reports. This provides no optional-output exemption.
Both per-file collection handlers catch others, print diagnostics and continue
without setting Error_Code; partial database/results updates can survive.
Neither process success nor SARIF executionSuccessful certifies coverage.

The generated project has one user object directory and explicit sources:
Main alone for null, or Main and the six fixed Silver source files. GPR2's
default tree iterator excludes runtime/configuration views. Under the retained
fresh-directory and artifact/source-behavior relation, the output family has
exactly the five named report units. Both wildcard calls stay in that directory,
and their matching-entry counter resets per iterator. They do not recursively
count the entire filesystem. The complete set must be extended if that
configuration domain changes; matching extra files cannot be ignored.

Ordinary and SARIF collection each parse the full report, including check
trees. Per-file JSON graph holders finalize before the next file, while native
database records, symbols and SARIF results remain. The reporter's symbol
pool spans both passes. Parse_Entity_Table clears only its map/vector and
reimports each entity name and each location filename. Mk_Unit contributes
one additional Find in the ordinary pass. Thus
`U+2*sum(E_i*(h_i+1))` bounds Find calls; unique symbols and hash-consed
subprograms have separate domains. Positive entity keys and native identity
come from the accepted producer relation, not merely JSON byte length.
The absent assumptions configuration disables claim import and transitive
search; serialized assumptions are still parsed and audited by Silver.

The JSON/XString holder bound concerns aliases of a particular backing, not
64 copies of the document. Native consumers retain no JSON graph. The
ordinary database's maps, ordered-output sets, suppression lists and copied
location lists have explicit cardinality/storage owners. Its most-difficult
set is at most eleven during insertion and ten after pruning. Empty shared
Unbounded_String storage does not increment the runtime counter; nonempty
strings have a bounded set of retained owners and sequential local copies.

Summary checks are bounded by `C=sum(F_i+R_i)`. The fresh goal-forest traversal
selects one successful proof per visited goal, or one Checker count for an
empty proving transformation. `S=sum(R_i*(G_i+1))` conservatively covers those
statistics and the native PC_Trivial route. Five prover names include Trivial
and Checker. The source evaluates `100*Part` in Integer before Float conversion;
`100*max(C,S)<=I` is the relevant sufficient guard. Nonempty selected statistics
maps have positive totals, and empty maps bypass division. After percentage
replacement, the later max-steps merge combines at most ten category maps
with counts at most 100. The summary's total map has no separate populated
statistics domain. Max_Time's Float-to-Integer conversion retains the explicit
nonnegative duration ceiling and safe endpoint margin; no observed duration
or added timeout supplies that premise.

## Populated representations and required Silver policies

SARIF appends one result for every flow/proof/warning row across all units.
The reviewed construction has at most one argument, suppression, primary
location, related location and primary logical location per row. No check tree
is copied into typed SARIF. The new record-size calculation traverses the
complete selected declarations and preserves the accepted ABI envelopes;
previous rule/invocation/run layouts are imported without a predecessor rerun.
Generated vectors own their arrays and nested vectors make deep copies.
The `3*Length` growth intermediate is checked before division; a representable
final length alone is insufficient. Result append history ends before the
My_Run and Root copies, whose arrays have populated length.

A particular newly converted text backing begins in one field of one result;
new rows do not alias that backing. At most 32 constructor/aggregate/return
boundaries, eight controlled adjustment stages and two temporaries give the
conservative initial allowance 512. Sixteen additional holders per result/rule
growth step overcharge old/new copies. Output iterates immutable records and
finalizes its local temporaries; it does not retain a copy per emitted character
or per later result. The bound applies separately to heap text and the VSS
argument-vector counter. The argument vector has one Append from null and
no later mutation, so its aligned initial allocation is sufficient. UTF-8
validation, character-count and alignment/spare guards remain distinct from
physical allocation availability.

The push writer stores no whole-document buffer or growing nesting stack.
Its populated schema provides the signed64 output-offset bound; individual
UTF-8 output requests remain small. File_Output error state is checked by
Content_Handlers' convenience methods, which can raise Assertion_Error.
Successful construction of executionSuccessful=True is therefore not a proof
that output, collection or proof coverage completed.

Silver's application reader and all four library readers retain their complete
policies. The latter are required regardless of Main's chosen operation.
Projection retains surrounding whitespace and final LF, so its actual bound
is `projected.pretty+1`. Discarded raw bytes do not consume retained storage,
but their nesting still consumes projection state. Current guards separately
cover the Main/runtime buffers, raw projection depth, scanner depth, cursor
spares and padded reference copies. The native reader checks remaining
capacity before addition/copy, EOF/error, projection completion and close.
Its mathematical byte histories are Ghost=>Static and do not allocate native
whole-file copies. Application and library audit call sites are one-based,
so the generic rebasing-copy branch is bypassed. Entity-reference handling
copies the digit span and adds a blank; it does not parse an arbitrarily long
reference as a machine integer. The null policy separately retains its raw
read and two local whole-report copies.

The fixed buffers and depth 64 are current implementation guards, not language
caps or evidence that every fixed report fits. Future #89 work must refine
source-derived scalable storage, nesting, cursor/copy demands and unchanged
complete policies. The orientation example has deliberately unbound source
inputs; passing it cannot establish fixed-library fits or full #119 assurance.


## Findings and exact repairs

**RRC-1 / #203 — Text_IO character/encoded-byte interface gap (medium,
repaired).** The original collector exported `lines*(line+1)` and its failure
analogue as emitted-byte bounds without a one-byte encoding premise. The
selected installed `a-textio.adb:1273–1388` advances Col once per Character
but can send upper-half characters through Put_Encoded. The accepted
`s-wchcnv` transfer allows two emitted bytes. The same omission affected the
configuration helper's parent `Summary logged in ...` export
(`gnatprove.adb:827–828`), which includes the variable object directory.
Existing loose ceilings were not an encoding derivation; the review did not
claim a demonstrated native overflow.

The repair separates source characters, explicit New_Line calls and encoded
bytes. Strings/backings and Col use characters; Line uses explicit lines;
ordinary file offsets use the twofold encoded bound. The parent's summary
exports at most `O+40` line characters, `O+41` characters including LF and
`2*(O+40)+1` encoded bytes. Its incoming parent descriptor remains a separate
lifetime join. GNATCOLL's full/configuration serializers escape non-ASCII
code points to ASCII, so their accepted file bounds are unchanged. The final
packet retains the exact JSON utility, Text_IO and encoding sources supporting
this distinction. The shared maximum line guard also covers the shorter
stderr diagnostic and success-line operands.

**RRC-2 / #204 — no-check failure diagnostics omitted from the owner census
(low, repaired).** After ordinary collection failures leave no SPARK/check
state, `spark_report.adb:1512–1529` can print the no-check warning, reason and
possible fix. These were absent from the five-lines-per-unit handler census.
The repair charges their fixed text separately and exports `5U+3` stderr
newlines, plus the distinct successful stdout delta. Existing numerical
slack might cover these messages; no numerical overflow was demonstrated.
The explicit charge now establishes their ownership without relying on that
unexplained slack.

**RRC-3 / #205 — common path-provider joins missing (medium, repaired).**
The original compose interface accepted the project path, object directory,
common path bound and per-unit path bounds independently, while the latter
common bound priced parser normalization, sloc symbols and consumer paths.
Their dominance relationship was not exposed. The repair adds the initial cwd
operand and a named demand map for project/object/cwd, config, summary, SARIF,
all required report names and unit source/sloc bounds. Its common-path guard
must dominate all these demands; collector separately checks unit paths.
Artifact_Dir's source binding and GPR2's default-iterator exclusions are now
retained in the packet. This makes the interface obligations checkable but
does not manufacture evidence for an actual cwd or installation path.

The alias clarification is also accepted: eight counts controlled adjustment
stages, not literal record/JSON edges. Optional record wrappers do not
independently multiply leaf holders. The numerical allowance remains 512
plus sixteen per growth step; no alias counterexample was found.

## Validation and disposition

I matched all nine final author files to commit `10604f4d21` before executing
its checker once in an isolated temporary tree, with bytecode writing disabled.
The original author packet was not modified. The audit passed 76 complete
source files, 23 current Silver snapshots and eight pinned inputs, the newly
populated layout calculation, configuration/required-set checks, percentage
and vector-growth boundaries, path joins, encoded-output distinctions, and
raw-versus-projected reader guards. The resulting deterministic record matches
the retained author result except elapsed time. Its
[result](../evidence/review-required-report-consumers-20261024/check-result.json)
and the [review record](../evidence/review-required-report-consumers-20261024/review.json)
retain the exact evidence and repair identities.

Checker elapsed time was 0.401562 seconds; invocation elapsed time was
0.573198 seconds. This was the only independent focused checker execution.
No native compiler/prover/solver, source provider or predecessor checker was
run. The complete review elapsed interval is recorded separately and includes
source inspection, author coordination, repair review and writing; it is not
a native execution time or a model-cost measurement. Selected reviewer setting
remained GPT-6 Astra / Extra High. Runtime confirmation and token/cost telemetry
are unavailable.

Within the stated conditional consumer boundary, no unowned growing local
representation remains after the repairs. The source/owner arguments and
reviewed recurrences support this disposition; passing orientation examples
do not. Retain all source/native, semantic identity, artifact stability,
resource, valid numeric metadata and UTF-8 premises, plus the explicit
Max_Time conversion ceiling. The remaining actual provider joins and scalable
implementation duties remain under #119 and #88/#89. This scoped review does
not establish complete assurance for the current fixed buffers.
