# Conditional operational bounds for the selected Why3 save

2026-10-20 UTC, Linux x86_64, authorized research #119 / #153;
base `dba4d5ec95f359e9752b91e9f447b4d49970da67`.

The selected save has a computable **operational** transfer without requiring
the two shape maps to be inverses, saved indices to identify their intended
formulas, or serialized prover IDs to be unique. The transfer bounds concrete
map growth, counters, list and string extents, dictionary output, prover-ID
search, serializer input and file-operation counts. Unknown entry state stays
unknown. It does **not** establish complete save capacity: the mutable-table
interruption contract and the formatter/native representations described below
still have to be joined. Independent review is pending.

The [packet](../evidence/retained-why-save-operational-bounds-20261020/README.md)
retains the executable transfer, source witnesses and focused boundary checks.
It imports the accepted [ordinary-ending control](retained-why-ordinary-ending-control.md),
[shape transfer](retained-why-session-shape-transfer.md) and
[artifact dependency](retained-why-save-artifact-dependency.md), including their
reviews. It neither reruns binder/alpha proofs nor strengthens their source,
private-printer, finite-term-opening, native-frame or selected-caller premises.
The fresh Per_Check, CE-off, automatic, non-replay continuation is essential.
Later cache reuse still requires faithful artifacts. Save remains required
execution before reporting and can interrupt proof preparation; there is no
observation-only exemption or new Oracle assumption here.

## Explicit input and composition boundary

Write `r = 1+k`, where `0 <= k <= 2` is the remaining callback budget supplied
by the accepted ordinary-ending protocol. This is an interval bound, not a
count of all process saves. Prior saves and registration may already have
changed the entry state. The same logical forest supplies `B,J,G,L` with actual
visit multiplicity. Its immutable task projection does not fix mutable attempt
records, statistics or save-table contents at every later entry.

All following quantities are nonnegative mathematical integers; each native
guard is a separate obligation. The entry schema needs:

| Family | Required upper bounds or contract |
| --- | --- |
| Global shape dictionary | `h0,i0`: initial persistent-map cardinalities; `n0`: nonnegative counter; `s0`: maximum map key/value string bytes; `a0`: absolute maximum of stored hyp-map indices; individually valid finite balanced maps |
| Saved goal shapes | Bound-table binding count, maximum existing list length `m0` and absolute index `b0`; old-shape maximum bytes; checksum maximum bytes; valid lookup payloads and separate mutable-table prefix contract |
| Shape Buffer | Valid entry position/backing/capacity, no unmodeled alias mutator, accepted no-return-to-interrupted-append contract |
| Attempts and provers | `A`: statistics-table binding visits per save; `Axml`: sum of goal-attempt binding visits in XML traversal; entry prover-ID **binding visits**, scalar size, bucket capacity and absolute ID bound, recorded separately |
| Forest serializer | File, theory, APn and transformation occurrences; argument/path-component occurrences; raw string byte sum over actual output occurrences; restored identifier-path joining lengths; scalar formatter output bound |
| Files and runtime | Session-directory bytes, selected no-compression route, container/string/native format and I/O representation contracts; live lookup coverage for any claimed normal completion |

Bindings count duplicates, while forest counts include repeated visits. `A`
and `Axml` need not agree. Captured pointer identities alone do not prove
structural equality of absent prover records. A finite input must bound every
save in this interval, including attempts/statuses installed after a capture.
Freshness does not imply an empty dictionary, Buffer or prover-ID table at
ordinary ending. Missing retained words cannot be reconstructed as zero.

Explanation bytes have the existing separate interface. For a joined prefix
count `p`, attribute-union cardinality `u` and bytes `s`, put
`E = max(11, p*(s+2*u)+1)`. `L` bounds shape Buffer appends and excludes E.
This packet accepts a supplied p; it does not infer the mutable configuration
from the five formula captures. The lead owns the selected-configuration join.
The executable requires `shape_output_input_ready=true` to consume L and
`typed_attribute_closure_established=true` to export E. Missing or false flags
leave the respective byte bound unknown even if numeric fields are present.
The check supplies shape-output readiness only for the exact accepted,
hash-bound shape packet, under its existing conditional contract.

