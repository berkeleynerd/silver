# Fixed backend context: source projection and import boundary

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
The five retained fixed-library JSON inputs now have an exact pretyping
declaration projection and a complete explicit imported-file closure. All five
load the same **11 files, 318,006 bytes and 252 modules**, containing **304 use
and 174 clone directives**. These are input counts, not typed allocation or
lifetime-identifier counts. Admission remains unchanged.

The [packet](../evidence/retained-producer-fixed-context-20261018/README.md)
retains all eleven installed library files and fifteen complete Why3 source
files at `9390baf120ef260547dfa14f08e11c890b203d9c`, with hashes. Its offline
checker reads the existing five complete native JSON files from the
[fixed-body packet](../evidence/retained-producer-bodies-20261018/README.md).
It performs no producer, Why3, solver, compiler, Lean or full-suite execution.
The existing source-to-installed-tool premises remain; this source projection
does not recover the installed SPARK archive's historical revision.

## Exact native declaration conversion

The converter dispatches each native declaration through `mk_declaration`
(`gnat_ast_to_ptree.ml:1011–1313`). A native function can produce two Ptree
declarations: a logical definition and an abstract program declaration with
an equality/equivalence postcondition. Counting native function nodes alone
would miss that second declaration. A native axiom with a dependency also
emits a separate metadata declaration.

The checker reproduces these declaration branches, recursively visits native
namespaces, and deduplicates imports using the converter's per-module key
(`:130–176,1315–1335`). It fails on an unhandled declaration or substitution
kind. The Ptree totals include scopes, metadata and imports, but exclude
expressions, terms, binders and type annotations inside each declaration.

| Backend input | Native modules | Ptree declarations | Dlogic | Dlet | Eany declarations | Efun declarations | Native clones |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Input_Is_Valid | 21 | 199 | 18 | 34 | 33 | 1 | 8 |
| Is_Message | 12 | 121 | 14 | 20 | 19 | 1 | 7 |
| First_Or_Default | 41 | 343 | 22 | 55 | 54 | 1 | 10 |
| Put | 46 | 352 | 27 | 62 | 61 | 1 | 13 |
| Put_Line | 46 | 352 | 27 | 62 | 61 | 1 | 13 |

Thus every native file has exactly one top-level program body, for its selected
entity. Other native callable declarations are generated `Eany` expressions;
logical definitions and axioms still retain formulas. This statement concerns
the native JSON conversion, not every body in the imported Why3 libraries and
not nested abstractions within the selected body. Eany/Efun are Ptree forms;
the table does not equate them with final typed Cany/Cfun counts.

All native clone origins belong to this five-module set:

```text
_gnatprove_standard.Array__1
ada__model.Static_Discrete
ada__model.Rep_Proj_Int
ada__model.Unconstr_Array
ada__model.Constr_Array
```

The converter emits only nullary symbol-to-symbol `CStsym`, `CSfsym` and
`CSpsym` substitutions, together with `CSprop Paxiom`
(`gnat_ast_to_ptree.ml:1240–1280`). The corresponding `type_inst` branches
populate `mi_ts` and `mi_ls`; they do not populate `mi_ty`, `mi_rs`, `mi_pv`
or `mi_xs` (`typing.ml:1593–1673`). Consequently these native clone directives
cannot select the program-routine refinement branch guarded by
`Mrs.mem rs inst.mi_rs` in `clone_pdecl` (`pmodule.ml:1380–1447`). This removes
that particular additional Cfun/VC construction from their accounting. It
does not remove ordinary clone allocation, type checking, logical-definition
checking or the independent type-invariant refinement path. It does not
restrict the substitutions of the 174 imported-library clone directives.

## The imported unit is an entire file

`find_module` resolves a qualified name with `read_module`
(`typing.ml:1584–1591`). `read_module` obtains the file's module map from
`Env.read_library` before selecting the named module (`pmodule.ml:1699–1702`).
For textual `.mlw`/`.why` inputs, `Lexer.read_channel` invokes the whole-file
parser, whose incremental actions type each module and declaration
(`lexer.mll:259–279`; `typing.ml:1816–1842,1898–1966`). For native JSON,
`type_mlw_file` explicitly folds through every module (`typing.ml:1756–1769`).
Neither path loads just the requested module.

The three explicit native file roots are `_gnatprove_standard`, `ada__model`
and `int`. Following every use/clone directive in their entire files gives:

| File | Modules | Use directives | Clone directives |
| --- | ---: | ---: | ---: |
| `_gnatprove_standard.mlw` | 65 | 76 | 28 |
| `_gnatprove_standard_th.why` | 5 | 7 | 0 |
| `ada__model.mlw` | 69 | 77 | 63 |
| `algebra.mlw` | 13 | 0 | 18 |
| `bool.mlw` | 2 | 0 | 0 |
| `bv.mlw` | 24 | 43 | 21 |
| `ieee_float.mlw` | 13 | 32 | 9 |
| `int.mlw` | 20 | 22 | 6 |
| `number.mlw` | 5 | 19 | 1 |
| `real.mlw` | 14 | 27 | 3 |
| `relations.mlw` | 22 | 1 | 25 |
| Total | **252** | **304** | **174** |

