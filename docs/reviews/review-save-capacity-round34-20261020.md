# Review: selected save capacity, Round 34

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153.

The two author components pass independent review in their stated conditional
scopes. The I/O packet passes this reviewer's integration consistency check and
a separate independent review of the disclosed reviewer-contributed lemma.
Exact aggregate reconciliation also passes. No blocking finding remains for
these scoped Round 34 results.
The full #119 objective remains active and unfinished; component completion
cannot substitute for its remaining work.

The isolated reviewer branch starts at published
`79301d13cfac0dafccf9e53b5da17345266d4eca`. Only this report is reviewer-owned.
The reviewed lanes are interrupted preparation/restore-table writer growth and
arithmetic, direct formatter allocation aggregation, and selected write/lseek
service attachment, followed by one exact aggregate.

| Component | Exact reviewed freeze | Disposition |
| --- | --- | --- |
| Writer/preparation | `f96c61a564a208d47eff04d8b4ffac17cd07b0c1` | Accepted conditional episode and writer interfaces; actual W/F null |
| Formatter allocation | `f00b6bb6b8c1a83c59b98641496f6fb300860083` | Accepted complete scoped direct-request accounting under named premises |
| I/O services | `78c6dd3f1d8a21f843e9747bd247acd4d2736b3f` | Integration consistency; successful initial lseek unnecessary for capacity; positive-write attachment absent |

Selected reviewer: GPT-6 Astra / Extra High, inherited from the parent-selected
review assignment. Runtime setting introspection and token/cost attribution are
unavailable. Review started at 12:11:16 UTC. The child live goal is null; the
parent owns the active full objective. AGENTS.md and relevant Oracle/trusted
boundary requirements were reread. Round 33 successful checks are retained,
not replayed. No reviewer native run, capture, disassembly, source fetch,
solver/proof/full-suite run, GitHub write or subdelegation is authorized or
performed.

## Early service question and contribution disclosure

The existing OS/libc/runtime boundary documents stable files, functioning
services and sufficient resources. It does not itself specify positive return
for every nonempty raw write. The earlier native materializer explicitly rejects
zero (`retained-literal-native-materialization.md`, bounded copying section),
so its accepted arithmetic does not supply the missing guarantee for OCaml's
Putch, which lacks that check in the selected release body.

A valid full output buffer, followed by a nonempty write returning zero and
then Putch's immediate append, violates the buffer extent. Eventual later
service progress does not repair that prefix. This is a countermodel to the
weaker return-count/eventual-progress interface, not a claim of an observed
host execution or a normative POSIX counterexample. The runtime comment that
flush makes room and the assertion compiled out of the retained native body
express an expectation; they do not independently attach its OS precondition.

A documented normative guarantee for the selected imported regular-file write
interface, with its file-kind/flags preconditions attached, could establish
the needed fact within the approved external boundary; a new kernel proof is
not inherently required. Broadly renaming the premise normal service cannot
establish a property absent from the supplied interface. The lead reports a
virtiofs host mount, so the Linux label cannot stand in for an ext4/backend
implementation identity. The final packet preserves the unattached positive-write
frontier.

**Reviewer contribution:** the reviewer proposed the cached-offset bias lemma
and checked its selected client/field-use scope. This derivation is therefore
not independently reviewed by its proposer. The lead authored the service
packet. The separate [independent bias review](review-save-offset-bias-20261020.md),
commit `140ed6fdca916b58a3fb56e2252c96ca5ac3220d`, accepts the exact root freeze.
That reviewer, `/root/save_path_bound_round31_20261020`, was selected as GPT-6
Astra / Extra High and neither originated nor implemented this remedy.
The independent check took 124 seconds through conclusion and read the source,
packet and inherited interface without checker/native/fetch replay. This report
read that acceptance and keeps its own contribution and consistency check
distinct from it.

For the fresh description let F count actual committed bytes, P pending bytes,
and delta be the initial cached lseek result, either -1 or zero under the
ordinary faithful return contract. Selected output maintains cached O=F+delta
and F+P≤A≤X. Hence -1≤O≤X and each cached addition stays signed-64-bit even
when initial lseek fails. This avoids requiring successful lseek merely for
representation capacity; it does not establish general position-query or seek
semantics. Existing positive-write, pending-flush and private-lifetime conditions
remain necessary where used.

