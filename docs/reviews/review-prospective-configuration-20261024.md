# Independent review: prospective fixed-report configuration

2026-10-24 UTC. **One P2 finding in the exported pathfile predicate.** The
constructive design at author `9432b9d69498cce7e2474d7a96c4adc37f97b7ae`
otherwise supports its declared conditional scope. Accept its source-selected
environment/runtime/path design, subject to correcting the executable predicate
before calling that predicate an exact implementation of the interface.
The finding does not establish that the selected GPR route produces a bad path,
invalidate P=188 under the stronger prose contract, or describe a production
regression. Production realization remains future #88/#89 work.

## F1 — reject repeated trailing separators in the exact pathfile checker

[`recipe.py:132`](../evidence/retained-fixed-report-composition-20261024/prospective/recipe.py#L132)
uses `v.rstrip('/') not in allowed`. This accepts any number of trailing
separators, although the
[`README` source-search relation](../evidence/retained-fixed-report-composition-20261024/prospective/README.md#L179)
permits an optional single trailing slash and identifies `pathfile_entries`
as the entry check. The same implementation also checks object pathfiles.

The independent [audit receipt](../evidence/review-prospective-configuration-20261024/result.json)
retains a concrete input: the 173-byte selected runtime source directory,
followed by 256 slashes and LF. `pathfile_entries` accepts and returns the
429-byte directory unchanged. Appending `system.ads` produces a 439-byte
pathname, exceeding both report P=188 and the frozen sufficient Arguments
endpoint 395, while remaining below the separate 4096 native path operand.
No native file operation or compiler run is needed to demonstrate the mismatch.

The selected GCC source does not justify assuming those separators disappear:
`osint.adb:403–428` sends each pathfile line to `Add_Search_Dir`;
`:654–656` installs `Normalize_Directory_Name (Dir)` in the source search table;
`:2127–2128` copies an already slash-terminated directory verbatim. Then
`:1899–1901` concatenates that directory, the basename and NUL, and
`:1917–1918` interns the full spelling if the regular-file lookup succeeds.
Filesystem equivalence to the short directory is therefore insufficient for
the byte-level predicate. This source argument concerns the reachable consumer
behavior for such an input, not an observation that the selected GPR producer
emits it or that an actual report contains it.

**Required narrow correction:** compare each raw entry with the allowed
directory spellings and, where permitted, exactly one added slash. Do not
merely normalize a copy used for the predicate while passing the original
bytes to the native consumer. Retain a targeted repeated-slash rejection case
for both source and object pathfiles. The source-generated ordering,
multiplicity, complete-child-input relation and storage duties remain intact.

The exact constructor proof could independently exclude this input. That is
why this is an exported-checker mismatch rather than a counterexample to the
entire conjunction of documented predicates. Nevertheless, the promised
check-before-consumption alternative must implement those predicates; the
current helper is too permissive to serve as that check. The author files are
unchanged and this report freezes the finding before repair.

## Other reviewed obligations

The initial environment is constructible directly from empty with only PATH,
LC_ALL and TMPDIR. GNSA absence is required before elaboration because
`configuration.ads` computes its support prefix at that point. The copied
Image-overlay GNATprove preserves I under GNATCOLL's link-resolving executable
discovery; replacing it with a symlink to the vendor parent would not establish
that property. Bootstrap's copy/link distinction agrees with the packet.
The author receipt identifies the copied ELF, linked vendor tools and existing
compiled Silver Image adapter separately, including generated vendor binding
and selected solver/server discovery. Those are frozen observations under the
existing stability/source-identity premise, not new attestation or private
protocol evidence. The independent audit did not repeat their installation
hashes or service queries.

The explicitly absolute RTS is forwarded through the parent GPR2 tree and
all GPRbuild phases. `gpr-conf.adb` normalizes that absolute value and feeds it
to gprconfig; `gpr-knowledge.adb:4641–4643` assigns Runtime and Runtime_Dir,
and `:3969–3973` preserves both in the selected compiler. An independent
evaluation of all 63 frozen base XML files finds exactly one changed
configuration: `gnat.xml[13]`, from unselected to selected, for both target
spellings. It adds RTS to Compiler leading switches and Binder required
switches without changing naming, mapping or include-path attributes.

GCC still consults runtime pathfiles first for an absolute RTS. The explicit
absence of `ada_source_path` and `ada_object_path`, including dangling
symlinks, and the physical R/adainclude/adalib relations select the intended
directory branches. Same runtime source identity reuses the accepted complete
1,575-file corpus and Source_Reference exclusion; no corpus rescan is needed
for this changed selector. Explicit RTS bypasses ordinary default search,
but does not bypass earlier effective include/object/pathfile inputs. The
packet covers those child inputs, including GPR-generated ADA_PRJ variables.

The source-generated seven-file project is an actual finite witness to the
mapping and naming domains. The review independently extracted its source
names and indexed Main declaration, reconstructed all seven mapping triples,
and checked the order-insensitive exact-multiplicity predicate. GPR's mapping
writer supplies unit/kind, display basename and display pathname; the no-import,
no-suppression project makes the proposed mapping constructive. The accepted
327-byte naming projection remains unchanged. The original user pathname is
not smuggled into the copied Main source or used as an admission cap.

The physical-directory predicates address the prior normalization gap.
Fresh physical W and initially empty T, ordinary controlled descendants and
stability through consumption can exclude symlink expansion of the final
GPR.<PID>/GNAT-TEMP filename. Checking only T or relying on mode 0700 would
not do so; the packet explicitly requires more. Its phase object directories,
saved/active cwd families, mapping/pathfile filenames and source roots follow
the reviewed constructors. It does not treat arbitrary caller-supplied P,
filesystem names or a hand-prepared fixture as evidence about actual native
inputs. The fixture inhabits the design; later refinement must establish
actual GPR behavior or perform complete checks before consumption.

The independent byte derivation agrees with the proposed path demands:
W/T 19/23, project 31, object including slash 34, largest phase cwd 53,
GPR temporary name 59, fixed source 42, Why JSON path 98, RTS/adalib 162/169,
and the runtime filename envelope 188. For the exact 19-entry command, every
represented decimal worker width gives joined command bytes `434 + width`
and configuration bytes `608 + width`; the endpoints are 435–444 and 609–618.
The changed configuration reader guards pass. Actual host worker reservation
is still distinct. The four previously accepted report fits at unchanged
P=188 are reused by identity, without repeating their checkers or arithmetic.

The 168-byte extra RTS switch has a separate native cost. The reviewed switch
store increments one table entry and allocates one String; it creates no
Atree node. That fact does not make table growth, pointers, search-directory
strings, child argv or GPR descriptors free. The packet preserves these
owners and exports the indexed-null 171-byte/one-line ALI delta rather than
claiming unchanged full native allocation or a general fixed-library/Main
storage theorem. Current adapter routing also remains distinct from future
private protocol/output refinement and fresh-session timing/completion
premises; zero top-level timeout does not establish them.

## Inputs, validation and disposition

The review owns only this report and
`docs/evidence/review-prospective-configuration-20261024/`, on a separate
worktree/branch rooted at the exact author. The receipt binds all twelve
author-changed files, the accepted research prefix, 42 repository inputs,
18 complete archived source/configuration files and the supplemental complete
GPR knowledge source. The accepted path author
`bc889215882ea5e3725e593fd092d058504746b5` and its review
`30ccdb6607f5c5f6d4a71bf6a07d40d2f943591e` remain inherited evidence.
The parent supplied authorization, scope and residuals. The reviewer read
AGENTS, Oracle, applicable review/agent workflow and the prior review; the
live harness returned no goal. No goal, GitHub, Oracle, tool pin, admission,
production source or author evidence was changed.

The one independent offline changed-obligation audit completed with F1 in
**0.322889 seconds**. Its first attempt stopped at review-script bookkeeping:
the base XML count inadvertently included the two separate overlay files.
After limiting that set to `db/*.xml`, the corrected audit completed. The
[initial diagnostic](../evidence/review-prospective-configuration-20261024/first-audit-failure.txt)
is retained; it is unrelated to the author's earlier 15-versus-14 project-line
fixture diagnostic. A final editorial correction changed the finding's line
reference from 130 to 132 in script/receipt without rerunning the successful
audit or altering its observed values. No author/predecessor checker, fixture,
native target, compiler, prover, Lean or service ran in this review.

Reviewer setting selected by the parent: **GPT-6 Astra / Extra High**.
Runtime model confirmation and token/cost telemetry are unavailable. Actual
host: Linux 7.0.14 x86_64; `scripts/dev.py paths` reports linux-x86_64.
The [round record](../evidence/review-prospective-configuration-20261024/round.json)
distinguishes the measured review window from unavailable earlier setup time.

F1 remains open for parent disposition and a narrow correction. No other
material finding was identified in this exact changed scope. Actual complete
common path bytes correctly remain null. The existing native warning/header,
source-span/private-fix, Main/five-report collector/SARIF and protocol/time
obligations remain open; #212/#119 are incomplete. Global e<=2, two
save-entering callbacks, three saves and physical-resource premises remain
unchanged. Production #88–#94 stays unstarted and PR #121 stays draft/unmerged.
CLI memory was not updated. Parent integration, issue filing and publication
are separate from this unpublished review freeze.
