# Selected library origins and later path writers

2026-10-20 UTC, #119 / #153 Round 32. Base
`2866d4642c43444abd18e0b6e9600edaa216b99b`, five retained Linux x86_64 processes.
The [Round 31 review](../reviews/review-save-capacity-round31-20261020.md) and
normal-service clarification `97914a071c01087cc6738ed318ac4e048e8a8cc7` are
reused. This packet performs no target, capture, proof or predecessor replay.

**Every selected later Theory path registration has qualified payload at most
116,162 bytes**, under the existing fixed-input/source/runtime relation and
the normal numeric/allocation service contract. The source argument below
discharges the named-library selection issue and replaces the unnecessarily
strong requirement that *all* parser body symbols have library-local origins.
Identifier-tag collisions are allowed. Initial selectable values and native
path construction are separate Round 32 components; this packet alone keeps
actual whole-process R/U unknown.

The numerical result is the accepted `3*S+128`, with the same four complete
library files and **S=38,678**. No larger source family or new numeric headroom
assumption is needed. This is a bounded semantic source argument for review,
not a theorem proved by the accompanying census/checker.

## Named module selection is independent of identifier tags

The [fixed invocation](retained-producer-driver-envelope.md) has one configured
environment, the three automatic drivers, counterexamples off, no replay,
manual driver, debug-save or interactive reload. The environment and driver
objects are retained by the controller and driver closures.

`Env.create_env` has its **own** counter, initialized to -1; it does not use
`Ident.id_register` (`env.ml:31–45`). The selected source constructs exactly
the following environments:

1. `Pmodule.dummy_env = Env.create_env []`, once at module initialization
   (`pmodule.ml:382`). Builtin modules use this object.
2. `Gnat_config` calls `Gnat_util.build_env_from_config` once at initialization,
   which creates the configured environment after loading the fixed plugins
   (`gnat_config.ml:346–409`, `gnat_util.ml:110–123`).

Their tags are 0 and 1. The complete retained `Env.create_env` reference census
also contains other application entry points and the controller's hard-reload
branch. These are not roots of this standalone invocation. In particular,
GNAT's old-session reload is before the cut and omits `hard_reload`, whose
default is false (`gnat_checks.ml:413–448`, `controller_itp.ml:246–261`);
the retained sessions are fresh anyway. No selected preparation, result,
save/ending or registered pending client calls another constructor. Thus the
outer `Wenv` memo cannot redirect a lookup to a different environment through
a wrapped owner tag. This small separate counter argument is not a freshness
argument for identifiers, terms, declarations or tasks.

Inside an environment, `Env.Hpath` keys are **string lists**, hashed by
`Hashtbl.hash` and compared by structural `(=)` (`env.ml:54–58`). A hash
collision still checks the complete key. `Pmodule.read_module` then uses
`Mstr.find` on the requested module name (`pmodule.ml:1699–1702`). Local
same-file module selection uses the same string map
(`typing.ml:1583–1591`). The builtin memo also uses string-list keys. No lookup
in this chain uses an identifier's numeric tag to choose a named module.

`Env.store` publishes a file map only after its parser returns, under the
same path passed to that parser. The parent-language `push` maps each module
to its theory without renaming the string key (`env.ml:82–125`,
`pmodule.ml:1662–1671`). Losing an outer memo entry or an inner table entry
can force a repeated parse; it cannot turn `["int"]` into another file key.
An incomplete table mutation may lose a binding, and an escaping exception
may abandon a parse. Successful reached lookups still return a binding
installed for that exact key under the inherited valid table/source relation.
This argument needs neither a normal memo hit nor preservation of every entry.

`locate_library` constructs the filename from the string path, tries the fixed
loadpath/extensions, and rejects missing or ambiguous resolution
(`env.ml:169–194`). The accepted fixed-context input relation supplies the
exact installed bytes, including later reads; it is not a claim about arbitrary
external file replacement. The `.mlw`/`.why` parser registration is the
retained `Lexer.read_channel`; the two fixed plugins add distinct `adb` and
`gnat-json` extensions. A returned file map therefore consists of the named
definitions from that file, with its declared imports. The companion
[inventory](retained-why-path-input-inventory.md) supplies the exact four-file
DAG, including same-file references to preceding definitions and the sole
external source builtin `why3.WellFounded.WellFounded`.

The incremental parser pushes a new slice with empty `file` and no open module.
Each module is created under that slice's environment/path, then inserted under
its lexical name. Nested library reads get their own slices. The grammar
closes/pops a successfully parsed file; the lexer discards the current slice
when parsing raises (`typing.ml:1781–1842,1894–1967`, `lexer.mll:259–279`).
Stack manipulation does not run a parser callback. The selected pending roots
save/exit or yield, and never enter the parser. Thus there is no reentrant
foreign parser that can substitute another slice's namespace at a declaration
action. A failed read does not install a completed file map.