## Persistent shape maps and scalar n

`Gshape.clear_gs` assigns empty hyp-map, empty index-map, then zero n
(`termcode.ml:566–569`). `add_shape` protects only its lookup with `Not_found`;
the handler performs a hyp-map assignment, an index-map assignment, increments
n, then returns `n-1` (`:571–577`). These writes are not a transaction. A
nested save can clear or change them before an outer lookup's miss continuation
runs. The accepted source continuation bound supplies at most

```
C = r*J                          insertion calls, hence at most C increments
N = n0 + C                       upper bound for n and any newly read index
H = h0 + C                       hyp-map cardinality
I = i0 + C                       index-map cardinality
S = max(s0, r*L, E)               dictionary string length
```

Each assigned map is either empty or one persistent `Extmap.add` result.
An add can increase its argument's cardinality by at most one; incomplete
construction cannot publish a partially built tree. A stale root may replace a
newer root, but it is an earlier root within the same global bound. Immutable
map snapshots being traversed retain that property after the mutable field is
reassigned. The bound counts insertion **attempts**, not distinct strings or
successful dictionary pairs. Reset reduces n; each source increment raises it
by one. `N <= max_int` prevents the increment boundary. We conservatively allow
`-1` for the returned `n-1` when calculating signed-string sizes, without
claiming that this inconsistent read is reachable under the stronger no-return
protocol. Native integer representation and valid comparison remain premises.

Let `D=max(H,I)`. The selected Extmap implementation recurses down a finite
search path and allocates at most four nodes per level, including rotations
(`extmap.ml:112–162`). There are at most two adds per insertion, so
`8*C*(D+1)` bounds newly allocated map nodes, including abandoned construction
prefixes. This deliberately loose cumulative bound also covers earlier roots
retained by suspended frames. Existing tree nodes are additional entry storage.
The native height-arithmetic guard is `D+2 <= max_int`. String storage can be
bounded by the entry strings plus at most C newly retained strings of length S;
two map references to one string do not require another string allocation.
This is a bound on the specified dictionary work, not on all term/GC storage.

`Shape.shape_buffer` is cleared on entry to each bound-shape task and after
each proposition. The accepted no-return lemma excludes a stale interrupted
append later committing its old position. Its post-first-clear extent is at
most `r*L`; before that clear, the entry position is separately bounded.
Each `Buffer.contents` copy has length at most `r*L`, including output affected
by a nested save. Buffer capacity is at most
`max(cap0, min(max_string_length, 2*max(1,r*L)))` under valid entry backing and
the accepted Buffer/native frame contract. Growth doubles only while its
current capacity is below the requested extent, then caps at max string length;
the intermediate doubling stays represented on the retained 64-bit runtime
when that extent passes the string guard. Old large backing is allowed.

No inverse dictionary theorem occurs in these arguments. `write_shape_to_file`
iterates one immutable index-map root and prints each value plus newline
(`termcode.ml:587–590`), so its bytes per invocation are at most `I*(S+1)`.
It does not dereference saved list indices or validate their meaning.

## Lists, checksums and the mutable-table boundary

Each private `current_shape` gains at most one cons cell per nonempty
`add_and_prepend` call. Nested saving has another local list. Across the interval
there are at most C new such cells; one returned list has length at most J.
Existing bound lists remain possible after partial clearing, so use

```
M = max(m0,J)
Aindex = max(a0,b0,N,1)
W = M*(digits(Aindex)+2)
```

for `string_of_shape` output: one optional minus per integer and at most one H
separator per item. This formatter has only integers and literal separators,
with no breaks (`termcode.ml:265–269`, `pp.ml:29–40,119–121`). It is fresh and
not shared with a nested save. W bounds its Buffer result under the scalar
format/helper contracts; W must independently fit the string representation.
Old-shape fallback uses its entry maximum, not W.

