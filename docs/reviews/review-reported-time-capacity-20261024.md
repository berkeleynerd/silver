# Review: reported-time source and configuration provider

2026-10-24 UTC. **Accept the bounded #206 symbolic provider at
`fd19cd4c3c4847795b04a2a194bf49ce52eacfc5`, including the completed #210
count-interface repair.** No remaining scoped correctness finding was found.
This completes the source/configuration, allocation-interface and cut-C
extension review; it does not adopt a production configuration or complete
#119, #201 or #202.

Selected independent reviewer: **GPT-6 Astra / Extra High**. Runtime model
and effort confirmation, token usage and monetary cost are unavailable.
The initial source freeze was `ae33d531d9259c1ee8896a475b78742d51922917`.
The intermediate #210 repair at `ea0896d220c6c67cc6f9c25696542ac5057efcb9`
is superseded by the accepted freeze above. The reviewer changed only the
review report and its [evidence directory](../evidence/review-reported-time-capacity-20261024/README.md),
in a separate worktree. Root handled the final bounded author repair.

Inputs were the [source argument](../research/retained-reported-time-capacity.md),
the complete [source/configuration packet](../evidence/retained-reported-time-capacity-20261024/README.md),
and its retained source/native witnesses. The accepted native/placeholder
provider at `6cc4c72f63`, reviewed at `35a5bea549`, and the entry provider at
`e45ee72a42d6cc669e95b80c2c991cbc65fe4e73`, reviewed at
`0116f0bee53911fc297d7b7ef62aa4ca23184733`, remain separate dependencies.
Their exact pinned files were read from `tmp/retained-tool-capacity`; their
proofs and checkers were not replayed. Native #208's corrected 214-word search
subtotal is within the unchanged 256-word export.

## Reported-time domain and configuration attachment

The seven-file recipe changes only private `slv-libv2.gen` line 23, from a
32-byte comment to a 33-byte line including LF. Each of the three new strings
decodes to the two bytes `5c3d`. The installed native provider establishes
Start semantics for these bytes; the reference source alone would not suffice.
All nine configured drivers are loaded, but the existing import graph reaches
the private common file once in each of the three selected roots. Separate
`Driver.add_global` calls construct nine distinct timing records and lazies.
The other configured roots and the selected solver limits remain unchanged.

The fixed placeholder search inside each `timeregexp` fails on the two input
bytes, so its replacement callback never runs and the timing-unit array is
empty. A successful Start search then makes `grep_time` return zero without
reading shared matched-group state. The protected search/option construction
can catch an escaping save exception, and an interrupted lazy can keep raising
on later calls. The accepted native isolation theorem permits that permanent
owner failure. Three independent owners per selected driver and the single
process-wide e<=2 allowance leave an untouched successful owner. A failure
outside that protected chain aborts parsing rather than silently producing a
raw-time result. Sufficient resources and the established callback/runtime
premises remain necessary; no new general exception exclusion is introduced.

I checked the complete retained `pr_time` occurrence inventory, the actual
constructors and the surrounding control routes. Ordinary nonempty-file
results use the existing floor `mu=0.000001`; both positive-limit
reclassification tests are false. The empty-filename route bypasses the timing
regexps, but the authentic Unix server's queued-removal sender supplies zero.
Other completions retain the nonempty temporary filename. Trivial results and
Checker statistics also contribute zero. Controller smoothing chooses the new
time or copies an old time; it constructs no third numeric value.

Freshness is the actual `init_cont` branch selecting `empty_session`. Merely
omitting replay would still allow `load_session` from an existing directory.
XML session loading, IDE result import, editor/manual, bisection, CE and
unselected prover routes are outside the selected automatic invocation.
Session creation, graft/reset, update and old-result transport preserve the
induction from an initially empty attempt table. Save callbacks serialize
state rather than import a new time. Consequently all reachable attempt times
are in `{0, mu}` under the stated recipe and premises.

