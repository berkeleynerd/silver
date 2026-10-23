# Early Main caller and wrapper review checkpoint

2026-10-23 UTC, recorded at 22:24:57 UTC. This is early source review of the
separate working #178 caller continuation, not final acceptance or an audit.
Selected reviewer GPT-6 Astra / Extra High. Runtime model/effort confirmation,
token usage and cost are unavailable. Active-review elapsed time was not
measured. No additional agent was spawned.

Root requested continued early review after accepting the construction review
commit `0b29dd9b215566e103e3e856a004abd9cca04a86`. Author assigned the bounded
question: establish the actual retained enclosing Main implicit clauses and
the exception frontier of generated warning/ignore Cfun while the author
implements declaration/assignment/control rows.

Author owns `docs/research/retained-main-callers-profile.md` and
`docs/evidence/retained-main-callers-profile-20261023/`. This reviewer owns only
the new caller-review packet/report paths. Accepted fixed and construction
providers remain unchanged. No final audit occurs before a new author freeze.
No author/provider Python module was imported or executed; all inspections
below read existing source archives/native JSON. No target, compiler, solver,
proof, capture, GitHub, shared-record, harness-state or CLI-memory write/run.

## Source locations

SPARK locations below refer to
`docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz`,
under `spark-source/src/`. Why locations refer to the unchanged complete files
in `docs/evidence/retained-main-construction-profile-20261023/sources.tar.gz`.
The retained native witness is `obj/gnatprove/main.gnat-json` in
`docs/evidence/retained-main-typed-profile-20261023/retained-main-input.tar.gz`.
These retained providers preserve existing source/runtime assumptions; they
are not newly captured executable evidence.

## Caller contract correction

`why/why-gen-arrays.adb:2131–2192` creates the array Boolean equality as Pterm
with nonempty binders and a definition. Converter
`plugins/gnat_json/gnat_ast_to_ptree.ml:1067–1090` emits a separate logical
definition and an RKnone program val with explicit `result=logic_application`.
The first working draft called this RKfunc. The author has corrected both the
note and catalogue route. The generic value post, extraction and residual cost
remain valid; the logical quantified body is not a per-call expansion.

This differs from Pterm with binders and no definition (`:1060–1066`, RKfunc,
as for String.to_string), and the nullary Pterm route (`:1044–1059`, RKfunc,
as for Integer/Positive bounds). Read-only comparison also agrees with the
concat source's right-outermost temporary binding order, static-empty-left
branch, explicit nonstatic-left conditional and index-type-last argument in
`Build_Last_No_Slide`, despite the latter helper's misleading comment.

## Main wrapper clauses

The existing Main grammar and fixed-call source exclusions remain premises:
Main is a nondispatching procedure with no formals, user contracts, variants,
source handlers/return, borrows or allocated parts; selected calls have no
exceptional/program-exit contracts. The accepted capacity source argument
already treats these guards. The current inspection follows the resulting
retained structure, rather than redoing that successful capacity audit.

In `why/gnat2why-subprograms.adb`:

- Effects begins as `New_Effects` at `:5583`. Exceptional and program-exit
  effect additions are gated off by the absent contracts. The final declaration
  at `:6253–6263` supplies one Unit_Param, default precondition, no postcondition
  (`Post_As_Pred:5316–5355`), empty declared effects and the composed body.
- Regular-body construction at `:5853–5872` retains declarations and handled
  statements once, appends a final Return raise, and catches it using the
  singleton handler at `:5413–5419`. Extra Ada/program-exit handlers are gated
  by `Has_Exceptional_Contract`/`Has_Program_Exit` at `:5843–5846`.
- No formals makes `Check_Init_Of_Out_Params:4958–5027` Void. No inline/logical
  equality annotations makes `Check_Inline_Annotation:5033–5076` Void. The
  ordinary fixed global types have no user type invariants. No Refined_Post
  disables all of `Checking_Of_Refined_Post:5100–5169`, including its dynamic
  output-property suffix. Thus that suffix must not be copied into Main merely
  because completion/callee contracts contain dynamic output properties.
- `RTE_Of_Pre:5362–5377` and `CC_EC_And_RTE_Post:4718–4735` each ignore the
  empty specification's True expression. Converter Binding `:600–611` removes
  the unused pure definition; Abstract_expr `:889–905` then yields unit.
  Their native allocation was already covered by the older capacity allowance.
- No Pre/Post location makes the inconsistency-warning helpers return Void at
  `:5474–5475` / `:5434–5435`; post-warning selection is additionally disabled
  for a body in SPARK at `:6219`. Absent contract/exit cases leave the maps and
  checks empty. No dynamic termination condition or variant adds a binding.
- No precondition location suppresses the initial-condition abstract block
  (`:4670–4681`). No allocated output parts gives no moved-pointer input clause
  (`:1826–1860`). The existing capacity argument excludes external constant
  assumptions and nonempty finalization actions for this grammar.

Empty native declared effects do **not** establish empty typed effects.
Why `src/mlw/dexpr.ml:1773–1789` types the body before `c_fun`, and
`src/mlw/expr.ml:828–835` passes the actual body effect to `create_cty`.
Main retains its inferred reads/writes and the eleven-key external family
where output calls are reached.

## Input dynamic-invariant slice

`Compute_Dynamic_Property_For_Inputs:1283–1353` collects referenced global
reads/writes and formals. There are no Main formals. `Process_Referenced_Entities`
in `spark/spark_util-subprograms.adb:1900–1915` skips Magic_String, leaving the
four concrete Silver_IO globals from the selected effect family.

