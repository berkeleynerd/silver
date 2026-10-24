# Reference-prefix reset repair, #219

This additive overlay corrects the scratch-event export in author
`17569ceaa8daf41892852cc4ab8b423b28d9091e`, identified by the independent
[GPR baseline review](../../../../reviews/review-gpr-baseline-20261024.md)
at `ad92df5c3658b7495f1747226cde54a0dadc3f20`. That exact review is integrated
locally as `c1097ef6f1263f7bfaeafbe4c6d61701b088ffe1`. Original author and review
files remain unchanged, including the historical six-event counterexample.

For **each** of datarep, phase1 and translation, the effective allowance is:

| Scope | Reference-prefix resets | Singleton pushes | Peak entries |
| --- | ---: | ---: | ---: |
| User/configuration baseline before extra RTS clauses | 7 | 7 | 1 |
| Additional two RTS attribute references | 2 | 2 | 1 |
| Complete selected prospective parse | 9 | 9 | 1 |

The prospective row adds the event counts; it does not add peaks. The scratch
table's accepted separate backing bound remains **672 bytes**. Seven must not
be reused as the complete prospective event count. These counts describe the
selected Reference_Prefix scratch table, which is distinct from the global
GPR.Names indefinite vector and its still-incomplete process-wide request bound.

## Source argument and effective callable

The original shape reader counts six references in declaration right-hand sides.
It separately counts one empty case construct. Empty alternatives do not remove
the selector parse: `gpr-dect.adb:889–895` calls Parse_Variable_Reference for
`case GCC_Prefix is`. `gpr-strt.adb:846` unconditionally calls Names.Init and
`:856` adds the initial prefix name. The loop continues only on a dot (`:858`);
all selected RHS and case-selector prefixes are singletons. The user project
has no reference calls. Thus six RHS calls plus the case selector give seven
baseline resets and seven pushes. Every call resets before pushing, preserving
peak one. Resets do not erase gross allocation events.

The accepted added fragment `db/gnat.xml`, zero-based configuration index 13,
contains one Compiler and one Binder attribute reference. They follow the same
Parse_Variable_Reference route, adding two resets and two singleton pushes.
Their selection and primary +20/+7/+7 table effects were already established by
the accepted prospective-native packet. This repair reads that one fragment;
it does not rerun XML selection or those primary calculations.

`capacity.effective_prefix(original_prefix, added_rts_reference_calls=2)`
is the effective export for downstream consumers. The second argument is
mandatory. It derives the baseline from both retained shape summaries, copies
the original record, corrects `reference_prefix_reset_events_upper` to seven,
and adds the corresponding baseline singleton-push field. The nested
`reference_prefix_events` record explicitly exports baseline seven, RTS two and
prospective nine for resets and pushes. It preserves every other original
coordinate and never declares complete allocator-event or process capacity.
Applying the overlay twice is stable; the source record is not mutated.

The original callable/result's six-event field is historical and superseded by
this overlay. Its supported primary and auxiliary table bounds remain usable.
The added scratch events do not alter the earlier list-value bound, the known
partial global-name contributions, the primary +20/+7/+7 arithmetic, or the four
auxiliary parser backings. Their successful receipts are retained unchanged.

## Focused evidence and remaining work

The one new changed-count/source/interface check passed first attempt in
**0.123714 seconds** on Linux x86_64. Its [receipt](result.json) verifies 13
provider pins and the complete pinned GPR.Dect/GPR.Strt source files, independently
counts the selected RHS/case and two extra RTS references, checks the exact
source route, exercises the new callable against all three retained phase
records, and confirms all other original coordinates remain equal. It imports
only the new overlay. No successful baseline, auxiliary, selection, predecessor,
native, prover, Lean, service, capture or runtime-corpus check was replayed.

The [handoff](handoff.json) exports the effective counts. The
[round record](round.json) records selected GPT-6 Astra / Extra High; runtime
confirmation and token/cost telemetry are unavailable. Independent verification
of this repair is pending. Root owns #219 disposition, integration and
publication; this subthread made no GitHub, push or CLI-memory write.

Nonparsed global Names, remaining startup/reset/growth accounting, XML/DOM/regexp
and KB containers, separate Gprconfig discovery/output/generation, GNATprove
GPR2, and later producer/report joins remain #212 obligations under #119.
Production/admission, physical premises, P188, e <= 2, two save-entering callbacks
and three saves remain unchanged. Complete producer configuration capacity is
still false.
