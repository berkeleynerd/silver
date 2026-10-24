# Retained reported-time regex: installed lifecycle

This #206 sub-result covers the final `Re.Str.regexp` owner constructed by
`Call_provers.timeregexp`, and searches of that owner at position zero. The
selected pattern is the two bytes **`5c 3d`**, backslash then equals, meaning
`Start` in this installed parser. It has no timing-unit placeholders. Three
separate calls construct three owners per selected driver, nine across three
driver loads. The driver text, placeholder substitution and timing-result
composition belong to the [parent argument](retained-reported-time-capacity.md).

The installed Linux x86-64 `gnatwhy3` remains 24,561,432 bytes, SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
We reuse the reviewed [R72 relation](retained-re-native-correspondence.md),
retained reference commit `f09672608781dc05172ad980a6e9a483c3b9d534`, and add
the narrowly selected native bodies in the
[packet](../evidence/retained-reported-time-native-20261024/README.md).
The reference is a semantic aid, **not an installed version identification**.
No target or Re engine was executed. The ordinary runtime, callback, physical
memory and stack premises remain those of R72; the numbers below bound owned
OCaml allocations and representation, not process RSS or collector copying.

## Correcting the candidate at the native parser

The earlier backslash-backtick candidate is rejected. Native
`Str.compile_regexp_445` calls `Emacs.re_no_emacs_605`; that function passes
tagged false to `parse_319` at `9272e8`. The parser puts this flag at root
closure offset `b8` (`9265fb`), while the atom closure starts at offset `78`
(`92658b`). Thus the flag read at atom offset `40` is false.
`atom_361:926bb1–926bb5` skips the backtick-to-BOS branch. Its ordinary escape
fallback at `926ed0–926f15` returns the literal character through Dense_map.
An output without a backtick therefore defeats that candidate without any
exception. The reference Emacs source lacks this installed dialect gate.

For backslash-equals, the same atom reaches the **ungated** comparison with
tagged character `7b` at `926c11`; `926c21` returns immediate `11` (tagged8,
`Start`). `Ast.seq_1210` unwraps the singleton branch. The new retained
`Ast.anchored_1569:91e25f–91e265` recognizes immediate8 and returns true at
`91e2dc`. Consequently `compile_2099` takes its Group-only branch and omits
the `Any*` search prefix. This is a native control argument, not a regex sample.

## Shape and one-step match

The Group/Start translation is

```
Seq First (Mark 0) (Seq First (After search_boundary) (Mark 1))
```

Native Group dispatch is `9ee468[4] -> 922d18`; its mark counter advances
by two logical marks at `922da3`. Immediate Start dispatch is
`9ee440[8] -> 9229ac`, passing tagged65, logical32, to `after_1178`.
The two marks, two sequences and one After allocate exactly five expressions;
their fresh local IDs are1..5. No repeat, rename or character-set translation
is selected. `handle_case` preserves the immediate, and native colorize
dispatch sends Group to its child and Start to the return-without-split branch.
The 257-byte color map remains all zero. Flatten produces one ordinary color,
256 zero color bytes and a one-byte representative containing255; `lnl=-1`.

Every call starts at position0. `make_match_str_1508:921564–921588` computes
initial category `1 | 32 = 33`. Deriving the tree visits exactly its five
expressions: the first mark adds `(0,-1)`; After succeeds since `33 & 32 !=0`;
the second mark adds `(1,-1)`. Both First-sequence splits have empty before
and after lists. The result is the singleton `TMatch` with these two marks.
It is independent of the next character/category. The nonempty scan validates
at most once, publishes the transition, then immediately takes the break-state
return at the same input position. Empty input instead derives once in the
final-boundary routine, with category33. Neither case scans the rest of the
string, constructs a substring, or reads a timing group.

Before index assignment all mark indices are -1. The native duplicate-removal
loop selects its TMatch branch at `918d70`, allocates only a singleton cons,
and never calls Hash_set.mem/add. The scratch option starts None and therefore
stays None forever; clear returns immediately at `9143b3–9143bc`. This removes
the large packed-table bounds from this particular owner entirely.

`free_index_1999` resets the bitvector before traversing marks. Its callback
`fun_3340` skips negative indices. Thus the sole bit remains zero, find_free
returns0, growth is never selected, and the working hint remains **0**.
`marks_set_idx_1397` replaces the two -1 entries by0 in fresh immutable list
nodes. Each `make_1214` allocates a fresh **one-element** positions array and
two-field positions record. Both nonempty break decoding and empty final
storage address element0. The actual break encoding is -9 and decodes to
tagged1 (index0); unknown tagged-3 follows validation instead. Mark-info arrays
have two entries. The completed Group has five fields and offsets `(0,0)`.

## Persistent state and interrupted reuse

For one successfully forced owner, the only StateTable keys are the initial
descriptor `(idx0, category33, singleton TExp tree)` and the nonempty match
descriptor `(idx0, fixed ordinary category, singleton TMatch marks0)`.
The empty-input derivative is held by the initial state's final cache, not
inserted into StateTable. There is one initial-cache entry, one transition
slot, and one final-cache entry, each absent or complete. Initial and final
miss paths have two lookup probes but only one construction path, outside
their lookup traps. StateTable.find's trap likewise ends before construction.

The table starts at128 buckets. Native Hashtbl.add allocates and initializes
its four-word bucket cell, publishes it at `98282d`, then increments size at
`982832`. A prefix can therefore undercount an already published key; it
cannot create an invalid link. Retry finds the published key and does not add
it again. There are at most two published cells and size in0..2, so resize is
unselected. Conservatively, attempted additions are at most `2+e_owner`,
where the sum of all `e_owner` and other charged exceptional events is at most
the **single process-wide e<=2**. This allowance is never renewed per call or
driver. Across nine owners there are at most18 published cells and20 attempted
adds. Hash arithmetic is the existing masked hash operation, not an increasing
resource counter.

