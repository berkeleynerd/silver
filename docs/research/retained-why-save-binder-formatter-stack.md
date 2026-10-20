# Retained save binder and formatter stack closure

2026-10-20 UTC, #119 / #153 Round 38; five retained Linux x86_64 cases.
Author base `795b52bebd`, selected GPT-6 Astra / Extra High; runtime setting
and token/cost telemetry are unavailable.

The recursive goal-explanation and public binder-opening roots now have a
complete selected call closure to named runtime services. The selected private
formatter, decoded-name and constant-printer roots have a complete closure to
named serializer callbacks, `Shape.check`, and services. This removes two
specific families from the former unclassified tool-owned stack term. It does
not yet give the complete process or save stack requirement.

The [packet](../evidence/retained-why-save-binder-formatter-stack-20261020/README.md)
checks 210 retained native bodies and 51,430 instruction bytes against the
retained executable. Of these, 97 bodies form the binder/explanation closure
and 121 form the formatter closure; shared bodies are counted by invocation
context. Two module-entry bodies establish public/static closure identities.
The source-selected callback and branch argument remains an auditable semantic
argument under the existing source/native behavior relation. A symbol graph,
ELF byte comparison, or a passing Python script alone does not prove it.

No gnatwhy3 execution, capture, disassembler, solver, predecessor-checker replay
or new term interpretation was performed. The author preserved all Round 36/37
bytes and read their successful results as inputs.

## Binder and enclosing explanation interface

The roots are `Termcode.goal_expl_task_1184`, and the public `Term.t_open_bound`
and `Term.t_open_quant` closures. The latter are **tuplify adapters**:

| Static closure | Public entry | Raw implementation |
| --- | --- | --- |
| `0xb49040`, module slot `0x1f0` | `caml_tuplify3` | `t_open_bound_5946` |
| `0xb490a0`, module slot `0x200` | `caml_tuplify4` | `t_open_quant_5970` |

Both adapters have 16-byte own high-water bounds including the return slot.
Their entry bytes, three closure words, and module stores are checked. The
selected `t_fold` let/quantifier branches call these entries, so merely counting
the raw opening implementations would omit real native execution.

The closure includes the enclosing explanation search and `t_fold`, fresh
variable/identifier construction, scalar type identity, structural substitution,
trigger/list operations, administrative maps, map comparators, and selected
application/curry adapters. Its imports are Round 37's `collect_expls` and
`concat_expls`; its only service frontier is `caml_call_gc` and `caml_raise_exn`.
The imported collect/concat component is charged once as `X(A)=32A+768`.

The governing dynamic premises are the frozen Round 36 transfer: term depth
`D`, list length `L`, and opening-environment key bound `N=S0+F0*D+L`;
all deferred substitution images remain variables; opening preserves the
constructor/list skeleton; no patterns/Tcase and no raw-task writeback occur.
Use Round 37's `A`, which includes term **and proposition-identifier** attributes.
Set `K=N+A+L+1` for a loose common bound on maps actually traversed here.

Fresh `id_clone` uses the empty default additional-attribute set. Its union
returns the original identifier attributes without descending that map. Variable
identifier attributes need not belong to the term/proposition union, and this
argument does not incorrectly bound their full size by A. `create_vsymbol`
shares `vs_ty`, `mk_term` shares the type field, and the selected `oty_equal`
callback is physical `Ty.ty_equal`. There is no recursive type traversal.

The selected exclusions are consequential:

- `search_attrs` calls `t_fold` only for let/forall in these no-Tcase terms.
  It does not call the generic `t_fold_unsafe` default or branch-opening helper.
- Structural substitution handles let/eps/quant itself. Its call to
  `t_map_unsafe` cannot select the latter's binder/branch mapper callbacks.
- `add_nt_vars` passes only variable images to `t_vars`; the singleton arm is
  the only selected arm. No arbitrary recursively expanded image is admitted.
- A selected constant remains the same term. `t_attr_copy` exits at physical
  equality before the constant-comparison arm of `t_similar`.

`call-closures.json` records every retained direct edge and created closure,
source-excluded targets, local constructor switches separately from true
indirect calls, and the finite selected callback environment. Generic
application entries are not permission to invoke every closure of an arity.
The fold2-intersection callback closure at `0xb48be8` has native arity four
and raw target `add_nt_vars_5653`; `caml_apply4` selects its exact-arity entry.
Its stored curry4 entry is not executed by this fully applied call.

### Simultaneous-instance argument

Every ordinary frame uses its own checked reservation, return slot and any
body-wide trap allowance. The result does not multiply an assumed maximum
frame size by a symbol count. The deliberately loose per-body multiplicities
are in `multiplicities.json`:

