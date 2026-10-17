# T5 notes — Oracle, assurance and validation consequences of a resource-exhaustion failure model

Inputs: review worktree b79b986403 (read-only); root HEAD 9cff9c28d6 docs read via `git show HEAD:` (read-only):
docs/session-memory.md (2026-10-17 B1 Option A authorization), docs/review-b79b986403-repairs.md,
docs/reviews/review-b79b986403.md. GNAT 16.1 frontend source excerpts read (read-only) from T3's scratch
(research/T3/gnatsrc) and T3's gcc probe outputs (research/T3/p/*/out.txt) — these are T3's observations, cited, not mine.

Evidence classes used: PROVED (Lean/SPARK theorem), PREMISE (documented trusted tool/OS assumption),
OBSERVED (measurement/probe), SOURCE-REVIEW (reading of tool source; not a binary attestation).

## 1. Oracle consequences

Constraining sentences (oracle.md line numbers):
- :1 "A program expressed as valid Silver can never be rejected. If it compiles, it proves."
- :2 "“Proves” means automatic discharge of every required Bronze and Silver obligation, without developer intervention."
- :9 "Guarantees must cover every permitted input, execution path and combination of admitted constructs."
- :10 "Language membership is determined by explicit, decidable rules—not by whether a particular prover run succeeds."
- :11 "... Trusted external dependencies and their assumptions must be documented."
- :12 "The assurance guarantee must be proved for the language and its composition rules. ... Every language change must establish the guarantee for the resulting admitted language and all its permitted compositions."
- :13 "Proof success must never be obtained by silently changing behavior, narrowing declared input domains or suppressing obligations."
- :14 "Rejection or proof failure of a valid Silver program is an implementation defect, not permission to weaken the guarantee."
- :18 "Before 1.0, Silver is one evolving language, without a compatibility obligation to earlier revisions. Changes must be explicit and reflected consistently in the specification, catalogue, implementation, proofs and samples. ..."
- :19 "Language restrictions and implementation resource limits must be explicit, with their purpose documented. Temporary scope limits must not be presented as requirements inherited from Ada/SPARK or as inherent limits of an admitted operation."
- :21 "... External failure must not redefine language membership, excuse required proof obligations or be represented as successful completion of the requested effect." (scoped to admitted *program* operations; used by analogy for the compiler)
- :22-23 Linux primary, macOS supported (same major/minor tools).
- :25 "GNAT, GNATprove, Alire, and existing operating-system/runtime libraries remain trusted external dependencies. ... Silver-owned wrappers receive no exemption."
- :26-27 Lean approved for "termination and completeness of automatic obligation discharge"; correspondence to actual SPARK/Ada required.

Conclusion: NO Oracle amendment is required.
- The Oracle never requires a size cap. :19 requires that limits which exist be explicit and purposed; removing them satisfies it vacuously; remaining tool-derived limits and the escalation schedule must be explicit/documented.
- Rejection (nonmembership) = verdict of explicit decidable rules (:10). Environmental failure = a trusted dependency's documented assumption ("sufficient resources") not met (:11, :25). These are disjoint as long as the driver never reports resource failure as "Rejected" (status 2) nor as success (status 0). :21 is the template.
- :14 still bites: a *definite* proof failure (prover answers unknown/invalid with resources remaining; unexpected report shape; frontend rejection; a Silver-configured solver limit being binding) is a defect. Therefore every Silver-configured solver limit must be made non-binding (escalate to unlimited), otherwise "step limit reached" is a Silver-imposed proof failure = defect, not environmental.
- :12 makes removal a language change requiring the full guarantee for the unbounded language (universal Lean proofs + source correspondence) — cost, not a stop.
- :2 "without developer intervention": providing host resources is provisioning, not proof intervention (interpretive; consistent with existing doc premise "sufficient environmental resources").
- language.md:499-500 ("failed compilation of admitted source is still a defect") is spec text, not Oracle; it should be restated (see §4), no amendment.

