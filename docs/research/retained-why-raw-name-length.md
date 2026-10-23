# Raw identifier names through selected SMTv2 printing

2026-10-23 UTC, #119 / #153. **Candidate source argument, pending independent
review.** The complete selected name-input family has the following bounds:

| Process | Original captured identifier maximum M | Raw name L at printer entry | Raw proposition comment name L_pr | Sanitized base including local projection/blacklist | Unique printed/candidate name bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 63 | 70 | 74 | 150 | 163 |
| Put | 63 | 70 | 74 | 150 | 163 |
| First_Or_Default | 60 | 67 | 71 | 144 | 157 |
| Is_Message | 45 | 52 | 56 | 114 | 126 |
| Input_Is_Valid | 47 | 54 | 58 | 118 | 130 |

This supplies the missing L attachment to the accepted
[R64 name-table interface](../reviews/review-printer-name-tables-20261023.md).
L covers every raw `id_string` that can reach the selected printer's
`id_unique`, including declaration/signature/type heads, constructor/projection
heads, binders, formals, free variables and generated or whole-old-returned
objects. Proposition heads use a separate L_pr because SMTv2 emits them directly
in `%S` comments. Their bound additionally consumes the separately frozen
hypothesis-name origin result described below. Neither result bounds the whole
formatted request or proves successful name uniqueness after caught failures.

The [packet](../evidence/retained-why-raw-name-length-20261023/README.md) is based
on published `8b651049e46c8800df92e9efed4832ddfcbad8ab`. It changes no Oracle,
language, tools, pins, admission or production source. Its mathematical
continuation argument is source-sensitive and conditional on the established
fixed-input/source-native/runtime, valid typed/persistent-field, immutable-key,
guarded-mutation and first-global-identifier-violation premises. A finite byte
census is the initial case, not a substitute for the continuing source argument.

## Complete initial fields, including signatures and old seeds

The new projection reads the original retained `session-blocks.jsonl` bytes,
checks field shapes and string headers/padding, and measures byte lengths
without lossy decoding. Every inspected identifier spelling is ASCII in these
five fixed inputs. That is a checked input fact, not a new language restriction.
It visits:

- Every logical declaration in the accepted R51 root/context census, including
  unused Dparam heads and all of their argument/result types, Dlogic signatures,
  Dtype arguments/aliases, all Ddata constructors/projections and Dind/Dprop heads.
- Every type in those signatures and in the complete stored term/variable
  family, recursively including type-head and type-variable identifiers.
- Every physical variable and logical symbol in R51's complete raw, candidate
  and compatible initial-seed graph. This includes dead saved keys/values,
  formals and variables absent from the exposed printed formula. Input's older
  representative graph supplies additional blocks where needed.
- Every R56 typed/declaration identifier as an explicit cross-check. R51's
  synthetic CE variable names are independently checked against their physical
  source-name/copy/`'unused` family; the continuation bound does not rely on a
  predicted allocation address or rerunning the historical CE model.

The resulting physical identifier counts are 6,179 / 4,978 / 2,113 / 571 / 670.
Each retained row identifies its original identifier/string pointer, measured
bytes, role(s) and attributes. These rows attach the new maximum to actual
captured source fields. For example, the Put projection
`tTwritten_bytesSP1__ref_tTwritten_bytesSP1__content__projection` is 63 bytes.
The old saved-proposition atom maximum of 40 bytes misses that signature head.
This is why the smaller atom scope is not reused as L.

R51/R56/R57 provide the already reviewed complete stored-root and original-key
coverage, including initial same-key representatives. They are consumed at that
scope; this packet does not claim a new heap capture or re-establish their
entire source simulation. The direct extractor adds the required signature and
spelling checks, rather than trusting a display-name maximum alone.

### Metadata that can supply a printed head

The old capture intentionally omits metadata descriptor/argument payloads.
Two attempted extensions exposed those missing bytes; no missing pointer was
accepted or assigned a default. The final projection instead uses the complete
retained R54 metadata events and its accepted address correspondence map.
Every `range_type` event is raw; its type/projection pointers map back to the
original capture. The new extractor reads each mapped type and complete
projection signature there. There are 7 / 7 / 3 / 2 / 3 such events. Their
names are within the reported M values; the result retains the actual pointer
joins. No `float_type` event is present.

The complete R54 event inventory has neither `introduced_lsymbol` nor
`introduced_prsymbol`. A new check also finds none of those two names, nor
`range_type`/`float_type`, anywhere in the fourteen retained driver files.
Thus the selected alternative driver closures cannot add a name-preserving
Introduction metadata override or an unexamined literal projection origin.
Selected later metadata writers retain existing arguments or refer to the
new heads covered below. Generalization, which would manufacture introduced
name metadata, is not a selected transformation. Other metadata changes syntax
or retention of existing heads; it does not import a term body or a new raw
spelling into this printer.

## Continuing origins and why the seven-byte growth is not repeated

