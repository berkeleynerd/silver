# Stock request storage operands

New R56 source/native operand reconciliation for #119 / #153. The
[argument](../../research/retained-server-request-storage.md) derives copied
field, request-record and argv allocation sums, plus a computable receive
buffer majorant and its arithmetic guards. Request lengths and argument counts
remain configuration/source operands to attach; this is not complete q.

`inputs.json` pins the retained source archive, R55 count result and existing
overlap-copy bridge. `source-witnesses.json` retains ten exact excerpts.
`native-inputs.json` and `installed-disassembly.txt` retain four installed ELF
bodies, including the actual 56-byte request and eight-byte argument operands.
Disassembly text has trailing whitespace removed; instruction bytes remain
exact in the JSON witness. Static disassembly did not execute the target. The system PATH had no objdump;
the recorded installed toolchain objdump was used instead.

Run `python3 docs/evidence/retained-server-request-storage-20261020/check.py`.
The check verifies identities/instruction bytes and the new arithmetic at field
and receive-growth boundaries. It does not execute predecessor checks, the
server, a compiler, a solver or a proof engine. Source semantics, valid stream
preservation, ordinary services and the receive-copy bridge require their
separate arguments and review. Independent review/integration remain pending.
