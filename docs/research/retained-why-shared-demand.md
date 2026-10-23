# Shared counter and backing demand at the fixed registration cut

2026-10-23 UTC; #119 / #153. **Author result, pending independent review.**
This supplies a process/owner/cut attachment and a callable six-owner arithmetic
join. The selected transform bodies through R58 and direct save binders fit the
six imported counter/backing transfers. Complete process headroom remains
**false**: transform lookup can parse/clone libraries before R58, and the
accepted publication result does not count those constructors. Later preparation,
solver-request printers and remaining callbacks also require explicit inputs.

The [packet](../evidence/retained-why-shared-demand-20261020/README.md) reuses
accepted finite results. No capture replay, target, solver or predecessor checker
ran. Mathematical source arguments below require review; the Python check only
binds the cited evidence and verifies the new projection, joins and arithmetic.
The older [checkpoint](../evidence/retained-why-shared-demand-20261020/checkpoint.json)
remains history, including its now-superseded Input provenance shorthand.

## Process, owner and cut attachment

The target is the successful registration cut of the accepted
[combined quiet/timeless/J12/logging invocation](retained-combined-parallel-startup.md).
Its actual J12 input roles and construction order are supplied by that result
and the [logging prefix](retained-parallel-logging-prefix.md), under their exact
source/native/runtime, successful-service, no-extra-callback and controlled
prefix premises. No new invocation is asserted to have run.

| Domain | Historical state PID / cut | Fresh save PID, separate evidence | Retained J12 PID | Relation to prospective registration |
| --- | --- | ---: | ---: | --- |
| Put_Line | 3085, registration | 17310 | 22236 | Exact six-owner state under constructor trace |
| Put | 3323, registration | 17514 | 22524 | Exact six-owner state under constructor trace |
| First_Or_Default | 3470, registration | 17631 | 21865 | Exact six-owner state under constructor trace |
| Is_Message | 3568, registration | 17704 | 22653 | Exact six-owner state under constructor trace |
| Input_Is_Valid | 97103, first CVC5 inline entry, after CE | 17869 | 22222 | Upper envelope for the earlier registration state |

The first four observations are the accepted
[fixed-registration result](retained-why-fixed-registration-state.md).
Input is now read directly from the accepted
[PID 97103 packet](../evidence/retained-why-session-save-state-20261019/README.md),
whose existing check replayed its private counter and auxiliary values. Its
archive binds the complete Hsdecl and auxiliary state to the same stopped
process. The old identifier-state packet's PID **74171** is not renamed 97103,
and the fresh PID 17869 Hsdecl observation is not used to attach another
process's auxiliary state. The new projection reads frozen metadata/blocks;
it does not rerun the accepted memory observer.

The exported registration counter inputs are:

| Domain | Ident | Hsdecl next | Hsty next | Hstdecl next | Hstask next | Hcpt next |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 136844 | 7207 | 577 | 11249 | 1233 | 1946 |
| Put | 121505 | 7178 | 577 | 11220 | 1204 | 1946 |
| First_Or_Default | 77806 | 6967 | 572 | 10985 | 639 | 658 |
| Is_Message | 59035 | 6796 | 568 | 10749 | 391 | 443 |
| Input_Is_Valid, upper bounds only | 60496 | 6836 | 570 | 10815 | 799 | 772 |

Each weak table has outer length 5003. `attachment.json` retains every observed
allocated-slot count and maximum bucket length, including empty weak slots;
it never replaces allocated slots by occupied slots. Hcpt has outer length
8192, seed zero and stored sizes 1945/1945/657/442/771. These are stored bucket
nodes, including dead keys if there were any, as required by the transfer.
`Task.Stdecl.Hcpt` is distinct from the AVL implementation `Theory.Stdecl` and
from the Theory restore-path table in the accepted 206-table save join.

### Extending the accepted constructor relation to these owners

Raw graph equality is insufficient. Use the accepted combined startup's
**ordered constructor/cache relation**, including intermediate declarations,
sharing, identical scalar/hash inputs and no weak clearing. Relate states from
the owners' initialization, not just at the final task roots:

- `Ident.id_register` has one private incrementing ref and allocates a fresh
  identifier. Matching calls preserve its numeric value and identifier sharing.
