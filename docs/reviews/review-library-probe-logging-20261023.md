# Library-probe pathname and logging capacity review

2026-10-23 UTC, #119 / #153. Both frozen conditional interfaces are accepted:

| Interface | Reviewed commit |
| --- | --- |
| Complete raw library-probe paths and local construction | `669f5743db60393a7f2b8c39c75605923d525ab7` |
| Selected J12 logging formatter/channel | `0f048d9f4f2db9660c5877c79bb404ee7005d364` |

The [independent audit packet](../evidence/retained-library-probe-logging-review-20261023/README.md)
passed **7,508 checks in 2.819383 seconds**, on its first run. It pins 26 author
files and 38 providers, checks 86 strict source ranges across 41 complete
source members, reconstructs all 80 candidate spellings, and verifies 2,888
native instruction rows across 12 functions plus three literal blocks. No
unresolved material finding remains in these interfaces. The successful audit
was not repeated.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime setting confirmation
and token/cost telemetry are unavailable. Review base is the accepted R69
integration `71b88c7959483839a1d9ae0e6d388a5df6754237`. Existing successful
results were reused without author/predecessor-checker replay. The reviewer
ran no disassembler or target executable. The path author performed a narrow,
explicitly recorded target-free native extraction; this is new byte evidence,
not a new process capture or native execution result.

## Review questions and disposition

**LP1 — exact generated-value attachment: resolved before freeze.** Reading
Config's native concatenations alone would leave Sys.executable_name unbound.
The final provider attaches each collector's resolved `/proc/PID/exe` value,
the exact mapped ELF and argv, Linux's `/proc/self/exe` branch, and the absolute
argv fallback. Filename's selected Unix dirname slot and Whyconf's actual
Config-field consumer are also attached. No value is inferred merely from an
ELF pathname or an ASCII substring.

**LP2 — callback occurrences after partial mutation: clarified before freeze.**
The logger count must use physical queue/list occurrences, not distinct hash
keys or an assumed persistent association. Final terminal dispatches are
bounded by accepted N<=Q result publications and a result-buffer transfer that
finishes before dispatch; failure leaves the timeout/main-loop continuation.
The queue argument separately bounds physical cells through fold/clear/rebuild.
Removal-before-callback is supporting control evidence, not a new theorem that
all interrupted hash-table mutations preserve unique bindings.

**LP3 — local allocation scope: clarified before freeze.** The path's 870-word
bound is for routine-owned direct managed requests, including intermediates and
failed prefixes. It excludes runtime/GC service internals and separately
charged signal/save callbacks. It is neither process peak RAM nor an allocation
bound for the entire nested call chain.

These were completed proof attachments and scope clarifications; no defective
execution was reproduced. A separate source inventory found `sexp`, omitted
from R69's explicitly undischarged raw-path domain. R70 explicitly corrects
that provisional enumeration to five extensions. R69's diagnostic-path result
and warning refinement do not change.

## Complete raw-path provider

Each current capture's process record was produced by the retained collector
using the resolved `/proc/PID/exe`. Its string equals the actual absolute
argv[0] and the pinned mapped gnatwhy3. OCaml's Linux startup first reads
`/proc/self/exe` and validates a regular target; if that returns NULL, path
search sees the slash in absolute argv[0] and copies it unchanged. Under the
retained installation/source/native/service relation, both successful routes
therefore yield the same executable name. This is not a failed-startup theorem.

The generated Config implementation is absent from retained source. Its
280-byte native entry calls the selected dirname closure twice, appends the
static OCaml strings `share` and `why3`, and stores field 0x18. The reviewed
Filename initialization selects the Unix wrapper and places dirname in slot
0x68. Whyconf's native initialization reads that Config field into datadir.
The native string-block proof checks headers, padding and exact bytes. The
independent audit maps addresses through ELF load segments and checks symbols,
function bytes, raw disassembly responses, decisive stores/allocation operands
and literal blocks; it does not import the author's ELF reader or re-disassemble.
Source/native semantics remain the existing trusted correspondence, rather
than a proof produced by those byte comparisons alone.

