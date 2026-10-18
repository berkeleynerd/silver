# Literal-output GPR parent review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed frozen commit `f7904ce722195e73a296b5503d36e8b827e7c0ef` independently
of its implementation. **Accepted within its conditional local DW-reader
scope; no material defect found.** This does not establish fixed-child
regeneration correspondence, complete native-parent capacity or literal-pipeline
capacity, and does not authorize a new admission rule.

## Exact inputs and method

The review covers the [source argument](../research/retained-literal-gpr-parent.md)
and [evidence packet](../evidence/retained-literal-gpr-parent-20261018/README.md),
including the callable, checker, input/source manifests, archived sources and
retained results at the reviewed commit. Principal callable identities:

| Input | SHA-256 |
| --- | --- |
| `compose.py` | `6d2bfeb57aacd6a25d509d784ac17bd029dc31cda1ac1a5c45ecc524a9e31c17` |
| `check.py` | `1d473eb8735a20785fed4bd9558a6025fdc4b3ed218593c0c98a7685d5745681` |
| `inputs.json` | `afee9b08be99ad0d64e6d0e654cd6c7ae1b9aa906e343ed704a9d1d16e278e7d` |
| `sources.tar.gz` | `a5c8833a7866632a9c6f4565fdde49dd0ab977611f02e877c2adc51f78c85d84` |

Read the relevant Oracle, language, development/review, planning, agent-workflow,
assurance and trusted-boundary requirements, and the dated #119 authorization.
Reused the accepted [Main writer](../research/retained-literal-ali.md),
[ALI-consumer review](../evidence/retained-literal-binder-ali-20261018/review.md),
[fixed output artifacts](../research/retained-linker-output-delta.md),
[split-option argument](../research/retained-split-options.md) and
[null-parent boundary](../research/retained-gpr-parent.md) with their existing
scopes. Source inspection used complete capsule members, with literal-LF source
line references, at GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and
GPRbuild `bdfb879cf03643ec8e48a09ce07b08c4a6ff0263`.

The callable enforces ten direct input identities and the predecessor's
transitive pins. Archive identity and complete member-set/content checks cover
the 151-member binder capsule, 29-member split capsule, three additional source
members and fixed output artifacts. The two additional GCC files also match
the supplied local GCC source tree. Independent inspection found all nine
overlapping binder/split source members byte-identical, so dictionary merging
does not substitute different source versions. Hash/anchor checks support the
source argument; they neither prove its semantics nor identify installed GPR
binaries. The existing relevant-installed-behavior premise remains necessary.

## Technical assessment

- **Three fresh jobs and no reread.** `Compute_Compilation_Phases` and
  `Insert_Project_Sources` leave only Main initially queued in the selected
  executable project. `Insert_Withed_Sources_For` looks up project sources,
  redirects a spec to its existing body, and excludes runtime files absent
  from that inventory. The retained edges therefore discover the Silver_IO
  body and Silver_Output_Libc spec. `Insert_No_Roots` retains its queue mark
  after `Queue.Next` and deduplicates source/path/index/project identity.
  `Await_Compile`'s second dependency process is Makefile-only. Fresh missing
  object/dependency files return from `Need_To_Compile` before incremental
  ALI parsing. `Phase_2_ALI` passes its existing parsed ID to `Record_ALI_For`;
  its W-only read requires `No_ALI_Id` and is absent here. The existing-binder
  queue reset/read is guarded by an up-to-date exchange file, while the other
  post-compile scans belong to excluded library paths. These conclusions rely
  on the explicit fresh, ordinary, local, non-requeue descriptor premises.
- **Reader policy.** `gpr-ali.adb` always enables U, enables W/Y/Z through the
  W selector, and enables D for DW. A remains disabled, G is unknown, and native
  parsing stops at X. Thus no Args Strings or invocation signature structures
  enter this reader, although all serialized bytes still enter its raw buffer.
  The fixed version conversion and checksum/reference-line arithmetic are
  covered by the specified retained fields and Main writer contract.
