# Review: selected save capacity, Round 31

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153.

**Accept the four bounded components at their stated conditional scope. No
blocker, medium or material low finding remains.** The normal-decimal-service
clarification identified below is fixed. This does not establish actual
restored-path R/U, complete save capacity or #119/#153 completion.

## Exact inputs and scope

The isolated review worktree starts at
`6cd72b0711d18a25ccdd6ee45b76af101a9c4119` and is fast-forwarded through
`79c4acdd3294a60bd9be8e183ade64276e8239b2` to the author aggregate
`573155d43811a9e86c95fd50a512a90ceafe00c8`, then to the exact final review
target `97914a071c01087cc6738ed318ac4e048e8a8cc7`.
Only this report is reviewer-authored.

| Component | Author origin | Integration input |
| --- | --- | --- |
| Formatter ownership and locale lifetime | `d27fb7abfefafda709b047f410751269f5f99e5f` | Same commit |
| Shared/private table and attempt-counter attachment | `9c3638a4ff78538cb8139321e3411f0992bc9984` | `6cd72b0711d18a25ccdd6ee45b76af101a9c4119` |
| Retained restored-path input inventory | `d35f7809e5366bbdb4012315de00d7089130233b` | `79c4acdd3294a60bd9be8e183ade64276e8239b2` |
| Qualified path payload bounds | `b6fd7adbe8a40b2c4dc62b17254454853531c61b` | `573155d43811a9e86c95fd50a512a90ceafe00c8` |
| Normal decimal-service scope clarification | Lead-authored in response to this review | `97914a071c01087cc6738ed318ac4e048e8a8cc7` |