- `Hashcons.Make` initializes next_tag=0 and `Weak.Make.create 5003`; all four
  instances use fresh record tagging. Induct on every hashcons/unique request.
  Equal hash inputs select equal bucket indices; related sharing and strict
  equality yield the same lookup outcome. Inserting uses the same first empty
  slot and growth/shrink/rehash algorithm, so table dimensions, cached hashes,
  oversize and rover agree at matching registration cuts. A unique goal advances
  the counter without entering a weak table. A hit does not manufacture a new
  tag merely because lookup work occurred. Hash arithmetic's intended modular
  behavior is distinct from the no-wrap obligation for unique counters.
- `Task.Stdecl` instantiates `Hcpt.MakeSet`. Its private implementation is
  `Ephemeron.K1.Make`, with create8192, deterministic seed zero and nextid=1.
  Leaves hash the preserved tdecl tag; branches hash their preserved prefix and
  child IDs. Related physical equality gives identical find/add outcomes,
  stored sizes and backing growth. AVL `Theory.Stdecl` is not substituted here.

The four functor implementations and their type/declaration/tdecl/task hashing
sites are pinned in `source-witnesses.json`. The argument uses the source
relation's valid tags, values and selected plugins; it does not follow from an
identity of complete heaps, addresses, GC colors or FileTags tables. The quiet
configuration changes only the already-reviewed command/time/diagnostic-location
roles; logging adds no input to these owners. The accepted combined relation
supplies exactly those exclusions. No entire combined configuration obligation
is reopened by this smaller table argument.

Initial no-wrap is not inferred merely from a small observed residue. Ident
uses the accepted initial-registration argument, including its special
increment-before-allocation pending-action check. The other owners have these
actual fresh candidate/tagging sites:

| Counter | Fresh record before each possible increment |
| --- | --- |
| Ty.Hsty | `ty.ml:103` allocates the tag copy; `:116–122` also builds a fresh `mk_ty` candidate. |
| Decl.Hsdecl | `decl.ml:391` allocates the tag copy; `:411–419` constructs the declaration and chooses hashcons or unique. |
| Theory.Hstdecl | `theory.ml:268` allocates the tag copy; `:272` constructs the tdecl candidate. |
| Task.Hstask | `task.ml:96` allocates the tag copy; `:99–106` constructs the task candidate. |
| Task.Stdecl.Hcpt | `hcpt.ml:157–158` allocates a leaf/branch before entering the find/miss path at `:154–156`. |

These are fixed-size small minor allocations under the retained native/source
relation. Hashcons's generic physical test `o == d` alone would not establish
fresh allocation for an arbitrary client; the actual tag functions do. Every
increment therefore has at least one previously allocated minor word. Without
a protected collection or minor-pointer reset, even abandoned candidates still
consume that allocation history. With initial value c0 and total minor bump B,
`c0 + increments <= c0 + B < 2^62` excludes a first signed wrap. Here c0=0 for
the four Hashcons instances and c0=1 for Hcpt: the latter would first wrap after
2^62−1 increments, not2^62. All these owners initialize after the protected
boundary. The common B bound is below2^28, using PID97103's retained
79,191,224-word bump through its later cut and the accepted combined bounds
for prospective registration. This is an initial count argument, not a claim
that later allocations cannot collect or fail.

### Input's later state is only an upper envelope

PID97103's protected interval begins before the first Why3 module. Its summary
has no protected GC/configuration guard hit, failure or new worker through
`inline_trivial_entry`. Minor collections stay at one (the earlier startup
collection), major collections and compactions at zero. Phase0 is **mark**,
not idle. The exact `probe.py` protected-switch sites are retained; no absence
of collection is inferred merely from a final live object count.

`Hashcons.Make` seals the weak table and exposes only hashcons, unique, iter
and stats. There is no client clear/remove/reset route. Each owner starts at
5003; an outer resize strictly increases the length and no operation reduces
it. Endpoint length5003 therefore excludes any earlier outer resize.