Retained OCaml source witnesses are `io.c` 94–124 (initialization), 185–202
(selected cached addition), 214–263 (char/string writers), 445–480 (finalizer),
540–561 (global channel iteration), 571–595 (close), 660–670 and 690–738
(flush/output wrappers); Stdlib 330–356, 358–379, 388–395; and Format 990–1007.
The excluded offset consumers are `io.c` 148–170 (size), 266–280 (seek/position)
and input routes 375–395 and their readers. The selected Why roots are
`session_itp.ml` 2118–2121, 2172–2209, 2236–2244, `termcode.ml` 587–590 and
`compress_none.ml` 12, 42–44. The accepted private-client closure remains a premise,
not a new unrestricted alias theorem. Native initialization at 0x9ce659/0x9ce65e
and addition at 0x9ce963 are already retained by Round 33.

## Root service packet

Root freeze: `78c6dd3f1d8a21f843e9747bd247acd4d2736b3f`,
`docs/research/retained-why-save-io-services.md` and its 20261020 packet.
The new focused checker passed once after freeze: six source witnesses,
20 descriptor/initial-outcome cases and 54 positive-prefix boundary challenges,
in 0.211373 seconds. The two lead-fetched official standards downloads and
short excerpts matched their retained identities in a separate read-only check.
The reviewer fetched no source. The first packet wait was 12:16:52–12:17:17,
25 seconds.

The integrated proof distinguishes actual committed F from cached O and removes
successful initial lseek from the representation requirement. The source
client exclusions and native-byte dependencies match the proposed lemma.
No integration inconsistency was found. This result is a source/client and
arithmetic consistency assessment; because of the disclosed contribution,
it is not an independent review of the bias derivation itself. The positive-write
attachment remains false, unconditional selected-file bounds remain null, and
complete save/pipeline flags remain false.

## Caller capacity versus the trusted service boundary

The existing external boundary permits faithful allocator/GC/OS behavior on
valid represented requests, preservation of roots and objects across collection,
ordinary service return/raise semantics and sufficient environmental resources.
It does not require verification of the entire collector, libc allocator or
kernel. A generic label such as runtime capacity must not silently enlarge
this research into such a requirement.

Concrete caller obligations remain: per-object extents, headers/layout and
arithmetic before an imported request; selected request multiplicity and
simultaneous object/direct-stack demand; tool-owned mutation/counter invariants;
selected callback/reentry and abandoned-prefix counts; and the specified
failure outcomes and receiving catches. Any exposed runtime operation used
by the argument needs its applicable interface preconditions and semantics,
not an automatic source proof of all its internals. Additional internal work
needs an owner only when a specific capacity limitation or required behavior
is not already covered by the documented trusted interface.

Sufficient resources cannot repair representation overflow, invalid requests,
unbounded selected reentry or an undocumented progress property. Conversely,
normal allocator/GC correctness need not remain an unclosed universal proof
obligation once the named request and lifetime conditions are established.
Cumulative requested bytes can conservatively upper-bound caller retention;
they are neither a measurement of available memory nor a native stack bound.
The packet dispositions name their remaining caller charges rather than claim
either whole-runtime verification or closure by fiat.

## Writer/preparation review

The source scheduling argument supports E<=3G+e preparation episodes, with
one process-wide e<=2 budget, including Input_Is_Valid's active first episode.
The essential facts are removal before scheduling, one queue pop/build/prepare,
only nonvalid Done requeueing, stored results before the GNAT callback, and
removal of a completed prover call before its Done notification. A repeated
completed pair needs a consumed Not_found at the selected whole-query catch.
Configured graft limits are distinct from adapted queued execution limits;
the source preserves the former for future completed-pair tests. The five
episode bounds 194/161/98/11/5 sum to 469 across separate processes.

The selected algebraic comp is a nonrecursive shadowing definition: calls in
its deferred map and fallback branch refer to the prior Task-only comp.
Its direct tuple branch has at most one tuple constructor per visited chain
occurrence. That constructor publishes at most the type head, constructor
head and closing theory; all projection entries are None. The two literal
library roots occur at most once each per episode, but their expanded parser,
clone, generated declaration and implicit tuple charges are still absent.
Thus E*(3D+2C_lib) is a conditional W interface, not an attached actual bound.

