# Selected report construction and private warning representation

2026-10-23 UTC; owner-authorized #119 / #153 author lane, pending independent
review. This closes the selected **reporting NONCORE representation** interface
left by [standard JSON inputs](retained-why-standard-json-inputs.md): report
trees and intermediate lists, small reporting tables, fixed format/annotation
objects and scalar conversions, answer strings, located warning copies, and
private `Loc.warning` construction. The
[packet](../evidence/retained-why-report-construction-20261023/README.md) retains
strict source spans, input identities, a conservative literal census and the
five-case arithmetic. It contains no compiler, solver, model or target run.

The result is a source-derived representation/finite-progress argument under
the existing source/native correspondence and ordinary runtime, physical
memory, stack and I/O sufficiency premises. It supplies **no aggregate RAM or
stack quota**, allocator proof, or deployment claim. The canonical-output
interface remains conditional. Startup, path/offset providers, raw solver
storage/parser construction, logging-channel capacity and the whole #119 goal
are separate. One global `e<=2`, two save-entering callbacks and three saves
are preserved, without renewal per owner or failed prefix.

## Inputs and exported guards

Use the [canonical interface](retained-why-canonical-json-input.md), accepted
collection ownership and occurrence bounds, the historical
[warning](retained-why-diagnostic-warnings.md) count `W_o`, and the terminal
scalar interface's symbolic `P/M/X`. For this new R69 join, the
[complete FileTags-origin theorem](retained-why-report-path-inputs.md) replaces
the earlier filename166/entry422 byte allowance with filename180/entry436:
`L_o<=436W_o`. Interrupted tag aliases may return a different admitted origin;
the complete origin domain supplies180 without association persistence or a
new counter/no-wrap proof. The historical R68 packet is unchanged. Counter
arithmetic and FileTags storage representation remain separate owners.
The accepted JSON schema supplies `S<=5R`, `K<=26`, depth at most seven,
`W=W_o+W_c+D<=W_o+O+N+1`, `L_A<=4O+64A`, `L_W<=L_o+L_c+H`, and
`D<=1,H<=26619`. Its formulas for C,V,F and scalar counts are unchanged.

| Case | R | G | A | N | O | W upper |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 22 | 64 | 169 | 155 | 12,844 | 254,970 |
| Put | 18 | 53 | 140 | 128 | 10,640 | 227,621 |
| First_Or_Default | 9 | 32 | 78 | 68 | 5,928 | 196,630 |
| Is_Message | 1 | 3 | 9 | 8 | 684 | 53,119 |
| Input_Is_Valid | 1 | 4 | 8 | 5 | 608 | 72,139 |

The local guards are:

* `R<=22<64` for the 32-bucket message table and at most five bindings in
  each 16-bucket stats table; neither can reach its resize threshold.
* All explicit report list lengths, count increments and sort sizes are below
  `max_int=2^62-1`; the displayed C,V,F,W,G,A bounds suffice. No list length
  is used as a contiguous-array allocation request.
* Every selected fixed non-string construction object has at most128 payload
  words. The new finite format census replaces the printer-specific90-byte
  literal ceiling; it does not reuse that ceiling for reporting templates.
* Per private answer: bytes<=368, events<=32, Buffer capacity<=512. Per located
  warning copy: bytes<=436, events<=32, capacity<=512. The default-margin
  sufficient guard `B+E+79<=1000000010` passes for both.
* Per enabled private Loc warning: offered bytes<=1024, core events<=128,
  capacity<=1600 from initial100. Its **margin1000000000** uses the special
  source argument below, not the default-margin guard.
* Abort annotations have raw bytes6, description4, integer digit1,
  Buffer16; the R67 bounded annotation-error Buffer256 route is retained.

The bounds include an allocation or mutation prefix that never produces a
returned string or JSON value. They do not replace the already owned standard
core/escaping bounds with another copy of those charges. The historical
`40V+24F+16Nf` remains a final-tree subset, **not cumulative construction**.
No cumulative direct-request total is asserted here or needed for these
representation guards under ordinary physical-memory sufficiency.

## Report records, lists, small tables and traversal

`Gnat_report` owns an initially empty HCheck table (`gnat_report.ml:32`).
`register` tests membership before adding one eight-field message; its key
comes from the accepted finite registered check domain. `ending` iterates that
domain once, builds the report once and has no local retry (`gnat_main.ml:213–279`).
Signal saving does not call report registration or mutate these private stats
tables. Interrupted registration can leave a partial prefix, but no receiving
continuation reinserts that key and resumes this same report. The selected
SIGINT save-and-exit path does not return normally. Classified returning
Thread/native clients resume without writing these private owners.