No weak clearing/removal means occupancy never decreases, but occupancy alone
would not prove allocated-slot monotonicity. Let an occupied full bucket of
length n grow to m=min(floor(3n/2)+3, cap). It then has at least n+1 occupied
slots. `prev_sz(m)=((m-3)*2+2)/3`, using OCaml truncation, is at most n: equality
holds without the clamp, and prev_sz is monotone when m is positive. Thus the
shrink test `live <= prev_sz(m)` fails. Before the first hypothetical shrink,
subsequent insertions preserve that inequality. An empty zero-length bucket
has prev_sz=-1, so it cannot shrink either. By first-shrink contradiction no
bucket shrinks. Allocated slots and maximum bucket length are consequently
nondecreasing through registration-to-post-CE. Their later values safely bound
the earlier state. Counts likewise increase without wrap by the previous
allocation argument.

Oversize and especially rover are **not** imported as monotone envelopes.
Rover can wrap modulo5003. The frozen weak transfer accepts arbitrary valid
inherited oversize/rover and includes a possible inherited resize; it consumes
only L, maximum bucket length and allocated slots. Their displayed Input
oversize/rover remain endpoint observations, not registration measurements.

Hcpt's private backing is reached only by find/add. There is no remove/reset
or external clear route; ordinary find does not clean. Resize cleans only dead
keys, and the protected interval has none. Stored size is therefore
nondecreasing, and outer length never decreases. The observed length8192 is
also its creation length, so the earlier length is8192. Its later771 stored
nodes and nextid772 are safe earlier upper bounds. None of this equates the
post-CE table to registration or subtracts an unmeasured CE delta.

## Source requests and common episode accounting

Use the actual 51/42/22/2/1 registered-root family, including its two trivial
roots, rather than R51's larger 64/53/32/3/1 raw selection. The new join matches
each R56 goal/task/formula against R51's frozen per-goal certificate and R58's
route rows. R55's guarded producer induction and the combined registration
relation supply the parallel caller attachment; the obsolete serial first-fill
caveat is not treated as a new unclosed combined-startup result.

For each process and additive stage demand D, use

```
sum_registered(D_z3 + D_cvc5 + D_altergo) + e * max_pair D,  0 <= e <= 2.
```

There is one e, two save-entering callbacks and at most three saves for the
**whole process**. The API accepts only that one e. Stage maxima can be added
conservatively using the same e; they grant no new exceptions. Save binder
charges already include three saves and e<=2 and are imported once, even if
a caller chooses a smaller e for preparation. Initial module/library/loading/
registration work is absorbed in the initial state and never added as a new
component. Input's initial value is an upper bound for registration, so the
**full** future update/CE allowance is used. The serial post-inline deductions
of15 and472 are inapplicable to this target cut and are not made.

Let C be the raw logical declarations including one goal, and H the accepted
R58 driver-independent task-node bound. H includes the metadata event envelope;
no selected driver `use` rule imports additional declarations here.

| Component | Six-owner requests/increments charged |
| --- | --- |
| Driver metadata update | R50 raw-goal binder registrations; at most H tdecl constructions, H task-add requests and 64H Hcpt constructors. Goal reattachment uses its existing tdecl, so adds no Hsdecl constructor. The complete accepted event inventory has exactly two MAty arguments, both one-node ground types (not merely two distinct output types); charge two Hsty calls per invocation for clone-meta substitution. |
| CE and Alt-Ergo ground monomorphisation | R51 exact direct Ident charge per registered goal; conservatively C Hsdecl constructions, one of them unique, C tdecls, H task-adds and 64H Hcpt constructions per CE. Mono adds one unique goal, one tdecl and one task; its separate goal-validator Ident charge remains. Neither route changes type descriptors or allocates a type symbol here. |
| First inline | Exact R56 Ident and kernel type-instantiation requests. Conservatively C Hsdecl constructions (one unique goal), C tdecls, H task-adds and 64H Hcpt constructors. R57 old-return traversal counts are not charged again as identity-producing operations. |
| R58 builtin/unused/detection | Import its separate direct Ident, Hsdecl, tdecl, task-add and type-application categories. Alt-Ergo has no detection. Charge 64 Hcpt calls per task-add; no term/type traversal total is silently substituted for constructor calls. |
| Save binders | Import the accepted shape-builder `fresh_variable_calls_upper`, already charged across all saves. It creates identifiers and pure local term/map objects; it does not reconstruct these declaration/task/history owners. |

