# Scalar guard frontend repair — 2026-10-29

The owner authorized repair of [blocker #284](https://github.com/berkeleynerd/silver/issues/284).
The current published response target is `88c127b631`, stacked above #266.
This isolated work changes neither published PR while external review proceeds.
The blocker remains open pending review and final combined assurance. The isolated
repair selects the pinned frontend configuration described below; no complete
validation is claimed yet.

## Confirmed counterexample

The independently reconstructed 167-byte source is:

```ada
with Silver_IO;procedure Main is pragma SPARK_Mode(On);X:Integer:=0;R:Integer range 0..9:=0;begin if X>=0 and then X<=9 then if X=99 then R:=X;end if;end if;end Main;
```

The delivered compiler accepts it and GNATprove proves all 67 checks, then native
compilation fails at `R:=X` with “value not in range” and “Constraint_Error would
have been raised at run time”. Removing the inner contradictory guard gives a
passing control. Managed probe `20261028T222332-125b175a567b` retains both outcomes;
its success means the expected rejection/control contrast was observed, not
successful compilation of the counterexample. Exact local evidence was retained
outside `tmp` at `.silver/linux-x86_64/review-guard-frontend-20261028/`.

All 131 compiler source files matched the reviewed response tree. The external
reviewer's original source was unavailable; this is an independent reproducer.
The responsible `Refine_Or_Keep` rule dates to PR #242, before arrays and foreach.
Its runtime-containment theorem is sound for the unreachable outcome, but that
does not establish the pinned frontend's acceptance of the source.

## Cause and selected correction

GNAT records one current conditional fact per entity. The inner `X=99` replaces
its record of the enclosing bound and lets native expansion replace `X` with a
nonstatic literal `99`. The subsequent assignment range check reports a known
failure; in `SPARK_Mode (On)` GNAT promotes that diagnostic to a hard error.
GNATprove already disables this condition-based substitution, which explains
why proof succeeds before native compilation rejects the same source.

The application build command now adds **`-cargs:Ada -gnatdM`** to native
compilation, retaining the project's `-gnat2022`, `-gnata` and `-gnato`. This internal GNAT flag disables current-value
replacement. It preserves static-expression evaluation and runtime checks, and
changes neither Silver's admission rules nor the author's source. It applies
to native compilation of Main and the selected library files. The generated
project, GNATprove options and compiler's own `silver.gpr` do not change.

The flag is source-documented, not a stable public compiler-option interface.
Its use is bound to the pinned GNAT release and needs review when that toolchain
changes. It does not make native compilation identical to GNATprove mode:
conditional comparison folding, for example, remains enabled. GNAT, GNATprove
and their faithful frontend behavior remain documented external dependencies.
The `Current.ToolContract.buildCompletes` premise remains required; this repair
does not claim to prove the physical compiler. Existing runtime-containment,
admission and source-correspondence theorem statements are unchanged. The driver
is not an embedded parser source, so no parser pin or certificate is changed.

An admission-only repair would be larger and remove useful programs. Bare-name
checks miss parenthesized references and GNAT's rewrites of `X+0`, `X*1` and
`X/1`. Checking Ada-static thresholds misses nonstatic constants whose values
GNAT knows. Propagating an empty interval alone conflicts with the existing
nonempty assignment rule and does not explain frontend acceptance. The selected
configuration corrects the identified optimization without adding a parallel
GNAT expression analysis to Silver.

## Pinned source argument

The installed Alire origin is GNAT `16.1.0-1`, archive SHA-256
`9f74f58a827a2ad40dd84c72a413e75ea52888e0d8f7e252fba4d26762402703`.
The release recipe at GNAT-FSF-builds commit
`0334dd54a2c479faa3dfad47a911373581b11739` selects GCC 16.1.0; the inspected
upstream release is commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
This is release-source provenance, not a reproducible binary attestation.

At that pinned revision:

- [`exp_util.adb`](https://github.com/gcc-mirror/gcc/blob/6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea/gcc/ada/exp_util.adb#L14051)
  records the overwritten conditional fact. `Get_Current_Value_Condition`
  handles reversed operands, negation, false outcomes and conjunctions; its
  GNATprove-mode branch at lines 7622–7630 disables this optimization.
- [`exp_ch2.adb`](https://github.com/gcc-mirror/gcc/blob/6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea/gcc/ada/exp_ch2.adb#L154)
  gates replacement through `OK_To_Do_Constant_Replacement`, then materializes
  the equality value as a nonstatic integer literal (lines 175–219).
- [`debug.adb`](https://github.com/gcc-mirror/gcc/blob/6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea/gcc/ada/debug.adb#L626)
  describes M as assuming variables modified and disconnecting tracking of
  constant values. `exp_util.adb:12047` makes replacement ineligible when M is
  set. The other callers of that predicate, `sem_util.adb:22732,22788`, only
  withhold stored nullness facts conservatively.
- [`checks.adb`](https://github.com/gcc-mirror/gcc/blob/6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea/gcc/ada/checks.adb#L3187)
  reports the known range failure; `sem_util.adb:6038–6048` promotes it to a
  SPARK error independently of `-gnatwe`. Unresolved range checks still reach
  `Enable_Range_Check` at `checks.adb:3497–3500`.

A case-insensitive scan covered all 474 top-level Ada frontend `.adb`/`.ads`
files (27,301,966 bytes, zero retrieval failures). The complete flag-reference
set in that scope is its default in `debug.ads`, setter in `debug.adb`, the one
operational consumer above, temporary save/enable/restore for `Loop_Entry` in
`exp_attr.adb`, and CodePeer enablement in `gnat1drv.adb`. None suppresses checks
or changes SPARK/legality settings. `Compile_Time_Known_Value` does not consult
mutable entities' `Current_Value`; `Determine_Range` uses declared bounds for
unmaterialized identifiers, so it does not recover the contradictory singleton
through that route. This inspection covers the named frontend sources, not all
GCC sources or a formal proof of every native behavior.

## Focused evidence and remaining validation

Managed frontend matrix `20261029T075208-6adf393e2b65` compared the existing flags
with `-gnatdM` across 30 exact sources: 27 admitted shapes and three rejected
controls. Seventeen admitted cases failed native compilation with the original
flags; all 27 compiled with M. Cases include operand order, parentheses,
identity arithmetic, a nonstatic threshold snapshot, false and short-circuit
flows, overflow, array indexing, counted loops and constant-array iteration.
The actual static range error still failed both native configurations. The
static division control was rejected by Silver but compiled by the native
frontend in both modes; it is not claimed as a native static-error observation.
This matrix is frontend-only, without proof, linking or execution.

The three persistent tests exercise the exact counterexample; grouped,
normalized, snapshot and false-flow variants with live scalar updates; and
argument input with arrays, counted loops and reverse element iteration. The
shared compile helper checks byte-identical captured source and complete Main
and selected-library reports, before execution checks observable output and
argument rejection. All 23 scalar-guard tests passed in managed run
`20261029T080947-da66ebf18023` (80.912 s in unittest), including five native
compile/prove/execute tests. The exact original source now proves, compiles,
links and runs; the retained 100-doors and guarded arithmetic tests also pass.
Final native-only driver build `20261029T080837-11b8a871e914` passed in 8.516 s.

Dynamic range/overflow controls in `20261029T080007-5833f73fad3f` both raised
`Constraint_Error` and retained unproved GNATprove obligations. Those controls
used the initially proposed shared-project flag, so their proof configuration
is diagnostic evidence, not the selected final configuration. Independent review
identified that the native flag audit does not cover GNATprove's separate
frontend; the correction therefore applies M only to the native build command.
The persistent original-source regression checks both that the generated
project omits M and that the native Main ALI records it. The initial controls
launch `20261029T075930-4fd40342a996` failed on a relative harness path before
executing the experiment; it remains failed. Focused driver run
`20261029T081206-84390bb82d97` passed all 133 checks (29 flow, 104 proof; ten
covered entities) in 362.070 s, with fresh solver work and four workers. A
single-unit invocation of the complete auditor,
`20261029T081909-3d2bc739e22c`, failed because the focused packet omits owned
dependency reports, first `Silver_Libraries.Capture_And_Snapshot`. That failed
attempt is retained; it is not a complete dependency/provenance audit. No audit
rule changed, and the required complete audit remains with the final checkpoint. The
[independent review](reviews/review-guard-frontend-repair-20261029.md) found no
unresolved implementation finding at `039daa3034`; its earlier configuration
scope finding was repaired. The [evidence packet](evidence/scalar-guard-frontend-20261029/README.md)
retains exact sources, pinned source analysis, commands and outputs. Complete native and
Lean/source/module/axiom checkpoints remain mandatory before merge, after the
applicable external feedback is integrated. Earlier successful evidence does
not cover changed driver inputs merely because parser sources are unchanged.

| Round | Selected settings | Result and limits |
| --- | --- | --- |
| Initial reproduction, 2026-10-28 | Astra / Extra High for bounded read-only rule/history review; lead runtime settings unavailable | Array-free failure and passing control reproduced with unchanged compiler options. No source repair or full project proof run. |
| Frontend rule and repair design, 2026-10-29 | GPT-6 Astra / Extra High for each of two bounded threads | Completed pinned producer/flag analysis and minimal repair assessment. The 30-case frontend matrix supports the selected configuration. |
| Implementation and focused validation, 2026-10-29 | GPT-6.1 Sol / Extra High for test implementation; lead settings unavailable | Three compact native regressions added; build, all 23 scalar-guard tests and 133 focused driver checks pass. Complete dependency/provenance audit remains deferred. |
| Independent critical review, 2026-10-29 | GPT-6 Astra / Extra High | Identified the shared-project flag's unreviewed proof-frontend scope; narrowed the repair to native compilation. Final implementation review has no unresolved finding; focused validation passed afterward, with complete assurance still pending. |

Selected settings are not independently confirmed runtime settings. Token/cost
measurements are unavailable. Detailed probe times belong with their evidence.
