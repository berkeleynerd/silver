# Main construction review checkpoint

2026-10-23 UTC. Early independent review of new #178 construction rows under
#119; this is preparation, not an acceptance or final audit.

- Selected reviewer: GPT-6 Astra / Extra High. Runtime model/effort confirmation,
  token usage and cost are unavailable. No additional agent was spawned.
- Observation began at 21:40:51 UTC. Reviewer worktree began clean at
  `00a37442cc2912a4a456717d33ee852facd1f2fc`.
- Accepted selected-contract evidence at author freeze
  `3040c6736d3a004239256b2ba50f25144e68bec8` and reviewer commit
  `00a37442cc2912a4a456717d33ee852facd1f2fc` is reused by identity. No predecessor
  checker replay or accepted-file edit is needed.
- No new target, compiler, solver, proof or capture run; no final independent
  audit before a new author freeze. No GitHub, shared-record, harness-state or
  CLI-memory writes.

## Source findings communicated during author development

The source locations below refer to the existing retained archives, not a live
upstream checkout. Author construction files were not yet available when these
findings were derived.

1. `New_Temp_For_Expr` in
   `unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz`,
   member `spark-source/src/why/why-gen-expr.adb:4962–4996`, tests
   `(Need_Temp and Get_Kind(E) not in W_Identifier | W_Deref) or
   Temp_Names_Map.Contains(E)`. Cheap identifiers/dereferences can remain
   repeated expressions. A node already registered as a temporary is rebound,
   even if its kind is Identifier. `Binding_For_Temp:311–348` consumes the
   registered entry and otherwise returns its context unchanged.
2. On the ordinary no-element-conversion branch,
   `why-gen-expr.adb:1403–1419` constructs an empty Label and then invokes the
   temporary helper. This is a genuine W_Label node. The generated builder
   implementation in `spark-source/src/why/xgen/xtree_builders.adb:238–249`
   unconditionally appends the specific empty-kind record and assigns fields;
   those records have `Kind => Mixed_Kind_Name` at `:486–492`. W_Label fields
   are registered at `spark-source/src/why/xgen/xtree_sinfo.adb:277–282`.
   Consequently the second split temporary is required on this branch.
3. Imported RKfunc/RKpred let bodies do not add their body formulas to the
   per-call cty. In `retained-producer-main-types-20261018/sources.tar.gz`,
   `why3/src/mlw/expr.ml:691–703` restricts `c_cty_enrich` and
   `local_post_of_expr` to Cfun with an empty post and kind RKnone.
   `create_rsymbol:138–150` adds the logical equality/iff for RKfunc/RKpred.
   `c_fun:828–835` uses the provided clauses and body effects.
   `why3/src/mlw/pdecl.ml:582–613` creates a separate logical definition/axiom.
   The retained typing archive's `src/mlw/dexpr.ml:1773–1789,1801–1829`
   carries the declared clauses and routine kind, including the separately
   checked constant-function case. Thus Unconstr_Array.to_array/of_array and
   Int's unspecced let-functions have the logical equality/iff call clause;
   imported declaration storage/unfolding remains a separate obligation.
4. Primitive scalar rows must distinguish their modules or explicitly choose
   a conservative larger row. In the main-type archive's installed theories,
   `ada__model.mlw:77–89` repeats `n <> first/last` or `in_range n` in the
   postcondition alongside `result=n`. Dynamic_Discrete `:459–469` has three
   arguments and analogous residuals. Boolean in
   `_gnatprove_standard.mlw:1814–1824` has only `result=n` in these posts.
5. The array primitive declarations have no hidden explicit call clauses:
   `_gnatprove_standard.mlw:1933,2013` declares slide/concat as val function;
   `ada__model.mlw:1256` declares Index_Type.mk as val function;
   `:1629–1632` defines to_array/of_array as let function without explicit
   specs. Unconstr_Array.first/last/length are instead RKnone val declarations
   with explicit result equality at `:1636–1648`.
6. The first author draft's restricted constructor order agrees with the
   complete conversion helper. Its explicit length tree must retain
   `if lf<=ll then rf<=rl /\ ll-lf=rl-rf else rl<rf`, from
   `why-gen-arrays.adb:3396–3462`; left bounds occur twice each, right bounds
   three times each. The dynamic range helper uses one target predicate with
   target first/last and source first/last (`why-gen-expr.adb:4337–4385` and
   `why-gen-arrays.adb:3305–3361`).
