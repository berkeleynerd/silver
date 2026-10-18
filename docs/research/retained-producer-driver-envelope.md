# Fixed registered-task and selected-driver call envelope

2026-10-18, Linux x86_64, research for
[#119](https://github.com/berkeleynerd/silver/issues/119).
The [accepted initial split/registration](retained-producer-fixed-tail.md)
now supplies a finite, **solver-answer-independent dispatch envelope** for the
next stage: at most **153 registered tasks**, **459 task/driver pairs**, and
**6,120 applications of configured driver-transform directives**, summed over
the five separate processes. Each pair causes at most one `prepare_task` entry
and at most one `print_task_prepared` entry. This closes call cardinality and
dispatch; it does **not** establish prepared-task, printer, shared-lifetime or
whole-pipeline capacity.

The [callable offline composition](../evidence/retained-producer-driver-envelope-20261018/README.md)
joins the exact accepted input identities, raw-task observations, Input_Is_Valid
classification and private-driver lists. It uses the unchanged relevant-source
premise for Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`; source control-flow
exhaustiveness is inspected, not mechanically proved by the checker. No new
native run, toolchain option, solver execution or source-admission rule is used.

## The task domain is fixed before solver execution

Retain the accepted fresh Per_Check launch: the three automatic provers
`cvc5,z3,altergo`, counterexamples off, no replay/manual prover/debug-save route,
and serial scheduling (`opt_parallel=1`, with no `-j` override). Exact arguments,
environment, input bytes and driver import closure come from the accepted
packet. `gnat_config.ml:24–55,308–330,531–549,650–676` supplies those defaults
and frozen values. The warning prover defaults to the first selected prover,
cvc5; no fourth driver is introduced by warning checks. Successful prefix
initialization with three selected provers also excludes the rejected mixed
interactive configuration.

`register_goal` visits the children of the one initial split. It either drops
a goal or adds it to a check's `toplevel` set (`gnat_main.ml:50–73`,
`gnat_checks.ml:201–226,490–505`). Thus a raw split count is an upper bound on
registered proof-node IDs; it is not their asserted equality. The separately
accepted Input_Is_Valid classification sharpens its bound from four to one.
No assumptions about the exact registrations of the other four cases are
needed for the following table.

| Fixed process | Raw initial tasks | Registered-task upper bound | Task/driver pairs | Configured transform applications |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 64 | 64 | 192 | 2,560 |
| Put | 53 | 53 | 159 | 2,120 |
| First_Or_Default | 32 | 32 | 96 | 1,280 |
| Input_Is_Valid | 4 | 1 | 3 | 40 |
| Is_Message | 3 | 3 | 9 | 120 |
| Sum of separate processes | 156 | 153 | 459 | 6,120 |

Every registered node is an initial split child without a further
transformation. For Per_Check, the strategy and its last transformation are
both `split_goal_wp_conj`; `is_full_split_goal` is therefore true for these
nodes (`gnat_checks.ml:283–323,346–353`). On exhausted provers,
`register_result` takes `unproved_vc_continue`, not `further_split`/`add_clone`
(`:598–661`). Counterexamples off excludes `add_ce_goal`. The normal scheduling
route consequently introduces no new registered proof-node domain after the
accepted endpoint, regardless of whether later prover answers are valid.

This is a bound for the five fixed inputs and their established configuration.
It does not turn captured success into a membership test for arbitrary source.
The earlier source-derived G/R bounds and their all-proved response premises
remain separately applicable; this packet neither rewrites their historical
constants nor asserts that raw task count equals reported G.

## Why a pair is entered at most once

The source argument needs more than three configured prover names. A fresh
attempt, a completed nonvalid attempt and an internal failure have different
state transitions:

| State/event | Effect relevant to repetition |
| --- | --- |
| Initial selection | `next` removes the chosen goal from its ordered scheduling set (`gnat_checks.ml:272–281`). Set membership prevents duplicate queued goal IDs. |
| First attempt with a selected prover | No saved selected-prover attempt exists. The built-in Trivial prover, if present, is a different key. `schedule_proof_attempt` uses the requested limits and creates a nonobsolete selected-prover attempt (`controller_itp.ml:591–652`, `session_itp.ml:644–675`). |
| Completed result | The controller stores `Some result`, nonobsolete, before calling `interpret_result`. With the fixed limits, `has_been_tried_by` subsequently returns true for that pair (`gnat_checks.ml:471–487`). |
| Valid result or already-proved goal | The goal is completed without re-adding that pair. A built-in trivial proof may cause no driver invocation at all (`gnat_main.ml:131–152`). |
| Nonvalid result | `register_result` may re-add the goal, but `find_best_untried_prover` selects only a prover whose identical-limit attempt is absent. After the last selected prover, Per_Check has no successor split (`gnat_checks.ml:621–647,714–726`). |
| Preparation exception / `InternalFailure` | `idle_handler` catches the exception and calls the failure callback. `interpret_result` records a warning and does not call `handle_vc_result`, re-add the goal or schedule a retry (`controller_itp.ml:517–536`, `gnat_main.ml:94–120`). An uncaught failure terminates the path. |
| Interrupted, detached or other non-Done notification | The normal interpreter does not requeue the goal. Fresh automatic script mode excludes editor/replay/UI rescheduling. |
| Duplicate or late server result | `timeout_handler` removes a finished/interrupted/failed call before invoking its callback; later lookup of that call is ignored (`controller_itp.ml:450–490`). It cannot cause a second scheduling transition. |

The limits used by `has_been_tried_by` are the same immutable-configuration
values used to create that first selected attempt (`gnat_config.ml:567–576,
632–655`). There is no existing selected-prover result to trigger adaptive
limits on first use, and a completed pair is excluded from selection before
any second adaptation could occur. Freshness also excludes the obsolete-valid
proof preference. `parallel=1` excludes the multi-prover scheduling branch;
warnings use only the first selected prover and do not enlarge the envelope.

These transitions establish one entry per `(fixed registered goal ID, selected
prover)` in every normal continuation. An infinite sequence of `NoUpdates`
does not add pair entries. **The envelope does not bound polling, wall time,
solver steps, output notifications or output bytes**, and it assumes ordinary
protocol/source behavior rather than arbitrary corruption. It needs no premise
that a solver proves a goal, returns a particular answer, or even completes.

## From queued attempts to preparation and printing

One scheduled attempt enters the controller queue once; the synchronous idle
handler pops it once and calls `build_prover_call`
(`controller_itp.ml:409–438,517–536,578–652`). The latter retrieves the original
task using `Session_itp.get_task` and calls `Driver.prove_task` once.
`Driver.prove_task` calls `prepare_task` once, then `prove_task_prepared` once
(`driver.ml:492–497`). That second function calls `print_task_prepared` once,
then flushes the formatter and derives a filename before `call_on_buffer`
(`:449–470`). Exceptions can prevent later entries; no retry loop occurs here.
Debug-save/manual printer entry points are excluded by the exact launch.

The original task relation is stable: `session_raw_tasks` associates the fixed
proof-node ID with its initial task, and `Task.task_hd`'s six fields are
immutable (`task.ml:65–77`). Ordinary selected prover attempts add proof-attempt
state, not new goal tasks. This says **which task is supplied** on a different
prover's call. It does not say that preparation reuses its physical nodes:
`update_task` adds driver theory/meta context and each configured transform may
rebuild the context, goal or helper declarations. A task passed to three
different drivers can therefore cause three separate reconstruction lifetimes.

The exact private-driver directives, including import order, are reused from
the accepted packet. Their source entry points are:

| Prover | Printer selected by `print_task_prepared` | Outer configured transform entries per task |
| --- | --- | ---: |
| cvc5 | `smtv2.6` → `Smtv2.print_task V26` | 15 |
| z3 | `smtv2` → `Smtv2.print_task V20` | 13 |
| altergo | `smtv2.6par` → `Smtv2.print_task V26Par` | 12 |

`Driver.prepare_task` folds those lists after `update_task`
(`driver.ml:330–393`); printer registrations are at `smtv2.ml:1077–1082`.
Hence each candidate registered task contributes at most 40 **outer configured
transform applications** across the three drivers, giving 6,120 in total.
This is not a count of recursively invoked transforms, per-declaration callbacks,
term visits, allocations or internal cache misses. Conditional transform flags
and helper dispatch still need their own source-specific analysis.

The no-collection and semantic-count evidence stops at the earlier registration
endpoint. Its `W=128,847,761`, `B=131,043,754` and count maximum 47 are not reused
as upper bounds on these future reconstructions. Neither a per-task sample nor
a per-driver maximum automatically bounds shared cumulative identifiers,
weak-cache behavior, name suffixes or all later allocation events.
Solver/result callbacks can interleave allocations and collection with later
preparation calls; the finite pair count does not extend the earlier
no-collection theorem across that complete lifetime.

## Concrete numeric subcalculation, without printer closure

All three printers use `smtv2.ml`'s `number_format` (`:319–334`). Its ordinary
real fallback uses fraction syntax, reaching `Number.print_frac_real`
(`number.ml:302–325`), which materializes powers of two/five and converts the
expanded numerator/denominator to decimal strings. The accepted SV6 checksum's
short exponent representation therefore does not bound backend numeric output.
Typed syntax literals also follow `syntax_range_literal`/`syntax_float_literal`
and may reach `Number.print_in_base` (`printer.ml:345–407`).

`eliminate_literal` can create new real constants for floating type bounds
(`eliminate_literal.ml:137–179`). For exponent width e and significand width s,
the positive maximum is exactly

```text
(2^s - 1) × 2^(2^(e-1) - s).
```

The already-pinned imported `theories/ieee_float.mlw` has three direct type
declarations, at lines 903, 945 and 987. For these declarations alone the new
checker computes the following exact bounds with unbounded integer arithmetic:

| e / s | Constructor power of two | Expanded numerator bits | Decimal digits |
| --- | ---: | ---: | ---: |
| 8 / 24 | 104 | 128 | 39 |
| 11 / 53 | 971 | 1,024 | 309 |
| 15 / 64 | 16,320 | 16,384 | 4,933 |

The constructor's power of five is zero and the denominator is one.
`Number.real_value` may transfer factors of five from the significand into its
normalized exponent (`number.ml:91–108`); the checker preserves that exact
value and records both constructor and normalized fields. It verifies decimal
digit counts using integer powers, not floating-point logarithms.

This is a concrete subcalculation for these three retained declarations. It
does not establish that every future floating type originates there, bound
every imported/native/generated literal, or close the printer's complete
numeric-formatting domain. Those joins remain explicit; no broad literal or
transformation inventory was added in this increment.

## Exact obligations remaining before a capacity claim

The offline `compose()` function produces the finite envelope and the above
subcalculation. Its result deliberately leaves prepared-task, shared-lifetime,
printer, solver-output and whole-pipeline capacity false. The missing argument
between registered input and a safely bounded printed task must establish:

- Every selected transformation branch and helper preserves the required term,
  type, declaration and representation invariants over the full context, with
  bounded cumulative allocations and semantic count operands. The three old
  count observers require extension or a source bound for these new calls.
- All source-created identifiers/counters and shared caches fit over every
  allowed call sequence. In particular z3 reaches `Introduction.Hsdecl`
  (`introduction.ml:33–54,170–185,195–230`): its `tag _ d = d` does not itself
  allocate. `Hashcons.Make.hashcons` increments when `WH.merge` returns the
  same object (`hashcons.ml:42–46`), so a cache hit on that same object can still
  increment; counting distinct declarations or misses alone is insufficient.
  A per-call allocation charge or a complete unused-counter consumer argument
  must close this explicitly. Structural term hashing/traversal also needs its
  own reached-operation account.
- Expanded term/type/template visits, number values and syntax widths bound
  generated text, formatter queue counters and buffer growth. Shared physical
  DAG size and the 459-call envelope do not bound unfolded printed occurrences
  or arbitrary exponent expansion. Generated float bounds are only one origin.
- Filename/path requests and the full lifetime up to the chosen task-printing
  endpoint compose with those bounds. Server/process/solver internals, result
  parsing, O, final timers, session and response serialization stay separate.

A future native capture is justified only after selecting which missing
condition it will discharge. Stopping at the first `call_on_buffer` would
observe just the first chosen pair and leave the other candidate pairs and
shared cumulative lifetime open. Repeating the five successful registration
captures at the same endpoint would add no evidence for these obligations.
No such run was performed or requested in this increment.

Selected model/effort: GPT-6 Astra, Extra High; live confirmation and token/cost
measurements are unavailable. The new round uses source inspection and offline
identity/arithmetic replay only. All byte-pinned prior records remain intact.
