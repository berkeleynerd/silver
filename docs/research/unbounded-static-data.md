# Unbounded programs: partial static-data feasibility research

**Historical checkpoint.** The [Linux continuation](unbounded-static-data-continuation.md)
and [combined result](unbounded-feasibility-result.md) supersede this document's
unfinished-work status. The observations below retain their original input and
host scope; they are not new runs.

Research date: 2026-10-17. Research authorization: [PR #106](https://github.com/berkeleynerd/silver/pull/106),
merge `66f55f67c053d761c76eb56b0f55ae3717fe95cd`. This is the research subphase
[#108](https://github.com/berkeleynerd/silver/issues/108) of
[#93](https://github.com/berkeleynerd/silver/issues/93), not implementation or
adoption of a larger language. The [scope](../unbounded-programs.md) and the
Oracle remain authoritative.

**Partial handoff checkpoint.** The owner requested transfer to an agent with
the required access before this research and its independent review were
complete. Issue #108 remains incomplete. Verified observations are useful
inputs to the successor; this document does not settle full-domain feasibility
or recommend adopting a new bound.

## Conclusion

`Integer'Last = 2,147,483,647` is the proposed per-String semantic ceiling on
the pinned native targets. It is not evidence that the complete family of
programs with such Strings builds. The source-capacity investigation must
account for frontend materialization of String expressions, and backend
capacity must account for the aggregate of live objects and compiler-created
copies, not only the largest object.

The native macOS experiment found a concrete non-resource relocation failure:
three zero-filled objects, each `2,147,483,647` bytes, compile to a 920-byte
object, but their direct references fail to link with `ADRP out of range`.
The corresponding small control links. The pinned Darwin compiler explicitly
rejects the large code model; turning off PIC does not enable it. These C
proxies isolate backend mechanisms; they are not admitted Silver programs and
do not establish a Silver language boundary. A separate Ada experiment in the
proposed String grammar confirms that its static constants use the same direct
ADRP addressing and that default compilation emits cumulative String values.

On Linux x86-64 the same zero-fill C source fails under the small code model
and links under medium and large. The unchanged 1 MiB Ada source also selects
large-data sections and 64-bit data addressing with those options. These
observations prevent treating the default 2 GiB address-placement assumption
as an unavoidable String-length limit. They do not establish complete large
Ada builds. The exact frontend, aggregate-data, runtime and proof obligations
still require separate evidence.

## Inputs, host and tool identity

The worktree starts at authorization merge `66f55f67c053d761c76eb56b0f55ae3717fe95cd`.
`scripts/dev.py paths` was read before selecting tools. Its worktree-local
tool directories are not bootstrapped; probes use the existing shared native
installation without modifying it.

Native observations below ran on Darwin 27.0.0, arm64, host `mini.local`, with
24 GiB physical RAM. The compiler identifies itself as GCC 16.1.0
`GNAT-FSF-builds`, target `aarch64-apple-darwin24.6.0`, installed by Alire as
`gnat_native_16.1.0_657cf254`. Its release archive hash in `alire.toml` is
`657cf254323eb91f79768918e8bd8887d6da7ac6056732a38f21e2848267da18`.
`binary-hashes.json` records the actual driver and `gnat1` hashes.

The installed linker wrapper prefers `xcrun --find ld-classic`, then falls back
to `ld`. On this host `ld-classic` is unavailable; actual linking used Apple
`ld-27037.1`, resolved to Xcode's default toolchain. This differs from merely
assuming that the wrapper's preferred linker exists. The driver selected SDK
27.0 and a default deployment target 28.0. The control link succeeds; no produced
application was executed, so these probes make no deployment/run claim.

The official [GNAT build recipe at release commit
0334dd54](https://github.com/alire-project/GNAT-FSF-builds/blob/0334dd54a2c479faa3dfad47a911373581b11739/specs/gcc.anod#L22)
selects upstream GCC 16.1.0 for non-Darwin builds and
`iains/gcc-16-branch`, tag `gcc-16.1-darwin-r0`, for Darwin. The latter resolves
to `d172afd6656630c80e2a1d5e8239ed4b4ec7f996`. Sources from that revision are
retained with URLs and SHA-256 values. Recipe provenance is not a reproducible
build or source-to-installed-binary attestation. Matching the native diagnostic
to the source branch supports the specific code-model claim, not every source
statement about the binary.

The retained original T3 research remains historical Linux evidence. Its
near-2 GiB accepted input was a **source-size** test with comment padding under
`gcc -gnatc`. Its 100 MB full `-O0` build was also a padded source, not 100 MB of
static String data. Neither establishes large static-value feasibility.

The new Linux observations ran on `nix`, Linux 7.0.0-38-generic x86_64, using
`gnat_native_16.1.0_9f74f58a`, target `x86_64-pc-linux-gnu`, GCC 16.1.0
`GNAT-FSF-builds`, configured with default PIE. The remote scratch directory
was `/tmp/silver-unbounded-feasibility-20261017/static-data`; its evidence is
retained locally under `linux-retained/`. The six runtime files copied for
each Ada probe have hashes identical to this frozen research worktree.
`gcc -print-prog-name=ld` identifies the bundled target linker path. The initial
metadata also records PATH's `ld --version` and hash; those describe Ubuntu's
system linker, not the selected bundled linker. A read-only follow-up captured
the selected linker as GNU Binutils **2.46.1**, resolved its path and SHA-256
`5fedbb6086b0234eb990800507c0670cb572b48ad864a4d8e8f961ddddef09a0`, in
`linux-retained/linux-selected-linker.json`. No compiler run was repeated.

## Frontend materialization and cumulative static data

The current grammar admits a String constant initialized from earlier String
objects and concatenation, and permits unused declarations. The proposed
expansion changes the value bounds, not this syntax. A source with `A0 = "x"`
and successive `Ai = A(i-1) & A(i-1)` therefore illustrates the intended
family. Its length at step `n` is `2^n`; retaining all constants through that
step has logical payload sum `2^(n+1)-1`. An additional expression combining
the powers through `2^30` has length `2^31-1` while every concatenation
intermediate can stay within that ceiling. A small source can consequently
describe large static data; a source-byte bound alone does not imply a
proportional String-data bound.

The native experiment stops at `A20`, 1,048,576 bytes, and calls
`Silver_IO.Put_Line(A20)`. The six runtime source files were copied unchanged
from the research worktree into its isolated probe directory. Compilation used
the production Ada options `-gnat2022 -gnata -gnato`, with `-S -O0`, and no
GNATprove invocation. It succeeded in 0.201 seconds. The assembly is 2,110,495
bytes and contains all 21 immutable constants with total String payload
2,097,151 bytes. The final argument is addressed by an `ADRP`/`ADD` pair;
`Silver_IO.Put_Line` is called normally. This is backend evidence at a small
scale, not confirmation of any large program's proof or execution.

This source exceeds today's 4096-byte **value** rule, although its source is
small. It was deliberately passed directly to GCC as a proposed-language
probe, not described as accepted by the current Silver compiler. No admission
rule, runtime source, or application source was changed to make it compile.

Frontend String-table growth is a separate and earlier constraint. The
[companion source-capacity research](unbounded-source-capacity.md) traces constant evaluation and its actual
character-table allocation. Any final recommendation must incorporate that
result before projecting this small backend observation toward Integer'Last.
Ordinary backend optimization cannot be assumed to avoid work already
performed by Ada semantic analysis.

At handoff, that source audit reports a strong candidate obstruction: character
codes occupy 32 bits, and the character table's length/index representation is
signed 32-bit. A single doubling chain can share its left operand at the pool
tail, so the backend's cumulative emitted sum must **not** be used as the
frontend pool count. Two independent live chains, one of `x` and one of `y`,
each reaching 1 GiB, instead require at least `2^31` character entries under
the inspected folding algorithm. The length representation cannot hold that
many entries. Default geometric table growth may fail earlier: the audit
derives a step from 931,307,812 to 2,328,269,530 entries, outside `Int`.
These are **source-derived, not observed boundary failures**. Exhaustive
`Mark`/`Release` reachability and correspondence to the installed native binary
remain explicit successor work; the source-capacity record retains the exact
source references. No giant concatenation was compiled to settle them.

## Backend, object format and linker

### Linux x86-64

The [GCC 16.1 x86 manual](https://gcc.gnu.org/onlinedocs/gcc-16.1.0/gcc/x86-Options.html)
documents three relevant models. The default small model assumes limited
placement of code and symbols; medium puts large data in separate sections;
large removes address/section-size assumptions. This is a build-mode choice,
not an Ada String subtype. The documented medium threshold chooses storage
placement and need not become a user-visible admission knob. A fixed reviewed
large-model build is also a candidate, subject to the actual toolchain,
runtime linkage and assurance checks.

These options do not remove frontend tables or finite machine address space,
and do not establish that an arbitrary number of near-Integer'Last objects
fits memory. Conversely, resource exhaustion of such a family is not evidence
for an arbitrary smaller String limit.

The new guarded Linux experiments provide more than the manual's claim:

| Input and mode | Observed result | Harness wall time | Child maximum RSS |
| --- | --- | ---: | ---: |
| C zero-fill, three 16-byte objects, small | Links | 0.067 s | 31,784 KiB |
| C zero-fill, three Integer'Last-byte objects, small | `R_X86_64_PC32` relocation truncation for `b` and `c` | 0.065 s | 31,688 KiB |
| Same large C source, medium | Links; executable 7,760 bytes | 0.067 s | 31,900 KiB |
| Same large C source, large | Links; executable 7,760 bytes | 0.067 s | 31,904 KiB |
| Ada 1 MiB final constant, small | Assembly generated | 0.129 s | 48,396 KiB |
| Same Ada source, medium | Assembly generated | 0.126 s | 49,436 KiB |
| Same Ada source, large | Assembly generated | 0.064 s | 49,940 KiB |

No guard triggered. The medium/large C executables were never run. `readelf`
reports their large data as `NOBITS` `.lbss`, confirming that the observation
does not require a giant initialized file. It is a placement/linkage test,
not a demonstration that its data can be physically allocated or used.

For the actual Ada String path, small-mode assembly references `a20.20` with
RIP-relative `leaq` in `.rodata`. Medium puts the constant in `.lrodata` and
loads a 64-bit `a20.20@GOTOFF` immediate with `movabsq`. Large also uses large
data and 64-bit offset addressing, including an indirect `PLTOFF` call. All
three emit 21 constants with total declared payload 2,097,151 bytes. Exact
line-numbered nonliteral assembly excerpts and full-artifact hashes accompany
the evidence. This tests that the options affect GNAT's Ada constant lowering,
but stops at assembly; it is not a near-boundary Ada compile/link, runtime or
proof result.

### macOS arm64

The [GCC 16.1 AArch64 manual](https://gcc.gnu.org/onlinedocs/gcc-16.1.0/gcc/AArch64-Options.html)
describes a 4 GiB small-model symbol-span assumption. Its generic large model
cannot be assumed available on Darwin: the release-specific
[initialization code](https://github.com/iains/gcc-16-branch/blob/d172afd6656630c80e2a1d5e8239ed4b4ec7f996/gcc/config/aarch64/aarch64.cc#L20765)
rejects it for `TARGET_MACHO`. The two tiny native probes observe the exact
diagnostic, both with default PIC settings and with `-fno-pic -fno-PIE`.

Mach-O is not simply a format with a universal 2 GiB or 4 GiB total-data bound.
Its `section_64` and `segment_command_64` use 64-bit sizes and addresses, while
section offsets, relocation-table offsets and several link-edit offsets remain
32-bit. The [format header](https://github.com/apple-oss-distributions/xnu/blob/main/EXTERNAL_HEADERS/mach-o/loader.h)
documents those fields; a copy of the locally selected GCC SDK header is
retained as `sdk-macho-loader.h:397-412,473-485,913-919`. This is a set of layout
constraints, not proof that every file of a particular total size is invalid.
Zero-fill sections exercise address extent without materializing their bytes
in the object file, so they do not test huge initialized images or their
link-edit layout.

The discriminating native C proxy defines three globals of length
`2,147,483,647`, and reads/writes their first bytes. GCC produces three
`.zerofill` directives and direct `ADRP` references. Its object is only 920
bytes. The linker reports:

```text
ld: fixup error (kind=arm64_adrp_lo12) at '_main'+0x20 from probe.o,
ADRP out of range, from 0x1000005F8 to 0x200003FFE ('_c')
```

The reported `__common` size is `0x17ffffffd` = 6,442,450,941 bytes, exactly
three Integer'Last-sized objects; the data segment has zero file bytes. The
link exits 1 in 0.500 seconds with about 124.5 MiB maximum sampled aggregate
RSS. The resource guard does not fire, and the small control links. This is
an observed placement/relocation limit, not memory exhaustion.

The C proxy does not use Silver source, initialize its arrays like Silver, or
exercise runtime library contracts. The Ada experiment supplies only a narrow
bridge: at its measured scale, static constants use the same direct addressing
form. A claim that the exact large Ada family necessarily reaches the linker
would additionally require clearing the frontend materialization limits.
There is also concrete counterevidence against treating this as a universal
Mach-O aggregate-data ceiling: the same backend's
[symbol classification](https://github.com/iains/gcc-16-branch/blob/d172afd6656630c80e2a1d5e8239ed4b4ec7f996/gcc/config/aarch64/aarch64.cc#L22768)
can indirect external/common/weak symbols through the GOT, while constant-pool
addresses remain local and PC-relative. A changed C storage/linkage model
therefore need not reproduce the proxy failure. Silver's initialized local
String constants are the path that needs its own solution.

## Alternatives and remaining obligations

1. **Reviewed build modes:** investigate fixed Linux medium/large-model flags
   before proposing a lower value bound. The same authoritative Ada source can
   be admitted, proved and compiled with such flags. This changes generated
   representation, not author syntax. Darwin's observed unsupported mode means
   the identical flag is not a cross-platform solution.
2. **Ordinary compiler optimization:** removal or sharing of redundant immutable
   constants can reduce backend data, but is not a universal capacity argument
   and need not avoid frontend constant evaluation. Distinct constants and
   mutable copies remain permitted compositions. Any selected flags require
   reviewed behavior over the admitted profile and corresponding build tests.
3. **Runtime representation or allocation:** constructing data dynamically,
   using heap storage, or introducing address indirection might avoid static
   relocation/layout limits. This is an implementation avenue, not an already
   verified solution or an identified switch in the pinned compiler. Normal
   compiler lowering of the unchanged Ada source is compatible in principle;
   replacing that source with generated initialization calls is not an allowed
   shortcut. It must preserve Ada/SPARK meaning, the actual same-source
   assurance chain, library identity and all resource/failure outcomes. Any
   new Silver-owned implementation remains subject to the verified-SPARK rule.
4. **Tool change:** an upstream compiler/backend fix or changed supported pin
   could address a forced tool restriction. It is outside this research
   authorization and requires the normal language/assurance/toolchain evidence;
   it is not permission to suppress checks or silently lower the domain.

The owner-facing decision must distinguish the mathematical String ceiling
from a realizable family under the selected compiler. No single successful
near-boundary build can establish all compositions. A source-sensitive
accounting rule, a proved universal envelope, and a representation change have
different expansion and assurance costs; compare them with the companion
source-capacity evidence before adopting one. If none satisfies the owner's
direction with the pinned stack, retain the scope's conditional full stop and
report the exact obstacle and alternatives to the owner.

## Validation, limits and side effects

All 15 measured compiler/linker probes (eight macOS, seven Linux) ran
sequentially after taking the shared probe slot. Eleven succeeded and four
returned the expected unsupported-model/relocation diagnostics; no resource
guard fired. The scratch harness uses 30-second wall/32-second CPU
limits, a 16 MiB per-file limit, disabled core dumps, and a 512 MiB aggregate
RSS guard sampled from `ps` about every 50 ms. Sampling can miss short peaks;
its limit is a research safety control, not a product resource policy.
`resource.getrusage` and sampled process-group RSS are recorded separately and
must not be conflated. On Darwin the former's max-RSS units are bytes.

One initial 45-byte C assembly attempt lacked a successful RSS-monitor
preflight: sandbox process inspection failed immediately after child launch.
It completed before follow-up inspection and left only a tiny assembly file.
It is retained as an invalid measured run. The harness now verifies `ps`
before launching any child, and the guarded retry is the cited observation.

No GNATprove, Lean, full suite, bootstrap, production build, application
execution, giant initialized file or allocation was performed. Research writes
are confined to the assigned scratch trees, this document and its compact
evidence bundle. Shared Silver caches and other-host artifacts remain
untouched. URLs, source hashes, binary identities,
input hashes, commands, diagnostics, timing, RSS samples and output sizes are
retained in the [compact evidence bundle](../evidence/unbounded-programs/feasibility-20261017/static-data/README.md);
full scratch artifacts and original T3 inputs remain intact. The record and
bundle are partial handoff artifacts, not a completion certificate.

## Successor work

1. Reconcile the Linux proxy/assembly results with the complete Ada lowering
   path. Successful C large-data linkage or a 1 MiB Ada assembly is not evidence
   that arbitrary near-Integer'Last Ada constant compositions build. Preserve
   the recorded controls and do not rerun them without a new contradiction.
2. Complete the frontend String-table accounting argument, including tail
   sharing, still-live distinct strings, release/rollback sites, generated
   strings, table-growth arithmetic and the actual Linux/Darwin source pins.
   Determine which statements are forced representation constraints and which
   depend on an unattested source-to-binary premise.
3. Compare source-sensitive forced-tool accounting with broader same-source
   compiler/build-mode or representation changes. A derived smaller envelope
   needs an expansiveness justification; a larger target needs a complete
   acceptance/assurance argument. Distinguish semantic maximum, admitted
   compositions and physical resource exhaustion throughout.
4. Investigate initialized-data/object/link-edit behavior only if a specific
   remaining hypothesis survives frontend analysis. The zero-fill probes do
   not establish it. Do not default to expensive giant files or proof runs.
5. Obtain independent adversarial review, record dispositions and the precise
   owner-facing conclusion/full stop, then update the parent issue and scope
   through the authorized workflow. Neither research completion nor this
   handoff authorizes #88–#94 implementation.

The record does not claim full-domain feasibility, resolve the conditional
full stop, or mark #108 complete.