7. Caller mode, not native Domain alone, controls term versus program
   conversion. The main-type archive's
   `why3/plugins/gnat_json/gnat_ast_to_ptree.ml:386–395,590–592,952–975`
   retains the enclosing E/T conversion mode for child calls. Thus accessor
   arguments inside program calls are program expressions, whereas assertion
   accessors are logical terms. Label removal at `:539–542` occurs after
   the native temporary decision and does not remove that binding.
8. Static bounds are not uniformly literal leaves. `Get_Array_Attr(Ty)` in
   `why-gen-arrays.adb:2813–2834` converts `New_Attribute_Expr` to the index
   representation; the latter helper at `why-gen-expr.adb:3600–3748` can
   produce a bound symbol/call, literal or static itype expression. An
   abstract bound may retain unary to_rep. The additional conversion in
   `Add_Attr_Arg:249–277` is identity because the accessor already returns
   the representation type. Author inputs must preserve the bound tree.
9. The author identified another necessary contract distinction:
   `ada__model.Rep_Proj_Base:14–15` has the reversed program post
   `to_rep(x)=result`. `term_of_post` does not recognize that orientation;
   `of_rep:11–12` similarly has `to_rep(result)=x`. A logical-only Cpur
   application is a different route, with its own result-first make_post.
   The nearby Discrete_Base.bool_eq conditional post at `:41–42` also cannot
   be replaced by a generic equality profile without checking its typing.
   Its unsimplified profile is `7+x+y+2r`; exact extraction would additionally
   require inspecting typed conditional simplification if this symbol is reached.

## Remaining review obligations

Await substantive author rows, review actual primitive coverage and structural
composition, then perform one independent audit of the exact frozen input.
Preserve actual cheap-reference repetition and binding scopes; scalar emitted
occurrence envelopes alone do not supply binder-sensitive profiles. Check
monotonicity and usefulness, and retain the separate obligations for the Main
emitter, assignments/declarations, branch observations, warning functions, loop
frame/index assumptions, enclosing Main contract, numeric U/H and whole #119.
No current finding establishes #178 completion.

## Executable draft review, before freeze

Read author `algebra.py` without running it. Temporary nesting, explicit checks,
affine let substitution and E/T child handling agree with the reviewed source
structure. Sent these corrections/limits before the author freeze:

- Generated `tmp:<serial>` strings need disjoint identity space from externally
  supplied keys, and native uid ownership must not collide across builders.
- Monotonicity concerns positive weights with constructor/control decisions
  fixed; changing cheap syntax into complex syntax changes temporary decisions
  and need not monotonically increase the program inventory.
- Static Integer/Positive bound identifiers are nullary program applications.
  Existing Q0NIav native declaration IDs 5/16 and 151/162 are Pterm definitions;
  converter `:1044–1059` emits RKfunc, and `dexpr.ml:1817–1833` retains only
  result=logical_constant per later call. Thus a corresponding bound signature
  has post `2+r`, extracted definition 1, residual 1. Literal-subtype bounds
  can remain constants. This inspection read retained input only.
- The initial program projector rejected a supplied conditional child; a
  generic conversion wrapper cannot by itself certify full program projection
  of every ordinary String child. Add supported child forms, supply a profile
  hole, or preserve that scope limit explicitly.
- The output normalizes some native annotations: source length-equality else
  Int.< call has `Typ => Base_Ty` despite its predicate signature. E/T typing
  uses the signature. Describe normalized constructor profiles accurately,
  rather than claiming byte-exact native AST output.

No independent audit has run. Final audit must bind the exact author freeze
and inspect retained branch inputs/trees independently of the author algebra.

## Final checkpoint

The preceding sections preserve the pre-freeze state. Final author freeze
`767007bf43ad1a7ef82b8d629ab460b6186f694e` was imported as
`0225661ec05fa9dc2bd5eab3c7a24e2e17de8062`. The sole independent audit passed
13,792 checks in 0.599727 seconds on 2026-10-23 at 22:14:25 UTC. Its full
inputs, logs and round record are retained alongside this checkpoint.
All pre-freeze findings are incorporated. Final scope comparison additionally
identified the source `Is_Constrained` versus interface `target.static`
distinction: the nonstatic-target branch requires an unconstrained String type
entity. The pinned capacity provider's Main shape induction at lines 653–705
excludes dynamic constrained target entities on this GNATprove path, resolving
the concern without a new author change or checker rerun. The
[final review](../../reviews/review-main-construction-profile-20261023.md)
accepts the restricted construction row and preserves the broader Main/U/H
obligations. No accepted earlier tranche was edited or replayed.
