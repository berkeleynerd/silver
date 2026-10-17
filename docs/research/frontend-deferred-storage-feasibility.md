# Deferred frontend String storage feasibility

**2026-10-17 — research evidence for [#113](https://github.com/berkeleynerd/silver/issues/113).**
This is a candidate representation, not an implementation, selected toolchain,
language change or completed assurance argument. The owner authorized research
in [PR #114](https://github.com/berkeleynerd/silver/pull/114), on `main` at
`b8e618c54592f66461b2a08023795f31c16a7d39`. Implementation #88–#94 remains unstarted.

A persistent, shared String representation can remove the specific frontend
pool obstruction without changing the authoritative Ada source or deferring
Ada-static evaluation to runtime. Its required interface changes are concrete,
but it is a larger change than widening the pool. It does **not** by itself make
the proposed language tractable end to end: GCC still materializes emitted
Strings, and the inspected GNATprove producer expands String values into
per-character proof data. Ownership and verified-SPARK obligations also remain
material. The [combined toolchain assessment](frontend-toolchain-feasibility.md)
owns those decisions and the resulting recommendation.

## Evidence and scope

The [retained bundle](../evidence/unbounded-programs/frontend-deferred-20261017/README.md)
contains a reproducible consumer inventory, selected source excerpts, exact
design arithmetic and four complete additional GCC source files. The input is
GCC commit `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, Ada tree
`a3b9f0d4c999c8c127cebdc239ca8218284137aa`. The audit rechecked all 2,490 Ada-tree
files against their Git blob identities: 62,760,971 bytes, zero mismatches.
The earlier [lifetime audit](unbounded-frontend-lifetimes.md) retains the full
inventory and establishes the ordinary frontend's lack of Stringt reclamation.
Applying this source analysis to an installed compiler retains the documented
source-to-binary premise; no reconstructed compiler or binary attestation exists.

The lexical inventory has 501 matching lines in 53 files, including definitions,
internal calls and 11 unrelated runtime `String_Length` occurrences. An additional
208 lines are candidates for overloaded `Append`/`To_String` calls. These are
search results, not counts of operational Stringt calls or a verified call graph.
The [resolved route inventory](../evidence/unbounded-programs/frontend-deferred-20261017/resolved-routes.json)
identifies the semantic, conversion and ABI routes used in this assessment.
The complete search remains available for follow-up resolution.

This lane performed source inspection and exact arithmetic on Linux x86_64
`codex-silver`; `scripts/dev.py paths` was read. It did not build a compiler,
bootstrap, run GNATprove/Lean, execute an application or repeat a giant-capacity
probe. The [earlier bounded backend probes](unbounded-static-data-continuation.md)
are retained evidence, not reruns or validation of this candidate.

## Concrete representation

Keep a `String_Id` descriptor containing an exact logical length and an immutable
root. Use three root forms: empty, a slice of a bounded immutable `Char_Code`
chunk, and a balanced concatenation of two roots with cached length and height.
Children refer to immutable roots, **not mutable String_Id descriptors**. A
descriptor for the current builder may change while all previously captured
roots retain their values. This avoids cycles and accidental alias mutation
when appending the current String to itself.

Use persistent balanced joins, such as an AVL rope, with empty operands
normalized away. Appending literal characters fills a private bounded chunk;
capturing a root freezes its contents, after which subsequent writes use new
storage. The current builder may have an unpublished pending chunk after its
immutable prefix. Reads of that current descriptor include the pending chunk;
capturing it for `Start_String(S)`, `Store_String_Chars(S)` or `End_String`
first flushes the chunk into an immutable root. Flushing does not seal the
descriptor: subsequent stores can open another private chunk. Chunk size is an
internal allocation choice, not a Silver membership
restriction. Do not allocate one node for every literal character. Checked,
wide or pointer-sized arena references and growth are still necessary: moving
from character entries to nodes does not justify reusing an overflowing table.

The existing logical API can preserve these behaviors:

| Operation | Candidate behavior and required invariant |
| --- | --- |
| `Start_String` | Add a fresh empty descriptor and current builder. |
| `Start_String(S)` | Capture S's root and length before opening the new builder. No character copy is required. |
| `Store_String_Chars(S : String_Id)` | Capture S's root before updating the builder; join the two immutable roots with checked exact-length addition. |
| Character and Ada `String` store overloads | Append to bounded chunks and join completed chunks. Preserve all `Char_Code` values, including the wide-character cases outside Silver's author profile. |
| `End_String` | Return the current descriptor identity. The existing body only returns `Strings.Last`; it does not seal the builder. Preserve that behavior instead of assuming a new immutability promise from the name. |
| `String_Length` | Return cached exact logical length using the existing `Nat` result. Proposed per-value lengths remain at most `Integer'Last`; aggregate storage uses a separate representation. |
| `Get_String_Char` | Resolve the 1-based index through concatenation lengths into its chunk. Return the same character as the current flattened sequence. |
| `String_Equal` and lexicographic comparison | Preserve exact equality/order, including length and null-string rules. Root identity can prove equality for identical roots; a hash alone cannot. |
| `Unstore_String_Char` | Remove the final character from the current builder, splitting a root or shortening a private chunk as necessary. Previously captured roots remain unchanged. |
| `Mark` / `Release` | Snapshot and restore descriptor/node/chunk arena tails and the builder state at the existing checksum boundaries. No surviving root may reference released storage. This is not new semantic-phase garbage collection. |
| `Lock` / `Unlock` / `Initialize` | Preserve mutation discipline, initialization of the null String and access during backend processing. Locking storage is separate from completing static evaluation. |

The mathematical abstraction is `value(empty) = []`, `value(chunk[a..b])` its
character sequence, and `value(join(l,r)) = value(l) ++ value(r)`. Required
invariants include exact length, balance, valid ranges/references, acyclicity,
snapshot immutability and valid rollback. Every operation must refine the
existing sequence operation, including builder self-aliasing and empty values.
No probabilistic hash assumption is required. This is a proposed proof boundary,
not a claim that these invariants have already been proved for implementation.

### Why the known witness becomes small in the frontend

The [two-chain input](../evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/two-live-chains.adb)
has `A0 = "x"`, `A(i+1) = Ai & Ai`, and a separate `"y"` chain through index 30.
The unchanged pool requires at least 2^31 character entries for its two final
values alone. A shared representation can describe the chains with two leaf
roots and 60 concatenation roots, plus 62 descriptors. Each self-concatenation
joins equal-height children, so balancing needs no additional rotation nodes for
this shape. Shared children do not duplicate their character storage.

Those counts are symbolic design arithmetic. They exclude lexical tokens,
compiler/runtime dependency Strings, metadata, other folds and spare capacity;
they are neither measured RSS nor an implemented benchmark. They establish that
the old aggregate-character obstruction is avoidable by representation. They do
not establish an unlimited source domain or shrink eventual emitted bytes.

## Preserve static semantics, not merely runtime values

Ada RM 4.9 requires the static evaluation and checks; the representation may
change without moving those obligations to runtime. Keep the existing semantic
routes and prove the storage abstraction gives them the same observations:

| Exact pinned route | Obligation |
| --- | --- |
| `sem_res.adb:10803–10815` → `sem_eval.adb:2342–2443` | Resolve and evaluate static concatenation with the same operands, lengths, lower bounds and constraint-error behavior. Replace storage construction underneath it; preserve the null-right-operand bound rule. |
| `sem_eval.adb:5118–5144`, `5293–5300` | `Fold_Str` still rewrites to a String literal with the same static flags and type information; constant references still resolve to the same value. A root is a compiler representation, not new author syntax. |
| `sem_eval.adb:1328–1385`, `2700–2765` | Compile-time comparison and indexed-component evaluation observe exact characters. Any faster comparison must preserve the current result; bypassing it is not a representation change. |
| `sem_res.adb:12035–12320` | Keep character legality, static predicates, type bounds and full-aggregate fallbacks. Standard.Character static concatenations already avoid a repeated character-range scan because their operands were checked; that existing optimization is useful counterevidence to an unavoidable scan at every fold. |
| `par-ch4.adb:2510–2665` | Preserve the parser's long-literal-chain folding behavior and `Is_Folded_In_Parser` distinction. It already builds through Start/Store/End, so the same logical API can represent its value without flattening it. |

The scanner's own character sequence must remain authoritative. Source locations,
diagnostics and invalid-input behavior need ordinary compatibility review in a
general GNAT change, even where Silver rejects the corresponding construct.
`-gnatd.f` is not this design: the pinned compiler describes that debug switch
as causing seriously non-conforming behavior by suppressing normal folding.

Other Stringt consumers still exist. `Append(Bounded_String, String_Id)`,
`String_To_Name`, `String_To_Name_Buffer` and `To_String` materialize characters
into name/String buffers. Pragmas, debug names, generic processing, dimension
handling and compiler-generated attributes use these routes. For example,
`sem_ch12.adb:6161` constructs a generic static-expression name and
`sem_ch3.adb:3972` converts an external-initialization String. These operations
must retain their existing semantics and bounds; the design does not make every
consumer allocation-free. Silver's author profile excludes many such inputs,
but the selected fixed dependencies also run through the frontend. The complete
dependency/source-capacity argument must cover their reachable routes.

## The C/C++ boundary must change

The existing ABI exports the character and descriptor pools directly:

* `stringt.adb:268–270,341–343` returns their addresses;
* `back_end.adb:100–101,169–170` passes them to Gigi;
* `gcc-interface/gigi.h:260–261` and `trans.cc:307–308,334–335` receive them;
* `stringt.h:51–88` duplicates the descriptor layout and implements reads by
  pointer arithmetic.

Keeping those exports and flattening every root before calling Gigi would
reintroduce the aggregate pool and its peak. The concrete candidate replaces
the raw exports with an opaque access interface. Export explicitly C-compatible
length and indexed-character functions; update the C header to call them, and
remove the obsolete Gigi pool arguments and globals in the same build. The
existing C types are `Int`/`String_Id` as signed `int` and `Char_Code` as unsigned
`int`; check width, signedness, calling convention and ranges explicitly against
the Ada declarations. Do not rely on an undocumented default Ada calling ABI.
The logical `String_Length`/`Get_String_Char` signatures can remain unchanged for
Ada callers. Compiler and producer must be rebuilt coherently; this is not a
binary-compatible replacement for an installed Stringt object.

For efficient sequential consumers, add a read cursor or chunk-copy operation
over an immutable root snapshot. A C entry point can fill a caller-owned bounded
buffer and return the actual character count. It must not expose a pointer whose
validity depends on later arena relocation. Its binding, lifetimes, buffer bounds
and conversions need their own verified interface argument. The first semantic
implementation can use indexed access; retaining large loops that call an
O(log L) accessor per character adds an avoidable logarithmic factor. A cursor
is an optimization with a concrete need, not permission to skip characters.

### GCC still materializes the final value

`trans.cc:6705–6731` currently allocates a temporary Character buffer, reads
each Stringt character, calls `build_string(length, buffer)`, then frees the
temporary. With the new accessor this remains semantically valid, but the
temporary and GCC's String node coexist. A reviewed constructor/helper could
fill a newly allocated GCC String node directly and remove the temporary;
`build_string(len, NULL)` already allocates/zeroes a fresh node, but the public
`TREE_STRING_POINTER` accessor is const-qualified. Arbitrary mutation of an
already published GCC constant is not a justified implementation shortcut.
Direct construction still needs L bytes for a length-L Character String.

The exact GCC endpoint check is more favorable than an assumed signed allocation
length: `tree.cc:2616–2636` takes **unsigned** `len`, allocates
`len + offsetof(tree_string, str) + 1`, stores an `int` String length and appends
a NUL. A Character String of length `Integer'Last = 2^31 - 1` fits that length
and the unsigned allocation quantity on the inspected 32-bit-Int/64-bit-host
configuration. The extra NUL byte does not by itself overflow `build_string`.
This is source arithmetic, not an allocation at that size.

There is a separate, unresolved **option/path obligation** at emission:
`varasm.cc:5628–5635` adds one to a non-NUL-terminated String when emitting into
a mergeable String section, then passes the size to `assemble_string`, whose
parameter is `int` (`2304–2335`). At the exact endpoint the incremented size fits
the wide `thissize` variable but does not fit that `int` parameter.
`mergeable_string_section:865–920` requires `flag_merge_constants` and a
matching String/type length, and can select non-NUL Character data. This is not
a demonstrated defect in the selected Ada large-model build: retained measured
objects use ordinary `.rodata`/`.lrodata`, and the full endpoint path was not
executed or proved reachable. Before claiming the entire value domain, close
that path under the chosen fixed flags, or repair its size handling. A reviewed
fixed no-merge configuration is a possible representation-preserving avenue;
this record neither adopts it nor substitutes a lower language endpoint.

Truly compressed GCC String constants would require broader GCC tree, hashing,
optimization, emission and possibly LTO changes. They are unnecessary to remove
the frontend pool obstruction and are outside this concrete candidate. Large
code-model placement, mutable object/stack allocation, linker and runtime costs
remain the separate obligations in the retained backend assessment.

## Cost, producer boundary and disposition

With balanced joins and bounded chunks, cached length is O(1), random character
access is O(log L), and a cursor traverses a length-L value in O(L + height).
One persistent join/split uses O(log L) new nodes in the worst case. Across J
joins with maximum value length L, a conservative retained-node bound is
O(J log L), plus source literal/chunk storage; identical balanced self-joins in
the witness are cheaper. Exact equality or ordering can require O(L) character
work. Differently shaped equal values cannot be declared unequal from distinct
root identities. No claim of constant-time comparison or automatic universal
compression follows from the DAG.

Incompressible literal data still needs its source-sized storage. Repeated
comparisons can repeatedly traverse a large expanded value, and backend output
can retain many named constants. Other source/AST/descriptor/numeric tables
remain finite and require independent accounting. A bounded source spelling can
still denote enormous compile/proof work; resource costs do not become a proof
of the Oracle's automatic-discharge guarantee.

The root stream's separate GNATprove inspection is decisive for scope.
In the inspected SPARK `fsf-16` source, `Transform_String_Literal` allocates a
`W_Pred_Array(1 .. Length)` and creates per-character index/access/value/equality
nodes; `Spark_Atree` also scans characters. Why node identities have an independent
finite representation. Giving those routines a deferred Stringt root leaves
their expansion intact. Source provenance matters: that SPARK source is a
verified branch snapshot, not an established exact commit of the installed
producer. The [combined assessment](frontend-toolchain-feasibility.md) retains
the exact commit, paths, bounds, premises and follow-up requirement. Deferred
Stringt does not establish producer capacity or complete automatic discharge.

The required change set is larger than a private-pool widening:

| Ownership-sensitive area | Required change or separate obligation |
| --- | --- |
| `stringt.adb`, `stringt.ads`, new arena/rope support if split out | Replace storage, builders, lifecycle and accessors; establish the sequence refinement and memory/arithmetic safety. |
| `stringt.h`, `back_end.adb`, `gcc-interface/gigi.h`, `gcc-interface/trans.cc` | Replace raw-pool ABI coherently; verify C/Ada boundary and matching tool builds. |
| Sequential String consumers | Indexed reads remain functionally valid; cursor conversion is needed where its cost matters. Changes to comparison/legality logic need semantic review. |
| GCC String construction/emission | Ordinary materialization can remain; eliminating its temporary or fixing a reachable endpoint path is additional implementation, not already obtained by the rope. |
| GNATprove frontend and producer | Use a compatible Stringt implementation and address independent per-character expansion; preserve obligation generation and prove automatic-discharge completeness for the admitted domain. |

No body becomes exempt from Silver's ownership rules by retaining its upstream
filename. A Silver-maintained fork containing unverified Ada/C++ changes cannot
simply be relabelled an existing trusted dependency. An upstream/vendor-owned
solution and a Silver-owned implementation have different obligations; the
combined assessment must establish a permitted route before implementation.

**Disposition:** the deferred representation is a technically coherent option
for reducing frontend duplication, with a concrete abstraction and interface
plan. It is not the minimum change to remove the identified pool-width defect;
narrow widening preserves more of the current API and processing model. Neither
option alone resolves the producer or ownership boundary. Do not start a lazy
frontend implementation as if it completed #113's end-to-end requirement. Use
this design only if the combined study establishes an authorized, supportable
toolchain route and the storage savings justify the additional implementation
and proof surface. No pin, language rule, cap, Oracle text or production code
was changed by this research.
