# Individual obstack object and chunk capacity

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119), Linux LP64.
This reusable transfer prices the selected GCC version-2 obstack interface.
It supplements [backend storage](retained-backend-capacity.md), including the
driver's [generated environment strings](retained-native-environment.md).
It does not supply callers' missing object-size or event bounds.

## Source-derived transfer

The pinned `include/obstack.h:105–125` defaults to interface version 2:
lengths, preferred chunk size and alignment mask use `size_t`. The selected
LP64 layout has two pointer fields before `contents`, hence payload offset
16 (`:157–163`). Default alignment is 16 and the default preferred chunk
size is 4064; `gcc_obstack_init` instead selects 65,536
(`libiberty/obstack.c:79–85,115–150`, `gcc/coretypes.h:375–388`). Callers
that set their own alignment/preferred size supply those actual values.
Installed interface/ABI correspondence remains part of the existing tool
premise; this record does not establish it by a new binary experiment.

Let `a` be the selected power-of-two alignment and `m=a-1`. Let `c` be the
positive preferred chunk size, with `c >= max(24,16+m)` (including the complete
LP64 chunk header). Let `s` bound **one current
object**, including every byte appended before its next finish, and include
the NUL for `obstack_grow0`/`copy0`. It is not a bound on all objects in the
stack. Define, in mathematical nonnegative integers,

```text
k = max(c, s + m + floor(s/8) + 100).
```

For each growth primitive, require current partial length `b` plus its complete
append request `l` to be at most `s`. This also covers `obstack_make_room`,
whose requested future room must be charged despite not advancing the current
pointer. Fast variants require already-established room; typed pointer/int
writes retain their alignment preconditions.

`_obstack_newchunk` computes exactly

```text
sum1 = b+l
sum2 = sum1+m
new_size = max(c, sum2+floor(b/8)+100).
```

The source has overflow fallback/guards, but a sufficient bound can avoid
those failure cases entirely: **`k+m <= PTRDIFF_MAX = 2^63-1`**. All displayed
unsigned additions are then representable, and `new_size <= k`. The at most
`16+m` bytes before the aligned payload fit because the fixed 100-byte
allowance exceeds the 16-byte header. Thus the requested chunk contains the
copied partial object and the requested new room. Every copy and in-chunk
pointer difference has magnitude at most `k`; finishing rounds forward at
most `m` before clamping to the chunk limit
(`obstack.c:188–236`, `obstack.h:282–332,373–421`). Initialization satisfies
the same header/alignment condition. Freeing or reusing old chunks does not
increase the next request: `h->chunk_size` remains the preferred size rather
than being replaced by the last enlarged chunk.

As with the surrounding native capacity arguments, pointer representation uses
the selected Linux ABI and allocator semantics. The absolute-address alignment
macro converts the pointer to `ptrdiff_t`, adds the mask and masks low bits
(`obstack.h:137–144`). Its supported-user-address premise is separate from
the relative-length inequality above; a length formula alone is not a proof
of arbitrary address placement. Finish may temporarily align beyond the chunk
end before subtraction/clamping, so the selected GNU pointer/address semantics
also apply to that operation. No aggregate address-span condition is imposed on
independently allocated chunks.

Each initialization requests one chunk. Each ordinary growth primitive requests
at most one further chunk; finish itself requests none. Therefore `i+t` bounds
chunk requests for `i` initializations and `t` growth calls, without assuming
reclamation. This may describe lifetime work, but it is not a memory-membership
gate. Allocation/free links chunks through pointers without a cumulative
chunk-number field. The separate `_obstack_memory_used` query sums chunk sizes
in `size_t` (`obstack.c:297–309`); any relevant caller of that query needs its
own count/usage argument. This transfer does not silently remove that counter.

GCC's memory-block callback pools a request **only when it equals 65,536**;
other sizes go directly to `XNEWVEC(char,size)`
(`memory-block.cc:61–78`). It does not round every smaller request up to a pool
block. The pool uses pointer links; reuse makes no new allocation and adds no
global size index (`memory-block.h:30–77`). Ordinary malloc overhead and physical
allocation failure remain external allocator behavior, not source rejection.

## Concrete join for the native driver strings

The native environment component bounds the largest constructed string in its
selected group by `s=20,221` bytes, including key/terminator, at its captured
path-candidate parameter `P=222`. Its `obstack_init` sites use default `c=4064`,
`m=15`. The new chunk request is consequently at most **22,863 bytes**; the
alignment-difference allowance reaches 22,878. Both fit the above sufficient
region. Smaller path lists and `COLLECT_GCC` strings fit the same component
bound. The seven initial environment entries are separate inputs, not objects
concatenated into this obstack string.

This closes local obstack growth arithmetic for those already-bounded strings.
GCC's other specs-parser temporary objects and streams, number of visits,
unpriced path probes and other driver containers remain separate. For bitmap
heads/elements, the earlier `c=65536`, small completed-object result remains
tighter. Other users, including ranger, alias and IRA stacks, can apply this
transfer once their actual largest partial object and alignment are known.

The [offline arithmetic check](../evidence/retained-backend-capacity-20261018/check-obstacks.py)
reuses five complete pinned source files from the existing evidence archive,
checks the relevant constructor expressions and boundary arithmetic, and records
the concrete driver substitution. It is not a compiler execution or a proof of
all callers. Independent source review rechecked growth/terminator accounting,
initial size, arithmetic, pool selection and the separate aggregate query, with
no correction required. No toolchain, solver or Lean run was needed for this
local result.
