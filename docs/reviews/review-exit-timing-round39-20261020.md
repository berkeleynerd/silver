# Retained exit timing review, Round 39

2026-10-20 UTC; #119 / #153. **Format extension accepted under its stated
premises.** No material defect or required repair was identified. This review
covers the static timing-format extension only. Timing-growth/counter bounds
and the later global-exit composition remain outside this acceptance.

The timing-format author freeze is
`60a70a11d75a9a3ce0902d48fe6ed5276a3febd4`, based on
`825412d96b0d0cc98a352887d7fe0c6dc635008d`. Exact format inputs are the
[research argument](../research/retained-why-exit-timing-format.md) and all
11 files in its [evidence packet](../evidence/retained-why-exit-timing-format-20261020/README.md),
including the checker, extension specification, source witnesses, native bodies
and controls, environment observations, imported identities and result.
The accepted Round 38 F basis and scalar-conversion service contract were
reused without replaying their checkers.

Selected reviewer setting: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime model/effort confirmation and individual token/cost telemetry
were unavailable. Observed review start was 15:09:46 UTC; the scoped report
was completed at 15:17:11 UTC, an elapsed 445 seconds including coordination
and waiting for the separately owned growth lane. That lane is not yet reviewed.
The reviewer used a separate Linux x86_64 worktree and owns only this report;
the lead retains integration, issues, durable memory and publication. The
reviewer did not author the reviewed packet.

The format review retains the Why3 source identity
`9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml identity
`8eb41f72ded84df884c3671734c947f612091f84`, installed ELF SHA256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`
and retained disassembly SHA256
`f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5`.
Oracle 7–9, 13, 21 and 25, source/native correspondence, complete selected
caller closure and the caller/service boundary govern the review.

- **Exact format and native extension.** Debug Stats uses the static
  `<stats>@[%s: %f, %d@]@.` template. The no-padding/no-precision closure
  supplies -6; format_of_fconv takes its absolute value and constructs
  `%.6f`, four bytes. The fresh 16-byte buffer does not resize. The checked
  native Float_f and Float_g dispatch entries both reach `0x96f31c`, and the
  character dispatch returns `f`. This selects the existing plain formatting
  route, without admitting the hexadecimal, uppercase or OCaml Float_F
  branches. The eagerly allocated hexadecimal closure is still charged even
  though its body is not invoked.

- **Bare annotation and accumulator census.** The parser represents bare
  `@[` with `Format(End_of_format, "")`; the empty annotation immediately
  selects `(0,Pp_box)`. Format's Pp_box branches use already-owned break and
  newline helpers. Neither a new token constructor nor another callback
  family is introduced. The nine main accumulator nodes and the main/empty
  annotation terminators give at most 11 output_acc entries for this
  template's own evaluation. The three literals total 11 data bytes. Thus
  the template data allowance is `name_bytes + 11 + 317 + 20`, plus its
  explicit flush/newline request. This excludes queued data, indentation
  and any reentrant output callback.

- **Binary64 carry and special values.** Every finite binary64 magnitude is
  below `2^1024`. Six-fractional-digit rounding changes the magnitude by less
  than one, and the exact integer inequality `2^1024+1 < 10^309` leaves ample
  room for a carry. It therefore needs at most 309 integer digits, including
  cases near decimal powers and the largest finite magnitude. A minus sign,
  one C-locale decimal point and six fractional digits give 317 bytes.
  Negative values, signed zero and subnormals fit the same allowance. The
  retained GNU contract supplies inf/nan, optionally signed, within four
  bytes. This is not an unrestricted ISO allowance for payload-bearing NaN
  text. Signaling/trap or conversion failures are outside the normal-service
  theorem. The five LC_ALL=C observations are manifest-bound evidence;
  they do not prove successful later locale initialization, preservation,
  selection or restoration. Actual float-size export remains null.

- **Reachable long conversion and requested allocation.** The 128-byte
  first destination cannot cover all normal Float_f results. Native
  `cmp $0x7f` followed by unsigned `ja` selects the long branch for
  `128<=n<=317`; it duplicates the format, allocates one result, formats
  again into `n+1<=318` bytes and frees the saved format. Negative first
  returns also enter this branch and are explicitly excluded by the normal
  theorem. Successful first and second formatting calls remain premises.
  The five-byte `%.6f` plus NUL copy can request a 16-byte runtime pool prefix,
  so the 21-byte malloc request does not assume the pool is null. Allocator
  rounding/metadata remain service-owned. The result needs 40 payload words
  and its header, 328 bytes, and stays below the installed small-allocation
  threshold. The six selected conversion allocations sum to 464 bytes;
  adding the 64-byte argument closure and 24-byte accumulator node gives
  552. These are requested-object subtotals, not total memory or live-heap
  claims.

- **Stack and global-state boundary.** The selected Float_f and annotation
  paths add no OCaml body or own stack byte to the F basis. Its reusable
  expression remains `2392*H + 176*J + 32*O`; a global-exit composition must
  justify its own H/J/O and callback/token/state environment. The inspected
  native C DAG gives `48+400+max(32+32,16+32+16,32,8)=512` wrapper bytes,
  including return slots. Both string-allocation branches are present;
  large-string/urgent-GC branches are excluded only by the normal n bound.
  This wrapper shell belongs to R and stops at explicit locale, libc,
  allocation/GC and error services. It does not replace those interiors,
  direct OCaml/C bridge frames or ambient A_pre. Preexisting global queues,
  boxes, tags, tabs, callbacks and settings are not established here.

The focused format checker ran **once**:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-exit-timing-format-20261020/check.py
```

It passed 22 native bodies / 4,784 instruction bytes, branch/constant checks,
the five retained process-environment identities and allocation/stack
arithmetic. Tool wall time was 5.386351232 seconds; the checker reports no
separate elapsed measurement. It regenerates its output artifacts, and Git
status was empty afterward: all regenerated tracked outputs matched the
freeze. The mathematical extent and source-selected branch arguments remain
reviewed reasoning under the behavior/service premises, not compiler or libc
refinement proofs.

No native target execution, new capture, disassembly, source fetch, solver,
predecessor replay or duplicate successful format check occurred. No GitHub
or CLI memory write was made. The child harness goal was null; no goal status
changed.
