# Stock server getcwd and strdup storage

2026-10-20 UTC, R58 research for #119 / #153, Linux x86_64. Base
`153f5a415d803f57a6d7f0852640c22f858909d4`.

The selected libc supplies computable requested-object bounds for the three
library allocations left named in [R57](retained-server-owned-storage.md).
For a successful stock `getcwd(NULL,0)` under the component-size guard below,
let C be the returned pathname's byte
length, `P=max(4096,p)` the initial allocation selected from the signed native
`getpagesize` return p, `B(C)=max(4096,2*C)`, and `D=1048576+48=1048624`.
Then sufficient envelopes are:

```
G_peak(C,P)       = max(P+C+1, 2*B(C)+D)
G_cumulative(C,P) = P+2*B(C)+(C+1)+floor(C/2)*D
G_return(C,P)     = max(P,B(C))
D_strdup(S)      = S+1.
```

`G_peak` includes overlapping old/new requested storage during realloc;
`G_cumulative` counts allocation-request bytes, including an optional failed
shrink request; `G_return` bounds the allocation retained after successful
return, even if shrinking fails. The two strdup calls require `2*(S+1)` in
both peak and cumulative requested storage. These are requested-object bounds,
with allocator metadata/rounding/retention, stack, loader and kernel owners
separate. They are not an assumption that libc's temporary buffers equal the
returned string length. The [packet](../evidence/retained-server-libc-storage-20261020/README.md)
retains the exact source package, binary package, selected source members,
patch audit, native operands and new arithmetic checks.

No historical page-size observation is invented: the installed caller uses a
signed 32-bit max and sign extension, so **P<=INT_MAX=2147483647** regardless
of the particular successful `getpagesize` result. Substituting that constant
gives a bound solely in C with no remaining unknown service envelope. If a
deployment separately establishes p=4096, substitute P=4096 for a tighter
bound. This packet neither observes nor changes a server process's loader data.

## Exact library and caller attachment

The already retained libc is `/usr/lib/x86_64-linux-gnu/libc.so.6`, 2,190,608
bytes, SHA-256 `85e64f97e348786a8fb4d9f3d52fec289e2fb86bba20f0731dfe61990525e0f7`,
GNU build ID `066527e430a32768d82741e00b81eebb1a872294`. Local dpkg metadata
names `libc6:amd64 2.43-2ubuntu2.4`, source `glibc 2.43-2ubuntu2.4`.
The fetched Ubuntu binary package contains byte-for-byte that exact libc.
The matching .dsc identifies the retained upstream 2.43 and Ubuntu patch
archives by SHA-256. All 103 enabled patches were inventoried: none changes
the 47 selected implementation/source-helper files. The corrected path audit
includes both `---`/`+++` endpoints and conservative `Index:` candidates,
ignores `/dev/null`, and strips path components according to the series.
All retained entries use quilt's default `-p1`; explicit `-pN` controls and
rejection of unsupported options/header forms prevent silent omission.
This is a conservative filename audit, not a patch-hunk application proof.
Download signatures were
not independently verified; no authenticated or reproducible-build claim is
made. Package metadata is a source-candidate relation, supplemented here by
the actual installed allocation control flow and operands, not a proof that
an arbitrary matching version label implies binary refinement.

R57's accepted server bodies show `get_cur_dir` passing zero/zero to
`getcwd@plt` at 0x3a88. `server_init_listening` calls that helper at 0x3fcf,
stores the result, then calls `strdup@plt` twice with the same socketname at
0x3fde and 0x3fe9. The packet additionally decodes both PLT/GOT/relocation
chains to the versioned undefined symbols `getcwd@GLIBC_2.2.5` and
`strdup@GLIBC_2.2.5`. There is one such startup per selected server. R57's
fresh shared-server topology and caller count remain imported results.

This is a prospective **ordinary noninterposed binding** to the named libc,
with ordinary allocator and elementary string/syscall services, intact live
arguments, no concurrent cancellation or unwinding, and successful initialization.
The historical server's loaded library and resolved GOT were not recorded;
the existing [copy-bridge limitation](retained-why-server-buffer-copy.md)
therefore remains. These static bytes are not a retroactive runtime observation.

## strdup: one actual allocation request

