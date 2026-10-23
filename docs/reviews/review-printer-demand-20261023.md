# Selected printer six-owner review, 2026-10-23

**Accepted with the retained premises at
`2b348ea7468f8307c39e72e6020270caa3e07871`.** This independently reviews the
complete selected `Driver.print_task_prepared` entry-to-return-or-escaping-
exception interface for #119 / #153. It does not establish complete printer
capacity or the whole #119 rule. Selected reviewer: GPT-6 Astra / Extra High;
runtime model/effort confirmation and token/cost telemetry are unavailable.
Exact frozen inputs, source witnesses, arithmetic and elapsed observations are
in the [new review packet](../evidence/retained-printer-demand-review-20261023/).

The initial target was `bc5db2f580b70c382455be5d5dd9fbf5a8839229`.
Review found a reachable registration site missing from that source census.
The author added its accounting and source witnesses before the one independent
audit. The exported numeric vector did not need correction. The initial
packet is not endorsed as a complete source-site census; the acceptance above
is tied to the amended freeze.

## Material finding and disposition

Alt-Ergo selects `smtv2.6par`. Its singleton-definition guard at
`printer/smtv2.ml:979–989` calls `Decl.get_used_syms_decl`, whose
`syms_logic_decl` opens the definition (`core/decl.ml:518–524,610–617`).
`print_logic_decl_aux` subsequently opens it again. This guard is reached
before the printer checks whether the definition has a syntax entry; it
cannot be omitted merely because a definition might later be skipped.

Let F be the outer formal slots and B the remaining body, trigger and branch
slots of a surviving singleton definition. R57's accepted context interface
includes formals in its bound of eight; R61 preserves these source slots and
uses P at least eight. Its generated definition family has the retained
ground signature bounds, and Introduction definitions are nullary. Thus
`F+B ≤ P` applies to the selected definitions. The guard and ordinary
definition opening cost at most F each. Body printing and the optional
`has_quantification` scan cost at most B each, giving
`2F+2B ≤ 2P ≤ 2P+A`. `syms_term` uses stored `t_s_fold`, so the guard's
body-symbol scan does not supply a third binder-opening pass.

The amendment records this argument explicitly. The new audit independently
checks every retained R57 context row's body-plus-formal total against eight,
the R61 dimensions, and the unchanged arithmetic. It does not execute those
transformations or replace the accepted source-preservation argument with
finite observations. No unresolved numerical defect remains from this finding.

## Complete cut and constructor paths

`driver.ml:391–404` looks up an already loaded printer, constructs the
argument record, prints and returns the printing information. Its optional
default constructs only empty information maps. It does not invoke preparation
or load a library. The selected `prove_task_prepared` buffer path calls this
printer once (`:456–474`); `prove_task` prepares once before that path
(`:490–494`). The accepted preparation/callback envelope therefore supplies
at most the same E printer calls. This is a statement about the selected
clients and formatter, not arbitrary external calls to this public API.

`Smtv2.print_task` creates fresh private state, reads syntax/meta histories,
prints preludes, and walks the chain once (`smtv2.ml:1003–1075`). Prelude
history folds use existing tasks and a local Hid table. `Discriminate`'s
syntax helper copies existing strings between keys; it does not invoke its
type-instantiation transformations. `Task.on_meta` and `on_tagged_ls` fold
existing Hcpt sets without inserting (`task.ml:283–347`, `hcpt.ml:291–309`).

The actual Ident-producing routes are fresh variables from `t_open_*`, the
definition openings including the guard above, and dummy data projections.
The general case-subject and wildcard constructors are excluded by the
accepted two-nullary-Boolean-pattern family. The Boolean branch opens each
pattern and prints each body once. Data groups are singleton types with at
most two constructors; field arity is bounded by A. Only a missing projection
calls `create_vsymbol`; the field allowance `2(A+1)` is conservative
(`smtv2.ml:855–923`). R61's singleton logic groups avoid an uncounted multiplier
from the generic mutually recursive definition printer.

