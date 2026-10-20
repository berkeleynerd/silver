# Quiet-command prefix transfer

2026-10-20 UTC, Linux x86_64; prospective research for #119 / #153.
The [direct base-config route](retained-cvc5-quiet-route.md) admits a bounded
source transfer to the retained Why3 prefix cuts. Replacing its one 44-byte
ordinary CVC5 command by the specified 167-byte command adds at most **4,096
managed words** before those cuts. The retained GC margins suffice for that
perturbation. Consequently the semantic graphs, identifier-registration order,
driver objects and their import associations transfer by a consistent graph
renaming. This is a conditional prefix result, not a new execution, production
adoption, complete task-writer bound, or complete q/O.

The [packet](../evidence/retained-quiet-prefix-transfer-20261020/README.md) checks
the exact command change, source witnesses, capture attachment, resource
inequalities and five initial-count applications. The source simulation below
is reviewed reasoning; the Python checker does not prove OCaml semantics.
The existing relevant-source/tool/runtime premise is unchanged.

## Paired executions and exact cuts

Start with each retained invocation, including executable, selected input JSON,
library/driver/plugin bytes, cwd and pathname spelling, environment, fresh
session, flags and ordinary native services. Keep all of these fixed; replace
only the ordinary `command` of the builtin CVC5 record in cwd `why3.conf`.
Its prover name, version, alternative, shortcut, driver and `command_steps`
remain fixed. The base grows 1,946 to 2,069 bytes. The 18-byte private extra
config is unchanged. This result does not also change `--warn-timeout`, `-j`,
socket paths or the generated command's filename. Such changes need their own
join. In particular it does not adopt the complete all-zero orchestration
described prospectively in the route note.

Both executions use `OCAMLRUNPARAM=s=256M,h=16M,M=1000`. The relation begins
at the first `Exn_printer.entry`, before Why3's counters and caches; config
reading occurs later. The earlier runtime/Re startup collection stays before
this boundary. Between the boundary and cut, use the established ordinary
successful-service relation: no delivered asynchronous callback/interruption
that changes application control or aborts a registration, no injected native
exception/stack fault, no extra OCaml worker, profiling or GC override. This
is the controlled successful-prefix scope of the
[GC argument](retained-producer-prefix-gc.md), not a claim that a production
process inherits a debugger's signal-stop policy. Resource-triggered collection
and size-induced representation failures are ruled out below, not assumed away.

The later capture family used by the
[initial-registration bound](retained-why-initial-registration-bound.md) has
four registration endpoints and one different endpoint:

| Case | Retained PID | Cut | Initial registrations I |
| --- | ---: | --- | ---: |
| Put_Line | 17310 | Before first `Gnat_checks.iter` body | 136,844 |
| Put | 17514 | Same | 121,505 |
| First_Or_Default | 17631 | Same | 77,806 |
| Is_Message | 17704 | Same | 59,035 |
| Input_Is_Valid | 17869 | First CVC5 `inline_trivial` entry, before application | 60,496 |

Every retained base config is byte-identical to the route's baseline. The packet
reattaches each current snapshot to its own capture and invocation. It does not
substitute the older fixed-tail allocation totals for these later captures.

## Command opacity and semantic projection

`Rc` returns values without lexer positions: `rc_value`, `make_t` and
`rstring` (`rc.mll:17–22,134–148,255–257`) retain section/field keys and string
payloads; `rstring` returns that payload. The extra characters change no keys,
field counts, parse branches, source locations attached to Why3 symbols, or
config-map shape. Both command strings contain no quote, backslash or newline;
every character selects the same ordinary-character action. The changed
`lex_curr_p.pos_cnum`, lexer buffer contents and shared `Rc.buf` capacity have
no consumer in typing, tag registration or task generation.

`RC_load.load_prover` stores the payload in `config_prover.command`
(`whyconf.ml:335–369`). Prover equality, comparison and hashing use only name,
version and alternative (`:79–105`). Config maps use those prover keys or the
unchanged section/field names, never a structural hash of the whole config.
`Gnat_util.get_gnatprove_config` changes only driver locations; builtin
selection, plugin selection and extra-config merging are unchanged
(`gnat_util.ml:100–123`; `gnat_config.ml:345–414`). The only selected plugins
remain `gnat_json` and `ada_terms`.

