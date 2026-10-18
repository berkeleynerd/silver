# Review of retained inline callback closure

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed commit `20e801be186ce6e41cb7c53d44d6cd072fa06dda`.
**R1 correction accepted at `f5475afb3513443a5a05bdfd1e6e7a8ab3a27269`.**
The focused correction disposition below supersedes the original acceptance
status; the original findings and evidence are retained as history.

Original disposition: **correction required before accepting the packet's named
signal-escape argument.** The proposed stable missing-task witness is refuted by the exact
membership guard already present in the archived source. The binder-opening
and signal/catch observations, scoped interface inventory, and unchanged
accounted endpoint remain useful. Complete callback capacity remains open;
this review establishes neither a replacement counterexample nor closure.

## R1: the missing-task witness overlooks the membership guard

The [note](../research/retained-why-inline-callback-closure.md), under “The
concrete remaining signal obligation,” describes an earlier goal creating
identifiers followed by a later non-detached goal whose missing raw task makes
`get_task` raise `Not_found`. That scenario does not follow from the source.
In the archived `why3/src/session/session_itp.ml`:

```ocaml
(* 310–311 *)
let get_task s id =
  Hpn.find s.session_raw_tasks id

(* 369–371 *)
let goal_is_detached s pn =
  try let (_:Task.task) = get_task s pn in false
  with Not_found -> true

(* 385, inside is_detached *)
  | APn pn     -> goal_is_detached s pn

(* 2222–2223, inside uniformize_shape *)
  | APn g when not (is_detached s any)  ->
      let t = get_task s g in
```

A task already absent when this node is visited makes the guard false and
the node is skipped. A prior node's identifier registrations do not alter
that conclusion. “Every non-detached node has a raw task” is not an independent
missing session-state invariant here: the predicate establishes membership by
that same lookup. The packet must withdraw this concrete missing-task witness,
rather than retain it as a conditional example awaiting a session snapshot.

There is no explicit table write between the two lookups. The complete
`session_raw_tasks` occurrence inventory in this source member is its field
declaration at 136, lookup at 311, initialization at 631, and `Hpn.add` at 687;
the field is not mutable, and this module has no removal or clear. Under
ordinary sequential table semantics and no interfering mutation, the second
lookup has the membership established by the first. The inspected thread
preemption and channel-destructor bodies do not supply a session mutator, and
the packet identifies no consumer that creates an additional OCaml worker or
registers a Why3 finalizer through the inspected APIs. Those scoped findings
give no positive mechanism for a task to disappear in this interval.

The packet does not establish a whole-program absence of arbitrary alias
mutation or every asynchronous callback; its own closure flag is false.
Accordingly this review does not promote the local observation into a global
mutation theorem. A claimed removal between the two lookups would need an
actual reachable mutator and ordering argument. No such witness is established
here. An asynchronous exception arising independently during the second lookup
would likewise require its own route; it is not evidence of missing membership.

Required repair: correct the lead result, numbered route, residual and next
checks in the note, README, `result.json` and `round.json`; preserve historical
validation and update affected identities. Include the existing guard in the
focused source witnesses. Replace the disproved missing-membership story with
the precise remaining exception/charging obligation, without inventing another
counterexample. This is a material research-argument correction, not a found
production failure. No candidate file was edited by the reviewer.

## Observations that survive R1

`gnat_main.ml:298–309` and its native body agree that the small
`Invalid_argument` trap covers signal-setting only. Session saving precedes
`Stdlib.exit` outside that trap. `session_itp.ml:2212–2245` recomputes shapes;
SV6's `Gshape.t_bound_shape_task` calls `Shape.t_shape` on proposition formulas,
whose binder-opening paths clone symbols through `Ident.id_register`. The
handler therefore has a source route to identifier creation for applicable
tasks; using Gshape does not avoid it.

The native `Trans.accum` trap contains both `Ephemeron.find` and allocation of
`Some`. Its `Not_found` arm resumes as a cache miss. The retained
`Ephemeron.find_rec` poll precedes the empty-bucket test, so that interruption
point does not require a cache hit. `signals.c` propagates a callback's
exception result through pending-action processing. These facts support the
conditional implication: **if a handler-side `Not_found` escapes after
identifier creation at this interruption point, the fold can catch it and
continue**. They do not supply the antecedent refuted in R1.

`Stdlib.exit` runs its exit hooks before `caml_sys_exit`, without catching every
hook exception. That is a legitimate remaining interface to inspect, not an
established installed hook that raises `Not_found`. Likewise, the signal setter
can allocate the previous handler and process pending signals. Neither finite
handler multiplicity nor one-shot charging follows merely from the order of
the ignore calls. A finite-count/shape-charge argument or an enforced launch
mask remains a candidate requiring the packet's stated checks.

## Scoped native/API inventory

No further material defect was found in the explicitly limited interface
findings. The retained numeric references and relevant source/native bodies
support these narrower conclusions:

- Gc entry initializes module data and closures; the finalizer/alarm APIs
  explicitly register supplied closures. The external entry reference is
  startup. Root/segment metadata and the compiler-emitted primitive retention
  table are not evidence of an executed finalizer registration. The live
  registry remains unobserved, including its zero-fill objects.
- Native Dynlink's global-value accessor is a real export route. The inspected
  Why3 consumers select other fields; the plugin import sets lack the named
  Gc/thread/signal/loader/custom APIs. The retained Dll/Symtable/Meta aliases and
  startup paths do not themselves demonstrate exercised reflection. The
  loader source retains handles, and its `getmap` interface returns decoded
  metadata. These are inspected-interface conclusions, not a universal claim
  about all computed symbol names, arbitrary object aliases or foreign code.
