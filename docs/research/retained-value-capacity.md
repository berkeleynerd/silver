# String and Uint capacity components for the retained frontend

**2026-10-17 — partial derivation for #119, under #91 and shared with #93.**
This supplies compositional upper charges for named String allocation events
and one successful scan of an admitted-form integer token. It also bounds the
Uint primitives needed for ordinary bounded scalar folding and closes literal
scan multiplicity for one syntactically valid Main parse. These are useful
components of a capacity rule, **not a complete source-to-tool allocation
bound or a new membership rule**. Dependency scans, fold multiplicities, generated code,
dependencies and other representations still need closure. Current production,
language, catalogue, proof artifacts, Oracle and tool pins are unchanged.

The components use GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
The [reproducer and output](../evidence/unbounded-programs/retained-value-capacity-20261017/README.md)
verify 27 inspected files against the retained complete-tree manifest and
evaluate the arithmetic below. Applying source conclusions to an installed
compiler retains the [existing correspondence premise](unbounded-frontend-lifetimes.md#reproducible-scope-and-premises).
Nothing here establishes the separate GNATprove producer's exact source identity
or transfers a GCC bound to that process. Validation was source/hash inspection
and bounded integer arithmetic on Linux; no compiler, prover, application,
full-suite, macOS or CI run occurred.

## Counting convention

An allocation charge is an upper bound on **total appended entries**, including
ones subsequently released. Adding nonnegative charges therefore bounds every
logical peak, without requiring a garbage-collection or cache invariant. It can
overcount substantially. Physical backing capacities and each growth intermediate
must separately satisfy the generic Table arithmetic contract; a logical count
within a nominal ID range does not establish that contract.

Keep a vector `(String descriptors, String characters, Uint entries, Uint digit
words)` and separate local-vector sizes. Compose successive event charges by
addition and simultaneous local-vector requirements by the actual call stack.
The calling phase supplies its initial retained state. The initialization and
selected dependencies are not free: Stringt creates the null descriptor, and
Uintp converts both host Integer endpoints before ordinary scanning
(`stringt.adb:108–117`; `uintp.adb:484–502`).

An event is an actual call identified below. Replacing event multiplicities with
source token/operator counts requires the missing caller-coverage argument.
The examples in this record deliberately keep that premise visible.

## String transfers

Let `C` be the number of logical character entries before an event, and let
`l` and `r` be its operands' lengths. For current String expressions these are
nonnegative; use an established upper length when a value is not exact.

| Event | Extra descriptors | Extra characters | Source and reason |
| --- | ---: | ---: | --- |
| One successful ordinary ASCII literal scan of decoded length `l` | 1 | `l` | `scng.adb:1101–1229`: one Start_String, then one append per decoded character; doubled quotes contribute one character |
| `Get_String_Val` on an existing literal or constant-alias chain | 0 | 0 | `sem_eval.adb:5293–5308`: returns/follows existing nodes; no Stringt operation on the valid path |
| One successful String/String `Eval_Concatenation`, left length positive | 1 | at most `l+r` | `sem_eval.adb:2395–2422`; `Start_String(left)` copies at most `l`, then the right append adds `r` |
| Same fold, left length zero | 0 | 0 | `sem_eval.adb:2404–2405`: retains the existing right String_Id |
| One parser flattening of a plain literal chain | 1 | sum of the chain's literal lengths | `par-ch4.adb:2613–2657`: one Start_String and one append of each literal |

The concat transfer follows directly from `stringt.adb:164–192`: it shares the
left range only when the range ends at the current pool tail; otherwise it copies
that range. `Store_String_Chars` then grows the logical character tail by exactly
the copied operand's length (`221–243`). Giving no sharing credit is sound for
these calls regardless of interleaved lexical literals or other allocations.
Scope exit is not a release. A later alias reference uses the existing descriptor;
it does not recursively re-elaborate its declaration's initializer.

For a single evaluation tree with caller coverage established, define the
deliberately conservative fold-only transfer:

```text
length(literal l) = l                 fold_chars(literal) = 0
length(name x) = environment[x]       fold_chars(name) = 0
length(a & b) = length(a)+length(b)
fold_chars(a & b) = fold_chars(a)+fold_chars(b)+length(a)+length(b)
fold_descriptors(a & b) = fold_descriptors(a)+fold_descriptors(b)+1
```

This charges even empty-left and non-folded concats, so their implementation
optimizations cannot increase the counted Stringt demand. Lexical scans and
parser flattening are separate charges. Ordered declaration lengths can be
computed through the existing semantic environment without constructing the
String's bytes. A mutable object or runtime Image needs a sound length summary;
these equations do not establish how many times its generated code is processed.

### Parser flattening is a separate reachable allocation route

After at least 1000 concatenations of plain literal terms, the parser replaces
the chain by `"" & "combined literal"` to avoid deep semantic recursion
(`par-ch4.adb:2546–2657`). It has already built the original nodes and scanned
the lexical Strings. The replacement copies all literal characters into one
additional descriptor. `Eval_Concatenation`'s empty-left path then returns that
descriptor without copying it again. The former 63-operator limit hid this
route from currently admitted source; removing that limit makes it relevant.

For 1001 one-character literals, one scan each and one parser flattening charge
2002 characters and 1002 descriptors, before dependencies/generated data.
This is source arithmetic, not observed native allocation. Charging every
original concat result *as well as* the parser copy is conservative but loses
the linear behavior this optimization supplies. A useful final rule should
select the parser-transfer alternative when its syntactic preconditions and
caller count have been established.

For comparison, two separate 30-step doubling chains with final lengths `2^30`
receive a no-sharing charge of `2 + 2*sum(2^j, j=1..30) = 4,294,967,294`
characters. The earlier retained-value obstruction was a **lower** bound of
`2^31`; these are different claims. Neither number is a selected admission cap.
Exact tail tracking could reduce the upper charge, but needs complete allocation
order, including the parser's up-front scanning and selected dependencies.

### String representation premises

For the audited operations, `C <= Int'Last` and every descriptor's
`start+length <= C` make the character endpoint sums and empty-tail starts
representable; each concat also needs `l+r <= Int'Last`. The intermediate
`start+Index` in `Get_String_Char` must fit *before* subtracting one
(`stringt.adb:96–102`). This is why the occupied final index being representable
alone is insufficient. Apply the table-transition checks to every append/bulk
extension and final Lock; do not treat these local conditions as all consumers'
arithmetic proof.

The nominal String region has 100,000,000 codes, but `No_String` consumes its
first code. `First_String_Id = -499,999,998` through `-400,000,000` supplies
**99,999,999 usable descriptors, including the initialized null String**
(`types.ads:348–350,504–512`). There are 99,999,998 further nominal descriptors
after initialization, before dependencies. Generic Table instantiates with the
base index type; the nominal ID count is a rule obligation, not evidence of a
graceful check at that count. The [table component](retained-table-capacity.md)
owns backing growth and phase transition arithmetic.

## One integer-token scan

This component covers ordinary integer tokens with base `b` in `2..16`,
nonnegative exponent `e` bounded by `E`, and final unsigned magnitude at most
`M=2^31`. Use `E=4096` for the current language and the proposed `E=799999`
only for analysis of that proposed extension. A leading sign is an expression
operator, not part of the token. The magnitude `2^31` permits directly signed
`-2147483648`; it does not admit a positive Integer of that value. Length
literals have a smaller domain but satisfy the same upper premise.

For `m*b^e <= M`, every nonnegative mantissa prefix is at most `m <= M`.
When `m=0`, however, the scanner still computes `b^e` before multiplying by zero.
The final magnitude bound alone therefore cannot bound its intermediate power.
The scanner route is `scng.adb:500–541,649–650,704–745,760–785`.

### Prefixes and direct values

Uint's radix is `B=32768`; direct nonnegative values end at
`D=(B-1)^2=1,073,676,289` (`uintp.ads:464–475`). Write
`digits(v)=max(1,ceil(bit_length(abs(v))/15))`.

For each mantissa digit `d`, the scanner computes `t=p*b`, then `p'=t+d`.
Each value above `D` needs at most one new Uint entry and `digits(value)` words;
all values here have at most three words. Charge the product when `t>D` and
the sum when `p'>D` and `d!=0`. A zero addition to a table-coded operand returns
that operand (`uintp.adb:814–819`). Every other direct result allocates no Uint
table entry. Ignoring UI_From_Int's hash reuse is conservative. Leading zeros
and separators do not cause a large retained numeric value.

The decimal base-prefix value is at most 16; the exponent and every decimal
prefix of it are at most 799999. Their multiply/add results stay direct, so
these scanning operations allocate no Uint/Udigits entries. Their scanner
position and `Scale := Scale-1` arithmetic still need source-position bounds;
this component does not waive the line/source accounting.

### Power construction without materializing the power

Set `k=ceil(log2(b))=(b-1).bit_length()` and

```text
P(b,p) = max(1, ceil((k*p+1)/15)).
```

Because `b^p <= 2^(k*p)`, `P` bounds the stored radix-32768 digit count. It is
exact at powers of two and conservative for other bases. Determine whether a
power is direct by exponentiation saturated at `D+1`; no giant integer is
needed. For each produced power with value above `D`, charge one Uint entry
and `P(b,p)` digit words.

`UI_Expon` has two different paths (`uintp.adb:1357–1451`):

- For bases 2 and 10 with `2<=e<=128`, the cold memo table computes powers
  `1..e`. Charge that sequence. A previously initialized prefix only reduces
  this cost. The memo table advances the protected minimum; no release credit
  is taken.
- Otherwise, for `e>1`, track `n=e`, `s=1`, `r=0`. If `n` is odd, append a
  multiplication event with exponents `(r,s)` and set `r:=r+s`; halve `n`;
  if it is still positive, append `(s,s)` and double `s`. The result exponents
  never exceed `e`. There are exactly `popcount(e)+floor(log2(e))` multiplication
  events. Halving `n` takes the direct `UI_Div_Rem` path and produces only direct
  quotient/remainder (`uintp.adb:1045–1059`), hence no table allocation.
  Finally charge one further copy of the resulting power when table-coded:
  `Release_And_Save` may append it after release (`693–717`). Counting all
  earlier events as retained makes that release and any protected minima safe.

`e=0` bypasses exponentiation and the final multiplication in the scanner;
`e=1` returns the direct base. Once a positive power is obtained, the final
mantissa multiplication contributes no Uint/Udigits allocation for `m=0`:
the zero vector returns direct zero (`uintp.adb:2421–2423`). For `m>0`, charge
at most one entry and three words if its final value exceeds `D`.

This closes the Uint/Udigits append routes inside **one successful Nlit call**
under the token premises. It does not count Simple_HTable node allocation from
UI_From_Int, source buffers, scanner token nodes, later semantic processing, or
multiple scans of the same token. Each UI_From_Int cache insertion has at most
one associated table-producing conversion in this component; the cache's own
representation still belongs to the auxiliary-allocation inventory.

### Local vectors and primitive arithmetic

`UI_Mul` creates operand vectors of `d_l,d_r` words and a product vector of
`d_l+d_r`, giving `2*(d_l+d_r)` simultaneous vector words
(`uintp.adb:2033–2069`). Each multiplication event above carries this bound using
`P` for its operand powers. `Release_And_Save` needs a copied result vector of
at most `P(b,e)` words. The final zero-mantissa multiply still needs at most
`2*(1+P(b,e))` words: zero's lack of a retained result is not zero work.

The mantissa prefix's multiply/add needs at most 16 simultaneous vector words:
multiply has `3+1+4`, and general add has operands `3+1` plus three length-4
vectors (`uintp.adb:824–862`). Direct conversion has at most three words.
These are local vector lengths, not stack-byte or peak-RSS measurements.
Array descriptor/address arithmetic and resource exhaustion remain distinct.

For later ordinary scalar folding, the Uint/Uint overloads also give the
following per-call bounds when both inputs and mathematical result have
magnitude at most `2^31`; the output bound is an explicit premise:

| Primitive | Extra Uint entries | Extra digit words | Local vector words |
| --- | ---: | ---: | ---: |
| `UI_From_Int` | at most 1 | at most 3 | at most 3 |
| `UI_Negate` | at most 1 | at most 3 | at most 3 |
| `UI_Add` | at most 1 | at most 3 | at most 18 |
| `UI_Mul` | at most 1 | at most 3 | at most 12 |
| `UI_Sub` | at most 2 | at most 6 | at most 18 |

`UI_Sub` may negate its right operand and then add (`uintp.adb:2232–2239`);
that temporary may be positive `2^31` even for Integer source values. It still
has three digits. `UI_Negate` uses one operand vector (`2153–2180`). `UI_Add`
uses two operand vectors and three vectors of `max(d_l,d_r)+1`. Multiplication
digit arithmetic has `Tmp_Sum <= (B-1)^2+2*(B-1)=B^2-1 < Int'Last`, with
carry at most `B-1` (`2057–2066`). Vector-index arithmetic needs the stated
length bounds. These rows are not bounds for all helpers called by
`Eval_Arithmetic_Op`, range checking, subtype creation or expansion.

### Reproduced discriminators

The table gives the append-only upper charge for **one** zero-mantissa token
scan. It includes temporary power values and the save copy, ignores releases,
and excludes all other tool paths and initial tables.

| Token | Uint entries | Digit words | Local vector words |
| --- | ---: | ---: | ---: |
| `0E4096` | 11 | 4,373 | 2,188 |
| `0E799999` | 27 | 785,347 | 426,670 |
| `2#0#E799999` | 25 | 196,348 | 106,670 |
| `16#0#E799999` | 28 | 785,350 | 426,670 |

These replace no retained lower bound or actual measurement. The earlier
177,170-word decimal result was a retained-power lower component, whereas this
785,347-word charge includes all conservatively counted power events and uses
a four-bits-per-exponent upper estimate. It is not the amount allocated by an
observed compiler run. The reproducer checks the digit inequality and event
counts for 3,885 base/exponent cases; this arithmetic exercise supports the
derivation and is not a universal proof or tool execution.

## Main parser multiplicity

Scanner-state restoration restores token/source fields and a prior Token_Node,
but does **not** restore Stringt or Uintp (`scans.adb:170–214`,
`scans.ads:524–536`). The saved token itself is reused; subsequent tokens may be
scanned again. Thus a lexical-token budget cannot silently assume one Nlit/Slit
call per source occurrence. The evidence contains textual save/restore matches
in the selected parser files, with LF-based lines; this inventory alone is
neither a resolved complete call graph nor an allocation multiplier.

For one syntactically valid Main parse under the unchanged Silver grammar,
**each source String/numeric literal is scanned at most twice**. This remains
true if the source/operator/leaf/value bounds are relaxed while the grammar and
lexical rules remain unchanged. It bounds `Slit`/`Nlit` calls, not all nodes or
semantic transformations. Independent source review checked these caller paths:

| Reachable path | Why it cannot introduce further literal rescans |
| --- | --- |
| Simple/qualified names, Image and Length (`par-ch4.adb:217–940`) | Dot/apostrophe probes scan punctuation or attribute names. `Id =>` probes scan only the token immediately after an identifier; in valid Silver actuals that is punctuation/operator, never another literal. Each call has one actual. |
| Grouped expressions (`par-ch4.adb:1579,1665–1684,1773,2201–2257`) | Valid groups return at the right parenthesis before the aggregate rewind. Inner expressions use ordinary relation/expression parsing, not the special lower-range parser. Aggregates are excluded. |
| Object declarations (`par-ch3.adb:159,1214,1443–1611,1956`) | One defining identifier excludes the declaration-reparse loop. Subtype probes see `:=` or `range` after String/Integer. Required `:=` excludes the missing-initializer-symbol recovery. |
| Ranges (`par-ch3.adb:2172–2183,3043–3078`; `par-ch4.adb:2890–2917`) | A parenthesized lower bound is preliminarily parsed then rewound, hence its literals can be scanned twice. Inner groups do not recursively invoke that special path. The upper bound uses ordinary expression parsing. These bounds contain only scalar expressions. |
| Conditions (`par-ch5.adb:1360`; `par-ch4.adb:2096–2123`) | Conditions use ordinary expressions and terminate at `then` or an enclosing `)`, so the semicolon/comma recovery lookahead does not run. |
| Statement keyword heuristic (`par-ch5.adb:285–328`; `par-util.adb:516–603`) | Depending on keyword casing, the heuristic may scan the token immediately after `if`/`elsif` and restore. Only a literal starting the condition gains this extra scan; grouping starts with punctuation. Correctly matched nested statements do not repeatedly revisit an outer `elsif`. |
| Statement calls and assignments (`par-ch5.adb:506–658`) | Dispatch probes only `:=`, `.`, or `(`. The actual call/RHS parser consumes the expression once. The separate same-line `else` lookahead is detailed below. |
| Main shell, pragma and end (`par-ch6.adb:406–438`; `par-ch2.adb:642–707`; `par-endh.adb:1155` onward) | The procedure-`is` probe sees the mandatory pragma. Its sole argument is `On`, with no literal. No outer configuration pragma is permitted. Correct end matching does not rewind into the body. |
| Aspects and token helpers (`par-ch13.adb:108`; `par-tchk.adb`, `par-util.adb`) | Absent `with`/`when`, aspect parsing returns. Matching punctuation takes the normal token-check branch. Calls have one actual; source sequences cannot enter comma/error recovery. `Next_Token_Is` callers are generic/record paths absent from Main. |

The extra literal scans are disjoint: same-line `else` scans can reach only
the first call's argument; `if`/`for` stop it and `:=` stops it before an RHS.
Grouped lower bounds have no conditions/calls. A keyword probe scans only the
first condition token, which cannot simultaneously be in a lower bound or an
`else` call argument. Thus no source literal receives all three charges.
This is a grammar/caller argument; the textual rewind-site count would not
establish it. Each independent compiler phase needs its own parse charge.
Fixed library sources have a broader grammar and are not covered.

Let `S` be the source String-token count, `L` the sum of their decoded lengths
and `A` the source `&` count. Lexical scans contribute at most `2S` descriptors
and `2L` characters. Each parser-flattened chain contains at least 1000 concats
and only plain literal nodes. Its replacement is an `N_Op_Concat`, so an outer
chain containing it cannot itself satisfy the plain-literal condition; flattened
chains' source literals/operators are disjoint. They contribute at most
`floor(A/1000)` descriptors and `L` characters. Consequently **Main parsing
alone** contributes at most `2S + floor(A/1000)` descriptors and `3L` characters.
Parser flattening does not apply to scalar lower-bound probes; `else`/keyword
lookahead only scans. For numerals, twice the sum of the per-token Uint charges
above conservatively bounds parsing, including discarded lookahead allocations.
Initialization, dependencies and semantic/generated allocations are additional.

### A reachable extra scan after `else`

`Else_Should_Be_Elsif` (`par-ch5.adb:1238–1262`) is called after scanning
`else` (`1321`), including valid programs. If the next token does not start a
new source line, it scans to an expression terminator and restores the saved
state. `Token_Class_Eterm` is the enum range from `Tok_Colon_Equal` through
`Tok_Semicolon` (`scans.ads:126–199,296–297`). Consequently an output call
written on the same line as `else` can have its entire argument scanned twice:

```ada
else Silver_IO.Put_Line ("x" & Integer'Image (0E4096));
```

The lookahead visits the String and numeral before the semicolon; the normal
call parse scans them again. The scan-state restoration does not release their
pool entries. For this lookahead invocation, charge one additional literal-scan
event per String/numeral token in the visited call suffix. In the example, the
extra contribution is one String descriptor, one character and the
`0E4096` upper charge above (11 Uint entries and 4,373 digit words). These
charges exclude the ordinary parse, generated code and other calls.

For an assignment, the lookahead stops at `:=` before scanning its RHS. A
first `if` or `for` statement is already an expression terminator;
its condition, bounds or body is not scanned by this lookahead. For `null;`,
the lookahead scans only the following semicolon. A newline
before the first token skips this lookahead entirely. For valid Silver's
output-call grammar the semicolon bounds the scan, so this invocation does
not multiply later statements or nested bodies. It only scans tokens; it
does not invoke the parser's long-concat flattening transformation.

This is a closed local rescan contribution derived from the pinned source,
not an executed compiler trace. It is one part of the parser bound above.
It refutes treating all literal rescans as erroneous-source recovery and
shows why whitespace can affect allocation even when the token sequence is
unchanged.

## Semantic caller coverage still required

Successful alias resolution itself does not allocate String characters, but
`Fold_Str` calls Analyze and Resolve after rewriting (`sem_eval.adb:5118–5144`);
generated-subtype/check costs and any allocation-producing reentry still need
counting. `sem_res.adb:10804–10831` resolves concat operands and constructs
subtypes even when a concat does not fold. Full-tree copying/expansion must not
be charged only as author syntax. The remaining String-producing inventory also
includes generated enumeration image/name support (`exp_imgv.adb:184–203,
821–836`), diagnostic/name materialization (`exp_util.adb:7277–7302`), and
String_From_Numeric_Literal (`sem_util.adb:29409–29416`). The latter is entered
through a user-defined-literal aspect test (`sem_res.adb:499–510,587–590`),
excluded for author Integer/String types but still requiring dependency closure.

The next composition step must attach justified multiplicities and lengths to
all relevant calls in the selected GNAT build phases and fixed dependencies,
then apply table arithmetic, node/name/source costs and producer/backend rules.
Until those obligations are closed, these components cannot justify removing
the current caps or completing #119, #91, #93 or milestone 5.
