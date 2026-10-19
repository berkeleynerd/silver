# Retained Why save/exit identifier-charge review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept the conditional source component at
`6dd2732dd083ba6e29c7e2bd026d5668a0283b5e`; no material findings.**
Direct save/exit contributes zero non-binder registrations, returning catches
add no registrations beyond the accepted first-fold allowance, and the
whole-interval reporting allowance **D = 25,920** is supported. The resulting
interface is **counter_end <= 89,493 + N_native**. Complete native effects,
initial configuration, preservation and the value of `N_native` remain separate
open obligations; this review establishes neither complete `R` nor an
unconditional endpoint or no-wrap result.

## Exact inputs and review record

The target comprises the [source argument](../research/retained-why-save-exit-charge.md)
and all nine files in its
[evidence packet](../evidence/retained-why-save-exit-charge-20261019/README.md):
README, checker, input manifest, effect ledger, report-site graph, source range
manifest, literal excerpts, result and round record. I inspected their frozen
contents, including the 62 source ranges, 16 effect rows and six report sites.
The manifest pins the inherited counter, representative, binder, atom,
serial-signal, exception-registry, Sexplib, formatter and preservation inputs.
Their successful results are reused at their stated scopes. The
[native coverage correction](../research/retained-why-interval-native-effects.md)
supersedes the earlier four-hook description; that obsolete description is not
a premise of this verdict.

