# Retained inlining declaration representative state

2026-10-18, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119),
based on `eea188d96f`. The complete retained `Decl.Hsdecl` table at the first
Input_Is_Valid/cvc5 `inline_trivial` entry supplies the missing representative
input for the [reviewed conditional operational transfer](retained-why-inline-operations.md).
For this entry, every selectable old declaration is one of the captured input
roots. Earlier local insertions cannot match a later mapped declaration.
Consequently the representative envelope is **E=8, V=6, T=3, A=80**, under the
existing relevant-source/runtime, well-formedness and fresh-identifier premises.

This attaches the conditional local structural/registration arithmetic, including
**1,145 fresh identifiers**, 36 saved-map keys and 21,483 stored occurrences per
formula. It does not establish complete transformation capacity: unsuccessful
comparand costs, other shared initial states, runtime allocation/collector
composition and downstream consumers remain open. Other fixed input/driver
entries and process histories are separate obligations. This is one retained
state, not a universal state-membership or whole-language capacity theorem.

The [evidence packet](../evidence/retained-why-inline-representative-state-20261018/README.md)
is new. The reviewed conditional packet remains unchanged. No production
source, Oracle, tool pin, admission rule or configuration was changed.

## Complete state capture and correspondence

The old 244-root capture contained only logical declarations reachable from the
task. It did not retain the shared declaration table. One new capture attempt
reached the same entry but failed on a decoder zero-byte read of an empty hash
array. The failed attempt and its complete diagnostic outputs are retained.
After an offline empty-array regression, one specifically authorized corrected
attempt succeeded. Both used managed one-worker reservations and separate
scratch roots; there were no prover submissions, builds or proof runs.

The successful capture retains **every** outer bucket, cached-hash array and
weak key slot, including empty slots. Every nonempty key supplies a declaration
root for the full reachable OCaml graph. No symbol or size filter was applied
while capturing. The exact result is:

| State dimension | Retained value |
| --- | ---: |
| Outer buckets | 5,003 |
| Allocated weak key slots | 11,968 |
| Nonempty slots / distinct declaration objects | 6,704 / 6,704 |
| Maximum bucket length | 7 |
| `next_tag` | 6,836 |
| Bucket limit / oversized buckets / rover | 7 / 0 / 0 |
| Combined task/table graph blocks | 326,456 |
| Retained graph header/payload bytes | 9,058,224 |

These are retained-state measurements, not capacity limits or live heap size.
Nonempty slots are a conservative selectable superset: a later weak read may
clear or lose an object. The projection does not equate nonempty storage with
strong reachability. It does include every object that a successful weak merge
could return from the initial table.

Why3 source is `9390baf120ef260547dfa14f08e11c890b203d9c`; OCaml source is
`8eb41f72ded84df884c3671734c947f612091f84`. The installed executable identity is
unchanged from the accepted entry, and the successful process's mapped-image
identity is checked against that identity. Complete relevant sources, static
instruction disassembly, runtime instruction-prefix checks, observer scripts,
launch/configuration identities and managed records are retained.

The installed `mk_decl` reads its `Hsdecl` module at
`camlWhy3__Decl + 0x2c0`. Module field zero is the `hashcons` closure; closure
field four is the weak-table record, and field three is `next_tag`. The installed
`Hashcons.Make` and `hashcons` instructions agree with this layout. `Weak.Make`
has five fields: bucket array, hash array, limit, oversized count and rover
(`hashcons.ml:32–54`; `weak.ml:108–140`). Its installed constructor writes the
same five-field record. The capture validates these record/closure shapes and
the closure's actual code address before following the table.

A bucket is an ephemeron with abstract tag 251, link/data words zero/one and
keys starting at word two. `caml_ephe_none` supplies the empty sentinel. The
source `additional_values=2`, `caml_ephemeron_create` and
`caml_ephemeron_get_key` agree with the installed instructions
(`weak.ml:29–34`; `runtime/weak.c:32–46,112–137,174–204,343–361`). The capture
reads each bucket's full payload, requires its data word to be empty, joins its
key count to the cached-hash array length and checks each occupied key's bucket
index. It does not follow the ephemeron link into unrelated tables or call a
weak getter in the inferior. The offline checker replays all bucket indices,
lengths, hashes, roots and graph-edge closure; a missing bucket or key graph is
an error, not a sample.

The inferior remains stopped throughout the snapshot. The accepted guards,
including collection, file-read, process/thread and printer/submission guards,
are retained byte-for-byte after the documented path relocation and new table
observer insertion. The process starts with one thread and creates no new
thread. All protected collection/request guards remain clear; the same runtime
counters and entry invariants are checked. The snapshot is in mark phase; all
nonempty slots are retained without making target calls that darken keys.

The combined graph has opaque tags 252 (strings) and 255 (custom payloads).
Every OCaml payload byte is retained; external C storage behind a custom
payload is not recursively decoded. This does not restrict the selectable
representative result: the surviving input-root subgraph contains only strings
as opaque blocks. Custom constant operations in excluded collision comparands
are not assigned a complete cost bound here.