The Hcpt multiplier follows the source Patricia insertion: a 63-bit key has
at most63 discriminating branches; a same-key replacement uses one leaf plus
its ancestor path, and a differing key can introduce one new branch only at a
previously unused discrimination position. Thus a leaf plus branch requests
number at most64. `Task.new_meta` and `new_clone` each perform one singleton/add;
ordinary logical insertion performs none. Counting every task-add overcharges
these mutually exclusive routes. `add_tdecl` does not recursively flatten a
Use theory; the different `use_export` operation stays with its actual owner.

The request and increment columns are separate. Each Hashcons request has at
most one increment; a unique goal has one increment and zero Weak.merge calls.
Hcpt increments only on its find miss, at most once per constructor request;
internal ephemeron rehash does not call Hcpt.hashcons. Later weak clearing may
increase misses within the charged calls; the frozen backing transfers already
allow clearing, cleanup, shrink and reinsertion. Unsuccessful comparator
traversals are not assigned identity increments, and their cost remains a
separate accepted interface.

| Domain | Known Ident increments, including saves | Known Hsdecl increments | Known Hsty requests | Known Hstdecl requests | Known Hstask requests | Known Hcpt requests |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 17199798 | 176619 | 485170 | 4275132833 | 19967897093 | 1277945410560 |
| Put | 13259024 | 145920 | 396524 | 3530432342 | 16492821080 | 1055540546304 |
| First_Or_Default | 4864603 | 42136 | 70351 | 962915994 | 4502791076 | 288178627328 |
| Is_Message | 232156 | 3560 | 4672 | 77777462 | 369421386 | 23642968448 |
| Input_Is_Valid | 314625 | 2684 | 3435 | 57329243 | 275163947 | 17610492416 |

These are known-component upper bounds, **not complete post-registration
process demand**. They are natural-number accounting values. Only actual
native counter endpoints, array lengths, bucket lengths and growth/shrink
operands are checked against machine limits. Their cumulative sum is not an
invented native variable. The retained Linux64 runtime/ordinary-header relation
uses max_int=2^62−1, Sys.max_array_length=2^54−1 and maximum ephemeron
keys=2^54−3; the exact Sys/Obj/runtime definitions are included in the source
witnesses. The installed choice is established by the accepted
[native runtime-limit witness](../evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json),
not by assuming the nonprofiling preprocessor branch. At ELF address0x9d5540,
`caml_sys_const_max_wosize` has retained bytes
`f30f1efa48b8ffffffffffff7f00c3`: `endbr64; movabs $0x7fffffffffffff,%rax; ret`.
Decoding the tagged return gives `(0x7fffffffffffff−1)/2 = 2^54−1`.
The witness's full ELF identity equals PID97103's captured mapped executable
(24,561,432 bytes, SHA256 `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`),
which the combined prefix relation retains. Its original checker mapped these
virtual addresses through ELF load segments and checked the instruction bytes;
this packet pins that result and decodes the immediate without replaying it.
The new check rejects a different runtime-limit value. No new disassembler or
target execution was needed. Ordinary allocator/OS physical resources retain
the trusted boundary; no aggregate RAM or time gate is introduced.

## Callable contract and remaining owners

`compose(residuals=None, escape=2)` consumes frozen inputs and the unchanged
pure `counter_transfer`, `weak_transfer` and `ephemeron_transfer`. It does not
call the predecessor compose/check functions. Each supplied residual must name
all six owners with explicit nonnegative `increments` and `requests`; Boolean,
negative, misspelled or partially specified vectors are rejected. Each process
requires the following distinct residual categories:

- `lookup_library_constructors`: all six-owner writes inside transform lookup,
  library parse/clone and initialization, including any lookup work before R58.
  This is an **earlier missing input**, not relabeled as later preparation.
- `later_preparation`: selected transforms after R58, including tuple generation
  and the constructors it invokes.
- `solver_request_printers`: term openings and other six-owner writes on the
  actual request-printing route.