The witness remains PID **97103**, capture
`20261019T000304-fcb988ec2c03`, executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Why3 revision is `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml revision
is `8eb41f72ded84df884c3671734c947f612091f84`. Focused reads from the already
pinned Why archive additionally checked `term.ml:400–418,665–739`,
`decl.ml:275–281`, `termcode.ml:618–628` and `pretty.ml:49–180`, resolving
the truncated comparison/unsafe-map continuations, termination return,
shape return and private printer interface. No new source version was used.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime model/effort confirmation, token usage and monetary cost are unavailable.
The timed inspection interval was **13:16:20–13:19:44 UTC**, **204 seconds**
at one-second resolution, excluding report preparation and commit. Actual host:
Linux 7.0.14 x86_64. The separate worktree is
`tmp/review-why-save-exit-charge-6dd2732dd0`; only this report is owned and
committed. The live subthread goal was null. Owner-resumed #119 authorization
is unchanged; production #88–#94 remains unstarted. CLI memory was not updated.
The lead owns integration, publication, issue records and durable memory.

## Returning catches and direct save effects

The crucial distinction is the protected expression. `Weakhtbl.memoize` and
`Exthtbl.memo` protect their lookup, with miss callbacks in the handler body.
A callback failure cannot be caught by that same lookup trap and replay it.
The Wtds callback returns a transformation closure before that closure runs;
the Wty callback is `ty_inst`, whose constructors register no named symbol.
Fresh variable construction remains outside that memo trap.

`Trans.current` likewise protects only a lookup. Its first backward walk does
not execute the fold body, and rewind executes each accumulated declaration
once. A `Not_found` recovery is therefore covered by the already accepted
empty-cache walk. `Lists.equal` recovery can reject an equality fast path and
select reconstruction, but cannot supply an invalid term or another declaration
visit. The selected comparison callbacks create no identifiers. The existing
allowance already includes reconstruction, all six formal-opening sites,
termination and match-check openings: `235 + 6*123 + 4 + 168 = 1,145`.

The let-graph recovery changes only the variable-description map; nonrecursive
singleton definitions leave no recursive call-list expansion. Private pattern,
comparison and fold sentinels are distinct exception constructors, rather than
arbitrary primitive failures. The selected patterns are nullary with empty
variable sets, and match checking receives `[t1]`, so its fallback fresh-test-
variable branch is not reached. Ephemeron replacement and Hashtbl traversal
cleanup do not reinvoke a binder-bearing callback. Structural map defaults do
not catch exceptions from a failed transformation.

For saving, `Task.local_decls` really can recompute a recursive suffix after
`Not_found`; calling it merely a lookup trap would be insufficient. Its body
only selects declarations, its accumulated list is immutable, and recovery
restarts with the earlier accumulator. Every completed result is an ordered
subset of its input occurrences. Shape traversal happens after this selection
returns, so recomputation creates neither duplicate shape occurrences nor
additional identifiers.

The retained save forest has no `Tcase`. Its bound/quantifier openings use the
raw substitution constructors, not logical term/formula checks. Explanation
`Exit` and shape-length catches abandon the relevant traversal without retrying
its opened prefix. Session/name/prover serialization, backup/path helpers,
integer formatting and the admitted formatter callbacks add no registration
edge. `BadID` is payload-free and `GoalNotFound` has a constant printer. The
accepted **966** binder charge covers an unsuccessful prefix of each of at
most two serial saves; registrations are not refunded after a failed attempt.

The exit chain distinction is also correct: Debug/Format gates clear before
their hooks, so a failure may skip an older link on one attempt and reach it
on a later attempt. Terminal `flush_all` may repeat. The empty registered-stat
list, scalar timing table and admitted output family keep their direct
identifier charge zero without assuming output or exit succeeds.

## Type diagnostics and failed printing

Primitive failure can become `BadTypeArity`, `BadArity` or `TypeMismatch`
at the stated source catches. The first two print existing symbol names,
not type declarations. The accepted typed/representative invariants and the
returning alternatives above prevent recovery from fabricating a malformed
term, arbitrary pattern or unsupported declaration for a larger printer.
An ordinary propagated failure abandons the body instead of returning such
a value. Native-created exception families remain an explicit separate
closure obligation.

The attached `T=3` envelope covers stored types and symbol signatures, and
normal instantiation gives the accepted size-nine intermediate envelope.
`ty_equal_check` can carry two such types. For the translating `ty_match`
catch, `ty_inst s ty1` substitutes each variable leaf once with a type from
the same envelope: at most **81** occurrences, plus at most **nine** in
`ty2`. `ty_inst` returns a map value at a variable leaf without recursively
instantiating that value. It therefore does not chase substitution-map cycles
or repeatedly expand a replacement. The inherited finite, well-formed type
graphs and raw type reconstruction preserve this argument and existing applied
symbols; they do not introduce alias expansion or new symbol arities.

Every applied symbol originated in a normalized type with at most three
occurrences, so its arity is at most two. `Pretty`'s actual `LegacyPrinter`
uses the default extension function and its private `print_any` dispatch;
the `Pp_ty` branch disables extension dispatch before inspecting the node.
No exported setter introduces another printer here. At each occurrence the
empty/general tuple guards make at most two `is_ts_tuple` calls. Each missed
`ts_tuple` request creates at most two named type variables and one named type
symbol. Its `NoDef` constructor does not enter numeric range checks. Thus
**90 * 2 * 3 = 540** registrations cover every matching Pretty attempt,
including a failed prefix and misses at every probe. `id_unique` changes
printable-name tables rather than registering Why identifiers.

The original zero-diagnostic draft would fail on this tuple initialization
edge. The frozen candidate explicitly repairs it; no initialized tuple-cache
premise is smuggled into the bound. New tuple entries do not enter the fold's
declaration environment, and exceptional reporting occurs after abandoning
that fold. Their construction cannot feed a larger diagnostic type back into
the selected transformation.

Both registries suppress a throwing printer and continue with the original
exception. One Why pass reaches the matching Pretty registration at most
once; the anomaly fallback permits one further pass through Why's Printexc
adapter. For Why-wrapper depth `d`, the conservative recurrence is
`E(0)<=2`, `P(0)<=1`, `P(d)<=E(d-1)`, `E(d)<=2*E(d-1)`.
The selected path adds at most one `Located` and one `TransFailure`, giving
**eight** attempts. Timing cleanup can replace the original failure with
`Finally_raised` of a scalar/save secondary exception; it cannot add that
wrapper around the discarded type payload. The accepted constructor-specific
Sexplib and other registry classifications do not add a competing type printer.

## Interval topology, conditional arithmetic and validation

The six report sites form a conservative forward envelope: the build callback,
idle callback, GNAT outer catch, GNAT uncaught handler, and the runtime's
sequential original/secondary fallbacks. Their handlers do not protect their
own bodies. A failed report therefore reaches an outer site, is suppressed
inside a registry, or escapes to the runtime's final suppressor; it does not
reenter its source report site. The fallback-original call must return before
fallback-secondary is reached. Counting all six also covers mutually exclusive
and primitive-only sites.

A signal during reporting enters the separately charged save/exit path,
which contains none of these reporting calls. Its failure can be consumed by
a registry or unwind outward, but cannot add a type-payload wrapper. Admitted
formatter output callbacks do not retain deferred invocations of these logical
printers. Consequently failure during printing does not invalidate the
**6 * 8 * 540 = 25,920** whole-interval allowance, including paths with no
SIGINT save at all.

The interval stops on normal return of the selected transformation before
later driver printing/transforms, on the selected failure continuation's
return before another scheduled invocation, at the ordinary scheduler
`Exit -> ending` boundary, or after the one uncaught-handler wrapper.
The ordinary ending save, later forests and later scheduler invocations are
not charged to this certificate. With these boundaries the arithmetic is
`60,496 + 1,145 + 2*966 + 25,920 = 89,493`, plus the independent native charge.

The native interface must establish complete applicable dispatch/configuration
and effects, preserve the typed inputs, representative/forest invariants and
private state used here, and account for any additional OCaml entry, exception
family or body replay. It cannot obtain those facts by assuming this endpoint
or `R=0`. The prefix freshness argument is valid only once an independently
established total stays below the counter limit. These explicit dependencies
make this a useful conditional component without declaring native closure.

I reused the author's exact **0.49199085700092837-second** successful binding
and arithmetic check. Its archive/member/range identities and forward-edge
checks make the selected evidence reproducible; neither excerpt presence nor
the small report graph mechanically proves semantic completeness. The source
reasoning above supplies this review's separate assessment. No checker or
predecessor suite was replayed, and no native target, capture, compiler,
disassembler, prover or Lean run was performed. Report links and whitespace
were checked. All target files remain unchanged, including the verbatim
upstream trailing space in the imported `gnat_util.ml` excerpt.
