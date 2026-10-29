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

The generated application project now adds **`-gnatdM`**, alongside its existing
`-gnat2022`, `-gnata` and `-gnato`. This internal GNAT flag disables current-value
replacement. It preserves static-expression evaluation and runtime checks, and
changes neither Silver's admission rules nor the author's source. The project
is shared by proof and compilation, including the selected library files. The
compiler's own `silver.gpr` does not change.

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
controls. Eighteen admitted cases failed native compilation with the original
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
argument rejection. Native execution of these tests is pending in this record.

The separate dynamic range/overflow controls check that inadmissible programs
still raise `Constraint_Error` and retain unproved GNATprove obligations with M.
Their managed outcomes, focused driver proof/build, regression results and
independent review will be recorded before handoff. Complete native and
Lean/source/module/axiom checkpoints remain mandatory before merge, after the
applicable external feedback is integrated. Earlier successful evidence does
not cover changed driver inputs merely because parser sources are unchanged.

| Round | Selected settings | Result and limits |
| --- | --- | --- |
| Initial reproduction, 2026-10-28 | Astra / Extra High for bounded read-only rule/history review; lead runtime settings unavailable | Array-free failure and passing control reproduced with unchanged compiler options. No source repair or full project proof run. |
| Frontend rule and repair design, 2026-10-29 | GPT-6 Astra / Extra High for each of two bounded threads | Completed pinned producer/flag analysis and minimal repair assessment. The 30-case frontend matrix supports the selected configuration. |
| Implementation and focused validation, 2026-10-29 | GPT-6.1 Sol / Extra High for test implementation; lead settings unavailable | Three compact native regressions added; focused driver/configuration validation in progress. |
| Independent critical review, 2026-10-29 | GPT-6 Astra / Extra High | In progress: actual patch, pinned flag semantics, check preservation and regression coverage. |

Selected settings are not independently confirmed runtime settings. Token/cost
measurements are unavailable. Detailed probe times belong with their evidence.
