# Independent review: save-channel cached-offset bias

2026-10-20 UTC, #119 / #153, Round 34. **Accepted at the stated conditional
scope.** The initial-lseek success requirement can be removed from selected
cached-offset representation accounting. Positive-write attachment remains
false, and this is not complete file/save capacity.

Reviewer: `/root/save_path_bound_round31_20261020`, selected GPT-6 Astra /
Extra High; live runtime settings unconfirmed. The reviewer did not originate
or implement this offset-bias remedy. Review input was exact root commit
`78c6dd3f1d8a21f843e9747bd247acd4d2736b3f`: the
[I/O-service note](../research/retained-why-save-io-services.md) and all eight
files in its [packet](../evidence/retained-why-save-io-services-20261020/README.md)
(`README.md`, `check-result.json`, `check.py`, `inputs.json`, `result.json`,
`source-witnesses.json`, `standards.json`, `transfer.py`).

The review also read the accepted file/channel debt/private-client argument;
the retained `io.c` offset uses; `Session_itp.save`/`save_goal`,
`Termcode.Gshape.write_shape_to_file`, selected `compress_none` bindings,
`Format.formatter_of_out_channel`, and `Stdlib.output_substring`/`close_out`
from the existing source archives. Native correspondence and the selected
Thread/pending-action relation are inherited from the accepted Round 33
packet, not re-established by this review.

The central argument is sufficient. A fresh private regular-file description
starts at actual position zero. A successful initial `lseek(fd,0,SEEK_CUR)`
returns zero; the retained ordinary failure contract returns -1 and preserves
position. Thus fixed bias δ is exactly -1 or zero. With F the successful
committed byte count, P pending bytes and `F+P<=A<=X<=2^63-1`, a successful
write of `1<=w<=P` yields

```text
F' = F+w; P' = P-w; O' = O+w = F'+δ.
F'+P' = F+P;  -1 <= O' <= X.
```

Consequently the signed 64-bit addition cannot underflow or overflow, including
δ=-1 at F=0. Buffer copies and write arguments use pointer differences and P,
not the biased O. The selected output clients invoke neither seek nor position
nor channel-size/input operations. The shape writer emits strings/newlines;
the selected compression module aliases Stdlib. Formatter output uses only
substring output and flush, and `close_out` flushes before closing. Inspection
of all retained `io.c` offset accesses found no additional selected consumer
that requires O to equal the actual position.

EINTR retries poll before rereading P; raising write errors do not perform the
successful-write state commit. Under the inherited callback relation, no
callback splits a successful write from its offset/buffer update. A nested
flush can drain existing debt; nested saves use distinct descriptions, so
rename/truncate does not invalidate `actual position=F` for the older one.
Abandoned open prefixes retain the same debt. Closed-channel tombstones must
remain outside the live-buffer invariant, as stated. These private-client,
ordinary-service and pending-action premises are necessary and were not
replaced by a weaker assumption in the new transfer.

The zero-return example is correctly scoped: at a full-buffer `Putch`, one
zero result leaves its next store at index 65536. It refutes sufficiency of
the weaker zero-permitting local interface; eventual progress cannot fix that
store. It does not prove that any retained run reaches that state with a zero
OS return, or that Linux/virtiofs actually permits such a return. The retained
POSIX excerpts and download identities support the stated interface discussion;
this review did not fetch or independently hash the full downloaded pages.
No new positive-write attachment follows from those excerpts or sample behavior.

The retained checker result reports five cases, 20 descriptor/outcome guards,
54 positive-write boundary checks and six source witnesses, in 0.194083 seconds.
This review inspected its code/result without replay. Those checks support the
source induction; they do not prove it universally. No blocking finding or
required rework was identified. Global channel lists/refcounts, error effects,
other direct resource owners and complete composition retain their existing
owners; no collector/kernel proof obligation is introduced.

Review interval: 12:29:03–12:31:07 UTC, 124 seconds through conclusion, including
isolated-worktree setup and source reads; report writing/commit follows.
Token/cost telemetry unavailable. No native execution, source fetch,
disassembler, component-checker replay, proof run or CLI-memory update occurred.
