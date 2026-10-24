# Independent review: prospective RTS producer storage

2026-10-24 UTC. **Accept author
`4aab5b0e9cc931965c68bf2450473d3b63f7841a` in its declared local and conditional
scope; no new material finding.** The #216 correction is supported by the
selected source: top-level RTS is 168 bytes, generated compiler/binder RTS is
169, the added ALI row is 172, and the indexed-null file/reader bounds are
29,622,976/29,622,977. This supersedes the earlier exported child-width values,
while preserving their historical evidence.

The packet closes the stated additional light-compiler objects and supplies
configuration-dependent transfer operands. It does **not** establish complete
fixed-library/Main semantic vectors, the producer GPR baseline, the direct
native build graph, actual effective configuration, or whole-toolchain capacity.
Those distinctions are necessary to this acceptance.

## Exact source and configuration correspondence

GPR's raw absolute Runtime and Runtime_Dir remain R. However,
`gpr-knowledge.adb:1410–1411` obtains `${RUNTIME_DIR(ada)}` through
`Name_As_Directory`, whose `:465–475` appends the native separator when absent.
The selected XML does not override that variable. Thus the new Compiler and
Binder literals are `--RTS=R/`, not the top-level `--RTS=R`.
`switch-c.adb:223–228` normalizes the runtime for search, while
`lib.adb:1173–1192` stores the original switch and changes only the driver's
`-fRTS` marker back to `--RTS`.

The review independently evaluated every configuration in the 63 base XML
files across all packages, for both selected target spellings. Default
selection contains 19 fragments; the prospective selection contains 20.
Only `gnat.xml[13]` is added and none is removed. The four selected runtime
macro sites are the two new RTS literals and the existing Runtime_Dir and
linker literals. `linker.xml[82]` is selected in both cases: its literal slash
after the macro produces R//adalib. The linker string is 186 bytes, so the
conservative new GPR Name_Entry object is 234 bytes. Its selection is unchanged
even though its substituted value changes. No native linker is run by the
proof/data-representation phases.

The compiler's physical normalization strips the final separator
(`s-os_lib.adb:2144–2168`). `Get_RTS_Search_Dir` then appends one separator to R
and the bare adainclude/adalib suffix. The two absent runtime pathfiles select
these fixed branches; failed opens return before file-length allocation.
`Add_Default_Search_Dirs` and `Normalize_Directory_Name` yield the documented
source/object directory spellings with at most one final separator. This
supports unchanged report P=188 under the existing physical, source-identity
and complete-child-input premises. It does not reinstate F1's permissive raw
pathfile checker or establish an actual native configuration.

## Compiler search, mapping, argv and ALI

The mapping-selected include branch with Use_Include_Path_File=False supplies
neither an extra include switch nor include pathfile. The retained full GPR
inventory has only the declaration/body references for `Set_Ada_Paths`; the
other literal ADA_PRJ setters clear those variables. The reviewer additionally
checked the archived default-option declaration. The initial empty-derived
environment excludes inherited alternatives. Translation's explicit object
pathfile visits the single project once and contains its own O directory plus
LF; the phase1 and datarep descriptors do not select it. The earlier broader
fixture is correctly distinguished from this source-selected output.

Three conservative primary-slot reservation events plus one source runtime
append give source demand 4. Library demand is 4 for phase1/datarep and 5 for
translation, including the latter's object-pathfile input. Primary-directory
replacement does not append; library normalization/deduplication cannot
increase the charged demand. These demands fit the retained table backings.
The new runtime/search Strings, suffixes, path tokens and 179-byte C open
buffers are priced individually; internal normalization service buffers retain
the accepted 4096 operand. There is no aggregate RAM admission gate.

The exact seven mapping records independently serialize to 489 bytes at the
selected 19-byte workspace. The 506-byte reader object includes the accepted
one-past and ordinary-object allowance. `fmap.adb:278–347` performs one mapping
filename Name_Enter and three name requests per record: 22 requests. Retaining
the old Fmap lifetime demand and adding seven entries is conservative; replacing
it with seven would discard possible later ALI-derived updates. The same
principle retains each owner's already path-adjusted Name operand before
adding those requests. The 35-byte translation object pathfile has a 52-byte
reader object. These are concrete corrections to the transferred objects,
not evidence of a new source read.

Both light descriptors have 18 arguments excluding the executable, 19
including it. Stored phase1/translation switches have counts 11/10 and payloads
246/239, with maximum 169. Switch-table capacity 60 costs 976 bytes under the
accepted sentinel allowance. The separate C argv, decoded/canonical storage,
Ada pointers/Strings and GPR argument-vector objects are explicitly charged.
The switch store creates no Atree, Stringt or Uint node; this narrow source fact
does not assert that the complete allocation trace is unchanged.

The new row is exactly `A ` plus the 169-byte switch plus LF. Main A11 and
unchanged System A10 give Args21 for the retained indexed-null source graph;
translation still suppresses ALI output. The old 789-byte maximum record
dominates the 172-byte row. The ALI argument consumer stores an ordinary
String, not a new GNAT Namet name for the RTS payload. The packet retains the
previous null source-semantic coordinates and recomposes the changed tables,
rather than substituting raw capture counts for a new semantic proof.

