# Independent review of the Unbounded programs scope — ec82b4e5f2

## Verdict and repairs before “proceed”

**The plan needs correction before implementation proceeds.** Its outcome contract is ambiguous, one retained limit is incorrectly described as forced, and the necessity of the proposed total-source envelope is overstated. There is also an assurance-description error and smaller documentation/process discrepancies. This review found no new executable safety defect in the existing implementation and did not establish that non-gating confirmation inherently requires an Oracle amendment.

Repair these items in the scope and affected issues before an unconditional “proceed”:

| ID | Severity and category | Action |
| --- | --- | --- |
| M1 | Medium — contract ambiguity | Separate unsuccessful-proof classification from the unchanged successful-proof audit. Applying that audit to every report would turn resource-only non-proofs into defects by precedence. |
| M2 | Medium — owner-fidelity defect | Remove or justify the retained Silver-chosen 16,384-byte command cap; stop calling it OS-derived. |
| M3 | Medium — incomplete scope justification | Treat the uniform total-source envelope as a candidate, not an established uniquely forced maximum. Require the necessity/tractability comparison and identify the unresolved build-feasibility stops. |
| D1 | Medium — assurance documentation | Correct the claim that confirmation checks producer completeness and per-program Image applicability premises themselves. |
| D2 | Low — outcome documentation | Reconcile application `Storage_Error` status 1 in the scope with status 4 in #93; specify observable causes and ambiguity. |
| D3 | Low — scope documentation | Qualify “compilation fails only through resource exhaustion” by the existing tool/infrastructure premises and enumerate the remaining failures. |

P1 is a historical process deviation to acknowledge; it does not require undoing the published scope. The smaller precision corrections below can accompany these repairs.

**The supplied retained evidence has been audited.** The owner supplied its evidence branch during this review; the manifest matches the requested hash and all 2,154 listed files match. All 59 pre-publication recommendations were reconciled against the publication. Some underlying measurements remain unverifiable because the original archive intentionally omits large inputs and prover session/report files. Live board Status values remain inaccessible. These are coverage limits, not findings that the missing measurements or statuses are wrong.

## Frozen target and verified relationships

All repository line references below mean the frozen target, not the dirty shared checkout. The review used a separate detached worktree at `tmp/review-ec82b4e5f2-worktree`.

