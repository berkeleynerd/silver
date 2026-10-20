# Fixed-task syntax origins and the remaining identity join

2026-10-20 UTC, #119 / #153, Linux x86_64. This extends the frozen
[solver-output result](retained-solver-output-relevance.md), under the same
fixed-input, relevant-source and ordinary-runtime relation. It changes no
Oracle, tool, driver, admitted source or callback allowance.

**The two malformed Float80 templates cannot enter the selected task family.**
This closes their syntax-origin obligation for all five retained process
domains, including losing attempts. Correct symbol-to-template lookup and
exclusion of removal-as-term/type additionally need the continuing identifier
inequality below. That inequality is not yet instantiated for the full
continuation; no actual attempt is newly classified ordinary and whole `q`
remains unknown. The [offline packet](../evidence/retained-cvc5-task-acceptance-20261020/README.md)
checks the exact finite inputs and dependency graph supporting this result.

## Imported theories, not the whole library file

The structured `W_MODULE` fields in the five fixed JSON inputs name ten external
roots: `_gnatprove_standard.{Array__1,Boolean,Integer,Main,BV64}`,
`ada__model.{Constr_Array,Rep_Proj_Int,Static_Discrete,Unconstr_Array}`, and
`int.Int`. Roots vary by case; the packet preserves each case's occurrences.
There is no Float-constant or floating-type-definition input node. This is
typed-field extraction, not an inference from an absent substring.

`Gnat_ast_to_ptree.mk_module_qident` copies the explicit file/name components;
include and clone conversion uses that function. Type names likewise retain
their supplied qualifier (`gnat_ast_to_ptree.ml:95–117,160–174,1240–1280`). The
converter's special Float32/64/80 construction requires a Float_constant node
(`:681–701`), absent here. Generic meta conversion and the synthesized axiom
dependency meta do not manufacture syntax templates (`:1226–1239,1285–1297`).

Following every `use` and `clone` in the rooted modules yields **47 modules and
66 dependency edges**: 46 definitions in the retained libraries plus builtin
`why3.WellFounded.WellFounded`. No `ieee_float` module, Float32/64/80 wrapper or
other floating module is reachable. The complete 11-file lexical check covers
252 module/theory heads and all 478 dependency heads, including quoted file
paths and local same-file references. It exports the reachable definitions and
source lines, and rejects an unmatched dependency head or unresolved external
module. The checker is deliberately a bounded lexical graph check, not a
general WhyML type checker.