| Native body family | Simultaneous multiplicity upper bound |
| --- | ---: |
| Each Extmap body | `3*(2K+1)` |
| `List.map` | `(D+3)*(L+1)` |
| `List.fold_left` | `2*(D+2)` |
| Each apply/curry/tuplify adapter | `8*(D+2)*(L+1)+32` |
| Each other binder/explanation body | `D+2` |

These follow source contexts, rather than total work or heap allocations.
Search/fold ancestry follows strict structural descendants, bounded by D.
Opening completes before search descends into the opened result. A current
opening may have a structural-substitution ancestry of at most D plus one
terminal variable image. Individual ordinary bodies therefore have at most
D+2 instances, including terminal/error prefixes.

A structural level can retain at most one ordinary argument-list map; opening
adds at most two trigger-list maps. Each retained list prefix has at most L+1
entries. Trigger folds add at most two native fold-left contexts per structural
ancestor. Their iteration steps are native tail loops, not one new frame per
visited item. The physical-child list comparison, reverse and map-fold loops
also finish each scalar callback before the next iteration.

Map operations are sequential within an administrative phase except for
explicit higher-order nesting. The two nontrivial nests are: deferred-image
map → variable substitution → attribute union; and fold2-intersection →
add-variable-image → scalar map or variable union. A variable image cannot
reenter a binder or structural subtree. Three simultaneously nested map contexts
therefore cover both nests and their terminal helpers. Within one map context,
recursive calls descend strict subtrees; split/join/balance work can inspect at
most the two input key domains, bounded by 2K. Each named recursive helper has
at most 2K+1 instances in that context. Scalar comparators/callbacks return
before the enclosing map descends again; they do not acquire one suspended
adapter chain per map node.

For adapters, use two structural ancestries (search and substitution), at most
four application/curry/tuple entry instances per source higher-order step,
and the overcounted list-prefix allowance. This gives `8*(D+2)*(L+1)`.
The extra 32 covers four entries at each of the three map contexts and the
remaining root/scalar application layers. The finite arity-two/three/four
callback table and selected native adapters are retained for this check.
Tail transfers only lower simultaneous occupancy; counting their return slots
again is conservative. No callback/save budget is restarted in this induction.

The resulting complete goal-explanation-or-opening component G includes X:

| Case | D | N | L | A | G bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| put_line | 197 | 2773 | 7 | 195 | 22,250,024 |
| put | 197 | 2379 | 7 | 171 | 19,540,616 |
| first_or_default | 89 | 631 | 7 | 193 | 6,756,712 |
| is_message | 37 | 266 | 7 | 42 | 2,637,768 |
| input_is_valid | 39 | 281 | 7 | 44 | 2,777,624 |

G is charged once per active save: the explanation root can contain an opening;
the separate Shape phase calls an opening, finishes it, then descends. It does
not keep a completed opening active at every Shape level. Shape/serializer
caller frames remain the separate caller component. Round 37's T task-selection
interface remains separate from G.

## Private formatter, decoded-name and constant interface

The selected interface covers `fprintf/kfprintf`, `asprintf/kasprintf`, their
returned argument/continuation closures, `make_printf`, `output_acc`, the fixed
box parser, selected Format core operations, fresh channel/Buffer formatter
factories, default output callbacks, scalar conversion wrappers and Buffer
helpers. It also includes `Ident.sn_decode/print_sn` and their scans, plus
SV6 integer `Termcode.const_shape/const_v2` through `Z`'s formatting wrapper.
`Shape.check` is an explicit import owned with the Shape traversal.

The channel callback `fun_2430` reaches the checked OCaml `output_substring`
wrapper and then `caml_ml_output`; `fun_2433` reaches `caml_ml_flush`. Buffer
callback `fun_2444` reaches `Buffer.add_substring`; its flush callback
`fun_2447` is empty. Defaults `fun_2407/2415/2421` implement newline/spaces/indent
using those concrete output callbacks. `asprintf`'s continuation is the checked
static identity closure `0xf8aa60`, installed at Format module slot `0x4d0`.
The integer and Boolean converter callbacks are explicitly included; merely
following direct calls from `make_printf` would miss them.

`formatter-spec.json` defines the source-selected branch/callback environment.
`formatter-call-closures.json` retains the resulting complete graph and every
excluded branch/site. Its callback imports are the exact selected native
serializer/Pp partial wrappers supplied by the serializer author, including
prover options, attributes, nested goal/theory/file printers, transformation
argument lists, shape integer-list output and shape-version output. Shared
List/adapter bodies are owned by call instance: the serializer owns its Pp/XML
wrappers and caller-side applications; this packet owns only their Format
and internal name/constant descendants.

