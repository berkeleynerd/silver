# Review: fixed diagnostic Ptree/Sexp transfer and capacity

2026-10-23 UTC; #119 / #153. **Accepted at the stated fixed-family,
source/native/service scope after the FileTags repair.** Final reviewed author
freeze: `e47e5236cfe9e73087870e0e3283d184e05bacf2`; initial review input:
`22e910d7f771ab682b3097411f67b0a5784c9856`. Target:
[`retained-fixed-ptree-sexp-output.md`](../research/retained-fixed-ptree-sexp-output.md)
and its complete evidence packet, including the reused raw Ptree packet at
`91ad324d83`. No unresolved critical finding remains in this bounded review.

This accepts the complete preserved source-tree transfer with variable
FileTags filename payloads, the captured native Sexp structure, the option-mode
and filename replacement allowances, individual converter/Buffer/string
representations, and the conditional private file-channel interface. It does
not accept arbitrary Main, the separate Mlw printer, complete failed-prefix or
whole-process composition, or #119/#153 completion.

Selected reviewer: **GPT-6 Astra / Extra High** (`gpt-6-astra`, `xhigh`), as
explicitly confirmed by the lead. Runtime confirmation and isolated token/cost
telemetry are unavailable. Actual host: Linux x86_64, kernel 7.0.14, glibc 2.43.
The [focused review check](../evidence/review-fixed-ptree-sexp-output-20261023/README.md)
passed **109 checks in 4.99185394399683 seconds**, first attempt. No capture,
native target, solver, compiler, proof, disassembler, source fetch, complete
graph-audit replay or provider checker ran in this reviewer lane. The original
author's five new boundary captures took 27.334876 seconds; those are reused
author measurements, not this review's execution. Review interval and exact
inputs are recorded in the new packet. No Oracle, tools, pins, admission,
production code, GitHub state or merge was changed.

## Material finding and repair

The first freeze's immutable-input transfer was too strong for its filename
payloads. The reviewer identified an omitted constructor:
`gnat_ast_to_ptree.ml:247–256` can form
`"'@" ^ marker ^ "@'" ^ filename`. The author then identified that the claimed
persistent FileTags association also contradicted the already accepted R69
partial-publication argument. The reviewer independently checked
`loc.ml:51–59` and the exact R69 origin/refinement provider: table publication
must not be treated as an atomic successful add/add/increment transaction.
An immutable position can subsequently resolve to another stored filename.
Thus the initial captured payload total alone was insufficient for every
failed-typing path. This was a required source-transfer repair, not optional
hardening or an upstream identity problem.

The final freeze imports the exact alias-robust R69 note, projection, warning
refinement, independent review and integration receipts. Their all-origin
bound is **180 bytes**, covering initial parser/driver/input names, selected
library paths, empty/dummy names and the one-shot native marker encoding.
It is a bound derived for this selected configuration family, not a new cap
on permitted paths. R69's raw filename/marker inventory also covers a stale
raw Curr pair after interruption. The review's focused observation finds the
actual marker-prefixed strings only in Put_Line/Put, each 27 bytes; it does
not replace R69's all-origin argument.

For every potential position occurrence the repair adds a whole replacement
filename, without deducting any captured bytes:

```
B = 4T + 3A + 2L + 19R + 4*180*Lloc.
```

Lloc overcounts every expanded three-immediate tag-zero record in the raw
Ptree, hence includes every Loc position, with sharing charged per occurrence.
Loc's converter emits one filename and four coordinate atoms. Replacement
does not change those atom/list counts or immutable numeric fields. The existing
3A term already pays possible quotes and separator changes; the new term pays
the new filename payload. A lookup failure escapes before a completed Sexp
result and cannot demand a larger byte serialization. The original successful
graph/native result is retained byte-for-byte; its structural facts remain
applicable. The review checked that preservation explicitly. No new capture was
needed, and the author ran only the changed-provider/arithmetic check.

## Source and native attachment

`gnat_ast_to_ptree.ml:1382–1423` closes over the completed original `mlw_file`.
Both exception arms call the same local print helper, and a helper exception
escapes its handler instead of retrying. The located arm's marker string is
used by the later Mlw printer, not by Ptree.sexp_of_mlw_file. The correct order
is converter, `.sexp` open, machine serialization, output/close, then `.mlw`.
An ordinary read/open error during typing remains allowed and can reach this
diagnostic route even for a valid immutable input.

The relevant Ptree fields are immutable. `Ident.attribute` itself has immutable
fields (`ident.ml:16–33`); hashconsing constructs the tagged value, and Sexp
conversion reads only `attr_string` (`41,53–54`). Loc stores immutable compressed
coordinates and a tag (`loc.ml:67–97`), with the external table handled by the
repair above. The raw graph contains no mutable ref/array or custom numeric
block. Typing constructs its own typed state, and does not overwrite the source
tree through these interfaces. This uses the existing faithful-memory and
relevant external-behavior relation; it is not a guarantee against arbitrary
memory corruption.

The converter/smart constructors do not read Gnat_config. Their private
synthetic-location/call counters and transient Curr values are driven by the
same fixed input in a fresh per-check process. The debug flag is read only by
the two diagnostic-output guards in read_channel. The earlier GNAT AST printer
does not call these Ptree constructors, insert FileTags values or set Sexp
option mode. Quiet/J12/logging/timeless changes therefore do not change the
source-tree structure. Hashcons tags and sharing are immaterial to expanded
serialization; FileTags payload changes and option modes are charged explicitly.

