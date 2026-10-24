# Why response to GNATCOLL parser capacity

2026-10-23–24 UTC; owner-authorized #119 / #186 research. Candidate for independent
review. This supplies a computable representation interface through
`GNATCOLL.JSON.Read_File`'s return or existing failure propagation. It changes
no implementation, admission, Oracle, invocation, or source pin. Later
GNAT2Why result aliases, proof messages, assumptions and `.spark` remain #119
obligations. Production #88–#94 remains unstarted; PR #121 remains draft.

The [packet](../evidence/retained-response-parser-capacity-20261023/README.md)
pins the accepted response/reporting inputs, the newly needed source, and the
[mathematical guard](../evidence/retained-response-parser-capacity-20261023/capacity.py).
The source argument below is essential: the offline checker does not prove
Ada semantics by testing generated responses. It runs no native tool and
replays no predecessor checker.

## Source correspondence and scope

The GNATCOLL candidate is revision
`1d4374ae9187fd14d42ca99a3deb0ab2ff1ebc55`, from the already retained complete
archive SHA-256 `945ec0ba0af2f33361ed80de7aabafa6aa8f4d4a6149896e70f2fb1c6c2ef676`.
The original response identity's premise is preserved verbatim: **“Candidate
source behavior and current installed config/driver bytes; no historical
binary-source identity claim.”** Existing JSON/Buffer/Strings_Impl/Atomic
bytes agree with that provider; missing Buffer declarations, String_Builders,
Strings instantiation, Unix file wrappers and mmap source were extracted from
the same archive. The packet also retains the actual installed GNATprove
16.1 runtime-source files needed for vectors, ordered maps, atomics, pathname
normalization and numeric conversion. Its atomic declaration agrees byte for
byte with the earlier null-tail snapshot. These are exact source premises,
not an assertion that an arbitrary GNATCOLL/runtime release or the historical
installed executable implements them. Deployment still needs the parent's
source/native correspondence relation; an archive hash alone does not supply it.

Use the selected Linux x86_64 domains: Ada Integer/Natural/Positive and
Ada.Containers.Count_Type end at `I=2^31-1`; Long_Long_Integer is signed64;
String_Size and Atomic_Unsigned are unsigned32 with maximum `U=2^32-1`;
size_t/address arithmetic is unsigned64. Ordinary correct Ada/ABI, controlled
assignment/finalization, atomic, allocator, mapping and OS behavior retain their
existing trusted scope. Adequate physical memory, stack and disk remain premises.
There is no aggregate RAM gate. The candidate can request large individual
objects; this argument addresses their representation, not their availability.

All scalar inputs below must be source/configuration-derived upper bounds,
computed with mathematical integers. An absent input or a false sufficient
guard means the interface is unestablished for that configuration. It is
neither evidence of actual overflow nor authorization for a language cap.
In particular, observed response length or successful parsing cannot supply B.

## Separate intact and interrupted response inputs

For an intact normal response import the current canonical J12 response
providers: R check records, G reported goals, A attempt-binding occurrences,
N parser owners, and W_o/L_o other-warning count/bytes. This retains fresh
nonreplay, CE-off, no-manual and selected metadata conditions, including the
actual `get_model=None` relation, and the prospective canonical-file refinement.
The current A is the accepted `A0+E`, **not** the old `4G` estimate; repeated
bindings are counted. Main may keep these source-derived parameters symbolic
until #185 and its subsequent joins provide them. In particular, the fixed-five
other-warning maximum422 and debug-buffer26619 must not be transplanted to
arbitrary Main. The executable interface requires explicit source-derived
`other_warning_max` and `debug_bytes`; use its own providers for those inputs.
The substitutions below describe the selected fixed-five configuration.

Set `S=5R, K=26, L_T=1051, O=76 max(A,N)` and, conservatively,

```
W   = O+N+W_o+1
L_A = 4O+64A
L_W = 514O+512N+L_o+26619
C   = 4+6R+S+3G+A
V   = C+9R+3S+3A+K+W+1
F   = 4+14R+4S+2G+4A+K
B_n = 212+987R+549S+189G+489A+321K+3W+6(L_A+L_T+L_W).
```

