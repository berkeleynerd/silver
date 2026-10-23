# Selected SMTv2 output bytes and private Format/Buffer operands

2026-10-23 UTC, #119 / #153. **Candidate source interface, pending independent
review.** The [packet](../evidence/retained-why-printer-output-20261023/README.md)
counts each request formatter, request Buffer and solver input file separately.
Its raw-name inputs are explicit; a whole-process sum is not imposed as an
individual string, file or formatter limit. Whole printer capacity remains
open, including private maps, native layout/stack and full correspondence.

This work starts at `8b651049e46c8800df92e9efed4832ddfcbad8ab`. It imports the
accepted R61 returned-field dimensions, R62 printer/syntax closure and R64 name
table history. The selected Why3 source is
`9390baf120ef260547dfa14f08e11c890b203d9c`, with retained OCaml 4.14.2
`8eb41f72ded84df884c3671734c947f612091f84`. Typed immutable inputs,
first-global-counter-violation guards, native service behavior, and the existing
source/native relation remain premises. No new binary-refinement claim is made.
The single process budgets remain `e≤2`, two save-entering callbacks, three
saves and `E=3N+e` request opportunities.

## Actual output owners and branches

`Driver.prove_task_prepared` creates a fresh Buffer1024 and its formatter,
prints once, flushes, and passes the Buffer to `call_on_buffer`
(`driver.ml:456–474`). `Call_provers.call_on_buffer:604–620` writes that
Buffer once to the individual temporary input file before invoking the prover.
Reset follows the call on the normal route. A failed prefix retains its actual
owner and can shorten output; it does not concatenate the next request to it.
Filename/argv construction and server-command bytes retain their separate
[request-line interface](retained-solver-request-bytes.md).

| Source output family | Charge and route |
| --- | --- |
| Global and theory preludes | `Printer.print_prelude` writes each existing string then a forced newline. `print_th_prelude` examines at most H Use/Clone nodes. Charge each visit as if its whole possible prelude prints, without a successful-deduplication premise. |
| Logic/type/literal syntax templates | Existing driver strings are length-counted data. `global_substitute_fmt` emits substrings and calls only the selected placeholders. R62 supplies affine type templates, no active `%t`/`%v` logic placeholder, and the two rotation templates' already-charged extra variable visits. Strings containing `@` are not reparsed as Format programs. |
| Names | `print_ident`, `print_var`, `print_tv`, plus returned field-name strings. R64 bounds every name call, including the temporary nullary-value label key and constructor/sort/projection helpers. A helper's returned name is printed at most once on the selected route; general non-Boolean pattern projection lookup is excluded. |
| Raw identifier comments | Dparam, Dlogic, Paxiom and Pgoal use `%S` on `id_string`, independently of `id_unique`. An incremental definition can have two comments, one for its parameter and one for its deferred equation. Charge at most two escaped raw names per logical declaration. |
| Literals | All retained complete stored original constants are integers. Their magnitudes and the separately retained range endpoints are at most `2^64`. R61 producers preserve them or add these endpoints and small constants; no float type or real/string literal producer is selected. Integer syntax padding is at most64 and bases are2/8/10/16. At most65 digit/character outputs plus sign/wrapper syntax suffice per literal. |
| Formula/header syntax | Parentheses, keywords, Boolean operators, let/quantifier binders, trigger group delimiters, type/data/function headers and separators. Boolean cases print one ite; general pattern printers and mutually recursive definition lists are excluded by R61/R62. Ground headers add no polymorphic `par` list. |
| Goal location | One surviving goal prints `Loc.pp_position`. The accepted goal-header theorem gives `silver_io.ads`, `silver_arguments.ads` or `silver_arguments.adb`, at most20 bytes. Location coordinates are represented OCaml integers; five20-byte scalar allowances and fixed punctuation cover the selected location printer. |
| Terminal commands | At most two check-sat sequences, the incremental option and optional reason-unknown commands. CE-off excludes produce-models, push-for-model and get-model output. The minimize branch, if selected, has the same bounded term traversal plus fixed syntax. |
| In-body diagnostic | `Printer.int_of_string:224–228` catches **all** exceptions from conversion, writes `bad argument for int_of_string: %s` to shared stderr, then asserts. Well-formed digits do not justify removing an interruption-origin branch. The handler is outside its own trap and no selected enclosing handler resumes this request after it fails. At most one such diagnostic is attempted per request. |

Unsupported-term/type/declaration and assertion failures otherwise propagate
to the accepted parallel callback, which drops their payloads. That later
callback argument does not erase bytes already emitted by a producer. The
accepted standard-formatter initial-state result concerns the registration
cut; it does not exclude the post-cut integer-conversion diagnostic above.
Its contribution is exported as a fragment of the **shared stderr** whole-
interval budget, never as a fresh stderr formatter.