## Declaration origins, allowing foreign body-cache hits

The global `Ity.restore_its`, `Expr.restore_rs` and `Ity.restore_pv` tables
really are keyed by numeric tags. Their hits are **not** asserted to be the
corresponding physical symbols. The relevant invariant is narrower:

- Module namespace units and declaration lists originate in the corresponding
  named DAG definitions and builtins.
- A declaration's introduced type, constructor, projection, logic, routine or
  proposition head has a lexical/fixed builtin stem, with the already bounded
  generated suffixes. The same bound covers locally introduced routine heads
  inside its body. Its `known` maps contain declarations from this family.
- Type-definition graphs used to construct/clone **type declarations** contain
  types from those namespaces, their local substitutions and builtin types.
  This clause does not assert that all types appearing in expression bodies
  or routine contracts have the same origin.

The distinction closes the global-cache question without pretending that those
caches are fresh. The supporting source cases are:

| Operation | Why it preserves the relevant origins |
| --- | --- |
| Lexical type declaration | `Typing.add_types` builds its `def`, `hts`, `htd` and field-name tables with string keys. Its `parse` resolves types from those tables or the current module namespace. It does not use `restore_its`. `Pdecl` constructors create the type using the supplied lexical identifier; alias types retain a newly supplied head (`typing.ml:1315–1474`, `pdecl.ml:20–143`, `ity.ml:587–616`). |
| Type hash-consing | `Hsity.equal` checks physical `its_equal` / `reg_equal` / `tv_equal` and physical child identity, rather than equating a type solely from a numeric tag. A hash collision cannot replace its type head (`ity.ml:125–171`). |
| Program declaration | `let_var`, `let_sym` and the final `let_rec` heads use their supplied lexical identifiers. Recursive effect repair uses `rs_dup`, which copies that head's string. The body and its inferred types do not supply the new binding's name (`expr.ml:115–173,721–733,1238–1307`). |
| Program restoration | `restore_its` converts a logical type in a program expression; `restore_rs` supplies a routine for expression/undereference/pattern handling; `restore_pv` supplies a program variable or ghost flag. The full retained reference census includes these uses. They may change an expression, inferred type or validation outcome. None returns a module, declaration, namespace unit or a replacement top-level binding identifier. |
| Parser proposition/logic declaration | Heads come from `create_user_id`; `create_val` uses that proposition head for its lemma routine. Logical symbol/term constructors do not run Theory insertion. Foreign symbols in formulas remain references, not new declaration heads. |
| Declaration hash-consing | Every `Hsdecl.equal` case compares each introduced symbol physically, including Dtype, Ddata, Dparam, Dlogic, Dind and Dprop. A numeric tag alias cannot import another declaration's introduced name merely by sharing its hash (`decl.ml:340–370`). |
| Known maps and namespace merges | `add_pdecl_raw` inserts the declaration being built; `use_export` imports the selected module's known declarations and namespace. A body reference may affect validation or `pd_syms`; it does not cause `restore_module_id` to import that symbol's defining module (`pmodule.ml:279–312,345–377,527–568`). |
| Clone maps | `cl_init` starts fresh per clone. Its initial substitutions are selected from the source and receiving namespaces. Later entries come from these declarations and locally created copies, including nested routine logical heads as detailed below. Tag aliases may select another entry from this bounded head family. The globally shared `impl_cl`/`mod_table` belong to the separate interface implementation route and are not used by ordinary `clone_export` (`pmodule.ml:575–1150,1487–1702`). |

Nested routine heads need their own case. `clone_expr` visits an `Elet` through
`clone_let_defn`; `sm_save_rs` can place its new logical symbol in the shared
`cl.ls_table` (`pmodule.ml:879–884,986–1082`). A later numeric alias can
therefore expose that local head when `clone_decl Dlogic` reconstructs its head
through `clone_fmla` and `ls_defn_of_axiom`. It is not sufficient to say that
body names cannot affect a top-level head. Instead, the nested *introduced*
routine heads also belong to the bounded stem family: `Typing` builds their
identifiers from lexical `Elet`/recursive-function binders; `Dexpr.sym_defn`
and `rec_defn` pass those identifiers to the routine constructors; its extra
function proxy uses the fixed name `h`. `create_rsymbol` creates any `RLls`
head from the supplied identifier. Recursive effect repair and clone routines
copy that head (`typing.ml:188–199,1063–1073,1206–1218`,
`dexpr.ml:1497–1545,1732–1788`, `expr.ml:112–171,1189–1307`).
The restoration caches return symbols, not function bodies or `let_defn`
nodes; applications of foreign restored routines do not splice definitions
into this syntax tree. Thus every value written by this additional
`cl.ls_table` route has a lexical/fixed stem even if its body/signature contains
foreign references. `ls_defn_of_axiom` reads the mapped formula's head; it does
not perform another global symbol restoration (`decl.ml:82–104`).