- **Reset versus persistence.** `Initialize_ALI` clears name marks and resets
  ALIs/Units/Withs/Sdep. `GNAT.Dynamic_Tables.Init` frees their backing; first
  growth allocates lazily. It does not clear GPR.Names. `Name_Entry.Value` has
  exactly `Name_Len` characters, despite the obsolete introductory source
  comment about a trailing NUL. Case-sensitive parsing gives at most one
  version event, two per U and three per W/Y/Z or D. The additive persistent
  contribution is correctly 5,470 events and 6,225,037 Value bytes at P=512.
  Incoming names, metadata/padding, vector capacities and overlap still need
  their separate join; an empty incoming pool is not assumed.
- **Options and fixed ALIs.** Actual switch storage and A serialization support
  six retained switches plus the three allowed additions, each at most once:
  nine rows, 102 payload bytes, 129 serialized bytes. The index-zero premise
  excludes GPR's automatic multi-unit selector for the two fixed children;
  an unrestricted explicit-switch list would not. Split-wide contributes 21
  A bytes, and no-Xref may remove a suffix. These facts do not establish the
  complete regenerated non-A interface or exact launch configuration.
- **Arithmetic and lifetime.** Independent artifact census confirms U/WYZ/D
  counts 2/7/30 and 1/6/28, complete lengths 4,443 and 2,933, historical A
  contributions of 72 each, and maximum selected rows of 70 bytes. Replacing
  A gives EOF-inclusive lengths 4,501 and 2,991. Together with Main's 2,152,397,
  the local peak and cumulative allocation are 2,152,397 and 2,159,889 bytes.
  No child discovery recursively reads another ALI before the current buffer
  is freed. Table populations, spare/index arithmetic and conservative record
  component sizes fit their initial allocations, including the 4,096,000-byte
  ALIs request. The cumulative no-reset census also fits those capacities.
  These individual representation checks are not an aggregate RAM gate.

The fixed-child incoming contract must preserve the enumerated U/W/Y/Z/D row
inventory **including multiplicities**, as well as the names, widths and
non-A envelope. That is the retained-row interpretation used in this acceptance;
preserving only a set of names or a maximum row length would not justify its
table/event census. The packet explicitly leaves realization of this contract
open. Its arithmetic cannot be reused for a changed naming/configuration
without reconciling that producer interface.

## Focused replay and disposition

Ran the checker once on Linux x86_64 (`Linux 7.0.14`, glibc 2.43):

```sh
python3 docs/evidence/retained-literal-gpr-parent-20261018/check.py \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --output tmp/gpr-parent-review/check-results.json
```

The working directory was
`/home/canto/src/github.com/berkeleynerd/silver/tmp/review-literal-gpr-parent-f7904ce722`,
detached at the reviewed commit. The actual wrapper passed the absolute form
of the output path shown above. Start: `2026-10-18T19:10:41.663894Z`; finish:
`2026-10-18T19:10:42.276465Z`; measured subprocess time: **0.609622367 seconds**.
Exit status was zero, stderr empty, and stdout exactly:

```json
{"cases": 16, "all_checks_pass": true, "native_tool_executions": 0}
```

The 10,176-byte output equals retained `check-results.json` byte for byte:
SHA-256 `51b3f46e04e5d1a0c07abc61fdf5ee4a8e6024e8f28ccdead7b063793d9ea232`.
The source cases and boundaries are specified by the frozen checker. Its actual
Hello input is 118 bytes, SHA-256
`4afeb197991947076cf9d5a678d14ebdaa0ff8fd23339d54caf976a73c8984c7`.
Raw output, timing/argv, extracted read-only source/artifact copies and the
independent census are preserved in that worktree's `tmp/gpr-parent-review/`.
No native build, compiler, binder, prover, Lean run or full test suite was run.
Synthetic ignored-record checks remain helper-policy checks, not native parser
acceptance evidence.

The local result is ready for integration with its conditional scope intact.
The output descriptor, fixed-child correspondence, shared name backing,
source/project/driver storage and whole-parent/pipeline joins remain unfinished.
The null parent's three-source-buffer witness does not transfer. No Oracle,
tool pin, compiler or language change is part of this review.

Selected reviewer setting: **GPT-6 Astra / Extra High**, as assigned by the
parent. Runtime confirmation of model/effort and token/cost measurements are
unavailable. Review worktree creation is recorded at `19:10:03Z`; source review,
focused replay and report preparation occupied approximately four minutes.
Native execution time was zero; the measured offline replay time is above.
This round resolved the local review question without implementation rework.
The subthread's live harness goal was null; no goal or CLI memory was changed.