Counterexample bookkeeping still runs with CE off. In particular, nullary
values call `update_info_labels` and model collection can populate private
maps. `at:` attributes would form `old_attr ^ ":loc:" ^ file ^ ":" ^ line`.
The separately pinned Hsattr provider supplies a continuing at-free input
premise, giving zero such concatenations, while the fold/map work remains.
Without that premise the byte interface is
`attribute_bytes + filename_bytes + 26 ≤ Sys.max_string_length`.
The located string is stored only in `cur_l/info_labels`, not back into
term/symbol attributes, so repeated labels do not recursively append locations.
Projection `model_trace:` removal produces a substring, not main output;
its length cannot exceed its existing input string. Neither map is treated as
closed here. `print_info_model`'s emitting branch requires CE and is absent.

## Finite source attachment and byte equations

The independent lexical census reads the 14 frozen driver files and their
existing import graph. Repeating a child for every import edge gives expanded
source byte ceilings 29,890 / 31,293 / 6,478 for Z3 / CVC5 / Alt-Ergo.
These deliberately include non-prelude source bytes. Every decoded quoted
string is at most its quoted source byte length; the largest token is347.
Each token has at most16 numeric placeholders and each parsed parameter has
at most four source bytes. The six integer literal templates are exactly
`#x%64x`, `#x%32x`, `#x%16x`, `#x%8x`, `#x%4x`, `#x%2x`: each prints the
integer once, with padding width at most64. Float placeholders are excluded
by the selected integer-only family. The scanner
handles nested comments and the special `(*)` token; its source projection
is not a WhyML or driver semantic proof.

The R51 graph decoder explicitly accepts only the ConstInt tag. The new
census checks every stored constant record, including hidden saved values,
and R61's separate range bounds. Selected preparation changes neither this
numeric envelope nor the absence of string/real constants: inline/opening,
splitting, simplification and whole-old returns preserve constants; literal
elimination reuses the same value and range endpoints; selected algebraic
producers have no selector/indexer integer stream or float branch. Consequently
`Constant.escape`'s variable-size Buffer and per-character sprintfs are absent.
The source bodies remain in the census with that exclusion stated explicitly.

Original trigger groups are nonempty. Selected maps preserve inner list
lengths, Introduction may discard triggers, and algebraic inversion creates
singleton groups (`eliminate_algebraic.ml:347–352`). Splitting preserves each
list; simplification maps its elements. Therefore each printed trigger-group
delimiter can be charged to a term in S; empty trigger lists contribute no
group. Merely bounding trigger terms without this bridge would omit list work.

Let S/P/H/A/T be the accepted R64 dimensions and define its already accepted
per-owner count

```
C = H [(2S+P)(T+1) + 2(A+1)(T+2) + 8],  Nname = 343+C.
W = max(22,5,2(L+5)) + digits(Nname).
```

L bounds every raw identifier entering name printing; Lc is the maximum of
the separate raw logical-head and proposition-name bounds. The frozen raw-name
provider `39afb9db41c4052a7b68c2663f2bcc72d72a27ac` supplies
L=`70/70/67/52/54` and Lc=`74/74/71/56/58`, consuming only the repaired Hsattr
provider `62f686fe7331c2faf74c3c9f66df93f2626f1fa0`'s hyp_name≤13 interface.
Their joint independent acceptance is a separate integration input. W covers sanitization,
the printer-local `_proj` addition and historical suffixes. Let Fd be the
driver expanded-source ceiling above and G=347. Per request use

```
Prelude = (H+1) Fd
B = (G+256+W) C + 8H(Lc+1) + Prelude + 512
F = 128C + 2 Prelude + 128
```

The source-unit partition is the same outer partition used for R64's name
bound, extended to account for syntax at units that print no name:

| Units per task node | Direct work charged to a unit |
| --- | --- |
| `2S(T+1)` | A term/formula entry plus up to T explicit type-node entries. At a body entry charge its own fixed form, its incoming list separator and, for the first member, one trigger-group delimiter. A literal uses at most65 digit events plus its template fragments; these are not recursive term units. |
| `P(T+1)` | One binder slot, its parentheses/separator/name, and up to T type nodes. Let names may already be charged by their body entry; duplicate charge is safe. |
| `2(A+1)(T+2)+8` | Declaration shells, head/sort/constructor names, up to two arity lists and their type nodes, and the corresponding fixed delimiters. For an incremental definition, both its initial parameter shell and later equation shell are included. |