`compute_and_add_shape` calls `Hpn.add`, not replace (`session_itp.ml:174–183`).
There are at most `r*G` calls, and potential duplicate bindings must be counted.
Under the **prefix traversal contract below**, bound-table binding visits are
at most their entry count plus `r*G`. `clear_only_shape` does not clear checksums;
`find_sum` can return an existing checksum or the empty default. It does not
recompute checksums. Assuming the serializer actually reaches its calls, the
shape-file bytes per save are bounded by

```
25 + I*(S+1) + G*(checksum_max + max(W,old_shape_max) + 2).
```

The first 25 is the 24-byte SV6 header and one separator newline. Each goal
adds checksum, space, saved shape and newline. Multiply by r for all reached
saves, counting bytes even if another save truncates the same file later.

The mutable-table prefix contract is a **remaining representation obligation**,
not a consequence of type correctness or the formula bounds. Every reached
lookup/iteration must traverse a finite acyclic bucket structure; insertion,
clearing, relocation, interrupted traversals and caught exceptions must satisfy
the stated binding-visit bounds, scalar bounds and key/payload validity. In
particular, a bound on unique keys or scalar `Hashtbl.length` is insufficient.
OCaml `clear` writes `size=0` before `Array.fill` (`hashtbl.ml:78–83`), and
`resize` publishes `h.data` before `insert_all_buckets` finishes; in-place tail
links are finalized afterward (`:113–152`). These source facts prevent an
unjustified atomic-clear/rehash assumption. They do not alone demonstrate a
reachable bad native poll or prove an actual cyclic table.

The accepted catch ledger permits higher continuations after a nested save
raises; it supplies no blanket transaction rollback. To discharge this join,
one must prove the relevant native polls cannot expose a harmful intermediate
state, prove the weaker prefix traversal invariant at those polls, or supply a
capacity guard avoiding the relevant rehash. Inventing a larger cardinality
does not establish termination of a possibly unvalidated chain. This packet
therefore does not silently mark the mutable-table contract established.

## Prover statistics, IDs and serializer storage

`get_used_provers_with_stats` visits the attempt table and uses a private
prover table plus three frequency tables (`session_itp.ml:1952–1976`). A
spurious caught `Not_found` can create another prover binding, even for a
previously seen prover. Consequently **A**, not the number of distinct provers,
bounds the private prover-table bindings. Each frequency is incremented once
per applicable attempt and is at most A; each frequency table has at most A
bindings. The total three frequency-table insertion opportunities are `3*A`.
Nested saving does not alias these private tables. Their mutation bodies are
outside the local missing-key catches: a throwing mutation abandons that
computation instead of returning a partially mutated private table for reuse.
Underlying scalar hash/equality and native allocation/error contracts remain
necessary, including when a failure exits this component.

Each private prover binding causes at most one `get_prover_to_save` call.
Across r saves there are at most `r*A` additions to shared `session_prover_ids`.
Under its prefix traversal contract, if initial binding visits are `V0`, use
`V=V0+r*A`. Scalar size has a distinct bound `size0+r*A`.
The local `occurs` table adds one binding for every shared-table visit.
Its IDs need not be unique, consecutive or nonnegative. Its nonnegative
occupied values number at most V, so search starting at zero encounters a hole
by V. Each successful test increments the candidate; `Not_found` or a caught
`Exit` can stop earlier. Such premature stopping can duplicate an ID but cannot
increase this operational bound. Require `V+1 <= max_int` conservatively.
Existing ID magnitudes are carried independently for printing. Both
`PHprover.add` after the Exit and the final `Mprover.add` occur outside the
search's protected expression; they do not restart the loop.

One useful sufficient **arithmetic** no-resize guard for this shared table is
`size0+r*A <= 2*entry_bucket_capacity`, with positive valid bucket capacity.
The table is not cleared by save. Given a valid compatible table at entry and
the native frame contract for its short insertion stores, this avoids the
rehash path. Passing this inequality alone does not establish those entry/frame
premises or any other hash table's capacity. The executable returns the guard
separately; it never treats it as a completed prefix proof.