- Thread startup installs a yielding preemption callback and shutdown cleanup.
  The external code references are startup and ThreadUnix timed waits; the
  creator interfaces have no identified external consumer. The inspected Sys
  module fields and direct signal setters match the note's inventory.
- The channel hook has one identified address-taking writer, which stores the
  fixed mutex-destruction target. Its source and native body destroy/free the
  mutex without calling Why3. The custom-operation records, registry path and
  public allocator inventory are useful bounded evidence. The 127 textual
  operation-record predecessors and one legacy allocator site are not a
  dominance proof, and the note expressly says so.

The extractor examines numeric operands/RIP targets, aligned allocated
non-executable PROGBITS words, relocations and dynamic symbols. It does not
prove arbitrary indirect control flow or aliases, and nearest-symbol names
do not prove object ownership. The report's qualifications are necessary for
reuse. No exact-source assumption for unpinned third-party packages was added.

## Exact inputs, validation and review record

Inputs were the ten files added by the reviewed commit: the research note and
all nine files in its [packet](../evidence/retained-why-inline-callback-closure-20261018/README.md).
The archived sources use Why3 revision
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml revision
`8eb41f72ded84df884c3671734c947f612091f84`. The two archive SHA-256 values are
`e59e901cb848afa258750a6c80de876dd0dd9aac3e45491f0dc19b95a136abb6`
(sources) and
`ed2f6226dfc0266cb819b2dacc211844ba2f51dc3ad4720f57721f05db8884fd`
(native). The review inspected the extractor/checker, archived argument
functions and reference-owner bodies, binding/result/round records, and the
accepted [counter review](review-why-identifier-c8bc383e11.md).

`binding.json` connects the retained predecessor capture and plan identities
to the executable and two plugins used by the static extraction. The executable
SHA-256 is `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
This preserves the recorded source/runtime correspondence premises; archive
hashes and native references alone do not establish arbitrary semantic
equivalence.

The author's final extraction regeneration (**10.861872 seconds**) and frozen
check (**0.356060 seconds**) were reused, not rerun. Those successful consistency
checks do not inspect `goal_is_detached` and therefore do not refute R1.
A new [narrow source check](../evidence/review-why-callback-20e801be18/check.py)
verified the frozen archive/member identities, exact guard/lookup snippets and
the field-occurrence inventory in **0.010100 seconds**; its
[result](../evidence/review-why-callback-20e801be18/result.json) records that
limited scope. No target, debugger, compiler, solver, proof, build or broad
suite ran. Host identification and `scripts/dev.py paths` confirmed Linux
x86_64.

The accepted arithmetic remains **60,496 + 1,145 = 61,641**, covering only
accounted registrations. All complete endpoint, callback closure, prior-history,
freshness, family, later-call, auxiliary, full-transform, whole-pipeline and
enforced-mask claims remain unestablished. R1 does not justify changing any
false completion flag or ending the owner's full-capacity goal.

Reviewer selected: **GPT-6 Astra / Extra High**. Runtime confirmation of model
and effort, token usage and monetary cost were unavailable. Review began at
**2026-10-18 23:13:26 UTC** and reached report completion at
**23:16:33 UTC**, **187 seconds** at one-second clock resolution, excluding
final commit preparation. This branch owns
only this report and its narrow evidence. No GitHub, CLI-memory or harness
writes were made; parent integration, author repair and publication are separate.

## Focused R1 correction disposition

**Accepted within the corrected packet's limited research scope.** The exact
correction target is `f5475afb3513443a5a05bdfd1e6e7a8ab3a27269`; the original
review is frozen at `64c4bb749bf4f6347853ebe7a8ddf13c024fe127`. The six-file
correction changes the note, packet README, checker, input manifest, result and
round record. R1 is resolved without changing source/native archives or the
inspected interface claims.

The note and README now explicitly withdraw the stable missing-task witness.
They explain that the detachment guard performs and catches the same lookup,
so a missing task is skipped. The numbered source route, result residual,
remaining obligation and next checks no longer demand the misplaced independent
membership invariant. The checker retains the exact guard/delegation/lookup
snippets and all four local field occurrences. The local no-write conclusion
is conditional on ordinary sequential table semantics and no interference;
no reachable mutator, global alias theorem or replacement exception witness
is asserted. `round.json` clearly labels the old argument as superseded while
preserving its original checks and exact-input record as history.

The repaired packet distinguishes established binder creation, callback
exception propagation and the continuing catch from the unestablished existence
of an actual post-registration escape. Remaining options are an exception and
continuation exclusion argument, finite callback multiplicity with charged
handler work, or the separately unimplemented mask configuration. Setter
allocation, pending signals, reinstallation, launch inheritance and cancellation
remain explicit obligations where applicable; one-shotness is not assumed.

The new [correction check](../evidence/review-why-callback-20e801be18/check-correction.py)
passed in **0.119747 seconds**. Its [result](../evidence/review-why-callback-20e801be18/correction-result.json)
records exact repaired input identities, unchanged archive/extractor/binding
bytes, preserved historical identities and checks, and the exact archived
guard/occurrence witnesses. Every original false result flag remains false;
the two new actual-escape/global-mutation claims are also false. Registration
arithmetic is byte-for-byte equivalent as structured data, with endpoint
**61,641**. The author correction's frozen-check pass (**0.346699 seconds**)
and original successful extraction were reused. No native, extraction,
debugger, compiler, solver, build, proof or broad-suite rerun occurred.

This rereview selected **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation and token/cost measurements remain unavailable. It ran from
**2026-10-18 23:19:55 UTC** through verification at **23:20:30 UTC**,
**35 seconds** at one-second resolution, excluding report and commit
preparation. The correction diff passes `git diff --check`. Only this review
and its narrow evidence were changed; GitHub, CLI memory and harness were not
written. Acceptance resolves R1, not the complete capacity goal.