`Assume_Dynamic_Invariant_For_Variables` in `why/gnat2why-expr.adb:2362–2461`
skips local Main entities (`:2402–2407`) and deduplicates work (`:2437–2457`).
`Assume_Declaration_Of_Entity:2041–2077` supplies the dereferenced object,
Initialized flag, Only_Var=False and Top_Predicate=True to the dynamic
invariant builder. The fixed Byte/Count types select the named five-argument
predicate at `:6758–6791`; their fixed types add no dynamic variable inputs.
Standard.Boolean is excluded from that named-predicate branch (`:6760`), and
adds no range, user predicate or type-invariant clause. The opaque keys never
enter this entity traversal.

The native witness's Main function 5353 has input assertions 5369 and 5392:

```text
Bytes.dynamic_invariant(map__content(Written_Bytes), True, False, True, True)
Count.dynamic_invariant(int__content(Written_Count), True, False, True, True)
```

Each retained logical term has weight `6+weight(key)`, or seven at unit weight.
There are at most two such clauses, conditional on the reached global family.
This is a fixed-source template inspection; the witness alone does not prove
the arbitrary-Main statement. Boolean/opaque keys still belong to effects even
though they add no input invariant term.

## Generated Cfun exception frontier

`New_Ignore`, `why/why-gen-progs.adb:199–213`, builds a discarded-value binding
with unit context and then an Abstract_expr with True post. It is not generally
an exception suppressor. Converter `:889–905` makes a nullary function when
the expression cannot simplify to unit. Why `c_fun:828–835` uses the child
body effect; `e_exec:755–773` deliberately retains the underlying zero-argument
Cfun effect except exceptions removed by false exceptional posts.

Also, `no_vcs_no_side_effects` is not a no-raise predicate. Converter
`:271–321` returns true for payload-free raises, recursively for raises with
arguments, and for assumes. A True-post ignore containing only such pure
structure may disappear before typing. A surviving Cfun needs the actual
body's exception proof; its helper name is insufficient.

The reached dead-code/branch and inconsistent-assume warnings are more
specific: `why/gnat2why-expr.adb:31187–31204,31245–31260` wraps only an
Assert/Check False. Assert/Check is not simplified by the converter's predicate
(`:318`); Why `e_assert:1116–1118` introduces reads and no raises. Thus these
warning Cfun have no escaping exceptional frontier. Empty pre/post ignores
vanish as described above. Other ignored expression/check children must retain
the no-escaping-raise induction from their actual constructors/contracts.

Zero escaping raises does not mean zero outcome-counter work. A retained
warning Cfun still has its internal `k_fun`/fresh-result traversal. Main's
appended Return raise has a real payload-free handler: count its reached
`nh` and `unit_h` despite the final effect's empty raise set. Loop handlers
need their own reached occurrence counts. Therefore do not infer zero H
increments from the final empty exception effect, and do not erase nested
Cfun merely because selected library calls have no raises.

## Loop handler and Boolean-conjunction refinements

`why/gnat2why-expr-loops.adb:2194–2334` always creates the inner Continue
handler (`:2244–2247`) and outer Exit handler (`:2301–2304`), with the generated
Exit raise at `:2259–2261`. No source continue does not remove its typed handler:
the converter at `:930–940` retains every handler;
`why3/plugins/gnat_json/ptree_constructors.ml:134` constructs Ematch directly;
`src/mlw/dexpr.ml:1641–1660` retains the unit handler; and
`src/mlw/expr.ml:1038–1090` does not filter handlers whose symbols are absent
from the body's effect. The extra Ptree constructor and VC sources are in
`retained-producer-main-types-20261018/sources.tar.gz`.

In that archive's `why3/src/mlw/vc.ml:857–872`, every retained handler allocates
`new_exn` and, for a payload-free handler, a unit program variable before
traversing the body. Thus each reached ordinary loop traversal contributes
`nh=2` and `unit_h=2`, even for the unused Continue handler. Main adds one each.
The two local exception kinds remain caught, so this is consistent with an
empty escaping frontier. Existing no-body-duplication premises must remain
attached to conversion of the loop; these are per reached traversal counts.

The author identified a further term-context seam, independently confirmed:
the implicit invariant joins Dyn_Types_Inv and Index_Inv using New_And_Expr
with program domain (`why/gnat2why-expr-loops.adb:1776–1785`). The helper at
`why/why-gen-expr.adb:3488–3502` first elides syntactic True operands, then
otherwise selects Boolean.Andb. Installed `bool.mlw:8` declares the Boolean
value function. Under a logical Assume, Why `dterm.ml:638–640` requests value
context for both actuals, while `:613–617` supplies the conversions. If both
children are predicates, the unsimplified logical profile is `9+P+Q`: one
Andb, two three-node predicate-to-Boolean conversions and one two-node outer
Boolean-to-proposition conversion. A child already typed Boolean omits its
three-node conversion. Preserve the complete resolved tree and True-elision
case; simplification can reduce this upper envelope. Program entry-condition
Andb retains its program comparison applications/contracts instead.

## Next step

The author is implementing the separate declaration, assignment, observation
and loop rows. Integrate these source findings into that new provider, retain
its complete source/identity records, then freeze it for one independent audit.
The current read-only findings do not close #178, arbitrary Main U/H, or #119.