The source/configuration join supplies exactly four immutable directories,
with byte lengths **147, 146, 134 and 145**: the two Why3 theories/modules
paths, SPARK theories, and generated datadir/stdlib. All complete base configs
and overlays are attached to their actual ordered opens. They contain no
main datadir/loadpath/stdlib override; the controlled environment has no
WHY3DATA/WHY3LOADPATH. The selected overlay merge changes provers/editors/
shortcuts, not the base main record. No proof-directory option prepends another
path. Env.create_env stores the four distinct strings in an immutable Sstr set.

The complete selected extension registry is **adb, gnat-json, mlw, sexp, why**.
The source census, linked initialization calls and mapped plugin identities
jointly establish this set. Lexer and Sexp_parser initialize the three linked
extensions; the selected explicit gnat_json/ada_terms plugins add the other
two. Generic plugin scanning and other parser modules are unselected, and no
selected suffix writer registers another format. Parent-language propagation
adds no new extension key. Merely registering sexp does not execute its parser
or introduce its location constructors into diagnostics.

Accepted producer ownership supplies the singleton logical bases int, real,
algebra and relations. Four directories times five extensions give **20
candidates per lookup**, and all four bases give **80 complete possible
spellings**, including nonexistent paths. The largest pathname is **167
bytes**. Successful-open observations alone would not establish this domain.

## Path construction and failed prefixes

The local source accounting includes basename and the empty-prefix logical
fold, both right-associated concatenations for each extension, and both
concatenations for every directory/candidate. There are at most 52 new string
blocks per lookup. Independent arithmetic gives:

| Base | Maximum path bytes | String payload sum | String allocation words | C-copy request sum |
| --- | ---: | ---: | ---: | ---: |
| int | 161 | 3,311 | 500 | 3,068 |
| real | 162 | 3,358 | 505 | 3,088 |
| algebra | 165 | 3,499 | 515 | 3,148 |
| relations | 167 | 3,593 | 525 | 3,188 |

The representation counts include headers and string padding. The largest
single managed string occupies 22 words. The local list bound is 98 new cons
cells, including extension/path keys, both levels of map, flatten's copied
spines, and filter's worst-case accumulator plus reverse. Each spine has at
most 20 cells. Fixed closure requests are 47 words: two four-word Env captures,
four five-word directory partial applications, a nine-word basename closure
group and ten words for find_all's two closures. Native allocation sites agree
with this decomposition. The largest result exception adds four words. Thus
**525+98*3+47+4=870 routine-owned direct managed words** suffices per call.
No final live-list size is substituted for cumulative construction.

All concatenation sums, substring endpoints, byte indices, list lengths and
string-header operands are represented. The finite traversals decrease a
proper list/tree or basename index. Sys.file_exists checks C safety first;
Linux's OS conversion is a plain duplicate with a NUL byte, at most **168
bytes per request** and **3,188 requested bytes per invocation**. No Windows
or locale expansion is imported. Failed stat returns false; zero or multiple
matches take their existing scalar exception branches. A failure after native
duplication can bypass free, so the accounting charges that request without
assuming reclamation. There is no local retry restarting all candidates.

These are per-invocation direct-request and representation interfaces. Global
locate-call multiplicity stays with the producer; physical allocator/GC and
stack sufficiency remain trusted. Full FileTags or other global counter/table
capacity is not proved by a pathname-length bound.

## Logger sources, multiplicity and private formatting

The selected logger has one pre-cut init site and one parallel-callback writer.
Its private output ref is replaced from stdout by the successfully constructed
fresh regular-file channel before registration and before SIGINT installation.
Accepted R55/R69 control transfer gives **P0=O0=0**, a 65,536-byte native buffer,
a 65,616-byte channel record and one rooted wrapper. Registration emits no
logging entry. This transfers an accepted constructed state; it is not a new
fd observation or a failed-startup claim. Debug/GNATWHY3LOG, diagnostics and
reports use their separately owned destinations.

For accepted scheduling-owner Q, Scheduled contributes at most Q logs,
build/idle error callbacks at most 2Q, consumed terminal result publications
at most Q, and valid-Done queue-interruption traversals at most Q². Build's
inner Sys_error callback may fail into the outer idle catch once; the latter
handler is outside its own trap. Blocking result collection filters Running.
Editor/replay/general Controller.interrupt clients are unselected.