Every mutable owner reachable by a search is covered:

* The compiler's ID/mark/cache refs and partially constructed structures are
  local until a completed compiled regex is returned through its own lazy.
* Immutable descriptors/lists and mark-info arrays are complete before cache
  publication. Status publication is either absent or a completed status.
* Initial/final lists and the one transition publish complete values in a
  single pointer update. A late exception leaves a valid cache for retry.
* Packed scratch is always None; the bitvector is fixed and reset before use;
  its only traversal indices are negative and skipped. The hint never changes.
* Positions are fresh per call and never resized. Only a completed Group can
  retain them. An interrupted call's unpublished owner is not reused.

The selected `Str.compile_regexp` allocates **two distinct lazies and two
closures inside each fresh two-field shell** (`9274f7–927585`). Search forces
field1, whose closure calls compile on the immediate Start. It shares no
mutable compilation/search storage with a different shell. Native Hashtbl
creation receives false directly and bypasses the random-seed lazy
(`98117b–9811c8`), so it introduces no hidden shared mutable compiler owner.
Immediate AST Start, empty marks and function closures may be shared immutable
values; that sharing does not share the lazies or caches.

`force_lazy_block_362` first replaces the selected lazy's closure with the
undefined placeholder, evaluates under its trap, and either publishes a
forward value or a four-word exception-raising closure. Failure while handling
an earlier exception can leave the placeholder. These are valid local lazy
states; they may permanently raise on every later force. Compilation runs at
most once for that owner. This argument deliberately does **not** claim an
interrupted owner later completes. Cached rethrows consume allocation credit
per call, but do not require another external exceptional event.

`Str.state` is the only shared search-result ref here. R72's actual narrow
trap ends before Some-Group publication and Group.offset. After failure it may
hold the incoming Group, None or a newly completed Group. That ref does not
reach compiler scratch, and zero-unit `grep_time` does not consume it.
The new Group may retain the caller's whole input string; its allocation and
length remain the parent raw-input premise, not a zero-length-input claim.

Under R72's serialized/no-reentrant-search callback premise, one charged
interruption can damage at most the currently active private owner. With at
most two such events, every triplet retains an undamaged owner. A normal call
to that owner succeeds on any represented input string, including empty. A
call to a previously damaged owner remains representation/memory safe and can
fall through to a later owner. This is the isolation result needed by the
parent; the complete reported-time and prefix proof remains its obligation.

## Allocation exports

Credits count freshly requested OCaml heap words **including headers**, for
these regex-owned operations only. Charge the total to either minor or major
if a coarse independent ceiling is needed; do not count it as two physical
allocations. C/runtime allocator metadata, collection copying, callbacks,
exception backtraces, stack and the already-existing input string remain the
common runtime/input premises. No GC-counter or available-RAM conclusion is
inferred from this local table.

| Stage | Selected allocation sum / conservative credit |
| --- | ---: |
| Parse the two-byte pattern and construct Str shell/lazies | 52 parser closure/buffer words + 3 branch cons + 3 reverse cons + 15 shell/lazy/closure words =73; credit128 |
| First force: Group wrapper and case handling | 3+3 |
| First force: color construction, colorize, flatten | 34+7+34+34+2+3 =114 |
| First force: compiler context and five expressions/return pairs | 17+35 |
| First force: working area, StateTable and compiled record | 13+134+12 |
| First-force total | 331; credit512 also covers a four-word lazy failure closure |
| One initial-state miss including cache publication | 31 |
| One derivative, including all ephemeral marks/splits/closures and new immutable state | 105; credit128 |
| Match status, compiled break state/bucket, or empty final-cache result | at most23 |
| Positions, Str argument/result wrappers, Group and complete native offset chain | at most32 |
| One search after charging first force separately | at most214 using derivative credit128; credit256 |

The derivative sum is `4+21+15+4+6+3+21+25+6=105`: context; two mark
updates including one remove_assq cons; three matches; two first_match options;
two split pairs; duplicate-removal cons; free-index traversal closures;
index-assignment closures/marks/TMatch/list; immutable state. All selected
lists have at most two mark pairs or one descriptor. Hash/fold/iteration and
the empty tseq branches add no owned heap blocks. The compilation color loop
has255 iterations but allocates no block per iteration. Cache hits only remove
these charges. Interrupted prefixes are charged the same whole-call credit;
published partial work and abandoned candidates are included. Repeated cached
lazy failures cost at most four owned words per force and fit the256 credit.

The native offset chain costs15 words: `Mark_infos.offset_455` returns a pair
and Some (5), `Group.offset_opt_503` allocates a closure (5), its
`Group.fun_1088` callback allocates the positions pair (3), and
`Stdlib.Option.map_292` allocates Some (2). Together with positions5, the Str
argument Some2, Group/result8 and Str.state Some2, this gives the32-word row.
Independent review found that the original20-word row counted only the final
pair; this correction increases the detailed214-word sum but leaves the
conservative256-word export unchanged.

For `o<=9` constructed private owners and `q` attempted searches, the export is

```
owned_words <= 128*o + 512*o + 256*q = 640*o + 256*q.
```

The parent may use `q<=3*T` for T invocations of the selected three-regex list.
It must separately charge the placeholder regexp/substitution, driver parser,
zero-unit timing-result objects, input strings and all other owners. The
maximum single owned allocation here is the initial128-element bucket array,
129 words including its header. All size/index/counter operands are tiny
relative to the retained64-bit OCaml representation limits. This finite
owner/call theorem does not close #206 or the broader #119 capacity objective.
