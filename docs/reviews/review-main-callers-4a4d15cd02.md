# Ordinary Main caller and U/H interface review

2026-10-23. Initial target: `4a4d15cd02c2104ee46ef89479677833194c0ce1`,
on accepted construction freeze `767007bf43ad1a7ef82b8d629ab460b6186f694e`.
Selected reviewer: GPT-6 Astra / Extra High. Runtime model/effort confirmation,
token counts and cost telemetry are unavailable. The reviewer used a separate
worktree and owns only this note and the
[review packet](../evidence/retained-main-callers-final-review-20261023/).

**Accept the amended source/typed/U-H interface at
`ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c`.** The receipt-only follow-up
`7ab729be0bfaf393f462f070d9a09af614c87567` leaves that code, diagrams and
source inputs unchanged. The initial freeze was not accepted; all three
findings below are closed by the independently reviewed correction batch.

## Requirements and exact scope

The task is the ordinary Main source-to-typed body/contract interface and its
program-variable/outcome-key join for #178 under #119. It covers every currently
admitted Main constructor and its implicit clauses under the retained frontend,
String-shape, type-frontier and tool-configuration premises. Passing diagrams
alone cannot establish this coverage. No Oracle amendment, admission ceiling,
aggregate RAM gate, production change or change to physical-resource/service
assumptions is proposed.

The five API contracts and construction/conversion tranche are reused as
accepted providers, rather than re-proved or replayed. This review also reuses
its own complete ignored-child/LDsym inventory
`fef5579f8da8269d6b6da37dd84d1f0973f4d428` and ordinary loop write-status audit
`620d990da30f4f12f638db7ae2b547b48f351756`. Their source conclusions remain
distinct from the audit of this implementation freeze.

The local body fold consumes actual frontend decisions (including folding,
entity/type identity, conversions, warnings and bound captures). Agreement of
these indices with the retained source guards is a derivation premise; an
arbitrary Python fixture is not an admitted source program. The universal claim
is the constructor induction with these guards, not observed native totals.
The fold does not read a `Ptree.Modules` block. Native module entries remain
triples `(ident, None, decls)` under the parent's explicit native attachment;
this review does not replace that attachment with the source pair layout.

## Findings in the initial freeze

1. **Anonymous sequence keys are omitted.** `typed.py`'s sequence branch
   charges an expression/kode node but creates no program-variable identity.
   `typing.ml:1126–1130` lowers `Esequence` to `DElet (_,RKnone,...)`;
   `dexpr.ml:1572–1575,1719–1730` calls `Expr.let_var:721–724`, which allocates
   an `LDvar` key. The retained seven-null fixture has 13 sequences while its
   claimed initial key superset contains only `Main:unit-formal`. Each retained
   sequence needs its own scoped unit binder in the initial union and the
   definition/result correspondence, including generated loop and wrapper
   sequences. This is an initial-union defect; coincidental spare allowance in
   a later scalar bound does not repair that claim.

2. **Two scalar check layers are conflated.** `source.Value.range_symbol`
   supplies the arithmetic overflow call at `source.py:214–217`; the expected
   scalar conversion at `:295–297` explicitly excludes arithmetic operators.
   The producer independently inserts overflow at
   `gnat2why-expr.adb:25521–25632`, using the base-type range-check symbol
   (`:12039–12056`), then calls `Insert_Checked_Conversion` at `:25654–25665`.
   Its scalar branch uses its own `Do_Check` guard
   (`why-gen-expr.adb:1518–1648`). An object-local narrowed Integer target is
   admitted; the interface supplies no mutual-exclusion theorem for those
   source guards. It must retain both selected layers independently, with the
   expected check outside the overflow result and separate actual/contracts.

3. **Ordinary String inequality uses an unreached helper fallback.** The
   source fold sends String `/=` directly to `callers.compare`, which wraps
   equality in `Boolean.notb`. The accepted frontend analysis instead rewrites
   this source form to `not (=)` (`retained-main-semantics.md:157–160`).
   `gnat2why-expr.adb:18723` marks the direct helper branch exempt for precisely
   that reason, and `:24547–24565` uses `New_Not` in program mode. It lowers to
   an `Eif` with False/True children. The initial fixtures exercise the fallback
   rather than this ordinary rewrite; a replacement adds one typed conditional
   and changes the per-call/condition interface. The generic helper can remain
   documented separately, but the source fold and ordinary fixtures must use
   the frontend rewrite.

The [original probe](../evidence/retained-main-callers-final-review-20261023/audit-original.py)
reproduces these seams and independently checks the retained source/provider
identities. Its [result](../evidence/retained-main-callers-final-review-20261023/original-result.json)
records 136 checks in 6.500877275 seconds on Linux x86_64: 30 complete source
files, 18 provider identities and 49 source spans. The checks preserve all
input hashes. The scalar probe demonstrates the one-index interface; the
two-layer coverage obligation comes from the source review, not this sample.

## Completed source and composition audit