The new graph's 244 input roots have an **exact sharing-preserving graph
isomorphism** with all 14,477 blocks of the accepted input graph. Node tags,
sizes, immediate fields and opaque payload bytes agree. Only process addresses
and header colour bits are immaterial; there is no source-name, attribute,
location or string normalization. The input JSON, argument/environment values,
driver closure and configuration agree under the explicit scratch-path
relocation. The accepted semantic analysis replays to exactly the same details
on the new input roots.

## Exhaustive selectable-old projection

`Hsdecl.equal` first distinguishes declaration kind, then compares the declared
logic/proposition symbols before the corresponding formulas
(`decl.ml:350–366`). The captured invocation has 81 singleton logic declarations
and 62 propositions, including one goal. `decl_map` preserves those symbols and
kinds; goals use `Hsdecl.unique` and do not query or enter the weak table
(`decl.ml:411–419,621–634`). Thus a selectable old representation must have the
same singleton logic-symbol list, or the same proposition kind/symbol, as its
mapped input declaration.

Filtering **all 6,704** initial objects by these necessary keys excludes 6,559.
The remaining 145 comprise the 142 captured non-goal input objects and three
older proposition objects. The packet retains each input index and every
same-key object address, rather than only the totals.

| Extra old proposition | Input index | Old opened coordinates `(n,b,p,a)` | Candidate upper coordinates | Excluding coordinate |
| --- | ---: | --- | --- | --- |
| `concat_singleton_left_def` | 143 | `(72,8,0,19)` | `(72,7,0,19)` | Bound slots |
| `bool_eq_rev` | 152 | `(53,7,0,18)` | `(52,7,0,18)` | Term occurrences |
| `argument_count__post_axiom` | 242 | `(17,2,0,8)` | `(16,2,0,8)` | Term occurrences |

The coordinate ceilings are the accepted corresponding optional-exclusion
alternatives, not a global maximum applied to every declaration. The old
coordinates are computed from the complete newly retained formula graphs,
following their delayed frames and including triggers and binders.

Why these inequalities exclude strict equality requires a source argument.
`descend` follows delayed substitutions reached from variable leaves;
`t_compare` recursively compares the resulting constructors, binder lists,
patterns and, in strict mode, triggers (`term.ml:266–281,325–395,515–532`).
Under the existing valid-frame/type premises, strict equality therefore entails
equal opened occurrence/binder/pattern/application coordinates. A raw variable
may stand for a larger saved value, but both the model opening and comparison
follow that replacement. Bound names are alpha-equivalent; binder-list lengths
are compared. Attribute/location checks may reject additional pairs; they
cannot make two different constructor/binder coordinate vectors equal. The
physical-equality shortcut also preserves these coordinates.

Consequently none of the three extra old propositions can equal any candidate
covered by the corresponding model alternative. This argument does **not**
assume that strict equality preserves attributes exposed by opening. That was
a separate uncertainty in the conditional packet and is handled below.

## Local insertion closure and actual opened attributes

The source fold walks the captured task spine once, in order. Its memo can skip
work but does not add visits (`trans.ml:76–108`). At this goal entry, `store`
bypasses its memo, so `bind` invokes the callback that constructs a new
`on_tagged_ls`/`fold_map` closure. Its fold memo starts empty
(`trans.ml:51–55,234–236,291–300`; `inlining.ml:92–102`). On each mapped logical root,
`decl_map` calls one declaration constructor. Opening, `make_ls_defn`, term
mapping, type instantiation and task validation do not insert a second logical
candidate into `Hsdecl` (`decl.ml:41–75,526–535,621–634`; `inlining.ml:56–85`).
Reused type/data/parameter declarations bypass reconstruction. The goal's
`unique` route increments its tag counter without inserting a table entry.

The checker establishes that the **143 mapped keys are pairwise distinct**.
A candidate inserted at index `i` retains that index's kind and declared
symbols. It therefore cannot compare equal to a later candidate at index `j`.
This is the local-insertion closure argument: all noncandidate objects a later
merge can return still come from the initial projection above. Rehashing and
weak clearing only move or remove existing objects; they do not invent a
representative (`weak.ml:210–311`). No unproved uniform bound on a sequence of
reinserted delayed maps is needed.

Wrapper interning also cannot substitute a different logical declaration.
`Theory.Hstdecl.equal` compares `Decl` payloads with physical `d_equal`
(`theory.ml:233–235`; `decl.ml:405`). `Task.Hstask.equal` requires physical
`td_equal` and equal predecessors (`theory.ml:283`; `task.ml:91–92`). Although
`task_hd_equal` has a semantic goal case, `check_task` rejects a goal predecessor
before normal `new_decl`, `new_clone` or `new_meta` construction
(`task.ml:75–81,140–161`). Their predecessor equality is consequently physical.
With the existing valid cached-map invariants, an old task wrapper thus retains
the same declaration and predecessor, and its cached known/clone/meta maps
describe that same spine. This is not a bound on those maps' allocation or on
every wrapper table in the process.