`extract_stats` creates Hprover5; `add_to_stat` inserts only a missing prover
and otherwise increments its three-field record. `adapt_stats` copies into
Hprover3; `get_stats` can add Checker once on the sole normal traversal.
There are at most four real keys plus Checker, including Trivial among the
real keys. No callback returns an alias to those local tables to a save.
The accepted table join already supplies valid hashes and finite bucket chains;
this lane adds their much smaller representation instance. Hashtbl.create
rounds17 to32 and3/5 to16; add resizes only when `size>2*capacity`
(`hashtbl.ml:68–76,354–362,477–484`). The arrays, bucket cells and four-field
table records therefore have fixed, represented sizes, even if all keys hash
to one bucket. The final primitive field writes contain no signal reentry into
the owner, and escaping exceptions abandon the construction.

`check_to_json` folds each finite GoalSet into cons cells. It visits each
physical attempt binding rather than deduplicating keys; the accepted A
already counts interrupted-publication duplicates. The selected current
reported leaves have empty transformation lists. The stat search selects at
most one proof per reported leaf or its selected finite transformation branch;
in the admitted leaf shape the latter is empty. Count increments are bounded
by G, not by a possibly wrapped integer count taken as an axiom.

Every JSON variant except Null has one payload field; fields, pairs, conses,
option wrappers, temporary refs and float boxes are small separate blocks.
The result fold produces R pairs, sort operates on that list, stats folds
produce at most five pairs, and timing fold produces at most K pairs. `get_msg`
concatenates four field lists of bounded length (at most eight total selected
fields); the root concatenates two lists (at most four fields). `List.concat`
copies proper left spines and preserves element pointers. Mapping warnings
copies at most W conses and creates at most W String constructors; it neither
concatenates their bytes nor allocates a W-element array. It snapshots the
persistent warning list; a signal's new prepend cannot cycle or enlarge that
already held immutable spine.

OCaml List.sort is stable_sort (`list.ml:320–389`): length counts a finite
proper list, the recursive sizes split by `n asr 1` and `n-n1`, and merge
consumes a head each time. Its only varying representation is additional
fixed cons cells and fixed closures. Normal comparisons use native integer
`compare`, without arithmetic subtraction; abort sorting compares only its
three fixed keys. Fold/map/concat and the selected finite JSON callback tree
decrease their source list/collection or strict JSON child. JSON cannot point
back to its parent: constructors wrap earlier immutable children. Accepted
session/check trees remain inputs, not a new arbitrary cyclic-graph premise.
This proves finite construction/traversal under ordinary stack sufficiency;
no stack-byte bound is inferred from an isolated scalar printer.

## Fixed accumulators, annotation helpers and scalar values

The [R67 representation argument](retained-why-format-accumulator.md) applies
to the same retained CamlinternalFormat constructors and OCaml closure/string
layout. This lane supplies its new selected callers: single-line and abort
JSON, answer `Pp.sprintf "%a"`, warning kfprintf, and the located-warning
`Format.sprintf "%s:(%d:%d)-(%d:%d): %s"`. The last route uses
**Format.strput_acc**, distinct from CamlinternalFormat.strput_acc used by
annotation failure. Both Format output accumulators recurse to their immutable
proper predecessor, then execute the current atom (`format.ml:1280–1393`).
No datum is reparsed as a format, and the selected callers use no dynamic
format substitution, precision, magic widths, custom format nodes or tags.
JSON's fixed `%04x` width4 is already covered by the byte-escape owner.

The packet bounds every double-quoted source literal in the reporting witness regions,
terminal witness regions and complete files in the retained warning census.
It scans overlapping candidates starting at every quote, so character/comment
quotes may produce extra candidates but cannot swallow a real literal's start.
This deliberately includes unused formats and ordinary strings. Four times
the maximum candidate size plus four is a conservative typed-format-node bound,
using the same source-to-format relation as R67. The census is a finite-format
size check; the selected call graph above and imported warning/terminal
partitions establish reachability. In particular Pp.formatted's dynamic-format
helper exists in the source but is not called by these report/warning routes.

Each make_printf step consumes a fixed format node, creating at most a fixed
atom/continuation; `%a` stores a callback and its argument by reference. The
JSON callback descends the finite tree; answer callbacks select one constructor;
the clone warning's list printer consumes a fixed raw path list. The report
fold/map closures capture existing tables, records, scalar references or one
accumulator, at most16 environment slots; sort's mutually recursive group
has two members. The generic formatting parser's three-member group and its
two captures remain as in R67. Compiler descriptor, curry/partial-application
and fixed record accounting therefore stay below the conservative128-word
payload bound. Neither number of list elements nor string length becomes a
closure's number of fields.