Each cancellation fold follows a snapshot's already-read next links. Its
Interrupted callback logs and falls through without recursively scheduling
or cancelling. A completed clear/rebuild inserts each nonmatching survivor
once. Failure before clear retains the old chain; failure during rebuild leaves
a prefix and escapes the timeout/main-loop continuation. No receiver resumes
that discarded rebuild. Returning selected clients do not mutate the queue.
Physical population therefore remains at most the Q original queued owners;
charging Q visits on every possible valid-Done traversal includes repeated
notifications after a previous incomplete clear. This establishes **H=Q²+4Q**
without deduplicating interrupted publications.

The returned attempt record supplies the prover name. All nine configured
names have at most eight bytes, and synthetic Trivial has seven. Their creation
origins and the sole unselected replay/upgrade mutation retain this bound even
if a lookup returns another stored record. The record's other payload fields
are a signed-native goal ID (20 bytes), one of ten status strings (15), one of
eight answer strings (17), and at most two %f outputs (317 each). Arbitrary
solver/error strings are dropped. Keys total 39 bytes, so key/value strings
sum to at most 99. The largest two-record/seven-field shape gives B=1266 and
E=238, covered by the exported **B=1280, E=256 per entry**.

Every entry creates a fresh default-margin formatter on the existing channel.
The single-line serializer emits only known-size text after the system box;
it has no user boxes, break hints, tags or layout-generated indentation. Actual
Format offers are therefore bounded by B, without an additional 70E allowance.
A direct newline adds one byte. There is **no formatter flush and no Buffer.t**:
channel flush cannot drain a discarded private formatter queue. This capacity
result does not establish complete or valid JSON lines and changes no behavior.

The small source graph, scalar/layout instances and fixed closure objects reuse
accepted R67/R69 representation arguments. Fresh core totals stay small; the
local sufficient guard is 1280+256+79=1615. Escaping failure abandons that
formatter, while any caught subsequent callback creates a different one.
The persistent channel's debt is never reset with the private formatter.

## Logger channel and conditional boundary

The total channel offers are **X=1281H**:

| Case | H | X bytes |
| --- | ---: | ---: |
| Put_Line | 24,645 | 31,570,245 |
| Put | 16,896 | 21,643,776 |
| First_Or_Default | 4,896 | 6,271,776 |
| Is_Message | 96 | 122,976 |
| Input_Is_Valid | 45 | 57,645 |

Instantiate the accepted generic debt theorem on this actual channel:
`0<=P<=65536`, `F+P<=A<=X`, and cached offset `O=F`. All offsets remain below
2^63-1. The process-global six flush_all attempts add no source bytes and give
at most six temporary wrapper increments; the rooted channel's refcount bound
is seven, below C INT_MAX. Closure references do not add native refcounts.

The **log-specific** service/lifetime attachment is essential. Each valid
positive write request must return a positive count no larger than its extent,
error/raise before the success commit, or not return. The save contract is
restricted to XML/shape files; its behavior is not silently inherited by the
logger. A zero successful count retains the known full-buffer countermodel.
The log descriptor must remain live with its selected service profile; a
private pathname alone proves neither descriptor independence nor delivery.
Pending actions run before debt is read, returning clients do not mutate the
channel, and a mutating save/exit callback exits or raises out of the suspended
caller. The native successful-write/offset/shift/debt commit has no selected
OCaml mutator. These are explicit existing/native and log-specific premises,
not properties established by the finite check.

Unix.gettimeofday must also initialize the valid output structure when the
selected call returns: its source wrapper ignores the status. Scalar printing
covers special floating spellings; finite JSON-number semantics are separate.
Short writes and failures remain allowed. Successful commits are bounded by X;
syscall attempts, cumulative requested syscall bytes, eventual delivery and
actual file extent are not established by the cached-offset theorem.

One global e<=2, two save-entering callbacks and three saves remain shared.
No aggregate RAM/stack gate, Oracle amendment, tool/pin/admission change or
production implementation is introduced. The reviewer made no GitHub,
publication, harness-state or CLI-memory write; the live harness goal was null.
Root composition, remaining FileTags/global owners, raw solver q, startup/full
grammar and whole #119/#153 assurance remain separate obligations.