The delicate case is `clone_type_decl`. It recursively visits type symbols
found in a type declaration's type graph and looks up their definitions in
the local `def` map. A numeric alias could pair a different symbol and
definition, so merely saying “clone copies its original name” would be
insufficient. Here both are in the bounded type-definition family above.
`conv_ity` does not restore a global program symbol. Its type map values,
recursive placeholders and copied field/constructor names are all from that
family (`pmodule.ml:1167–1346`). `kn` is the receiving module's known-declaration
map, not a global symbol-to-module cache. The one concrete variant in these
files is `int.IntInf.t = Finite int | Infinite`; the other explicit type heads
are abstract. This source inspection includes the clone-substitution type
heads that the lexical inventory deliberately lists as candidates.

Conversely, foreign types obtained while elaborating a routine body do not
become the type-definition graph of a new `PDtype`. They stay in that routine's
body/signature and can induce an error or an automatic builtin use. The automatic
`add_use` cases are exactly WellFounded, HighOrd, Ref and tuple modules
(`pmodule.ml:534–546`). They do not restore an arbitrary module from a symbol.
The predefined modules have fixed heads; tuple-module reconstruction derives
its type/constructor from `n`, covered by the accepted 25-byte tuple bound.

The selected files have no interfaces, so neither `mod_impl_register` nor the
shared implementation-clone state is entered. `Pmodule.restore_module` and
`restore_module_id` are not used by this parser/clone path. The former is used
by the excluded counterexample/RAC reporting path; the latter by an unselected
reflection transform. Their tables may contain foreign modules without
affecting this argument.

