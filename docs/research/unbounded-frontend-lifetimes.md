# Pinned frontend String and integer lifetimes

**2026-10-17 — research for #107, continued from PR #109.** This closes the
specific Stringt reclamation question in the
[partial source-capacity record](unbounded-source-capacity.md) and identifies
retained numeric-literal storage. It adopts no language rule and changes no
compiler, runtime, proof, or tool pin. Implementation #88–#94 remains unstarted.

The pinned source cannot represent two simultaneously retained, different
Strings of length 2^30 in its shared character pool. This is a structural
obstruction to implementing the proposed full value domain using that frontend
unchanged and admitting these compositions. It is not a giant native experiment,
an exact native failure threshold, or an impossibility result for alternative
compiler representations. A byte-only source-position bound cannot resolve it:
the concrete witness below is only 2,481 source bytes.

## Reproducible scope and premises

The [evidence directory](../evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/MANIFEST.json)
retains the complete upstream tree inventory, all-file hashes, raw package
references, comment/string/character-filtered lifetime searches, manually resolved
call inventory, selected source snapshots, exact arithmetic and witness input.
The upstream commit is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`
(`releases/gcc-16.1.0`); its entire `gcc/ada` tree is
`a3b9f0d4c999c8c127cebdc239ca8218284137aa`. All **2,490 files, 62,760,971 bytes**
were retrieved and checked against their Git blob hashes, with zero mismatches;
the recursive API inventory is not truncated. The source archive was streamed
into scratch, without modifying any tool installation.

Run the retained `audit.py` against that exact extracted subtree to repeat the
hash checks and lexical inventory. The lexical searches include unqualified
`Mark`/`Release`, qualified calls, package references and potential aliases,
pool resets, and C/C++ address consumers. The resulting **217 Ada lifetime-token
matches** were inspected for Ada name resolution; **41 operational sites** refer
to Uintp lifetime operations, and the only two external Stringt mark/release
sites are the checksum pair. This is a complete search of the pinned Ada
subtree with manual call-site resolution, not a mechanically verified call graph.
Generated/foreign code and actual binary identity remain correspondence premises.

Line references below use those exact snapshots. The
[handoff provenance](unbounded-source-capacity.md#evidence-and-provenance) records
release recipes, installed identities, and the limited Darwin-source comparison.
An upstream source hash is not proof of the installed binary's construction.
Applying these conclusions to the installed GNAT16.1 binaries assumes the
relevant implementations correspond to these bytes; no reconstructed build or
binary attestation is claimed. Linux is the actual continuation host, confirmed
by `uname` and `scripts/dev.py paths`; no macOS rerun was performed here.

## Stringt has no semantic-phase garbage collection

`Stringt` owns its two private Table instances in `stringt.adb:36–59`:
`String_Chars` contains 32-bit `Char_Code` entries indexed by signed `Int`;
`Strings` contains `(String_Index : Int, Length : Nat)` descriptors.
`Table.Length`, `Max`, and `Last_Val` are also signed Int quantities.
The complete mutation inventory has these dispositions:

| Route | Exact source | Effect on retained values |
| --- | --- | --- |
| Initialize | `stringt.adb:108–117`; compiler caller `gnat1drv.adb:1025` | Resets once before `Frontend` at driver line 1167. Other callers initialize separate tools (`make`, `gprep`, `gnatls`); none resets the pool between ordinary declarations. |
| Mark / Release | `stringt.adb:135–149`; only external callers `ali-util.adb:446,463` | Saves/restores logical tails around `Get_File_Checksum` for minimal recompilation. No ordinary parser or semantic folding mark/release exists. |
| Lock / Unlock | `stringt.adb:123–129,361–365`; driver line 1530 | Lock calls generic Table.Release to trim unused capacity; it does not remove any logical value. Driver invokes it immediately before the backend. Unlock changes lock flags, not lengths. |
| Start / Store | `stringt.adb:157–243` | Appends descriptors/characters; only the left operand already at the pool tail shares existing characters. No global interning, rope, compression, relocation or collection occurs. |
| Unstore | `stringt.adb:371–376`; five callers in `scng.adb:890–926` | Removes characters from the currently unterminated literal during error recovery. Valid completed literals and folded constants cannot take this path. |
| Address export | `stringt.adb:268–270,341–343`; `back_end.adb:169–170`; `gcc-interface/trans.cc:334–335` | Exports the retained pools to the backend after frontend processing. The C header's accessors read the same Int offsets; no earlier reclamation or hidden wider representation is supplied. |

The private table declarations rule out another Ada unit directly resetting
their logical tails. Searches for every package reference, renaming, lifetime
operation, and exported C symbol revealed no alternate reclamation route.
The backend's global pool pointers are assigned when entering Gigi; their other
uses in `stringt.h` are reads. Even a hypothetical backend collection would occur
too late to avoid frontend folding's peak.

### Concrete live-value obstruction

[`two-live-chains.adb`](../evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/two-live-chains.adb)
declares `A0 := "x"`, then `A1 := A0 & A0` through `A30 := A29 & A29`;
it separately declares `B0 := "y"` through `B30`, and prints both final values.
Every declaration has ordinary `constant String` syntax. There are 62
declarations, 60 concatenations, no author annotations, and no new construct.
Each length is at most 1,073,741,824, below the proposed `Integer'Last` bound.
It fits today's source/operator/declaration counts; its String values exceed
today's 4096 limit. This is a **hypothetical member of the proposed expanded
fragment**, subject to the still-unselected source-capacity rule, not a currently
admitted Silver program or a completed feasibility test.

