# Fixed placeholder-regexp startup cost

This follow-on to the [Start-owner kernel](../README.md) covers exactly one
fresh `Re.Str.regexp` on bytes `25 5c 28 2e 5c 29` (`%\(.\)`), followed by
one `Re.Str.search_forward` at position0 on bytes `5c 3d`. The parent source
argument establishes nine such constructions/searches through
`Call_provers.timeregexp` and `Str.global_substitute`. It owns the substitution
wrappers, string_after copy, driver parser and final timing records separately.
The exported **4096 owned OCaml words per construction/force/search**, including
headers, therefore contributes at most36,864 words for nine calls.

The startup premise here is the parent's successful prefix before callbacks
are registered. A terminal allocation failure takes the retained failure path;
this helper owner is not reused after an interrupted invocation. No new
exception allowance is introduced. The common runtime/backtrace/physical
memory/stack premises and input ownership are the same as the Start kernel.
This is a fixed-input source/native derivation, not target or Re execution.

## Selected syntax and native path

The installed parser recognizes escaped parentheses and dot in its Str
dialect. Percent comes from the preinitialized Dense_map character table;
dot reads the preinitialized not-newline AST. `Dense_map.fun_353` selects its
ordinary pointer-array branch, not its float-box branch. The native AST is
`Sequence [Set percent; Group (Set notnl)]`. Its unanchored compilation is

```
E = Seq Shortest R G
R = Rep Greedy Shortest (Cst any)
G = Seq First (Mark 0)
      (Seq First (Seq First (Cst percent)
          (Seq First (Mark 2) (Seq First (Cst notnl) (Mark 3)))) (Mark 1))
```

There are exactly14 allocated automaton expressions: three Cst, one Rep,
six Seq and four Mark. Repeat's lower bound is0 and upper bound is absent,
so neither finite-repeat expansion nor rename runs. The top-level semantics
remain First; there is no extra enforce-kind epsilon expression. This uses
R72's retained native parser/constructor/translation correspondence, with
the new selected Cset/color-map bodies closing the small allocation joins.

Colorization splits only `[0,255]`, `[37,37]`, and `[0,9] U [11,255]`.
The five ordinary color intervals are `[0,9]`, `[10,10]`, `[11,36]`,
`[37,37]`, `[38,255]`; both input bytes92 and61 have color4. The representative
for that color is255. There is no last-newline color. Translation keeps the
three Cst sets in at most two intervals each. The Cset translation cache has
at most two keys: any and notnl; the singleton-percent fast path bypasses it.

Let `m` be empty marks. On either input byte, delta of R is
`[TExp(m,R); TMatch(m)]`. Shortest composition first tries G. Mark0 is
introduced transiently, but the required percent fails on color4, so that
branch contributes no descriptor. The only residual is

```
S = [TSeq Shortest [TExp(m,R)] G].
```

Deriving S on the second byte reproduces S. The final-boundary derivative
uses color-1: any and percent both fail, and the resulting descriptor list is
empty, hence Failed. The captured-group/notnl suffix is never derived. Thus
there are at most three delta invocations, one at each of the two character
positions and one final check. There are two StateTable keys (initial and S),
two occupied transition slots (initial→S and S→S), and one final-cache entry
on S. The final state is not inserted into StateTable. The ordinary failed
search raises Not_found and Str clears its global Group ref; Group.offset and
the replacement callback are not reached.

Each surviving descriptor has empty marks. Reset/free-index therefore selects0
on all three deltas. The bitvector stays one bit, the hint0, and positions
length1. The scan stores only positions0 and1; no positions resize occurs.
No successful Group or mark-info array is allocated by this search.

## Packed scratch is one slot

Duplicate removal descends through the sole TSeq and sees exactly one TExp
whose key is R's expression ID. There is one mem/add pair on each character
delta and none on the final empty delta. Delta clears scratch before every
duplicate-removal pass, as in R72.

On the first pass, mem on None returns false. `init_508` creates the empty
backing/table/Some owner; `add_590` selects `resize_582` because capacity is0.
The resize requests exactly8 sentinel-filled bytes (`91458f–9145aa`), with
no old slots to reinsert, and add stores the one key then sets size1. The next
clear resets size0 and the sole slot to sentinel-1. A zero historical size
does not select growth (`9146d8–9146dc`); the one key is added into that empty
slot. The final clear leaves size0. At all dereferences capacity is1 and the
byte offset is0. A full one-slot table is never probed for an absent second
key: clear precedes the next probe. Hence there is no collision loop, second
resize or historical-counter inflation in this selected execution.

