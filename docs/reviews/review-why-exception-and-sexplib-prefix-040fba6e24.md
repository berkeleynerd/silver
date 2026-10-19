# Why exception and Sexplib converter prefix review

2026-10-19 UTC, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**Accept both packets for their stated bounded conclusions. No material finding
requires a packet correction.** The Why primitive-exception rejection argument
and the installed Sexplib converter-family argument are supported. Neither
establishes complete exception effects, interrupted-continuation preservation
or `R`. The existing assurance boundary does not justify dropping the remaining
save/exit work or assuming that no signal occurs.

## Frozen inputs and review record

| Packet | Exact target |
| --- | --- |
| [Why session exception prefix](../research/retained-why-session-exception-prefix.md) | `18bd02108fc2e0456f4339d3e31b593b5daab7da` |
| [Sexplib converter prefix](../research/retained-why-sexplib-converter-prefix.md) | `040fba6e247e3735f9731a7581ec609b251d4a78` |

The review uses a separate sparse worktree at the latter target, including the
accepted #142 formatter repair. All eleven files added by the exception target
are byte-identical there. Only this new report is reviewer-owned. Inputs include
both complete packets, their archived matching Why/OCaml/package sources,
retained disassembly and installed identities; the accepted session/callback
and formatter arguments; and the Oracle and assurance/capacity documents below.

Selected reviewer: **GPT-6 Astra / Extra High**, as assigned by the lead.
Runtime confirmation, token usage and monetary cost are unavailable. Inspection
began **01:22:57 UTC** and reached the completed evidence checkpoint at
**01:26:42 UTC**, **225 seconds** at one-second resolution, excluding report
preparation and commit. Actual host: Linux 7.0.14 x86_64. The live subthread
harness goal was null. This is continuing owner-authorized #119 research, with
no Oracle, tool, configuration or production-admission change. CLI memory was
not updated; the lead owns integration, issue and publication bookkeeping.

## Accepted dispatch and converter conclusions

The 55 retained Why registration snippets use their own constructors and
re-raise unmatched input. I inspected their match branches and the retained
alias inventory. They reject the named ordinary primitive family without
calling a logical term/declaration printer. This is a scoped constructor-identity
argument, not a claim that the save path can raise only those constructors.
`Pretty` and `Printer` have genuine logical payload branches; recursive wrapper
branches preserve the obligation to classify the inner exception.

`registered_exn_printer` tries callbacks with the original exception and swallows
ordinary callback failures. The private `Exit_loop` denotes success.
Why's Printexc callback calls this registry function, not the anomaly fallback,
so the documented second registry pass does not itself create an infinite
fallback cycle. OCaml's default scalar renderer does not traverse an arbitrary
payload as a Why term. Conversely, a matching callback can perform work before
failing; the packet correctly avoids inferring zero work from failure alone.

The installed executable and two plugins match the pinned identities. The
three v0.16.0 debug paths, exact upstream archives and targeted installed
startup/alias/flag/call evidence support the stated relevant-behavior relation.
Debug paths alone are not source-to-binary refinement. The packet explicitly
retains that limitation and its valid typed-heap, fixed-loaded-code and
no-unmodeled-foreign-mutation premises; this review adds no stronger identity
or whole-program proof claim.

The private converter table is keyed by extension-constructor identity. `add`
ignores `finalise`, and the public interface exposes no table/remove operation.
`find_auto` checks the automatic-printing flag before the indirect callback.
The installed ordinary iterator passes tagged false and the exceptional iterator
passes tagged true. The 24 events produce 23 keys: Pre_sexp's `Of_sexp_error`
is the same constructor as Sexplib0's and uses a different later callback.
Ephemeron insertion prepends and lookup selects the first matching live entry;
resize preserves order. The earlier binding is retained, not deleted, and the
argument conservatively retains its callback as well.

The six enabled latest keys and seventeen disabled keys agree with the source
and registration record. Every member of the named primitive family is absent
or disabled for automatic Printexc conversion. Direct `sexp_of_exn` queries can
still invoke disabled converters; the packet distinguishes those calls.

