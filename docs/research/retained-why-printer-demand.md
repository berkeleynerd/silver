# Six-owner demand of selected solver-request printing

2026-10-23 UTC, #119 / #153. Candidate source argument, pending independent
review. This supplies `solver_request_printers` to the accepted
[six-owner API](retained-why-shared-demand.md). Its boundary is entry to
`Driver.print_task_prepared` through return or propagation of an exception.
The input is the [accepted R61 printer-entry family](retained-why-printer-entry.md),
under the same source/native/runtime, valid typed-state, guarded-mutation and
first-counter-violation premises. Printer execution is distinct from preceding
preparation, lookup constructors and subsequent exception rendering.

No source, configuration, tool, pin, language or Oracle is changed. This is a
request-count interface for six shared owners, not a complete printer capacity
theorem. Attribute tags, local table backing, formatted bytes and other native
operands remain separately required. Ordinary physical-resource sufficiency
retains the established trust boundary; no RAM or execution-time gate is added.

## Entry and concrete clients

`driver.ml:391–404` selects the already loaded named printer and constructs
fresh `Printer.printer_args`; it neither prepares a task again nor parses a
library. `Printer.lookup_printer` is an Hstr lookup (`printer.ml:117–123`).
`default_printing_info` constructs empty maps and fields; even eager evaluation
of the optional default does not register an identifier or construct a logical
type/declaration. The selected driver/import closure uses SMTv2 variants; its
finite syntax and [source-origin companion](../reviews/review-printer-syntax-20261023.md)
is frozen at `114d0194b2907cf088347afc4bef5cf479358f8c` in the packet inputs.

`Smtv2.print_task` (`smtv2.ml:1003–1075`) builds a fresh private printer and
information record, prints the selected preludes, and walks the prepared task
chain once. Only `Theory.Decl` nodes call `print_decl`. A successful input has
one final goal: every `Task.new_decl`, `new_clone` and `new_meta` checks that its
predecessor is not already a goal (`task.ml:121–160`). The typed cached-task
family preserves this constructor invariant. A missing goal raises before the
declaration walk. The old-channel argument is ignored by this printer.

Syntax-map construction is read-only with respect to the six owners.
`Printer.get_syntax_map`/`get_rliteral_map` fold metadata into private Mid maps
(`printer.ml:518–558`). `Discriminate.get_syntax_map` only copies an existing
syntax entry from one lsymbol key to another (`discriminate.ml:487–499`); it
does not invoke `Insts.make` or reconstruct types. Prelude/history and
counterexample-meta lookups likewise read existing objects. Counterexample
information maps and label updates do not construct any of these six owners;
their possible attribute allocations retain their separate owner.

The accepted [debug flag/control result](retained-why-debug-formatter-control.md)
excludes the `Pretty.print_term` calls guarded by `smtv2_printer`. It covers the
actual argv, initial environment and later setters, not merely the current
value of a flag. False dprintf's `ifprintf` does not call `%a`/`%t` arguments.
The [counterexample-meta result](retained-why-model-meta-control.md) is reused
with its source preservation argument. The six-owner count does not infer that
all counterexample-related metadata or private map updates disappear.

## Source-visible printing and registration

Use R61's S for completely exposed formula mass, P for all source slots
(including unused binders and names moved to free positions), and H for task
chain nodes. All five have P at least eight. Saved images are binder-free,
although they may contain nonleaf terms. Opening may traverse large hidden
maps, but these scans do not create fresh bound variables inside an image.

A general driver template is not affine: some templates repeat an argument.
The accepted fixed-family syntax companion establishes the relevant
origin restriction. Its finite extraction identifies only the two BV64
rotation templates as repeated-argument templates attached to the fixed task
family. Their original arguments are quantified variables in separate
nine-node axioms, without saved substitutions, triggers or nested rotation.
They are Dparam heads, not optional inline definitions. The original-context
returned-field family and the selected later producers preserve those origins;
new literal, epsilon, algebraic and Introduction heads do not acquire either
rotation identity. Correct template lookup is conditional on the same shared
identifier no-wrap prefix used by the other capacity components. It is closed
only by eventual aggregate composition, not assumed from an observed residue.

Under that restriction each ordinary printer expression walk uses at most 2S
recursive term/formula callbacks. Repeating these variable arguments opens no
extra binder. Type-template substitution invokes `print_type`, not a term
printer. Unsupported constructs stop the invocation rather than starting an
unbounded alternative traversal.

The source sites that can register Ident values are:

| Site | Charge and source |
| --- | --- |
| `t_open_bound`, `t_open_quant`, `t_open_branch` | One fresh variable per opened slot; `term.ml:799–833` calls `fresh_vsymbol`/`create_vsymbol`. Substitution and pattern rebuilding otherwise reuse types and heads. |
| `Decl.open_ls_defn` | Opens at most the leading forall once and returns its body; `decl.ml:60–67`. It does not create another definition or declaration. |
| `has_quantification` | Uses the opening `Term.t_any`/`t_fold` (`smtv2.ml:676–679`, `term.ml:1284–1299`). Count its let/branch openings even though quantifier/epsilon nodes return true before their own recursive fold. |
| Nonvariable case subject or wildcard pattern | These generic sites (`smtv2.ml:547–585`) are excluded: the accepted family has only two-nullary-Boolean-pattern cases, and later producers introduce no new case. The Boolean path opens its patterns and prints each branch once. |
| Missing data projection | One dummy variable per constructor field without a projection (`smtv2.ml:855–903`). The accepted ground data/signature family bounds these fields; a source `id_fresh` alone is not a registration. |

The selected remaining definitions are singleton nonrecursive definitions;
new Introduction definitions are singleton and nullary. Original data groups
and generated side declarations retain the R61 source shape: a singleton data
type, with at most two constructors, and no larger constructor argument list
than the retained arity A (at most seven). The syntax companion bounds all
ordinary and `has_quantification` openings plus separate definition formals
by `2P+A` per logical declaration. Two constructor field lists each fit
`A+1`, so a conservative combined charge is `2P+3A+2` per declaration.
Charging it at all H task nodes also includes metadata and repeated wrappers
that perform no such construction. This avoids the earlier provisional
`8H(S+1)(P+1)` traversal-based overestimate: S still bounds printing work, but
fresh variable registrations come from actual opened slots and fields.

Incremental mode does not multiply this budget by the number of declarations.
A quantified axiom or definition is deferred instead of printing its body;
the single final goal then visits each deferred list entry once
(`smtv2.ml:681–699,786–831`). Definition parameter and check-sat formatting
creates no bound variables. The same bound allows incremental mode whether
or not its meta is present. The ordinary declaration walk and a failed prefix
are both bounded by the full prospective charge.

Printing a name calls `id_unique`/`forget_id` on fresh private tables
(`ident.ml:230–302`), not `id_register`. Those operations need their own
table/index/name bounds; it would be incorrect to add one global Ident
registration per name lookup. Type/free-variable folds similarly traverse
stored fields without creating fresh variables (`term.ml:1178–1209`).

## Type writers and the five zero owners

Successful `print_type` recurses through existing types. Ordinary term opening
and unsafe term substitution reuse type pointers. `pat_rename_all` uses the
earlier lexical `pat_map`, whose application reconstruction precedes the
checked `pat_app` definition (`term.ml:132–185`); its type equality checks do
not construct a type. No general `t_ty_map`, inferred application, new tuple
type or type-symbol constructor is selected by this printer.

The generic `%v` syntax branch could call `Printer.get_type_arguments`
(`printer.ml:288–296,328–340`), whose type-mismatch diagnostic can construct
`ty_inst`. But the fixed-family syntax census finds no active `%v` or `%t`
placeholder. Together with its raw-meta, driver/update and later-writer origin
argument, this excludes forcing the lazy type-argument computation throughout
this selected family. It is not an assumption of canonical type identity or
an omitted exceptional path. Normal explicit-type rendering does not call it.
Therefore Hsty requests and increments are zero at this selected printer cut.

The concrete wrapper, SMTv2, syntax helpers, model-map helpers and term-opening
paths contain no logical-declaration, tdecl, task or Hcpt constructor. Their
read-only `Task` lookups are not insertions. Thus Hsdecl, Hstdecl, Hstask and
Hcpt are zero for this cut. Library loading belongs to the earlier lookup
vector. Rendering an escaped exception belongs to the later callback/error
vector; it is not silently treated as zero here.

## Export and proof boundary

For each process, E is the accepted `3N + e`, with the single global e<=2,
two save-entering callbacks and at most three saves. Every printer invocation
follows one preparation episode, so the failed/successful printer count is at
most E. No allowance is renewed at the printer boundary. Export:

```
Ident increments <= E * H(2P+3A+2)
Hsty = Hsdecl = Hstdecl = Hstask = Hcpt = 0
```

The [packet](../evidence/retained-why-printer-demand-20261023/README.md) retains
exact input/source identities and finite arithmetic checks. Its process vectors
already include E. A caller must not multiply them by E again. A finite checker
does not prove the source simulation. Whole-process counter/backing headroom,
attribute and private memo/printer owners, output bytes, failure reporting,
full current-grammar coverage and the complete #119 rule remain required.
