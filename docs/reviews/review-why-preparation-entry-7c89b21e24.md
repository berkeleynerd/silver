# Independent review: first actual Why3 inlining entry

2026-10-18. Research [#119](https://github.com/berkeleynerd/silver/issues/119).

**Disposition: scoped acceptance; no material finding.** The retained capture
and decoder establish the exported ordered input dimensions for the first
observed Input_Is_Valid/cvc5 `inline_trivial` entry, under the existing
relevant-source/runtime premise. The excessive generic recurrence value is
a failure of that coarse bound to certify the integer range. It is not an
observed overflow or a capacity obstruction.

## Exact inputs and scope

The frozen target is `7c89b21e2489d984bdabcae3d5bd88a6dd38e2b8`, reviewed
in the initially clean isolated branch `review/why-preparation-entry-7c89b21e24`.
The reviewed change consists of the
[research note](../research/retained-why-preparation-entry.md) and
[evidence packet](../evidence/retained-why-preparation-entry-20261018/README.md):
`README.md`, `inputs.json`, `capture.tar.gz`, `sources.tar.gz`,
`drivers.tar.gz`, `decode.py`, `compose.py`, `check.py`, `dimensions.json`,
`batches.json`, `result.json` and `round.json`.

The bounded assignment reused the Oracle, owner-authorized #119 research,
applicable AGENTS and review bookkeeping. I read the predecessor conditional
inlining transfer and its callable, then checked the new capture, decoder,
identity joins and exported claims. The later eligible-definition/symbol-hit
refinement is outside this target and was not reviewed. No all-task, all-driver,
whole-pipeline or production-admission claim is accepted here.

All sixteen source archive members, including the license, independently
matched the accepted
`retained-producer-prefix-composition-20261018/sources.tar.gz` byte for byte.
This includes the new map, driver-parser and encoding files as well as the
overlap checked by `compose.py`. The selected source revision remains Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`. Runtime/source correspondence
remains an explicit premise, not a new historical build attestation.

## Entry and identity assessment

The installed instruction evidence supports the chosen registers at function
entry. `Driver.prepare_task` saves rax as the driver and rbx as its input
task, and loads the transformation list from driver offset 0x18. The entry
to `Driver.apply` at static address 0x5d7aa0 reads the pair's name from
rbx+8 and transform from rbx, while retaining rax as the task captured by
the application closure. The observer stops at the first instruction, before
those registers are repurposed, and checks the expected first 32 bytes.
This matches the source `apply task (tr,name)` and `List.fold_left` at
`driver.ml:372–389`.

There is one observed preparation call. Its directive list matches the
accepted cvc5 list; its visited prefix is exactly
`counterexamples_dependent_intros`, `inline_trivial`. The source places
`update_task` before that fold, so the first transformation has returned
and the selected inlining transformation has not begun. The CE-off branch
selects unused-symbol removal, not counterexample dequantification
(`prepare_for_counterexmp.ml:15–31`).

The preparation input's entire 434-element declaration-address sequence
matches graft child 2 uniquely in the same process. This is a process-local
identity comparison supported by the retained collection guards, not an
address comparison across separate executions. The inlining-entry chain has
512 nodes. Reversing its predecessor walk gives the original declaration
order consumed by `Trans.fold` (`trans.ml:76–101`).

I independently joined the new case and all fourteen driver/import identity
and resolution records to the predecessor fixed-tail capture after the
explicit scratch-root substitution. The four private driver files are byte
identical; the overlay configuration differs only by that path relocation.
The actual process argv/environment match the retained plan. The input is
121,828 bytes with SHA-256
`d146b75d28832260c49de3d8eb5f816c8481595127dc56dfaf3512cbdb6a4b2d`.
The executable's mapped-file identity matches its plan and the predecessor
plan: 24,561,432 bytes, SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.

The recorded successful file opens agree with pinned identities; all required
overlay and selected driver-closure paths were observed. Printer,
`call_on_buffer` and both request-submission guards have zero hits. The
probe reads stopped memory/registers without inferior calls or fabricated
returns. It kills the client at the entry stop. The retained single-client
server teardown is not a solver response. No solver result is used.

## Graph, opening and ordered batches

The raw walker starts from every logical declaration payload and follows all
scanned block fields. I independently recomputed closure from the 244 roots:
all 14,477 retained blocks are reachable, every scanned pointer edge resolves,
and header-plus-payload storage sums to 401,208 bytes. The only opaque tag is
252, for strings. The graph's identity is 1,490,344 bytes and SHA-256
`d7f49ce0181875434292f228c3d599c8c8157b3d1f0ac6793f0d12c2558184be`.

The raw root set deliberately excludes use/clone/meta payloads. Their 34/42/192
task positions and tags are retained for the ordered batch input. This is
sufficient for the exported `inline_context` dimensions because those node
kinds have no mapped term roots. It does not establish complete metadata,
type, validator or cache work. The note keeps those scopes separate.

The constructor tags and fields agree with the retained OCaml definitions
in `term.ml`, `decl.ml`, `ty.ml` and `extmap.ml`. `measure` charges each
shared edge's occurrences again, while memoizing only its result. Binder
slots, branch pattern nodes and application nodes are distinct coordinates;
quantifier triggers contribute their term occurrences. Pattern variable-set
checks include disjointness and agreement between both alternatives of an
or-pattern. Variable-map keys are checked for unique, ordered identifier tags.

The frame lookup matches `term.ml:258–283`: bound variables shadow saved
substitutions, and a saved value is interpreted in the remaining outer
frames. The opening routines at `term.ml:815–833` freshen binders and apply
these substitutions to bodies and triggers. Replacing fresh identities by
bound leaves preserves the measured type-erased occurrence dimensions; it
does not supply a fresh-name or allocation count.

I additionally used an independent eager environment evaluator for all 143
mapped roots. It evaluates saved substitution values in the outer identifier
environment and then overrides freshly bound identifiers with one-node
leaves. This avoids the decoder's frame-descent implementation. Every root's
four dimensions matched, with sums `(n,b,p,a)=(1613,168,12,594)`, hence mass
1,793. The maximum mass is 99, maximum logic arity 6, and the goal has
`(n,b,p,a,m)=(68,5,0,36,73)`.

Logic roots are the opened definition bodies selected by `open_ls_defn`,
with the outer formal arity recorded separately (`decl.ml:61–69,621–634`).
The outer definition quantifier and equality/iff wrapper are not charged as
part of that body. Their full axiom dimensions and termination-list lengths
remain available in the separate validator inventory. All roots remain in
their own declaration batch; the 512 batches preserve metadata positions and
do not expose a definition to its own declaration's transformation.

The stored walk separately follows every saved substitution value, including
unused values, and retains 1,933 unique stored term records. Its 157 binder
records contain eight saved entries across three nonempty substitution maps.
The checker recomputes semantic free-variable occurrence counts for all 157
binder payloads, including trigger and substitution effects, and matches
their `bv_vars` metadata. This is a useful captured-object invariant check;
it does not validate every constructor/type invariant or bound the operations
needed to open those representations.

## Recurrence and remaining obligations

The adapter calls the unchanged reviewed `inline_kernel` in task order,
starting with an empty environment, and updates the environment after each
singleton logic batch. Its update is the predecessor callable's deliberately
conservative rule: admit every singleton and allow every application to hit.
It stops before evaluating the remaining enormous recurrence.

The first reported excessive output-mass bound is reproduced at task index
60, logical declaration index 37, with input `(n,b,p,a,m)=(7,0,0,2,7)` and
preceding environment mass 1,310,666,765,893,632. The bound is
12,024,931,598,526,509,256,156,767,059,968, above the nonnegative OCaml integer
limit 4,611,686,018,427,387,903. No actual transformed-output size or gap
between that size and this majorant was measured. The accepted meaning of
precision loss is that this coarse transfer cannot certify the requested
range; it does not prove an overflow, obstruction or need to change tools.

The future prefix route is correctly presented as research. In particular,
the cited CE-removal source can duplicate polarity work and can retain a let
binding expression after substitution. An unproved shrinking assumption
would be invalid. This review supplies neither a uniform expansion factor
nor an all-pair projection.

Precise inlining capacity, hidden substitution/type/validator work, later
transformations and printing, process-wide caches/counters, serialization,
and schedule/cache independence remain open. All corresponding completion
booleans remain false. No native capture or one-pair dimension measurement
is promoted to universal assurance.

## Evidence and round record

The focused offline command passed, with assertions enabled:

```sh
python3 -B docs/evidence/retained-why-preparation-entry-20261018/check.py
```

Reviewer-measured elapsed time was 0.465320 seconds on Linux 7.0.14 x86-64,
glibc 2.43. The replay reproduced all three result files, exercised all 157
binder checks, and rejected the selected header/root/substitution/count,
trigger-omission and archive-corruption changes. The separate source/archive,
driver-identity, graph-closure and eager-environment audits above were also
offline. They do not mechanically prove OCaml source/runtime semantics.

The existing successful native capture is reused: managed run
`20261018T201352-407bbd8ad0f5`, 7.153969065 seconds overall and 4.873981385
seconds in the debugger. The preceding setup-only failure records an absent
worktree installation before native target execution. Neither run was
repeated. New reviewer native/compiler/prover/debugger/server/solver runs:
zero; no native worker reservation was needed.

Selected reviewer settings: GPT-6 Astra / Extra High, assigned by parent.
Runtime confirmation and token/cost measurements are unavailable. Review
ran from 20:23:03 to 20:28:44 UTC, an elapsed 341 seconds including reporting.
Intended outcome: independently check the captured entry, complete exported
graph projection, ordered dimensions and recurrence interpretation. Achieved:
scoped acceptance with no material finding or rework. Only this report is
changed in the review worktree. The parent owns integration, issues and
durable memory; CLI memory was not updated. The child harness goal query
returned null; no goal state was changed here.
