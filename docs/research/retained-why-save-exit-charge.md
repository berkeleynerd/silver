# Conditional identifier charge for save, exit and first-fold reporting

2026-10-19, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119), based on `08062f36ac`.
The source-side allowance for exceptional reporting in the retained first
`inline_trivial` interval is **D = 25,920 identifier registrations**. Direct
save/exit work adds **zero non-binder registrations**, and a caught exception
that returns within this first fold adds **zero registrations beyond its
already accounted 1,145**. The separately charged save binders remain at most
966 per attempt, including an unsuccessful prefix.

These are **conditional component bounds**. They require the complete native
effect/preservation obligation, which is still **OPEN**. Write `N_native` for
its additional identifier charge over the whole interval. The useful interface
is now

```text
counter_end <= 60,496 + 1,145 + 2*966 + 25,920 + N_native
            = 89,493 + N_native.
```

This does not establish 89,493, 63,573, complete `R`, or an unconditional
counter no-wrap theorem. A whole-interval reporting allowance covers primitive
failure even with **zero SIGINT attempts**; assigning every exceptional cost
only to an actually executed save would miss that case. The older
`63,573 + 2R` interface remains an uninstantiated alternative, not this packet's
claim. Later scheduler invocations and the ordinary normal-ending save remain
outside the boundary.

The [evidence packet](../evidence/retained-why-save-exit-charge-20261019/README.md)
pins inherited evidence and exact source excerpts, supplies an effect/catch
ledger, and checks their identities and arithmetic. The control-flow argument
below is inspected source reasoning, **not machine-checked OCaml semantics**.
No native execution, capture, build, prover, disassembler, old checker replay
or new global census was performed.

## Inputs and the noncircular native interface