Induction follows the named module DAG and the local declaration/clone order.
Within a module, generated pure declarations retain the original routine/type
stem and bounded suffix; repeated cloning does not append a new suffix to the
previous generated proposition. The [reviewed Round 31 suffix and namespace
argument](retained-why-path-payload-bound.md#fixed-library-source-origin-lemma)
then applies to these relevant origins. Namespace `Uscope` labels follow the
same acyclic source ancestry; expression-body aliases cannot add a scope unit.
Thus `J(p) <= (S+64)+S+S <= 116162`. The old blanket statement that every
body-symbol cache hit is source-local is neither imported nor needed.

## Selected writer closure

The accepted driver envelope supplies 20 distinct outer transform names and
three printer names. `Trans.lookup_transform` and `Printer.lookup_printer`
use immutable string names in the fixed registrations. Environment-transform
memoization has the same two-owner argument above. Private task/type/tag memo
aliases can select another result from the same callback family; they do not
install a new function into a registry. Registry extension by arbitrary plugins
is excluded by the retained two-plugin/loading relation, not by lexical absence.

| Selected root/helper family | Theory path effect |
| --- | --- |
| `Driver.update_task` | Task insertion/export and Theory meta cloning only; the accepted task/export distinction applies. Driver loading, including its theory export construction, is before every cut. |
| `inline_trivial`, unused removal, builtin/definition/recursion elimination, inductive/epsilon/guard-epsilon elimination, formula simplification, premise introduction/splitting, polymorphism detection | Rebuild terms, declarations, metas and Tasks through the selected `Trans` combinators. Their callbacks do not take a theory-under-construction owner and do not parse a library. |
| `counterexamples_dependent_intros` | Chooses removal or dequantification. Both are covered Task-only bodies; the effect result does not depend on selecting the default branch. |
| `monomorphise_goal`, encoding and all encoding flag choices | Accepted Round 31 no-path-writer family; generated symbol names remain Task declarations. |
| `discriminate_if_poly` | Includes compile-match, monomorphisation, selection/completion and declaration reconstruction. Its four extra flag tables each register none/goal/local/all in `Encoding_select`; all 16 callbacks return sets/maps over task symbols/types, and their wrappers add metas/Tasks. No parser or Theory writer is hidden in this dispatch. |
| Algebraic elimination, compile-match and projection helpers | Task constructors, with the one path-writing exception `Theory.tuple_theory` in `fold_decl`. Tuple payloads are bounded by 25 bytes. Both branches of the polymorphism selector are included. |
| `eliminate_literal` environment initialization | The two literal library roots are exactly `["int"].Int` and `["real"].Real`. Misses/reparses use the named-DAG/declaration-origin argument above. |
| SMT V20, V26 and V26Par printers | Print existing declarations, terms, identifiers, numeric literals and syntax templates; fill private printing/model-information maps. Their environment is stored in the result metadata, not used to parse a library while printing. Pretty/debug printing likewise does not register Theory paths. |

The packet retains the complete new transform/printer/helper bodies and all
references to the four discrimination flag tables. This is an effect analysis
of callbacks and insertion owners. A list of driver directives or an absent
`create_theory` token by itself would not establish it. `Task.add_decl`,
`Task.add_tdecl`, `Task.use_export` and `Task.clone_export` retain their accepted
no-Theory-path effect even when tasks contain symbols generated elsewhere.

Result processing requires a separate check: `Smtv2_model_parser` can read
`real`, `ieee_float`, and theory names chosen by its known model conversions.
Those are **not** silently included in the four-file lemma. They are excluded
on this invocation by the following meta-preservation argument.

The exact 14 resolved driver files, 11 prefix library files and five native
JSON inputs contain no `get_counterexmp` directive/name outside driver comments.
The three raw driver mentions are explanatory comments, handled by the retained
driver comment rules. The JSON converter and selected parser do not synthesize
that meta; its only source definition is the constant in `Driver`. The complete
registration census has 74 references (including definitions/interfaces), all
actual fixed registrations being module-initialization bindings. No selected
late client registers a meta. Thus the distinct constant meta objects have
nonwrapping tags, independently of `Ident` and task counters.

Task meta maps are persistent `Mmeta` maps keyed by those stable meta tags.
The selected constructors either preserve an existing meta object or create
one of the displayed encoding/algebraic/introduction/definition metas, never
`Driver.meta_get_counterexmp`. Task hash-consing compares the actual tdecl and
previous task; it cannot invent a new meta binding solely from a task hash
collision. Transformation memo aliases only return Tasks from this same
CE-free family. Induction over initial construction and later reconstruction
therefore preserves the empty `get_counterexmp` entry. This is stronger than
equating the command-line CE option with every prepared task's meta map.

`Driver.prove_task_prepared` consequently passes `get_model=None`.
`Call_provers.record_model` does not call `prp_model_parser` in that branch,
even if prover output contains model-looking text (`driver.ml:456–474`,
`call_provers.ml:328–336`). Ordinary answer parsing updates attempt state and
calls the existing scheduler callbacks. It can schedule another of the same
selected attempts, but cannot introduce a new driver/parser root. The immutable
counterexamples-off configuration excludes CE goals and the reporting/RAC branch.

Errors also do not turn names into parser entry points. The retained exception
registration census and containing source suffixes cover core/MLW/parser,
driver/session/utilities, and the two loaded plugins. Handlers print scalar,
type/term/pattern/declaration/program-symbol or S-expression data, delegate
wrapped exceptions, or rethrow. `Exn_printer` suppresses a failing handler and
tries the next; it does not invoke a transform by an exception's string.
Program-symbol pretty printers inspect symbols/type data and may open/copy
terms, but perform no declaration insertion. Warning/debug hooks use their
accepted formatter owners. JSON warnings and GNAT's uncaught handler print
and exit. No error handler here loads a driver, parses a library, or promotes
an expression symbol to a module declaration.

Session saving uses `Theory.restore_path` and existing fallbacks, not a writer.
Ordinary ending traverses results and saves; it does not reload the input.
SIGINT saves/exits, SIGVTALRM yields, and the retained Debug/Format/flush hooks
only report or flush. No selected pending or exit callback enters preparation
or the parser. The native selector/loading and capability-prefix results are
used only for their established configurations and root families, with the
same ordinary source/runtime interface relation. This is a new local no-path-
writer application to these displayed clients, not a claim that the earlier
original-PID first-fold capacity theorem already covered the full interval.

## Result and remaining composition

The selected later writers are therefore exhausted by tuple construction and
the four-file parser/clone family (plus empty `store_theory` paths). On normal
numeric/allocation services their nonempty payloads satisfy **R=116,162**.
No bound on the total number of parses, identifier registrations, task sizes,
or complete helper work was required for this value invariant.

The statement is about all values that these writers can install, including
under tag aliases, loss-to-fallback and repeated cache misses. It does not
bound failed conversion/allocation work or assert successful parsing/printing.
It inherits the explicit normal-decimal-service limitation fixed in Round 31.

To obtain an actual whole-process bound, combine this result with the separate
initial-current-table/old-array argument, and then the separate attempted
list/concat construction proof. The existing conditional U and Format
arithmetic need no numeric change. This packet does not close remaining
failed-service, formatter, stack/GC, aggregate allocation, channel/path/error
or full-pipeline obligations. Oracle, admission, tool pins and production code
are unchanged. Aggregate review, issue/memory updates and publication remain
lead-owned. See the [evidence packet](../evidence/retained-why-path-library-origins-20261020/README.md).
