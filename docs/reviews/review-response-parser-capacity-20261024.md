# Independent review: Why response to GNATCOLL parser capacity

2026-10-24 UTC; #119 / #186 / #187 / #188. **Accept** repaired author freeze
`6fa482f6266d60256300849adf0a657d1df521bc`. No unresolved scoped finding
remains. This completes #186's technical response-parser capacity interface
under its named source/configuration/native/physical premises. This review covers the
[derivation](../research/retained-response-parser-capacity.md) and its complete
new packet through `GNATCOLL.JSON.Read_File` return or existing failure
propagation. Later GNAT2Why aliases, result conversions, assumptions, messages
and `.spark` are outside this component and remain #119 obligations.

Selected reviewer: **GPT-6 Astra / Extra High**, as selected by the delegating
lead. Independent runtime confirmation and isolated token/cost telemetry are
unavailable. The actual host is Linux x86_64, kernel 7.0.14. The subthread
harness goal was null. The lead supplied owner authorization for the bounded
independent review and retains integration, GitHub, publication and memory.
This worktree owns only this report and its
[evidence packet](../evidence/review-response-parser-capacity-20261024/README.md).

## Findings and repair

**#187 is a real candidate-source counterexample to the historical streamed
reader argument.** `Read_File` opens a reader and immediately calls `Read`.
Its first whitespace/token scan uses the offset-taking `Next`, which only
increments below `Last` and never invokes `Internal_Next`. The stream branch
leaves the default `Last=0`; the first event is therefore DOC_END while the
parser expects a value. The other Next overload's refill cannot repair this
first transition. A successful stream-window theorem does not follow from
the pinned implementation. No installed-binary experiment or defect is claimed.

The repair requires a stable regular-file byte bound with `B+256<=2^31-1`.
The selected `Open(Path)` then reads at most 64 KiB or maps the entire file.
The held-window refill, shifting and doubling branches are unreachable on this
successful route. The spare also covers token slice endpoints, line/column
error scanning and fixed numeric diagnostic slices. A file/open/read/mapping
failure retains the source's existing outcome; the inequality cannot make an
unsuccessful read successful. In particular the small-read branch has its own
catch/close behavior, rather than a promised propagation of every service error.

**#188 blocks the original author freeze
`e87701a25b2c1a953c9313a4f0e35505c6ba57a7`.** The retained
`Run_Gnatwhy3` calls `Non_Blocking_Spawn` with `Output_File_Descriptor=>Fd`
and `Err_To_Out=>True`, stores the tempfile name, and `Collect_One_Result`
passes that same name to the result parser. The original malformed-file bound
covered stdout only. Including some stderr text in a shared text majorant
did not pay for stderr layout and direct fallback writes. This was a new
omission at the response-file join; the accepted component owners already
exported those bytes.

The repaired bound uses both cores. A normal single-line JSON attempt has no
boxes or breaks. Each abort attempt has five opens and five width-one breaks.
`Printer.int_of_string` emits text followed by `@.`; Format maps this to one
`pp_print_newline`, hence one flush/reset and at most one final newline.
The Debug stderr newline wrapper adds a channel flush, not another core reset.
With a abort attempts and Q diagnostic attempts, the two initial system begins
plus at most Q+2 resets give

```
Y_merged_core(T,a,Q) = T + 69*(10a+Q+4) + Q+2.
```

This reuses the accepted dirty-core token-once theorem. Every processed begin
or break contributes at most 69 layout bytes. System begins remain charged
even if a previous reset or output was interrupted. User-open depth remains
at most 5a+1<=21, far below the default max-boxes value, so the ellipsis-text
path cannot add an uncharged string. The two exit-flush credits are global,
not per root or report; charging two possible final newlines is conservative.

For the post-cut alternative, T includes the once-per-process 64Q stderr text,
and direct writes add `2*Y_terminal+371`, including the two distinct warning
backtrace prints. The pre-cut provider already includes the initial Q=1
diagnostic text; it needs `2*R4+253` direct stderr bytes. Successful-cut
continuation and terminal pre-cut failure are alternatives. Neither repair
renews `e<=2`, two save-entering callbacks or three saves. The actual response
descriptor, stable-file and publication relation remains required. No new
framing policy or channel separation is assumed.

## Parser shape, storage and errors

The intact schema uses the accepted `A=A0+E` attempt-binding bound and explicit
warning/debug providers. Repeated equal keys may replace a map entry but
cannot exceed the occurrence count. The per-invocation 76-byte canonical answer
bound yields 39576 source bytes for the largest warning,237458 encoded bytes
and 79152 decoded bytes. Why escapes each non-ASCII byte as `\u00xx`; the
twofold decoded bound is byte-specific. It is not a general Unicode theorem.
Variable Main must supply its own warning/debug maxima and response operands.

Failed writes and merged diagnostics can splice quote context, turning payload
brackets into structure. The malformed profile therefore bounds every token,
key, decoded string, container count and depth by the complete offered-file
byte bound b. A parser creation consumes input monotonically. Whole-document
validity is unnecessary: `Un_Escape_String` receives a tokenizer-validated
string token. Its surrogate lookahead is within that token: the closing quote
covers the first lookahead, and a following slash/u supplies the validated
escape bytes. Decoding never emits more bytes than this encoded token.