For the last row the parameter-plus-equation route needs at most
`2+(A+1)T+A(T+1)+A+2` units: two head uses, initial signature types,
typed formals, repeated formal names and two shells. A data group needs
at most `2+4+2A(T+1)+2` units: sort uses, constructor uses, fields/types
and shells. Both fit its allowance. A parameter/ordinary definition/type
declaration uses fewer units. Each shell's direct fixed text is below256
bytes and its direct events below128 even when both deferred shells are
combined. Ordinary term/type/binder units have fewer than32 direct events
apart from integer digits; a literal has at most65 digits plus two template
fragments (and optional sign), below128. At most16 template replacements
mean at most17 direct substring events; recursive arguments belong to their
own units. These generous local caps include all incoming separators; the
table does not multiply a unit by its recursive subtree size again.

B is the sum of direct text-token lengths; F counts prospective core events
(text, open, close, break, forced newline and flush). C also dominates all
selected term/type/binder/header source units: a unit's recursive children
and list elements have their own units. Each direct unit has at most256 fixed
text bytes plus one template and the separately charged name. At most128
events cover fixed syntax/separators, at most65 per-digit literal operations,
and at most16 template substitutions with intervening substrings. The largest
fixed fprintf forms are the datatype/definition headers; their variable lists
are charged by A/T/P, not hidden in the constant. The same accounting covers
deferred lists printed once at the final goal. The `512`/`128` terms cover the
one location, initial/final wrapper and terminal commands. Failures are charged
at prospective entries, before any eventual successful output.

Two `%S` comments cost at most `2(4Lc+2)` per declaration, below `8(Lc+1)`.
`Caml_string` uses `string_to_caml_string`; `String.escaped` delegates to
`Bytes.escaped`, whose pass adds at most four bytes per input byte, before
the two quote bytes are added. These sources are frozen explicitly.
This is separate from sanitized names. Prelude strings and newlines have at
most two events per nonempty source byte; counting all expanded source bytes
also covers empty prelude-string syntax and repeated import occurrences.

## Fresh large-stream drain argument

The retained fresh-save theorem uses `B+F+79 ≤ pp_infinity` as a sufficient
guard. It remains unchanged. The coarse printer envelopes exceed that guard,
so substituting them into that theorem would not establish closure. The new
argument here is specific to fresh private selected formatters and needs
independent review.

Put `Q=B+F`, `Pinf=1000000010`. Until a flush, left/right totals stay between1
and `1+Q`; space lies in `[-Q,78]`; indentation is at most68. Selected box
indentations are0/1/2, so a stored width is in `[-Q-2,78]` and an unclamped
indentation is at most `Q+80`. Breaks have width0/1 and offset0; there are no
tabs, tags, Magic_size, if-newline, settings changes or custom nonempty break
strings. Native additions/subtractions fit the conservative condition
`4(Q+Pinf+100) ≤ max_int`. Queue/each stack length is at most `4(F+1)` and
depth is at most `F+1`. These are individual field operands, not heap quotas.

The lemma requires **every break to be nested under a user box**, or no
breaks at all. It is false for an arbitrary fresh stream: after more than
Pinf bytes have drained and a forced newline restores the available space,
enqueueing a system-scope break and short text can
leave the unknown break at the head; flush's `Pinf-left` is then negative,
so `advance_left` stops and `pp_rinit` discards the queue. The source-level
counterexample is preserved in `drain-counterexample.json`.

For this selected stream `Driver.print_task_prepared:403` opens a user box
with `@[%a@]@?` before calling SMTv2. The selected term/type/header formats
have balanced opens/closes, with the goal's assert contributing an additional
open box; chunked constructor formats close their own opening. They cannot
close the enclosing Driver box. Prelude strings are data, not format control.
There is no flush in the selected producer until its final `smtv2.ml:1075`
flush. Therefore all main-stream breaks belong to a user box. After that
flush the Driver close is ignored at depth1; its `@?` and the later
prove_task_prepared flush emit no breaks. Name and annotation helpers have
only text and flush events. This lifecycle is essential to the lemma.

The scan/queue invariant then supplies the missing drain step:

1. Every queued unknown user-begin or break token has its scan entry. Scan
   entries are ordered by enqueue position. Additional entries may refer to
   already removed tokens; this does not remove an entry for a pending token.
2. A new break first resolves the preceding break in that open box. A close
   resolves its last break and matching begin. Nested already-closed entries
   were removed in their own close operations. Thus closing all user boxes
   resolves every still-queued user begin/break. The explicit nesting premise
   excludes a leftover system-scope break.
3. The obsolete-entry reset cannot discard a pending unknown token: its test
   is `entry.left_total < current_left`. FIFO processing cannot advance left
   beyond a still-queued token's enqueue position. All older entries have no
   larger position, so clearing that suffix discards only removed tokens.