Single-line JSON opens no boxes. Each abort report's fixed boxed serializer
creates at most five annotation helpers, thus at most ten across its two
attempts. `compute_tag` makes Buffer16, prints `"<hv 1>"` (6bytes), flushes,
then slices to `"hv 1"` (4bytes). The parser scans increasing indices and
parses the one digit1. Other selected terminal annotations retain R67's
raw<=7/description<=5 envelope. The annotation-failure route is retained even
for a valid fixed description: a callback-origin Failure can enter the catch.
Its bounded46-byte CamlinternalFormat.strput_acc message uses Buffer256 and
does not resize. Failed annotations do not mutate their receiving main
formatter before the successful open action.

Native signed integers produce at most20 decimal bytes. Location coordinates
are already represented integer fields decoded by Loc.get; JSON IDs and
extra-info fields are copied, not multiplied. For steps, using a generic
signed-native input alone would be insufficient: `c-add` and final `+1` can
overflow at endpoints. The actual selected drivers have **no StepRegexp**
directive (StepLimitExceeded classifies an answer and does not add one).
Driver starts stepregexps empty and only that directive adds to it. Thus
normal parsed results use default `pr_steps=-1`; the empty-output-filename
branch uses0; initial Trivial uses1. Stats select/max these values without
changing that domain. For every selected conversion, `0<=add<=450000`,
`1<=mult<=800`, so `-450001<=c-add<=1` and
`(max 0 (c-add))/mult+1` is1 or2. Adapted stats are not converted again.
Checker's max_steps0 is inserted after adaptation. Lowercase/sub operations
consume the accepted fixed prover-name strings and the six fixed prefixes;
the substring guard tests its endpoints first.

The existing [float/timing](retained-why-exit-timing-format.md) and
[JSON byte/scalar](retained-why-json-byte-escape.md) owners retain `%g`<=13,
`%f`<=317 and their fixed format buffers/native result operands, including
special-value spellings. Finite floats are still required separately for
valid JSON semantics. This note does not turn numeric formatting capacity
into a proof that a supplied time is finite.

## Private answers and location prefixes

Pp.sprintf aliases Format.asprintf (`pp.ml:208`). The answer call creates
Buffer512 and one default-margin formatter, then invokes only
Call_provers.print_prover_answer (`:150–158`). Constants, at most two unit
breaks, and one raw payload string give bytes<=`4o+64<=368`, for canonical
o<=76. No nested box or indentation is introduced; a broken unit space emits
one newline at indent0. A ceiling32 includes source token events and final
flush/reset actions. Default-margin representation guards pass, contents is
at most368 and the initial512 buffer never resizes.

Gnat_report.add_warning first constructs the location prefix, if present,
using Format.sprintf and its **own** Buffer512. The six argument conversions
are raw strings and four native decimal integers; there are no formatting
breaks or boxes. The imported complete FileTags-origin bound180 plus the
existing256-byte allowance for fixed text, coordinates and punctuation gives
successful size<=436, which also
bounds every output/allocation prefix of this private owner. At most32
events and its final flush fit the ordinary private guard; capacity remains512.
No-location incompatible warnings and the final D/H Debug copy bypass this
formatter and are stored by reference. The global escape Buffer's existing
owner is not charged as a fresh Loc.warning.

## Loc.warning's large-margin specialization

`Loc.warning` allocates Buffer100 and a formatter, sets margin to1000000000,
opens one zero-indent user box, then tests its flag (`loc.ml:187–195`). The
setter preserves the existing max_indent68, computes min_space_left999999932,
and reinitializes (`format.ml:782–814`). Its arithmetic and all initial
queue/stack objects are represented. **Disabled warnings still construct
these objects.** They then call make_iprintf, which consumes the finite fixed
format without building an output accumulator or invoking `%a` callbacks.
Their actual argument values are references; discarded private owners perform
no later output. This per-invocation result does not infer their count from
W_o, which counts publications only. Their finite producer traversals retain
the existing selected-source termination premises.