`id_register` copies `pre_name`, `id_fresh` stores its argument, and `id_clone`
preserves `id_string` while unioning attributes (`ident.ml:187–219`). Neither a
fresh identifier tag nor a printer suffix is appended to the raw name by those
constructors. Opening and generic typed renaming use `id_clone`
(`term.ml:799–831,1085–1115`). Inlining, substitution, closing and retained
whole-object returns consequently preserve the spelling origin; they do not
combine one object's old spelling with another candidate's fields.

The actual growing cases belong to different source roles:

1. **Unused variables.** `v_copy_unused` tests the immutable, module-static
   `Ident.unused_attr` before appending the seven bytes `'unused`
   (`term.ml:1675–1686`, `ident.ml:557–559`). Every newly derived identifier
   carries that same marker via `id_derive`'s attribute union. Every selected
   later clone retains it. A second call on that identifier, or on a fresh
   clone descended from it, returns without another suffix. An original
   captured name that already ends in `'unused` but lacks the marker is still
   safe: M already includes its whole spelling and permits one further append.
   No assumption about initial suffix/marker consistency is necessary.
2. **Completed data projections.** `complete_projections` derives
   `constructor_name ^ "_proj_" ^ decimal(i+1)` only for a missing projection
   (`eliminate_algebraic.ml:280–291`). R61's selected original data family has
   at most two constructor fields, so the suffix is seven bytes. The new symbol
   is a projection, with constructor count zero. It cannot become a Ddata
   constructor on a later selected pass. Original data constructor heads are
   retained or cloned with their original spelling; no selected transformation
   creates a Ddata using a generated projection or an introduced nullary symbol
   as its constructor. Repeating preparation or using an older result therefore
   derives from the original constructor stem, not from an earlier `_proj_1`
   output. If a projection was already supplied, the function retains it.

These growth paths cannot concatenate in the selected family. Unused copying
acts on variables. A generated projection is a logical symbol and is not
converted into a variable by these selected transforms. Epsilon and Introduction
can turn a variable into a nullary logical symbol, but never into a data
constructor. Conversely, data constructors are not variable origins for unused
copying. Literal/projection/inversion-generated binders have the fixed names
listed below. This is an origin/role argument, not merely the observation that
one execution produced short names.

Old immutable identifiers are never edited in place. A failure before a fresh
identifier is returned cannot publish a partially initialized raw spelling or
strip a marker under the retained valid-field/native premises. Failure after a
publication can leave that complete marked identifier in an old task/cache;
it still has the same origin. A failed map/union returns no replacement input
object. Signal unwinding and caught false misses may allocate another clone,
but its original stem/marker behavior is unchanged. No successful memo
publication, unique spelling, successful whole transformation, no-signal or
nonnegative-table-size premise is added. Persistent sets must continue to meet
the already retained valid-set/guarded-mutation contract; this packet does not
infer marker preservation from strings alone.

### Other selected generators

| Generator | Name origin reaching `id_unique` |
| --- | --- |
| CE, ordinary opening, safe/type maps, optional inline, split and simplification | Existing names, marker-preserving clones, or the one unused-variable rule above. |
| Full algebraic elimination | Constructor/projection clones preserve names; missing projections use the seven-byte rule. Generated variables are `u`, `v`, `w`, `x` or `z`. R61 excludes multi-constructor selector/indexer/discriminator and material-array branches. |
| Projection-on-sums / compile-match | Kept singleton records and nullary Boolean cases; fixed `v`/`x`/`w` locals or preserved projection heads, with no new constructor-name family. |
| Literal elimination | Fresh `rliteral` (eight bytes); the generic `fliteral` is also eight but its float branch is excluded. Range binders are `i`; range projection heads are the metadata-joined originals. |
| Guard/general epsilon | The selected closed, noncanonical family returns an existing witness or clones the epsilon variable's name for a nullary head. R61 excludes the canonical identity/partial-function `_closure` producers and the equality-special route. |
| Introduction | `ls_of_vs` clones a variable identifier. Its metadata override is excluded above; its initially empty queues contain only current-family creations. Type-variable introduction is an identity for ground goals, and even its clone would preserve the input spelling. |
| Discrimination / SMT encoding / inductive and recursion elimination | The accepted R57/R61 ground, nonrecursive and removed-inductive families make their name-expanding branches unavailable. Retention and whole older returns keep their existing origins. |
| Core builtins and selected zero-arity tuple helper | Fixed `int`, `real`, `bool`, `string`, `True`, `False`, `infix =`, `tuple0`, `Tuple0` names, each at most eight bytes. R61's task-side tuple requests have argument zero. |

The accepted R61 complete generated-signature and returned-field argument is
used here, not only initial A/T inventories. Whole public hashcons returns
retain their original head identities and complete older origin. Introduction's
initial-empty private tables/queues contain only later objects created by the
same rules; weak loss or an interrupted append cannot manufacture a different
spelling origin. Separate preparation episodes start from the accepted original
registered tasks. A prior printer's name table is private and is never fed back
into any task's `id_string`.

### The selected library helpers