The statistics and Ada report paths initialize from zero/an attempt and use
maxima. Decimal formatting, GNATCOLL's `Long_Float'Value` and the later Float
conversion preserve the deliberately widened interval `0..1`. This supplies
#194's sufficient Integer margin for the unconditional `Integer(PC.Max_Time)`
conversion without bounding actual prover duration. It does not normalize the
server's earlier wire time, debug/Stats clocks, log timestamps or calendar
fields. Their existing numeric and formatting premises remain separate.

Normalized times can change which already Valid prover receives credit and
the resulting max-step statistic. The accepted claim preserves per-attempt
identity/answer/status and the proof-success criterion, not identical credited
prover statistics or measured elapsed time. No failed or incomplete obligation
is converted to success.

## Startup allocation and entry extension

The imported common file is a segment of one multifile parser stream. Its EOF
is suppressed, and the parent stream resumes on the existing parser. Inserting
three located globals adds pending cells to the right-recursive global list.
The next old token sees the same relevant control state above those cells;
fixed-arity actions neither inspect nor traverse the deeper suffix. The root
EOF eventually adds the three extra list reductions. Existing list reductions
still allocate same-size records and conses. The argument therefore accounts
for both the deeper stack and the final unwind, without positing a fresh parser
per imported file or an uncharged tail rescan.

Later raw byte offsets increase by one, while filename, line and column keys
are preserved. This is not equality of complete lexer buffers or captured
heaps. The full candidate common-file overcharge covers changed refill
alignment. Its 412 tokens, 72 strings, maximum raw string length 121 and
depth-one comments support 16 reductions plus two shift/input credits per
token and boundary unit: 7,434 elementary passes per occurrence. I checked the
listed grammar families and the special `(*)` lexical rule.

The installed Menhir bodies use linked five-field stack cells. The retained
checkpoint loop returns a shift/reduction checkpoint and then starts another
charged pass; it does not execute an unbounded series of semantic reductions
inside one pass. Repeated packed-array and row lookup helpers allocate nothing.
One selected action, bounded dispatch/return wrappers, and the fixed external
location/operator helpers fit two traversals of the overinclusive 1,629-word
module-bump sum plus 128 words: 3,386 below the 4,096-word pass credit. The
native bodies and source call paths, not the bump sum alone, justify this bound.

The successful-startup delta is **91,752,681 minor words**, including headers,
discarded intermediates, three complete common-file parses, nine separately
charged placeholder operations, caller/list wrappers and nine unforced Start
shells. The placeholder provider is distinct from the final Start provider.
All added individual payloads are at most 256 words. Before a hypothetical
first collection, the added lexer/parser/driver/regexp owners are young;
the shared placeholder-result store writes immediate None. No new FileTags
name, open, custom block, ephemeron, dependent allocation, foreign buffer or
resource-fraction request is introduced. Unchanged existing channel/open
effects retain their old owners; they are not discarded from accounting.

The largest minor history becomes **227,274,405 words**, below `2^28` by
41,161,051 words. Major/history and reference/resource-table components remain
at their accepted baseline bounds. The individual-small-request argument and
these strict margins jointly exclude the first extra collection; young-owner
classification is not assumed after one. The existing sufficient physical
stack premise includes the fixed new constructor chain. Tail parser dispatch,
depth-one comments and fixed two-/six-byte regexp inputs introduce no new
Main/output-dependent native recursion. No numeric whole-process stack or RSS
fit is claimed.

The new cut-C extension consumes the exact accepted baseline envelope and the
new configuration fingerprint. It recomputes all five layouts' counter,
backing and scalar bounds, while preserving the populated-state interpretation,
Introduction's separate empty owner and the single global callback/save budget.
Its largest managed/static carrier is **237,953,393 words**. This is a monotone
addition to the source-derived entry history, not endpoint subtraction or
relabeling the old empty timing-list state.

Interrupted startup construction is charged as a prefix. The no-collection
successful-prefix conclusion is not extended to terminal diagnostic/exit work;
those existing runtime/collector providers must consume the enlarged carrier.
This preserves the existing failure boundary without creating another save or
exception allowance.

## #210: count source allocations at entry, repaired

The initial later-allocation interface charged a possible seven-word smoothing
copy only per ordinary nonempty-file result. `timeout_handler` also smooths
empty-filename queued cancellations. The argument supplied neither absence of
an old result nor a separate count charge for that route. This was a material
provider-count gap, not a demonstrated production failure or a failure of the
startup arithmetic.

The first repair counted all `ProverFinished` deliveries, covering cancellation
copies, but used that same count to bound searches. That boundary was still too
late: `handle_answer` parses a server `Finished` record before constructing
`ProverFinished`, and `wait_for_server_result` maps a whole batch before
buffering it. Searches can allocate in a parse or batch that is subsequently
abandoned without delivering a result.

The final repair defines two independent entry counts. `p` counts entry to
authentic Finished-result parsing, including abandoned/interrupted calls;
`f` counts entry to the controller's ProverFinished arm before smoothing,
including cancellation and an arm interrupted before `Done`. Each parse entry
attempts at most three searches, so `q<=3p`; each controller-arm entry can
allocate at most one seven-word copy. No relation between p and f is assumed.
The accepted extra post-C constructor interface is therefore

```
512*o + 266*q + 7*f words, with o<=9 and q<=3p.
```

The 266 combines the accepted 256-word attempted native search and the actual
ten-word grep wrapper. The 512 first-force credit is separate from the Start
shells already charged at startup. Cached lazy failures count as attempted
searches without spending a new event. The cancellation-only and abandoned-parse
coefficient checks produce 7 and 798 words respectively. #210's two count
boundaries are repaired and independently accepted at the final freeze.

Later promoted-owner writes, GC copying, runtime/backtrace/stack services and
the retained raw input still belong to their existing general providers.
Shared Str.state can keep the entire raw output alive despite a zero-length
match. Startup's zero extra remembered-entry result does not apply to these
later stores. The repaired interface bounds the new constructors, not all
post-C storage or native work.

## Audit, completion and remaining integration

One [independent final audit](../evidence/review-reported-time-capacity-20261024/audit.py)
passed in **1.234037 seconds** on Linux x86_64. Its
[receipt](../evidence/review-reported-time-capacity-20261024/result.json) binds
39 frozen author files, 35 fixed inputs, three source archives, 20 complete
members and 49 spans, the nine-entry time assignment census, six new parser
module attachments and eight caller wrappers. Independent configuration and
lexical checks, startup arithmetic, all five entry envelopes, six later-count
cases and seven invalid-interface controls passed. The repair left the startup
fields and entry-extension/baseline/recipe/result bytes unchanged.

No author checker, predecessor checker, native target, compiler, prover,
solver, Lean, capture or disassembler was run by this reviewer. Retained raw
objdump text is exact hash-bound tool output. These checks corroborate the
identities and arithmetic; they do not machine-prove the source/control argument
or recreate accepted native evidence. No macOS validation is claimed.

Recorded review intervals were 04:05:05–04:09:57 UTC (292 seconds) and
04:15:24–04:20:24.581266 UTC (300.581266 seconds through the final audit).
The intervening interval released the reviewer slot for repair. These are
partial wall-clock intervals, including reading, coordination and repair waits;
initial worktree creation and final report/commit preparation are outside them.
No exclusive CPU-time or total team-cost measurement is inferred.

The reviewed result completes **#206's bounded symbolic reported-time provider**:
the exact supported prospective recipe, time-origin/consumer induction,
successful-startup resource delta, later constructor interface including
abandoned prefixes, and executable extension of the accepted cut-C entry
provider. Root owns integration and issue disposition. Remaining work has these
distinct scopes:

- Parent research must integrate this freeze and review, attach `Max_Time<=1`
  to #194, and use the new configuration identity and enlarged cut-C envelope
  wherever #201/#202 previously consumed the timeless baseline. Later demand
  must supply actual bounds for p, f and q, consume the promoted-owner mutation
  and raw-input lifetimes, and retain collector/native/terminal-failure owners.
  No whole-process #119 resource bound follows solely from this provider.
- Future **#88 actual refinement** must materialize and select the exact seven
  supported files under the retained path/import/discovery relation; establish
  the fresh-session, non-replay, noninteractive, CE-off invocation and unchanged
  zero solver limits; and preserve the nine-owner loading/selection bound.
  A reload, different selection, path relation or configuration requires a new
  attachment. This review installs none of that production behavior.
- That refinement must consume the extended entry and later-demand interfaces,
  preserve attempt identity/status and complete obligation evidence, and expose
  normalized timing metadata honestly. It cannot present these values as
  measured proof time or physical-resource attribution, assume identical
  credited prover/max-step statistics, or introduce a finite proof timeout.
  The existing source correspondence, physical resources and one process-wide
  e<=2/two-callback/three-save premises remain in force.

Production #88–#94, admission, Oracle and installed tools remain unchanged.
No GitHub or CLI memory write was made by this reviewer.