4. After the flush's automatic closes, the only possible queued unknown is
   the system begin. If it is still queued, no later token has been removed
   and left is1. If it was already removed, every remaining token is known.

`pp_flush_queue` then assigns Pinf to right. Known tokens bypass the
`pending_count >= space_left` test. A remaining system begin sees
`Pinf-1 >= 78` and drains, after which only known tokens remain. Every step
removes a token; a large prior left total cannot prevent draining. The
subtraction `Pinf-left` may be negative but is represented under the guard
above. Reset replaces the state. The internal print_task flush closes the
Driver's outer box; its later redundant close at depth1 is ignored and its
flush sees the new system box. No matched-box assumption is lost at that edge.

These are completed-private-operation invariants. A stopped operation need
not preserve them for reuse: no selected receiving catch resumes this owner
after a partial core/Buffer operation. `%a` runs synchronously, not as a queued
closure. Save/exit activity owns other formatters and either terminates or
unwinds; it cannot return after mutating this private owner. The number literal
Exit handler fails with no custom callback; integer-parser diagnostics assert;
Unsupported wrappers escape. Optional record-field catches contain no
formatter call. A failure during annotation parsing precedes the main open
operation and rethrows. A stopped prefix therefore needs its bounded primitive
operands, but not a reusable completed core. The existing native service and
unwinding relation remains essential.

The syntax scanners' local Exit traps contain no formatter operation. An
early caught Exit before a percent marker leaves `b=start`, so the next
substring has length−1 and escapes before output. After a marker, the scan
endpoint advances beyond start. The selected argument indices are single
digits; an unfinished index is empty and takes the diagnostic/assert route,
while a completed index is the original one. For an incomplete integer
literal placeholder, its last scanned digit is not a base selector and
the literal printer fails before emitting digits. Thus these local scalar
traps neither resume an interrupted formatter update nor create an output
replay loop. The accepted selected-template origin restrictions matter here.

## Buffer, helper and file interfaces

Per request the core offers at most `O=B+70(F+1)` bytes and `4(F+1)` output
callback invocations. Default indentation is at most68, within the fixed
80-byte blank string; no recursive blank expansion is selected. `Buffer`
starts at1024 and receives append substrings. Its position and every requested
`position+length` are at most O. Require `O≤2^57-9`, the selected native maximum
string length, and represent the temporary doubling used by `resize`.

If d is the first power-of-two multiple of the initial capacity at least
`max(initial,O)`, every temporary new_len is at most d. The loop tests the
prospective total, doubles until sufficient, then clamps to max_string_length
before allocation. Thus **d itself may exceed max_string_length** without
requesting an oversized string; require only `d≤max_int`, with allocated
capacity at most `min(d,max_string_length)`. Copies and `output_buffer` use the
actual position, at most O. A shared/returning callback that could mutate this
Buffer would invalidate this attachment.

SMTv2 opens Format then Pp; its unqualified `sprintf` resolves to
`Pp.sprintf = Format.asprintf` (`pp.ml:208`), whose `kasprintf` uses
`output_acc` and a fresh Buffer512 (`format.ml:1387–1396`). Each temporary
`sprintf "%a"` name formatter has one text event and one
flush, offers exactly W bytes, and owns a Buffer512. There are at most C such
owners; they are not one C×W Buffer. Each box annotation helper has raw bytes≤7,
description≤5 and one decimal digit, its own Buffer16 and at most two core
events. There are at most F such helpers. Ordinary `%S` comment conversion
strings are individually bounded by `4Lc+2`. Template substring extents are
at most347; argument arrays have the accepted bounded signature arity.

The single file-content extent is O. At most E files are attempted; E×O is a
mathematical cumulative service-work bound, not an allocation, file offset,
Buffer capacity or formatter counter. Physical I/O, allocator/GC, native
stack and underlying channel service sufficiency remain trusted/delegated.
Shared stderr receives at most `64E` text bytes and `8E` events from the
integer-parser path; other reports and hooks must be joined into its existing
whole-interval owner. CamlinternalFormat accumulator recursion/layout and
complete private-map capacity are not closed by this packet.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost telemetry are unavailable. Exact providers, focused checking,
elapsed observations and rework are recorded in `round.json`. No native run,
proof, solver, capture, predecessor replay, Oracle/tool/pin/admission change,
GitHub write, CLI-memory update or aggregate RAM gate is introduced.

The focused author check passed in 2.411883 seconds over48 frozen inputs,
45 strict source spans and15 case/driver compositions. It verifies identity,
joins and arithmetic; it does not independently prove the source argument.
