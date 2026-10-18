# Fixed backend context: source projection and import boundary

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
The five retained fixed-library JSON inputs now have an exact pretyping
declaration projection and a complete explicit imported-file closure. All five
load the same **11 files, 318,006 bytes and 252 modules**, containing **304 use
and 174 clone directives**. These are input counts, not typed allocation or
lifetime-identifier counts. A retained ordinary application run also supplies
successful acceptance of all five **byte-identical** inputs, including their
typing and VC construction. Admission remains unchanged.

The [packet](../evidence/retained-producer-fixed-context-20261018/README.md)
retains all eleven installed library files and twenty-six complete Why3 source
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

## Retained ordinary acceptance and its read projection

The historical application workspace
`.silver/linux-x86_64/program-Z0j19G` belongs to successful managed test run
`20261017T121442-e0df446200f8` on 2026-10-17. Its complete local test log is an
exact substring of the retained managed log. The latter names the workspace,
reports `Success: all checks proved (71 checks)`, and records compilation,
binding and linking through its executable. The archived `gnatprove.out`
separates 19 flow checks and 52 proof checks. Five proof checks belong to that
historical Main; **47 belong to the unchanged fixed libraries**.

All five complete `.gnat-json` files are byte-for-byte equal to the fixed-body
capture used above. This comparison does not erase native IDs, names, labels,
locations or any other fields. All six copied library sources equal both the
current source files and the historical test run's captured source hashes.
The archived `.spark` records and Why3 sessions reconcile as follows:

| Fixed input | Native JSON bytes | Library proof records | Session file status |
| --- | ---: | ---: | --- |
| First_Or_Default | 286,340 | 9 | proved |
| Input_Is_Valid | 121,828 | 1 | proved |
| Is_Message | 85,809 | 1 | proved |
| Put | 274,756 | 16 | proved |
| Put_Line | 288,617 | 20 | proved |

Each session identifies its matching `gnat-json` filename. Some individual
prover attempts are recorded as `highfailure`; alternate attempts completed
the goals. Neither the table nor the managed run means every attempted prover
invocation succeeded. No native tool was rerun to assemble this packet.

The source read projection establishes what that acceptance covers:

1. The ordinary controller loads drivers, then adds the selected file or
   reloads the existing session (`gnat_checks.ml:380–450`). A new session calls
   `Controller_itp.add_file`, which calls `Session_itp.read_file`
   (`controller_itp.ml:271–290`). Reload calls `merge_files`, whose reparse
   function calls the same reader (`:249–271`; `session_itp.ml:1921–1928`).
   `Env.read_file` opens and parses the file; it does not recover a previously
   typed input from the solver-result cache (`env.ml:157–166`). Thus ordinary
   proof caching does not by itself bypass this typing prefix.
2. The JSON reader converts the complete input and calls `Typing.type_mlw_file`
   (`gnat_ast_to_ptree.ml:1382–1418`). That function folds all native modules;
   `add_decl` types their declarations and generates their VCs in ordinary
   proof mode (`typing.ml:1675–1769`). The successful prefix includes the
   imported typing/clone work above, native declarations, and body VCs. It is
   stronger evidence than a diagnostic which enables `type_only`.
3. Driver loading is earlier than native input typing
   (`controller_itp.ml:114–136`). Drivers themselves read theories
   (`driver.ml:235–249`), and the environment's load path comes from the fixed
   configuration (`gnat_util.ml:101–124`). Therefore the **eleven-file table is
   the explicit native/import closure, not a whole-process load inventory**.
   Driver-selected context is an additional fixed configuration component.
   Its successful historical processing is covered by this witness; changing
   driver/configuration/library bytes requires a new read projection.
4. `gnat_main.ml:332–360` initializes the controller before registering and
   scheduling proof tasks. In `gnat_config.ml`, the requested step limit is
   consumed by `steps`/`limit` (`:629–655`). Changing only `--steps=100000` to
   `--steps=0` changes later prover limits, not this typing/VC prefix. Changing
   to `No_WP` would change it: that mode enables `Typing.debug_type_only`
   (`:687–689`). Solver limits, races and later driver transformations remain
   separate from this acceptance transfer.