The [accepted library-origin argument](retained-why-path-library-origins.md#named-module-selection-is-independent-of-identifier-tags)
supplies the semantic connection: module resolution uses path/string keys and
returns the named definition, with a fresh parser/module scope. Parsing other
modules in the same file does not import them into the selected module. Uses
and clones follow the selected definition's units. Automatic program uses are
WellFounded, HighOrd, Ref and tuple modules, with fixed builtin declarations;
`Vc.mk_env` reads only int.Int and WellFounded (`vc.ml:173–174`). BuiltIn/Bool/
HighOrd/Ignore/Unit and tuple construction do not reference Float80
(`pmodule.ml:384–410,463–494`; `theory.ml:1020–1075`). A real builtin type is
not the `ieee_float.Float80` theory. Later literal-helper reads of int.Int and
real.Real are already covered by that accepted helper argument and introduce
no syntax meta. These builtin/helper cases are separate from the 47-node
explicit-source graph.

## Why driver loading does not introduce the bad strings

Driver loading resolves a syntax directive's symbol in its named theory's
namespace, retaining the actual type/logic/proposition object with the meta
(`driver.ml:155–205`). All selected driver objects and imported theories are
initialized before the five cuts. The
[initial-registration proof](retained-why-initial-registration-bound.md)
establishes exact identifier counts and pre-cut tag injectivity, not merely
positive observed counters:

| Case | PID | Initial registrations I |
| --- | ---: | ---: |
| Put_Line | 17310 | 136,844 |
| Put | 17514 | 121,505 |
| First_Or_Default | 17631 | 77,806 |
| Is_Message | 17704 | 59,035 |
| Input_Is_Valid | 17869 | 60,496 |

Its controlled no-collection/no-abandonment prefix gives `5*I <= B < 2^28`,
excluding a first identifier-counter wrap. Therefore the old theory-name keys
in driver maps and raw-task clone histories cannot alias each other. This is
a property of those immutable old keys; later identifier creation cannot
retroactively change them.

The [accepted dispatch result](retained-producer-driver-envelope.md#the-task-domain-is-fixed-before-solver-execution)
fixes the raw session tasks before scheduling: Per_Check's initial split is
already final, so exhausted provers do not produce another split or CE task.
`Session_itp.get_task` reads `session_raw_tasks`; the controller passes that
task to `Driver.prove_task`. Preparation binds its result locally and never
replaces the raw session entry (`session_itp.ml:310–311,687`;
`controller_itp.ml:420–431`; `driver.ml:490–494`). In particular, another
driver's prepared temporary task is not the next call's raw input.

`Driver.update_task` attaches a theory's metadata only for entries returned by
`Task.find_clone_tds task0 th` (`driver.ml:330–369`). That lookup uses the raw
task's immutable use/clone history. The first loop can add driver-requested
theories, but **all fourteen selected driver files have zero `use` directives**;
their `drv_thuse` maps are empty. The metadata loop itself adds Meta declarations,
not new Use/Clone entries. Thus Float80's empty raw-history lookup prevents its
two malformed syntax metas from being inserted. `prepare_task` performs this
update before applying the selected transformations (`:372–389`). The first
Input_Is_Valid update, already completed at its distinct cut, follows the same
argument.

This argument also accounts for cached values. Driver metadata lives in
`Theory.Stdecl`; it does not populate the separate `Task.Stdecl` Hcpt instance
merely by being loaded. The complete retained source has only the definition
and interface of the `Task.mk_tds` conversion API, with no caller to seed this
pool from the driver set. Raw task construction/splitting uses the selected
source-module histories above, with no driver syntax metas. Update caches
contain outputs of these raw inputs; subsequent selected task/meta caches
contain values constructed from that family. `Hstdecl` compares actual meta
objects/arguments and the `MAstr` bytes, and `Hstask` compares its actual tdecl
and predecessor (`theory.ml:214–240`; `task.ml:88–106`). A tag-only memo alias
can return another member of this family, or lose data; it cannot obtain a
Float80 syntax string from the separate driver-map domain. No fresh-task-tag
theorem is inferred from this weaker value-origin invariant.

The [accepted selected helper closure](retained-solver-task-language.md#scope-and-imported-construction-result)
covers all selected outer transforms and their flag-dispatched helpers.
`Theory.clone_meta`/`cl_marg` preserve MAstr and remap symbol arguments within
their kinds; encoding meta reconstruction preserves MAstr; discrimination
copies an existing syntax-map value (`theory.ml:861–878,999–1015`;
`encoding_sort.ml:225–247`; `discriminate.ml:489–504`). None manufactures another
syntax template. Together with the base and update cases, induction excludes
the two Float80 strings throughout the selected family, even without a full
future identifier/task-tag bound. This excludes those strings; it does not
prove that every possible cached task denotes the intended obligation.

There is a useful preparation refinement. With `drv_thuse` empty, update adds
only metadata: on the correct-cache route, the sequence of logical term roots
is unchanged from the raw task. Its **direct metadata loop registers zero
identifiers**. `clone_meta` looks up the existing type/logic/proposition symbols;
its `sm_trans_ty` rebuilds type applications/substitutions without creating a
named type or variable (`theory.ml:651–660,999–1015`;
`ty.ml:120–128,159–170,203–217,234–236`). Meta/task hashcons and map insertion
do not call symbol constructors. This is not a zero charge for all of update:
the final goal reattachment at `driver.ml:368` invokes `Task.new_decl`, then
`Decl.known_add_decl` and `check_match`, whose traversal opens binders and checks
patterns (`decl.ml:743–752,830–835`). That validator's registration charge, and
separately classified pending callbacks, remain required.

## Removal entries require a different counter argument

`Ident.Mid` compares numeric `id_tag` values through `MakeMSHW` and
`OrderedHashed`, despite the separately exposed physical `id_equal`
(`ident.ml:165–183`; `wstdlib.ml:61–67,93–100`). The unified syntax map inserts
type and logic templates by their identifiers, then inserts `("",0)` for
`MApr` removal entries (`printer.ml:518–541`). The checked driver syntax
strings themselves are nonempty.

The private immutable type/logic/proposition representations have distinct
identifier-registration constructors: `Ty.mk_ts`, `Term.create_lsymbol`, and
`Decl.create_prsymbol` (`ty.ml:84–88`; `term.ml:73–79`; `decl.ml:303`, with their
private interfaces). Cloning preserves those symbol kinds. If the common
registration counter never wraps, no proposition identifier equals a type or
logic identifier's map key. Hence an empty removal entry cannot be found by a
term/type query. `Discriminate.sm_add_ls` then copies only logic syntax entries,
never a removal entry. This property survives a task memo selecting another
task from the typed family; it needs identifier freshness, not exact task
identity.

Here is the quantitative obligation, in mathematical integers. For each process
cut `p` and every prefix ending at a selected syntax query, let `R_p` bound **all**
post-cut calls to `Ident.id_register`, including discarded objects, preparation
of other task/driver pairs, printer work, library construction and any continuing
save/report callbacks. A sufficient check is

```text
0 <= R_p <= (2^62 - 1) - I_p.
```

The packet calculates each right-hand side. This is a composition interface,
not a supplied bound for `R_p`. A source charging partition can separate normal
preparation, printing/reporting, and save-entering callbacks; nested helper work
belongs to its caller's charge exactly once. There remains one global allowance
of two save-entering callbacks, three saves and `e <= 2`; it is not renewed per
task, transform or exception. A save that exits before any later query need not
be included in that query's prefix, while a save failure caught by continuing
code must be included.

The [accepted preparation transfer](retained-why-preparation-bound.md#recursive-entries-and-meaningful-fresh-identifiers)
already supplies each inline term-kernel summand
`b(t) + H*(2*B + F)`. It must be summed over all reached roots/calls, with the
separate definition-opening and validator charges; a clone is charged for each
actual symbol constructor, while `id_clone` alone registers nothing. The
earlier retained first Input_Is_Valid/CVC5 fold has the stronger existing accounted
charge `235 + 6*123 + 4 + 168 = 1,145`, giving `60,496 + 1,145 = 61,641` at
its original attached graph/table scope. Equal initial counter values alone
do not transfer that full prepared-input/cache argument to a fresh process.
The later [native-effect closure](retained-why-native-effect-completeness.md)
does not turn all OCaml/helper registration counts into zero. The local 1,145
must not be multiplied across different unmeasured prepared forests.

Exact semantic symbol-to-template correspondence additionally needs the
independent task/declaration/type/Hcpt memo-key and caller-capacity joins.
For example, `Trans.store`/`fold` use `task_tag`, and `Task.Stdecl` uses `td_tag`;
neither counter is `Ident` (`trans.ml:46–53,75–99`; `task.ml:19–29`). Identifier
freshness alone cannot make those lookups select the right prepared task.
Their source-specific increment bounds and starting states require their own
no-wrap inequalities, even though the weaker string-origin proof tolerates
selection within the family.

## Next instantiation and solver-output consequence

The narrow next missing preparation charge starts with **goal revalidation on
update**, then the opened-root/hidden-substitution dimensions before the inline
kernel for each fixed raw task/driver. The update refinement above removes
logical-context expansion at that stage. CVC5 additionally performs unused-CE
removal; Z3 enters inline directly after update; Alt-Ergo additionally runs
`monomorphise_goal`.
The exact transfer is `Inlining.t_replace_all` via `Inlining.fold` and
`Decl.decl_map`, with `open_ls_defn`/declaration validators charged separately.
The [five-cut capture packet](../evidence/retained-why-save-state-capture-20261020/README.md)
provides `capture-<case>.tar.gz`, with `capture/session-task-chains.json` and
`capture/session-blocks.jsonl` below each registration/inline case prefix.
Its common archive supplies both driver-resolution maps and exact plans.
Use these raw logical forests with the retained source/driver metadata rules;
the observer did not decode every Meta/Use/Clone payload into a complete
semantic map. A no-cache source constructor calculation can derive the missing
entry dimensions and charges without another native capture. The same-process
Input_Is_Valid first-CVC5 graph (`inline-entry-graph.json`) supplies a concrete
prepared starting graph to compare with the earlier 244-root/1,145 theorem,
including its representative-selection/cache premises. The fresh session-forest
comparison alone is not that complete prepared-input join. Its remaining later
transforms and the other two drivers still need their own charges. This next
step should extend those exact forests and transfers, rather than repeat a
whole-helper inventory.

Once these identity, size/index/counter and supported-syntax/API conditions are
joined, the existing trusted faithful-translation and solver-input semantics
can justify the ordinary CVC5 route. They do not require proving arbitrary
solver algorithms. Ordinary external-tool correctness excludes defects and
ambient fatal executions at its established scope; a size-induced overflow or
invalid caller request cannot be assumed away as a tool defect. The existing
assumption that **some pinned prover completes** does not classify every CVC5
attempt ordinary.

The frozen output result's ordinary response pair then has raw output at most
84 bytes and formatted answer at most 64. There is also a useful conditional
prefix case: if a running attempt's trace before server SIGKILL contains only
that ordinary output language, the signal adds no child bytes, so its retained
raw-file prefix also has at most 84 bytes. Silent ongoing search need not
terminate: this is a bound from the output trace, not eventual completion.
It remains an exceptional parser/JSON
case: use the generic `4*q` answer and warning bounds, not the clean 64/no-warning
case. Queued cancellation retains its separate `q=0` case. Attributable failure
or interruption that emits other diagnostics still needs its own output bound.
This note has not supplied the missing caller conditions for those classifications.

Selected worker setting: GPT-6 Astra / Extra High, parent-confirmed selection;
runtime confirmation and token/cost telemetry unavailable. Only focused offline
checks ran. No native, solver, proof, capture, predecessor replay, GitHub, memory
or harness write occurred. Parent owns independent review and integration.