The lead found a pre-freeze attachment gap: initial topology cells alone did
not establish the initial scalar size used by the writer transfer. The author
corrected it with a minimal scalar projection from the five retained members,
verified against the accepted member identities, and a separate initial_size
parameter. The corrected code and result attach 6941/6941/6901/6783/6819
as the actual scalar sizes, each equal to the captured cell count. The exact
maximum W values allowed by this conservative size guard are
2,147,480,177/2,147,480,177/2,147,480,197/2,147,480,256/2,147,480,238;
their maximum-plus-one checks fail as intended. These are input thresholds,
not actual publication counts.

The existing representation ceiling D=floor(2^64/56) cannot make the displayed
W-based scalar guard pass, even at C_lib=0. This is evidence that the current
bound is too loose, not evidence of actual overflow or a theorem that one
particular work order is impossible. No retained initial/raw/inline chain count
is yet attached across all selected transforms. A narrower useful next charge
is tuple-Ddata occurrences reaching the single algebraic fold, together with
expanded fixed-library publication counts. These are now concrete save
dependencies and belong in the next named full-#119 work package.

The alternative size-discrepancy interface can establish the scalar guard
independently of lifetime W if the caller's abandoned count-changing mutations
F are bounded by five. Its one-active-prefix allowance is conservative under
the private nonreentrant writer relation: clean's unpublished decrements occur
within one current bucket; resize omits at most the old table's cells; prepend
can precede its increment by one. Completed mutations preserve the existing
size-minus-current-cell discrepancy. F<=2 cannot be obtained merely by naming
the signal budget when nonsignal failure continuations remain in scope.
Useful finite W remains necessary for the present allocation and recursive
frame charges even if a separate F argument closes the scalar counter.

The new focused checker passed once after freeze in 2.714608 seconds: 35
source excerpts, five status/domain joins and scalar attachments, 738 finite
scheduling challenge states, and 2,520 drift-boundary challenges. The finite
models test the supplied interfaces; they do not replace the source induction.
Native runs and predecessor replays were zero. The author worktree stayed clean.

## Formatter direct-allocation review

The direct allocation partition was checked against the retained Format,
Buffer, Queue, Stack, CamlinternalFormat, Why printers and channel sources,
and the relevant retained native bodies. It covers fixed formatter objects,
dynamic queue/token/scan/format objects, Stack/Queue options, replaced
sentinels, flush closures, normal scalar temporaries, all geometrically
reachable Buffer backings and final contents, selected caller-local blocks,
restored concatenations, path copies, channel wrappers and lazy mutexes.

The seven dynamic classes total 640I for I=3E+1 per stream. set_size is
nonrecursive and takes at most one top/pop; closing consumes an earlier open;
advance_left removes each queued token at most once and has at most one
non-removing final peek per entry. These source facts support the cumulative
option/reset allowances. Factory system and sentinel objects are charged to
the dynamic classes, apart from the fixed 640-byte factory envelope. The
normal selected percent-g route allocates the unconditional 48-byte conversion
closure and bounded format-buffer/strings; the separate 40-byte native branch
belongs to the unselected Float_F dot-fixing route. Buffer.resize's native
reference is not a heap object; its visible 24-byte sites construct assertion
exceptions on excluded invalid-invariant paths.

Pre-output scalar requests retain prospective event slots. Shape text events
are bounded by the per-string extent because every integer or H separator is
nonempty; this does not infer whole allocation counts from output bytes.
Geometric Buffer charging includes initial and superseded backings, and the
private-frame premise excludes resuming an abandoned resize. Global r=3 is
applied once over all normal, nested and abandoned save entries.

The draft initially included 80 bytes of save_session local closures while
its ownership prose/table excluded that preliminary route. The author removed
that subtotal before freeze and clarified the ownership. This preserves the
stated formatter scope; those closures remain with the preliminary traversal.
The three native structural pair/list/prover-tuple groups and all map/sort
results remain explicit external owners.