This is the synchronous selected fold, not an invocation of the external event
scheduler. Its source call graph contains no thread creation or application
callback that inserts an unrelated declaration. The captured process is single
threaded; the separate idle server has a different address space. The installed
GNAT source's interrupt handler saves and exits instead of returning to the
fold (`gnat_main.ml:298–309,335`). Inspection of the complete pinned Why3 source
finds no OCaml finalizer registration or thread/domain spawn. These source facts
support absence of a foreign insertion in a continuing invocation under the
existing relevant-runtime premise. Interrupt/session-exit behavior and runtime
allocation/collection capacities are not newly proved by this local argument.

Proceed by induction over the ordered declarations. Before the first root the
environment is empty. Assume each stored environment body is a permitted model
alternative. Mapping the next input then obeys the accepted optional-hit bound.
Its merge either returns that candidate, or an initial object. The key and
coordinate exclusions above leave only that index's exact captured input
object. Thus the induction reduces to showing that this input body is itself
an allowed alternative.

The packet checks this directly for all 143 model roots. Recursively selecting
the first (miss) branch at every optional hit reproduces the exact interned
input body, including types, constants, variable identities, triggers, patterns
and attributes. This is also the source model's construction: miss preserves
the original node with recursively mapped children. The accepted opener includes
real delayed substitution and `t_attr_copy` attribute unions. Therefore the
selected old input body's actual opened attributes and eligibility lie in the
already checked alternatives. Uniform eligibility, the 45 binder-free bodies,
85 possible hits and coefficient-at-most-one facts are reused. No extra
eligible body is inferred from strict equality alone.

This closes the induction without circularly assuming the candidate ceilings:
earlier environment selections are already covered, so the current ceiling
justifies exclusion of the three old shapes; the surviving input alternative
then preserves the next environment invariant. Unknown metadata exclusions
remain optional misses throughout.

## Attached envelope and remaining capacity obligations

Every selectable old seed now comes from the exact input graph. Its eight
saved entries, six-node unary/binder-free values, nonunit-key disjointness,
size-three types, captured symbol/signature universe and 80-attribute union are
the previously checked inventory. The distinct-key insertion proof supplies
closure over the invocation. Together with the opened-body induction, these
instantiate the repaired representative contract. The new result attaches the
unchanged conditional arithmetic; it does not edit the old result's intentionally
uninstantiated status.

The table also supplies one shared-state starting point. Charging at most 143
`Hsdecl` increments, including the goal's `unique` call, gives `6836+143=6979`.
The pure weak backing transfer with outer length 5,003, maximum bucket 7,
allocated slots 11,968 and at most 143 requests gives individual outer-array
length at most 36,336 and bucket length at most 18,169. Its explicit integer,
array and ephemeron representation conditions still apply. This instantiates
this table's local starting state, not every other caller in the process.

The local structural/registration transfer is attached under the existing
runtime/well-formedness/noncolliding-freshness premises. The packet deliberately
keeps these separate from:

- Complete equality-callback/comparand work. All initial comparator objects are
  retained, but this packet has not completed their operation/capacity transfer.
- The other shared counters/tables and their process-lifetime callers.
- Runtime allocation, collector and serialization composition.
- Later transforms, printer/request paths, other fixed pairs and universal
  source/configuration membership and capacity claims.

No complete transformation or whole-pipeline verdict is asserted. Physical
resource availability remains an external assumption; no aggregate RAM gate is
introduced.

## Validation and round record

The offline checker verifies archive/dependency identities, every bucket and
stored edge, the exact input graph join, semantic replay, exhaustive key/shape
exclusions, all-miss attribute attachment and the exported arithmetic. Negative
checks reject a missing bucket, truncated hash array, wrong cached-hash bucket,
missing graph block, changed input string and an extra old representative that
cannot be excluded by the current shape proof. The failed zero-byte read is
regressed with a synthetic memory reader that forbids zero-length reads. These
are model/source checks, not machine-checked native semantics.

The failed managed attempt is `20261018T213006-c14a891efb1a`; the successful one
is `20261018T213147-a12cd442bb5e`. Debugger durations are respectively
4.89050305 and 7.529223531 seconds. Their managed durations, complete outputs,
selected settings, exact check timing and review status are in `round.json`.
Earlier successful captures/suites were reused; the native rerun obtained a new
missing input, and the retry repaired a diagnosed failed decoder.

Selected worker: GPT-6 Astra / Extra High, assigned by the parent. Runtime model
confirmation and token/monetary measurements are unavailable. The parent owns
independent source/state review, integration, publication, issue status and
memory. No CLI-memory or harness write occurred in this subthread.