C counts containers, V values excluding keys, and F field occurrences. Each
array has at most `max(R,G,W)` entries; each object at most `max(8,K,5,A)`.
Using all A for a single attempts object is deliberately safe for repeated
prover names; `Include` replaces an equal key and cannot enlarge that count.
Empty transformation/model objects/arrays retain the accepted schema. Maximum
container depth is seven and parser depth including its sentinel is eight.

The fixed schema and timing/prover keys are ASCII, of maximum 59 bytes:
encoded key including quotes <=61. Each selected canonical parser input has
at most 76 bytes. Applying the answer/warning argument **per invocation** gives
an answer <=368 bytes and any consecutive-answer warning <=
`2*76+512*(76+1)=39576` bytes. Other selected warnings are <=422 each; the one
final debug-buffer warning is <=26619. Thus every source string is <=39576,
its encoded token is <=237458, and its decoded UTF-8 string is <=79152.
These maxima do not multiply the largest string by all V to infer refcounts.
Integer tokens are <=20 bytes; finite selected double tokens <=317 bytes.

Why's serializer emits every non-ASCII **byte** as `\u00xx`; it does not decode
an arbitrary UTF-8 source string before escaping. A byte becomes at most two
UTF-8 bytes in `Un_Escape_String`. Fixed ASCII keys stay ASCII. The packet
checks all 256 byte cases. This twofold bound must not be applied to arbitrary
Unicode code points or a differently implemented serializer.

An isolated complete terminal error is a different schema:
`{"error":string,"internal":bool,"results":[]}`. For payload bound x it has
C=2, V=4, F=3, depth=2, array cardinality=0, object cardinality=3, encoded
key<=10, encoded token<=`max(6x+2,10)` and decoded string<=`max(2x,8)`.
Its prospective text bytes are <=`42+6x`; boxed layout is charged next.
A terminal error remains an error. None of this treats it as a successful proof.

## Offered stdout bytes even after failed output

Do not assume failed reporting leaves an isolated valid JSON document. The
accepted channel contract commits prefixes of each successful write; Format's
dirty state can drop pending material and later abort attempts can splice
quote/escape context. Payload brackets can then be parsed as structure. A
sum of original schema depths would be unsound. We also do not add a new #88
framing policy to exclude such files.

The accepted interrupted-core theorem proves each enqueued token is formatted
at most once, including abandonment and dirty resets. Its general bound
`B+70(E+2)` can be sharpened here using the **actual nontext event classes**:
normal `print_json_single_line` has no opens/breaks; each boxed abort has five
hv1 opens and five width-one breaks. Each processed begin/break offers at most
69 layout bytes (newline plus at most 68 blanks). There are at most two
process-global exit flush attempts, at most two reset-system begins plus the
initial stdout system begin, and at most two final flush newlines. Close/end
tokens add no output. At most5a<=20 user-open depth credits can remain
unclosed, plus the one system level; reset cannot increase that maximum.
The selected default max_boxes=OCaml max_int is far above21, so opening a box
cannot take the extra ellipsis-text path. No text payload becomes a format
program. Therefore

```
Y_stdout(T,a) = T + 69*(10a+3) + 2
```

bounds bytes offered to stdout when T bounds all its prospective text and a
bounds attempted abort invocations. Using a both-root text bound for T is safe;
using both roots' generic layout allowance is unnecessary. Dirty boxes need
not be balanced: the inherited core theorem still bounds each processed
begin/break's layout, its queue-cell multiplicity, and default indent setting.
No fresh core, successful flush, contiguous offered document, eventual output
success or renewed exceptional allowance is assumed. Positive committed byte
counts plus retained channel debt are bounded by offered bytes. For the
selected new response file/pipe there is no unrelated initial stdout content;
the parent's descriptor ownership/publication relation remains required.

For the post-cut alternative use the current reporting provider's
`T = B_n+84+6X`, `a=2`, where X sums its at-most-two terminal payloads. Its
standard-core arithmetic and source/service conditions must also hold.
The sharper stdout-only argument does not weaken those conditions.

For fixed pre-cut failures import author `62cb8175ab11041a8f8396eac699f722cb616675`,
reviewed at `33b2eb6f8780133eac5385c4d59f4869dbef55de`. In that alternative
`PrecutP=max(180,|initial client cwd|+10)` and U_label is the fixed label bound:

```
S0=max(467,U_label+256,4*PrecutP+2048)
C0=8*(723+12*S0)+65536; R4=31*C0
X_pre=4*(R4+PrecutP+1024)
T_pre=6*X_pre+576; a_pre=4.
```

T_pre conservatively includes the provider's stderr text. The earlier initial
standard-prefix/failed-startup attachment is required: no unclassified stdout
writer is introduced here. Normal continuation and abandoned pre-cut failure
are alternatives, not additive budgets. The same global e<=2, two save-entering
callbacks, three saves and once-gated exit hooks are retained throughout.

For any possibly malformed offered stream bounded by b=Y_stdout, use the
separate conservative profile

```
B=token=encoded_key=decoded=depth=array=object=C=V=F=b.
```

A parser event/token consumes input monotonically. Each value/field/container
creation needs at least one input byte; successful string decoding emits no
more bytes than its encoded token. This includes ordinary byte characters and
all tokenizer-accepted Unicode escapes: one six-byte escape emits <=3 UTF-8
bytes, or a twelve-byte surrogate pair <=4. Even a malformed document has a
well-formed *token* before `Un_Escape_String` is entered. The utility's surrogate
lookahead is safe: the closing quote covers `Idx+5`; when that byte is a slash,
tokenizer validation supplies the next escape character and, for `u`, four
hex digits. No assumed validity of the whole stream is used. A syntax error
stops further creation. A numeric range error follows the existing outcome
below. This broad profile pays for arbitrary changed quote context without
pretending the original depth-seven shape survives.

## Reader, offsets, endpoints and the stream counterexample

