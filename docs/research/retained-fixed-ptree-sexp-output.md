# Fixed Ptree diagnostic S-expression output

2026-10-23 UTC, Linux x86_64, #119 / #153. **Author result for independent
review.** This supplies the complete immutable-input transfer and `.sexp`
serializer bound for the five fixed dependency inputs. It does not cover
arbitrary Main inputs, complete #153/#119, or change admission. The
[packet](../evidence/retained-fixed-ptree-sexp-output-20261023/README.md)
retains the exact native inputs, source attachment and individual arithmetic.
The separate `.mlw` bound receives the same preserved Ptree and filename bound.

## Caller, input and configuration transfer

`gnat_ast_to_ptree.ml:1382–1423` reads one immutable fixed JSON document,
constructs one `mlw_file`, then passes that value to `Typing.type_mlw_file`.
Both exception arms call the local `print_mlw_file` at most once. Its order is:

1. If located, first form the marker string using `Format.asprintf`.
2. Convert the original Ptree with `Ptree.sexp_of_mlw_file`.
3. Open `.sexp`, serialize with `Sexplib.Sexp.to_string`, output and close.
4. Open `.mlw`, print the original Ptree, close, then propagate the exception.

An exception from a handler's helper escapes that handler; it does not reenter
the same match. A `.sexp` failure prevents the `.mlw` open. Partial files and
an unclosed channel are possible; successful delivery is not assumed. Library
read/open errors can reach these arms even with valid immutable input, so they
are included rather than excluded as physical-resource failures.

The [raw Ptree packet](../evidence/retained-fixed-ptree-capture-20261023/README.md),
freeze `91ad324d83` following `09d9a2382f`, supplies the complete pre-typing
graphs. All inspected Ptree records, lists, strings, attributes and positions
are immutable. No graph node is a mutable ref/array/custom numeric value.
`Typing` constructs its own typed records and environments; it cannot update
these immutable source fields through the selected source interfaces. The
handler closes over the original `mlw_file`, not a typed or reconstructed tree.
The external `FileTags` mapping only adds associations and does not replace an
old tag's filename; its existing counter/backing argument remains applicable.
Ordinary failures preserve that original tree. The existing external behavior,
faithful-memory and physical-resource premises remain explicit; this is not a
proof against arbitrary memory corruption.

The converter and smart constructors have no `Gnat_config` reads. Their data
inputs are the JSON fields and fixed constructor spellings. Quiet reporting,
J12, logging and timeless backend controls do not alter them. Name attributes
may acquire different hashcons tags, but serialize their `attr_string` only
(`ident.ml:41,53–55`). Locations may acquire different FileTags integers, but
serialize `Loc.get`, which returns the original filename and coordinates
(`loc.ml:44–97`). Sharing/address differences do not affect expanded occurrence
counts or content. The private synthetic location counter starts at zero for
the fresh plugin/process and advances only through these smart constructors.
No other admitted Main file precedes this fixed file in these per-check clients.

All filename origins in the preserved tree are JSON filenames
(`gnat_ast_to_ptree.ml:60–64`), the smart constructor's literal `<dummy>`
(`ptree_constructors.ml:6–14`), or `Loc.dummy_position`'s empty filename.
They are not expanded against cwd by those constructors. Maximum JSON string
lengths are 174/171/189/186/182, so **Ptree filename payloads are at most189**
bytes. Using the complete captured direct-string maximum202 is also sound.
This is the filename operand for `.mlw`/`.sexp` source locations; initial
client/config/loader paths in the pre-cut exception analysis are a separate P.

The inspected source revision is still Why3
`9390baf120ef260547dfa14f08e11c890b203d9c`, under the existing
[relevant-behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary).
The raw capture found one explicit layout difference: native module entries
are `(ident,optional_signature,decls)`, all with middle value `None`, while the
inspected source uses pairs. This packet retains the actual native converter
reader: `sexp_of_mlw_file_3475` selects closure `0xcb77c0`, whose
`caml_tuplify3` entry and `fun_8036` body read all three fields, invoke
`sexp_of_option` for the middle value and construct a three-element Sexp List.
The new output captures therefore include the extra None. No exact upstream
revision identity or pair-layout equivalence is silently assumed.

## Complete native serializer inputs