The exact per-directive source line and target are retained in `result.json`.
The checker recognizes nested Why3 comments, including the special `(*)`
operator rule in `lexer.mll`/`lexlib.mll`, and quoted path identifiers. It
checks every unqualified target against the file's module names or the
explicit builtins, and refuses unsupported comma-separated use targets.
This is a restricted dependency scanner for the retained files, not a general
WhyML parser or a type checker. Module bytes are pinned independently.

In particular, selecting integer-only native operations still loads the
floating-point and bit-vector modules in these shared files. The imported
`ieee_float` library contains `let function`/`let predicate` definitions as
well as abstract declarations. Main's case-free frontier cannot be used as a
global description of this setup.

`Env.read_library` caches each file's module map per environment
(`env.ml:212–218`), and detects circular file loading (`:199–210`). The file
closure is therefore paid once per fresh backend environment, not once per
native import occurrence. Builtin modules and lazily created tuple modules
are additional source-defined setup; they are not disguised as external file
bytes in the table.

## Sharing, cloning and axiom elaboration

`use_export` merges known declarations once per used module identity and
refers to the existing module (`pmodule.ml:276–290`). It still appends a Uuse
unit and merges namespace maps on every call. Repeated use is not repeated
typing of all its formulas, but it is not allocation-free either.

`clone_export'` instead folds over the origin's module units
(`pmodule.ml:1590–1634`). Udecl units are cloned, Uuse units reuse their
imported module, nested clone metadata is mapped, and scopes are traversed.
Cloning an origin whose local declarations already include earlier cloned
declarations visits those declarations too. The scalar number of clone
directives is therefore not an upper bound on cloned declarations.

For already typed pure formulas, `clone_term` is `t_gen_map` over type,
logical-symbol and variable renamings (`pmodule.ml:676–678`). It preserves
the fully opened term-occurrence skeleton, modulo simplification; type,
region, variable and cached-substitution storage remain separately charged.
No source expression is substituted for a logical function symbol here.

The axiom-to-callable path is also explicit. `Typing.add_prop` retains the
typed proposition and, for a non-goal proposition, first attempts `create_val`.
That constructs a ghost Cany from `Expr.cty_from_formula` and adds its let
declaration with `vc:false` (`typing.ml:1567–1580`). An unbound type variable
can make the attempt return without the new declaration, after intermediate
work. Counting at most one additional callable declaration per typed axiom
or lemma is valid; treating axioms as only proposition nodes is not.

A useful local formula transfer follows directly from
`expr.ml:781–828` and `ity.ml:1267,1359–1434`. Let `F` be the fully opened
term-occurrence count of the already typed axiom, including trigger terms,
and let `a` and `r` be the numbers of universal argument and existential
result variables stripped by `cty_from_formula`:

```text
sum(occurrences of new contract preconditions and its one postcondition)
  <= F + 3
new tuple-case patterns <= r + 1 when r >= 2; otherwise 0
```

The pre-decomposition removes leading universal quantifiers and implications,
retaining each antecedent once. Its substitution maps variables to variables.
Post-decomposition removes existential binders and reassociates the right
conjunction spine without duplicating its operands. With zero or one result,
`create_post` adds one epsilon node. With several results it also adds one
case and its result-variable term, plus the separately counted tuple pattern.
`create_cty` checks the formulas and constructs effect/type metadata; it does
not add formula operands. Triggers discarded with opened outer quantifiers
are conservative overcount in F. The original proposition remains retained,
so together its formula and the new callable contract cost at most `2F+3`.

This bound concerns retained fully opened formula occurrences only. Opening
quantifiers creates fresh variables; lazy substitutions, maps, tuple types,
effects and intermediate terms still allocate. It is not a lifetime creation
bound, nor does it assert that all imported declarations are case-free.

## Exact remaining quantitative join

For the literal-output family, the
[zero-Main-check source argument](retained-producer-zero-check-sources.md)
eliminates variable Main backend formulas altogether. The unchanged fixed
library sources still select five backend inputs, each with the closure above.
The existing body independence argument means longer literal-output Main
source does not add another imported module or formula to those inputs.
Fresh native IDs and source-location metadata remain separately bounded and
must preserve their established semantic role; this record does not infer
execution identity merely from similar-looking names.

The largest remaining fixed source-to-typed join is now concrete: bound the
**lifetime creation requests and representation sizes while typing all 252
modules and expanding their 174 clone directives**, then the per-input native
7–13 clones, contracts, and one program body. The required vector includes
typed formula/definition/alias occurrences, variable-use multiplicities,
types/regions, namespace and known-declaration maps, and fresh identifier and
hash-cons requests. `Ident.id_register` increments its own counter
(`ident.ml:187–192`); each `Hashcons.Make` instance has a separate `next_tag`,
which increments on a fresh weak-table entry or `unique` request
(`hashcons.ml:37–50`). Retained node counts do not bound these lifetime totals
when weak entries can be collected and recreated.

The earlier task bounds `G <= 2981`, `R <= 51` remain valid but do not price
this context. Each backend process owns its own counters; adding all five
counts into one artificial identity space is unnecessary. This packet closes
the exact pretyping/import projection and two local typed transfers; it does
not supply the missing full typed-lifetime vector or complete #119. No broader
proof or validation rerun is warranted by these source-only findings.
