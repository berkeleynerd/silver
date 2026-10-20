# Save-channel offset failures and the write-service boundary

2026-10-20 UTC, #119 / #153, Round 34. The
[Round 33 file/channel result](retained-why-save-file-capacity.md) need not
require a successful initial lseek for its offset representation argument.
A failed query leaves a constant -1 bias in the runtime's cached offset;
the selected output path can safely carry that bias. The distinct requirement
that a positive-count write either makes positive progress or interrupts/raises
remains unjoined. This result does not establish complete file/save capacity.
The [packet](../evidence/retained-why-save-io-services-20261020/README.md)
retains the source join, arithmetic interface and precise scope.

## Failed initial query does not threaten offset arithmetic

The inherited selected-file relation supplies a fresh regular-file descriptor
whose actual offset starts at zero, private output clients, no append/seek
operation and the named faithful service semantics. `caml_open_descriptor_in`
stores `lseek(fd,0,SEEK_CUR)` directly (`io.c:94–124`). Under ordinary lseek
semantics, success returns zero; failure returns -1 without changing the
actual offset. Thus its initial cached result is δ∈{-1,0}. No successful
initial query is assumed or observed.

Let F count the bytes actually committed by successful writes through this
description, P the buffered bytes and A the bytes offered so far. Preserve

```text
0 <= P <= 65536
0 <= F, F + P <= A <= X <= 2^63-1
cached offset O = F + δ, where δ is fixed in {-1,0}.
```

The actual descriptor position equals F. A reached positive write commits
1≤w≤P bytes. `caml_flush_partial` adds w to O and subtracts w from P;
therefore F becomes F+w, debt F+P is unchanged, and O remains F+δ.
Every cached addition lies in [-1,X], including an error-initialized channel.
No multiplication or pointer address is derived from that cached value in
the selected output operations. The direct read/copy/flush clients use the
buffer pointer and length, not O, to select write arguments.

The already accepted pending-action and ownership argument still applies:
pending actions run before the flush rereads P, and no selected callback
intervenes between a successful write and its state commit. EINTR and raising
errors perform no successful-write commit. Separate nested saves retain
separate descriptions; renaming or truncating a path does not change another
description's offset. The closed-channel tombstone remains excluded from live
buffer debt. This refinement changes the cached-offset lower bound, not any
offered-byte or buffer bound.

`channel_size`, `seek_out`, `pos_out` and input operations read or reset cached
offsets in other ways. They are distinct routes in the retained source and
are absent from the accepted private save-channel clients. This lemma does
not extend to those routes or assert that a cached position query would report
the correct offset after failed lseek. Ordinary return semantics, private
descriptor ownership, valid roots and the existing native/source relation
remain external premises; successful lseek is removed from the capacity
requirements rather than replaced by a new success assumption.

## Positive write progress is still a separate obligation

The selected macro calls `caml_flush_partial` once when its buffer is full,
then stores the character. A zero return for a positive full-buffer request
leaves P=65536, so the next store has index 65536, outside the buffer.
One zero return followed by future positive returns is sufficient to defeat
this path under the weaker 0≤w≤requested contract. Eventual progress does
not repair it. This is a countermodel to that weaker interface, not an
observed failure of the installed OS or a claim that the selected filesystem
actually returns zero.

The installed release does not enforce the source's positive-count assertion.
The older materializer's explicit zero rejection belongs to a different loop.
The general trusted-boundary phrase “functioning services” and a successful
sample write cannot supply a universal property of every selected call.
The inspected POSIX return-value wording supplies the upper bound; its
descriptions of full media and signal interruption specify errors in those
cases. This packet makes no deduction that they exclude every zero-progress
outcome. It therefore retains the explicit positive-write premise and its
actual attachment as open. A normative selected-interface contract that
requires the property could close this join without proving the whole kernel.

Two official POSIX.1-2024 pages were read for this specific question:
[lseek](https://pubs.opengroup.org/onlinepubs/9799919799/functions/lseek.html)
and [write](https://pubs.opengroup.org/onlinepubs/9799919799/functions/write.html).
URLs, download identities and short excerpts are retained. The current Linux
checkout is on a virtiofs shared mount; neither that observation nor the Linux
version identifies a particular underlying storage implementation or proves
its service behavior. No kernel/filesystem-source correspondence is claimed.

## Composition and validation

Both possible initial outcomes pass the signed-offset guard for both
descriptors in all five retained processes. The maximum shape-file extent
remains 459,543,692,845,491,887 bytes, below the signed 64-bit ceiling. The
new checker compares retained inputs and six source excerpts, exercises
positive-write prefix boundaries including the signed limit, and retains
the zero-return interface countermodel. It does not execute a target or
replay predecessor checks; the finite cases corroborate the induction above.

The reviewer suggested separating actual committed bytes from the cached
offset during Round 34; the lead integrated the source argument and transfer.
Independent review must retain that contribution transparently. Global channel
lists/refcounts, allocation/GC/stack, failed-service error effects and complete
save/pipeline composition remain outside this lemma. Default usable whole-file
bounds remain null without the positive-write contract. Oracle, production
admission, installed tools/pins and #88–#94 are unchanged.