The existing format census establishes only fixed `%s`, `%b`, `%i/%d`, `%g`,
`%a`, literals, breaks/newlines/flush and four box annotations. It rules out
custom/dynamic/reader formats, explicit widths/precision, Magic_size and tags.
No tabs, tags, if-newline tokens or formatter-setting changes enter the private
instances. The only `List.iter` instance inside this closure is the empty
`clear_tag_stack` iteration, so its callback cannot run. Fixed annotations
`h`, `v 0`, `v 1`, `hov 1` make the parser's invalid-box continuations unreachable.
An allocation/service failure abandons that computation; it does not turn the
fixed annotation into a malformed input.

All transported constants are integers and the selected shape version is SV6,
so const_v1, real and string-constant branches are excluded. `sn_decode`'s data
scans are native loops; its `%a%s` and print_sn's fixed string/punctuation
formats add at most two simultaneous formatted invocations. Data strings are
never interpreted as formats.

### Formatter simultaneous-instance bound

The selected `make_printf` construction transitions are tail transfers, including
box-annotation construction and resumed argument closures. Format queue draining,
box closing, scans and Buffer growth are also native loops. The checker verifies
that `output_acc` is the only selected body with a direct self-call; the source
context argument additionally excludes a mutually recursive unbounded callback
cycle. Core output callbacks reach Buffer/channel output, not another formatter.

Use at most two main formatted calls (XML outer/inner, or sn_decode/print_sn),
each with the retained 32-node allowance plus terminator, and one two-entry
annotation evaluation: **O=68 output_acc instances**. XML callback reentry
finishes before the next serializer traversal level. Internal const/name
formatters run in the separate Shape/printer phase; counting all families
against the same allowances overcounts them safely.

Every other ordinary owned body gets **H=4 instances**, covering the two main
calls, annotation work and a terminal/helper allowance. Each generic apply/curry
body gets **J=64 instances**: at most four formatter levels with sixteen
application/partial-application layers per level, above the selected arity≤4
chains in this component. Larger-arity serializer call sites remain counted
in the serializer component. Repeated format nodes and emitted bytes do not
add such layers: construction is tail, and output core callbacks return before
the next token. Runtime-mediated nested saves use the global save count below.

The sum of exact ordinary own frames is 2,392 bytes, adapter own frames 176,
and output_acc owns 32. Thus the closed owned surcharge is

```text
F = 2392*H + 176*J + 32*O
  = 2392*4 + 176*64 + 32*68
  = 23,008 bytes per active save.
```

F covers all simultaneous selected Format/internal-name/constant instances,
not merely one invocation of each root. Charge it once per active save, not
once per emitted format or printer call. Its explicit imported callbacks still
need their caller component; C/GC/service stack remains R.

The parameterized expression can be reused only under the same selected
callback/token/format environment with justified H/J/O. Queue length and box
depth alone do not grow these native loops. This packet makes no claim that
preexisting global standard/error formatters satisfy the private-instance
premises; exit diagnostics may need other format constructors or callbacks.

## Composition boundary and residual

Let C be the separately closed serializer/identifier/Shape caller component,
and T the Round 37 task-selection component. The intended tool-owned join is
`C+T+G+F` per save, with component ownership checked at callback interfaces.
The old Round 36 binder/structural/output_acc projections are replaced, not
silently added as evidence of closure. This packet does not compute C or claim
the whole join is complete before that separate packet is reviewed.

Across the accepted interval, `r≤3` saves and `e≤2` callback opportunities remain
global budgets. Round 37's 816-byte Qs is only the dispatch-to-save shell, whose
handler contribution is 32 bytes while saving. The handler's signal-setter
phase is a separate imported phase alternative; its caller/trap frames are
not simultaneously live during save and are not silently covered by Qs.
Root-owned setter, exit, global-formatter, channel and other callback phases
must be composed using their actual interfaces. Direct OCaml/C or GC bridge
high-water is separately charged under the Round 37 4,104-byte interface;
service-owned nested crossings stay in R. Ambient suspended preparation is
A_pre, not another save-owned component.

The precise remaining tool-owned imports are therefore the serializer/caller
packet and root-owned non-save phase packets. No newly unknown binder,
private-formatter, const_shape or sn_decode descendant is hidden in a generic
U here. The complete bound remains null until those joins and their global
control premises are discharged. None of these abstract native-byte upper
bounds proves that the physical host stack is sufficient or that exhausted
native services recover gracefully.