`string/strdup.c:39–53` computes `strlen(s)+1`, calls malloc once, and copies
exactly that many bytes when allocation succeeds. The installed 64-byte body
at 0xbb950 mirrors that order: strlen call at 0xbb95e, add one at 0xbb963,
malloc at 0xbb96a, and tail copy at 0xbb984. The compiled tail is fortified
`__memcpy_chk`, with both requested length and destination size set to the
same S+1. On valid live ranges its check cannot enter `__chk_fail`.

The retained x86_64 string IFUNC selectors/templates use registers, vector
loads/stores and ordinary branches; they do not create a heap buffer. Their
checked-copy failure branches are outside this successful valid-range route.
The allocation count is one regardless of which ordinary supported candidate
is selected. Loader binding, allocator internals and exceptional failure
machinery remain separate owners; they are not charged as fictitious extra
strdup result objects. The input must be a valid NUL-terminated S-byte string
and S+1 must fit the selected object/pointer representation. Two consecutive
calls can retain both copies, so both S+1 requests are charged. R57 already
describes their later free after binding; the cumulative bound needs no free.

## getcwd: kernel route and generic fallback

`sysdeps/unix/sysv/linux/getcwd.c:47–133` selects P, mallocs it, and makes the
getcwd syscall. A positive absolute-path result has length C+1 including NUL
and fits that buffer. The function attempts `realloc(path,C+1)` and returns
the original P-byte request if shrinking fails. Thus its peak old/new requested
storage and cumulative request bytes are both at most P+C+1. A successful
return does **not** establish a final requested capacity of C+1.

The native `getcwd` body is 0x126c60–0x1274fd. Its initial page-size call,
signed `max(4096,p)`, sign extension and malloc occupy 0x126ca3–0x126cc7;
the syscall is 0x126cea. The fast shrink is at 0x127323 and its failed-result
selection retains the original pointer. `getpagesize` itself reads loader
page-size data at 0x12cc74–0x12cc84. A zero loader field enters an assertion,
outside the successful-service route. The fixed INT_MAX upper bound follows
from the caller's signed comparison, without requiring a captured field value.

If the kernel cannot supply an absolute pathname, the selected fallback
first frees the initial P allocation, then enters the generic implementation
with NULL/zero. Native 0x127248–0x127284 preserves this order. There is no
P-plus-generic-buffer overlap. The generic `_LIBC` build selects openat support
and disables its separate system-getcwd retry. Its initial path capacity is
4096 (`sysdeps/posix/getcwd.c:18–45,162–170,237–255`). The no-openat dotlist
and the non-libc Solaris/Windows alternatives are not selected.

The generic algorithm constructs the path backwards, beginning with one NUL.
For each completed ancestor iteration, let n>=1 be the selected component's
byte length, a the current capacity and u the used suffix bytes including NUL.
It appends n bytes and a slash. If a-u<=n, it replaces a with
`a+max(a,n)` before the append. The source checks size overflow; native
0x126f87–0x126fc5 has the corresponding max, add/carry and realloc.

For any successful finite return, every completed iteration increases used
length by n+1>=2 and no constructed suffix is later removed. The completed
iteration count h therefore satisfies `2*h<=C`; root alone returns C=1 and
h=0. This argument concerns the actual assembled path and does not assume an
unchanging filesystem merely to identify its length. Ordinary valid directory
entry contents and successful service remain necessary.

At a growth, `a<=u+n`, the new used length is `u+n+1`, and both a and n are
at most the final C. Hence the new capacity is at most 2*C. Including the
initial allocation, all capacities are <=B(C). Every growth is at least a
doubling, so the sum of all initial/growth allocation requests is <=2*B(C).
At most two such requested path allocations overlap during one realloc.
The final shrink requests C+1 if needed, after closing the final directory
stream; it may fail while getcwd still succeeds.

This growth step also needs enough room for the new slash. Require each
selected ancestor component n<=4095. Then n<a for every capacity a>=4096,
the new capacity is 2*a, and `u+n+1<=a+(a-1)+1=2*a`. Without that guard the
recurrence alone is insufficient: a=u=n=4096 gives new capacity 8192 but needs
8193 bytes. The initial finite-model check exposed this missing premise; it
was not a native corruption observation. The packet retains this negative
arithmetic example. The guard concerns the selected filesystem/caller names,
not a new Silver language cutoff or physical RAM policy. An applicable
pathname-service guarantee or the actual selected ancestor names can discharge
it; the historical server's unobserved cwd does not itself establish it.

