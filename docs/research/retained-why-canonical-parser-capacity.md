# Canonical file reader and answer-parser representation

2026-10-23 UTC, owner-authorized #119 / #153. This separates two results:
the selected Why3/OCaml reader and direct parser callers have small source
bounds; the exact retained Re reference implementation also has bounded
representation for these callers. **Applying the numerical Re bounds to the
installed engine remains conditional on the specific correspondence below.**
Neither a short input nor the existing matching-semantics premise alone proves
that correspondence. This is not full installed-parser or whole-process closure.

The [packet](../evidence/retained-why-canonical-parser-capacity-20261023/README.md)
contains the new fixed-operand/span census, strict source witnesses and four
narrowly retrieved Re reference files. No target, solver, compiler, native
capture, Re engine or predecessor checker/model was run. It assumes the
prospective [canonical publication](retained-adapter-outcome-interface.md),
the [current-domain attachment](retained-why-canonical-json-input.md), retained
Why3/OCaml source/native relation, and ordinary physical-memory, stack and I/O
sufficiency. It adds no RAM/stack admission gate. One global `e<=2`, two
save-entering callbacks and three saves are retained over the entire continuation.

## Inputs and direct guards

Every nonempty forwarded filename denotes the complete immutable canonical
file, published after successful write/flush/close, never subsequently replaced,
rewritten or reused. Its contents are one of the retained 31 rows, at most76
bytes. This is a future adapter/proxy refinement condition, not current
production behavior. Empty-filename cancellation enters the fixed interrupted
result branch and performs no read or regexp construction. Fresh Trivial
registration is also outside this parser. The timeless combined profile has
no time/step regexps or answer-valued exitcode rules; the historical directive
JSON's time entries are removed by the accepted timing/combined-prefix provider.

| Owner, per nonempty-file parser entry | Bound |
| --- | ---: |
| Read Buffer / read scratch bytes | 1024 / 1024 |
| Returned output string / fd bytes consumed | 76 / 76 |
| Runtime input buffer / native read request | 65536 / 65536 |
| Positive input returns plus final EOF | 77 |
| Union string, cvc5 / z3 / Alt-Ergo | 401 / 247 / 243 |
| Individual regexp count, same order | 13 / 5 / 6 |
| Union Format bytes / event allowance / Buffer capacity | 401 / 64 / 512 |
| Fresh regexp records / lazy cells | 14 / 28 |
| Returned split segments / Delim segments | 8 / 4 |
| Union searches / individual searches | 5 / 52 |
| Replacement attempts, conservative caught-prefix allowance | 52 |

The accepted Q bounds count parser entries including abandoned prefixes;
`handle_answer` removes saved_data before invoking the reader. This lane does
not infer uniqueness from a possibly interrupted table resize or repair that
table. It imports the accepted occurrence/ownership provider.

| Domain | Q: reader/parser attempts | 77Q input-return allowance | 14Q constructors | 57Q searches |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 155 | 11935 | 2170 | 8835 |
| Put | 128 | 9856 | 1792 | 7296 |
| First_Or_Default | 68 | 5236 | 952 | 3876 |
| Is_Message | 8 | 616 | 112 | 456 |
| Input_Is_Valid | 5 | 385 | 70 | 285 |

These are invocation/allocation-prefix counts, not only completed publications.
At most Q new input-channel records and descriptors arise from these attempts.
The canonical path length is the separate existing `Pc=R+24` provider, where
R is actual directory length; the channel name's native copy requests `Pc+1`.
Neither R nor its path/native allocation guard is instantiated by a76-byte
file-content bound. Keep that input with the
[path provider](retained-why-report-path-inputs.md).

## Reader, offsets and failed prefixes

The selected route is `Call_provers.read_and_delete_file` (`call_provers.ml:
168–173`), calling `open_in`, **`Sysutil.channel_contents`**, `close_in`, and
then `Sys.remove` when debugging is disabled. It does not call the separate
`Sysutil.file_contents` exception wrapper and has no finally/cleanup catch.
`channel_contents_buf` creates Buffer1024 and Bytes1024, repeatedly calls
`input cin scratch 0 1024`, and appends the returned bytes. At every append,
position plus n is at most76; `Buffer.add_subbytes` does not resize. The final
`Buffer.contents` copies exactly that position. All offset+length calculations
are within1024, and the resulting copy is at most76.

