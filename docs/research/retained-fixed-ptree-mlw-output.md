# Fixed Ptree Mlw diagnostic output

2026-10-23 UTC, Linux x86_64, #119 / #153. **Author interface for independent
review.** This bounds one attempted `Mlw_printer.pp_mlw_file ~attr:true` on
each of the five retained dependency Ptrees. It includes marked and unmarked
ordinary typing-failure routes, interrupted prefixes, private construction,
formatter operands and the `.mlw` channel's offered-byte extent. It does not
bound arbitrary Main Ptrees or complete #119/#153. The
[packet](../evidence/retained-fixed-ptree-mlw-output-20261023/README.md) freezes
the input/source/native attachment and one offline check.

Inputs are the cumulative capture freeze `91ad324d83` (initial `09d9a2382f`):
five graphs stopped before `Typing.type_mlw_file`, with every reachable data
block and string. Their preservation through a failed typing call and transport
to the selected invocation remain the root's separate capture-transfer result.
`M` denotes the marker's returned **string length**, and `P` bounds every
filename returned by `Loc.get` on the retained trees. Neither a marker's
cumulative allocation nor the direct graph's string-byte sum substitutes for
these quantities. The external FileTags map is borrowed; its filename payloads
are not present in the graph.

The inspected Why3 revision remains `9390baf120ef260547dfa14f08e11c890b203d9c`.
The existing [scoped external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
applies to its Mlw traversal/helpers and OCaml 4.14.2 formatting/runtime
behavior. The explicit native module adjustment below replaces the contradicted
pair-layout part of that relation. This is no blanket historical source-version
identity claim. Oracle, tools, current admission, Why-only SIGINT masking,
published-mutation guards and physical allocator/GC/stack premises are unchanged.

## Native module reader and fixed shape attachment

Inspected `ptree.ml` and `mlw_printer.ml:1250–1258` use `(ident,decls)` pairs.
The actual native graph uses three-field module entries, whose middle field is
raw immediate1. Static disassembly of the identified installed `gnatwhy3` gives:

| Native site | Reached behavior |
| --- | --- |
| `pp_mlw_file_3279`, `pp_mlw_file_inner_15431` | Optional attr defaults to represented true; the Modules arm opens the outer vertical box and prints the module list. The caller explicitly supplies true. |
| `pp_module_3287` offsets8,118,272 | Reads tuple fields at byte16, byte8, byte0 respectively: declarations, optional middle value, identifier. |
| Same function / immutable format at `0xd13eb8` | `@[<v0>@[<v2>module %a%a@ %a@]@ end@]`; the extra callback occurs after the identifier. |
| `fun_15525` / `pp_opt_inner_7831` | The middle value is passed to `pp_opt`, with prefix ` : ` and empty default/suffix. `pp_opt` tests the value's immediate bit at offset13; immediate1 selects the empty default. |

Thus the native field is **None on every captured entry**, not an inferred
Boolean false. Its absent branch prints nothing and calls no child printer.
Projecting `(id,None,decls)` to `(id,decls)` preserves the inspected printer's
event stream, apart from that finite empty-format callback. The packet retains
1,011 instruction bytes across five complete functions, three immutable string
spans and executable identity. The static inspection neither starts nor attaches
to an inferior. Source/native behavior beyond these witnesses remains the stated
external relation, with this explicit adjustment.

The graph check counts **expanded occurrences**, including every repeated edge
to a shared object. Put `N=blocks+immediates+1`, `S=expanded direct string bytes`,
`Lloc=expanded three-immediate tag-zero records`, and `K=maximum multiplicity of
one identical such triple`. All real Loc records are included; unrelated triples
can only overcount. `Loc.equal=Stdlib.(=)` compares these three integer fields.

| Case | Blocks | Immediates | S | Lloc | K |
| --- | ---: | ---: | ---: | ---: | ---: |
| put_line | 22,005 | 22,554 | 47,776 | 5,481 | 33 |
| put | 20,861 | 21,439 | 45,078 | 5,175 | 33 |
| first_or_default | 19,820 | 20,263 | 47,292 | 4,904 | 24 |
| input_is_valid | 9,506 | 9,876 | 19,133 | 2,339 | 18 |
| is_message | 6,420 | 6,649 | 11,467 | 1,572 | 13 |

Two conservative structural scans supply useful exclusions without treating
an untyped broad candidate census as an exact semantic node count. A candidate
term/expr/pattern record is any two-field tag-zero block with its second field
a Loc-shaped record. Every actual such record is included under the source
layout relation. For each candidate whose descriptor has tag24, the descriptor
has two fields and its second field is immediate1. Since Eraise is the 25th
nonconstant expression constructor, every actual Eraise has **no argument**;
unique candidate totals are6/5/7/4/0. Consequently even counting two local
Eraise syntax attempts cannot replay an expression subtree.

For descriptor tag0/size1, the payload is either a three-field identifier with
a string head (the Pvar alternative), or a ConstInt wrapper containing a
two-immediate integer record. Unique ConstInt candidates are48/39/56/18/12;
all magnitudes are at most2^31. No string or real constant can enter
`Constant.print_def`. All graph immediates, including range endpoints, have
magnitude at most2^31; no custom numeric block is reachable. This excludes
Constant's string-escape Buffer and real-number expansion, while `%S` used for
attributes/metas remains charged. Declaration and module totals reconcile with
the retained projection; the native middle None does not shift declaration reads.

## Source traversal, repeats and direct output

The complete retained `mlw_printer.ml` is the source partition. An ordinary
constructor/record shell, a list cell and an immediate leaf each have their own
occurrence in N. A shell's recursive children are charged to their occurrences,
not to an unbounded callback hidden inside its fixed allowance.

| Source family | Traversal and exceptional repetition |
| --- | --- |
| Identifiers, qualids, types, patterns, attributes | Descend through proper children and existing lists. A Qdot accessor emits its terminal location once explicitly and again in the full qualid, while printing its argument once. `pp_closed`/marked wrappers invoke the raw printer once. |
| Expressions/terms and fun/let/any wrappers | Disjoint recursive operands are printed once. Application/infix/binop/sequence flattening moves existing operands to a fresh list; it does not recursively print the flattened spine again. Multi-assignment traverses its list twice but prints each lhs/rhs expression only on its respective pass. |
| Eany and result specifications | Eany may borrow the first postcondition pattern for its result type and later print that pattern in the postcondition. This is one extra traversal of a pattern/type-only region; a pattern contains no expression or specification capable of recursively repeating the rule. `pp_spec` uses its result-pattern argument only for comparison. |
| Function literals | Term funlit peels Tif tails and prints disjoint test/value subterms; expression funlit collects Elet right-hand sides and consumes the list in pairs or a final singleton. Its structural guard failures assert. No right-hand side is duplicated or inserted into an earlier subtree. |
| Eraise | Source's ordinary Exit branches precede any formatter call. All captured optional arguments are None. A possible second local spelling therefore has only keyword/qualid/marker work. The handler is outside its own trap and cannot retry itself. |
| Declarations/specifications | Lists of fields, binders, postconditions, variants, substitutions and declarations have their own cells. `pp_decls` inserts at most one blank None and one Some per declaration; incoming separators and group openings are charged to these cells/shells. The native module adjustment adds one empty callback per module. |

These cases exhaust the source's output-recursive edges. At most two traversals
of an original printable pattern occurrence, two marker uses of an accessor
identifier and two local Eraise spelling attempts suffice; the latter cannot
contain a borrowed pattern. Use the generous uniform allowance **eight charged
visits per expanded occurrence**, `U=8N`. It covers the preceding repeats and
the fixed shell/list-wrapper routing without multiplying ancestor depth into
every child. Comparison-only scans are treated separately below.

Per charged visit, **256 fixed text bytes and 256 core events** cover its
constructor form, incoming separator, marked/closed parentheses, fixed helper
wrappers, empty alternatives and any integer digits. The largest Mlw quoted
source token is65 bytes. Even the let-function shell's outer/inner formats,
its ghost/kind/partial helpers and result/spec list prefixes are below256;
per-list elements have their own visits. The specification shell has nine list
families and two flag spellings, each with fixed delimiters, below this cap.
Other shells use fewer fixed fragments. Integer printing needs at most64 digit
events plus sign/base syntax (actual retained magnitudes need at most32 binary
digits); this also fits256. A failed pre-event construction consumes its
prospective visit even though it emits no core event.

`Ident.sn_decode` returns a substring, original name, or a fresh asprintf name
with at most eight punctuation bytes added. Its successful suffix route prints
disjoint slices of the original identifier; it does not expand recursively.
Literal/attribute/name data can be visited at most four times under the above
repeats. `%S` escapes each byte to at most four bytes plus two quotes. Thus16S
covers direct variable string data, with added punctuation/quotes in the fixed
allowance. `term_hyp_name` strips a prefix and prepends one space. Failure
strings `pp_infix: ` / `pp_innfix: ` add only fixed prefixes to one existing
identifier. No user string is parsed as a format program.

An ATpos may retrieve a filename not stored in the graph. Each such visit has
quoted filename bytes at most4P+2 and four represented scalar coordinates at
most20 bytes each. Charge `8Lloc(4P+82)` independently of S. Loc.get only borrows
the FileTags filename and constructs a fixed five-field tuple; missing-file
lookup failures escape. The map's pre-existing capacity remains with its owner.
Optional debug location IDs add one represented20-byte decimal and fixed
punctuation per visit, inside256. This bounds both debug-ID settings and does
not require a zero-output environment claim.

Only `pp_maybe_marker` and `pp_maybe_marked` emit the marker string, after the
three-integer equality test. The equality's true branch can match at most K
original location occurrences. The same eight-visit allowance therefore gives
**at most8K copies of M bytes**. Merely comparing a marker never copies its
message. `id_loc` and `next_pos` appear only in their definitions inside this
printer; no output route calls them. Both synthetic counters have zero
increments during this operation.

For one attempted writer, including its caller's final newline/flush, export:

```text
U = 8N
F = 256U + 1024
B = 256U + 16S + 8Lloc(4P+82) + 8KM + 1024
Q = B+F
O = B + 70(F+1)
```

B is summed text-token bytes, F bounds core events, and O is offered channel
bytes including all possible indentation/newlines. These are deliberate
overbounds, not observed file sizes. They apply to partial as well as complete
attempts. Different `.sexp` and `.mlw` outputs are separate owners.

## Formatter, helpers and private construction

The accepted R66 core result at `7d507503b9af867a08215c3ef11f226400ee3b51`
and R67 accumulator result/review at
`4364b0bcccfabaad6a843b529879ba6c48eedb2e` /
`3ae80bf153b7fbb550f39122173e94714545c2b2` are reused, not replayed.
Mlw adds box indentation3 to their selected0/1/2 set. Every break still has
width0/1 and offset0; no tabs, tags, magic size or custom break strings occur.
The same core induction now gives stored width in `[-Q-3,78]`, unclamped
indentation at mostQ+81, actual indentation at most68, totals in[1,1+Q], and
space in[-Q,78]. The conservative guard

```text
4(Q+1000000010+128) <= 2^62-1
```

covers the added one in all native additions/subtractions. Queue/each stack
length is at most4(F+1), depth at mostF+1, and output callbacks at most4(F+1).
O follows with the same70-byte allowance for a newline and at most68 blanks.

Every captured file is Modules. Its top user box encloses all producer breaks;
the native extra callback emits nothing. Split declaration-group separators
close and reopen their own group box, preserving the outer module/file boxes.
There is no producer flush. The caller `%a@.` performs the sole terminal
newline/flush after the producer closes its user boxes. Thus R66's large-stream
drain condition holds: closing user boxes resolves pending breaks before
flush resets the queue. The false generic system-scope-break lemma is not used.

All selected format trees retain the R67 bound364 nodes: the Mlw census maximum65
is below its90-byte cap; Ident's selected name formats and Number's selected
integer formats are also below90. Dynamic data enter `%s`, `%S`, `%a` or `%t`;
no runtime format parser is selected. A call descends proper format-rest and
immutable accumulator-predecessor links. A marker is referenced by an accumulator
payload and never flattened into the format tree. Recursive `%a` callbacks are
synchronous and follow the finite source traversal above.

Private variable-length constructions are linked lists: application/infix/binop/
sequence collection, funlit bindings, filtered attributes/preconditions,
`List.rev` in let-any, and `List.combine` in mask/result printing. Each list has
at most2N cells; `pp_decls` has at most2N entries. Nested combines construct
two lists whose individual lengths are bounded by existing input lists.
Filtering and reversal do not create a longer list. Record copies contain
only the fixed source fields (the largest copied spec has10). No AST or array
grows by substituting a subtree into itself.

The comparison-only helpers `pat_equals`, `is_marked`, `List.for_all`, suffix
tests and reference/attribute scans descend through finite input structure.
Comparing one result pattern against several posts can take quadratic work;
it does not print that result pattern per comparison or enlarge one owner.
A conservative64N² structural/compare steps, each with finite string comparisons,
plus borrowed FileTags/only_ids lookup work, suffices. This is a mathematical
termination allowance, not a stored loop counter or RAM quota. Native recursive
frames still require the existing physical stack service premise.

All newly formed local closure groups in Mlw are single functions; their
captured values are existing `attr`, printer/formatter, subject, optional
arguments, result pattern or a list head. A conservative16 environment slots
covers each, including `pp_spec`'s local callbacks and function-literal helpers.
The large top-level `let rec ... and ...` printer group is static, not allocated
per call. Ident's local scanners and Number's radix helper also have one-member
groups. Combining this with R67's at-most-three-member annotation group gives
the same28-word closure payload bound and the same conservative **128-word
fixed object bound**,1032 bytes with header. The native module adaptation's
largest local closure has eight payload words. Curry cells reference the previous
closure rather than making a variable-sized capture array.

Each direct string/temporary has length at most

```text
T = max(M, 4P+2, L+16, 90),  where L <= 202.
```

This includes decoded names, hyp names, escaped filename/meta strings, local
failure messages, decimal conversions and fixed annotation helpers. Marker
copies contribute to B but are not concatenated into a8KM-byte string. The
decoded-name asprintf owns a fresh Buffer512 and text-only formatter, output
at mostL+8; it fits without resizing. Annotation helpers have Buffer16,
descriptions at most5 bytes and one digit0/1/2/**3**; the same failure-message
Buffer256 and46-byte bound applies. There is no main output Buffer for `.mlw`.
For each string allocation require T<=2^57-9, then R67's native word/padding
arithmetic applies. Existing allocator/GC failures remain failures, not an
aggregate preflight memory gate.

`Eraise`'s explicit Exit fallback is selected before output. Ident.sn_decode's
local Exit/Not_found catches contain scans, not formatter mutation. The reached
runtime/OS errors and the masked Why signal route do not synthesize Exit inside
the Mlw formatter. No selected catcher resumes a partially mutated formatter
after a formatting/runtime failure. Eraise's None-argument census additionally
excludes recursive replay; it is not used to assert that dirty formatter reuse
would be safe under arbitrary injected exceptions. `with_marker` resets the
global marker only on success; failure may leave it set, but the failed writer
does not retry or mutate the graph. The receiving pre-cut flow and any later
global state use remain the root's caller ownership proof.

## Private channel prefix and composition

`gnat_ast_to_ptree.ml:1401–1423` creates the printer (optionally with_marker),
attempts the separate Sexp writer, then uses `open_out mlw_filename`, a fresh
`formatter_of_out_channel`, `%a@.` and `close_out`. A Sexp failure precedes
creation of this channel. The selected open_out route is write/create/truncate,
without append/nonblocking flags; Linux text mode adds no translation. The
existing private regular-file/workspace and stable-description premises attach
to this `.mlw` owner; merely calling open_out does not prove file kind or private
path ownership.

Apply the same precise [positive-write service interface](retained-why-save-service-contract.md)
to this caller: a valid blocking regular-file write with1<=n<=65536 returns
1<=w<=n, errors/raises, or does not return. This is an explicit `.mlw` attachment
of the existing service behavior, beyond R36's original XML/shape caller scope.
It is not derived from successful writes or a general POSIX eventual-progress
claim. Ordinary errors and arbitrarily many EINTR retries remain admitted.

Let A be offered bytes, C committed bytes, D pending channel-buffer bytes and
delta∈{-1,0} the initial cached-offset bias. The source copy/flush induction is

```text
0 <= D <= 65536
0 <= C, C+D <= A <= O <= 2^63-1
cached_offset = C+delta in [-1,O].
```

A returned positive write reduces D by w and increases C/offset by w, preserving
debt. Copies add only an offered prefix within the remaining buffer extent;
flush/close add no new offered bytes. An initial lseek failure needs no success
assumption. Under the existing pending-action/state-commit service relation,
no unclassified callback intervenes between the successful write and its commit.
Each actual syscall request is within the65536-byte buffer and C int/ssize_t
range. Positive short writes cannot multiply file content beyond O. Errors and
nonreturn do not imply complete delivery; later ordinary draining of this same
description consumes only its retained debt. No syscall-count or durability
bound is claimed. Global channel-list lifetime and unrelated receivers remain
their existing owners.

The pre-cut author interface frozen at
`07e63b97f3623b2405172433ae093ce894defd23` exports
`M <= 15*(8*(723+12*max(467,P+51,Nid))+65536)+1024`.
For P<=416 and Nid<=467 this is1,743,304 bytes. This packet's numerical join
uses that author-candidate value and P=416, explicitly pending root's independent
provider review. All five Format/individual-string/channel guards pass. The
symbolic B/F/O interface above remains valid for any established P/M satisfying
those arithmetic guards; these guards are derivation obligations, not new
language admission limits.

Selected author model/effort: GPT-6 Astra / Extra High. Runtime confirmation,
whole-round elapsed time and token/cost telemetry are unavailable. The retained
check reports its own elapsed interval. No target/capture/solver rerun,
predecessor checker replay, production/source pin change, Oracle amendment,
GitHub write, harness update, CLI-memory update or aggregate RAM gate occurs.