The frozen result's interval totals, in Put_Line/Put/First_Or_Default/Is_Message/
Input_Is_Valid order, are 95,095,382,112; 72,677,794,467; 28,512,934,719;
3,753,840,753; and 4,515,574,341 bytes. These count cumulative direct requests
with no reclamation credit and all global r=3 entries. They bound the retained
representations of the named caller objects, not physical heap reservations,
GC-copy duplicates, native stack or external owners. Default exports remain
null; complete direct accounting is available only under all five named
premises and per-object guards. Whole formatter/save/pipeline flags remain
false.

The new focused checker passed once after freeze in 0.550 seconds: four
generated JSON comparisons, 27 source excerpts, 85 retained native bodies /
15,600 instruction bytes, and five case compositions. The imported source,
executable and retained byte identities matched. The selected allocation-site
constants and independent Buffer/guard challenges passed. Native execution,
disassembly and predecessor replays were zero; the author worktree stayed clean.

## Exact integration and remaining obligations

Semantic aggregate: `6fb9dd82d13b0e9d99eb73d87413bdbe28b7fc29`.
Reconciliation commit: `d7f78a18e886a90c6298f0697586da4bff5bc51c`.
The isolated reviewer worktree was fast-forwarded to this aggregate with only
this report retained as an untracked owned file. The new identity reconciliation
passed once in 0.254575 seconds: 28 exact author files, all 94 unchanged retained
native pins, six Python parses and 19 local links. No component checker was
replayed at integration. This compares identities and interfaces; it does not
turn conditional components into a complete save envelope.

The remaining caller obligations include useful post-preparation tuple-Ddata
and expanded library publication counts; the other writer/getter objects and
mutations; structural save maps/lists/sorts and shape-production charges;
simultaneous retained objects across their distinct owners; whole selected
native stack; source-owned signal/error/exit and service-failure continuations;
global channel wrappers/refcounts; and the selected positive-write attachment.
Each needs its own applicable request/lifetime/continuation proof or a precisely
attached trusted interface. The absent physical-memory measurement is not an
instruction to verify an entire collector or kernel.

The next preparation/publication work package is supported by this review.
It should target the two specific missing inputs T_prepared and C_lib, then
feed a useful W into #153. It need not assume every downstream driver capability
must be completed first, and it must preserve the possible F-only scalar route.
The root records that package as #155 under #119 and owns issue/milestone
dependency bookkeeping and further authorization. This reviewer did not modify
GitHub. The final reviewer base includes the separate bias review at
`4a490758c0400ddaa259ce56b90c401f2f30406a`; its integration changes only that
review file after the checked semantic aggregate, so no component replay was
needed.
Full #119 and #153 remain unfinished, production #88–#94 remains unstarted,
PR #121 remains draft/unmerged, and Oracle, admission and installed tools/pins
are unchanged. CLI memory was not updated by this reviewer.

## Review effort and handoff

Review ran from 12:11:16 through the 12:32:45 UTC conclusion checkpoint,
1,289 seconds including packet waits, source/native reading, derivation,
correspondence checks, discussion and report drafting; final report checks and
commit follow. Selected reviewer model/effort remained GPT-6 Astra / Extra High.
There was no escalation or subdelegation. Runtime model introspection and
token/cost attribution were unavailable.

Recorded packet waits were 25, 74, 22 and 38 seconds (159 seconds total).
A separate 183-second draft-wait interval included substantive trusted-boundary
classification and is not counted as pure waiting. These observations do not
measure total active model time. Reviewer checker times were 0.211373 seconds
for I/O, 0.550 for allocation, 2.714608 for writers and 0.254575 for the aggregate.
Each new focused checker ran once after its freeze; successful predecessor
checks were retained. No expensive identical-success rerun occurred.

This round closes the episode-count and complete scoped direct-allocation
obligations, removes unnecessary successful-lseek capacity attachment, and makes
the next quantitative publication dependency precise. Review found and checked
the corrected initial-size attachment and caller-local scope reconciliation.
No source/pin/Oracle/admission change or whole-goal completion is asserted.
The parent receives this report for integration/publication and owns the active
goal, roadmap, issue state and durable-memory handoff.