The retained process is PID **97103**, run
`20261019T000304-fcb988ec2c03`, with executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Why3 is `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml 4.14.2 is
`8eb41f72ded84df884c3671734c947f612091f84`. The accepted same-process
[counter/table attachment](retained-why-inline-identifier-state.md),
[representative transfer](retained-why-inline-representative-state.md),
[saved atoms and unsuccessful prefixes](retained-why-session-save-outcomes.md),
[formatter repair](retained-why-session-formatter-prefix-repair.md), and
[OCaml ownership argument](retained-why-save-preservation.md) are reused.
The [native coverage correction](retained-why-interval-native-effects.md)
supersedes the ownership note's obsolete four-hook residual: four cells, and
even its seven exhibited routes, are not an exhaustive native boundary.

The native certificate must independently establish which native dispatches
can occur, their initial configuration and preservation, effects on logical
inputs, counters, callback families and private state, and the exceptions
they can deliver. The source lemma accepts the ordinary primitive exception
family from the reviewed exception packet, plus the source constructors listed
below; an additional native-created exception or OCaml entry requires its own
closure/charge. Native effects must preserve typed values and the already
established representative/forest invariants. They must not introduce an
unaccounted replay of these OCaml bodies. A bounded native identifier charge
may be supplied as `N_native`; it need not be forced to zero.

This is an open proof interface, not an added no-callback/no-signal/no-throw
assumption. In particular, the native certificate must not justify its effects
by assuming this combined endpoint or a combined `R = 0`. Existing faithful
runtime, allocation and numeric-library contracts remain applicable; this
packet does not reprove allocation or GMP implementations. Arithmetic
freshness uses the usual prefix bootstrap: if the eventual native allowance
keeps the total below the machine counter limit, every preceding registration
is fresh, so the typed/freshness invariants used by this component persist.

## Save and exit: where registrations and exceptions arise

`save_session_and_exit` ignores the three termination signals, directly calls
`Gnat_checks.save_session`, and then `exit` (`gnat_main.ml:298–309`). Its only
local catch handles unsupported-signal `Invalid_argument`; it does not retry
save. `Session_itp.save_session` (`2212–2244`) has no encompassing retry.
The accepted signal protocol allows at most two serial attempts and no second
SIGINT save inside the handler.

The bound-shape forest has 66 roots, 1,545 stored terms, 309 identifiers and
ten integer objects; its atoms are `0, 1, 32, 126, 4096`, with no real/string
constants and **no Tcase**. Explanation/shape traversals open bound variables
with `t_open_bound`/`t_open_quant` and `t_subst_unsafe`. Their 966 registrations
are the existing binder charge. Unsafe reconstruction does not introduce
`TermExpected`/`FmlaExpected`; absent Tcase also removes the branch-pattern
constructor route. Saved substitutions preserve the covered atoms/types.
`ShapeTooLong`, explanation `Exit` and lookup `Not_found` have the local
handlers shown in the ledger. Failures before completion only shorten the
charged binder traversal.

`Task.local_decls` deserves a stronger statement than “a lookup catch.” Its
`try` encloses a recursive suffix (`task.ml:268–274`), so a `Not_found` can
recompute a selection suffix. Every call still returns an ordered subset of
the declaration occurrences passed to it; that pure selection body does not
open terms or register identifiers. Shape traversal occurs after it returns.
This catch neither duplicates declaration occurrences in its result nor
repeats a binder-bearing shape body.

Serialization traverses existing session fields, names, prover IDs and shape
integers. `save_ident` uses `Theory.restore_path` or the existing `id_string`;
it is not a logical-term printer. Prover-ID search is a scalar loop, distinct
from the private `Ident` counter. Backup/path/HTML helpers, the installed
`Compress_none`, fixed formatter output/tag callbacks and scalar JSON report
have no registration edge. This does not prove all scalar counters, output
volume or service progress. Primitive representation errors remain distinct
from physical allocation/I/O failure; either is included in the exception
classification where its constructor belongs.

Session lookup can raise payload-free `BadID`; goal extraction can raise
`GoalNotFound`, whose printer is constant text. Under the accepted valid
forest, the direct save route creates no term/declaration payload exception.
The integer constant branch does not enter Number's real/range diagnostic
printers. None of these source routes invokes parsing, Re, Yojson, Marshal,
`Gc.stat`, process creation or directory closing. The native effects of their
actual scalar/runtime leaves are still the independent open interface.

Exit hooks have the accepted Debug → Format → terminal `flush_all` family.
Debug's registered-stat list is empty; its timing table contains scalar data.
The Debug/Format once-only gate clears **before** the hook runs; a throw skips
older links on that attempt, and a later attempt can reach them. Terminal
`flush_all` is not itself once-only. This distinction matters to I/O behavior,
but none of these hooks creates a Why identifier or logical exception payload.
No successful-exit or successful-output assumption is used.

## Returning catches do not enlarge the first-fold registration vector

The selected fold has the accepted worst-case vector
`235 + 6*123 + 4 + 168 = 1,145`. Its six formal-opening sites are declaration
mapping, termination, the used-symbol eligibility guard, environment opening,
task used-symbol checking and declaration match checking. All optional
environment hits/misses are already covered. The 81 singleton definitions are
nonrecursive, eligible bodies are binder/pattern free, and actual patterns
are nullary with empty variable sets.

The ledger covers the receiving traps by their **protected expressions and
continuations**, rather than merely finding no direct registration in a catch:

| Receiving route | Effect on the first-fold bound |
| --- | --- |
| `Trans.current` | A `Not_found` selects the already charged empty-cache backward walk. The first walk executes no fold body; rewind executes each queued body once and never reenters that walk. |
| `Weakhtbl.memoize`, `Exthtbl.memo` | Only lookup is inside the `try`. The miss callback and insertion are outside it, so failure in a running callback cannot retry that callback. The Wtds callback builds a transformation closure; the fold executes after the memo call. |
| Hit-body Wty memo | Its callback is `ty_inst mapT`, which creates type nodes but no named symbol. Recomputing that callback is not another binder opening; variable registrations occur outside the lookup trap. |
| `Lists.equal` | A caught `Invalid_argument` yields false. Reached equality callbacks add no identifiers. False can choose reconstruction instead of a physical/equality fast path; the accepted bound already counts that reconstruction and covers the same typed result. Hashcons false selects a valid candidate rather than an extra declaration visit. |
| `vs_graph_let`, subsumption, map/table defaults | Recovery removes/omits a mapping, reports false, or supplies a default. No binder work is replayed. Nonrecursion excludes a new recursive call-list closure. `Extmap.find_opt/find_def` are structural matches, not catches that could turn arbitrary failure into an environment miss. |
| Ephemeron replacement and Hashtbl traversal cleanup | Recovery adds a container or restores traversal state and reraises. Fixed selected hash/equality callbacks add no Why identifiers. No fold callback is reinvoked. |
| `Util.FoldSkip`, strict-comparison sentinels, pattern sentinels, `KnownIdent` | These are distinct constructors, not save's primitive failures. Their normal continuations are already in the accepted transfer. Pattern checking receives `[t1]`, not an empty term list requiring new test variables. |
| `Loc.try2`, `Trans.named`, timing `Fun.protect` | Wrap or propagate failure, with no replay of work. Timing cleanup updates scalar entries. A failed cleanup replaces the original with `Finally_raised` of that scalar/save secondary failure. |

The operations which consume failure and return preserve the typed alternative
and freshness invariants needed downstream. In particular a false equality
reconstructs the same well-typed value; a weak-cache miss cannot invent an
eligible body outside the model. Misses in type instantiation recompute the
same simultaneous substitution. They therefore do not create a later
`TermExpected`, `FmlaExpected`, arbitrary pattern exception, or unsupported
term/declaration printer input.

Primitive-to-logical translation is narrower and **not zero by inspection**:
`Ty.ts_match_args` turns `Invalid_argument` into `BadTypeArity`;
`Term.ls_arg_inst` (and the pattern arity checker) can turn it into `BadArity`;
`Ty.ty_match` turns `Exit` into `TypeMismatch (ty_inst s ty1, ty2)`.
Other term/type checks have their ordinary valid-input meaning; a propagated
exception aborts their body rather than becoming a fabricated term value.
`ls_defn_of_axiom` is not the `decl_map` route. Ddata/inductive constructors
and their broader translating catches are not invoked by this selected map.
`check_match` adds at most one `Loc.Located` wrapper; `Trans.named` adds at
most one `TransFailure`. These wrappers introduce no new payload shape.

## The diagnostic allowance includes tuple-type initialization

The 55 inherited Why printer registrations reject the primitive family.
`BadID`, `GoalNotFound`, `BadTypeArity` and `BadArity` use constant text or
existing symbol names; the last two do not print the symbol's type declaration.
The accepted Sexplib registry has no enabled key for these Why constructors,
or for `Loc.Located`/`TransFailure`; the enabled parsing wrappers cannot be
manufactured by these routes. Printexc's default does not recursively inspect
a logical block. Wrapper branches delegate only the established inner family.

However, Pretty's `TypeMismatch` branch prints two types. Its actual printer
is `LegacyPrinter`: the default `print_ext_any` dispatches to its private
`print_any`, and `Pp_ty` returns to type printing with extension dispatch
disabled. There is no externally installed term-printer callback here.
Type printing **does** call `Ty.is_ts_tuple`, which calls memoized `ts_tuple`.
On a miss, `ts_tuple n` creates `n` named type variables and one named type
symbol. A draft zero diagnostic charge was rejected during this source review
for precisely this edge. Cache initialization is not assumed complete.

The accepted attached type envelope is `T=3`, with intermediate instantiated
type size at most `T²=9`. A diagnostic `ty_inst` substitutes each leaf once;
its partial map contains types from that same size-nine envelope. Its result
has at most `9*9=81` type occurrences, and the second diagnostic type has at
most nine: **90 occurrences per pair**. Instantiation preserves existing
type symbols. Normalized original types have at most three occurrences, so
every reached applied symbol has at most two parameters. A tuple probe can
therefore register at most **three** identifiers, including a failed prefix.
`create_tysymbol` uses `NoDef`, so it does not enter numeric range comparison.

`print_ty_node` tests a tuple at most twice per occurrence (the empty-argument
and general guards). Its default extension dispatch does not double these
tests: only the inner call with `ext_printer=false` examines the node. Recursive
children partition the occurrence tree. Consequently one matching Pretty
attempt, even if every tuple lookup misses, costs at most

```text
(81 + 9) * 2 * (2 + 1) = 540 registrations.
```

`id_unique` assigns printable strings; it does not register another identifier.
There is no `fs_tuple` or `tv_of_string` edge on this route. New tuple memo
entries are private scalar/type-symbol state and do not insert a term or
declaration into the first-fold environment. Failure during their creation
can leave a charged prefix; it cannot retry the body under the same lookup trap.

## Finite reporting topology, including failures while printing

One registry pass tests the matching Pretty registration at most once.
`Exn_printer` can perform that pass and then call `Printexc.to_string`, whose
Why callback performs one more pass. A printer that throws is suppressed and
the original input is retained; it is not recursively replaced with that
secondary exception inside the registry. Printexc has the same suppression
rule. The inherited fixed registration family has one Why adapter and no
other matching type-diagnostic converter.

For an exception with `d` Why wrappers, let `E(d)` bound matching Pretty
attempts from `Exn_printer`, and `P(d)` those from `Printexc.to_string`.
The leaf bounds are `E(0)<=2`, `P(0)<=1`; a wrapper invokes `Exn_printer` on
its strictly smaller inner exception. Thus `P(d)<=E(d-1)` and
`E(d)<=2*E(d-1)`. There are at most two wrappers (`Loc`, then `Trans`), so
**eight attempts per outer report call** suffice. `Finally_raised` carries a
secondary primitive/save exception, not the discarded TypeMismatch, and
therefore does not add a third type-diagnostic wrapper. The private wrappers
of parser/dynlink/strategy interfaces are not created by this call chain.

There are at most **six outer report calls** before the first invocation has
returned to its caller/scheduler or escaped the uncaught-handler wrapper:

1. `Controller.build_prover_call`'s `Sys_error` handler invokes GNAT's
   `InternalFailure` callback. Its ordinary input is scalar; count it anyway.
2. The enclosing `idle_handler` can invoke that callback once more for a
   failure escaping `build_prover_call`, including failure of call 1. Its
   handler body is outside its protected expression and cannot catch itself.
3. GNAT's outer catch can print once if the scheduler/callback escapes. Its
   handler body likewise has no self-retry; stack-trace/OOM branches skip it.
4. The installed GNAT uncaught handler can print once. Before it runs,
   `Printexc` tries exit hooks and suppresses any hook failure.
5. If that handler throws, `Printexc` prints the original exception once.
6. It then prints the secondary exception once. Failure here is suppressed
   by the final uncaught-handler wrapper, without another reporting round.

This deliberately counts mutually exclusive and primitive-only sites. A
failure inside a report may shorten it, enter the next outer site, or be
suppressed by a registry; it cannot revisit the same source report site.
A second SIGINT during reporting enters the separately charged save/exit
route; its primitive/payload-free failure cannot add a type wrapper. Output
callbacks hold formatted tokens/data, not deferred invocations of these
logical printers. The Debug/Format hook gates do not introduce a reporting
loop. Hence failures during printing do not invalidate the finite count.

The resulting interval allowance is

```text
D = 6 outer calls * 8 Pretty attempts/call * 540 registrations/attempt
  = 25,920.
```

`Driver.prepare_task`'s transform fold and `prove_task` are sequential: an
escaped preparation does not proceed to print or prove the task. If the
InternalFailure callback returns, the accounting boundary is the return of
this first invocation, before another scheduled task. If a scheduler `Exit`
catch transitions to `ending`, that ordinary save is likewise a separate
boundary, not an extra save justified by this forest. Successful later driver
debug printing, later transformations, later forest membership and ordinary
save/SIGINT Buffer interference remain separate obligations.

## Disposition and measured round

The numeric source component and catch argument are ready for independent
review. The complete native certificate, full `R`, final counter endpoint,
ordinary-ending save and whole-pipeline assurance remain open. The new checker
validates pinned identities, archive/member/line correspondence, ledger links
and arithmetic; it cannot establish the semantic coverage argument by itself.

Author settings selected by the lead: **GPT-6 Astra / Extra High**. Runtime
model confirmation and token/cost measurements are unavailable. The round
started at **2026-10-19 12:50:32 UTC**; its measured end and validation duration
are in `round.json`. The substantive rework was discovering and charging tuple
initialization in a type diagnostic instead of claiming zero. No CLI memory
was updated; the lead owns integration, issues and durable session memory.
