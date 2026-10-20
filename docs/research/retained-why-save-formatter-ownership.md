# Fresh save formatter ownership and normal scalar-service attachment

2026-10-20 UTC, research #119 / #153, Round 31. This attaches the selected
source ownership and locale-lifetime arguments to the accepted
[Format core](retained-why-save-formatter-core.md) and
[scalar conversion](retained-why-save-scalar-format.md) bounds. It does not
establish the missing U/input bounds or complete formatter/save capacity.
The [packet](../evidence/retained-why-save-formatter-ownership-20261020/README.md)
retains exact source and installed-byte witnesses and the attachment interface.

## Private formatter and receiving catches

`Session_itp.save` allocates its XML formatter after opening two channels. The
formatter is a fresh local value. Its only consumers are the selected XML
printers and the final flush (`session_itp.ml:2021–2209`). The save context
contains the prover map and shapes channel, not the formatter. Neither session
fields, identifier tables, attempt records nor the persistent prover maps
receive the formatter or a closure that captures it.

The closures partially applying `save_prover`, `save_file`, `save_goal` and
`save_trans` are passed to synchronous map/table/list traversals. Those
traversals call the closure while walking their finite data; they do not
register it as a later callback. `%a`/`%t` printers are synchronous
`Acc_delay` consumers, as already established in the Format-core result.
The queue stores data tokens and sizes, not those printers. The selected
formatter is never passed to `at_exit`, a signal registration, weak-table
callback, scheduler, or global formatter setter.

This is a source nonescape argument for the named call graph, not a conclusion
from a lexical absence search over arbitrary plugins. It uses the existing
valid typed-value and fixed-loaded-source/native behavior boundary, including
exclusion of unmodeled unchecked mutation. Runtime stack/heap scanning preserves
rooted values under that boundary; it does not hand a caller's private formatter
to an arbitrary source callback. No new physical-memory sufficiency argument
or whole-program binary refinement is asserted.

The local receiving scopes matter:

| Source scope | Work inside its catch | Relation to this formatter |
| --- | --- | --- |
| `save_ident` Not_found fallback | Restore path, test list, concatenate components | Ends before `fprintf`; no call on this formatter occurs inside it |
| Prover-ID/statistics helper catches | Table lookups, candidate-ID search, persistent map construction | The formatter is not an argument and is not captured |
| `pp_sum_shape_version`, HTML/string/scalar printers, goal/transformation/file serializers | Selected fixed conversions and output | No catch resumes a failed core operation |
| `compute_tag` | Fresh Buffer16 and a second private formatter | Its output/flush has no local catch; it has no alias to the XML formatter |
| Box-description integer parser's Failure catch | `int_of_string` on the fixed annotation's digit | Runs after the helper formatter was flushed; no formatter mutation is enclosed |

The direct `Format` and selected `CamlinternalFormat` output path likewise has
no handler that restarts an interrupted queue/stack mutation. An exception
escaping one of those operations unwinds the selected printer and `save` frame.
A higher controller/signal/ending catch can start another save, but that save
creates another formatter; it cannot resume the abandoned private state.
The lifetime argument does not assume that every `fprintf` or channel call
succeeds. A catch in a different computation between two completed formatter
operations may continue serialization, but it has not enclosed a partial
formatter mutation.

A signal save has the same fresh construction. Its formatter and auxiliary
formatters are distinct from the interrupted save's local formatter. Standard
formatters used for errors are separate objects. Channel operations or global
`flush_all` can touch an already opened channel; they have no reverse pointer
to its `Format.formatter` queue/stack record. Thus channel aliasing does not
invalidate the private core-state argument. Channel effects, byte delivery,
file truncation, failures and their representations retain their own owners.

Under the inherited faithful-runtime/pending-action behavior, these facts
discharge the **selected source** fresh-default and private-frame integrity
requirements of the core transfer. An interrupted operation is either a
prefix that is abandoned, or returns normally with its source post-state.
They do not establish arbitrary user-supplied formatter callbacks, safe
continuation after unchecked heap corruption, or all native allocator internals.
The source/native behavior relation remains an explicit external premise;
its required scope is not replaced by the ownership proof.

