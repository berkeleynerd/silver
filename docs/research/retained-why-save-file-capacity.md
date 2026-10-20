# Selected save filenames and channel extents

2026-10-20 UTC, #119 / #153 Round 33, Linux x86_64. Base
`2cb11d8b5dcb7146694103616d1abea13ab8808d`.

The five selected saves fit the filename, output-argument and signed 64-bit
file-offset representations under the named source/runtime, upstream extent
and normal POSIX service relation **plus an explicit positive-write progress
contract**. That extra contract is required below and is not derived merely
from POSIX's return-count wording. Its actual service attachment remains open.
The argument counts each newly
opened descriptor separately, including nested saves and abandoned prefixes.
It does not treat successful file delivery as evidence of capacity, and does
not establish complete save, global exit-channel, allocator/GC or error capacity.

## Filename and native allocation extents

`session.session_dir` is an immutable string field (`session_itp.ml:131`).
Its retained per-process lengths are 19 / 14 / 34 / 28 / 32 bytes, ordered
Put_Line / Put / First_Or_Default / Is_Message / Input_Is_Valid. The
[fresh-state join](retained-why-save-state-join.md) attaches those lengths to
the five later captures. They are not silently replaced by the absolute-path
claim in an adjacent source comment.

`save_session` constructs `why3session.xml`, `why3shapes` and `why3shapes.gz`
with `Filename.concat`, backs up each, and selects the uncompressed shapes
name. `Compress_none` aliases Stdlib for both exported modules. The longest
basename has 15 bytes; Unix concatenation adds at most one slash and backup
adds four bytes. Thus every filename is at most Ddir+20 bytes, at most
**39 / 34 / 54 / 48 / 52** in these processes. The existing selected-host
[PATH_MAX=4096 and NAME_MAX=255 contract](retained-literal-native-materialization.md)
covers the complete relative syscall argument including NUL and each component.
No canonical absolute path needs to be materialized to use a relative argument.
Input identity, directory existence and filesystem access retain their separate
external contracts; arbitrary external replacement with a special file is
outside the selected fresh regular-file relation.

The two binary concatenations in the nonempty, non-separator branch of
`Filename.concat` cannot have an intermediate longer than the resulting name.
Stdlib `(^)` adds the two lengths, allocates one string and copies their ranges.
All additions/offsets fit the native string/int representations at these small
lengths. At most nine string blocks are requested per save: two per filename
plus one per backup. A block for a string of length L needs
`8*(1+floor((L+8)/8))` bytes including its header. Failed allocations are counted
as attempted requests; allocator-internal costs remain separate.

`Sysutil.backup_file` performs at most two existence tests, one removal and one
rename per filename. Stdlib opens exactly two channels, both with write/create/
truncate flags. Per save this gives six existence tests, three removals, three
renames and two open attempts. Unix runtime wrappers copy one C pathname for
each existence/removal/open, two for each rename, and one channel name per
new channel: at most **19 C copy requests** per save, each at most Ddir+21
bytes including NUL. A failed prefix or missing original file only reduces
these counts; neither backup nor the channel wrapper retries the OCaml caller.
Pending actions inside blocking-section entry retain the same existing copy.
Diagnostic strings created after an error are a different owner.

Installed `caml_open_descriptor_in` requests **65,616 native bytes** for its
channel, including its **65,536-byte buffer**. The retained instructions attach
the buffer at offset 72, end at offset 65,608, and an eight-byte file offset at
offset 8; `lseek64` supplies the initial offset. Across the one global budget
of three saves, at most six new descriptors/channel structures are attempted,
requesting at most **393,696 native channel-record bytes**. Additional custom
wrappers, channel mutexes, native allocator metadata and global-list traversal
are not included in that subtotal.

## Per-descriptor debt and partial writes

Each reached fresh regular-file `open_out` starts a separate open file
description at offset zero; the selected Unix mode performs no text expansion.
The channel's cached O=0 also requires the named normal `lseek` service to
return zero: `caml_open_descriptor_in` stores its result without testing -1.
The wrapper itself does not prove or check that service success.
XML and shape channels remain private to the save's formatter/context and its
fixed synchronous callbacks. Other selected saves open their own channels.
The public global channel list exposes existing channels only to the classified
flush/cleanup clients, which do not append new save text or seek these channels.
The valid native lifetime/root relation prevents freeing a channel still used
by a rooted caller. These ownership facts, not filename inequality, are needed.

For an open channel let O be its committed offset, P its currently buffered
bytes, and A the number of source bytes offered to this descriptor so far.
The induction is `0 <= P <= 65536` and `O+P <= A <= X`, where X is that
descriptor's XML or shape extent. After a partial copy/flush, not all source
bytes may have been accepted; the inequality permits that prefix.

`caml_putblock` clamps a source request to INT_MAX before conversion to C int,
then copies at most available buffer space. This includes an argument larger
than INT_MAX: successive iterations use represented intnat positions/lengths
within the original string. The source string is rooted and its pointer is
recomputed on each iteration after potential GC. `output_substring` checks its
range before the native call. The existing formatter/shape source owners supply
valid whole-string/range arguments, separately from the file-size bound.