The capture is attached to the **actual** `save_mlw_as_sexp_7559` call to
`Sexplib0.Sexp.to_string_mach_1258`. Its stack identifies the successful debug
read_channel arm and its rax operand is the graph root. The entry assembly
reads the tag through rax, corroborating that calling convention. The retained
native serializer distinguishes Atom/List, creates Buffer1024 for a List,
calls the machine loop and returns the contents. This is not a Format route.
The retained `.sexp` files are empty because the open preceded the stopped
serializer entry; the review checks those empty artifacts independently.

The module layout difference is handled explicitly. At `0x6eaa3f` the actual
module converter selects closure `0xcb77c0`. Its retained closure words select
`caml_tuplify3` (`0x52b390`) and `fun_8036` (`0x6ead40`). The adapter loads
fields 0/1/2 into rax/rbx/rdi; the body converts the identifier, calls
sexp_of_option on the middle field, converts the declarations and constructs
a three-element Sexp List. The captured middle field is None. Thus the
extra field is included in the actual Sexp captures; it is not silently
identified with the inspected source's module pair.

All five full Sexp graphs are retained and interpreted as Atom(string) or
List(proper finite Sexp list). The author checker checks reachable-node
coverage, headers and acyclicity; memoized child summaries are summed once
per incoming occurrence. Its source was reviewed, and the successful graph
evidence was reused rather than replayed. The review separately binds archive
identities, verifies that the fixed five-case family is complete and checks
the exact amended source/provider inputs. The retained 11 native bodies and
closure data supplement the named scoped source/native behavior premise;
they do not claim historical upstream build identity or vendor compiler proof.

## Byte and representation argument

The machine serializer in `sexplib0-sexp.ml:51–134,246–269,310–334` escapes
each input byte to at most four, adds at most two quotes and one preceding
atom separator, and emits two parentheses per List. Therefore `4T+3A+2L`
bounds the captured mode. The maximum expanded counts are A=51,019,
L=35,101 and T=273,688; maximum captured atom size is 202.

`sexp_conv.ml:41–45` changes Some from `[child]` to `[some;child]`, or None
from `[]` to `none`. The possible increase is at most one four-byte atom:
19 bytes under the conservative atom bound (17 after crediting the removed
List for None). `R=expanded_words+expanded_blocks+expanded_immediates` bounds
all source option-field/value occurrences. Generated structural converters
consume each source field once; the custom attribute/Loc/scalar helpers add no
options, and the native extra None is already a counted field. Independent
mode choices at different occurrences still obey this sum.

The repaired per-case results independently reproduce as follows:

| Case | Lloc | Offered-byte bound B | Largest Buffer backing |
| --- | ---: | ---: | ---: |
| Put_Line | 5,481 | 7,104,139 | 8,388,608 |
| Put | 5,175 | 6,718,015 | 8,388,608 |
| First_Or_Default | 4,904 | 6,397,311 | 8,388,608 |
| Input_Is_Valid | 2,339 | 3,036,350 | 4,194,304 |
| Is_Message | 1,572 | 2,033,232 | 2,097,152 |

Buffer starts at 1024, appends only and doubles. Each prospective append fits
the resulting backing bound. Its contents and all escaped atoms (at most 810
bytes) fit the accepted native string/header/rounding domain; signed-native
addition/doubling guards pass. Each B also fits signed C int and signed64-bit
file offsets. Converter temporaries are fixed-field objects or linked lists;
reverse/map intermediates preserve the corresponding finite list length, and
the conservative alternate-mode list maximum 52 fits native representations.
The raw immediates and Loc's extracted numbers fit the existing 20-byte decimal
interface. These are individual object/index arguments. Aggregate RAM and
physical stack sufficiency remain trusted; no new aggregate admission gate is
inferred from the arithmetic.

## Private channel and remaining composition

The source opens a fresh private `.sexp` description with write/create/truncate
and text flags, with no append/nonblocking mode or Linux text translation.
Regular-file kind, exclusive/private ownership and stable description remain
explicit environmental premises. The existing positive-write service contract
is expressly applied to this new caller: valid requests of 1..65536 bytes return a
positive prefix, error/raise, or do not return. It is not inferred from POSIX
or from a successful sample write.

The retained channel induction therefore gives `0<=D<=65536`, `C+D<=B`,
and offset `C+delta` in `[-1,B]`, including initial lseek failure with
delta=-1. Short writes preserve the invariant; errors and nonreturn do not
perform a successful-return commit. EINTR can retry without an asserted finite
retry bound. Open-before-serialization failure can leave an empty channel;
later output/close failure can leave an incomplete file and buffered debt.
Later draining consumes existing debt and introduces no new offered bytes.
The shared channel-list/pending-action ownership remains with its existing
provider. Nothing resets the global e<=2/two-callback/three-save allowance.

The separate Mlw serializer and final failed-prefix composition remain open
joins. The accepted Sexp result exports B and the alias-robust FileTags operand
for its exact fixed source/configuration family. Wider inputs or configuration
families require their own attached operands; they are not admitted by this
review.