`id_fresh` and `id_clone` create pre-identifiers. `create_vsymbol` calls the
actual `id_register` once. In contrast, `id_unique`, blacklist reservation
and `forget_id` operate on private name tables (`ident.ml:187–215,262–298`).
Counting name lookups as global Ident registrations would be incorrect.

The independent [syntax review](review-printer-syntax-20261023.md), frozen
at `114d0194b2907cf088347afc4bef5cf479358f8c`, is reused only for its
bounded origin, recursion and opening results. Its non-affine templates are
confined to the two BV64 rotation heads with variable-only arguments. This
supports at most `2S` ordinary term/formula entries and no extra openings
from repeated arguments. It does not authorize general template affinity.
The complete opening argument here adds the definition guard missing from
that companion's narrower discussion.

Incremental lists are initially empty and retain bodies instead of printing
them immediately. The unique terminal goal prints each deferred list entry
once (`smtv2.ml:681–699,805–831`). Its second check-sat command does not replay
any body. `Task` constructors preserve the one-final-goal invariant; a missing
goal fails before the declaration walk. Unsupported-type/declaration catches
wrap and propagate the exception. The data record-field catch only handles
its local optional map update. None retries a binder or field constructor.
Hence a failed printing prefix is bounded by the same prospective charge.

## Five zero owners

Normal type printing recurses over existing type fields. Opening performs
`fresh_vsymbol` followed by unsafe term substitution, reusing types and heads
(`term.ml:739–831`). `pat_rename_all` calls the earlier lexical `pat_map`,
which reconstructs applications using the unchecked earlier `pat_app`
(`:132–188`). Its type-equality check raises with existing type operands;
it does not call `ty_inst` (`ty.ml:314–315`). The later checked `pat_app`
would have different effects, but is not selected by this lexical route.

The generic lazy `get_type_arguments` can reach `ty_match`'s exceptional
`ty_inst`. The accepted syntax-origin result excludes active `%v` templates
through raw metadata, driver strings, selected writers and whole old returns.
The sole forcing branch at `printer.ml:337–338` is therefore unavailable.
This establishes zero Hsty requests at this cut without relying on persistent
physical hashcons identity after an interruption.

The wrapper, selected printer, model helpers and opening/substitution closure
contain no reached declaration, tdecl, task or Hcpt constructor. Counterexample
collection and label updates may allocate attributes and private map nodes;
those are not any of the six shared owners. The accepted debug control
excludes the separate `Pretty.print_term` branch. Later rendering of an
escaped exception is outside the reviewed cut, and is not assigned zero.

## Accepted interface and evidence scope

For each process the exported Ident increment bound is
`E × H × (2P+3A+2)`, with the same process-wide `E=3N+e`, `e≤2`, two
save-entering callbacks and at most three saves. H counts all task nodes,
including nodes that do not print a logical declaration. Hsty, Hsdecl,
Hstdecl, Hstask and Hcpt requests and increments are zero for this cut.

| Process | Already episode-weighted Ident increments |
| --- | ---: |
| Put_Line | 2,287,249,358,625 |
| Put | 1,533,868,345,984 |
| First_Or_Default | 327,757,646,588 |
| Is_Message | 3,307,499,520 |
| Input_Is_Valid | 3,295,500,250 |

These process vectors must not be multiplied by E again. The single focused
independent audit passed in **0.809270 seconds**, checking twelve complete
Why3 source members, frozen inputs and all five vector calculations. No
author/predecessor checker, native target, solver, proof, capture or nested
agent ran. There was no failed or aborted audit before that pass.

The source reasoning remains reviewed mathematical reasoning, not a
machine-checked simulation of OCaml. Its fixed-input/source-native relation,
typed-state, guarded-mutation and first-counter-violation premises remain
required. Whole-process aggregation must close those counter premises;
small isolated increments alone do not establish no-wrap. Attribute tags,
private memo/printer tables, request bytes, formatter/Buffer operands,
later exception rendering and full current-grammar coverage remain separate
obligations. Large mathematical traversal totals are not native counters,
and this result introduces no aggregate RAM gate. No Oracle, tool, pin,
language or admission rule changes.
