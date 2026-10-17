# Source-capacity research: result and remaining derivation

**2026-10-17 — Research conclusion: stop before adopting a replacement source
rule. No sound whole-program capacity rule is established or adopted.** This
records research authorized by
[PR #106](https://github.com/berkeleynerd/silver/pull/106), merged as
`66f55f67c053d761c76eb56b0f55ae3717fe95cd`, for
[#107](https://github.com/berkeleynerd/silver/issues/107), a research child of
[#91](https://github.com/berkeleynerd/silver/issues/91). The earlier partial
[handoff](unbounded-feasibility-handoff.md) is retained as history. The subsequent
Linux continuation closes the decisive String lifetime investigation and
compares the remaining approaches. The [combined result](unbounded-feasibility-result.md)
records the full stop, review and disposition. Implementation of #88–#94 still
requires the separate recorded “proceed”.

The result is that a byte-only source-position calculation is
insufficient: virtual source copies, line tables, allocation growth, expanded
trees, and semantic constant values consume independent finite representations.
A source-sensitive vector of capacity obligations is a plausible, more expansive
candidate than a single worst-case byte cap. Its complete soundness derivation
and comparison have **not** been completed. Neither this candidate nor a uniform
cap can yet be represented as the justified best tractable rule. The missing
derivation is a specific unresolved obligation, not a proof that a sound rule
cannot exist. Further deriving that rule depends on the disposition of the
current frontend's independently established static-value obstruction.

The strongest cross-track concern is static String folding. The frontend stores
characters in a signed-32-bit-indexed pool even on this 64-bit host. Small source
can demand large semantic values. This couples #107 to
[#108](https://github.com/berkeleynerd/silver/issues/108); increasing the value
domain to `Integer'Last` does not establish physical frontend capacity. The
source-derived arguments below remain distinct from an observed native boundary.
The [complete pinned-tree lifetime audit](unbounded-frontend-lifetimes.md)
establishes the obstruction for the inspected implementation; it does not claim
that all semantics-preserving compiler alternatives are impossible.

## Evidence and provenance

The first-pass observations in this section are historical macOS evidence.
The continuation's complete pinned Ada-tree inventory, call-site audit and
exact arithmetic are linked by the [lifetime record](unbounded-frontend-lifetimes.md).
Native Linux build evidence and actual executable identities belong to the
[static-data continuation](unbounded-static-data-continuation.md). The release recipe selects
upstream GCC 16.1.0 on Linux; this relates the inspected sources to the packaged
release without claiming a reproducible build or binary attestation.

The checked-in handoff evidence is
[`feasibility-20261017/source-capacity`](../evidence/unbounded-programs/feasibility-20261017/source-capacity/MANIFEST.json).
It contains the nine probe inputs, copied runtime units, commands, output, guarded
results, source hashes, derived arithmetic and a compressed source snapshot with
upstream copyright headers preserved. `MANIFEST.json` covers the other files.
`source-manifest.json` gives each source file's SHA-256, Git blob SHA-1 and exact
upstream URL. `source-snapshots.tar.gz` expands to `upstream/`.

- Actual host: macOS/arm64, identified using `python3 scripts/dev.py paths`.
  Installed tool: GNAT-FSF-builds 16.1.0 in the parent checkout's
  `.tools/macos-aarch64/alire/toolchains/gnat_native_16.1.0_657cf254`.
  `gcc-version.txt` records the actual native tool output. The review worktree
  has no separate installation; shared installed tools were read only.
- Most source inspection uses GCC `releases/gcc-16.1.0`, resolved to
  `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. The original T3 source snapshots
  were retained from the owner's evidence branch; the parent verified that
  original research manifest against the supplied SHA-256. Additional files
  were fetched by exact commit and their Git blob hashes checked.
- The Darwin release recipe uses `iains/gcc-16-branch` commit
  `d172afd6656630c80e2a1d5e8239ed4b4ec7f996`, tag `gcc-16.1-darwin-r0`, from
  GNAT-FSF-builds recipe commit `0334dd54a2c479faa3dfad47a911373581b11739`.
  Ten relevant files are byte-identical to the inspected GCC source:
  `types.ads`, `sinput.adb`, `sinput-l.adb`, `osint.adb`, `table.adb`, `alloc.ads`,
  `stringt.adb`, `sem_eval.adb`, `uintp.adb`, and `scng.adb`.
  `darwin-comparison.json` records those comparisons. This is source/recipe
  correspondence, **not attestation that the installed binary was built from
  precisely those bytes**. Other inspected frontend files were not compared
  with the Darwin branch.
- All source line references below refer to these frozen snapshots. Native
  observations refer only to the named macOS probes. Linux and backend evidence
  belong to the separate #108 record, not to these measurements.

## Established source structure and cheap observations

### Physical and virtual source positions

`types.ads:53–56,148,190–201` defines signed 32-bit `Int`, source pointers and
4096-byte source alignment. `osint.adb:2634,2709–2714` converts file length to
`Integer`, forms the end pointer and allocates the source buffer with its EOF
position. `sinput-l.adb:414–415` aligns the next source after the previous end.
Consequently all loaded source units share a finite position space; the limit
is not an independent maximum for each physical file.

More precisely, for a range with extent `e = Source_Last - Source_First`, the
next range begins at `Source_First + 4096 * ceil((e + 1) / 4096)`.
Each preceding range therefore adds **1–4096** positions beyond its extent,
including the EOF position and alignment. Summing rounded extents for preceding
ranges and the last range's extent gives the final source position. Virtual
ranges can share their template's physical text buffer while still consuming
distinct position ranges. This formula closes the arithmetic only after the
complete phase-dependent range inventory is known.
The [retained-trace reconciliation](../evidence/unbounded-programs/feasibility-20261017/continuation/planning/source-position-reconciliation.json)
checks the recurrence against seven original inputs without rerunning a compiler.

`sinput-l.adb:130–233`, `Create_Instantiation_Source`, also allocates a new
aligned source range for a generic/inlined template. Counting only physical
files misses these virtual ranges. This route is relevant to this language:
the installed `s-imgint.ads:41` instantiates `Image_I (Integer)`, and
`exp_imgv.adb:1113–1119` selects Integer Image support. In the mixed native
probe, enabling frontend expansion with `-gnatdx` changed the trace from
17 physical/3 virtual entries to 31 physical/8 virtual entries. The virtual
Image template appears explicitly in that trace.

There is also arithmetic headroom beyond a final pointer being representable.
`sinput.adb:851–864`, `Set_Source_File_Index_Table`, increments `SP` by 4096
after recording every visited block, including the last. Keeping this arithmetic
and the next-source alignment representable gives the sufficient condition
`final Source_Last <= 2,147,479,551` (`Int'Last - 4096`). This is a
**source-derived sufficient arithmetic condition**, not an observed exact
native maximum or a completed whole-program bound. Compiler build checks and
optimization must be considered before claiming the exact externally observed
failure point.

### Tables have several distinct budgets

The following inventory corrects the idea that nominal ID ranges alone describe
capacity. It is not yet an exhaustive inventory of every reachable table.

| Component | Frozen-source evidence | Consequence for accounting |
| --- | --- | --- |
| Names | `namet.ads:226–234,557–632`; `namet.adb:1138–1162` | Name entries and character storage are separate. Generated `Name_Enter` deliberately bypasses interning, so repeated/generated names are not all deduplicated. |
| Name lock headroom | `namet.adb:39–40,1124–1131` | Lock reserves another 5000 characters and 100 entries. Final user-name counts omit this. |
| Nodes | `atree.ads:731–732,765–773`; `atree.adb:507–516,1157–1176`; `types.ads:1003–1009` | Each node has a 16-byte header and separately allocated 32-bit slots. Slot offsets have their own signed-32-bit representation. Copies/rewrites allocate more than source AST nodes. |
| Lists | `nlists.adb:49–96` | List headers are separate; next/previous arrays consume an entry for every node, not only list members. |
| Strings | `stringt.adb:36–59`; `types.ads:529–534` | String headers and the character pool are separate; every character occupies a 32-bit `Char_Code`, even when the source is ASCII. |
| Universal integers | `types.ads:356–363`; `uintp.ads:464–475,545–586` | The full 1.5-billion-wide Uint code range is not the table-entry budget. Table-coded IDs start at -699,999,999: 100,000,000 nominal IDs. Direct integers use much of the other range. `Udigits` is a separate Int-indexed digit-word table. |
| Generic table growth | `table.adb:40–47,127–153,167–220`; `alloc.ads:76–140` | `Length`, `Max`, and logical last are signed 32-bit. Growth computes in 64 bits but converts the new length back to Int without saturating. The growth history can bind before a final nominal ID budget. |

Many generic table instances use the base type rather than a nominal ID subtype.
Their nominal ranges are representation budgets, not proof of a graceful
runtime boundary check at exactly that count. Memory needed for a table is also
different from its index/length capacity.

Line-number tables are another independent case. `sinput.adb:93–155` and
`alloc.ads:76–77` start at 500 entries (times `Table_Factor`) and double, because
the percentage expression uses integer division. The allocation byte-size
expression multiplies `New_Max` by the component bit size before converting to
`size_t`. With 32-bit components, the last doubling capacity whose multiply
remains in Int is 65,536,000; the next is 131,072,000. This is an unresolved
source-arithmetic hazard, **not an observed 65-million-line compiler failure**.
The 64 KiB blank-line probe only corroborated the doubling sequence through
128,000 entries. A source-sensitive rule must cover line count and allocation
arithmetic; a table-ID inventory alone does not.

### Static folding can dominate tiny source

The current grammar permits ordered String constants and concatenation. After
the proposed value-cap change, repeated doubling can express a large static
String in a small source. `sem_eval.adb:2339–2443` resolves constant operands and
folds their concatenation into Stringt storage; `sem_eval.adb:5293–5300` follows
a constant entity's value. `Fold_Str` rewrites the expression to a literal
(`sem_eval.adb:5118–5144`). This is semantic expansion, not a count of source
literal bytes.

An important refuted candidate: one doubling chain does **not** necessarily use
the sum of all its intermediate lengths in the frontend pool.
`stringt.adb:164–191` reuses the left operand's character range when it is the
current tail; `Store_String_Chars` then appends the right operand
(`stringt.adb:221–242`). A 695-byte A0…A16 chain with final length 65,536
completed semantic checking and grew String_Chars to capacity 97,655, consistent
with tail sharing. Backend emission of separate constant objects is a different
cost, documented by #108; its cumulative payload must not be substituted for
frontend live-pool usage.

Two independent live chains give a stronger source-derived challenge: build
`A0 = "x"` through `A30 = A29 & A29` and separately `B0 = "y"` through
`B30 = B29 & B29`, then reference both final values. Each final value has length
2^30, below `Integer'Last`; the inspected folding algorithm cannot share the
two different character sequences, so their live pool needs at least 2^31
characters. Generic Table's signed Int length cannot represent that count,
irrespective of available RAM. This is a **source-derived structural obstruction
to relying on the per-value bound alone**, not a run at that scale or a proof
that no alternative tool implementation can work. The continuation closes its
lifetime and ordinary-compilation-route premises in the
[lifetime audit](unbounded-frontend-lifetimes.md).

The first-pass lifetime audit found that `gnat1drv.adb:1025` initializes Stringt
and `gnat1drv.adb:1530` locks it immediately before the backend. Stringt's
`Mark`/`Release` only restore the previous tail (`stringt.adb:133–149`); they do
not relocate live strings. No release around ordinary folding was found in the
inspected parser/semantic/driver files. A GitHub search on a newer default branch
found the checksum caller in `ali-util.adb`; that caller was then fetched at the
pinned commit (`ali-util.adb:424–463`). A default-branch search is not an
exhaustive pinned-tree call graph. The continuation instead searches the complete
hash-verified pinned Ada subtree, including unqualified calls, initialization,
tail removal, lock/unlock and backend address access. The checksum caller cannot
discard these constant values during ordinary compilation.

Growth may bind substantially earlier. `Table_Factor` defaults to 1
(`opt.ads:1508`), String_Chars starts at 2500 with 150% increment
(`alloc.ads:127–128`), and generic Table multiplies the length by 2.5, truncating
to an integer. The sequence reaches 931,307,812; the next length is
2,328,269,530, which cannot convert to Int. This is derived directly from the
default allocation recurrence. Its first few values match the small probe.
It is not an experimentally established native cutoff. In particular,
`gcc-interface/Make-lang.in:46` supplies `-gnatpg` when building the frontend;
compiler Ada checks are suppressed. An out-of-range conversion is therefore
not evidence that a native checked exception occurs at precisely this growth
step. The continuation retains the recurrence as an arithmetic hazard, without
using it to establish an exact native boundary. Even corrected saturating
growth would not remove the underlying finite character representation.

Disabling folding is not an established repair. The debug option `-gnatd.f`
is documented as causing “seriously non-conforming behavior”
(`debug.adb:732–734`); it cannot silently replace inherited Ada semantics.

### Numeric values need their own allocation accounting

The scanner's zero-scale shortcut is not a zero-mantissa shortcut.
`scng.adb:764–785` evaluates the power for a positive exponent before multiplying
by the mantissa. `uintp.adb:1357–1453` performs repeated squaring and preserves
the computed power with `Release_And_Save`. Thus `0E799999` is not safely
modeled as allocation-free just because its mathematical value is zero.
The exact integer 10^799999 has 177,170 base-32768 digits (708,680 bytes of
32-bit digit words). This number is a mathematical derivation, not measured
resident memory; it excludes temporary vectors, headers and allocator growth.
The continuation's [Uint lifetime audit](unbounded-frontend-lifetimes.md) follows
the scanner/parser and the saved exponentiation result: repeated zero literals
retain the large power during parsing even though their semantic value is zero.
This strengthens the need for separate allocation accounting; it is not an
observed native cutoff. No large repeated-literal run was made.

## Probes completed

The exact harness is `probe-source.py`; root executed it because this worker's
sandbox could not read process RSS. It first checked RSS observation and host
headroom, then ran one compiler process group at a time with a 512 MiB sampled
RSS guard and 30-second wall guard. The headroom estimate was free + inactive +
speculative pages, not a reservation. Polling every 25 ms can miss a short peak.

All nine probes used copied runtime units and
`gcc -c -gnatc -gnat2022 -gnata -gnato -gnatdl -gnatdd main.adb`.
`mixed_expanded` additionally used `-gnatdx`, which forces frontend expansion
without the backend (`debug.adb:553–558`). All exited 0, none hit a guard.

| Input | Bytes | Physical / virtual source entries | Final source position |
| --- | ---: | ---: | ---: |
| Null shell | 66 | 2 / 0 | 12,354 |
| Static String/output shell | 124 | 17 / 3 | 177,682 |
| Argument shell | 265 | 18 / 3 | 181,778 |
| Mixed declarations, guards, loops, Image and concatenation | 525 | 17 / 3 | 177,682 |
| Sparse, comment-padded shell | 65,536 | 17 / 3 | 243,218 |
| Dense null statements | 65,536 | 17 / 3 | 243,218 |
| Blank-line-padded null shell | 65,536 | 2 / 0 | 77,824 |
| Folded String of length 65,536 | 695 | 17 / 3 | 177,682 |
| Mixed input with frontend expansion | 525 | 31 / 8 | 371,551 |

Total measured compiler wall time was 0.476 seconds; individual runs were
0.041–0.094 seconds. Maximum sampled process-group RSS was 17,504 KiB.
These are native Ada/SPARK, profile-shaped proxies. The current canonical Silver
recognizer was not run against an identity-verified target binary, so these
results are not labeled current Silver admission evidence. Some deliberately
exceed current source/value limits. They do not cover all admitted compositions,
full builds, GNATprove preprocessing, optimization choices or Linux behavior.

No GNATprove, Lean build, kernel replay, complete/cold proof run or full test
suite was performed. The proposed follow-up folded-string expansion run was
not launched: tail-sharing already resolved that apparent contradiction.

## Candidate comparison and remaining obligations

| Candidate | What this investigation supports | Still required |
| --- | --- | --- |
| Uniform byte envelope | Could be sufficient if every phase's worst-case costs are proved as functions of bytes and semantic maxima. No such envelope is derived here. | Include static value expansion, numeric exponent work, runtime/virtual sources, lines, every relevant table and growth history. Compare lost capacity against source-sensitive accounting; mere conservatism does not establish best tractability. |
| Source-sensitive capacity vector | Can distinguish equal-sized sparse comments, dense syntax, many lines and semantic constant expansion; small probes show these consume different resources. This is the preferable candidate if the existing frontend is retained, not an adopted rule. | Establish closed syntax/semantic transfer functions, phase-dependent duplication and fixed runtime closure; prove computed upper bounds cover every admitted composition. It would exclude some individually legal large-value compositions, requiring explicit disposition of the intended domain. |
| Capacity-checked instrumented frontend | A research alternative could check actual allocation/representation requests before overflow, avoiding guessed per-byte multipliers. No claim of impossibility was established. Checks alone do not enlarge the representation. | Cover source positions, all table/growth arithmetic, internal counters and secondary storage; provide stable capacity diagnostics and source identity. Decide whether it is merely external failure observation or part of explicit decidable membership. A known build representation limit cannot simply be renamed physical exhaustion. Running an opaque compiler is not by itself a verified membership rule. |
| Wider or deferred frontend representations | Could address the actual obstruction while retaining author source and Ada meaning. It has not been ruled infeasible; no off-the-shelf replacement is established here. | Audit shared Ada/C++ layouts, indices, slots, source encodings and allocation arithmetic, or preserve all required static semantics with deferred materialization. Build and validate the changed pinned tool, including the proof producer. This is a separate toolchain investigation and does not establish solver completeness. |

The next source-sensitive derivation should maintain a vector, rather than one
unexplained coefficient: aligned physical/virtual source extent; line capacities;
name entries and characters; nodes, slots and list links; string headers and live
characters; Uint entries and Udigits; and growth/lock headroom. Syntactic counts
can be gathered while recognizing the finite grammar. Static String lengths and
numeric literal magnitudes can be computed compositionally without materializing
their full values. That makes such a rule plausible to investigate; it does not
prove the frontend's complete cost model has been captured.

Expansion remains the main unclosed obligation. For example, -O0 String
concatenation can select `System.Concat_2` through `Concat_9`, while larger forms
take another route (`exp_ch4.adb:3470–3510`). Branches with condition actions can
be rewritten into additional nodes/lists (`exp_ch5.adb:4767–4934`). Node copying,
subtype construction, checks, internal names, runtime loading and generic
instantiation must be charged in their actual phases. A measured node/source
ratio or one mixed example cannot substitute for this accounting.

There is currently a **hold on adopting a replacement source rule**, because
its two required obligations remain incomplete. This is not a conclusion that
no tractable rule exists, nor a claim that the research time spent proves an
impossibility. The static-data obstruction requires a tool change or explicit
disposition of the intended domain; silently replacing `Integer'Last` with a
convenient lower cap is not authorized by this evidence.

## Work after disposition and preserved historical state

The following obligations are **not completed by this research** and must be
resolved against whichever tool and domain the owner authorizes next. Their
remaining status does not become an assumed guarantee when #107 is closed as
a researched full stop.

1. Read the [combined result](unbounded-feasibility-result.md), its independent
   review, the current scope and the actual owner disposition before claiming
   further work. Existing implementation packages remain Backlog.
2. If retaining these tables, resolve their actual unchecked growth behavior
   separately from the structural live-character limit. If changing them,
   rederive all dependent representations and source/producer assumptions.
3. Establish phase-specific reachable runtime units and virtual template copies
   for all grammar operations, actual Silver build options, library bodies and
   GNATprove preprocessing. The existing `-gnatdx` trace is a useful discriminator,
   not a complete production invocation.
4. Derive/check allocation transfers for each admitted construct and internal
   expansion utility, with explicit saturation/overflow conditions. Compare a
   closed source-sensitive candidate with a genuinely sound uniform candidate.
   If either remains incomplete, identify the exact missing obligation rather
   than calling lack of a proof a tool impossibility.
5. Coordinate source and value feasibility before proposing a domain rule. Run
   only a small, targeted, guarded probe if needed to resolve a concrete source
   contradiction. Any larger experiment needs an explicit resource/cost decision.
   Serialize any compiler/prover process with the parent task and preserve
   existing evidence.

The first-pass local workspace was `/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/tmp/unbounded-planning-corrections`,
branch `codex/unbounded-feasibility-research`; starting commit `66f55f67c053d761c76eb56b0f55ae3717fe95cd`.
Scratch: `/tmp/silver-unbounded-feasibility-20261017/source-capacity/`.
Original retained input: `/tmp/review-ec82-original-evidence/tmp/unbounded-programs-research/`.
Earlier tool-review scratch: `/tmp/review-ec82-tools/`.
Darwin recipe evidence: `/tmp/silver-unbounded-feasibility-20261017/static-data/sources/`.
The parent found Linux SSH access as `canto@nix.local`; this subtask did not run
Linux probes. The earlier plain `nix` name was unresolved. Do not infer current
remote access or a particular repository path without checking it.

First-pass side effects were confined to the owned research document/evidence directory and
scratch: source downloads/copies, nine compiler subprocesses, their `.ali`/trace
outputs and package manifests. No tracked implementation, proof, caches,
installed tools, GitHub items or other-host artifacts were modified by this
subtask; no commit was made. Other agents' worktree edits were preserved.
Research/packaging wall time was not instrumented by activity; artifact creation
timestamps begin at 19:13 UTC. The root handoff index records final packaging time.
Only compiler timings above are measurements. No per-agent token-usage meter was
available. Confidence is high in the quoted representations and recorded small
observations. The continuation resolves the lifetime argument; the exact native
boundary and a universal source-capacity rule remain unestablished.