Optional (owner's choice, not required): add an Oracle sentence making compiler resource exhaustion an explicit environmental outcome, mirroring :21. Not a full stop.

Gate (procedural, not a content decision): development.md:3-5 "a roadmap entry alone does not authorize implementation"; the 2026-10-17 B1 authorization "does not authorize the next construct" and defers stack redesign (O1). A new milestone needs an explicit owner "proceed" recorded in session memory, after the B1/M1 checkpoint completes.

## 2. Limit classification (see structured output items)

Key new facts (from T3 scratch, SOURCE-REVIEW + OBSERVED by T3):
- GNAT line limit is tab-expanded: scng.adb:129-190 — physical length > 32766 → "this line is too long"; for lines ≥ 4096 physical chars, columns are expanded (tab → next 8k+1) and Col > 32766 → "this line is longer than 32766 characters" + Unrecoverable_Error. T3 probes: 32765 spaces ok, 32766 error; all-tab 4095 ok, 4096 error; tabs 4130 ok / 4131 error. Today unreachable: GNAT's own comment "Any shorter line [< 4096 physical] could not be a problem, even if it was all tabs", and Silver sources are ≤ 4096 bytes.
- GNAT identifier crash: namet.ads:144 Bounded_String default Max_Length 2**12; namet.adb:136-141 "Name buffer overflow" → Program_Error → GNAT BUG box. T3: id_4096 ok, id_4097 / id_8000 / id_16000 crash. Not resource exhaustion — a hard tool limit. Today unreachable (identifier ≤ ~4030 in a 4096-byte program).
- GNAT exponent: scng.adb:766-773 "UI_Scale >= 800_000 → exponent too large" (hard error, any mantissa incl. 0). Silver's 4096 exponent limit is a policy below this.
- GNAT fixed ID ranges: types.ads Text_Ptr range -4..Int'Last; Names 100M ids; Strings 100M; Nodes 0..1,999,999,999; Uint ~1.5G. Overflow of these is a tool hard limit, not memory exhaustion; whether memory runs out first is host-dependent → needs one derived source bound (T3 to derive) or an explicit, falsifiable premise.

## 3. Trusted premise restatement

Lean ToolContract (proof/Silver/Current.lean:209-226) ALREADY states the weak premise:
`boundedProofCompletes : ∀ checks, BoundedFragment checks → ∃ steps, tools.prove checks steps` — existential, no 100,000/1,000 MiB bound. The numeric bound appears only in prose: assurance.md:590-592, trusted-boundary.md:43 (table), :901-907, language.md:757-760. So the Lean shape needs no change; docstring already says "not ... a measured universal step bound".
BUT `BoundedFragment`/`InFragment` and `uniformRangeObligations` are instantiated at maxSourceLength=4096 and proved by `decide +kernel` (ComposeObligations.lean:45-51), and `guaranteedIntegerLast := 32767` (GuardedObligations.lean:24) — the String arithmetic argument relies on Ada's minimum Integer'Last; lifting the value domain to 2^31-1 must switch to the pinned target Integer'Last (already assumed for scalars, language.md:208).

Important honesty point: with the 4096 cap the set of admitted programs (hence VCs) is FINITE, so the completion premise is a finite claim; after removal it is a claim over an infinite family of unbounded-size goals, which no amount of testing can exhaust. It rests on the solvers acting as decision procedures for the generated fragment. This strengthens the premise (permitted by :11/:25; must be documented).

Escalation design (implementation policy, explicit per :19, non-binding):
- tiers k = 0,1,2,...: steps S_k = 100,000·r^k (r e.g. 4 or 10), per-prover memlimit M_k = min(1000·2^k MiB, a constant above any host RAM); timeout 0; final tier steps=0 (unlimited, if GNATprove 16.1 treats 0 as unlimited — T4 to confirm) and memlimit constant ≥ host RAM.
- Rerun only while every unproved goal had at least one prover stop on a resource flag (unproved_status steps/memory/time). If an unproved goal has no resource flag for any prover (all definite unknown/invalid) → stop: "prover incompleteness = implementation/toolchain defect" (status 3).
- Why a ladder and not one unlimited run: GNATprove tries the portfolio provers in order per goal; one unlimited prover can starve the others. Geometric dovetailing finds a proof whenever ANY portfolio prover proves the goal within finite steps (PREMISE: success monotone in the step limit for deterministic solvers), with total overhead ≤ r/(r-1) × (#provers) × final-tier work. That property is a small Lean lemma over an abstract monotone-prover model (recommended), not a solver theorem.
- Same source, same project, same obligations; only resource options change → no conflict with :10, :11, :13.
- Open premise items for T4: does --steps=0 mean unlimited at --level=2; does an explicit large --memlimit propagate to gnatwhy3; Z3 rlimit width (normalized 100,000 → Z3 80,450,000; if Z3 rlimit were 32-bit unsigned, normalized steps above ~5.3M would overflow — UNVERIFIED, check); session reuse gives a complete final report.

"Unknown" vs resource: evidence so far (expression-headroom.md:70-84; restrictions-capacity.md:243-250): the only observed unproved admitted-shape goals had steps=true (resource), proved by Z3 at 10,738/11,609 steps. Alt-Ergo OOM on an admitted goal (trusted-boundary.md:911-912) — resource. No definite "unknown" on an admitted schema is recorded. Incompleteness remains a defect under :14 and violates the owner's "fail only by resources" goal.
Minimisation: keep obligations to range/length/overflow schemas whose VCs are linear integer arithmetic over interval hypotheses (decidable, QF_LIA) — String checks only use 'First/'Last/'Length; keep byte-content reasoning out (already: no mutable byte equalities tracked). Exception: variable×variable multiplication already yields bounded-box nonlinear goals; with the 63-operator budget removed, degree/variable count become unbounded → solver completeness not guaranteed (NRA decision procedures exist but are doubly exponential; QF_NIA undecidable in general, decidable on bounded boxes). This is the weakest link; scaling probes on product chains must be run; if they show pathological growth, the only legitimate remaining operator restriction is an assurance-motivated one (e.g., limit the number of non-static factors per product), documented as protecting automatic discharge — not a size knob.

## 4. User-visible resource-failure contract

Current (README.md:326-338; src/silver.adb:344-397,438-453): 0 success; 2 excluded source/usage; 3 infrastructure/verification/compilation failure ("Verification failure for admitted Silver: toolchain or implementation defect."); Storage_Error in the compiler exits 1 unmapped (trusted-boundary.md:79-81). Report > 16 MiB → "missing or incomplete proof evidence" (defect, status 3). Source > 4096 → "Rejected" (status 2).
Probe (OBSERVED, this track): `silver check` on 1 MiB and 17 MiB sources → both "Rejected: source is outside the Silver catalogue." status 2 (0.03-0.04 s). Today correct (membership cap 4096), but the Read_File 16 MiB buffer (silver_platform.ads:10) and every other fixed buffer would turn into an Oracle :1/:10 violation once the membership cap is gone, because capacity would be reported as rejection.

Proposed contract:
- 0: proved, built (and published/run) — only when every phase completed.
- 2: "Rejected: <rule>" — only explicit decidable membership rules (including tool-derived rules). Never a capacity or resource condition.
- 3: "Verification/Compilation failure for admitted Silver: toolchain or implementation defect (<cause>)" — definite non-resource outcomes: prover incompleteness, unexpected report shape, frontend rejection of admitted source, build failure, snapshot drift.
- 4 (new): "Resource exhaustion: <phase> stopped because host <memory|time|disk|stack|process> resources were exhausted. The source is admitted Silver; it was not rejected and nothing was verified or published." Triggers: child tool killed by SIGKILL/SIGXCPU/SIGXFSZ, ENOMEM/ENOSPC/EMFILE/E2BIG from Silver's own I/O/process calls, proof report showing memory flags with the final non-binding tier, Storage_Error surfaced by a tool (trusted diagnostic premise).
- Uncatchable in-process exhaustion (Storage_Error in the compiler → GNAT last-chance exit 1; SIGKILL → 137 from the shell): documented as environmental. PROVED+PREMISE argument: GNATprove proves absence of every runtime error in the SPARK compiler except Storage_Error (SPARK does not cover stack/heap exhaustion), so an unhandled-exception exit is resource exhaustion or a trusted-runtime defect. Optional: SPARK-verified last-chance handler mapping it to 4.
- No partial success: no artifact published unless all phases succeed (existing). Workspaces retained for diagnosis. Escalation tiers printed on stderr.
- User interrupt (SIGINT) distinct (130).

## 5. Validation strategy

- Replace "boundary at 4096" with boundary tests at each explicit tool-derived limit (line columns 32765/32766 with CR/LF/CRLF/none and tab mixes; identifier 4096/4097; exponent 799,999/800,000; Integer'Last literals) — exercised by both `silver check` and pinned gcc -gnatc and gnatprove.
- Universality: Lean theorems with no source-length hypothesis (or only the tool-derived source bound as a symbolic hypothesis); forbid `decide` over size-dependent constants; grep/audit gate that no 4096/341/64/63 literal remains in model modules except named tool-derived constants. Source correspondence for the dynamic-sized native structures.
- Scaling evidence (OBSERVED, not proof): geometric ladder of dense probes (e.g., 4 KiB, 16 KiB, 64 KiB, 256 KiB, 1 MiB where feasible) for each cost-dominant shape: dense assignments; one maximal expression (64, 256, 1024, 4096 leaves); deep nesting (loops, ifs, parentheses); nonlinear product chains; Image-heavy. Record: tier reached, max normalized steps per goal and per prover, any no-resource-flag unproved goal (must be zero), wall time, peak RSS (process-group), stack, report bytes vs E(S), recognizer time/memory.
- Admission-only scaling of `silver check` up to the tool-derived source bound (or ≥ 64 MiB) at default 8 MiB stack: must be near-linear and never fail by capacity.
- Resource-contract tests: run compile under ulimit -v/-s/-f/-t and a full disk tmpfs; assert status 4 (or documented environmental 1/137), message, no publication, never 2/0.
- Report envelope: guard the symbolic formula E(S) and check every probe's actual report against it.
- development.md checkpoint text: replace "Exercise boundaries" at 4096 with "exercise every explicit tool-derived limit at limit and limit+1; run the scaling ladder for new cost-dominant shapes; record (not threshold) costs; zero incompleteness outcomes".

## 6. Interactions with B1/M1 (#77-#84) and order

- Root HEAD 9cff9c28d6: B1/M1 implementation committed (78cf419452), native checkpoint passed (run 20261017T121201-b6d6ef10643e, 15,149 checks), complete regression + Lean/source validation + independent review pending.
- B1 Option A is itself a tool-derived semantic restriction ("intentional pre-1.0 language restriction required by the pinned frontend") — precedent and template for the new tool-derived rules; limit removal must not reopen it.
- M1 makes ScalarConstraintAt mandatory and threads source readings through Sequence.scalar_tokens_source_bounds → Predicate.meaning_scalar_source_bounds; parameterising maxSourceLength touches these same certificates. Land B1/M1 complete checkpoint first; one proof-workspace writer.
- O1 (stack) was explicitly deferred by the 2026-10-17 authorization; limit removal needs it un-deferred under the new authorization.
- Suggested order: (0) finish #77-#84; (1) escalation + resource-failure contract + premise rewording (no language change); (2) explicit tool-derived rules (vacuous today, except exponent raise to 799,999); (3) compiler internals sized by input: dynamic environments, iterative/heap recognizer, report storage sized by E(S) or streaming audit, dynamic source read; unify duplicated constants; (4) Lean parameterisation separating source-length, value-length and identifier-length constants; (5) remove source cap/operator budget/leaf limits with scaling validation; (6) lift String value/argument domain to Integer'Last (runtime contract change, bootstrap refresh).
- Lifting the 4096 value domain changes observable behaviour: an argument of 4097..(OS limit) bytes is currently rejected at runtime (status 1, no output; language.md:688-689; tests/test_arguments.py:106 expects b'x'*4097 invalid) and would become valid input. Linux MAX_ARG_STRLEN (128 KiB per argument) then becomes the environmental cap (exec fails, E2BIG). Admitted-program set is a superset (N + K·C ≤ Max with Max and C growing together leaves K≥1 unguarded cases unchanged). Permitted as an explicit pre-1.0 change under oracle.md:18; must update spec, catalogue (max_argument_bytes, initializer_capacity, max_result_bytes, expression_bound), runtime (Silver_IO ghost arrays/contracts, Silver_Arguments), Lean, tests, manifest. Widening is not "narrowing declared input domains" (:13).

## Experiments run (this track)
- silver check: src4096 (4096 B) Accepted 0; src4097 Rejected 2; exp 0E4096 Accepted 0; 0E4097 Rejected 2; 1 MiB and 17 MiB sources Rejected 2 (0.028 s / 0.040 s). Files in probes/ (big files deleted). No PIDs left running; no files created outside scratch.
