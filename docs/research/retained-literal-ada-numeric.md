# Literal Main Ada numeric table composition

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins the previously separate incoming Uint/Udigit state to the selected
literal Main's constant-size callbacks. It is a component of the retained-tool
capacity derivation, not a whole-native capacity rule or production change.

The selected source is the existing declaration-free Main/SPARK shell with one
`with Silver_IO;`, C >= 1 direct-literal Put/Put_Line calls and N >= 0 nulls.
Each decoded literal length is between zero and INT_MAX. The accepted native
phase, O0 options, indexed naming configuration, default table factor one and
source/installed-tool correspondence remain premises. The proof producer and
separately compiled library processes have independent numeric states.

## Demand ownership and source argument

The [fixed-source reduction](retained-native-expansion.md#concrete-fixed-inputs-and-capture-reconciliation)
establishes the runtime/specification closure, once-per-unit analysis and
first-freeze behavior, including conservative all-miss numeric accounting.
Its complete fixed witness contributes 24,324 Uint appends, 74,958 digit words,
60 Ureal records and 504 Rep_Table records. These are lifetime upper allowances,
not a claim about an observed starting table position for this Main. Retaining
the full witness, including its own Main and backend increments, is deliberate
overcounting. No recorded allocation or assumed cache hit is subtracted.

The [actual-source frontend adapter](retained-literal-native-frontend.md) supplies
zero numeric scanner entries, 7C Main Uint appends and `(60+k)C` retained digit
words, where `k=uint_digits(C+2)` is the positive base-32768 digit width.
The unchanged constructor model charges 60C for standalone literals and kC
for conservative output wrappers. Its scope bound is incoming depth one plus
C wrappers plus one, even though the selected literal path needs no transient
scope. The former 61C simplification applied only for C <= 32,765. At C=32,766,
k becomes two and the model pays 62C; no new call-count restriction is needed.
There are no real literals, numeric
source tokens, declarations, concat, Image or Integer expressions in this shell.
Text resembling a numeral inside a String or comment adds none of those forms.
The Main word/null counts can change without adding a numeric constructor.

The fixed naming-pattern pragmas contain no numeric expression. The indexed
naming exception contains only direct Uint 1, as established in the
[indexed configuration argument](retained-native-expansion.md#indexed-main-invocation-and-source-buffer-delta).
Changing selected pathname spellings therefore changes no field in this numeric
projection. The adapter reads the numeric fields of `native_fixed_frontend(0,0)`;
those two zero arguments project away unrelated name/path fields. They are not
a proposed invocation or zero-length pathname premise.

The two fixed Standard floating endpoint conversions retain their separately
proved additional allowances: 4,096 Uint appends, 32,768 digit words, seven Ureal
records, zero Rep_Table records and a largest nine-word local vector. They are
added in full even though some work also occurs in the fixed witness. This
is the [fixed floating callback transfer](retained-native-expansion.md#fixed-floating-bounds-still-allocate-ada-numeric-metadata), not the
null Main's later-callback-zero claim.

The [original Main source ledger](retained-literal-original-main-storage.md)
establishes at most two nonnegative constant-size annotation roots per literal.
They return through `decl.cc:9347–9358`; they do not create Rep_Table entries,
annotation-cache entries or dynamic annotation serial increments.
`UI_From_gnu` uses either signed32 `UI_From_Int` or at most five stored digit
words (`cuintp.cc:171–222`). The exact exported interface therefore adds 2C Uint
entries and 10C digit words. This leaf calls that unchanged ledger using the
actual decoded lengths, null count and number of distinct called procedures.
The unspecified implicit-with visit count is irrelevant to these numeric fields:
that source branch returns an empty statement list before entity conversion.

The separate [cold String residual](retained-literal-string-layout-storage.md)
does not introduce another Ada numeric callback: Positive/Character have known
Esize, RM size and alignment; unconstrained String has no TYPE_SIZE to annotate.
Its `UI_To_gnu` conversions read Ada integers and allocate GCC constants, not
Ada Uints. The helper and synthetic-function construction intervals operate on
GCC trees; their allocations remain in their own ledgers. These statements do
not import the null program's zero-callback specialization into literal Main.

Thus, through the selected frontend and original gigi construction interval:

| Table | Composed demand allowance |
| --- | ---: |
| Uints | 28,420 + 9C |
| Udigits | 107,726 + (70+k)C, k=uint_digits(C+2) |
| Ureals | 67 |
| Rep_Table | 504 |

These sums bound occupied positions even if temporary digits are released.
The fixed witness's positive growth and the generated constructor/callback
allowances retain discarded work. There is no subtraction for release, cache
sharing or overlap. Other frontend tables and later GCC/counter/collector
closure remain separate; this result supplies neither their costs nor a claim
that the complete original gigi ledger has been integrated.

## Backing and individual numeric objects

The executable [composition](../evidence/retained-literal-ada-numeric-20261018/compose.py)
reuses `native_table_backing_row` unchanged for each of the four demands. For
initial capacity a, increment i and demand d, the sufficient capacity is
`max(a, d+d//1000, max(d,a)*(100+i)//100, max(d,a)+10)`.
It preserves every predecessor check: initial and growth multiplication,
signed capacity plus sentinel, physical and nominal indices, and individual
allocation/pointer-difference arithmetic. In particular the Uint nominal ID
interval remains a separate check from the allocation byte width.

Uintp, Urealp and Repinfo are absent from the pre-backend lock list
(`gnat1drv.adb:1518–1535`). C's Uints/Udigits exports are pointer cells, read
again by conversion rather than cached across table growth
(`uintp.h:104–108`, `cuintp.cc:93–120`). Thus this join applies the existing
growable-table envelope to incoming demand plus callbacks. It does not require
an empty table or a backing pointer to survive reallocation.

The local numeric checker uses the maximum of the retained fixed operand
allowance 74,958, the scanner demand and the Main family's `max(18,k)` envelope.
The fixed allowance dominates in the nominal-Uint passing region, together with
the five-word constant conversion and nine-word float workspace. The unchanged
local numeric checker preserves its dimension/index,
bit-count and decimal-count arithmetic. Each UI_Vector has at most 149,916
words and 599,680 bytes including its descriptor. This is an individual-object
bound, not a sum over recursive frames or an aggregate RAM admission limit.

`UI_From_Int` has 1,023 fixed pointer buckets (8,184 bytes) and individual
16-byte wrappers. The non-direct miss calls `Vector_To_Uint` before insertion
(`uintp.adb:1466–1506`). The bucket structure does not resize with insertion
count; its known wrappers do not become one combined allocation. This packet
retains the original Main 2C and float 4,096 wrapper-request allowances without
pretending that their sum is the complete cache history.

For Hello (C=1), the demands are 28,429 / 107,797 / 67 / 504. Their backing
capacities are 56,858 / 215,594 / 400 / 3,000, giving individual allocations
454,872 / 862,380 / 6,416 / 96,032 bytes including sentinels. All selected
numeric checks pass. No whole-program capacity conclusion follows from them.

## Evidence and scope

The [manifest](../evidence/retained-literal-ada-numeric-20261018/inputs.json)
binds 14 current repository inputs and 47 compiler source files. Source hashes
are inherited from the accepted original-Main and fixed-float source manifests.
Only their source-file identities are imported; their unrelated historical
aggregate pins are not treated as current inputs. The frontend loader separately
enforces its existing repository and full-source checks. The general constructor
formula is unchanged; the numeric specialization now retains its scope width.
The old accepted freeze and review remain historical evidence.

The original 53 focused checks
exercise actual sources, both procedures, empty and 8,192-byte literals, trivia,
invalid-family rejection, the 5,000-call source and the adjacent nominal-Uint
arithmetic boundary. The latter uses demand arithmetic directly, not enormous
allocated sources, and is not a whole-pipeline acceptance boundary. They passed
in 0.455881 seconds, including model loading and input checking. Samples
check the transcription and joins; the source arguments establish the bounds.
The current [focused checks](../evidence/retained-literal-ada-numeric-20261018/check-results.json)
also exercise actual sources on both sides of the 32,765/32,766 scope-width
transition. The nominal-Uint arithmetic check uses the general digit formula.
These 57 affected checks passed in 1.412007 seconds. Finding
[#138](https://github.com/berkeleynerd/silver/issues/138) tracks this correction
and its selected-route attachment; the original `3a7d590389` result and review
remain scoped to their historical inputs.
The [retained pre-repair reproduction](../evidence/retained-literal-ada-numeric-20261018/scope-width-before.json)
records the old rejection and its exact numeric source identity. These checks
do not assert that the other pipeline predicates accept either transition case.

```sh
python3 docs/evidence/retained-literal-ada-numeric-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source
```

The retained [Hello result](../evidence/retained-literal-ada-numeric-20261018/result.json)
keeps all broad completion flags false. No compiler, prover, debugger, build,
solver, full suite or previous component suite was executed. Independent review
is required before this projection is attached to the aggregate.