The largest scratch backing is8 bytes, size/occupancy are at most1, and the
only key is in1..14. StateTable remains at128 buckets with size at most2.
All indices, sizes, byte offsets, mark counters and ID operands are represented
far below the retained64-bit OCaml limits. Failed allocation prefixes have no
larger request than the complete path, and are not resumed in this startup
theorem. This does not generalize the one-slot result to other input strings.

## Owned allocation credits

The intentionally rounded stage credits below include block headers and
abandoned intermediates, not just retained objects. They cover these Re
operations only; C/runtime metadata, backtraces, collector copying and caller
substitution wrappers retain their separate owners.

| Stage | Bound and justification |
| --- | --- |
| Parser plus Str shell |128 words. Parser buffer/closures52; three branch cons and their reversals18; group3; outer Sequence2; shell/two closures/two lazies15:90. Character/notnl AST providers are preinitialized immutable pointers. |
| AST wrapping and case handling |128. The unanchored wrapper adds at most18 words; case traversal has only the two sequences, two groups, Sem, Repeat and three sets, at most35 words. |
| Color map, splitting and flattening |256. The 257-byte map, two256-byte temporaries, five-byte representative and result pair cost107 words; colorize7 and three split closures15 add22. Each of the four source intervals writes only its two endpoints. Flatten's255 iterations allocate no block. |
| Translation bookkeeping and expression blocks |256. Fourteen constructors each cost at most7 words (98); the compiler context17, at most14 result pairs42, one Sem-context copy9 and bounded repeat/sequence closures fit the remaining90 words. No repeat expansion or rename is selected. |
| Three character-set translations/cache operations |3×128. Percent's one_char Some costs2 and uses the static singleton table. Each other set has at most two intervals: translation closure5, fold wrappers bounded by16, at most two interval pairs/cons12 plus at most two union copies12, key pair3, and at most two six-word Map nodes12. The cache has at most two keys; balancing never rotates. Each subtotal is at most60, below128. |
| Working area, StateTable, compiled record |160, covering13+134+12=159 as in the Start kernel. |
| **Compilation credit** |128+256+256+384+160=1184; charge2048. |
| **Each derivative credit** |512, as detailed below; at most three. |
| Other search work |128: positions/argument7; at most two compiled-state constructions with six-element transition arrays and bucket cells (at most2×17); initial-cache publication6; final result/cache9; status-option caching at most3×2; initial descriptor/state12; extra result/exception wrappers fit54 spare words. No Group or offset chain runs. |

For a derivative, the selected call tree visits at most eight automaton
expressions and at most two pre-existing descriptor nodes. Its allocating
families admit the following independent upper sums: context4; one add_eps6;
two add_match10; one mark update9; three first_match options6; one split3;
one remove_matches cons3; at most eight tseq constructions/appends at ten
words each80; duplicate-removal descriptor/list copies at most32; free-index
traversal closures at most32; index-rewrite closures/descriptor/list copies
at most48; new immutable state6; packed mem/add/initialization/backing at
most32. Their sum is271, below512. Empty-list cases, cache hits and the final
failed derivative only remove charges. Hash/fold/list iteration contributes
no further owned blocks beyond the listed closures; the retained ordinary
runtime relation covers arithmetic/hash primitives.

The selected total is bounded by

```
128 + 2048 + 3*512 + 128 = 3840 <= 4096 words.
9 * 4096 = 36864 words.
```

This deliberately does not subtract removed old step-regexp work. The parent
can charge this full additive amount and separately charge each final Start
owner using the reviewed640-word fixed credit. All new owned blocks are
minor-sized; the largest is the129-word initial StateTable backing. A coarse
composition may charge the total to either allocation class, with collector
effects handled by its existing runtime argument.

`check.py` verifies only these fixed source/native inputs, instruction witnesses,
the five-color arithmetic, explicit residual/counter facts and stage sums. It
does not import/run the predecessor checker or a regex engine. `native.json`
contains eleven additional named native bodies; `inputs.json` selects reused
R72/Start bodies. The installed ELF identity is unchanged from the Start
kernel. The reference commit remains a semantic reference, not an installed
upstream-version assertion. The parent still owns complete #206 composition.

The focused check passed once in0.429590 seconds:17 fixed inputs,104 selected
whole native bodies and29 instruction witnesses. Eleven new helper bodies
were extracted; other identities were reused without predecessor replay.
Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements are unavailable. `round.json` records the bounded
work and draft corrections. Independent review/integration remains pending.