## C numeric locale lifetime

The installed native startup calls `caml_init_locale` before GC/signal setup
and before `caml_start_program` invokes the OCaml application. The selected
Linux implementation creates `newlocale(LC_NUMERIC_MASK,"C",0)` and stores
its result in `caml_locale` (`floats.c:107–149`, `startup_nat.c:104–160`). The
runtime does **not** check a null result. This packet does not turn a failed
locale allocation into a successful initialization or claim to have measured
that outcome in the captured processes.

Under the existing functioning-service and sufficient-resource premise, this
valid request returns a locale object with C numeric conventions. Source
startup initializes it before any selected save. No selected path replaces or
frees it during ordinary application execution. The runtime's freeing site is
`caml_shutdown`, after its registered exit/shutdown callbacks and heap finalizers
have run (`startup_aux.c:174–198`). Any callback save during those stages still
precedes freeing. The selected standalone executable reaches that shutdown
only from terminal `caml_do_exit` when cleanup is enabled; after shutdown the
route terminates signals and exits. It does not resume the save scheduler or
perform a subsequent OCaml formatting callback. The registered shutdown callbacks
use `caml_callback_exn`: an ordinary OCaml exception is returned to the shutdown
caller, which continues toward terminal cleanup; it does not resume the save
scheduler after freeing the locale. Embedded clients that directly call
shutdown and then reuse OCaml are outside this selected executable route.

Each `caml_format_float` selects `caml_locale` before its `caml_alloc_sprintf`
call, then restores the previous locale after success (`floats.c:177–196`).
Nested successful conversions save/restore the same C locale while inside an
outer conversion. An exception that skips restoration leaves C selected;
it does not install a wider decimal separator. Each later conversion again
selects C explicitly. The lifetime/selection argument uses successful locale
services and the existing source/native/pending-client behavior; it does not
assert that an arbitrary foreign `freelocale` call is harmless.

The integer formats have no grouping flag or locale-sensitive textual field;
their signed decimal output remains at most 20 bytes. For `%g`, the already
reviewed GNU conversion contract at precision six and C numeric locale yields
at most 13 bytes, including all binary64 bit patterns. Boolean output is the
fixed literals. Therefore the selected normal scalar bound **d=20** can be
attached under the existing external numerical/allocation service premises,
with the locale preservation obligation now justified by this source lifecycle.

No new vendor-source recovery or toolchain modification is required. Source
and installed bytes support the same scoped external behavior relation used by
the other capacity components. Existing trusted services do not prove a
finite-representation bound by assertion: the particular integer/float/string
extents and fixed buffers were derived in Round 29, and are reused unchanged.

## Attachment and remaining scope

The interface distinguishes source-derived obligations from inherited external
premises. It attaches fresh/private formatter integrity under the existing
source/runtime relation and normal d=20 under that relation plus functioning
numeric/locale/allocation services. Its default carries no assertion that those
services actually succeeded. Missing service or source premises leave the
respective usable attachment null. The core input/continuation bound remains
unjoined until the table/string owners supply it. No full-save flag is set.

A failed locale initialization, negative `vsnprintf` result, allocation failure,
shutdown-service failure or unclassified pending client is not certified as a
normal scalar conversion. The known unsigned long branch on negative printf
return remains outside the normal temporary-size result. Failed/exceptional
paths still need their capacity/error owner. This packet neither relabels a
representation error as external exhaustion nor uses sufficient physical memory
to prove the still-missing finite bounds.

Accumulator construction/recursion, aggregate object/allocation and native
layout, runtime stack/GC, channel/file-offset/pathname and error/exit capacities
remain open. So do useful restored-path U and the full driver/solver/report/
fixed-library/current-grammar composition. Oracle, pins and admission remain
unchanged, production #88–#94 unstarted and PR #121 draft/unmerged.

Lead-authored; live model/effort and per-agent token/cost attribution are
unavailable. Only bounded source and retained-instruction reads were performed;
there was no target, capture, disassembler, source-fetch, solver/proof or broad
prior-checker replay. Independent review belongs to the aggregate Round 31.