Enabled callback prefixes construct primitive/S-expression data, while the
Pre_sexp helper and Parsexp `user_exn` conversion have real nested-exception
edges. Those delegates can return to Why's logical printers and remain open.
S-expression data traversal is not arbitrary user-callback invocation, but this
does not bound its allocation, recursion or possible failures.

The preservation argument follows the public API aliases and actual source
clients, including generated exception converters. The retained 64 Why deriving
declarations are ordinary types. `Exn_magic` really exposes arbitrary-converter
adapters, but its installed initializer only publishes closures; it does not
call those adapters. The inspected fixed source clients and reconciled module/
closure accesses support their dormancy in this prefix. The raw reference
census remains corroboration rather than an indirect-call proof. Optional
Sexplib_unix source is not mistaken for a linked initializer, and the fixed
plugins add no registration client. These qualifications are essential to
acceptance of the bounded family claim.

## What the existing assurance boundary permits

The governing distinction is between a representation obligation and an
execution whose external premises fail:

- The [Oracle](../../oracle.md) requires complete automatic Bronze/Silver
  discharge for admitted source, all permitted paths/compositions, and no
  obligation suppression or reclassification of failure as nonmembership.
- The [trusted dependency table](../trusted-boundary.md#trusted-computing-base),
  particularly GNATprove and OS/runtime rows, retains complete generation/proof
  and adequate-resource/functioning-service premises. Its compiler import
  discussion at lines 227–235 says external process completion and successful
  allocation are infrastructure conditions and external exceptions may terminate
  outside the ordinary diagnostic path.
- [Automatic completion](../assurance.md#automatic-completion-and-the-external-boundary)
  requires completed matching tools, sufficient resources and successful
  infrastructure I/O. Detected infrastructure or verification failure prevents
  publication; it is not successful proof.
- The capacity contract's
  [required conclusion](../research/retained-tool-capacity.md#inputs-and-required-conclusion)
  explicitly requires every reachable representation/intermediate to fit on
  the selected build and assurance-essential production paths under its premises.
  Physical resource exhaustion is separate. Its
  [producer-limit rule](../research/retained-tool-capacity.md#producer-limits-and-correspondence)
  forbids waiving an essential limit as optional confirmation.

The explicit signal/interruption exclusion at `trusted-boundary.md:514–526`
and `assurance.md:433–442` concerns application-output/completed-reply semantics.
It does not supply a compiler-wide invariant that no OCaml signal callback runs.
Nor does eventual process completion imply the absence of a prior caught
exception. The author's separately requested applicability assessment was
reported by the lead after this independent boundary inspection; the conclusions
agree. No new environmental restriction is adopted here.

| Case | Conclusion for the current work |
| --- | --- |
| Actual external cancellation, unsuccessful infrastructure I/O or physical exhaustion causing an incomplete/failed proof execution | No successful-proof claim follows. Such a trace need not establish the conditional completed-pipeline theorem. Failure must remain failure, with no membership or obligation waiver. This does not retroactively close the broader retained callback lemma. |
| Asynchronous signal whose save/exit work raises into an interrupted catch | No blanket exclusion follows from the existing premises. Determine the actual outcome and continuation; the first continuing-invocation target remains open. |
| Normal scheduler completion and synchronous `at_exit` | Required selected-path work unless a separate nonessentiality argument is established. Neither is eliminated by excluding a terminated signal execution. |
| Representation-origin failure | Remains a #119 capacity obligation even when its exception constructor is also used for environmental failures. Assuming successful completion cannot be used circularly to waive that limit. |
| Internally reachable caught exception followed by proof work | Its work and state effects must be covered, or its reachability under the selected premises must be excluded. A catch or warning alone does not establish terminal failure. |

A concrete representation example is matching OCaml `Buffer.resize`
(`stdlib/buffer.ml:77–87`): it raises `Failure "Buffer.add: cannot grow buffer"`
when the requested extent exceeds `Sys.max_string_length`, separately from
`Bytes.create` allocation. Thus even a primitive-family rejection lemma says
nothing about whether its originating failure is environmental or a finite
representation obstruction. This is an illustration of the required distinction,
not an observed overflow in the retained instance.

## Source routes and the precise next obligation

Normal `gnat_main.ml:271–279` calls `C.save_session` before iterating and printing
result messages. `gnat_scheduler.ml:18–26` invokes that ending function after
its loop. Session saving is therefore not established as reporting-only: a
failure can prevent the normal evidence emission on this route even if solver
work has already completed. Normal `Stdlib.exit` also runs the exit chain before
`sys_exit` (`stdlib.ml:554–570`). The accepted once-only gates and formatter
repair remain useful, but they do not eliminate synchronous exit work.

Only SIGINT installs `save_session_and_exit` at `gnat_main.ml:335`; SIGHUP and
SIGTERM are ignored inside it, not additional registrations of that callback.
The save call at line 308 is outside the small signal-setting exception block
and precedes `exit signum`. An escaping save exception can therefore avoid that
exit. `controller_itp.ml:439–440,529–534` has continuing `InternalFailure`
callbacks, and `gnat_main.ml:110–114` formats the exception into a warning and
returns. Local lookup catches can also consume a compatible exception.
These source routes do not prove a particular post-registration escape occurs;
the withdrawn missing-task witness remains withdrawn.

The next bounded obligation is an **outcome and effect partition for the actual
save/exit helper graph at eligible points of the first continuing invocation**.
For each surviving escape, identify its source condition and whether it is a
representation condition, a genuinely failed environmental premise, or an
internally reachable exceptional outcome. For the latter paths, identify the
receiving catch/termination and prove the identifier charge and preservation
of the charged session/term/formatter/callback state through any continuation.
The normal save route and synchronous exit hooks need the same relevant helper
closure. Existing primitive rejection and converter-family results can be
reused; an inventory of unrelated exception constructors is not the deliverable.

A branch may be excluded from the conditional production theorem when its failed
external premise or nonessentiality is actually established. That is not a
permission to silently narrow the existing broader continuing-invocation target.
A separate healthy/uninterrupted lemma would need an explicit scope and a proven
applicability relation before it could replace any #119 obligation. No such
relation or no-signal premise is established by these packets.

## Evidence and disposition

Retained successful checks are reused: exception prefix **40 excerpts, 22 bodies,
5,619 bytes**, final check **1.2073443560002488 seconds**; Sexplib prefix
**26 excerpts, 50 bodies, four windows, 20,509 bytes and 39 closures**, final
check **1.3069440080034838 seconds**. Neither checker was rerun.

Independent input checks matched eight unique dependency records, sixteen local
records and the executable/two plugin identities in **1.237283506001404 seconds**.
A focused **38-check** diagnostic passed in **0.15322525300143752 seconds**.
Using a separate ELF load-segment reader, it compared four selected retained
bodies (**368 bytes**), selected startup/alias instructions, four direct call
edges, the indirect call and the two flag values; it checked eleven named source
identities, registration shadowing/counts, unchanged exception-packet files and
open result flags. It did not generate disassembly or reconstruct the census.
Additional boundary/source reads include the normal scheduler ending and Buffer
representation failure. Exact source identities and scratch results remain in
this worktree's `tmp`.

No native execution, capture, debugger, disassembler, compiler/prover/solver,
broad audit/build, predecessor/checker replay, GitHub write or delegation ran.
**Disposition: accept the bounded dispatch and converter-prefix progress.**
`B_binders = 966`, exceptional charge null, complete `R` null, and the conditional
`counter_end <= 63,573 + 2R` interface remain unchanged. There is no established
63,573 endpoint, counterexample, complete callback capacity or #119 completion.
The next required work is the scoped outcome/effect partition above; production
#88–#94, Oracle amendments and tool changes remain outside this review.