The source-derived argument is:

1. `sem_res.adb:10803–10815` invokes `Eval_Concatenation` for String operands
   during resolution. `sem_eval.adb:7226–7348` folds static operands with no
   optimization-level gate. Thus ordinary `-O0` does not defer these constants
   to execution. `Get_String_Val` at lines 5293–5300 follows constant values, and
   `Eval_Concatenation` at lines 2339–2443 materializes their character sequence.
   `Fold_Str` at lines 5118–5144 attaches the resulting String_Id to the tree.
2. Tail sharing can keep a single chain's descendants over a common prefix;
   charging every intermediate chain length would overstate required storage.
   This audit preserves that counterevidence.
3. Every character in the final A value is `x`; every character in final B is
   `y`. Their contiguous character ranges cannot overlap in this representation.
   Both descriptors remain live, and no valid-source route releases A while B
   is folded. Therefore the final values alone require at least 2^31 character
   slots, or 8,589,934,592 bytes of Char_Code payload, excluding descriptors,
   original lexical literals, dependency strings and spare allocation.
4. Generic Table's signed Int `Length` cannot represent 2^31 entries. Stringt's
   append, start-plus-length, and range arithmetic additionally require signed
   Int endpoints. Extra lexical/runtime characters strengthen the conflict.
   Sufficient physical RAM does not widen those representations.

This closes the handoff's missing lifetime premise. The argument establishes
that the unchanged representation cannot faithfully process this composition.
It does not predict whether a particular executable first raises an exception,
loops, exhausts physical memory, wraps an index or produces another defect.
An earlier non-resource rejection, with sufficient physical resources, would
also be inconsistent with admitting the witness and promising a faithful
full-domain build. Physical exhaustion remains an allowed operational outcome;
the precise cause of an observed unsuccessful run must not be guessed.

### Default growth is a separate, qualified finding

`alloc.ads:127–128` sets the character-table initial length to 2500 and increment
to 150%. `opt.ads:1508` defaults `Table_Factor` to 1; `switch-c.adb:1315–1318`
changes it through `-gnatT`. Compiler arguments are scanned before table
initialization. No such switch is part of the examined default recurrence.

`table.adb:187–192` computes `new = max(floor(old * 2.5), old + 10)` and converts
the first operand to Int. Exact integer arithmetic gives 931,307,812 followed
by 2,328,269,530. The latter is not representable in Int. These are mathematical
growth values, **not an established native cutoff**: the compiler build fragment
`gcc-interface/Make-lang.in:46` uses `-gnatpg`, suppressing Ada checks. A physical
build's handling of the conversion may differ from checked-source behavior;
truncation and the `old + 10` fallback cannot simply be assumed away. User
program flags `-gnata -gnato` do not retroactively enable checks in the compiler
binary. Build correspondence and exact generated arithmetic matter.

Changing the initial factor or saturating growth can avoid this particular
conversion, but cannot fit two different 2^30 live character sequences into the
existing pool. The structural conclusion does not depend on this recurrence,
the compiler's check settings, or observing a multi-gigabyte failure.

## Zero-valued literals retain large powers

The complete Uintp lifetime caller inventory is retained in
[`resolved-lifetime-inventory.json`](../evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/resolved-lifetime-inventory.json).
Operational callers are local arithmetic/image helpers in `uintp.adb`,
floating-point helpers in `eval_fat.adb`/`urealp.adb`, range arithmetic in
`checks.adb`, and debug-bound calculation in `exp_dbug.adb`. No `Scng`, `Scn`,
parser or frontend driver mark encloses ordinary token scanning. Only
`Uintp.Initialize` resets the pools; `Release` resets to a supplied mark subject
to protected minima. No other direct Uints/Udigits reset was found.

For an ordinary decimal `0E799999` token:

1. `scng.adb:764–785` skips exponentiation only for zero **scale**, syntax-only
   processing, or prior serious errors. The mantissa being zero does not skip it.
   The overloaded expression computes `UI_Num_Value * UI_Base ** UI_Scale`.
2. `uintp.adb:1431–1449` marks the existing tables, computes the base power by
   repeated squaring, then `Release_And_Save` retains the final power. The
   memoized 2/10 power cases apply only through exponent 128, not 799999.