On selected Linux, `open_in`'s text flag introduces no newline transformation.
The fresh ordinary-file descriptor begins at offset0. Require the canonical
file/open-description identity to remain private through this read, with no
outside seek or descriptor reuse; publication immutability alone does not
describe a separately aliased open description. The accepted file/runtime
service supplies normal read semantics. `caml_ml_input` requests the runtime
buffer size65536, not the user's1024. Since the whole file has at most76 bytes,
each successful read returns at most76 and is copied completely to the scratch
array; positive returns sum to at most76 even with arbitrary short reads.
The ordinary next read at EOF returns zero. The `int` request/result, pointer
differences, native offset addition and OCaml tagged result are represented.
No file-size probe or conversion from arbitrary raw-backend file length occurs.

`caml_read_fd` can retry after EINTR. There is no numeric attempt bound for
zero-progress interruptions; eventual return/error remains ordinary I/O
progress. The displayed77 bounds positive returns and EOF, not syscalls.
At a callback cut after read advances the fd but before the runtime publishes
the cached offset, the fd and cached offset can differ. Each stays within0..76,
and the unrecorded debt is at most76. No successful-offset equality is asserted
for that cut. An escaping exception abandons this reader; neither this function
nor its caller retries the same input channel. Returning classified clients
do not read/seek/close it; save/exit flush_all considers only output channels.

The input channel has `max!=NULL` throughout, even after close, so
`caml_ml_out_channels_list` never adds wrapper references to it. Its constructor
starts refcount0 and the sole `caml_alloc_channel` increments it to1. No growing
input-channel refcount depends on the number of exit flushes. Closing sets
curr=max=end and fd=-1 before the native close; a failed close is not rolled
back. A failed read can abandon an open fd. In this retained OCaml implementation
`caml_finalize_channel` frees the input-channel record/name but **does not close
that abandoned fd**. No descriptor cleanup guarantee is inferred from GC.
At most Q reader attempts bounds these descriptor prefixes; resource sufficiency
is still external. A failed deletion can leave the immutable file behind after
the descriptor has closed. No such prefix accumulates more bytes in this reader.

## Union formatting, splitting and answer construction

`craft_efficient_re` prints each pattern as raw string data, with two-byte
`\\(` / `\\)` delimiters and `\\|` separators. For m rules its size is
`sum(pattern bytes)+2m+2`, and it makes `2m+1<=27` string-print calls.
`Pp.print_list_delim` adds no boxes, breaks or dynamic format parsing. The
existing private Format proof applies with B401/E64, default margin79 and
Buffer512: `401+64+79<1000000010`. Fixed format/record/closure objects are
within the conservative128-word small-object envelope; explicit varying arrays
are separately bounded below. Interrupted private formatting is abandoned.

`analyse_result` constructs the union and maps all individual patterns before
`full_split`, and eagerly folds every returned segment before the later Valid
priority. Thus early Valid does not avoid parser allocation. The finite census
records exact spans for all31 rows under the already named Re byte semantics:
each answer line is one nonempty Delim, each intervening/trailing LF is Text,
and the H row is Text `!\n`. No row has more than four Delims/eight segments.
The ordinary union search takes at most five calls, including the final failed
search; every individual regexp sees at most four disjoint Delim strings whose
**total** length is at most76. Delims contain no LF. None of these patterns
matches the empty string; `search_forward_progress`'s second-search branch is
unselected. The census translates only the fixed Emacs syntax to inspect byte
spans; it is not a run of Re or of the predecessor answer-reduction model.

`grep` traverses at most m rules per Delim. Its Not_found catch covers both
search and replacement, so the bound counts replacement attempts on failed
prefixes rather than assuming one completed replacement. Replacement templates
are `\\1`, `(not unknown!)`, or empty; no selected pattern has a backreference.
Group endpoints are within the searched string or cause a checked access to
raise. Replacement length is at most76 (the fixed literal has13 bytes), and
its native/OCaml buffer/subtraction/blit operands are represented. The two-pass
replacement code can consume a callback-origin Not_found in `group_len` or
`replace`; it need not preserve normal contents, and a later checked blit can
fail if the computed allocation was shortened. This does not justify assuming
successful parsing after an exception. It also cannot enlarge the allocation
beyond the stated bound or bypass the checked blit.

Full_split's catch returns the remaining Text suffix and terminates that split
branch. A failure while constructing that suffix can reach an outer recursive
catch, discarding the deeper partial result. It does not restart from zero,
duplicate a completed Delim in the returned list or perform another engine
search. Temporary failed strings remain substrings of at most76-byte input.
List.rev/fold_right operate on proper finite cons lists. The fold adds at most
one signaled HighFailure entry; canonical ordinary completions are nonsignaled,
but allowing this extra fixed entry is conservative. Unknown concatenation
consumes distinct adjacent segments; the existing `4o<=304` payload envelope
therefore remains sufficient. Other reductions drop an element or replace two
by one. With `get_model=None` no model parser executes, saved_models stays[],
and `pr_output` stores the original at most76-byte string by reference.
Empty time/step lists do no regex/numeric parsing; the zero limits avoid their
numeric conversion branches. Int64.to_int is a defined truncating conversion.
Warning/private answer formatting remains the separate R69 owner.