Literal preparation reads only the named comparison/negation heads from
`int.Int`/`real.Real` (`eliminate_literal.ml:193–199`). The fixed installed
sources declare their local `(<=)` and `(-_)` operators before the clone-export
statements; those statements substitute the already local operators into their
algebraic copies (`int.mlw:11–31`, `real.mlw:11–30`). Parser operator encoding
and `create_user_prog_id` preserve the respective raw spellings `infix <=` and
`prefix -`, both eight bytes; `create_rsymbol` passes that identifier to the
logical-symbol constructor (`parser_common.mly:1560–1566`,
`typing.ml:188–200`, `expr.ml:138–150`). Ordinary cloning uses `id_clone`
(`pmodule.ml:729–738`). The accepted four-file/cache-source relation supplies
this same origin for cached or repeated reads.

This does not assert that every restored library body is source-local. The
accepted library analysis explicitly allows foreign restored bodies. Such body
scans belong to lookup work; this selected task transformation imports these
local helper **heads**, not their bodies or arbitrary declarations from the
library environment. Their signatures use the fixed integer/real types. Newly
created background tuple/library objects cannot enter the printer merely by
having a matching display name. R61's typed task-origin restrictions and the
first-identifier-violation premise remain required for that distinction.

Together these cases prove, for every reached preparation/printing prefix,

```
L = max(M+7, 8).
```

M is domain-specific and is not reset or enlarged by a failed prefix. The
single process-wide `e≤2`, two save-entering callbacks, three saves and R62's
E are unchanged. They bound opportunities elsewhere; they do not multiply a
name's length or authorize a new suffix allowance at each call.

## Separate proposition comment names

Proposition identifiers do not call `id_unique` in SMTv2; `print_prop` and the
final-goal branch emit `pr_name.id_string` directly via `%S`
(`smtv2.ml:770–775,810–825`). Original proposition names are included in M.
Generated literal axiom names have at most 14 bytes. Range axioms append six
bytes `'axiom` to an original type name. Inversion appends ten `_inversion`
bytes to an original type name. Projection and epsilon defining axioms append
four `'def` bytes to a logical-symbol/variable origin already bounded by M+7.
No selected producer converts one of those proposition heads back into a
variable, data constructor or logical head and appends another such suffix.

`Introduction.pr_of_premise` uses `get_hyp_name` or the fixed `H`
(`introduction.ml:188–191`, `ident.ml:510–513`). The separate Hsattr author
freeze `62f686fe7331c2faf74c3c9f66df93f2626f1fa0` supplies the complete
continuing hypothesis-name value bound of 13 bytes, including initial hidden
fields, later copying/pushing and library annotation defaults. Exact copies of
that source note and result are retained solely for this interface. Its joint
independent review was pending at this author's freeze; no other Hsattr count
or closure is endorsed or consumed here. The general raw-name L above does not
depend on that additional hypothesis-name result.

Thus, conditional on that separate interface,

```
L_pr = max(M+11, 14, 13).
```

The resulting five values are 74 / 74 / 71 / 56 / 58. L also bounds raw logical
head `%S` comments. Output escaping and complete formatter/request bounds
remain with the output component.

## R64 composition and evidence scope

R64 proves that every suffix/cache/test/successor operand is at most its local
N, including blacklist reservations, false misses, deletions and interrupted
prefixes. The largest is Put_Line's 9,861,957,430,423; none is renewed per name.
The sanitizer uses at most two ASCII bytes per input byte, and maps empty input
to `zilch`. Its output has no space, so `sn_decode` selects SNword and the
quote-sized `String.make ind` branch is excluded. The only raw-name extension
inside the selected printer is the five-byte `_proj` dummy-field suffix at
`smtv2.ml:884–886`. Accordingly:

```
base_bytes ≤ max(22, 5, 2(L+5))
unique_name_bytes ≤ max(22, 5, 2(L+5)) + decimal_digits(N).
```

All five new string guards pass the actual R64 callable interface, along with
its unchanged integer/table guards. These bounds cover sanitizer concatenation
lengths, string indices and candidate append operands, stored Hstr keys/Hid
values and the decimal suffix conversion under the retained scalar services.
R64's generic `raw_name_origin_attachment_established:false` field is not edited;
this new source argument supplies that missing attachment outside the old API.
No total string-call count is mistaken for a machine integer or a physical RAM
requirement. String-service/physical-resource assumptions remain where previously
specified; no aggregate RAM gate is introduced.

The focused checker validates frozen bytes, strict in-file source ranges, every
new direct projection, metadata pointer joins, the finite name-family arithmetic
and all five R64 string guards. It imports only R64's pure arithmetic function,
not its checker, model or native evidence. It does not execute preparation or
prove this source induction by enumeration. The round record preserves the
metadata-payload discovery and exact subsequent evidence, selected GPT-6 Astra /
Extra High, unavailable runtime confirmation/token/cost telemetry and measured
check time. No native/compiler/solver/proof/capture or historical checker ran.

Independent review remains required. Other printer owners, complete output and
Format/Buffer capacity, the wider native/service composition, successful naming
semantics and full current-grammar/#119 coverage remain separate obligations.
