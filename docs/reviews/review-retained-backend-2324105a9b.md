# Native backend capacity component review

2026-10-18, Linux x86_64. Frozen review target: `2324105a9b`, for
[#119](https://github.com/berkeleynerd/silver/issues/119).

**No material finding within this component's stated scope.** The
[backend derivation](../research/retained-backend-capacity.md) correctly supplies
local bounds for whole-file line-map allocation, Character String lowering and
the selected O0 String-emission path. Its conclusions remain conditional on the
recorded source/configuration and ordinary LP64 layout premises. This is not a
whole-backend capacity verdict, an admission rule, or evidence that an installed
compiler accepts a near-limit program.

## Review and reproduction

Read the complete twelve source files identified by the component and followed
the relevant allocation, option-default and emission callers beyond the quoted
ranges. The component checker verifies all twelve complete-file identities and
reproduces both `checks.json` and `source-excerpts.md` byte-for-byte. Independent
integer calculations check the boundary and cumulative cases below. No large
source, String or location table was allocated.

The x86 option table contains a `SUBTARGET_OPTIMIZATION_OPTIONS` hook. To check
that potential exception, this review retained 22 additional immutable GCC
configuration/header sources, including the normal x86-64 Linux header selection
in `config.gcc`, its target headers and relevant included headers. None defines
that hook or mentions a merge-constants override. Their exact bytes, retrieval
URLs and local verifier are in the
[review evidence](../evidence/review-retained-backend-2324105a9b/README.md).
This is a source check under the selected build configuration, not a fresh
preprocessing run or an installed binary/source equivalence claim.

### Line-map boundary and accumulation

`back_end.adb` passes every source-file record's maximum logical line to gigi.
The gigi loop checks file/map count equality and creates one top-level map per
file. `linemap_add` begins that map with zero column/range bits. The 252-column
hint selects eight column bits; Ada's default range-bit count is zero.

The reuse guard computes its exponent from `sizeof(linenum_type)`, an unsigned
int, rather than from the 64-bit `location_t`. The resulting strict inequality
is `n - 1 < 2^24`. Thus `n = 16,777,216` still reuses the map, and
`n = 16,777,217` creates an extra map. The report correctly avoids treating a
missing next-file diagnostic as permission to violate the invariant. The
positive-line requirement and separate logical-line inventory are necessary
qualifications, especially for dependencies and virtual source files.

With incoming maximum `h`, the next map starts at `h+1`, its last line starts
at `h+1+256*(n-1)`, and the explicit final column is 251. This gives the stated
per-file charge `256*(n-1)+252`. Leaving a top-level file allocates no map. The
independent check reproduced the cumulative formula for a single shortest
file, a single boundary file, a mixed inventory and 100 boundary files. The
largest later masked column is 255, requiring the stated four-value headroom.

Those last four values can numerically reach past the next map's start; the
component does not claim injective source-coordinate encoding, and neither does
this review. Its claim is the map count and arithmetic bound, with exact columns
explicitly excluded. The strict normal-region ceiling is a sufficient condition
for this path, not a demonstrated exhaustion threshold for the 64-bit space.

### String lowering and allocation

The Standard Character branch in `trans.cc` allocates an `L`-byte temporary,
copies every Stringt character, and passes the signed-int length to `build_string`.
The temporary uses `alloca` only below 1000 bytes; the larger buffer is freed
after construction. Wide-character lowering is a distinct branch.

Under the stated conventional LP64 layout, the two four-byte `tree_base` words
precede the eight-byte tree pointer; the following four-byte length puts `str`
at offset 20. The request is therefore `L+21` bytes. `build_string` stores the
length separately from its private trailing NUL, so `L=2^31-1` requests
2,147,483,668 bytes without overflowing its unsigned 32-bit allocation quantity.
The independent arithmetic also checks lengths 0, 1, 999 and 1000. These facts
do not count lowering events, justify reclamation, bound allocator overhead or
establish whole-program memory use; the component leaves those obligations open.

### O0 emission

The apparent `Init(1)` in `common.opt` is not the final default: `opts.cc` calls
the O1-and-above default entry at O0 with the generated negative value. Neither
the inspected Ada overrides nor the selected x86/Linux configuration re-enables
merging. The generated application project in `src/silver.adb:113` supplies
language/check switches without an optimization or merge override. The result
is scoped to that O0 configuration; it is not an assertion for O1 or an explicit
`-fmerge-constants` invocation.

The ordinary ELF selector reaches `mergeable_string_section`, whose first guard
requires `flag_merge_constants`. Variable and constant emitters derive their
`merge_strings` argument from the actual section flags; ordinary object-block
emission passes false. Aggregate element paths inspected in `varasm.cc` also
pass false. Under the selected conditions, `output_constant` therefore passes
`L` to `assemble_string` without its optional extra byte. Its chunk loop cannot
overflow signed `pos` when `L <= int_max`, and `ceil(L/2000)` bounds both the
2000-byte and 16384-byte variants. Padding and other emitted entities remain
separate, as the report states.

## Disposition and limits

Keep these results as conditional components of #119. No correction is required
to this frozen report. The outstanding source/tool relation, per-construct
event counts, other GCC containers, allocator growth, code/data and frame sizes,
assembler/object/linker representations and relocation reach are not discharged
by this review. Current admission and the implementation dependency remain
unchanged.

Validation used local Python source/evidence checks and read-only upstream source
GETs. No compiler, GNATprove, Lean build, full suite, clean rebuild, kernel replay,
macOS validation or native near-limit probe ran. Only this review and its evidence
were added in the review worktree; no production file, reviewed report, issue,
board entry, harness goal or GitHub state was modified.