Fixed-library transfer retains old Args and overpays all seven current project
sections at eleven rows each, rather than assuming their historical -I/map/
switch descriptors match the new one. The sharper one-row/172-byte delta
applies when comparing the same prior prospective descriptor. The source/path
adjustments, complete fixed/Main ALI operands and semantic vectors still must
be joined by their existing owners. The GPR DW/W-only reader skips A records,
but its raw buffer and GG line reader still need the additional bytes/line.

The separate datarep graph gains one joined -fRTS argument through GCC's
long-option mapping and Ada spec. Its new gnat1 count is 24, fitting the
accepted 24/48 argument/canonical envelope at P=512; the prospective paths and
169-byte switch fit that envelope. Under -S it selects no assembler, binder or
linker child. This reuse covers that retained datarep graph, not the direct
native #201/#89 build.

## GPR deltas and the unclosed baseline

The independent audit extracts the actual XML chunks and follows Merge_Config's
LF/six-space insertion. Adding the command-header R and growth of both retained
runtime-prefix occurrences yields configuration text bounds 7,505, 7,715 and
7,779 bytes. Each still aligns to 8,192 bytes. Shorter future cwd/temp spellings
are conservatively ignored. Selected Store_Comments=False means the changed
command/cwd comments do not add syntax nodes.

Each added clause allocates a declarative item, attribute declaration, outer
expression, reference term, attribute reference, list term, literal-list node,
inner expression, literal term and literal node: ten, hence twenty total.
The package-prefixed attribute-reference branch returns at
`gpr-strt.adb:1080`, before the variable-reference allocator at `:1085`.
There is no discarded variable-reference node to add. The index string is
installed directly as the existing name/index, rather than parsed as another
expression node. The one-name prefix scratch table is separately included.

Evaluation copies the existing four Compiler elements and one Binder element,
then adds one singleton to each, giving seven String_Element allocations.
Those copies remain charged even when the final array/index value overwrites
an existing entry. The fixed project has no user declaration for either changed
attribute, selecting Apply_Config's shallow copy rather than its list-copy
branch. The full seven-cell Name_List conversion is conservatively added over
the previous demand. The reviewer inspected the scanner's Name_Find string
route and the names table's collision/equality return: the three changed
literal spellings are interned; unchanged identifiers and indices are reused.
This is a parsed-configuration literal delta, not a complete enumeration of
all parent/Gprconfig names or allocations.

The Project_Node record has 22 scalar fields; the 352-byte component bound is
conservative. The String_Element and Name_Node bounds and selected table
parameters agree with source. GPR.Names uses an indefinite vector with separate
variable-sized entries, and its append path can double the pointer backing.
The callable arithmetic transports supplied parse/evaluation/conversion
multiplicities; it does not fix all traversals to one. Its endpoint results are
sufficient arithmetic conditions, not observed context sizes.

Crucially, the accepted orchestration packet provides configuration texts and
source-reader allowances, **not** numerical Project_Nodes, String_Elements,
Name_Lists or GPR.Names baselines. The new interface cannot establish complete
GPR capacity by evaluating its own conditional endpoints. The packet's explicit
residual correctly assigns a sufficient baseline and existing capacities,
traversal multiplicities, remaining GPR/Gprconfig containers and parent
allocation joins to #212 under #119. This is neither an unnamed external owner
nor the distinct direct-native #201/#89 graph. Source-derived sufficient bounds
can discharge it later; exact historical AST reconstruction or a new native
capture is not a prerequisite imposed by this review.

## Evidence, settings and disposition

The review used a new isolated worktree at the author, preserving the original
prospective/F1 reviews. The [audit receipt](../evidence/review-prospective-native-20261024/result.json)
binds all 33 changed inputs, 20 provider files, 52 complete archived sources
and two supplementary source reads from the same pinned GPR archive (scanner
and default options). It checks archive/manifest correspondence and the
accepted research prefix. The complete runtime corpus and earlier successful
provider evidence are reused. The author’s superseded checks, failed handwritten
185-byte expectation, corrected 186-byte literal and final 0.435197-second
receipt remain history and were not replayed.

One independent offline changed-obligation audit passed on its first attempt
in **0.401887 seconds**. It used source/data reads and the new pure arithmetic
interface, with no author/predecessor checker, native target, capture, compiler,
prover, Lean, fixture, service query or runtime-corpus rescan. Governing AGENTS,
Oracle and review workflow are unchanged from the earlier bounded reviews;
the live harness returned no goal. Actual host is Linux x86_64 and
`scripts/dev.py paths` reports linux-x86_64.

Reviewer selected **GPT-6 Astra / Extra High** as assigned. Runtime model
confirmation and token/cost telemetry are unavailable. The
[round record](../evidence/review-prospective-native-20261024/round.json)
records the separately measured review window and exact scope. No GitHub,
goal, author, production, Oracle, admission or tool-pin write was made.

#216's corrected exported child/ALI widths are accepted. No additional material
finding requires author repair. #212/#119 remain incomplete; actual complete P
correctly remains null. Native warning/initial-counter/header/source-span/
private-fix storage, fixed/Main/five-report collector/SARIF joins and the future
private protocol/time and physical-configuration refinements remain separate.
Global e<=2, two save-entering callbacks, three saves and physical-resource
premises are unchanged. Production #88–#94 remains unstarted; PR #121 remains
draft/unmerged. This review is frozen without publication. Parent issue
disposition/integration/publication is separate, and CLI memory was not updated.