## Reference Re internal representation

The reference is the same commit `f09672608781dc05172ad980a6e9a483c3b9d534`
used by the accepted response/timing papers. Previously retained Str/Emacs/Core
and eight internal files are reused. The new packet adds only Group, Mark_infos,
Category and Pmark from that exact commit, with URLs and hashes. Uncalled
debug printers, AST witness generation, general regex APIs and arbitrary regexp
inputs are outside this proof.

The fixed syntax census has no counted repetition, repeated group, backreference,
case folding, named group, Pmark or Last_end_of_line. Each repetition operand is
a single character/class; its lower/upper repetition counts are0/1. Emacs scans
at most401 pattern bytes; Parse_buffer pos/test2 arithmetic is at most403, and
its numeric `integer` helper is never called. Each bracket range lies in0..255.
Character-set union/intersection/difference retain finite ordered intervals;
their endpoint adjustment lies in-1..256. Color construction uses257 bytes,
two256-byte temporaries and a representation substring of at most256 bytes.
No special last-newline color is required. State transition arrays therefore
have at most257 words, including their metadata slot.

Compilation makes fresh IDs, group position, names and Cset-map refs. There
are at most three explicit groups in the union, plus the compiler's enclosing
group: group_count<=4 and mark indices0..7. Individual patterns have at most
two total groups. Pmark.gen is unreachable, so its module-global counter does
not receive a new bound or charge here. Mark_infos.make allocates at most8
words, and Group.t has five fields; group0/1 queries use at most indices0..3.

A deliberately loose syntactic ID ceiling is `64*(L+8)^2<=10705984` for L401.
Here is the source accounting behind it. The Emacs tree and its branch lists
have a constant number (at most eight) of nodes per consumed byte plus fixed
wrappers. Case handling preserves that tree. merge_sequences only flattens
alternatives or factors a common head; each factoring removes an original head
occurrence from a suffix, with at most (L+8)^2 original head/branch pairs. Charge
eight AST/list constructors per such pair. Translation creates at most eight
automaton expressions per resulting syntax node: repetitions only clone a
single Set expression, groups create two marks/two sequences, and other
selected cases create a constant expression/sequence. The unanchored search
prefix is covered by the eight-byte slack. This bounds cumulative Ids.next
within a compile, not just the final AST, including expressions discarded by
sequence simplification. Fixed selected grammar also bounds recursive descent;
ordinary stack/memory sufficiency is not replaced by a machine stack estimate.
The local Cset map is persistent and uses only finite syntax-derived keys;
Map node height is at most that node count, with bounded `+1`/balance arithmetic.
Hash accumulators intentionally use OCaml modular integer arithmetic, followed
by the stated masks; they are hash values, not unbounded allocation counters.

Dynamic state bounds follow from actual call operands, not the number of all
possible DFA states. A search scans at most its input length, and an unknown
transition is validated once before that position advances. A successful
validation fills that transition; an escaping failure ends the current search.
Each search has at most one initial-state lookup/add and one final boundary
delta. The absent Last_end_of_line removes that separate scanning branch.
For one fresh union, five searches of at most76 bytes give at most380 character
validations and five initial/five final operations. For one individual regexp,
the total searched length is at most76 with at most four initial/final operations.
The generous bounds402 and86 include the **same** global e<=2 consumed false
misses; there is no e budget per cache, phase or invocation. They do not require
all searches to succeed or presume a warm cache.

| Reference mutable owner | Source bound |
| --- | ---: |
| Union State.Table attempted additions / bucket capacity | 402 / 256 |
| Each individual State.Table attempted additions / capacity | 86 / 128 |
| Working_area maximum bit capacity / backing bytes | 512 / 64 |
| Each search's positions array, including growth prefix | 2048 words |
| Each State transition array | 257 words |
| Each Mark_infos array | 8 words |
| Initial/final cache lists | At most the corresponding lookup-call count |

