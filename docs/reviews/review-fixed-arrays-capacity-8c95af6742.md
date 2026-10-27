# Fixed-size arrays: report-capacity integration review

2026-10-27; review target `8c95af6742`, specifically
`docs/fixed-integer-arrays-report-capacity.md`, `tests/test_capacity.py`, the
32 MiB Main/platform constants, and the pinned producer excerpts cited by the
capacity record. Reviewed by the integration lead, separately from the capacity
author. The live lead model/effort and token/cost measurements are unavailable;
no new native or Lean validation was performed for this review.

No blocking finding in this scope. The conservative envelope is **25,084,928
bytes**, below the **33,554,432-byte** Main allocation. This is a source/producer
bound under the retained toolchain assumptions, not a measured worst report or
an independent proof of the whole feature.

The indexed read and write routes translate the one subscript once and add at
most one index check. The write's final component conversion is unchecked;
ordinary RHS conversions retain their separate charge. Explicit aggregate
elements are translated individually. Signed positional indices without
`others` skip the positional-choice check; the sole named choice is static.
These observations agree with the selected one-dimensional Integer fragment.

The joint two-byte charge separates assignment roots (`:=`), indexed
parentheses, aggregate component token/delimiter pairs and comparison syntax.
Aggregate components cannot contain comparisons, and indexed parentheses do
not consume their non-parenthesis operand token bytes. The inherited scalar
declaration allowance remains an overcount. Recomputing the formula gives
3,006 safety records and the 15,142,912-byte subtotal.

The warning count must include nesting. `Variables_Initialized_By_Loop` has
mutually exclusive call sites; its recursive traversal visits each indexed
assignment once per enclosing loop analysis. Each visit emits at most one
note, and admitted calls supply no array output parameter. The warning JSON
path appends records without deduplication. The failed recognition branch
withholds a positive initialization fact; it does not assume initialization
or discharge a safety obligation.

`for I in 1..1 loop` consumes 18 bytes and `end loop;` another nine.
`A(0):=0;` consumes eight distinct bytes, so `27L + 8W <= 4096` bounds
loop/write pairs. Independent integer maximization gives 19,404 pairs;
the record's 19,418 closed-form bound is conservative. Charging 512 bytes per
fixed-schema note gives the stated total and 8,469,504 bytes of headroom.
The source/operator budgets and runtime-report allocation remain unchanged.

The reviewed producer files' hashes are retained in the capacity record,
including the flow traversal and warning serializer. Remaining delivery work
is complete native proof, universal/source assurance, regression validation and
review of the integrated feature. The separate
[classifier review](review-fixed-arrays-main-advisory-4d4919efa2.md) covers the
acceptance predicate; this review does not replace it.