3. `UI_Mul` at lines 2020–2072 has no general zero-operand shortcut. With a
   table-coded power it creates digit vectors, computes an all-zero product,
   and `Vector_To_Uint` returns direct `Uint_0`. Neither operation releases the
   already saved power. The token node receives zero in `scn.adb:155–164`.
4. The next literal's exponentiation mark is taken **after** the earlier power.
   Its release therefore preserves the earlier allocation and appends its own
   saved power. During ordinary parsing, repeated identical zero-valued literals
   accumulate powers, despite having the same small mathematical result. No
   broad integer interning is present on this route: `Release_And_Save` copies
   the saved digit sequence into a new entry.

The digits below use exact Python integer `bit_length`, with
`ceil(bit_length(base**799999)/15)`, not floating-point logarithms:

| Literal | Retained base-32768 digit words for its power | Digit-word bytes |
| --- | ---: | ---: |
| `2#0#E799999` | 53,334 | 213,336 |
| `0E799999` | 177,170 | 708,680 |
| `16#0#E799999` | 213,334 | 853,336 |

These are lower bounds on the saved table payload of one scan, not peak RSS.
Repeated squaring retains intermediate table values until its local release;
`UI_Mul` uses operand/product vectors, and `Release_And_Save` copies the final
digit vector before releasing old storage (`uintp.adb:693–717`). Vector stack
use, table capacity growth, protected minima and allocator overhead are extra.
The fixed maximum exponent limits each exponentiation, but neither the retained
allocation total nor the amount of schoolbook multiplication across a source.

For scale only, 12,122 decimal powers already require more than Int'Last digit
words, before other values or intermediates. This arithmetic is not a measured
native boundary or a proposed rejection rule. The structural String witness
already establishes the full-domain obstruction without relying on this numeric
extrapolation. A future source-sensitive model must charge exponent spelling and
transient/retained allocation, not merely the final Integer interval; a
zero-mantissa scanner repair could remove this waste without changing meaning,
but is a tool change requiring its own validation.

## Consequences and remaining research

The complete lifetime search supports the unchanged-frontend obstruction and
eliminates release/reuse as an answer to the two-chain example. It does **not**
close a sound capacity vector for every construct: generated nodes, slots,
names, source copies, lines and phase-dependent dependencies still need bounds.
Nor does this establish a sound universal source-byte envelope or prove that
source-sensitive accounting is intractable.

A source-sensitive rule could distinguish compact semantic expansion from
large harmless comments and could account for String characters and numeric
spelling. It would reject the witness under the existing representation, so
presenting it as removal of all unnecessary value restrictions would conceal a
tradeoff. A conservative uniform byte cap would also lose unrelated programs;
the witness shows that source-position headroom alone is insufficient.

For the owner's expansive direction, changing the tool's representations and
checking its arithmetic is the direct research alternative. Widening offsets
alone is insufficient. The affected interfaces are concrete:

- `stringt.adb`'s `String_Entry.String_Index`, `String_Chars_Last`, append
  temporaries and start-plus-length arithmetic must represent wider pool offsets.
  Per-value Length can remain bounded by the target String domain; it is a
  different quantity from total pool length.
- `table.ads` fixes `Last_Val` and saved-table endpoints to Int independently of
  the generic index type; `table.adb` fixes Length/Min/Max to Int. Merely changing
  Stringt's generic actual index type is insufficient. A wider table variant or
  coordinated table redesign must cover growth, restore, release and byte sizes.
- `stringt.h` duplicates the `(Int String_Index, Int Length)` descriptor layout
  and computes offsets using Int in `Get_String_Char`. `back_end.adb:169–170`
  passes raw addresses to `gcc-interface/trans.cc:334–335`. Ada and C++ layout
  and accessor arithmetic must change together; widening every compiler Int is
  a much broader change than introducing wide character-pool offsets.

Segmented or compressed constant representations could instead avoid eagerly
materializing full strings. They would need to replace the contiguous-array
assumption behind these exported pointers/accessors, preserve static lengths,
comparisons and legality checks, and supply semantically equivalent codegen
initializers. Merely moving all evaluation to runtime would fail required Ada
static evaluation. The feasibility, whole-language semantic preservation and
assurance of either redesign remain unestablished; neither is authorized
implementation here. A capacity-checked frontend can detect a limit without
making the existing representation larger. `-gnatd.f` is expressly documented
as non-conforming and is not an established semantics-preserving fix. Backend
code models act after this folding, so cannot solve it either.

No large compile, compiler invocation, application execution, GNATprove run,
Lean build, test suite, tool bootstrap or installation edit was needed for this
continuation. Validation here consists of source retrieval/hashes, exhaustive
lexical inventory with manual resolution, exact arithmetic and document/evidence
consistency checks. The original small native observations remain historical
evidence with their original host, inputs, and limitations.