State.Table.create97 rounds to128 and grows only after size>256;402 additions
permit at most the128→256 resize. Individual tables never resize. A descriptor
stores immutable finite expression/mark lists, a bounded index, category and
cached masked hash. Marks.set_mark removes the old same mark first; there are
at most eight different marks per marks list. Desc.set_idx assigns only the
new free index, and Working_area.free_index sees only previously generated
indices. Starting from index0, each delta can introduce at most one new largest
index. The above delta-call allowance keeps that index below402, and repeated
doubling from one keeps the bit capacity at most512. Each search creates its
positions afresh from current capacity+1 (or ten); doubling before writing
cannot require more than2048 words. Values stored in it are0..76. Description
lists/trees and marks use fixed-size blocks; their length does not become an
array allocation. Their traversals terminate: delta recursively consumes the
finite descriptor and finite automaton expression; the Rep branch processes
its child then retains a pointer to the repetition, without recursing into that
same repetition. No engine-side unbounded numeric repetition is selected.

## Catches, lifetime and correspondence boundary

Every analyse_result creates fresh regexps. Only srch is forced; mtch remains
lazy. No compile/state table is reused by a later parser entry. Lazy.force
stores a completed compiled value or a fixed closure re-raising its exception;
it does not restart a failed compilation on each Delim. A failure during that
publication can leave Undefined, which likewise does not retry. Str.state is
the one shared last-match ref, holding None or one Group. It is not a
process-wide compilation cache. A successful parser-side match overwrites it;
a failed search resets it to None. It can retain the last small input and
positions array after the other local regex objects become unreachable.
An entry that aborts before its first completed search can leave the incoming
Str.state untouched. Any such pre-existing Group remains its earlier/startup
owner's input; this note does not infer that it was already a canonical match.

The selected signal save does not call this answer parser. Its chain is
Gnat_main.save_session_and_exit→Gnat_checks.save_session→Session_itp.save_session,
then the accepted exit hooks. SV6 Shape.decoded uses **Ident.id_unique**, not
id_unique_attr/get_element_name (the latter really does call Re). save_ident
restores a path or uses id_string; explanation/checksum/shape helpers in the
accepted save closure do not call Re. The exit family is scalar Debug Stats,
Format flushing and channels, with the empty registered-stat callback list.
Thus the selected save/exit source path does not replace Str.state. Classified
returning Thread/native clients remain nonmutating under the existing callback
boundary. The at most two escaping save exceptions may still be caught by
the parser/engine; no normal-return-from-SIGINT assumption is substituted.

An interrupted Working_area reset/mark leaves scratch bits only. The next delta
resets all bits before use; completed growth changes only capacity. A fresh
positions array is made on the next search, and only successful search publishes
a Group. Cache list publication prepends fully constructed immutable values.
The individual state-table add has no resize; a prefix may publish a complete
bucket without incrementing size, but the chain stays proper and its bindings
remain bounded by attempted additions. This can undercount size, not create an
extra resize. A false Not_found in a lookup can add a duplicate valid state;
that add is already counted. Equality/hash read immutable descriptor fields,
not the status memo. Union resize interruption needs no reusable-table theorem:
add/resize is outside the table-find catch, then search_forward clears state
and rethrows Not_found to full_split, which returns its suffix and performs no
further union search. Other escaping exceptions abandon analyse_result. The
later individual-regexp loop does not alias that union table. This separates
prefix abandonment from recovery of a reused mutable owner.

The existing response premise specifies byte matching/replacement semantics.
The timing premise additionally specifies per-regexp fresh allocation/cache
independence. These supply the direct caller semantics and exclude a global
warmup dependency; they do **not alone** identify the numerical internal
representation just bounded. Actual-engine closure additionally needs its
selected compile/search/group/working-area operations and failure-prefix writes
to refine these reference representations, or an independent numerical bound
no weaker than the table above. Ordinary physical-resource sufficiency does
not supply that missing representation relation.

The retained ELF identity is24561432 bytes, SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The existing native packet retains caml_program calls to Re module entries,
including Search, Domain, Slice, Dense_map and Hash_set. It retains **no Re
function bodies**. Those names neither establish a numerical bound nor prove
a mismatch on the selected Str route. The tool recipe installs the Why3
dependency but does not pin an installed Re commit. The smallest next native
question is the selected Str compile/search/group delegation and the actual
Compile/Search state/position growth bodies; it is not a new whole-library,
startup or raw-file audit. No new native inspection was performed here.

Consequently the reader/direct-call portion is reusable now under its stated
file/path/runtime inputs. The reference representation proof is also reusable
as an exact conditional attachment. The installed Re numerical correspondence,
actual canonical directory guard, raw backend files, startup, protocol owners
and the whole #119 capacity goal remain explicit separate obligations.