Under the existing source-to-installed-tool and unchanged-configuration
premises, the fixed prefix's ordinary input/representation requests can
therefore be reused as an accepted fixed component. The
[isolated-library source reduction](retained-producer-fixed.md#separate-fixed-library-processes)
keeps Main out of these inputs, and the
[zero-Main-check family](retained-producer-zero-check-sources.md#literal-output-source)
adds no Main backend process. Extending a Main in that family does not add
module/clone work to any of the five fixed processes. Each process starts its
own counters; they are not accumulated across Main or the other four files.

This is a fixed-input/configuration transfer, not permission to erase arbitrary
metadata. Native IDs mostly annotate conversion diagnostics, but loop-variant
temporary names also use them (`gnat_ast_to_ptree.ml:807–813`); source-location
labels enter attributes (`:60–64,249–256`). The witness needs no renaming
argument because those bytes are equal. Input/session paths, driver paths,
diagnostic formatting, generated dummy locations and later session records
retain their separate representation obligations. A future input differing
in one of those fields must satisfy the corresponding source projection,
not merely resemble this input after normalization.

The historical test ledger records the Silver executable hash and its source
and generated configuration inputs, but no separate historical `gnatwhy3`
executable hash or complete historical driver/library inventory. The archived
`src/silver.adb` is taken from executed snapshot `78cf419452` and hash-equals
that ledger input. It is not silently replaced by today's later indexed-Main
implementation. The producer's temporary option files named in the `.cswi`
records are gone. These limits remain; the witness does not manufacture a
stronger installed-tool identity than the retained evidence supplies.

## Counter behavior and the remaining boundary

The acceptance transfer does not establish an exact lifetime-allocation trace
or a bound independent of garbage-collection schedules. `Ident.id_register`
increments a private counter on every call (`ident.ml:187–192`). Each `Hashcons.Make`
has its own weak table and counter; only a fresh merge or `unique` increments
it (`hashcons.ml:37–50`). A dead value can be collected and later reconstructed.
Retained typed nodes therefore cannot be substituted for lifetime creation
requests. Ephemeron memoization retains an entry while its key remains live
(`weakhtbl.ml:65–104`), but that fact does not establish that every potential
key stays live throughout typing or across later transformations.

OCaml integer arithmetic wraps by its ordinary integer semantics. Crossing
positive `max_int` is consequently not itself a checked overflow failure;
the cited map/set/hash consumers compare integer tags with `Int.compare` or
integer equality (`wstdlib.ml:61–66,87–100`; `weakhtbl.ml:69–75`). This does
**not** remove the finite-identity obligation. `Weakhtbl.tag_hash` asserts
that a tag is not the reserved `-1` (`:50–58`), and a full-cycle reused tag
makes the cited consumers equate otherwise distinct live objects. `Extmap`
then finds/replaces an entry when the comparator returns zero
(`extmap.ml:150–176`). Type and program-type tables use exactly these consumers
(`ty.ml:92–114`; `ity.ml:125–154`). The modular arithmetic is defined; these
identity collisions would still be semantically wrong.

A sufficient positive-counter bound remains valid, although `max_int` is
conservative rather than an established exact failure threshold for every
consumer. This packet neither assumes wrap is harmless nor claims a concrete
counter failure occurs in the fixed context. Ordinary request acceptance can
transfer without an invented aggregate heap number. Any quantitative claim
about all lifetime counter histories still needs a separate bound or a more
specific source reduction; the successful witness alone does not supply it.

For the literal-output family, the
[zero-Main-check source argument](retained-producer-zero-check-sources.md)
eliminates variable Main backend formulas altogether. The unchanged fixed
library sources still select five backend inputs, each with the closure above.
The existing body independence argument means longer literal-output Main
source does not add another imported module or formula to those inputs.
Fresh native IDs and source-location metadata remain separately bounded and
must preserve their established semantic role; this record does not infer
execution identity merely from similar-looking names.

The earlier task bounds `G <= 2981`, `R <= 51` remain valid but do not by
themselves price context creation or later driver transformations. The exact
pretyping/import projection, two local typed transfers and retained fixed
ordinary acceptance now stand together. No full typed-lifetime vector or
whole-tool capacity predicate is claimed, and #119 remains incomplete. The
remaining work should address a concrete uncovered representation or changing
component; rerunning this fixed proof prefix merely to duplicate success would
not establish the absent counter bound.

The native-expansion reviewer independently replayed the packet and checked
the add/reload/parser route, hash-cons increments and weak-table consumers.
The scoped transfer was accepted without a blocking finding; that review
performed no native execution.