`Controller_itp.load_drivers` iterates the same nine records in the same order
(`controller_itp.ml:114–122`). `Driver.load_driver_for_prover` reads only
`driver` and `extra_drivers` (`driver.ml:281–283`); the command is not stored
in the resulting `Driver` object. Driver tags, theory keys and shared imported
objects therefore correspond. The source consumer inventory in the packet
separates config serialization/extensions and other executable entry points
from the selected prefix. None reads the command to hash, compare, register a
symbol or choose a transformation before registration.

Input_Is_Valid additionally calls `get_complete_command` once, through
`build_prover_call` (`controller_itp.ml:411–432`). With zero steps it selects
the changed ordinary string and joins empty extra options. In OCaml 4.14.2,
even this singleton `String.concat` copies the string; its extra 15 managed
words are included below. `Driver.prove_task` calls `prepare_task` before
`prove_task_prepared` (`driver.ml:490–494`). Preparation and its first
`counterexamples_dependent_intros` transform depend on the driver/task, not
the command. The captured first-inline cut precedes inlining, task printing,
`Call_provers.actualcommand`, `%f` substitution, argument queues and server
request serialization. There is **no additional command-token queue element
before any of these cuts**. Existing scheduler/session queues have the same
logical members; they do not inspect the changed string.

Project the state onto immutable terms/types/theories/declarations, symbol and
driver tags, raw task/session/check graphs, sharing, selected driver root/import
associations, and the logical keys/values of their caches. Remove configuration
payload/lexer storage and wall-clock timing values from this projection. The
existing prefix cache argument supplies address-independent hashing and equality
that respects sharing. Until a first collection, matching requests therefore
give matching cache decisions. This is a graph isomorphism, including shared
edges and semantic integer/string fields; it does not identify native addresses,
bump pointers, complete heaps, formatter queues/backings or arbitrary snapshots.
In particular, graph projection alone would not preserve weak caches after GC.

## Allocation and representation delta

For a byte/string payload of n bytes on the retained 64-bit runtime, count
`S(n) = 1 + floor((n+8)/8)` managed words, including the header
(`runtime/alloc.c:79–94`). The following are source upper bounds, allowing the
compiler to eliminate local objects. They are not a measured machine delta.

| Changed allocation | Added words through registration |
| --- | ---: |
| 123 accepted lexer actions, each at most one four-field position | 615 |
| Shared `Rc.buf` new 136-byte and 272-byte backings | 19 + 36 |
| At most two `Buffer.resize` ref cells | 4 |
| `Buffer.contents` command copy, `S(167)-S(44)` | 15 |
| Table-generator subtotal | 689 |
| Conservative direct-code lexer allowance, 123 × 2 × 6 | 1,476 |
| Bound covering either OCaml lexer generator | 2,165 |
| Input_Is_Valid's one complete-command copy, if reached | 15 |
| Uniform selected bound Δ | **4,096** |

`Rc.buf` starts with capacity 17. Both base files first grow it through 34 and
68; only the candidate also reaches 136 and 272. Every other quoted field is
at most 61 bytes; clearing the buffer retains its backing. Thus there is no
unaccounted later growth caused by the changed capacity (`buffer.ml:33–39,
59–63,79–102,132–137`). The parsed value wrapper, field list cells, map nodes
and prover records have the same sizes and multiplicities.

The per-character lexer cost deserves explicit treatment. `Lexing.engine` and
`new_engine` allocate one position record on an accepted action, not on a
refill continuation (`lexing.ml:64–87`). `string_val` has only single-character
captures at fixed offsets zero or one. The static optimization in
`lex/lexgen.ml:332–369,425–483` removes their tags; its entry needs no `lex_mem`
array. `lex/common.ml:128–157` emits nonoptional `sub_lexeme_char`, a byte read,
not a substring or option allocation. The table generator emits no custom
refill closure for this lexer (`lex/output.ml:75–120`).

For completeness the bound also covers the direct-code generator, avoiding an
extra build-mode assumption. With no custom refill handler, each character
transition returns at most one five-field tuple (six words), whether it reads
the backing directly or refills (`lex/outputbis.ml:57–81,227–244`). An ordinary
`string_val` action consumes one character, with at most one further lookahead;
no unbounded expression can match in that entry. Charge two such tuples per
extra character, even though the accepting state can return immediately.
No callback closure is emitted on this branch. Refill chunk boundaries can
change, but the refill helper returns the transition's tuple rather than an
additional tuple per read, and its empty-read/EOF recursion is a tail call.
The remaining lexical action sequence is unchanged.