`caml_flush_partial` calls `check_pending` **before** reading `curr`. That helper
unlocks the channel while processing pending actions and reacquires the lock.
A nested `flush_all` may drain existing bytes. On return, the outer flush reads
the resulting buffer state, so it does not count those bytes again.

After that read, `caml_write_fd` uses `caml_enter_blocking_section_no_pending`.
The selected native Thread hook releases/reacquires runtime state; it supplies
no OCaml preparation/output callback. `caml_leave_blocking_section` records
pending signals for a future poll rather than dispatching them. Under this
accepted hook/one-worker relation, no OCaml callback occurs between a successful
write and its offset/buffer commit. Retained native instructions corroborate
that route and the 64-bit offset addition.

For a positive-count write the additional service contract requires either
`1<=w<=towrite`, the EINTR marker, or the raising error path. This is necessary
for the selected character writer: `Putch` calls `caml_flush_partial` only once
when the buffer is full, then writes a byte. A zero return would leave it full.
The retained `caml_write_fd` has no active assertion rejecting that zero;
neither a string-output loop nor the older native parent's checked write loop
repairs this character path. Zero-return behavior is outside this conditional
lemma and remains a named service frontier, not assumed impossible by the
Python checker.

For `towrite<=65536`, a positive return w satisfies `w<=towrite`, so its
narrowing to C int is safe. The runtime adds w to O, shifts any remaining bytes
with a bounded memmove and subtracts w from P: debt is conserved. EINTR returns
the interruption marker before any offset addition; the next pass polls and
rereads the buffer. The EAGAIN retry reduces the request to one byte without
growing state. Other errors raise before the successful-write commit; their
diagnostic allocation/callback paths remain separately owned. Successful writes
are bounded in count by offered bytes. No finite bound on all interrupted
polling attempts is claimed, and that loop has no growing direct
native stack frame per iteration.

Nested backup/rename/truncate operations can change which path names an inode
and can truncate it while an older descriptor is live. They do not merge the
independently opened descriptions or increase an older descriptor's offset.
There is no selected seek or append route for these channels. Each descriptor
therefore retains its own bound. This is not a claim that the final file is
complete, useful, or equal to the last save's intended serialization.

`close_out` flushes, then sets fd=-1 and curr=max=end before/while closing.
That **closed tombstone** is not interpreted as 65,536 newly buffered bytes.
`caml_ml_flush` returns immediately for fd=-1, and the channel-list iterator
excludes closed channels through max. Selected callbacks do not close another
save's private live channel. An abandoned open channel may retain pending bytes;
later flushing can only drain that same debt.

## Actual arithmetic and remaining owners

XML extents come from the accepted
[Round 32 path/input composition](retained-why-save-path-input-join.md). Shape
extents reuse the [operational transfer](retained-why-save-operational-bounds.md)
and its fresh-state attachment, including dictionary strings, current/old
shape text, checksum and header/newline contributions. Their upstream validity,
normal numeric services and global continuation budget remain explicit.

| Case | XML bytes per descriptor, upper bound | Shape bytes per descriptor, upper bound |
| --- | ---: | ---: |
| Put_Line | 588,599,398 | 459,543,692,845,491,887 |
| Put | 490,581,822 | 295,636,510,136,143,316 |
| First_Or_Default | 303,447,466 | 4,033,425,430,835,237 |
| Is_Message | 44,645,930 | 11,850,662,528,646 |
| Input_Is_Valid | 53,513,166 | 27,551,815,185,207 |

Each bound fits signed 64-bit file_offset. Every offset addition and buffered
position sum is a prefix of that descriptor's bound; no aggregate across
descriptors is stored in a native counter. The deliberately loose shape-file
bound does not mean one string has that length. Its longest individual offered
string is bounded separately by the dictionary/shape/string inputs, and fits
the native string representation. The packet derives both guards independently.

The [packet](../evidence/retained-why-save-file-capacity-20261020/README.md)
checks retained source ranges/native bytes and derives the five arithmetic
applications. Missing external premises leave usable outputs null. It does
not run a target, disassembler, observer, solver or predecessor checker.
The result without an attached positive-write contract remains null even when
the other named premises are supplied. This conditional component does not
silently add that service restriction to the completed #119 guarantee.

Global exit-channel list/cardinality/refcount, extra custom wrappers and mutexes,
all allocator/GC/stack owners, syscall error construction and diagnostic/exit
effects remain unfinished. In particular the new-channel count does not bound
all previously open channels or every `out_channels_list` wrapper. POSIX service
semantics and physical resource availability are distinct from the proved
representation inequalities. No service success was newly observed. Oracle,
admission and installed tools/pins are unchanged; #119/#153 remain incomplete,
production #88–#94 unstarted and PR #121 draft/unmerged.