The raw graph alone would require a new global theorem about all generated
converter expansion. Instead, the packet retains the **actual complete Sexp
values** at entry to `Sexplib0.Sexp.to_string_mach_1258`, before its first
instruction. These are five new boundary captures, not repetitions of an
earlier successful validation. The fixed family is exhaustive, not a sample
of arbitrary Main programs.

Each uses byte-identical JSON and configuration files, the same installed
executable/plugins and original per-check argv, with the sole option addition
`--debug-why3 gnat_ast` and fresh cwd/TMPDIR. That option selects the same local
`print_mlw_file` on the successful typing branch. It also prints the earlier
GNAT AST; that printer has no Ptree constructors, FileTags writes or Sexp-option
setters. Successful typing and failed typing both pass the preserved original
tree to the identical `save_mlw_as_sexp` converter. The marker is used only by
the subsequent Mlw printer and is absent from the Sexp converter. Thus the
successful debug route supplies the same Sexp input as the failure route,
up to the option-mode allowance below and irrelevant physical sharing.

The stack records `save_mlw_as_sexp_7559` immediately above the serializer,
not a coincidentally reached general Sexp helper. The input is in rax. Its
120 entry bytes match installed ELF address `0x86cf10`. Fork/vfork/exec and
the later `Gnat_checks.init` boundary are guarded. No inferior function call
or memory write occurs, and no serializer byte output, server connection or
solver work follows the cut. Five serial captures used one managed worker,
**27.334876 seconds** total. The earlier Ptree capture's failed preparation
and successful inputs remain separately retained; no successful capture was
repeated to populate a reporting field.

The checker interprets the whole graph as precisely `Atom(string)` or
`List(proper finite list of Sexp)`, checks headers and acyclicity, rejects
uninterpreted reachable nodes and charges shared children at every occurrence.
This includes derived labels, expanded FileTags filenames, integer strings
and the native extra module field; none is inferred from a static-label cap.

| Case | Atom occurrences A | List occurrences L | Atom payload bytes T | Maximum atom | Maximum list |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 51,019 | 35,101 | 273,688 | 187 | 51 |
| Put | 48,300 | 33,334 | 258,658 | 184 | 51 |
| First_Or_Default | 45,800 | 31,535 | 250,053 | 202 | 47 |
| Input_Is_Valid | 21,909 | 15,325 | 114,630 | 199 | 27 |
| Is_Message | 14,847 | 10,411 | 75,385 | 195 | 22 |

The ordinary derived converter uses each source field once. Its exceptional
leaf helpers are `Ident.sexp_of_attribute` (one string),
`Loc.sexp_of_position` (one filename and four integers), and integer decimal
conversion. Constants, masks and scalar enum types are structurally derived;
there is no function-valued/custom printer or external callback in the Ptree.
All original numeric values are immediates with magnitude at most2^31; there
are no arbitrary-precision custom blocks. Decimal conversion therefore needs
at most20 bytes, including sign. Loc's shift/mask results likewise fit that
conservative signed-native decimal bound.

For robustness to Sexplib's mutable `write_old_option_format`, let R be
`expanded_words + expanded_blocks + expanded_immediates` from the raw Ptree.
Each option conversion corresponds to a source field/value already charged
in R; the extra native None is charged too. `Some` switches between
`List[child]` and `List[Atom "some";child]`; `None` switches between `List[]`
and `Atom "none"`. Either change adds at most one four-byte atom to the
machine-output upper bound. There are at most R such occurrences, including
sharing expanded on every incoming edge. This allowance also permits choosing
the two modes separately at different occurrences; no mode-change stability
premise is needed. Other custom converters introduce no options.

## Buffer serialization and individual representations

`Sexplib.Sexp.to_string` aliases the machine serializer, **not Format**.
`sexp.ml:53–138,245–271,310–335` establishes:

- Each atom of length l escapes to at most4l bytes, plus at most two quotes.
- An atom has at most one preceding separator space.
- Each List emits precisely two parentheses, traversing each child once.
- The serializer creates Buffer1024, appends these fragments, then copies its
  contents. The Atom-root special case is smaller; these roots are Lists.

Induction over the actual finite Sexp graph therefore gives

```text
B_captured = 4T + 3A + 2L
B = B_captured + 19R
```