Both parser-state and builder arrays start at 32 and double. The sentinel
requires `q=max(32,pow2ceil(depth+1))`. Popped builder cursor slots are not
cleared, and growth copies the full old array. The JSON counter census therefore
charges 3q slots for old/new backing and one source-assignment temporary, plus 32
for locals, one parent position and its vector-copy variants, aggregates and
return transport. Each created payload is fresh and inserted into at most one
parent; end events do not insert it again. `JSON.Adjust` increments the selected
container's counter only, without recursively copying its children. Map
replacement and pointer-only rotations cannot introduce a second parent.
The transient census is consequently per payload, not a total-values heuristic.
Even q=2^30 gives 3,221,225,504 aliases, below the unsigned32 maximum.

An XString backing is a separate owner. JSON handle copies share the JSON
internal object and do not copy its Str field. Keys and string values decode
fresh; no nonempty map/container clone occurs. The 16-handle envelope covers
the decoder/result, aggregate/node and controlled-return temporaries under the
selected GNAT controlled-assignment relation. Leaked holders remain counted.
This is not a compiler-independent assertion about unlimited hidden temporaries.

String_Builder resets before each encoded key and reserves a NUL, so its
doubling bound uses key+1. XString growth must guard unsigned32 `Current*3`
before division, strict-next-page rounding and half-capacity storage. Before
an actual growth, current capacity is below the requested decoded length;
an oversized final backing is never multiplied again after decoding ends.
The path builder has its own actual path/cwd bound. Unix normalization with
Resolve_Links=False allocates `p+2m+4` scratch and cannot return more than
`p+m+1` bytes under the selected native cwd contract. It does not reuse the
different Why-client PrecutP. Mmap page expansion retains its signed64 guard.

Positive-index vectors append one item and double at most to2^30 when their
length is<=2^30-1; endpoints, length additions and Count_Type conversions fit.
Ordered maps allocate fixed-size nodes and increment their represented count,
with no hash/load-factor multiplication. Per-object size bounds remain below
size_t. These are representation checks, with physical memory/stack/disk
availability still explicit premises; no aggregate RAM gate is introduced.

The selected integer/Long_Float scanners use fixed numeric state. Decimal
index/scale changes are bounded by the token length; exponent accumulation
stops at its threshold, and the large-exponent branch replaces the scale.
The token+Integer'Last/10+2 guard covers the remaining additions. The two
part-scale differences cancel their common exponent. Numeric Bad_Value text
is truncated to 128 input bytes. Integer range errors become a fixed
Invalid_JSON_Stream; Long_Float Constraint_Error escapes JSON.Read.

Cleanup claims match source: the caught Invalid_JSON_Stream branch frees
Read_States but omits Current_Key deallocation. An uncaught service or
conversion failure can retain Read_States and its partial graph. Those objects
remain within the per-object/per-counter bound; repeated-call allocation
demand and downstream error reporting are different owners. No failure is
reclassified as parsed success or successful proof.

## Evidence and scope

The first and only frozen review check passed **374 checks in
1.611748152 seconds**. It pins all 12 author files and 27 provider inputs,
checks the 49 source files and their ranges, and independently compares the 24
GNATCOLL members to the retained complete ZIP and 25 installed runtime-source
snapshots to their named origin bytes. It checks all nine new merged-source
ranges, the independently reconstructed five post-cut byte bounds, pre-cut
examples and adjacent capacity/path boundaries. The author's original 1,560
and corrected 1,623-check results remain retained; neither was replayed here.
This check supports the reviewed source argument rather than establishing
Ada semantics by counting assertions or executing example JSON.

The retained source candidate remains GNATCOLL
`1d4374ae9187fd14d42ca99a3deb0ab2ff1ebc55`, complete archive SHA-256
`945ec0ba0af2f33361ed80de7aabafa6aa8f4d4a6149896e70f2fb1c6c2ef676`.
The historical premise remains: “Candidate source behavior and current
installed config/driver bytes; no historical binary-source identity claim.”
Installed GNATprove16.1 runtime-source snapshots are source evidence too.
Matching their current origin bytes does not establish executable correspondence.

The repaired merged-file orientation is 688,428,436 bytes for post-cut Put_Line
at P416/M444. The fixed pre-cut examples are 271,693,521 bytes at P180 and
344,742,129 at P416. The sufficient malformed interval remains b<=2^30-1.
The parser-only PrecutP range becomes 2771; intersecting the accepted scalar
provider's 1927 leaves 1927. Actual configuration/path/page attachment remains
unknown. These numbers are source-function calculations, not measured maxima,
new admission limits or physical allocation promises.

No author or predecessor checker, compiler, prover, native target, inferior,
disassembler, source fetch or provider capture was run by this review. No
Oracle, production implementation, tool pin or admission rule changed.
Full #119 and production #88–#94 remain open; PR #121 remains draft/unmerged.