`Lexing.from_channel` has fixed 512-byte auxiliary and 1,024-byte input
backings. The packet checks both files' concrete lexical tokens; quoted values
are one-character actions, not a 167-byte lexer token. The maximum retained
token is 16 bytes; adding one lookahead byte stays below 512. A refill retains less than 512
bytes and reads at most 512; compaction fits 1,024 and the lexer backing does
not grow (`lexing.ml:89–169`). Successful native `input` copies into an existing
channel/backing and returns an immediate integer (`runtime/io.c:802–839`).
The channel object and its fixed C buffer have unchanged size. Neither extra
file bytes nor refill count introduce a custom-resource allocation.

The largest new payload block has 35 fields (272-byte backing), below
`Max_young_wosize=256`. The enlarged command has 21 fields. Positions, refs
and optional direct-code tuples are also minor allocations. No original
allocation crosses the minor/major threshold. Ordinary recursion is tail
recursive, and both extra resize loops have one doubling step, so the added
characters introduce no growing native stack representation. All lexer
offsets, lengths and growth arithmetic remain below 2,070 or 1,024, far below
their signed integer/string limits.

Use an additional conservative remembered-reference allowance **R=4,096**.
Extra position updates write two pointer fields per action; backing changes
write two more in total. Even charging every field of the added position,
ref/tuple objects and the extra command-copy path as a remembered-reference
insertion stays below R. In fact the lexer and buffer objects are minor and
their updates do not enter that table. Unchanged writes retain the same
minor/major age classification under graph renaming. Ephemeron/custom-object
requests and custom-resource fractions are unchanged. Applying R to all three
table margins below is deliberately weaker than these source facts.

## First-event inequalities and preserved initial counts

The packet reconstructs these maxima from the five **later** capture snapshots:

| Trigger quantity | Retained maximum | Candidate bound | Trigger |
| --- | ---: | ---: | ---: |
| Minor bump words | 127,939,731 | 127,943,827 | 268,435,456 |
| Cumulative major words | 945,213 | 945,213 | 268,435,456 |
| Reference-table entries | 68,961 | 73,057 | 33,554,432 |
| Ephemeron-table entries | 146,291 | 150,387 | 33,554,432 |
| Custom-table entries | 84 | 4,180 | 33,554,432 |

Minor and major custom-resource fractions remain respectively at most
0.00030899095108339816 and 0.005198286960875475, both below one. Dependent
memory is zero. The initial major phase is idle and all request/collection
statistics stay at their baseline in the retained prefixes. The checker
verifies the actual active minor pointer, trigger address, arena sizes and
table thresholds, not just those printed maxima.

Suppose the paired candidate first reaches a collection/request before its cut.
Up to that event the source projection, unchanged allocation sizes outside the
bounded lexer/copy subtrace, and unchanged weak-cache availability give the
same semantic requests. Minor usage is bounded by retained usage plus Δ;
major/custom/dependent requests agree; remembered-table usage is bounded by
retained usage plus R. All are monotone during this interval and strictly below
their triggers. There is no selected explicit collection/setting override or
independent asynchronous route under the named prefix relation. Thus no first
event exists. This proves cache preservation together with the resource bound;
it does not assume cache preservation after an unexamined threshold crossing.

The changed parser/copy subtrace registers no Why identifier or driver. The
unchanged semantic requests therefore register the same identifiers, in order.
For each candidate, `5*N <= B_minor + Δ < 2^28`; under the ordinary
no-abandoned-registration relation stated above, the
[native five-word witness](retained-why-initial-registration-bound.md) rules out
a first identifier wrap. Hence the candidate count is the displayed I and the
registered identifiers remain injective. This preserves the association of raw
task Use/Clone keys with driver theory objects, not merely an identifier count.
The initial type-symbol count and initial tuple-registry additions remain at
most I; their two arity-family union has cardinality at most `2*I`. These are
not bounds on maximum arity or on later registrations.

Independently, applying the same Δ to the older accepted
[fixed-tail prefix](retained-producer-fixed-tail.md) gives
`W' <= 128,851,857`, `B' <= 131,047,850 < 2^27`,
`W'+1 < 2^47-1`, and `16*B'+2 = 2,096,765,602 < 2^62-1`.
Its identical semantic operation trace retains maximum 47 through its own
registration cut. This is a perturbation of that older capture family; it does
not extend its count coverage to Input_Is_Valid's later first-inline cut.

The remaining continuation must still supply every later counter increment,
task/argument/output size, save/report capacity and attributable resource or
cancellation outcome. The [preparation bounds](retained-why-preparation-bound.md)
retain their explicit input requirements. This result makes the command-only
prefix transfer concrete; it does not fill those other summands or complete
#119. Production work #88–#94 remains unstarted.