Inputs include the corresponding `retained-why-save-formatter-ownership.md`,
`retained-why-save-table-contract-join.md`,
`retained-why-path-input-inventory.md` and `retained-why-path-payload-bound.md`
research notes and complete `docs/evidence/*-20261020/` packets:
retained source/native excerpts, input
identities, attachment/checker code and exported results. Source archives and
the identified installed ELF were read as data. The selected executable
SHA-256 remains
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
source revisions are Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`
and OCaml `8eb41f72ded84df884c3671734c947f612091f84`.

AGENTS.md, the Oracle and applicable review/reporting rules were read.
Accepted Format-core/scalar, growth, counter, state/native-prefix and
theory-control results are reused at their recorded premises. The source/native
behavior relation in `retained-tool-source-identity.md` remains an external
premise, not recovered historical build identity or a binary refinement theorem.
The native-effect result's first-fold/serial-save scope does not establish all
later preparation/result clients. Whole post-cut frame preservation, callback
ownership and the single signal budget are explicitly imported over that
larger interval; they are not newly proved native capacity.

The child harness returned no live goal. The parent confirms that the owner’s
full #119 goal remains active and unfinished and retains integration,
issue/memory/publication ownership. No new goal was created by this reviewer.

## Formatter ownership and locale lifetime

The selected formatter is fresh and local to `Session_itp.save`. The save
context carries the prover map and shapes channel but no formatter. Its
partially applied printers are used by synchronous map/table/list traversals;
`Acc_delay` invokes printers synchronously and the Format queue stores tokens,
not deferred printer closures. The formatter's own default output closures may
refer to it, but there is no outward publication to session state, callbacks
or a global formatter setter. Sharing a channel does not provide a reverse
alias to this private Format queue/stack state.

The receiving-catch challenge passes. `save_ident`'s fallback covers restore,
list testing and concatenation before its `fprintf`. The private prover helper
catches do not capture this formatter. The retained `format.ml`, Queue and
Stack implementations have no selected handler that resumes an escaping
partial core mutation. CamlinternalFormat's fixed box-description integer
parser catches `Failure` only after `compute_tag` has flushed its separate
private formatter; a failure in the handler propagates. Runtime parsing of
arbitrary format strings is not part of the selected constant-format route.
Thus a partial core operation that escapes abandons that private state under
the faithful runtime/frame premise. A caught exception between two completed
core operations is a different case and may continue serialization safely at
this structural scope. This does not assert that every output call succeeds.

The installed startup and shutdown order agrees with the retained source:
`caml_init_locale` precedes GC/signal setup and application startup;
`newlocale(LC_NUMERIC_MASK,"C",0)` supplies the object only on success;
shutdown callbacks and heap finalizers precede `caml_free_locale`. The selected
standalone route reaches shutdown from terminal `caml_do_exit`, then terminates
signals and exits. Its `caml_callback_exn` calls do not allow an ordinary OCaml
exception to resume the application after freeing the locale. This reasoning
does not apply to an embedding that shuts down and then reuses OCaml.

The runtime does not test the `newlocale` result for null. Successful creation,
selection and numerical/allocation service behavior are therefore explicit
conditions, not captured observations. `caml_format_float` selects C before
formatting, and a successful nested conversion restores C to the outer one.
An exception that skips restoration leaves C selected; it does not itself
introduce a wider separator. No selected source path frees or replaces the
object while an application save can resume.

Under those conditions, the accepted integer/binary64/GNU conversion argument
supplies normal `d=20`. Missing behavior or service premises leave the usable
attachment null; `runtime_service_success_observed` stays false even with all
conditions supplied. A failed locale service, negative printf return,
allocation failure or unclassified pending client is outside the normal result.
The unsigned long branch on a negative printf return retains its separate
error/capacity obligation. No finite representation bound is inferred merely
from sufficient physical memory.

## Tables and attempt counters

The packet attaches 203 accepted no-resize applications and uses the accepted
selected theory-control result for exactly the three failed theory guards.
All 206 rows preserve their distinct captured entry size, capacity and visit
inputs. The three replacements have visits 99/99/89, scalar sizes 51/51/46
and capacity 32. The proof does not assume key preservation through an
abandoned theory resize: its selected continuation excludes the later repair
traversal that would permit the shared-input second-rehash countermodel.

The key/payload argument selects integer/tag and immutable three-string prover
keys. The source hash's weighted sum is at most `10*(2^30-1)`, within the
native integer range. The accepted mutation inventory and simultaneous
key-preservation/no-first-resize induction supply structural prefix traversal
bounds. A failed lookup is still bounded; a callback's success or whole-client
cost is not inferred from a structural row. The exported legacy whole-client
flag remains false. Per-invocation visits do not bound a potentially repeated
number of invocations.

The new counter witness includes the actual inline implementation, not only
the standalone generator. At `0x7f285b` it loads the old counter, at
`0x7f2862` adds tagged two, and at `0x7f2866` stores the successor. There is
no allocation, poll or call between that load and store. The first following
allocation check is at `0x7f286f–0x7f2876`; its GC continuation at `0x7f291e`
jumps to `0x7f287c`, so it cannot repeat the increment. Per-goal add at
`0x7f28dc` precedes global replace at `0x7f2902`. This matches the accepted
constructor receiving-catch/event argument and supports endpoints
209/174/109/13/10 under the supplied premises. The event count prevents the
first overflow without relying on ID uniqueness to derive that count.

The membership-to-global gap remains an adverse execution. A save can see a
published membership whose global record is absent; `get_proof_attempt_node`
turns that failed `Hint.find` into `BadID`. The result correctly exports
`successful_membership_to_global_lookup_at_every_prefix: false`. Structural
lookup bounds and the one abandoned-counter-prefix charge still apply. There
is no invented rollback, successful serialization or interrupted scheduler
entry bound.

Private helper ownership supports the additional table claims.
`PHprover.add` is in the handler of its find catch; each frequency replace is
outside the corresponding find/default catch. The traversal's cleanup handler
rethrows. Consequently an escaping mutation cannot be caught locally and
retried on these same private tables. Each new helper constructs new owners.
A completed private resize restores disjoint chains and tail cuts before later
client traversal. An interrupted resize starts from valid disjoint input and
is abandoned; its temporary roots may have `2*A` occurrences. The exported
`A` bound is correctly restricted to reached lookup/fold entry, rather than
all intermediate published roots. No second rehash of an abandoned private
table is possible. Generic scalar Hashtbl behavior is imported through the
named source/runtime relation; this packet claims no new native-body check of
that implementation.

For the ID search, private `occurs` construction lies outside the later Exit
catch. Each increment requires the current nonnegative candidate to be a key;
it cannot exceed the number of occurs bindings, at most 6/7. A signal-origin
Not_found/Exit may end the search early and collide with another ID, but cannot
lengthen it beyond that bound. The actual captured shared-ID tables are empty;
no prior ID magnitude is silently discarded. Private frequency capacities
128/128/64/16/16 and sizes/values 208/173/108/12/9 are represented. Their
allocation and whole-client resource costs remain separate.

## Retained restored-path input inventory

The direct raw-block comparison covers the current table record, bucket array,
every chain cell and ephemeron key/data pointer. All cached hashes in each
current array are distinct. The selected Weakhtbl hash is the numeric tag,
and Ephemeron tests that cached hash before key equality; therefore missing
decoded payloads at other hashes do not conceal another current candidate
for a serialized tag. There are 64/53/32/3/4 absent tags and exactly two
present tags per case. Both matching payloads are fully decoded, one with a
six-byte qualified component and one empty. The occurrence-weighted maximum
of fallback/current candidates reproduces 607/503/334/74/86 bytes. This is
stronger than relying on one observed successful lookup, but remains a
current-array claim.

The extractor distinguishes a missing block from the represented empty list.
Only 47/47/42/13/22 full current payloads are available. Global payload maxima,
saved old-array roots, active resize frames and whole-interval name bounds
remain null. The retained endpoint summaries record phase PCs and preparation
directives, while all included backtraces are startup guards. They do not
supply endpoint call frames or exclude suspended resize from an observed stack.

The four retained library files contain 38,678 bytes, 69 module heads and 102
literal use/clone edges. Their topological certificate and maximum dependency
chain of 13 reproduce. The complete clone spans, including continuation lines,
and exclusions for interfaces, explicit scopes/namespaces, mutable/private
types, invariant/witness syntax and clone val/exception substitutions are
retained for semantic inspection. Candidate maxima 29/26/12 are lexical and
declaration observations; no parser or generated-name theorem follows from
regular-expression enumeration alone. The note explicitly separates this
source-name DAG from modules that an arbitrary tag-alias lookup might return.
That distinction is essential for the subsequent continuation proof.

## Qualified path payloads

The tuple constructor starts with an empty prefix and registers only its type
and constructor names, each formed from a five-byte stem and one native signed
decimal integer. Its private memo results are from those constructors;
declaration data equality compares the physical symbols, so a numeric tag
collision does not replace the supplied declaration names. The resulting
one-component bound is 25 bytes under the normal decimal-service contract.
This proves neither tuple arity resource capacity nor tag noncollision.

All registered choices of the three encoding flag tables are included. Their
callbacks create symbols, terms, declarations and tasks; the insertion owners
are `Trans.decl`, `Trans.goal`, `Trans.add_tdecls` and Task constructors. In
particular, `encoding_guards_full.empty_th` uses `Task.use_export`, despite its
name. The called algebraic query helpers do not invoke tuple construction.
The complete helper bodies and their callback owners support the no-Theory-
path-writer claim. Exported registries still require the fixed-loading/client
premise; the 17-reference lexical census alone would not prove this effect.

The library argument supplies a conditional origin lemma rather than an
observed lookup guarantee. `G_library` requires every memo hit to return the
module from the corresponding named definition and declared dependencies,
and excludes foreign symbol/namespace origins. Merely restricting possible
names to the same finite set would not preserve the DAG after edge redirection.
The final note retains that stronger origin condition explicitly and does
not assert it for all actual post-cut clients.

Within that origin condition, lexical stems and fixed operator encodings
survive `id_clone`/`id_attr`. Program declaration names require more than pure
Theory names: the argument includes specification/definition/lemma suffixes
and postcondition counters. I checked the clone recurrence: `PDpure` copies
its proposition name, while cloned `PDlet` reconstructs pure declarations
from the routine name, so repeated cloning does not repeatedly append those
suffixes to already generated propositions. The selected nonempty library
path suppresses ordinary let/recursive VCs. Type VCs have no witness/invariant,
and absence of val/exception clone substitutions excludes the refinement VC
branch. Plain module heads exclude interface implementation-copy generation.

Use/clone scopes have lexical names. Under the corresponding-definition
condition, a single namespace path follows an acyclic dependency ancestry;
merging namespaces chooses branches rather than concatenating two ancestry
paths. Its label bytes and dot count can each be charged to the retained source
size S. Together with a stem of at most `S+64` and builtin slack, the bound
`3*S+128=116162` is conservative. This is a semantic source argument under
the origin/service premises, not the inventory's lexical maximum promoted
to a proof of all generated names.

The conditional arithmetic uses `U=C+N*max(F,R)`, preserving fallback bytes
and occurrence counts. All five exact sentinel ceilings and their first
rejecting successors reproduce; the common ceiling is 2,162,382. The
conditional library result fits comfortably, but actual R/U remain null.
The packet still requires all initially selectable values, including a
resumable old resize array, and all later selected writers to satisfy the
uniform payload invariant. The accepted original-PID, post-cut native-effect
argument is not extended backward to rule out a suspended resize at these
cuts. Source/native list/concat construction and complete save composition
remain separate.

One review scope clarification was requested: both the tuple's decimal suffix
and `Pdecl.post_axioms`' decimal counter call the normal integer conversion
route through `caml_alloc_sprintf`. They inherit the normal numerical-service
contract and establish no failed-conversion capacity. The parent fixed this
in `97914a071c`: the note/README and result metadata state the premise and
failed-path exclusion, and the packet pins the accepted scalar contract note
and result. I reviewed the exact five-file diff and reran only this changed
focused packet. Source witnesses, registry census and numeric bounds are
unchanged. The clarification is independently confirmed and resolved.

## Disposition and remaining obligations

No numeric or source-control counterexample was found within the named
premises. The normal-decimal-service clarification above is the sole requested
review change and is fixed. Whole post-cut native/frame behavior remains
imported; actual library origins, remaining path-writer coverage and initial resumable old
arrays are not established. Failed locale/conversion/allocation paths,
aggregate object/native layout, CamlinternalFormat recursion, runtime stack/GC,
channel/file-offset and pathname/error/exit capacities remain open. Broader
driver/solver/report/fixed-library/current-grammar composition is also open.

The Oracle, tools/pins and admission remain unchanged; production #88–#94
remains unstarted and PR #121 remains draft/unmerged. This review does not
complete #153 or #119 and adds no approval gate.

## Focused verification and reporting

| Reviewer execution | Result | Measured checker time |
| --- | --- | --- |
| New formatter-ownership check | 19 source excerpts, six retained native bodies/1,456 bytes and premise-separation checks pass | 0.558 s |
| New table/counter check | 22 identities, eight source excerpts, two new native bodies/400 bytes, 206 structural rows and five endpoints pass | 0.432 s |
| New retained-path inventory check | Raw current arrays/candidates, complete-file candidate/DAG census, source identities and preserved unknowns reproduce | 4.159 s |
| New path-payload check at author aggregate | 62 source witnesses, 17 registry references, five exact boundaries/rejecting successors and unknown propagation pass | 0.573 s shell call |
| Changed path packet at final review target | Same checks pass with explicit normal-service metadata and scalar-contract identities | 0.574 s shell call |

For the inventory check, the sole `verification.json` write was intercepted;
all original extraction and assertions ran, the output was printed, and the
tracked author evidence remained byte-identical. Earlier component successes
were retained across the fast-forwards. The final path check was repeated
because its checker/input manifest/result metadata changed; no old successful
packet was replayed. Parent executions are separate and are not attributed to
this reviewer.

The tests corroborate exact inputs, arithmetic and interface behavior; source
reasoning supplies the conditional ownership/control argument. Successful
test cases are not universal assurance. No predecessor checker, target,
capture, disassembler, source fetch, solver/GNATprove/Lean/full-suite run,
GitHub write or CLI-memory update was performed. `scripts/dev.py paths` and
`uname` confirmed the actual Linux x86_64 host; reading ELF bytes did not
execute the target.

Reviewer launch selected explicitly by the parent: GPT-6 Astra / Extra High.
Runtime model/effort confirmation and per-review token/monetary-cost attribution
are unavailable. Review began at 10:59:13 UTC. The final source assessment,
focused checks and report were complete at the 11:09:10 UTC checkpoint:
9 minutes 57 seconds wall time, including input waiting and coordination;
this is not active compute time. The report commit follows that checkpoint.
Intended outcome: one independent aggregate assessment. Achieved result:
conditional acceptance with one normal-service scope clarification, no numeric
rework, and the named path/native/whole-capacity obligations still open.
No reviewer subdelegation occurred.