| Reference | Independently verified fact |
| --- | --- |
| [PR #95](https://github.com/berkeleynerd/silver/pull/95) | Title: “Scope unbounded programs and non-gating proof confirmation”; created 2026-10-17 16:37:09Z; merged 16:50:01Z. |
| `ec82b4e5f2bd1d3001e7117fe09e610d7d69658f` | PR merge SHA; first parent `041acd08fb09551ece781c6302cc8b431323703d`, second parent `d2426c99b4cbd990c77029de18a3925c9e8138a0`. Git objects and GitHub metadata agree. |
| `d2426c99b4cbd990c77029de18a3925c9e8138a0` | Sole PR commit; its message contains `Fixes #87`. Its tree and the merge tree are both `6f13ac80dfedb0e3f01bcbd79f04412d8fc66325`. |
| First-parent diff | Exactly four files, +865 lines: scope, curated research JSON, roadmap and session-memory entry. No implementation or proof source changed. |
| [Milestone 5](https://github.com/berkeleynerd/silver/milestone/5) | “Unbounded programs”; created 16:34:56Z; open, with one closed and seven open issues at capture. |
| [#87](https://github.com/berkeleynerd/silver/issues/87)–[#94](https://github.com/berkeleynerd/silver/issues/94) | All belong to milestone 5, have the required title prefix and `type: work package`, and appropriate area labels. #87 closed at 16:50:02Z; #88–#94 open. Their complete bodies, comments and REST timelines were captured. |
| Handoffs | All eight issues have postmerge handoffs at 16:50:21–30Z citing the full merge SHA. They retain the “proceed” requirement and restrict the planning agent to research within #88–#94. |
| [Original evidence branch](https://github.com/berkeleynerd/silver/tree/0cd253d05b2cb650cc8fca81255e9a711765e16a/tmp) | `evidence/unbounded-programs-scoping` fetched and frozen at `0cd253d05b2cb650cc8fca81255e9a711765e16a`; both requested directories extracted without changing the review target. Manifest SHA-256 `7848544990640d8609ed9d2b445417b19b432973d5597465cdb3adf705af9a63`; 2,154/2,154 files match, with no missing or unmanifested research files. |
| [Board 6](https://github.com/users/berkeleynerd/projects/6) | Project access failed because the credential lacks `read:project`; an in-app browser attempt returned GitHub “Page not found.” REST issue timelines show project/status events but omit the values. #87 Done and #88–#94 Backlog are documented in comments, not independently verified live board state. |

Actual execution host: Darwin arm64, `mini.local`; `scripts/dev.py paths` identifies `macos-aarch64` in both checkouts. The shared checkout was at `b8b263ded5f7d5371e6861db81a093e369a33682`, with extensive unrelated edits. Those edits and its current Oracle were not substituted for the target’s contents. The target commit was fetched without moving the shared branch.

## Defects in the proposed design and scope

### M1 — Outcome precedence does not distinguish expected non-proof from audit defects

**References.** [Scope lines 79 and 135–141](https://github.com/berkeleynerd/silver/blob/ec82b4e5f2bd1d3001e7117fe09e610d7d69658f/docs/unbounded-programs.md#L135-L141); [#88](https://github.com/berkeleynerd/silver/issues/88), “What confirmation proves,” outcome classification and the completion criterion that the report policy and accepted diagnostics are unchanged. Implementation/specification: `src/silver_library_reports.adb:1301–1315,1397–1403`; independent Python audit `scripts/check_evidence.py:491–498`; regressions `tests/test_library_reports.py:161–171,760–762`.

**Violated claim.** Resource-only unsuccessful confirmation is Inconclusive/status 4, while defects override inconclusive results. The owner requires failures to be reported honestly without redefining membership or treating failed checks as success.

**Minimal reasoning.** Take a genuine Main safety check that no prover proved and whose attempts all ended with `Timeout` or `OutOfMemory`. It meets the proposal’s Inconclusive condition. The unchanged exact auditor nevertheless rejects it: successful Main safety records must have `severity = "info"` and `how_proved = "prover"`. If that audit is applied to every report, as line 79 suggests, the Defect condition includes the rejection and takes precedence: the same input becomes status 3. Interruption before complete reports creates an additional overlap between expected incompleteness and audit rejection.

**Impact.** Two reasonable implementations produce different statuses for ordinary resource exhaustion. The plan does not specify the branch order or unsuccessful-report policy needed to resolve that difference. This is a contract ambiguity, not a claim that the current gated compiler accepts unproved checks.

**Counterevidence.** Preserving the exact existing policy for Confirmed is correct. An implementer can first classify unsuccessful reports and invoke that exact audit only for Confirmed candidates; the design is therefore implementable. But that separation and the unsuccessful-report structural checks must be written down, not inferred from conflicting conditions. The pre-publication technical recommendation 10 used the clearer “all ended without Valid”; the final “no proving attempt and at least one attempt” also needs correction.

**Repair and proportionate verification.** Keep the successful-proof acceptance policy intact. Separately validate unsuccessful reports’ structure, identity, provenance and coverage, then classify attempt outcomes. Specify when missing/partial reports are explained by an observed interruption and when they indicate a defect. Structural/provenance defects may take precedence; expected unproved-resource records must not automatically do so. Replace “no proving attempt” with “no successful proving attempt.” Use fixtures for all-resource non-proof, Unknown plus resource failure, a losing failure plus Valid, malformed/coverage-invalid reports, and interrupted missing/partial reports. No scaling run is needed to repair this contract.

### M2 — The retained command cap is Silver-chosen, not OS-derived

**References.** [Scope lines 17–24 and 256–263](https://github.com/berkeleynerd/silver/blob/ec82b4e5f2bd1d3001e7117fe09e610d7d69658f/docs/unbounded-programs.md#L256-L263); #89’s objective; `src/silver.adb:29–45`; `src/silver_platform.ads:23–24,54–61`; `scripts/bootstrap.py:173–181`.

**Violated direction.** Keep an arbitrary fixed limit only where it is truly the only way. The scope retains command text of 16,384 bytes under “OS-derived infrastructure.” The implementation instead has a literal 16,384-byte ghost buffer/precondition and bootstrap rejects configurations to fit that compiler bound. Its own comment describes reserved “ample fixed driver command text,” not an operating-system maximum.

**Cheap reproduction.** The pure `build_configuration(HostLayout(...))` function rejects an actual writable macOS directory whose resolved root is 763 bytes, with four legal apostrophe-containing path components, as `quoted installation paths exceed the compiler's command bound`. File creation/read at that path succeeds. The same host reports `SC_ARG_MAX = 1048576` and executes a 20,000-byte `/bin/sh -c` command successfully. Results are retained in `tmp/review-ec82b4e5f2-evidence/root/command-cap-probe.json`; no toolchain was relocated or bootstrapped.

**Impact and scope.** This is a surviving installation/configuration limit mislabeled as forced. It is not a demonstrated admitted-source compilation failure: supported installations prevalidate the fixed command, and the probe did not establish that every downstream tool supports that exotic installation path. The narrower evidence is sufficient to refute the claimed derivation of 16,384 from the OS.

**Counterevidence.** Fixed command text does not grow with program size; retaining a provably sufficient bound for one generated installation need not restrict that installation’s language. That does not justify rejecting otherwise representable installations at an unexplained global value or calling that value OS-derived.

**Repair and verification.** Assign the command capacity explicitly: use a generated exact sufficient bound or growable/sequence-based command observations, and preserve real OS argument/path failures as operational outcomes. Alternatively, supply an actual necessity argument and narrow the milestone’s claim. Align bootstrap, SPARK contracts, source correspondence and configuration tests when implementation is authorized. The scope correction and this small configuration probe suffice now. Do not equate Linux’s path convention with macOS’s path limit.

### M3 — A sufficient total-source envelope is presented as a forced maximum before necessity is established

**References.** [Scope lines 44–69 and 218–236](https://github.com/berkeleynerd/silver/blob/ec82b4e5f2bd1d3001e7117fe09e610d7d69658f/docs/unbounded-programs.md#L218-L236); [#91](https://github.com/berkeleynerd/silver/issues/91), total-source derivation; [#93](https://github.com/berkeleynerd/silver/issues/93), pending static-data probe; roadmap lines 29–35; PR #95 body.

**Violated direction/claim.** The owner asked for the most expansive tractable choice, accepting a safe lower limit only if truly necessary. The scope calls the smaller of a global source-position bound and a worst-case table-entries-per-byte bound “Forced, not chosen,” although the latter is not yet derived and its necessity over a more selective capacity rule is not established.

**Reasoning.** A uniform bound that protects every possible source shape is sufficient. It does not follow that every larger source exhausts a table. Sparse comment/whitespace-heavy source and dense declaration/`elsif` source have different table consumption. Padding still consumes source positions and may consume line-table entries; it does not consume Names/Lists at the same rate as declarations/arms. A source-sensitive or mode-sensitive decidable capacity rule can therefore potentially admit more than the global worst-case envelope. This review does not claim such accounting has already been proved tractable.

The pending #93 probe also asks whether near-2-GiB static String data actually compiles and links **before fixing the domain**. Its failure with adequate resources would be a build-tool limitation or defect, not the full-stop section’s sole conditional event, which is an unfixable confirmation non-proof. The plan acknowledges the work in the issue but does not expose this unresolved condition in its “resolved here” narrative.

**Impact.** The owner is asked to confirm a necessity/maximality conclusion the research has not established. A blanket bound could unnecessarily reject safe larger programs; an unfixable frontend/linker limit could require a further rule or changed scope after the unconditional “no full stop” reading.

**Counterevidence.** GNAT’s fixed tables and source-position width are real constraints; source acceptance must remain guaranteed for every admitted source. Leaving overflow to unchecked vendor tables would be unsound. The owner authorized scoping after research recommending a derived cap. #91 already requires per-construct analysis before #92 and distinguishes null/output modes; #93 explicitly assigns the static-data probe. The defect is unsupported certainty about necessity, not unauthorized consideration of a conservative candidate or an unassigned feasibility task.

**Repair and verification.** Mark the uniform envelope as a candidate pending derivation; compare it with one plausible source-sensitive alternative, or document why it is the best tractable choice. No exhaustive optimality proof is requested. Make #91’s completion criteria address that justification, and cross-reference the already assigned static-data research with its conditional stop/repair disposition in Full stops. Producer-source accounting and cheap contrasting sparse/dense examples come first; no repeat of multi-gigabyte or scaling experiments is needed for this scoping repair.

## Documentation inaccuracies

### D1 — Confirmation cannot verify all the stated producer and Image premises

**References.** [Scope lines 267–282](https://github.com/berkeleynerd/silver/blob/ec82b4e5f2bd1d3001e7117fe09e610d7d69658f/docs/unbounded-programs.md#L267-L282); #88’s requested trusted-boundary update; `docs/assurance.md:590–595,777–780`; `docs/trusted-boundary.md:334–342`.

The scope says faithful static evaluation, complete obligation/report generation and per-program Image premises “were previously checked for each program” by the gate, and confirmation now checks them. The existing assurance record expressly distinguishes report acceptance from proof that generation omitted no obligation. The Image scanner checks selected theory templates, not every Main occurrence; Main translation applicability remains a premise.

A missing required obligation can leave an apparently complete, accepted report. A Main Image translation outside the assumed applicability condition need not alter the templates the adapter validates. Successful confirmation therefore cannot establish every named premise.

**Impact.** This overstates both historical assurance and the diagnostic coverage on which the owner is asked to rely. It does not demonstrate unsound current execution or justify adding a new verification project.

**Counterevidence.** The scope explicitly retains these premises and disclaims universal solver proof. Confirmation genuinely checks identity, observable proof outcomes, report policy and selected template structure. Those checks corroborate assumptions; they do not prove the unobserved completeness/applicability conditions.

**Repair/verification.** Say exactly which observable consequences are checked and which premises remain assumed even after Confirmed. Align #88 with the cited existing assurance paragraphs. A static cross-document review is proportionate. This correction belongs before “proceed.”

### D2 — Application resource status conflicts, and observation has unavoidable ambiguity

**References.** Scope lines 105–132; #88 exit/observation contract; #93 “Application resource outcomes”; `src/silver_platform.adb:153–191`.

The scope explicitly forwards an application’s `Storage_Error` as status 1. #93 instead says to map an observed application `Storage_Error` or signal death to 4. “Where it can be observed” is a useful qualification, but the authoritative table contains no such exception. Generic exit 1 also means ordinary Reject/output failure; it cannot itself identify resource exhaustion.

The proposed observation mechanisms also do not recover all nested tool causes. In a cheap native probe, `system("exit 137")` and a shell forwarding a child killed by SIGKILL both return raw wait status 35072 (`WIFEXITED`, exit 137). On this macOS host, exit 152 similarly collides with a shell-forwarded SIGXCPU. These probes affect only short-lived child processes. The pinned Why3 report path records result text but drops the numeric per-prover process status. `High failure (signaled)` therefore does not identify SIGKILL versus another signal, and decoding the outer shell’s status cannot recover a solver grandchild’s status.

**Impact.** Tests can encode incompatible application behavior; a blanket promise that every real resource exhaustion returns 4 is unsupported by the proposed observations. Unrelated direct executable statuses must remain distinct from compiler results.

**Counterevidence.** #88 explicitly permits ambiguous tool failures to be status 3 and permits documented uncaught environmental termination instead of a supervisor. Its Inconclusive row requires attributable/observed causes. These are sensible escape cases, but must appear in the overall status contract and validation expectations too. This review does not demand perfect cause diagnosis from unavailable information.

**Repair/verification.** Choose one application policy and state it consistently. Specify the evidence used for each cause, including a direct child status or structured leaf-process observation where needed; preserve an explicit ambiguous/uncaught case. Do not classify generic exit 1 or 137 by guesswork. Use a small status matrix for ordinary Reject/output failure, explicit exit values, genuine resource exceptions/signals, failed exec, interrupted confirmation and parent termination. Record platform-specific signal numbers. No proof-scaling run is required.

### D3 — “Only resource exhaustion” needs the existing operational qualifications

**References.** Roadmap lines 21–27, PR #95 opening, milestone description and #87/#89 objectives; scope lines 77–79,108–132,262–285; existing `docs/assurance.md:618–627` and `docs/trusted-boundary.md:34–51`.

The same proposal explicitly retains status-3 toolchain, implementation and infrastructure failures. It cannot unconditionally promise that compilation fails only through exhaustion. Its conditional operational target can be coherent, but the summary currently erases the qualifications that make it coherent.

**Impact/counterevidence.** The detailed status table is candid about defects, and no implementation has changed. This is an overbroad summary, not evidence that all tool bugs must become language exclusions. Correct the headline and Full stops to distinguish size-policy elimination, trusted functioning services, defects, and actual resource outcomes. The failure inventory below is the proportionate static verification.

### D4 — Smaller evidence and wording inaccuracies (low severity)

- Scope lines 269–270: the actual pinned admitted source family remains finite because the alphabet and total-source rule are finite. The symbolic theorem family may quantify over arbitrary capacities; the physical family becomes much larger, not literally infinite.
- Scope lines 154–157 and the JSON’s option observation: the retained 1,000-MiB `Trivial` entry is explained by the pinned source as a synthetic Valid attempt, not a launched prover with that cap. Preserve the original observation as history and distinguish it from an actual residual memory limit.
- Scope lines 309–310: the 14 tabulated scaling runs have maximum winning steps 1,021; 1,340 is explicitly attributed to earlier 4-KB reports in the JSON. Make that distinction visible in the prose if “these runs” is intended. No incorrect maximum was found in the JSON.
- “No tool crash” in the run summary should mean no whole-run fatal tool failure; signaled losing-prover attempts remain unexplained. Their cause is not established by a successful alternate prover or a racing hypothesis.
- Scope lines 242–244: the Image estimate does not follow from its cited points. T4 notes give 217,003 identifiers for 32,461 source bytes and 427,951 for 8,188: **6.685–52.266 IDs/source byte**, not 25–52. The simple source-size projections are approximately **41–321 MB**, not 40–80 MB. The original models were not retained, so this tests the arithmetic of the recorded points, not the counts themselves. Model growth and longer identifier encodings may change an extrapolation; no claim that “more than 100 GB” is necessarily false follows. Recompute and label the projection, or omit the unsupported range. No large run is needed.
- Curated JSON line 360: T3 `scripts/run.py:10–12` divides Linux `ru_maxrss` in KiB by 1024, producing **MiB**, despite labeling it MB. Thus `batch2.log:17`'s 4,431.9 is about **4.328 GiB / 4.647 GB**, not 4.43 GB. Normalize the units; the superlinear-cost conclusion survives. Raw T2 notes also call Run C's 15,330,712 KiB “15.3 GiB”; it is 14.6205 GiB. That latter number was not copied into the curated record.
- Curated JSON line 316's **576 KiB per loop level at a 64-KiB source bound** is not established by the retained measurements. T1 notes line 75 gives 11,764 KiB total at depth 20, without a second depth for the same build; a total includes a substantial base stack. The 29/113 slopes have two points. Label the 64-KiB figure as an estimate with its baseline, or retain only the measured total. This review does not assert a replacement slope.
- Scope line 304 and curated JSON line 328 literally say no failing declaration is a uniqueness or fuel argument. T2 `runA.log:82`, `runB.log:98`, `runC.log:81` fail `Guarded.decimalTail_unique._unary`; `runD.log:110,126` fail compiled `parseFuel`/`readFuel` artifacts. The supported interpretation is that no failure showed **essential dependence** of those properties on 4096; helpers still fail mechanically. Correct the absolute wording, preserving that counterevidence and the conditional nature of the lifting experiment.
- Raw T3 notes lines 20–22 say four tiny full-proof runs, but eight distinct retained `gp_all.txt` logs exist: five memory configurations, two identifier cases and one deliberately unproved overflow. This is a raw bookkeeping error, **not** a contradiction of the separate T4 17-run dataset.

These corrections affect evidence precision rather than demonstrating a broken safety guarantee. Repair them with arithmetic, log classification and source review; do not repeat the expensive experiments. The published OOM-selection wording at scope lines 174–176 and 384–386 also needs the qualification described under configuration below.

## Process deviation

### P1 — #87 was claimed before its authorization record reached main

**References.** `docs/planning.md:47–54`; [claim comment](https://github.com/berkeleynerd/silver/issues/87#issuecomment-6236776527); #87 body; session-memory lines 3–45; PR #95 merge time.

The rule explicitly requires recording even a direct current owner request on `main` **before claiming**. #87 was claimed at 16:36:35Z, expressly stating that the record would arrive with the scope PR. It first reached `main` at 16:50:01Z: 13 minutes 26 seconds later. The issue text did not amend the governing workflow.

**Impact.** A historical shared-agent authorization-record ordering violation. The direct owner request did authorize the substantive scoping work; this is not a finding that the planning agent lacked permission to scope, or that it implemented #88–#94. The later merge supplies the current record but cannot change the earlier chronology.

**Counterevidence.** Direct requests bypass the need for a separate Ready transition or fresh approval. They do not bypass the explicit before-claim record rule.

The retained pre-publication process finding 1 explicitly proposed that #87 move to Ready/In progress only after the entry reached main. That clause did not land. Therefore scope lines 400–402, PR #95's body and #87's review-publication comment overstate incorporation of the reviews' corrections. No accepted/rejected disposition list is retained; this review does not infer one.

**Repair/verification.** Acknowledge the deviation and follow the recorded sequence for later implementation. No undo, extra approval ceremony or test run is useful. Git history and the captured timestamps suffice. Milestone creation itself was authorized by the owner’s explicit request for a milestone scope and issues; it is not a separate violation.

## Oracle, language and assurance conclusions

The controlling Oracle is the one at the review target. Its relevant sentences are:

- Line 1: “A program expressed as valid Silver can never be rejected. If it compiles, it proves.”
- Line 2: “ ‘Proves’ means automatic discharge of every required Bronze and Silver obligation, without developer intervention.”
- Line 10: “Language membership is determined by explicit, decidable rules—not by whether a particular prover run succeeds.”
- Line 11: “The source admitted, proved and compiled must be the same source. Hidden annotated replacements are forbidden. Library specifications and implementations selected for verification and compilation must correspond. Trusted external dependencies and their assumptions must be documented.”
- Line 12: “The assurance guarantee must be proved for the language and its composition rules. Passing examples is insufficient. Every language change must establish the guarantee for the resulting admitted language and all its permitted compositions.”
- Line 14: “Rejection or proof failure of a valid Silver program is an implementation defect, not permission to weaken the guarantee.”
- Line 19: “Language restrictions and implementation resource limits must be explicit, with their purpose documented. Temporary scope limits must not be presented as requirements inherited from Ada/SPARK or as inherent limits of an admitted operation.”
- Line 26: “Lean 4 is approved for machine-checked proofs of Silver's admission and composition rules, decidable language membership, universal safety guarantees, termination and completeness of automatic obligation discharge, and functional correctness and semantic preservation of the Silver compiler and Silver-owned runtime and library implementations.”
- Line 27: “Lean proofs must establish correspondence between their formal models, the actual SPARK compiler and Silver-owned runtime and library implementations, and the authoritative Ada/SPARK source. Proving a separate model alone does not establish implementation correctness; proving safety alone does not establish automatic proof success.”
- Line 28 requires Lean to supplement GNATprove and retain Bronze/Silver verification of all Silver-owned compiler/runtime/library implementation. Line 29 requires pinned Lean, explicit trusted assumptions, no unfinished proofs or project-specific axioms, and automatic checking.

**Non-gating confirmation:** no sentence expressly requires a fresh application proof run before publication. The owner directly requested the safety-check model. Existing `Current.ToolContract` already makes physical tool completion conditional. Thus a blanket “Oracle amendment required merely to move confirmation” finding was refuted. This does not license weakening automatic discharge, same-source correspondence, library verification, or complete obligations. “No Oracle amendment needed” is defensible for that architecture, conditional on actually retaining those guarantees; it is not a proof that every proposed limit or operational claim is correct.

**Lean pipeline:** `Current.ToolContract` separates parse/build/preservation fields (`proof/Silver/Current.lean:209–228`); `automatic_pipeline` uses `boundedProofCompletes` at lines 282–283. Keeping it, `admitted_assurance` at lines 157–167 and the verified library evidence while adding a build-only endpoint need not weaken the stronger theorem. A build-only theorem must not be substituted for proof-completion assurance. Resource-indexed model inhabitation does not verify physical tools.

**Uniform and exact length schemas:** static inspection of `Guarded.RangeObligation.Valid` (`proof/Silver/GuardedObligations.lean:24–35`) gives `forall x <= variableBound, fixedLength + x <= 32767`. For `<L,L>` this is equivalent to `2L <= 32767`; 16,384 fails. Historical `<2L,L>` needs `3L <= 32767`. For nonnegative S,K,C and `d <= C`, `S+K*d <= S+K*C <= V`; a prefix/subtree has no larger contributions. The existing coefficient-domination argument is in `ComposeObligations.lean:60–85`; the one-based/null-range reasoning is in `GuardedObligations.lean:46–56`, and actual argument normalization promises First=1 in `src/silver_arguments.ads:15`. The retained `research/T2/probes/Probe6.lean:13–31` and successful log independently record the claimed uniform and affine lemmas. Thus the proposed exact arithmetic is sound for the described domain and every concatenation intermediate. This is static verification of the argument and retained evidence, not a fresh kernel run or verification of the future 64-bit implementation.

**Inherited limits:** signed Integer bounds and the maximum length of the one-based predefined String on these pinned targets are inherited meanings. Their exact numeric values are target properties, not portable Ada minima. The line, identifier, exponent and source-position restrictions are GNAT implementation limits, not Ada/SPARK requirements. No new misstatement of inherited scalar meaning was established. Keeping necessary bounds while removing independent policy limits is appropriate; M2/M3 concern unsupported necessity claims.

## Remaining non-resource failures and observability

This inventory distinguishes possible failures from defects reproduced here. It explains why the operational qualifications matter; it is not a demand to implement protection against every broken environment.

| Boundary | Remaining non-resource failures after the proposed cap removal | Planned handling / unresolved observation |
| --- | --- | --- |
| Silver admission/driver | Incorrect recognizer, contract/assertion failure, invalid snapshot/library identity, unsupported configuration, retained command cap, ordinary I/O exceptions | Defect 3; nonmembership/usage alone 2. M2 removes an unnecessary configured cap. Ordinary exceptions must not silently become resource outcomes. |
| GNAT frontend | Rejection of an admitted shape, internal bug/unchecked table overflow, source-position overflow | Defect or explicit decidable tool rule. #91 has not yet derived the complete rule; resource availability does not fix an exhausted fixed ID range. |
| GNATprove/gnat2why | Frontend/flow errors, translation bug, inconsistent or missing analysis, unsupported generated form, invalid option/installation | Defect; producer limits may be explicitly Inconclusive for confirmation. Some limits can fail before an interpretable report exists. |
| Why3/provers | Unknown, Invalid, internal errors, crashes, bad theory/driver/configuration, unavailable executable | Defect if no alternative proves the required check and cause is not attributable to resources. Nontermination is not a definite Unknown and can remain pending until interruption. Numeric signal causes are not preserved by check_tree alone. |
| Image adapter | Unsupported/invalid model plan, template/refinement rejection, theorem-byte mismatch, failed snapshot/install, native spawn failure | Existing `Failure_Kind` in `src/silver_image_adapter.adb:22–41` lists these. Confirmation status 3 unless an independently observed resource cause applies. These are not all producer node-counter exhaustion. |
| Report writer/reader/audit | Schema/provenance mismatch, corrupt/truncated data, omitted coverage, unsupported diagnostics, failure to open/read/write/close | Distinguish real malformed evidence from interruption/resource-incomplete evidence (M1). Writer’s possible 2-GiB limit remains pending #89 source verification. |
| GPRbuild/binder/assembler/linker | Project/configuration errors, missing objects/libraries/SDK, ABI/relocation/object-format limits, linker bugs | Defect/tool failure; source acceptance alone does not establish whole-build completion. #93’s near-2-GiB static-data test is still pending. No such large-data failure was reproduced here. |
| Alire/tool installation | Missing/unusable tool, index/settings/environment errors, incorrect dependency/tool selection | Existing trusted setup/service premises; status 3. No compilation resource theorem proves deployment works. |
| OS/process layer | Permission/no-exec failures, missing executable/interpreter, invalid binary, external signals/cancellation | Exec errno/direct wait can identify some; shell forwarding loses information. A supervisor cannot report after the supervisor itself is killed. Uncaught environmental termination is explicitly allowed by #88. |
| Filesystem/streams | Missing path, permission denial, read-only filesystem, symlink loop, I/O error, changed file, broken diagnostic stream | These are not all ENOSPC/ENOMEM. The same errno observation needed for resource causes must preserve non-resource failures. A full disk can also prevent writing the requested bug bundle. |
| Executed application | Intentional Reject, output write/flush failure, runtime exception/signal, Storage_Error | Ordinary status 1 is not enough to discriminate causes. Scope/#93 conflict is D2. A directly invoked executable inherits its caller’s limits and need not use compiler statuses. |

Actual resource classes include memory/stack exhaustion, CPU/time/process/descriptor limits, argument-size limits and disk/file-size exhaustion. An ambiguous bug box mentioning Storage_Error is explicitly allowed to remain defect 3. The proposed supervisor-or-document choice and this ambiguity mean that “every resource failure returns 4” must not be a universal test requirement.

## Pinned confirmation configuration

The proposed no-`--level`, explicit `--timeout=0 --memlimit=0 --steps=0 --counterexamples=off`, three-prover configuration is supported by static review of the pinned producer/Why3 source. No live GNATprove run was needed or performed.

- Explicit `--level=2` introduces the 1,000-MiB preset when memory is zero; omitting the level avoids that preset. The `Trivial` entry carrying 1,000 is synthetic evidence, not an actual capped subprocess. macOS does not enforce the same prover memory limit as Linux; this review did not re-observe Linux address-space enforcement.
- `steps=0` results in no step argument. The pinned Z3 normalization is `450000 + 800*steps`. 5,368,146 gives 4,294,966,800; 5,368,147 gives 4,294,967,600, wrapping to 304. Direct installed Z3 4.15.4 option probes independently observed 2^32 -> 0 and 2^32+1 -> 1.
- The naive concern that three concurrent GNATwhy3 clients could occupy all three slots was refuted: the GNATprove semaphore limits clients to `max(1, Parallel/Num_Provers)`. At `-j3`, one client owns the opportunity to schedule a triple; at `-j8`, two clients fit. The producer schedules all three for a goal and interrupts alternatives on Valid. A goal where all attempts remain pending can still consume slots indefinitely, as the scope acknowledges. This is source-derived support, not a new scheduling experiment or proof of solver completion.
- `unproved_status` alone is insufficient. Per-prover result text helps distinguish resource answers from Unknown/Invalid, but does not retain numeric process-signal identity. D2 records the consequence.
- A candidate finding that report JSON depth necessarily grows with Ada nesting was refuted for the reviewed producer strategy: its fixed two transformation stages add breadth and bounded proof-tree nesting; counterexamples are disabled. Recheck the fixed schema when expanding classification, rather than inventing a program-dependent depth defect.
- `oom_score_adj=1000` biases Linux OOM selection; it is not an absolute isolation guarantee for a shared host. Selection is constrained by the actual kill domain/cgroup and eligible tasks. “First choice” should not be read as assurance that unrelated tasks cannot die. No OOM experiment was run.

Pinned upstream revisions, file/line references, native commands, hashes and the scheduling counterevidence are retained in the tool reviewer’s notes in the evidence bundle.

## Evidence reconciliation

The curated JSON parses. The original research was recovered from the owner-supplied immutable evidence commit above. Manifest verification establishes identity with that archive, not truth of its contents. The independent checks below distinguish raw log corroboration, saved summary telemetry, arithmetic, and retained researcher narrative. Research paths in this section are relative to `tmp/unbounded-programs-research/` in that evidence commit.

| Claim | Result of this review |
| --- | --- |
| 17 runs, 16 completed, 1 stopped | The archive has 17 project result files and 17 matching PID entries: 14 fitted scaling runs, two option smokes, one stopped run. Sixteen report exit 0; the stop is the harness memory guard. All curated numeric fields in the 14 rows match the saved per-run summaries; source lengths and semicolon counts match the retained programs. Six copied runtime files in every project are byte-identical to the frozen target. The earlier 18 count double-counted the smoke; an interim note saying 15 completed predates the final f2-16k run. |
| Wall-time exponents f1/f2/f3 | Recomputed log-log least-squares on the specified points >=1,500 source bytes: 1.817493 / 1.989761 / 1.915388, rounding to 1.82 / 1.99 / 1.92. |
| gnatwhy3 memory exponents | Same points: 0.998592 / 1.432529 / 1.981428, rounding to 1.0 / 1.43 / 1.98. f3 uses only 2,044 and 4,096 bytes. |
| Fit points | f1: 1,556, 4,021, 8,115, 15,885, 32,461 bytes. f2: 1,876, 4,067, 8,043, 16,279. f3: 2,044, 4,096. Per-point values and calculations are saved in `root/numeric-reconciliation.json`. |
| Report/check exponents “about 1” | Report exponents 0.982690 / 0.974353 / 1.044104; check-count exponents 0.999914 / 0.977558 / 1.045810. Supported as rounded descriptions of these points. |
| Memory/steps | Dense 4-KB saved telemetry gives 5.863 GiB/1,376.7 seconds, correctly rounded to 5.9 GiB/23 minutes. Saved summaries reproduce the winning/attempt step figures, including maximum winning steps 1,021. The stopped result records about 14.0 GiB gnatwhy3 and 14.11 GiB process tree at 263.3 seconds, followed by the harness SIGTERM. Earlier 1,340 belongs to a pre-existing report named in T4 notes, absent from the archive. Projected 23/90 GiB and 85 minutes are extrapolations, not observed completed runs. |
| “High failure” in 11/16; 8 Alt-Ergo answer failures | Recounting `attempt_results` in the 16 completed result files gives High failure in 11; f1-32k has eight Alt-Ergo unrecognized answers plus one signaled failure. The other counts reconcile. Original `.spark`/session files were omitted, so this independently checks the saved summaries, not every underlying leaf report. Cause remains undiagnosed. |
| Line/identifier/exponent boundaries | Retained input/output cases corroborate the lexical values; independently reproduced with native macOS GNAT 16.1 below. T3 retains successful 4096-character check/flow/proof cases and 4097 gcc failure cases, but no 4097 GNATprove logs; the stronger all-mode assertion is supported by notes/shared-scanner reasoning, not independently recoverable output. |
| Total-source 2,130,706,432 accepted; near-2^31 crash/hang | The 2,147,483,647 output contains repeated `malloc(): corrupted top size`. The giant sources, timing/RSS result lines and claimed hang backtrace were not retained; successful-tool output files are empty. The exact largest accepted size, 10.46 seconds and 2.16-GB figure survive as researcher narrative, not reparsed measurements. Cheap native 1-MiB/16-MiB sparse sources pass. GNAT fixed-table/source-position code supports real representation bounds; the safe combined envelope remains unproved. |
| Recognizer 29/113/576 KiB per level, 1.73–1.88/32 seconds, 16,352 KiB stack, up to six parses | T1 retains scratch source variants, drivers, generated cases and acceptance/error output. Notes reproduce the timings and stack values, but the measurement driver’s JSON timing/stack summaries were not retained separately. The notes’ 783→4,203 KiB over depths 20→138 gives 28.98 KiB/level; 5,242→9,766 over 40→80 gives 113.1. The 576 figure lacks a second same-build depth (D4). 16,352 KiB is 15.969 MiB. Repeated parsing is source-supported; no new timing run was warranted. |
| Lean lifting counts | Logs independently give A 4,154+193=4,347; B 4,559+217=4,776; D 2,524+103=2,627; concrete C 4,633+137=4,770. All four stats files exit 0 and all have zero ADDFAIL entries. Symbolic rates 95.5602%, 95.4564%, 96.0792% support 95–96%; C is 97.1279%. Each attempted declaration is kernel-checked, then re-added unchecked even after failure; dependent successes are conditional. The absolute uniqueness/fuel classification needs D4’s correction. |
| Uniform/exact schema claims | Independently checked mathematically against tracked definitions. Retained Probe6 source/log/stats corroborate ordinary kernel-checked lemmas with no unchecked reinsertion and only the standard printed axioms; exit 0, 1.2 seconds. Its resource contract assumes Current.ToolContract and defines outcomes as proved/exhausted: the dichotomy is a model case split, not physical-tool evidence. No fresh Lean replay. |
| Report envelope | Re-derived from `docs/report-capacity.md` and `docs/bounded-mutable-report-capacity.md`: E(4096)=15,292,416; E(4502)=16,775,980; E(4503)=16,780,078. First crossing of 16 MiB is 4,503 source bytes. E(587402)=2,147,482,900; E(587403)=2,147,486,998, so first crossing of Natural'Last is 587,403 bytes. “Above 4,502” and “near 587 KB” are correct. |
| Measured report ratios / derived writer range | Rows give 18.5747–350.1301 report bytes/source byte, supporting rounded 19–350. Dividing an assumed ~2-GiB writer limit by those rates gives only an indicative ~6–115 MB range. It is not a proved worst-case source threshold. |
| Image-node 40–80 MB / >100 GB model estimates | D4 identifies a wrong source-ratio calculation for the two stated points. The original model files are absent. The producer counter is distinct from widening Silver’s own identifier; no tested reachable counter boundary or guaranteed host-memory stop was established. |
| 319 relative links and anchors | Independently counted 22 scope + 118 roadmap + 179 session-memory links; all paths and anchors resolve in the frozen tree. |
| Manifest / 2,154 files / omitted large files and session directories | Requested manifest hash verified; all 2,154 entries match, no missing or additional research files. The manifest documents 20 omitted files over 2 MB and omission of session directories. T3 and T4 contain no `.spark` or XML session files, so report-derived counts can be reconciled only with saved summaries and notes. |
| Three pre-publication reviews; fixes incorporated | All 59 proposed findings were mapped: 22 accuracy, 17 process, 20 technical. No accepted/rejected disposition field exists. Process 1’s before-main clause did not land; technical 10’s precise no-Valid condition became ambiguous wording. Application-status inconsistency and OOM overstatement came from incorporated recommendations. Other fixes landed or were superseded. All eight final issue drafts match the live issue bodies after placeholder substitution; the full matrix is retained. |

The envelope computation preserves the old 63-operator assumptions. It validates the quoted historical capacity calculation, not a capacity guarantee after #92 removes that budget. #92 appropriately replaces that ledger.

## Work-package completeness, order and significant refuted candidates

Most suggested omissions have explicit owners:

| Area | Coverage found |
| --- | --- |
| Proof options and why3session fixtures | #88 names `tests/test_samples.py`, options/limits and each outcome. M1/D2 are contract problems, not missing ownership. |
| File/report storage, name policy, Python audit | #89 names growable files, 64-bit/streaming reports, `scripts/check_evidence.py`, identifier bound and producer writer. |
| Catalogue fields/export and 4096 fixtures | #92 names all relevant capacity fields, samples and tests; #88 requires catalogue agreement. Existing export consistency tests and fixed-size fixtures need updating, but absence of every test filename from an issue is not a material scope omission. |
| Runtime/bootstrap identity | #88 retains exact bound snapshots and #93 regenerates runtime/library sources and re-derives source-position consumption; normal bootstrap/rebuild/source-correspondence rules still apply. |
| Static data, application stack/status | #93 explicitly owns near-2-GiB compile/link research, >=20 GB disk prerequisite, application stack and direct-executable environment. Pending feasibility and D2 remain. |
| README, Rosetta, RESUME, records | #88/#93 own CLI/observable behavior; #94 owns synchronized records and reassessment of tasks blocked only by capacity. No new Rosetta construct is falsely admitted by this documentation PR. |
| Workspace retention and host coexistence | #88 prints retained workspace paths/sizes; scope requires one proof-workspace writer for overlapping #89/#90. Other-host artifacts and macOS’s independent, nonblocking validation are explicit. |

No wrong dependency was established. #89 separates native constants; #90 ties formal counterparts and coordinates source certificates; #91 can research earlier but applies rules after those prerequisites; #92 waits for all; #93 may overlap but explicitly re-derives the runtime-dependent source bound; #94 closes the complete checkpoint. Implementation must keep interim capabilities pending until the required stable assurance checkpoint, as development.md already requires.

Additional challenged candidates:

- **Milestone created too early:** refuted as an authorization violation. The owner explicitly requested a milestone scope and issues; scoping #87 itself was authorized/in progress. This does not authorize implementation.
- **Planning agent implemented future packages:** not supported. The publication changes four documentation/evidence files and the issue handoffs prohibit such execution. The recovered scripts show research-only scratch builds/probes. T4 explicitly stopped its own run and retained the adapter workspace; no evidence of implementation or shared-cache edits was found. Logs alone cannot prove the absence of every historical side effect.
- **Roadmap duplicates live board status:** not a material defect. It records direction, dependency order and the authorization boundary, not a second changing task ledger. The repeated order in issue headings is redundant but consistent.
- **Removing 64 leaves makes Natural counters necessarily unsafe:** not established. A derived source rule below 2^31 bounds syntactic counts; the actual new arithmetic/source proofs still need verification. No independent arbitrary count cap was identified beyond the retained cases discussed above.
- **All losing-prover failures invalidate a confirmation:** refuted. One Valid proof of every required check is sufficient, with valid audit/provenance; a losing attempt is not an unproved check.
- **Every finite solver cap must remain for assurance:** refuted. Removing caps changes the operational completion premise and cost, not the validity of a proved obligation. Never relabel Unknown/Invalid as proof or exhaustion without evidence.
- **Non-gating means any confirmation defect can silently count as confirmed:** refuted by the design’s explicit defect reporting and preserved discharge requirement. M1 concerns outcome partitioning, not permission to waive checks.

## Optional improvements and unresolved questions

1. **Exact built snapshot for later `confirm`.** #88 requires identity before/after confirmation, but Main is not embedded in the compiler like the runtime libraries. The current compile call holds original Main bytes only in memory (`src/silver.adb:48–65`). Clarify the retained build-input witness or the stable-workspace assumption; add a stale-workspace test if accidental edits are intended to be detected. Existing hostile-workspace/binary-attestation hardening remains deferred. This is not a demand for a comprehensive provenance system or a demonstrated defect in code that does not yet exist.
2. **No universal tractability proof.** The scope is correct to admit that measurements do not establish completion for every physical solver goal. The conditional solver premise remains substantial, particularly for larger nonlinear product chains. The owner should see that qualification beside the “in every case” direction; an inconclusive stopped run supplies no evidence of a definite non-proof.
3. **Evidence retention limits.** The named directories are now verified. Original prover sessions/reports, large source inputs and the frozen imported Lean objects are not in that archive. Preserve the saved summaries as observations with that limitation; do not describe this review as a fresh leaf-report audit or kernel replay. Recover existing originals if available, rather than rerunning scaling. The retained 200 small block programs corroborate the corpus size, but their individual `silver check` stdout is not retained; the claim that all were accepted remains a researcher observation.
4. **Live board.** Read the actual Status field with an authorized project-readable connection. Do not infer it solely from a closed issue or handoff comment, and do not treat the permission gap as evidence of a wrong board.
5. **Original conversational wording.** The supplied owner-direction fragments agree with the session entry. The complete earlier conversation and all planning-agent statements outside the publication/raw directories were unavailable. No conclusion about verbatim fidelity beyond those supplied fragments is made.

## Coverage gaps and confidence limits

High confidence in Git relationships, manifest integrity, classification ambiguity, command-cap derivation error, process chronology, arithmetic recalculations, native small GNAT boundaries, retained Lean log counts, and pre-publication recommendation coverage. Medium confidence in the absence of other package omissions and in the static architecture review. Archive integrity is verified; omitted measurements and live board values remain unverified. The raw Lean experiments used the older b79 review proof tree, as the curated record discloses; no frozen-object hash chain to that import build is retained here.

The review read `AGENTS.md`, `oracle.md`, `language.md`, `development.md`, `roadmap.md`, `docs/session-memory.md`, `docs/planning.md`, `docs/assurance.md`, `docs/trusted-boundary.md`, `docs/reviews/review-b79b986403.md` and `docs/review-b79b986403-repairs.md` at the frozen revision, with their cross-referenced implementation/specification/tests. The shared checkout’s current cost/iteration guidance was also checked; this review followed its proportional-validation rule and the user’s stricter prohibitions. Historical records remain historical. The prior b79 review and its repair record explicitly distinguish the corrected empty-interval recipe and preserve the per-program Image premise; neither was inherited as a blanket clean conclusion.

No matching target-built Silver executable or frozen canonical Lean build was available on this host. An older shared installation was not treated as target validation. No `silver check`, Lean probe/build, GNATprove run, full test suite, kernel replay, cold proof run or scaling experiment was performed. Native macOS observations do not replace the retained Linux evidence or establish Linux enforcement behavior.

## Validation performed

- Read-only Git/GitHub verification: PR metadata/commit list, merge parents/tree equality, four-file diff, milestone, eight issue bodies/labels/milestones/comments/timelines. Board reads failed with missing project scope.
- `scripts/dev.py paths` on the actual host and frozen worktree; live harness goal read returned null, with no goal created or changed.
- 19 sequential native `gcc -c -gnatc -gnat2022 -gnatws -gnata -gnato main.adb` probes using installed GNAT 16.1.0. Tool identity, each input hash, stdout/stderr, status and elapsed time are retained. About 12.93 seconds total, mostly the 799,999 exponent case.
- Physical widths 32,765 accepted and 32,766 rejected with LF, CR, CRLF and EOF; error text: `this line is longer than 32766 characters`.
- All-tab physical lines: 4,095 tabs accepted, 4,096 rejected. Suffix-tab cases verify the expansion boundary. Whole-file byte totals include LF; distinguish them from physical-line byte counts.
- Identifier 4,096 accepted; 4,097 gives `Name buffer overflow; Max_Length = 4096` and the `namet.adb:141` Program_Error bug box.
- Decimal zero-mantissa exponent 799,999 accepted; 800,000 rejected with `exponent too large`. The broader bases/mantissas and original Linux timings were not rerun.
- 1-MiB and 16-MiB comment-padded source accepted. No giant source/table exhaustion, 100-MB object build or near-2-GiB link was attempted.
- Direct Z3 4.15.4 rlimit option-wrap probes, plus source review of pinned GNATprove/Why3 option normalization, scheduling, interruption and result serialization.
- Pure bootstrap command-cap probe; four short `system()` wait-status collision probes. No resource exhaustion was induced on the host.
- Curated JSON parsing; original manifest and all 2,154 file hashes; raw run/source/runtime reconciliation; four Lean lifting logs and ordinary probe source/log inspection; 59-item pre-publication matrix and eight draft/live comparisons; independent fit/envelope arithmetic; 319 relative links/anchors; `git diff --check` for the target first-parent diff.

## Elapsed time and token usage

Review began approximately 16:58Z and the report was finalized at 2026-10-17 17:29:34Z: approximately **31.6 minutes elapsed**. Wall intervals below are approximate because static reading was not individually instrumented; concurrent activities overlap.

| Activity | Wall interval / elapsed |
| --- | --- |
| Host, governance, GitHub references and isolated target setup | 16:58–17:04Z; about 6 minutes |
| Initial independent assurance, package/process and tool reviews | 17:04–17:14Z; about 10 minutes, concurrent |
| Lead static inspection, failure semantics and arithmetic | 17:04–17:18Z; about 14 minutes, overlapping reviewers |
| Native gcc boundaries | 17:06:35–17:06:48Z; 12.93 seconds measured subprocess time |
| Z3, command-cap and wait-status probes | Under 1 second each excluding preparation; wait-status probes about 0.016 seconds total |
| Original evidence recovery and manifest hashing | 17:18–17:20Z; about 2 minutes |
| Raw-track reconciliation and pre-publication audit | 17:19–17:26Z; about 7 minutes, three reviewers plus lead concurrently |
| Writing, adversarial challenge, consolidation and final artifact checks | 17:13Z–17:29Z; overlaps the preceding activities |

These intervals must not be added as serial elapsed time. No expensive proof/testing activity was performed.

Exact input/output/cache token counters for this chat and its reviewers were not exposed. `get_goal` returned no active goal and null token-budget/accounting fields. No account-wide usage percentage is substituted for this review’s token use. Available per-review token usage: **unavailable**.

## Artifacts and side effects

- This report is untracked at `docs/reviews/review-ec82b4e5f2.md`; an identical copy is retained in the detached review worktree.
- Evidence bundle: untracked `tmp/review-ec82b4e5f2-evidence/`, containing read-only GitHub captures, reviewer notes, native probe inputs/results and independent calculations. It is this review’s evidence. The original research and pre-publication bundle are separately preserved under `/tmp/review-ec82-original-evidence/` and retrievable by the immutable evidence commit.
- Python imports and `dev.py paths` created task-local `scripts/__pycache__/` files in the review worktree; they are preserved. No canonical proof cache was rebuilt or cleared.
- Original scratch remains at `/tmp/review-ec82-tools/`, `/tmp/review-ec82-planning/` and `/tmp/review-ec82-root/`. The quoted-path probe created a small directory chain under the last path; it was not used as an installation.
- A temporary background browser tab attempted the board read and showed “Page not found”; it made no board change and was closed after inspection. Fetch added the target and evidence-branch Git objects/FETCH_HEAD; creation of the detached worktree added Git worktree metadata. The shared branch did not move. PR #95 was attached to this chat; no PR content was changed.
- No tracked file, issue, milestone, board field, PR, session memory, CLI memory, canonical proof cache/workspace or other-host artifact was intentionally modified. No commit, publication, implementation or #88–#94 execution was performed. Existing scratch and worktrees were preserved.