| Area | Reviewed correspondence and result |
| --- | --- |
| Leaves and names | Integer/static folding leaves; located unit/null entries; mutable field reads; nullary immutable program symbols; static map literals; split String map plus complete converted bounds. Initializers are not replayed at name uses. |
| Scalar and Boolean expressions | Child occurrences and program/term/predicate distinctions; Int program relations versus Term-only Integer Boolean relations; short-circuit warning child; Boolean lowering to `Eif`; two corrections above required. |
| String callers | Concat's two stateful temporaries, static-empty-left representation, dynamic conditional, seven actuals and result-index last bound; Positive last check; two-argument length versus String length; Image's two calls and outer conversion. Eager unused initialization-check temporaries stay in pending state. |
| Declarations and assignments | Mutable regular assignment, immutable forced initialization binding/equality, split String one-time initialization with map assignment and both bound assumptions; declaration invariant suffix; checked outer conversion, length assertion and subsequent representation conversions. |
| Conditionals | Each source condition is evaluated once through `spark__branch` assignment/read; each arm and generated warning remains explicit. Missing else/unit and source labels can only remove the already retained padding. |
| Loops and captures | Whole endpoint relocation into at most two immutable captures; both program endpoints and logical index-range endpoints; descendant assignment and concrete output roots; eager snapshots even for True preservation; program Andb inside logical Assume; body once, entry/exit/update and both handlers. No trip-count multiplier. |
| Main shell | One Unit formal, True precondition, no explicit normal post, Return raise/handler, deduplicated input dynamic invariants, empty pre/post RTE ignores. No admitted refined post, extra exception/ProgramExit, source-local subprogram or recursive definition. The accepted external-constant exclusion at capacity:2270ff remains applicable. |
| Guarded query context | Separate entity-context term replay retains `epsilon result. result = f(args) /\ guard(result,args)` and its argument bindings. It is distinct from executable initialization and from per-call contracts. |
| Ignored bodies and effects | `New_Ignore` is not assumed to suppress exceptions. The reused full-source audit proves the reached ignored bodies raise-free and excludes the other source families. Zero-program-arity bindings take LDvar, including map-valued data; no body-local LDsym/LDrec, RLlemma or RLpv family is silently skipped. |
| Contracts and scopes | All selected API pre/posts, extraction definitions/residuals and eleven external effect keys are imported unchanged. Saturated calls instantiate formals with variables, retaining the full actual definition separately; logical result/quantifier/epsilon binders are not program keys. Each repeated binder occurrence gets its own scope. The sequence-key repair completes this inventory. |
| U/H and kode | Actual proxy slots, both assignment proxies, signature formals, named mutable fields and free attached-term keys are explicit. Flat all-solid types leave no extra invariant cases. Fresh families are condition proxies, each Main/internal k_fun result, optional Eexec traces and each unit handler placeholder; completed exceptional posts, white-box lost exceptions, lemma and RLpv families are zero. Handler increments are one for Main plus two per source loop. Local kode rows agree with the accepted transfer, including Cfun's separate k_fun and loop True-test skip. Optional tags and `B_reflow <= 3B+2` remain conservative. |

Lexical term coefficients retain definition weight at a let site and every
later use; logical binders are removed from the free-key map at their scopes.
Full per-occurrence terms, extraction residuals, effect records and outcome
structure remain available to the existing SP/WP transfer. A scalar kode
total is not substituted for that interface.

No other missing source/body family was found in this audit. This does not
claim that fixed-library bodies, whole-tool U/H aggregation, the final capacity
comparison or broader #119 obligations are complete.

## Amended freeze and final disposition

The correction at `ebe36e4b9c9a12cc6a5ad4fd4269f2faafeec58c` closes each
finding:

- `overflow_symbol` and `expected_range_symbol` are separate source indices.
  The selected expected check wraps the overflow result; neither copies the
  arithmetic child. Identical selected symbols still yield two distinct
  application, actual-definition and contract occurrences. Term replay
  suppresses runtime checks. The new complete Main diagram exercises mutable
  initialization, immutable initialization with separate term replay, and
  assignment to a narrowed target.
- Each sequence has a fresh `:sequence-bound` Unit identity in U0 and an
  explicit LDvar definition/context link. `program_binding_slots` includes
  both explicit bindings and sequences. The key supplies the first child's
  kode result even though the source context cannot name it. Non-Unit first
  children reject. `Expr.e_let:730–751` retains the binding, so the source
  creation chain does not rely on a later simplification assumption.
- The ordinary String comparison fold normalizes `/=` to the same native
  shape as `not (=)` in all three modes. Program mode yields the required
  typed conditional and False/True applications; the direct-helper fallback
  remains explicitly separate. Pred/Term coercions retain their established
  meanings and lexical multiplicities.

The [changed-seam audit](../evidence/retained-main-callers-final-review-20261023/audit-repairs.py)
passed **6,513 checks in 1.289046530 seconds** on Linux x86_64; its
[result](../evidence/retained-main-callers-final-review-20261023/repair-result.json)
retains exact final hashes. It checks all 1,819 sequence occurrences and 529
explicit bindings in the 60 retained Main diagrams, their U0/scope links and
the fresh-key formula, the 12 targeted repair diagrams, and the six added
source spans. It independently constructs scalar-check combinations,
same-symbol nesting, all three String inequality modes and nested sequences.
Unchanged source archives, provider lists and prior spans were compared with
the original independently checked inputs; they were not re-extracted through
the predecessor checkers. The author's final 29,358-check run remains separate
evidence, not the basis of the source induction. The later receipt commit adds
only README/round reporting and the preserved prior result.

With `B` including anonymous sequence bindings, the displayed initial union
and fresh-key transfers now cover the reviewed creation families:

```text
U0 <= 1 + |R| + B + A + 2J + sum(arity(s), s in S) + |Fields|
U <= U0 + I + P + 2C + Y + 2F + 2
Delta = 1+2F;  Cfinal <= C0+1+2F;  H <= H0+2F+2.
```

This accepts the ordinary Main interface under its explicit accepted source,
frontend/type/configuration and external-service premises. There is no
remaining finding in this review. Parent integration, whole-tool aggregation,
fixed-library-body obligations and the final capacity comparison remain
outside this acceptance; #119 is not closed by it.

No compiler, prover, target, Lean or successful predecessor-checker run was
replayed. No GitHub, shared task record, harness goal or CLI-memory write was
made. The live harness read returned no active goal. Selected reviewer settings
and the measured review interval are recorded in
[round.json](../evidence/retained-main-callers-final-review-20261023/round.json).