`Read_File(Path)` creates `Buffer.Open(Path)`, then `Read(Data)`, whose first
`Parse_Next` calls `Skip_Whitespaces`. The latter uses
`Next(Data, CC, Offset)`; so do string/number scans. In the selected candidate
`Buffer.adb:223–238` this overload increments Offset only while `Offset<Last`;
it **never calls Internal_Next**. At the endpoint it sets EOF and returns false.
The other Next overload can refill, but `Check` reaches it only after a literal
has already been scanned. `Buffer.ads:163–191` defaults Current/First/Last and
the signed64 Offset to zero. Open(Path)'s stream branch initializes FD and
64KiB storage, but does not fill it. Consequently its first offset scan sees
Last=0, reports DOC_END in EXPECT_VALUE and returns a parsing error. This is a
counterexample to using the older response note's stream-window envelope as
a successful `Read_File` capacity theorem. Tracked as [#187](https://github.com/berkeleynerd/silver/issues/187), it is a finding about the **pinned
candidate source**, not an experimentally established installed binary defect.

For successful regular-file parsing require the source byte bound plus spare
`B+256<=I`. Open(Path) then selects its <=64KiB read or whole-file mmap branch,
with `First=1, Current=0, Last=n<=B, Offset=0, FD=Invalid_FD`. For every reached
scan, `0<=Current,Offset_local<=n`; Next increments only below Last, and false
Next does not increment. `Current_Position` is therefore in `[0,B]` in
signed64. A returned token has `1<=First<=Last<=B`; subtracting the zero base
and converting to Integer is safe. Token slices retain their original lower
bounds, so this is an endpoint proof as well as a length proof. Number
lookahead backs up by one only after a successful Next. Valid root objects
end at `}`; EOF scanning adds no stored `n+1` character.

In this mode Release does nothing because FD is invalid. Thus **no held-window
shift, `Hold+1`, `Hold+capacity/2`, capacity doubling, offset update, or
`Current+1` in Release occurs**. Their guard is reached-path exclusion, not an
unchecked token-window formula. On the early stream/error branch Current=0,
Release can set First=1, but the first scanner still returns the error before
any refill or doubling. The whole-file guard is required by this implementation;
token guards alone cannot replace it. Changing that behavior requires a new
source and proof attachment, outside this documentation task.

On Linux mmap uses File_Size=size_t, offset zero and whole-file length n.
Its page expansion computes `n+page-1` then aligns down; require
`B+page-1<=2^63-1` (stronger than unsigned64), with represented positive page.
Pointer conversions, the underlying mapping, and file stability retain the
ordinary selected native/OS service relation; mmap is not proof of physical
availability. The small read requests at most 65536 bytes. Its returned prefix
is at most the requested length, including a short read. A failed read/open or
mapping retains its existing error behavior rather than acquiring successful
file/content status from the byte inequality.

Path input is separately bounded. Let p bound the path's actual bytes and m
the selected positive `__gnat_max_path_len` value. Unix Stat normalizes relative
paths with Resolve_Links=False: `s-os_lib.adb:2041ff` allocates
`p+2m+4` scratch bytes and `m+2` link scratch, prepends at most m cwd bytes and
one separator, and then only removes components. Require these Integer
endpoints to fit and use `p_abs=p+m+1` for its String_Builder. The reached native
Get_Current_Dir contract must respect its supplied m-byte destination; an
unavailable cwd/error does not become a valid normalized path. Absolute paths
use the smaller original p. Unix FS.Open's static builder uses p+1; mmap's
open error adds the fixed `"Cannot open "` prefix. `p+64<=I` covers those
strings. This does not attach an unknown GNAT2Why cwd/path or silently reuse
the different Why-client PrecutP. Both remain named configuration inputs.

## Token decoding and the two string backings

The String_Builder keeps the **encoded** key, including quotes. Each Set first
sets Str_Last=0, then appends one token; prior keys do not accumulate.
`Allocate` repeatedly doubles a Natural capacity starting at 64 until it
covers `Str_Last+Chars+1`. The extra byte is a NUL. With key bound k, require
`kb=max(64,pow2ceil(k+1))<=I`. This bounds the additions, all doubled capacities,
copy endpoints and `New_Last+1`, including reuse of a previous large backing.
Use the same formula on p_abs for Stat's dynamic path builder.

`Un_Escape_String` trims the already validated quotes, then appends one raw
character or one bounded UTF-8 encoding. Its indices stay within the input
token plus one; the file spare also covers substrings and fixed error text.
The XString starts empty, remains unsliced with First=1, and is only appended
during decoding. For a decoded length bound d, an actual growth call has
`Current_capacity < requested_size <= d`. Accordingly define

```
c=max(0,d-1); z=max(floor(3c/2),d)
r(z)=z+(z mod 2)                     if z<=4096
     =(floor(z/4096)+1)*4096          otherwise
xb=max(24,r(z)).
```

Require `3c<=U`, `xb<=I` and `xb/2<=2^31-1`. These guard the **intermediate
unsigned32 Current*3**, division, page quotient+1, multiplication by4096,
even rounding, Half_Capacity storage and its later multiplication by2. Exact
page multiples above4096 round to the *next* page. Fitting only the final Ada
String would miss the unsigned32 intermediate wrap.

It would also be needlessly restrictive to multiply the maximum final backing
by3: an overallocated final backing is never grown again after decoding stops.
Before each actual growth its current capacity is below d. Append computes
`Current+1` or `Current+small_UTF8_length`, First+Current and the final endpoint;
all are <=d or d+1. The guard's spare covers these. The selected Character
instantiation has one byte per character, 23 small bytes on this ABI, and a
four-byte atomic header when copy-on-write is enabled. Every allocation request
is <=xb+8, well inside size_t. No Reserve, substring or mutation of a nonempty returned string is performed
by this parser after its construction. Shared COW handles do not clone it.
If lock-free COW is unavailable, ordinary XString copies instead allocate an
independent represented buffer; the same size bound applies.

## Parser, array and map storage

For depth h set `q=max(32,pow2ceil(h+1))` and require q<=I. The extra one is
the parser sentinel; the builder uses at most h slots. Both arrays begin at32.
For intact normal/terminal responses q=32 and no growth occurs. The malformed
profile may grow; every allocated doubled endpoint is <=q and every push
index <=h+1. Empty/end events pop only an existing state: parser syntax checks
precede builder dispatch. Never count only the active builder prefix: its
popped Read_State cursor slots are **not cleared**.

JSON arrays instantiate Ada.Containers.Vectors with Positive indices and
controlled JSON_Value elements. For per-array n require `n<=2^30-1`.
`a-convec.adb:205–230,960–1319` makes append Count=1, before=Last+1. The backing
starts at1 and doubles at most to2^30; new length, No_Index=0 plus capacity,
last+1, slice endpoints and Count_Type conversions fit. There is no middle
insertion or nonempty JSON_Array copy in this parser: Create receives only
Empty_Array. Array growth copies elements before freeing the old backing.

Object fields instantiate Ordered_Maps, not a hash table. Bound distinct
fields by f<=I-1. Include performs lookup then either inserts one node or
replaces its key/value. `a-coorma.adb:684–747`'s new-node aggregate contains
one XString and one JSON_Value; tree rebalancing changes pointers/colors, not
payload multiplicity. Generic tree-key insertion increments Count_Type length
once only; its optional endpoint check is not needed under f<=I-1. The comparison borrows both XStrings,
gets their represented lengths, then compares bounded slices. There is no
hash-capacity/load-factor multiplication. Duplicate field occurrences may
replace a subtree but do not create graph sharing with another parent.

The selected x86_64 fixed record layouts (tag/control words, scalar/discriminant,
pointer fields and alignment) are each below256 bytes: JSON_Value, Read_State,
vector descriptor/header, map node including key/value, and JSON internals.
Thus `256*(q+1)` and `256*(pow2ceil(max(1,n))+1)` bound each variable-length
array request including its header; individual map nodes are fixed-size.
Require each such request, kb, path backing and xb+8 below size_t'Last.
These are per-object representation checks. They do not sum allocation demand
or presume that sufficient physical resources are available on this host.
Container tamper guards have no iterators or user mutation callbacks here;
comparison and Adjust only borrow/increment. Their bounded local nesting does
not grow with the number of previous tokens.

## Actual ownership and reference counters

Each OBJECT_START/ARRAY_START/string event creates a **fresh** internal object.
Later insertion puts that payload into at most one current parent position.
There is no interning or JSON pointer parsed from input; contents that happen
to be equal remain separate payloads. End events do not insert Tmp again.
Replacement of an equal map key can detach old subtrees but cannot introduce a
second parent for the new payload. The resulting live and detached graphs
remain acyclic. Sharing a JSON container handle does not Adjust its children:
JSON.Adjust increments only that container's atomic Cnt.

For any one payload, the following inventory conservatively charges actual
possible **holding slots**, including slots with stale values and temporaries:

| Holding source | Per-payload upper envelope |
| --- | ---: |
| Builder Read_States, old/new backing during growth, and one full source-assignment temporary | 3q |
| Read's Result, Cursor and Tmp | 3 |
| Parent element/node, old/new vector storage and one slice-assignment temporary | 4 |
| Create's local/aggregate, controlled assignment and Read_State/node expression temporaries | 8 |
| Create/Read R_Result/Read_File result transport and receiving result during finalization overlap | 8 |
| Unused fixed-slot slack | 9 |
| **JSON atomic reference count** | **3q+32** |

Fresh internals start at count1; every controlled copied holder increments once
and each finalized holder decrements once. Under the selected ordinary controlled
assignment/finalization relation, a counter stays positive while a holder
remains and reaches zero exactly when its internal object can be freed. Leaked
holders remain charged; they do not create a fictitious decrement or underflow.
Parameters of tagged JSON_Value/XString are by reference. Map rotations copy
no JSON payload; recursive finalization decrements child counters rather than
copying whole subtrees. The array/record assignment allowance includes a
materialized RHS even when GNAT can eliminate it. At an element's Adjust there
is at most one such assignment expression in each active storage/return
operation; no compiler-independent unlimited-temporary assumption is made.
This is a source/selected-GNAT controlled-assignment argument under the named
native correspondence, not inference from V or F. The packet exercises the
stale-slot and old/new/slice cases separately.

Require `3q+32<U`, conservatively reserving the all-ones value too. For q=32
the bound is128; even q=2^30 gives3,221,225,504 <4,294,967,295. A graph can have
many more total values than a counter's aliases without changing this proof.

An XString's backing counter is separate. Copying a JSON_Value containing a
string shares JSON_String_Internal and **does not copy its Str field**.
An unescaped key is fresh, then becomes one map node key; an unescaped value
becomes one JSON string's Str. No nonempty object/map clone occurs. At most16
XString handles for one backing covers decoder local/result, expression and
allocator aggregate, node or Str holder, assignment and return temporaries.
Both shared and local COW modification paths respect this bound; decoding has
no preexisting external alias. `Unshareable=U` is never set because the parser
never takes variable string indexing. Require16<U. At success, Current_Key is
deallocated, Read_States is freed/finalized and locals/Parser/Reader finalize;
only the returned graph and caller's receiving result remain. Their later
aliases are explicitly outside this interface.

## Numeric values and errors are not proof success

Signed63 Why integers fit the signed64 JSON_Int target. Selected finite double
rendering and the existing valid numeric-locale/conversion premises feed
Long_Float. Later GNAT2Why Natural, Duration or Float conversions are excluded.
For malformed stream tokens, the retained runtime scanner has fixed-size
numeric state: Value_R uses two mantissa/scale parts for Long_Float; decimal
scans keep only bounded mantissa parts, advance indices at most token+1, and
change scales at most once per consumed digit. Scan_Exponent stops increasing
its accumulator after the Integer'Last/10 threshold. When its result exceeds
that threshold, Value_R replaces the scale and zeros the other part; otherwise
it adds that exponent. Require `token+I/10+2<=I`. Part-scale differences cancel
the common exponent and are bounded by token length. Power tables are fixed
and range-checked; arithmetic overflow becomes the existing Bad_Value outcome,
not a token-sized numeric array. Integer scanning similarly checks the unsigned
accumulator before returning a signed value.

`Bad_Value` truncates its error string to128 source bytes plus fixed text.
Integer conversion Constraint_Error is translated to fixed Invalid_JSON_Stream;
Long_Float conversion Constraint_Error is **not caught** by JSON.Read. Other
lexer/parser Invalid_JSON_Stream messages are fixed text, one offending byte,
or a finite enumeration image. Their <=256-byte envelope fits the retained
Unbounded_String error owner. None recursively prints the partially built JSON.

For caught Invalid_JSON_Stream, Read frees Read_States then calls
Current_Text_Position. In read/mmap mode Track_Lines remains true; its scan is
bounded by Current<=n, column<=n and line<=n+1, covered by the spare. The stream
branch has Track_Lines=False and returns (0,0). This position routine is an
error-only scan, not a per-byte line counter during successful parsing.

The existing cleanup is not stronger than its source: Current_Key is not
deallocated in the Invalid_JSON_Stream handler, so one key backing may leak.
An uncaught conversion or service exception can also leave the allocated
Read_States and its reachable partial graph unfreed. The above per-object and
per-counter envelopes include those objects; repeated calls and their retained
physical allocation demand remain the caller/resource owner's concern. We do
not claim a successful parsed return, rollback, or leak repair on these paths.
Ada exception/OS runtime storage itself retains the existing service boundary.

## Guard application and remaining attachment

The executable interface applies every guard above to the intact and malformed
profiles separately, together with source/provider premises. The malformed
profile has the useful sufficient interval `b<=2^30-1` (plus path/page/native
inputs); its power-of-two state/key backings are then <=2^30 and its decoded
string growth intermediates fit. This is derived from reached machine
representations, not a new admission policy or physical memory threshold.

All five current normal-response bounds pass at the declared path/page
orientation. At post-cut `P=416,M=444`, including interrupted normal/abort
output, the maximum malformed stdout bound is683,528,842 bytes (Put_Line).
The fixed pre-cut `PrecutP=180` bound is250,796,153 bytes; at416 it is318,226,073.
All 15 retained pre-cut examples pass. For the fixed label envelope<=189 the
parser's sufficient PrecutP range extends to3060; intersecting with the already
accepted scalar/reporting provider's1927 leaves1927. These are source-function
calculations, not measured cwd/path/file maxima or completed deployments.
The packet retains actual configuration guard status as **unknown**.

The critical review targets are the offset-Next counterexample, failed-output
layout refinement, complete decoded-growth endpoints, stale-slot and transient
ownership census, and the numeric/error alternatives. A successful offline
check is not independent review. Parent #119 must attach actual configuration
and source/native correspondence and finish downstream collector/report owners;
this component does not close the parent or authorize production.