Enabled ordinary warnings in the complete accepted census use literal text,
native decimal output or the initial clone's raw dot-separated path. They
introduce no nested user box, tag, explicit-width or newline token. Missing
parent adds one `@.`. Incompatible-answer warnings use three `@.` delimiters,
two answer callbacks, and the latter's unit break hints. No answer string is
interpreted as formatting. Two answer envelopes368 plus fixed text and three
newlines fit1024, and128 core events cover all of these alternatives (the
raw clone path has at most42bytes/components). W_o's own body is smaller;
1024 is a private-owner ceiling, not a replacement for L_o or L_c.

Partition a successful call at `@.` / final flush. Before a segment's flush,
the fresh system box is the unknown queue head, `left_total=1`, queued input
length<=1024<margin, so advance_left does not drain it. All user tokens remain
queued. The only user box is the initial Loc box, which the first flush closes
before setting right_total to `Pinf=1000000010`.

1. In the first segment, closing that box runs set_size(true), then
   set_size(false). All breaks and the user box now have known nonnegative
   sizes<=1024. There is no stale scan-stack entry, since nothing has drained.
   The system box drains because `Pinf-1>=margin` (nine bytes of slack).
   The user box opens at column0 and fits, so every break stays flat. All
   remaining tokens have known sizes and drain independently of that slack.
2. `@.` resets the core to the system box alone; the Loc user box is not
   reopened. A later segment contains only text/unit breaks. Every break but
   the last is sized by the next break; those known sizes<=1024 fit the huge
   remaining width. Until the last break, after consuming length q, both
   `left_total=1+q` and `space_left=margin-q`. Therefore the unknown last
   break's drain test is `Pinf-(1+q)>=margin-q`, again the same nine-byte slack.
   It may break, but its system-box width is margin and offset0, so indent0.
   Following tokens are text with known sizes; there is no later unknown
   break to stall. A segment without breaks is simpler.
3. There are no user open tokens after a large insertion point, and no
   forced-newline token before that last break. Raw newline bytes inside a
   payload are ordinary text bytes to Format and do not invalidate its scalar
   column invariant. The explicit `@.` emits its one extra newline after
   draining, then reinitializes all totals/stacks. Final flush similarly
   resets, without the extra newline.

Thus each segment drains in finitely many queue pops; all preflush totals are
at most1025, size negations/sums and flush-time differences are represented,
and only zero or one space/newline byte is offered for a unit break. Offered
bytes over the call remain<=1024. Buffer100 doubles through200,400,800,1600;
position+length, doubling, copy endpoints and contents<=1024 are all small.
No allocation approaches the maximum String/header size. This explains why
the default guard `B+E+margin+1<=Pinf` was unnecessarily strong here; it is
**not** applied to the large-margin owner.

## Failures, owner reuse and boundary

Each answer, located-copy, annotation and Loc warning formatter/Buffer is
lexically private. The source callbacks do not catch a formatting failure
and continue writing through that same private reference. An escaping signal,
allocation or service failure abandons the owner. SIGINT's save-and-exit path
does not resume; the separately classified returning Thread/native clients
do not mutate these owners and resume the same prefix. Loc's hook receives only
Buffer.contents after successful flush, not the formatter. Theory's local
Exit catch likewise cannot reuse the discarded warning owner. Repeated
warning opportunities create new private owners and retain the same global e
budget. Prefix failure can reduce publication without invalidating any
per-owner allocation operand bound.

Terminal exception formatting is different: registered-printer failure can
continue on a dirty private formatter. Import the
[terminal owner's](retained-why-terminal-diagnostic-bytes.md) interrupted-core
transfer and guards with its symbolic
`S=max(467,P+51,M+23,256)`, `K=467+12S+256`,
`Y=21*(8K+65536)`, `x_abort=Y+1024`, `X=2*x_abort`, `E_private=2256`.
Its per-owner guards, not the small-warning ceiling or a fresh-stream theorem,
cover these reused objects and their Buffer bounds. No path input is replaced
by the temporary P416/M444 orientation in this export. Terminal fixed-format
and annotation objects use the R67 representation instance above; terminal
payload growth, failed callback prefixes and copied strings remain owned by
that imported symbolic proof.

For every new small string/bytes allocation n in this lane, `(n+8)/8` rounds
to a represented payload of at most2^54-1 words, with padding index8w-1 and
0..7 padding bytes. The packet checks the actual small ceilings; the terminal
owner retains its own larger symbolic guard. Existing runtime/ABI behavior
and the identified source-to-installed-tool correspondence remain necessary.
This is scoped source assurance, not a native execution or a new attestation.
The focused check validates identities, strict spans and arithmetic; independent
review must assess the semantic argument. #119/#153 stay open and production
is unstarted.
