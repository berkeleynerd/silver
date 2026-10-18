# Retained assembler shared backing

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This extends the [selected null Main assembler transfer](retained-assembler-capacity.md)
to shared GAS obstacks and frame-state requests. It uses the same retained
Binutils commit and selected LP64/configuration premises. No compiler,
assembler, linker or prover was executed. The
[offline evidence](../evidence/retained-assembler-capacity-20261018/README.md)
retains the declarations, allocation sites and arithmetic.

The result bounds individual requests and the arithmetic used to grow them.
It does not impose an aggregate RAM limit or complete the fixed parser,
opcode/hash and BFD initialization inventory. Allocation success, pointer
placement and installed-source correspondence remain explicit premises.

## Frame and subsection objects

The prior transfer gives thirteen fragment chains, thirteen cached segment
information objects, twelve CFI instruction nodes, one FDE and one per-chain
CFI state. Its ordinary ELF CFI serializer creates at most one CIE. Charging
the optional SFrame path gives six rows, one function descriptor, one
translation context and one pointer in the FDE-symbol array.

These selected LP64 ceilings follow from the retained field declarations;
they are not native `sizeof` measurements:

| Object | Count, at most | Raw bytes per request, at most | Allocator |
| --- | ---: | ---: | --- |
| `frchainS` | 13 | 192 | `frchains` obstack |
| `segment_info_type`, including x86 state | 13 | 128 | `notes` obstack |
| `cfi_insn_data` | 12 | 96 | `notes` obstack |
| `fde_entry` | 1 | 224 | `notes` obstack |
| `frch_cfi_data` | 1 | 32 | `notes` obstack |
| `cie_entry` | 1 | 128 | direct heap |
| `sframe_row_entry` | 6 | 128 | direct heap |
| `sframe_func_entry` | 1 | 64 | direct heap |
| `sframe_xlate_ctx` | 1 | 64 | direct heap |
| SFrame FDE-symbol pointer array | 1 | 8 | direct heap |

The obstack control structure fits 88 bytes. A fragment-chain object has
eight pointers, one four-byte subsection number and that embedded control
structure, fitting the conservative 192-byte ceiling. Segment information
has five pointers, flags, an eight-byte union and the 40-byte x86 extension;
the selected x86 target has no literal pool (`include/obstack.h:163–198`,
`gas/subsegs.h:45–111`, `gas/config/tc-i386.h:289–306`). `alloc_seginfo`
initializes it once; later section changes reuse the cached object. All
selected subsections are zero, so the x86 section-change hook immediately
returns and allocates no subsidiary subsection-state nodes
(`gas/subsegs.c:70–97`, `gas/config/tc-i386.c:18799–18829`).

The CFI node's largest union member contains two unsigned fields and one
at-most-40-byte expression. The FDE includes two such expressions; its
pointers and scalar flags remain within the stated ceiling. The per-chain
CFI state is four eight-byte fields. The CIE combines four pointers, one
expression and small encoding/flag fields. The selected ELF/x86 configuration
has no target CFI extensions and disables multiple/linkonce/compact frame
grouping; no debug-segment hash or composed linkonce name is allocated
(`gas/dw2gencfi.h:77–94,115–235`, `gas/dw2gencfi.c:366–400,430–432,2263`).
The SFrame declarations use at most three pointers, three eight-byte offsets
and small register/flag fields for a row; three pointers for a function;
five pointers for the translation context. Their constructors make one
typed allocation per counted object
(`gas/gen-sframe.h:59–153`, `gas/gen-sframe.c:591–627,1070–1075`).

`subsegs_begin` initializes the shared `frchains` obstack with the default
chunk size, and the sole chain constructor allocates one completed object
per new section/subsection (`gas/subsegs.c:35–40,131–145`). The selected
default chunk is 4064 bytes. Charging a 32-byte initial header/alignment
allowance and fifteen bytes after every object gives

```text
32 + 13*(192+15) = 2723 < 4064.
```

Thus all thirteen chain objects fit the initial chunk; no `frchains`
growth is required. The conditional-directive obstack also initializes one
default chunk, but the selected stream has no conditional directives and
adds no objects (`gas/read.c:252–260`). Each chain's *fragment* obstack is
already bounded separately by the previous fragment transfer.