The19 is four times the added four-byte payload plus quotes/separator. Removing
a List or reusing an unescaped atom only reduces actual bytes. This is an
upper bound on total offered `.sexp` bytes for one complete attempt, and hence
on any failed prefix; it is not the measured output file size.

| Case | R | B_captured | B, either option mode | Largest Buffer backing |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 96,832 | 1,318,011 | 3,157,819 | 4,194,304 |
| Put | 91,885 | 1,246,200 | 2,992,015 | 4,194,304 |
| First_Or_Default | 87,671 | 1,200,682 | 2,866,431 | 4,194,304 |
| Input_Is_Valid | 41,967 | 554,897 | 1,352,270 | 2,097,152 |
| Is_Message | 28,131 | 366,903 | 901,392 | 1,048,576 |

Reuse the accepted native Buffer/addition/backing relation from the
[allocation result](retained-why-save-format-allocation.md). With positive
initial capacity1024 and no resets/truncation, the next doubling power of two
above B bounds every backing. Each append adds at most `4*max_atom+2` bytes;
the separately inserted separator/parenthesis is smaller. Position+length,
escaped-length counters, byte-copy indices and doubled capacities all fit
native signed integers. Every backing and returned string is below
`Sys.max_string_length=2^57-9`; padding/header arithmetic follows the same
accepted runtime result. The maximum escaped atom is810 bytes. Buffer contents
has length at most B. There is no Format queue, scan counter or sentinel on
this route, and no invented aggregate work counter.

Converter temporaries are fixed-field tuples/records, Sexp constructors and
linked lists. The list converter's `rev_map` and `rev` each have the same length
as their corresponding completed list; the largest output list is51 (at most52
under the alternate Some mode). Record-field/variant list builders are also
fixed or bounded by their completed lists. Loc's expansion is a five-field
tuple; scalar decimal strings fit20. No intermediate variable-size array or
unbounded numeric block is constructed. The native three-field module tuple
adds only the explicitly included fixed-field list. These statements bound
individual objects and native indices; they do not impose an aggregate RAM
quota. Finite recursion still uses the trusted sufficient physical stack.

The retained11 complete native bodies attach the actual module converter and
machine serializer/escaping loops to the identified ELF (2,912 instruction
bytes). The capture roots attach their actual calling convention. This uses
the existing scoped external behavior relation for standard runtime/converter
operations; it neither claims a new compiler-correctness proof nor substitutes
unrelated source hashes for the relevant native attachment.

## Channel and failure composition

The caller opens the `.sexp` file before byte serialization, using fresh
`open_out`, `output_string`, `close_out`. Its selected flags are
write/create/truncate without append/nonblocking, and Linux text output has
no translation. The same private regular-file/workspace and stable-description
premises used for saves are attached to this new caller. `open_out` alone does
not prove the file kind or exclusive ownership.

The [positive-write service contract](retained-why-save-service-contract.md)
is explicitly extended from its original XML/shape callers to this `.sexp`
description: valid requests1..65536 either return1<=w<=n, error/raise, or do
not return. The unchanged runtime handles ordinary EINTR retries; no finite
retry count or eventual delivery is inferred. This is a declared application
of the existing external service premise, not a stronger claim about POSIX.

Let C be committed bytes, D pending buffered bytes and delta∈{-1,0} the initial
cached-offset bias, including an initial lseek failure. The inherited copy/flush
induction gives `0<=D<=65536`, `C+D<=B`, and cached offset `C+delta∈[-1,B]`.
B is far below signed64-bit file offsets; each runtime write request is within
the existing buffer and C int/ssize_t ranges. Flush/close and later draining of
an unclosed channel consume only existing debt, adding no offered bytes.
Errors/nonreturn do not execute a successful-write commit. Pending-action and
state-commit service premises are unchanged. Global channel-list ownership is
not replaced by this private-channel calculation.

The Ptree is preserved even if `.sexp` succeeds and `.mlw` fails. A failed
serializer is not retried by this handler, and no handler renews the one global
e<=2/two-callback/three-save allowance. The pre-cut exception/marker packet and
independent Mlw packet remain separate composition providers. This result is
for review; complete fixed-process and #119 coverage are not claimed here.

Live lead model/effort and token/cost telemetry are unavailable. Native and
offline intervals have the precise scopes in the packet. Oracle, installed
tools/pins, current admission and physical-resource premises are unchanged.