## The fallback's directory storage is bounded independently of directory size

`fdopendir` calls `__alloc_dir` in `opendir.c:90–134`. That constructor clamps
the filesystem's block-size hint to [32768,1048576] and requests
`sizeof(DIR)+allocation`. Native 0xf6773–0xf678f establishes both clamp
constants, adds **48**, and calls malloc. Even a strange block-size hint
cannot increase this request beyond D=1,048,624. Its fields and inline lock
initialize inside that object; there is no second directory-entry allocation.

The generic loop closes the previous stream before allocating the next;
`closedir` frees its object before closing the descriptor. Thus at most one
DIR object is live. `readdir64` refills that same allocation with getdents64;
rewinddir resets offsets and seeks without replacing the allocation. The
selected source bodies and native routines are retained. The number of
directory entries scanned affects work, not the number or capacity of DIR
buffers. For a successful call there is exactly one DIR construction per
completed ancestor iteration, hence at most floor(C/2) constructions.

The source-helper inventory also retains the selected syscall wrappers and
x86 string templates. Ordinary file-stat/open/fcntl/close/seek/getdents paths
do not create another user heap owner. Uncontended private DIR locks require
no separately allocated lock record. Async cancellation, corrupt dirents,
interposed functions, loader initialization and allocator internals are not
silently assigned zero physical cost: they are outside this requested-object
argument and keep the existing successful ordinary-service/other-owner boundary.

Consequently fallback peak requested objects are <=2*B(C)+D, while cumulative
requests are <=P+2*B(C)+(C+1)+floor(C/2)*D, including the earlier freed kernel
buffer. Taking the max with the kernel route gives the displayed envelopes.
Finite arithmetic examples in the checker challenge the threshold and shrink
cases; the inequalities above, not those examples, cover arbitrary lengths.

## Caller guards and composition

Require C>=1, the selected ancestor-component bound n<=4095, valid successful
ordinary services, representable source pointer
differences and allocation arithmetic, and the inherited R57 response guard
`C<=INT_MAX-45`. This guard implies `B(C)<=4294967204<PTRDIFF_MAX` and keeps
every new generic capacity, C+1 and the directory request representable on
the selected LP64 ABI. Require `0<=S` and `S+1<=PTRDIFF_MAX`, with a valid
socketname buffer. These are representation/service premises, not newly
adopted Silver input cutoffs. Formula sums are mathematical integers; a
capacity rule must check its own representation before converting them.

After getcwd returns, the stock caller retains its one returned allocation
while making both strdup copies. A tighter startup peak is therefore
`max(G_peak(C,P),G_return(C,P)+2*(S+1))`. The simpler additive term
`G_peak(C,P)+2*(S+1)` safely composes with R57's conservative direct envelope;
do not add the C+1 or two S+1 known payloads again. The cumulative companion
is `G_cumulative(C,P)+2*(S+1)`, for later allocator-retention analysis; it is
not substituted for an allocator physical bound. For multiple servers, sum
the chosen per-server envelope with each server's actual C and S.

This closes the named getcwd/strdup **requested-object** summands at the stated
selected-library/caller interface. The existing
[capacity contract](retained-tool-capacity.md#comparison-and-next-derivation)
supplies ordinary allocator/OS behavior and sufficient physical stack, memory
and disk. Excluding physical allocator overhead/retention, mappings, kernel
storage and child memory creates no aggregate RAM admission gate or new proof
of allocator internals. Relevant source/configuration correspondence, finite
indices/representations and stack assumptions, request arithmetic, correctness
counters and correct callers remain required. Other libc families and the
meaningful raw-output/proxy/Why behavior remain distinct from this bounded
argument under that same contract.
No solver/proof/server/capture run, successful predecessor replay, Oracle/tool/
admission edit or production adoption occurred. The global two save-entering
callbacks / three saves / e<=2 allowance is unchanged. Full #119/#153 and q
remain incomplete; production #88–#94 are unstarted and PR #121 is draft.