## Shared notes obstack

Let **A** be the assembler argument count including its program-name argument,
and **P** bound the bytes including NUL in the output-path spelling copied
by `-o`. Require `0 <= A < INT_MAX`, so the signed `old_argc+1` is
representable, and a representable P. Define

```text
Q = max(2248, 8*(A+1), P).
```

The selected GAS symbol, fixup and relocation transfer bounds every typed
or array request it adds to `notes` by 2248 bytes. The frame and segment
requests above are smaller. Argument filtering requests `8*(A+1)` bytes;
the output-name copy requests at most P bytes
(`gas/as.c:636,1174`, `gas/symbols.c:252–286`). These interfaces finish each
object before returning. The copied argument vector stores pointers rather
than duplicating every argument string.

The remaining selected `notes` users have the following bounds:

- Section-name parsing copies at most 32 bytes including NUL. The selected
  names have no `%S` substitution; no group name is supplied, so the group
  hash and group-name allocation paths are absent
  (`gas/config/obj-elf.c:503–516,575–639,1071–1124,1427`).
- Quoted `.file` and identifier strings fit 32 bytes including NUL; the
  fixed filename is `main.adb` and the compiler identifier has 29 bytes.
  The parser builds one byte at a time and finishes the object. ELF's
  optional replacement filename copy is bounded by the same spelling
  (`gas/read.c:6341–6371`, `gas/config/obj-elf.c:203–215`).
- The close routine builds one composite containing the thirteen fragment
  obstack pointers and a terminating NULL: **112 bytes**. It finishes the
  composite before calling `bfd_close`
  (`gas/output-file.c:56–95`).

There is no listing/debug option, include path, include/macro expansion,
symbol versioning, general `.reloc`, `.eqv`, CFI escape/personality,
remember-state or multiple-frame-section path in this selected stream.
Their additional `notes` users do not enter this transfer. Fixed parser/hash
initialization uses separate allocators and remains a separate inventory;
it is not silently charged as a small `notes` request.

Consequently, at entry to any selected growth/append request, the existing
unfinished prefix has at most **112 bytes**. Every append/request to `notes`
has at most **Q bytes**. A bulk allocation/copy starts with an empty prefix
and finishes its object before another request; its temporarily unfinished
Q-byte result is not carried into another growth. Completed objects
contribute no bytes to the next unfinished object. With alignment mask at
most 15, `_obstack_newchunk` computes

```text
new_size = partial + append + mask + (partial >> 3) + 100
         <= 112 + Q + 15 + 14 + 100
         = Q+241,
```

then takes the maximum with the preferred 4064-byte chunk. Hence every
individual shared-notes chunk request is at most
**`max(4064,Q+241)`**. Requiring this bound not to exceed `PTRDIFF_MAX`
suffices for the request additions and within-chunk differences, under the
retained allocation/alignment premises. This argument includes a partial
object surviving a chunk move; it does not assume a fresh empty chunk for
each append (`include/obstack.h:314–358`,
`libiberty/obstack.c:114–150,187–235`).

For the descriptor example `as --64 -o main.o TEMP.s`, A=5 and P=7. Thus
Q=2248 and every shared-notes chunk is at most **4064 bytes**. The temporary
input pathname is retained through an argument pointer rather than copied
by these `notes` sites. The symbolic contract above remains the appropriate
transfer if the caller changes the output spelling; production GPRbuild may
use an absolute object pathname. The actual phase join must supply its
argument/path inputs. These example values neither complete that join nor
introduce an arbitrary path cap.

## Remaining composition

The selected fragment, symbol/fixup, frame-state and common GAS obstack
requests now have separate sufficient bounds. The
[ELF object writer](retained-elf-object-capacity.md) supplies its later
metadata/file envelope. Remaining assembler work includes fixed
parser/opcode/hash startup, BFD object/section/hash initialization and their
allocator contexts. Neither this packet nor a successful native sample
closes the whole assembler or the complete retained-tool capacity rule.
