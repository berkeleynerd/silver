# Sexplib converter prefix and the installed indirect dispatch

2026-10-19, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). This closes the named
**Sexplib converter registration/replacement boundary** in the frozen
[exception-prefix packet](retained-why-session-exception-prefix.md), commit
`18bd02108fc2e0456f4339d3e31b593b5daab7da`, under the existing scoped
source/runtime correspondence, valid typed-heap, fixed-loaded-code and
exclusion-of-unmodeled-foreign-mutation premises. That packet remains unchanged.
The callable family at **`0x86e592`** is now classified; arbitrary nested
exception effects and interrupted continuations remain unclosed.
**Exceptional identifier charge and complete `R` remain null.**

## Exact installed version and evidence

The same installed executable, SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`, embeds
`.debug_str` build paths for **sexplib0, sexplib and parsexp v0.16.0**. Their
file offsets are respectively 19,520,670, 19,492,631 and 19,507,138.
The official GitHub tag responses name these exact commits:

| Package | v0.16.0 commit |
| --- | --- |
| sexplib0 | `df916dfe8d0538a0dbfcdcb35c6e933ac9fc8130` |
| sexplib | `e5b3b209d40c5ecb348634832eafd1945b25fb2d` |
| parsexp | `f359b2244cc5f7421120917450a846a4a326836d` |

The [new evidence packet](../evidence/retained-why-sexplib-converter-prefix-20261019/README.md)
retains those responses and official commit archives, exact source excerpts,
registration events, and **50 bodies plus four windows / 20,509 byte-checked
bytes** extracted from the existing disassembly. Thirty-nine static closure
records include the exported registration adapters and the `add_inner` infix
entry. The pinned checker reads files only. No native execution, capture,
debugger, disassembler or solver was started. The debug paths select the
matching upstream versions; they are not a universal source/binary refinement
proof. Installed startup, constructor aliases, flags, callbacks and delegated
calls supply the specific correspondence evidence used here.

## Registry semantics and the real replacement

`sexplib0/src/sexp_conv.ml:76–120` makes a private ephemeron table keyed by
exception extension constructors, with physical equality and constructor-id
hashing. Each value contains a callback and a `printexc` flag. The public
interface (`sexp_conv.mli:268–284`) exposes `add` and a test-only size query;
it does not expose the table or removal. The optional `finalise` argument is
ignored. In particular, these registrations do **not** install finalizers.

`find_auto` obtains the actual constructor and returns `None` for an absent
entry. With `for_printexc=true`, it also returns `None` for an entry whose flag
is false. Otherwise it invokes the saved converter. Installed `find_auto`
corroborates the lookup at `0x86e551`, the flag test at `0x86e56c–0x86e57a`,
and the callback call at `0x86e592`. The Sexplib0 Printexc printer passes true.
`sexp_of_exn` and `printexc_prefer_sexp` pass false; the latter is a query,
not a mutator. When `sexp_of_exn` finds no converter, it calls
`Printexc.to_string` on the same exception (`sexp_conv.ml:122–148`).

The installed startup window calls Sexplib0 initialization at `0x526f34`,
Parsexp's two registering modules at `0x527014` and `0x527074`, then
Sexplib.Pre_sexp at `0x527164`. Initialization has **24 registration events
for 23 distinct keys**:

| Initialization contribution | Events | Automatic Printexc flag |
| --- | ---: | --- |
| Sexplib0 ordinary defaults | 17 | false |
| Sexplib0 `Sexp.Of_sexp_error` | 1 | true |
| Parsexp's own `Parse_error` and `Of_sexp_error` | 2 | true |
| Pre_sexp `Annot.Conv_exn`, aliased `Of_sexp_error`, own `Parse_error`, `Of_string_conv_exn.E` | 4 | true |

The 17 defaults are `Assert_failure`, `Exit`, `End_of_file`, `Failure`,
`Not_found`, `Invalid_argument`, `Match_failure`, `Not_found_s`, `Sys_error`,
`Arg.Help`, `Arg.Bad`, `Lazy.Undefined`, `Parsing.Parse_error`, `Queue.Empty`,
`Scanf.Scan_failure`, `Stack.Empty`, and `Sys.Break`. Their callbacks construct
strings or S-expression data. The two built-in list iterators pass tagged
false and true respectively. The retained event list ties each constructor
to its source line and installed closure.

Pre_sexp's `Of_sexp_error` is **the same constructor** as Sexplib0's, not a
similarly named fresh exception. Source `include Sexplib0.Sexp` and
`Sexp_conv`'s explicit alias agree with native copies of `Sexp+0x28` into
`Pre_sexp+0x18` and `Sexp_conv+0xc0`. The initial registration uses that
`Sexp_conv` field at `0x8708fd`; the later one uses `Pre_sexp+0x18` at
`0x829eab`, passing a different closure. Parsexp's constructors are fresh,
distinct keys despite their similar names.

`Ephemeron.add` prepends a binding and `find_opt` selects the first matching
live binding (`ocaml/stdlib/ephemeron.ml:214–221,270–293`). Thus the later
Pre_sexp registration **shadows** the earlier Sexplib0 converter; it does not
delete the old binding. After completed startup the six enabled keys select
the six callbacks below. The family argument conservatively also retains the
earlier `Of_sexp_error` callback. Ephemeron cleanup cannot manufacture a new
callback, and neither registration of this key changes its flag to false.
The count of 23 keys is not a claim that the table contains only 23 bindings.

## Enabled callbacks and delegated effects

All six later registration calls pass tagged true to `add_inner_2040`:

| Constructor | Registration call | Closure / code | Direct behavior |
| --- | --- | --- | --- |
| `Pre_sexp.Annot.Conv_exn` | `0x829dcd` | `0xe48310` / `0x8262a0` | Location string and inner exception |
| `Sexplib0.Sexp.Of_sexp_error` | `0x829ebb` | `0xe48398` / `0x826620` | Optional Annot unwrapping, Sexp data and inner exception |
| `Pre_sexp.Parse_error` | `0x829f61` | `0xe48410` / `0x826860` | Error message and four position integers; does not traverse the parsing stack |
| `Pre_sexp.Of_string_conv_exn.E` | `0x82a696` | `0xe48980` / `0x8294c0` | Containing/invalid Sexp data and inner exception |
| `Parsexp.Parse_error.Parse_error` | `0x834bf5` | `0xe57698` / `0x834880` | Position and message data |
| `Parsexp.Of_sexp_error.Of_sexp_error` | `0x869cea` | `0xe5d578` / `0x869b30` | Location/Sexp data and inner `user_exn` |

Pre_sexp's three exception wrappers use
`sexp_conversion_error_message` (`pre_sexp.ml:150–168`). It treats an inner
`Failure s` as an atom; otherwise it calls `sexp_of_exn` on that inner
exception. The installed helper has that call at `0x826157`.
Parsexp's `sexp_of_t` delegates `user_exn` at `0x86997c`.
The earlier Sexplib0 converter likewise delegates the inner exception
(`sexp_conv.ml:406–411`). These are explicit residual edges, not zero-charge
annotations for arbitrary payloads. An inner logical exception may ultimately
reach a Why term/declaration printer through `Printexc.to_string`.

The direct data-building parts contain no Why identifier creation, session
mutation, statistics callback installation or formatter callback installation.
Sexp values are the `Atom of string | List of t list` data type; rendering them
uses data traversal and the already repaired formatter family, not a callback
stored in the Sexp payload. This says nothing about termination, allocation
volume, cyclic malformed values or exceptions raised while rendering. Runtime
pending-action dispatch remains at its existing separate boundary.

For the ordinary primitive family in the frozen exception packet, every key
is either absent or one of the false-flag defaults. **When reached through
the Sexplib0 Printexc callback, `0x86e592` is therefore not taken for that
family.** A direct `sexp_of_exn` query can invoke a disabled default converter;
its inspected primitive/data behavior explains that separate case. No enabled
registration replaces a primitive key. This lemma does not say that the save
and exit paths can raise only those primitive exceptions.

## Why subsequent registry mutation is excluded in this prefix

The preservation argument uses API abstraction and the actual clients, including
aliases and generated code; it does not infer unreachability from a zero raw
caller count. The three complete package archives and fixed 603-file Why source
projection are retained. The Why projection has no converter-registration or
`Exn_magic` client. All **64** `sexp` deriving declarations belong to ordinary
types, including mutually recursive types, rather than exception declarations.
Their retained declaration snippets address the otherwise hidden
PPX-generated-registration possibility.

`Sexplib.Conv` includes `Sexplib0.Sexp_conv`, and `Parsexp.Import` both aliases
and includes it. Those aliases therefore have to be followed. The installed
copies and external uses are reconciled as follows:

| Access path | Scoped interpretation |
| --- | --- |
| `Sexp_conv+0x238` to `Conv+0x238` (`0x82cc03–0x82cc0a`) | Publishes the abstract converter API; no call or new registration |
| `Sexp_conv+0x238` to `Import+0x240` (`0x8315dd–0x8315e4`) | Same API alias; package source clients are the two fixed Parsexp initializers |
| Why `Mysexplib.input_sexp` reads `Conv+0xc0` (`0x542b23`) | Tests the `Of_sexp_error` constructor; does not load the registration API |
| `Sexplib.Std` reads Conv fields | Exports ordinary conversions, including the query `sexp_of_exn`; its source exports no `Exn_converter` module or registration function |
| `Parsexp.Cst.sexp_of_t` reads `Import+0x38` (`0x833537`) | An option's data-conversion function, not the API at `+0x240` |
| `Sexp_conv_error` reads `Sexp_conv+0xc0`; `Sexp_conv_record` reads `+0xc8` | Exception-constructor alias and record-check option, respectively |
| Installed `Ppx_sexp_conv_lib.entry` | Copies the Sexp data API; does not publish the converter registration API |

Within Sexp_conv, the private table is used by `add`, lookup and size; the
other global accesses concern primitive converters, conversion options or the
exception constructor. The interface prevents a typed client from obtaining
the table and using generic ephemeron mutation directly. Installed closure and
module access records corroborate these source paths, including the exported
`add` closure's infix `add_inner` entry.

`Sexplib.Exn_magic.register1` through `register10` really can register arbitrary
supplied conversion functions; they are **not** safe-family formation rules.
The full package source defines them without an initializer that calls them,
and the scoped Why clients never obtain them. Installed `Exn_magic.entry`
contains only publication of the static export closures and a unit return.
Its exported closure addresses and module block have no application access
beyond that publication in the inspected installed access paths. The sole
additional static word naming `register` is code-segment metadata. Thus
publishing these dormant APIs does not enlarge this prefix's callback family.
Allowing a new caller or unchecked access would invalidate that conclusion.

The new raw diagnostic has 20 direct-call/jump candidates to the registration
APIs: six later initializer calls, eleven Exn_magic adapter bodies, one
optional-argument adapter, and two built-in iterators. It also records all
selected export/module RIP-relative candidates and aligned data words.
These scans are **diagnostics, not a whole-program indirect-call proof**;
their role is to expose and reconcile installed aliases and clients with
the source argument above. The two fixed plugin identities are included:
`ada_terms.cmxs` has no related symbol and `gnat_json.cmxs` only references
Sexplib0's Sexp string rendering, matching its source. Optional upstream
`Sexplib_unix` is not linked here; its source registration must not be counted
as an installed event.

Every admitted initializer registers one of the listed callbacks; subsequent
scoped application/library operations query this private table, rather than
install a new converter. Each listed converter directly builds data or delegates
exception printing; it has no registration edge. This establishes preservation
of this converter family through the relevant prefix, including the genuine
same-key shadowing and nested calls. It does not substitute for the separate
interrupted-handler/state-preservation proof.

## Remaining obligations

The Sexplib registry is no longer an unclassified indirect callback. Two
obligations from the frozen exception analysis remain: the exhaustive family
of exceptions actually reachable from save/exit and their transitive helpers,
and preservation/accounting through interrupted catches and continuations.
Nested exception delegation stays inside the first obligation. No nonzero
identifier counterexample or observed save failure is asserted.

`B_binders = 966` and the conditional **`counter_end ≤ 63,573 + 2R`** interface
are unchanged. 63,573 is not an established endpoint. Full-history/family
capacity, later invocations, auxiliary allocation and whole-pipeline assurance
remain outside this packet. Root owns independent review, integration and
publication bookkeeping.
