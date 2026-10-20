# Conditional native bridge for the server buffer shift

2026-10-20 UTC, #119 / #153, Linux x86_64. Base
`a6d848598c0d1a7cfa15ac554c25c37a79bef6e9`; selected GPT-6 Astra / Extra High,
not runtime-confirmed. This answers the independent review's `readbuf.c`
overlap question without changing tools or proving libc's implementation.

**The exact installed `have_taken` calls `memcpy@GLIBC_2.14`. In the matching
retained libc, that symbol's resolver selects exactly the same implementation
as `memmove@GLIBC_2.2.5`, for the same stable resolver inputs.** Under an ordinary
noninterposed binding to this exact libc, the existing trusted memmove service
therefore supplies the required overlap-safe native shift. This is a
conditional deployment attachment; the historical server's loaded libc and
resolved GOT target were not recorded and remain null.

The source's overlapping `memcpy` is still outside the generic C memcpy
contract. There is no claim that a source-level undefined operation is valid,
that an overlap or corruption was observed, or that this witnesses universal
compiler/binary refinement. The
[packet](../evidence/retained-why-server-buffer-copy-20261020/README.md)
retains exact identities, commands, instruction bytes and the resolver comparison.

## Exact call and identities

The Why3 source candidate is revision
`9390baf120ef260547dfa14f08e11c890b203d9c`. Its `readbuf.c:45–49` defines
`have_taken`, the consume operation:

```c
assert (size <= b->len);
memcpy(b->data, b->data+size, b->len - size);
b->len -= size;
```

The client processing loop calls it with the consumed prefix `old` only when
old>0. For `0<size<len-size`, the remaining source and destination ranges
overlap. Ordered socket reads do not establish that this later in-process copy
preserves them. The symbolic possibility is sufficient to require a contract;
it is not a recorded execution of overlapping data.

The selected installed file is the recorded `libexec/spark/bin/why3server`,
96,904 bytes, SHA-256
`143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80`.
It matches the retained `registration/put_line/capture/server.json` binary
identity (server PID 17299); this server is distinct from Why PID 17310.
The metadata records actual environment PATH=/usr/bin:/bin and LC_ALL=C, but
does not record server library maps, IFUNC features or a GOT read.

The 82-byte `have_taken` body at ELF address 0x2fdb checks unsigned size<=len,
loads data as destination, computes source=data+size and count=len-size,
and calls 0x2590 at instruction 0x2ffe. On return, instruction 0x3003 subtracts
size from len. The failed check calls `__assert_fail`. No copy is inlined and
no call to memmove was substituted. The 16-byte PLT entry at 0x2590 jumps through
GOT slot 0x7f00; its R_X86_64_JUMP_SLOT relocation selects the undefined dynamic
symbol `memcpy@GLIBC_2.14`. DT_NEEDED names libc.so.6.

The currently installed `/usr/lib/x86_64-linux-gnu/libc.so.6` is 2,190,608 bytes,
SHA-256 `85e64f97e348786a8fb4d9f3d52fec289e2fb86bba20f0731dfe61990525e0f7`.
This exactly matches the already retained native-effect provider identity.
That provider's Why process image observation does **not** become a historical
server image observation merely because both processes ran on the same host.

## Bounded resolver comparison

In that libc, memcpy@@GLIBC_2.14 is an IFUNC resolver at 0xb8c80 and
memmove@@GLIBC_2.2.5 is an IFUNC resolver at 0xb9600. Each is 257 bytes / 58
disassembled instructions. The checker compares all bytes against their ELF
load segments, then compares their complete instruction sequences as follows:

- All instructions except RIP-relative loads/address calculations have
  identical bytes at identical relative offsets. Short branch displacement
  bytes match, and every branch target is checked as an instruction offset
  inside the corresponding body.
- For the only three RIP-relative opcode forms present, it independently
  decodes the signed displacement and computes the absolute target. Both
  opcode prefixes and computed targets must match; merely erasing the
  displacement would be insufficient.
- The initial load uses the same `_rtld_global_ro` slot, 0x211eb8. Subsequent
  tests read identical offsets and masks. Register updates, conditional moves,
  returns and control flow therefore agree for the same resolver input state.

The complete set of address-valued return candidates is:

```text
0x0c2280  0x0c22f0  0x0c2380
0x197970  0x197a00  0x1a03f0  0x1a0480
0x1a78f0  0x1a7980  0x1b0970  0x1b0a00
0x1b2c10  0x1b3640
```

The two resolvers choose the same candidate under the same feature/tuning
state; this is stronger than equality of the unordered candidate sets. No
particular candidate was observed being selected in a server process. These
target bodies were not re-proved: their behavior is supplied through the
existing trusted memmove interface for represented valid requests and
sufficient resources. No new libc source fetch, source-wide audit, execution
of a resolver or runtime copy experiment was performed.

## Conditional interface and the remaining join

For the native service bridge require:

1. The exact server and libc identities above, ordinary ELF versioned-symbol
   and IFUNC resolution, no overriding/interposed copy symbol, and the same
   stable loader feature/tuning data used by the compared resolvers. Absence
   of LD_PRELOAD in one environment alone does not prove all these facts.
2. The usual trusted memmove behavior for the selected implementation: given
   valid live readable source and writable destination ranges of n bytes,
   copy the original source bytes as if through a temporary buffer, including
   overlap. The implementation's internal resource costs remain external.
3. The server's separate source/native ownership and arithmetic premises:
   data owns a live allocation, `0<size<=len<=capacity`, both computed ranges
   lie within it, and the native representation supports those computations.

The two ranges then fit the original allocation. The post-copy bytes
`data[0:len-size]` equal the original `data[size:len]`; the following native
subtraction sets len to len-size. This supplies the single shift-preservation
step needed by a request-stream induction. It does not prove the rest of the
server parser, client/ID bounds, liveness, malloc/realloc behavior, buffer
growth, stack or total server capacity.

For a prospective fixed deployment, binding this named binary/libc/loader
profile is a concrete configuration and source-correspondence obligation.
For the retained server executions, the exact loaded-library/GOT attachment
remains missing: `historical_server_loaded_libc`, `historical_server_GOT` and
`selected_runtime_target` are null in the result. The current server source
packet must therefore keep stream preservation conditional on this interface.
No new capture is requested here, and no arbitrary current PID is substituted
for the historical process. Extending to another libc/build requires its own
relevant behavior attachment or an authorized source/tool change; the generic
memcpy contract cannot fill the gap.

The focused comparison checks 612 instruction bytes, the ELF call/PLT/
relocation chain, two complete resolvers and 13 return candidates. It is
read-only evidence checking, not a loader/libc proof. Oracle, installed tools,
source pins and admission are unchanged. #119/#153 remain incomplete;
production #88–#94 remain unstarted and PR #121 remains draft/unmerged.