Prover Mprover/Mint trees, goal-attempt lists and transformation lists are local.
Their sizes are bounded by A, Axml and the actual transformation occurrences T.
`List.sort` computes native list lengths and allocates merge lists; input lists
have at most `Axml+T` cells in total per save. A deliberately loose
`4*(Axml+T)*(Axml+T+1)` bounds sort-allocated cons cells; the selected finite
merge recursion does at most a linear number of allocations per level and at
most n levels for n input elements. Length and stack/resource guards remain
separate. Each transformation's private `arg_id` begins at zero and increments
once per argument, bounded by total argument visits. File/theory status cache
misses can perform one add per visited file/theory; these shared tables also
retain the prefix contract. Missing live goal/attempt/transformation/prover
lookups can still abort serialization; artifact nondependence does not supply
their coverage.

For the XML input interface, let
`Q=1+F+Th+G+T+Axml+A+Args+Paths`, counting all occurrences above; let U be the
sum of unescaped string lengths actually presented by these operations, and d
a joined upper bound for scalar `%i/%d/%g` conversion output. Inspection of
the fixed formats (`session_itp.ml:2021–2209`) gives the conservative source
text allowance `1024*Q + 6*U + 32*Q*d`, with at most `128*Q+U` direct source
print/token events. The factors exceed each fixed per-node format, optional
attribute and scalar count; `html_char` expands one input byte to at most six
(`&quot;`). These are **formatter input** bounds, not total output bytes,
formatter allocation counts or a proof of its internal arithmetic. Breaks,
indentation, queues, accumulator construction, scalar conversions and channel
callbacks still require the formatter/native owner. The accepted formatter
prefix supplies a zero-direct-identifier-effect family, not those capacities.

`save_ident` can join `Theory.restore_path` components with dots before HTML
escaping. Original identifier-name maximum alone does not bound that string.
The input must cover the restored path or prove its fallback condition, as well
as its concatenation arithmetic. Missing prover strings, scripts, file formats,
transformation arguments and `proofn_expl` similarly remain explicit. The
direct explanation E bound does not bound all these XML strings.

## File paths, outcomes and residual owner

The selected `Compress_none` module aliases Stdlib; it creates no compression
state. Session save constructs three filenames and calls backup on each before
opening XML and shape outputs (`session_itp.ml:2233–2244`). With session-dir
length Ddir, each filename including `.bak` has length at most `Ddir+20` on the
selected Unix path implementation. This covers the 15-byte longest basename,
one separator and four backup bytes. Each save has at most six existence tests,
three removals, three renames and two channel-open calls; hence at most `2*r`
new channels can remain unclosed after failed prefixes. This is an addition to
already open channels. There is no encompassing cleanup `Fun.protect`.

A normally completed ordinary save proceeds to reporting. A save-origin
exception can be consumed by one of the named higher catches and leave changed
tables, counters, channels and partial files, or escape ordinary ending and
prevent normal result JSON. A SIGINT save exits or raises; it never normally
resumes an interrupted Buffer operation. Timed-save finally, error formatting,
exit hooks and diagnostics retain their separately owned effects. An exception
name alone neither demonstrates external resource exhaustion nor validates a
representation failure. No successful current result is inferred from a
partial file or from these upper bounds.

The **remaining full-save owner** must attach actual entry bounds and every
later attempted-save state to this transfer; discharge the mutable-table prefix
and live-lookup contracts; bound the private term/printer/formatter containers,
Format counters/queues, decimal temporaries, native hashes/strings/allocation,
channel/file-offset and pathname services; and compose the reached
diagnostic/exit/callback charges. Required service success and sufficient
physical resources cannot replace finite-representation proofs. Whole-process
identifier headroom and other owners, all-pair driver preparation, solver,
result/report and current-grammar assurance remain separate. No production
88–94 work, source admission, tool/pin change or complete-capacity flag follows.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements unavailable. Round timing and the brief lead-directed
authorization pause are recorded in the packet. No native/proof/solver/capture
run, predecessor checker replay, source fetch, GitHub write or CLI-memory update
occurred. Root owns integration, issue and durable-memory bookkeeping.
