# T2 — Generalizing the Lean assurance beyond the 4096 bounds

Worktree read: /home/canto/src/github.com/berkeleynerd/silver/tmp/review-b79b986403 (b79b986403).
Frozen Lean build used read-only: .../scratchpad/lean-frozen/lib/lean (Lean 4.34.1).
Nothing in the project or the review worktree was created, modified or deleted.
All probes, logs and scripts are under this directory (probes/, scripts/, run*.log).

## 1. Method

1. Static inventory (grep + import-closure script `scripts/imports.py`, results `imports.json`,
   `constant_uses.json`): 465 Lean files, 28 generated certificates, 33 `include_str` source
   bindings; `Silver.Current` import closure = 103 modules (60 of them mention a capacity constant).
2. Environment reference counts (`probes/Probe2.lean`, 70 s): declarations whose type / value mention
   each constant.
3. Dependency cone (`probes/Probe3.lean`, 29 s): every Silver declaration that transitively mentions
   `Silver.maxSourceLength`: 4,629 declarations (852 defs, 3,254 theorems, 144 inductives with
   235 ctors / 144 recursors), including `Current.ToolContract`.
4. **Lambda-lifting kernel experiment** (`probes/Lift.lean`, driver `RunA.lean`/`RunB.lean`):
   every declaration in the cone is rebuilt as `fun (L : Nat) => …` with `maxSourceLength := L`
   (inductives get `L` as an extra first parameter, projections/ctors/recursors renamed),
   and each lifted declaration is kernel-checked in dependency order
   (`Kernel.Environment.addDecl`). A declaration fails only if its *existing proof term* relied
   on the concrete value (directly or through a hard-coded literal / separately-defined constant).
   Failed declarations are then added unchecked so their dependents are still tested against
   the lifted statement → the failure list is the set of **independent root failures**.
   This is an in-memory research probe, not a project replay; nothing is written back.
   - Run A: `maxSourceLength ↦ L`, `ScalarExpression.maxBindings ↦ L/12`.
     4,347 groups: **4,154 pass, 193 fail**; 746 s, peak RSS 5.8 GiB (`runA.log`, `runA.stats`).
   - Run B: additionally `Output.Runtime.maxLength ↦ L` and literal `4096/4097 ↦ L/L+1` inside
     the 43 declarations that hard-code them (OutputEquations/OutputExpressions structures,
     `ScalarExpression.Native.ValidText/ResultType/LiteralType`, `admitted_bounds`,
     `Output.member_literal`). 4,776 groups: **4,559 pass, 217 fail**; 682 s, 5.8 GiB (`runB.log`).
   - Run C: concrete machine bound: all of the above set to the closed literal 2,147,483,646
     (= Integer'Last − 1; maxBindings 178,956,970) and `Guarded.guaranteedIntegerLast := 2,147,483,647`
     (`probes/LiftC.lean`, `RunC.lean`, `runC.log`). 4,770 groups: **4,633 pass, 137 fail**;
     1,032 s; peak RSS **15.3 GiB** (higher than runs A/B: one proof-local mismatch,
     `Compose.expressionResult_coefficients`, spent 456 s in kernel recursion before failing;
     29 GB were available, no contention at that time).
   Classification script: `scripts/classify.py` → `runA_classified.json`, `runB_classified.json`.
5. `probes/Probe7.lean` (52 s): which root failures each top-level theorem transitively uses
   (`top_roots.tsv`).
6. `probes/Probe1.lean`, `probes/Probe6.lean`: symbolic restatements (no sorry; axioms only
   propext / Classical.choice / Quot.sound) of the truth-dependent schema and of a
   resource-indexed tool contract.

Contention: during run B another agent (T3) ran gnatprove/gnat2why (≈3.9 GB RSS);
free memory was 24 GB (> 12 GB + 6 GB peak), so the run proceeded. Only one Lean process of mine
ran at a time. PIDs started: 65114 (failed compile), 65235 (run A), 71369 (Probe5), 71499 (run B),
74451 (Probe6), 74478 (Probe7), 77520 (run C), 83750 (run D); an earlier `nohup` launch (64719) died with its shell
and a `/usr/bin/time` launch failed (not installed). No other processes were signalled.

## 2. Inventory and classification of capacity constants (non-certificate Lean)

Raw counts (non-certificate files): `maxSourceLength` 471 occurrences / 100 files
(232 in the `Current` closure), `maxBindings` 101/24, literal 4096|4_096|4097 47/24,
`maxOperands|maxExpressionOperands` 33/11, `maxConcatenations` 20/9, `maxExponent` 8,
`Output.Runtime.maxLength` 46+27, `guaranteedIntegerLast` 9 (one module).
Environment: `maxSourceLength` appears in the *type* of 437 declarations and only in the value
of 439 more (304 theorems).

Role of `maxSourceLength` (pattern count): ≈171/471 are source-length roles
(`text.length ≤ maxSourceLength`, `source.length ≤ …`); the rest are **String value domain**
(`StringExecution.lean:31` evaluation returns `none` above it; `PredicateObligations.lean:41-44`
range schema), **argument capacity** (`PathNativeModel.lean:35`, `PredicateComposition.lean:29`
`Context.initial maxSourceLength`), **length-literal domain** (`IntegerLiteral.lean:33,65`,
including the exponent numeral), **output bound** (`SequenceEffects.lean:180`,
`Current.lean:151-154` `n * (maxSourceLength + 1)`). One constant currently carries five domains.

Separately defined copies of "4096" in Lean:
- `Silver.maxSourceLength := 4096` (Admission.lean:103)
- `ScalarExpression.maxBindings := 4096 / 12` (ScalarExpressionEnvironment.lean:9) — literal, not
  derived from maxSourceLength (Ada derives it: silver_scalar_expressions.ads:8)
- `Compose.maxBindings := maxSourceLength / 12` (ComposeAdmission.lean:21)
- `Output.Runtime.maxLength := 4096` (OutputRuntime.lean:92) — IO per-call bound; also the
  argument-validity bound (ArgumentsRuntime.lean:28)
- `ScalarLiteral.maxExponent := 4096` (ScalarLiteral.lean:12)
- literal `≤ 4096` hypotheses in `Output.DefinitionEquations/PrimitiveEquations/SourceEquations`
  (OutputEquations.lean:134-157, 208-256) and OutputExpressions.lean:244-294 (legal native call
  domains), `ScalarExpression.Native.ValidText/ResultType/LiteralType` (ScalarExpressionNativeTypes.lean:9-13,
  `≤ 4096`, `≤ 4097`), `admitted_bounds` statement (Admission.lean:129), `OutputAdmission.lean:285`.
- `Guarded.guaranteedIntegerLast := 32767` (GuardedObligations.lean:24).

### Category results (lifting experiment, run A → run B)

| Category | Run A | Run B | Meaning |
|---|---:|---:|---|
| (1) threaded / generic | 4,154 of 4,347 groups | 4,559 of 4,776 | Proof term valid for every L with no side condition |
| A artifact (`_unsafe_rec` compiled code, `eq_1` definitional lemmas) | 75 | 91 | No logical content |
| B concrete examples (`decide +kernel` on fixed sources) | 56 | 72 | True for every L ≥ example size; instantiate |
| C true for all L, proof unfolded the constant (`0 ≤ 4096`, `0 ≤ 341`) | 11 | 11 | Re-prove generically |
| D small-constant side condition (`16 ≤ L`, digit ≤ L, `"silver_arguments".length ≤ L`, `0 < L/12`, Image ≤ 11, `K*L ≤ L ⇒ K ≤ 1` needs L ≥ 1) | 14 | 14 | Need hypothesis L ≥ 16 (all trivially met) |
| E hard-coded literal 4096/4097 coupled to the constant | 21 | 18 (different set) | Mechanical rename to the named constant(s) |
| F coupling with the separate IO/argument `Output.Runtime.maxLength` | 7 | 0 | True only when domains are related (see §4) |
| G Integer'Last arithmetic | 5 | 5 | **Truth** depends on the bound (see §3) |
| H decide on a symbolic definitional fact (`maxBindings L = L/12`) | 1 | 1 | `rfl` suffices |
| source-pin numeric tie (`OutputSourceBridge.actual_runtime_declarations`) | – | 1 | Expected: ties parameter to Ada token |
| other / review | 3 | 5 (2 are `_sparseCasesOn` bitmask false positives of literal replacement) | proof-local |

(2) arithmetic on concrete values: the C/D/E/H rows (~40 declarations, mostly in
GuardedDecimal, ComposeBounds/StateBounds/Lexical, IntegerLiteral, NamedEquations, Predicate*Grammar/Header).
(3) kernel decide/computation over concrete bounds: the B rows (all in *Examples modules) plus
`ComposeSourceChecks.declaration_fact_04`, `NamedEquations.forbidden_word_bounds`, `uniform_discharge`.
(4) source pins: ~15 modules (list in §5).
(5) finiteness that decidability/termination/completeness genuinely needs: **none** (see §3).
(6) ToolContract: see §6.

Top-level theorems (Probe7, `top_roots.tsv`): `Current.accepts_iff_member` depends on 8 root
failures, `member_has_meaning` 11, `meaning_unique` 1 (`IntegerLiteral.digitsAt_complete`, needs 16 ≤ L),
`automatic_discharge_complete` 9 (incl. `uniform_discharge`, G), `admitted_assurance` 13,
`automatic_pipeline` 11, `pipeline_realizes` 12, `PredicateSourceBridge.executable_main_correct` 28
(incl. F `healthy_effect`, `selected_domain`), `actual_source_correspondence` 16;
`execution_specified`, `pipeline_preserves`, `Semantics.admitted_assurance` (null) 0.
Every root failure on these paths is in categories C/D/E/F/G/H — none is a recursion,
termination or decidability argument.

### Run C (concrete bound = Integer'Last − 1, target Integer'Last for String arithmetic)

- 67 of the 72 concrete examples now **pass** at the huge bound: kernel evaluation of the
  recognizers/executions does not scale with the bound (slowest example 54.5 s). Fuel
  `2*maxBindings+1` is structural on a Nat literal, so only real iterations are evaluated.
- The 5 failing examples are boundary tests that are *about* 4096 or 32767 by design:
  `Compose.repeated_static_overflow_rejected`, `repeated_dynamic_overflow_rejected`,
  `repeated_dynamic_overflow_at_new_limit` (65 copies exceed 4096), `Guarded.range_checker_rejects_excess`
  (32767), and historical `Guarded.example_admitted` (the obsolete fixed guarded shell requires
  `capacity + decorations = maxSourceLength`, GuardedAdmission.lean:95).
- G items still fail even with Integer'Last = 2,147,483,647: `2N = 4,294,967,292 > Integer'Last`
  → the exact schema (§3) is required for a value domain above 1,073,741,823.
- All F couplings disappear (domains unified); remaining failures are the same proof-local C/D/E
  items as run A/B (their auxiliary `_proof_*` lemmas were elaborated with the literal 4096 and must be
  re-elaborated) plus the pinned digit-fold tie.

## 3. Is any theorem's *truth* bound-dependent?

Yes, exactly these:

1. **Concatenation range arithmetic (G).** `Compose.uniformRangeObligations = [⟨L, L⟩]`
   (ComposeObligations.lean:42) and `RangeObligation.Valid` = `fixed + v ≤ 32767`
   (GuardedObligations.lean:24-37). `Compose.uniform_range_valid`, `Current.uniform_discharge`
   (Current.lean:73), hence `automatic_discharge_complete` and `admitted_assurance`, are true iff
   `2L ≤ 32767`, i.e. **L ≤ 16,383** (Probe1/Probe6 `T2.uniform_iff`; `(⟨16384,16384⟩).discharge = false`).
   The historical `Guarded.uniformRangeObligations` (`⟨L,L⟩, ⟨2L,L⟩`, GuardedObligations.lean:60-62)
   needs `3L ≤ 32767`, **L ≤ 10,922**; it is imported into the `Current` closure.
   `Compose.Check.InFragment` (ComposeObligations.lean:289) is *defined* as domination by `⟨L, L⟩`,
   so `Current.BoundedFragment` itself is bound-relative.
   Even with the pinned target's Integer'Last (2,147,483,647, already used for scalars:
   IntegerIntervals.lean:14-15) the uniform schema needs `2L ≤ 2^31−1` (L ≤ 1,073,741,823);
   so a String value domain of Integer'Last needs the *exact* schema: admission already proves
   `S + K·C ≤ V` (SafeExpression), and validity of a range obligation depends only on the sum,
   so `S' + K'·d ≤ S + K·C ≤ V ≤ Integer'Last` for every prefix/intermediate
   (`T2.exact_schema`, Probe6, checked). With that change the arithmetic holds for every
   V ≤ Integer'Last of the pinned target. Against Ada's portable minimum 32,767 the String value
   domain could not exceed 32,767 at all — so going beyond 16,383 requires adopting the pinned
   target's Integer'Last as a documented frontend premise for String index arithmetic (it already
   is for scalars and language.md:208-209 states it).
2. **Domain relationships (F, run A).** `Sequence.healthy_effect`, `Branching.healthy_execution`,
   `PredicateSourceBridge.executable_main_correct` need every evaluated String ≤ IO `Max_Length`
   (OutputRuntime.lean:170/207/297: Put/Put_Line return failure above `maxLength`), and
   `Compose.selected_domain`, `*.default_is_message` need the argument bound (IO `Max_Length`,
   ArgumentsRuntime.lean:28) ≤ the path capacity (`maxSourceLength`). They are true today because
   both constants are 4096; they are false if the source/value bound exceeds the IO bound without
   changing the runtime. Truth depends on `A ≤ V ≤ IO bound`, not on 4096.
3. **Small lower bounds (D):** `16 ≤ L`, `12 ≤ L`, `11 ≤ L`, keyword lengths ≤ L. Truth needs L ≥ 16;
   irrelevant for any useful bound.
4. **Examples (B):** true for L ≥ size of the example source/value.

Nothing else: run A/B show every other proof in the 4.3–4.8 k-declaration cone is already
parametric. In particular decidability (`accepts_iff_member`, a total Bool recognizer —
the bound conjunct is one `decide` among others, Admission.lean:106-112), uniqueness, loop
termination (Integer ranges, not source length), the Lean discharge checker
(`Semantics.discharge_terminates`: ≤ obligations+1 steps, Semantics.lean:221) and recognizer
termination (`termination_by text.length + 1 - position`; fuel `2*maxBindings+1` at
ComposeAdmission.lean:486 is a symbolic bound) need no finiteness of the 4096 bound.

## 4. What a generalized statement looks like

Symbolic-bound form (tractable now): theorems quantified over a capacity record
`{source S, value V, argument A, ioPerCall P, literal = V, exponent E}` with side conditions
`16 ≤ S`, `A ≤ V ≤ P` (or P removed), `V ≤ IntegerLast_target` (exact schema) — and, for the
native correspondence only, machine-domain conditions inherited from the Ada types
(`S + 1 ≤ Natural'Last` for `Literal_Position`, `65·V ≤ Natural'Last` for
`Expression_Length` unless widened, etc.). Run A/B demonstrate that ~95% of the cone needs no
edit; ~40 proof-local repairs (C/D/E/H), 56–72 examples instantiated at concrete values,
and the 5 G items replaced by the exact schema.

Unbounded source (S = ∞) for the *language* theorems is also tractable: drop the
`length ≤ maxSourceLength` conjunct from `Member/accepts` and use `text.length` wherever the
proof needs a finite bound (fuel, positions). But it requires first splitting S from V: about
two-thirds of the `maxSourceLength` uses are value/capacity roles, and several proofs use
"literal length ≤ source length ≤ 4096" to bound value lengths (`decode_complete_spec`,
`prefix_decoded_valid`, `ValidValue`), which must become explicit admission checks against V
(admission already checks every expression total against the bound). The native correspondence
remains machine-bounded: the Ada recognizer takes `String` (index Positive), so its legal domain
is `Text'Length ≤ Integer'Last − 1`; GNAT rejects lines ≥ 32,766 characters (lead fact) and its
`Source_Ptr` is 32-bit — those are pinned-tool caps that the language must restate (a decidable
line-length rule) or carry as frontend premises.

String value domain = Integer'Last: Lean side changes are (i) exact range schema + target
Integer'Last premise, (ii) unify/relate IO per-call bound, argument bound and value bound
(runtime and ghost `Written_Bytes : String (1 .. Max_Length + 1)` cannot have Max_Length =
Integer'Last in Ada — Silver_IO needs a different ghost model), (iii) length literals
0..Integer'Last (IntegerLiteral parser is generic in its bound), (iv) Nat arithmetic in Lean
is unaffected; Ada types (`65 * Max_Length`, `Max_Length + 1`, `Long_Long_Integer` literal
values) must widen — outside this track.

## 5. Certificates and source pins (category 4)

- 28 `*Certificate.lean` files are generated by `proof/generate_source_certificate.py`
  (SOURCE_BINDINGS list) via `scripts/check_lean.py:486`; each line certificate is kernel-checked
  against the `include_str` source. They carry tokens only; changing an Ada constant simply
  regenerates them.
- Hand-maintained pins that spell constants: `SourceBridge.lean:106`, `OutputSourceBridge.lean:84-86`,
  `PredicateSourceRequirements.lean:256-266`, `ComposeSourceChecks.lean:266-309,366`,
  `NamesSourceChecks.lean:56`, `IntegerLiteralSourceChecks.lean:66`, `ScalarLiteralSourceChecks.lean:48,70`,
  `PathFactsSourceChecks.lean:109,118`, `PathFactsSourceBridge.lean:39,45`, `ReviewedOutputShape.lean:10,18`,
  `ReviewedSourceShape.lean:22,241` (mutation test 4_096→4_095), `ScalarLiteralSourceShape.lean:10`,
  `PathFactsSourceShape.lean:9`.
- Only `Output.Runtime.maxLength` has a mechanical numeric tie (digit fold of "4_096",
  OutputSourceBridge.lean:85-86). `maxSourceLength`, `maxExpressionOperands`, `maxConcatenations`,
  `ScalarExpression.maxBindings`, `maxExponent` are tied to the Ada tokens only by review
  (`ComposeExpressions.lean:758` interprets the Ada name `Max_Source_Length` as `maxSourceLength`).
  With a symbolic bound these ties become explicit instantiation lemmas (run B's one pin failure is
  exactly this tie).

## 6. ToolContract / solver resources

- `Current.ToolContract.boundedProofCompletes : ∀ checks, BoundedFragment checks → ∃ steps,
  tools.prove checks steps` (Current.lean:217-218): steps are existential and unbounded; no
  memory, time or step limit appears in Lean. `100000`/`memlimit` appear nowhere in proof/Silver
  (grep); they exist only in the driver (src/silver.adb:116-123) and docs
  (assurance.md:591-592, trusted-boundary.md:43 and :901-903). The `steps ≤ obligations.length + 1`
  in `all_obligations_discharge` is the Lean checker, not a solver.
- So the Lean premise already *is* "completion given sufficient resources"; the physical
  instantiation (fixed `--steps=100000 --memlimit=1000`) is what makes it "completion within a
  fixed allowance". Removing/escalating the limits needs no Lean change; it weakens the
  external premise to the Lean one.
- Physical note (assurance.md:794-801, trusted-boundary.md:901-910): GNATprove 16.1 at
  `--level=2` treats `--memlimit=0` as unset and still applies 1,000 MiB; the Why3 runner applies a
  1,048,576,000-byte address-space limit; `--steps=100000` normalizes to 100,000 (Alt-Ergo),
  3,515,000 (CVC5), 80,450,000 (Z3). So "no memory/step limit" cannot be obtained by passing 0; the
  physical driver needs explicit large or escalating values (track T4). Lean is unaffected.
- Optional sharpening (Probe6, checked, no sorry): `T2.ResourceContract` = existing `ToolContract`
  + `sound` + `eventually : ∀ checks, BoundedFragment checks → ∃ r₀, ∀ r ≥ r₀, prove checks r = proved`,
  with `outcome_dichotomy` (proved ∨ exhausted at every allowance) and `resource_pipeline`;
  `model_resource_contract` shows joint inhabitation. Monotonicity in the allowance is a new
  observed/premise fact about the solvers (deterministic resource-limited search), not proved.
- `BoundedFragment` is bound-relative (domination by ⟨L,L⟩); a larger L enlarges the class of VCs
  the completion premise covers (same linear shape, larger constants, more operands if the
  64/63 budgets go) — premise strength grows, Lean proof does not change.

## 7. Operands (64), operators (63), exponent (4096)

- `maxExpressionOperands`/`maxOperands`/`maxConcatenations` are threaded through grammar validity
  (`expression.length ≤ maxExpressionOperands`, PredicateStatements.lean:27, Bindings.lean:343,
  `withinWorkBudget` in membership, ComposeAdmission.lean:242) and native-type mirrors
  (`operand_count natural range 0 .. 64`); no theorem's truth depends on their values
  (the range schema uses `K·C` with Nat K). Removing them is a language/Ada change; Lean impact is
  mechanical (112 declarations mention maxExpressionOperands in their type).
- Exponent: `ScalarLiteral.powerAt` rejects exponent > 4096 (ScalarLiteral.lean:82);
  length-literal exponents are bounded because the exponent numeral itself is parsed under
  `maxSourceLength` (IntegerLiteral.lean:65-79). `scale` recurses `exponent` times
  (≤ 4096 for a zero mantissa). An unbounded exponent is tractable: short-circuit zero mantissa,
  overflow after ≤ 32 multiplications otherwise; saturating exponent parse. Lean proofs about
  `scale` are inductive and generic.

### Run D (operand 64, operator 63, exponent 4096 lifted)

`probes/RunD.lean`: `maxExpressionOperands ↦ P`, `ScalarExpression.maxOperands ↦ P`,
`maxConcatenations ↦ P − 1`, `ScalarLiteral.maxExponent ↦ P`. Cone 2,934 declarations / 2,627 groups:
**2,524 pass, 103 fail** (390 s, 6.5 GiB; another agent's gnatprove was running, 28 GB available).
Failures: 44 `_unsafe_rec` + 2 `eq_1` artifacts, 50 concrete examples, 2 source-pin decides
(`declaration_fact_03` `maxExpressionOperands = 64`, `declaration_fact_23` `maxConcatenations = 63`),
and 5 proof-local items that need only `1 ≤ P` (`Compose.argument_shape`,
`argument_declaration_valid`, `ScalarExpression.Native.literal_result_type`,
`literal_correspondence`, `atom_correspondence`). No proof depends on 64, 63 or the exponent cap
4096 beyond `P ≥ 1`; the exponent cap has no root failure at all.

## 8. Effort / order (Lean side only)

1. (S) Single source of truth: derive `ScalarExpression.maxBindings` from the bound; replace the
   ~45 hard-coded 4096/4097 literals with named constants; add digit-fold ties for every pinned
   constant. Run B shows this removes all literal couplings except native-type mirrors.
2. (S) Exact range schema + target Integer'Last (`T2.exact_schema` pattern); sum-domination
   `Refines`; delete/restate historical `Guarded.uniform*`. Removes the only truth dependence.
3. (M) Split roles: S (source), V (value/literal), A (argument), P (IO per-call), E (exponent);
   relate A ≤ V ≤ P (or drop P with an IO redesign).
4. (M–L) Parameterize (section variables or a capacity structure) with side conditions; repair
   ~40 proof-local items; instantiate 56–72 examples. Kernel cost unchanged (runs A/B: ~12 min
   for the whole cone in one process, 5.8 GiB).
5. (L) Unbounded source: drop the source conjunct, fuel from `text.length`, machine-bounded native
   correspondence, GNAT line-length rule/premise.
6. (S) Docs/premise wording for solver resources (no Lean change), optional ResourceContract.

No Oracle amendment is required by any Lean step. Decisions the owner may want to know about
(non-blocking, recommended defaults given): adopting the pinned target's Integer'Last for String
arithmetic (portability claim narrows to the pinned targets); and the inherited/tool caps that
cannot be removed (Ada String index ≤ Integer'Last; GNAT 32,766-character lines; GNAT 32-bit
source positions).

## 9. Evidence status

- Proved (kernel-checked in probes, in-memory, no sorry): `T2.uniform_iff` (current uniform schema
  valid iff 2L ≤ 32767), `(⟨16384,16384⟩)` invalid, `T2.exact_schema`, `T2.resource_pipeline`,
  `T2.outcome_dichotomy`, `T2.model_resource_contract` (axioms: propext, Classical.choice, Quot.sound).
  Lifting runs: 4,154 / 4,559 / 2,524 lifted declarations kernel-check for an arbitrary symbolic
  bound (runs A/B/D) and 4,633 at the concrete Integer'Last − 1 bound (run C).
- Observed (analysis of failures; each failure is a statement about an existing proof term, not a
  proof that a re-elaborated proof would fail): classification in §2, §3, run C/D sections.
  Conditional on dependencies generalizing: failed declarations were added unchecked so
  dependents were still tested (independent roots).
- Premises unchanged by generalization: frontend interpretation (now including pinned-target
  Integer'Last for String index arithmetic if the exact schema is adopted), faithful/complete
  GNATprove generation, solver completion for the (larger) bounded fragment, monotonicity of solver
  success in the resource allowance (new, only if the resource-indexed contract is adopted),
  GNAT line/source-size capacity.
- Not covered: re-elaboration of edited source (tactics re-run); Ada/GNATprove side of any change;
  splitting source length from value domain (S vs V) was analysed statically, not lifted;
  macOS.