- `other_callbacks_and_shutdown`: remaining six-owner writes outside the named
  transform/save-binder components. A zero here needs its own source argument.

The accepted [Theory publication bound](retained-why-publication-composition.md)
is attached as its existing W, with its original scope and premises. W counts
restore-path publications, **not** the number of parser/clone Ident or hashcons
calls. Neither W nor allocation-byte totals can fill the lookup constructor
vector. This missing constructor interface is exposed by the composition.
The exact next source question is: for each direct `int.Int` or `real.Real`
read selected by `eliminate_literal` environment initialization
(`eliminate_literal.ml:193–199`), what upper vector of Ident increments,
Hsdecl hashcons/unique calls, Hsty calls, Hstdecl calls, Hstask calls and Hcpt
leaf/branch requests covers the incremental WhyML parser, typing, program-module
cloning and implicit tuple construction, including failed prefixes and allowed
foreign restore-cache hits? `Driver.prepare_task:373–375` resolves the whole
transform list before `update_task` and before any CE/inline/R58 body. Thus a
transform listed after R58 can still load its libraries before that cut.

Reuse the accepted four-file DAG (`relations`, `algebra`, `int`, `real`), its
expanded-slot/read recurrences and the global tuple-memo replay allowances.
Supply separate per-direct-read base vectors and whole-process replay vectors,
then instantiate `lookup_library_constructors` using at most two literal roots
per admitted preparation episode and the same e. Initial static builtins and
all completed pre-registration driver/library loading stay absorbed by the
entry state. Post-registration cache misses, false misses or reparses are
additional calls; neither an initially loaded name nor the initial counter
absorbs them. The source question must also distinguish `Pmodule.clone_export'`
from the unused namespace walker, and justify any zero Hstask/Hcpt component
rather than assume that a library parse cannot reach it. No native rerun is
needed to answer this constructor-count question.

Missing residuals are listed and never replaced by zeros. Even completely
supplied numerical vectors establish only conditional arithmetic under the
caller's supplied bound contracts; they do not establish their provenance.
The whole-process flag is always false because other mutable owners and native
operands remain outside these six transfers. In particular:

| Reached memo owner | Writer / representation | Relation to this result |
| --- | --- | --- |
| Driver update Hint and its per-driver Trans.store Wtask | Hint add; Weakhtbl/Ephemeron replace | At most three selected driver identities, but false misses and memo-state/backing attachment retain their own obligation. They are not Hstask writes. |
| CE Trans.store_decl Wdecl and Trans.fold Wtask | Weakhtbl/Ephemeron replace after successful computation | Guarded producer/cache relation reused; complete backing state and insertion demand are a separate interface. Memo hits reduce the charged six-owner source walks. |
| Inline Trans.bind/store Wtask, metadata Wtds and fold Wtask | Same ephemeron representation, distinct closures | No counter is equated with Hcpt's private nextid. Their requests do not become Ident increments. |
| Hit-local type Wty and declaration/termination temporary maps | Fresh ephemeron/map instances | Covered semantic/type demand remains R56/R57; whole backing/primitive arithmetic still needs its own owner contract. |
| R58 transform fold/declaration/dependency memos | Per selected Trans closure; persistent maps and ephemeron tables | R58 operation counts are reused. These are not the six global hashcons tables. |
| Save/session tables and Theory restore-path | Accepted table-specific contracts | Reuse all206 applications:203 no-resize plus three Theory replacements, and attempt endpoints209/174/109/13/10. Their source process and behavior premises remain unchanged. No table proof is reconstructed. |

Thus `known_and_supplied_operands_fit` is a six-owner arithmetic result.
`through_R58_complete_including_lookup`, `actual_whole_process_headroom` and
`whole_pipeline_capacity` remain false. Closing lookup constructors, later
transforms/printers, the memo interfaces, callback/native operand closure and
source/caller correspondence is required before a whole-rule headroom claim.
This note changes no production, launcher, toolchain, Oracle or admission rule.

Selected author setting: **GPT-6 Astra / Extra High**, inherited assignment;
runtime confirmation, token use and monetary measurements unavailable.
`round.json` records actual elapsed/check scope and corrections. Parent owns
independent review, integration, GitHub status, durable memory and harness goal.
