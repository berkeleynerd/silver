# Independent output-binder assembler review

2026-10-19, research [#145](https://github.com/berkeleynerd/silver/issues/145)
within [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted at **`cc7db56baf51b1aaccf9604bdcc4b21e0cf720a3`** for the stated
conditional output-binder checksum family. No blocking defect was found.
The retained fixed zero/nonzero successes and the compiler/GAS source
projection establish the claimed all-uint32-checksum assembler transfer under
the selected source, invocation, configuration and installed-behavior premises.
This does not establish complete native capacity, actual-source attachment by
a future aggregate, or production admission.

Selected reviewer: **GPT-6 Astra / Extra High**, assigned by the lead.
Runtime-setting confirmation and token/monetary measurements are unavailable.
Review began at 15:00:33 UTC; source inspection and focused checks completed at
15:07:02 UTC (**389 seconds**, excluding report authoring), on Linux x86-64.
The isolated review checkout stayed at the frozen implementation. There were
**zero new native tool executions** and no predecessor proof-suite replay.
Only this review and reviewer-owned scratch were written.

## Exact inputs and scope

The eight changed files were reviewed: the
[source argument](../research/retained-literal-binder-assembler.md) and the
[packet](../evidence/retained-literal-binder-assembler-20261019/README.md)'s
`README.md`, `capture.tar.gz`, `check.py`, `checks.json`, `derive.py`,
`inputs.json` and `result.json`. The capture archive is 93,026 bytes, SHA-256
`eed3a9bc25114377fc06849628f2b7abe94fe18f28f34158ff4361383be1567b`.
The callable replay verified its sixteen source/repository pins and archive
identity. Review separately checked the three recorded installed tool
identities against their available files; this read did not execute them.

Inherited arguments were the accepted
[compiler checksum closure](../research/retained-binder-checksum-closure.md),
[binder options](../research/retained-binder-options.md),
[invocation join](../research/retained-literal-invocation-join.md),
[null-pipeline output-path transfer](../research/retained-null-pipeline.md), and
the GAS [invocation](../research/retained-assembler-invocation.md),
[startup](../research/retained-assembler-startup.md),
[backing](../research/retained-assembler-backing.md) and
[capacity](../research/retained-assembler-capacity.md) interfaces. Review did
not repeat those complete predecessor arguments or substitute Main's GAS
event counts for the binder's fixed-success witnesses.

The GCC source root was
`/tmp/silver-backend-compose-20261018/full-source`; the Binutils source root
was `/tmp/silver-backend-compose-20261018/gas-source`. In addition to the
packet's nine external-source pins, the six relevant complete files
`gas/as.c`, `gas/ehopt.c`, `gas/write.c`, `gas/config/obj-elf.c`, `bfd/elf.c`
and `bfd/elfxx-x86.c` matched the retained GAS source manifest. Supplementary
reads checked the target/environment and GNAT object-output-name routes.

## Source argument challenged

The accepted binder compiler family makes the public readonly `mainB`
initializer the sole varying assembler datum. `gen_int_mode` truncates to
signed SI, `CONST_INT` printing is signed decimal, and the integer writer
selects `.long`; the zero writer instead emits `.zero 4`. This gives the
complete nonzero spelling family, not just the four captured values.
At most ten digits, one minus sign and one newline fit the nineteen-byte
directive ceiling. Neither the public symbol nor its section selection can
disappear when the checksum is zero.

The nonzero GAS decimal route remains below the eighteen-digit small-number
threshold. Every prefix is at most 2,147,483,648; unsigned negation for a
negative spelling adds one bounded operand frame. The direct four-byte
`O_constant` emission creates no relocation, symbol, bignum or broken-word
record. For every signed32 value the truncation-warning predicate is false.
An additional positive-value native probe is unnecessary: the source argument
covers that branch, and the retained negative witness already uses the extra
operand frame. Boundary probes are corroboration, not exhaustive evidence.

The varying scalar occupies ordinary `.rodata`, with ELF flags exactly
`SHF_ALLOC`, not a merge/string or executable section. `check_eh_frame`
returns immediately outside `.eh_frame*`/`.debug_frame*`
(`gas/ehopt.c:276–300`). The four data bytes therefore cannot select an EH
optimization or variable relaxation route. Downstream section/symbol/fixup
demands use the unchanged extent and metadata, not this scalar's contents.

Zero was examined separately. The `.zero 4` path calls
`frag_var(rs_fill,1,1,0,NULL,4,NULL)`, whereas `.long` appends four bytes.
These are different fragment requests. The packet correctly pays the zero
path with its own fixed successful execution and does not infer equal internal
allocation from equal object size. The nonzero source transfer preserves its
own request shape; both streams preserve the four-byte extent and later
symbol values.

The fixed longest line is 87 bytes, independently of checksum spelling.
The 32,768-byte read block and initial 65,536-byte scrub payload suffice even
for short reads: the carried unfinished line cannot reach the scrub-growth
threshold. Line and byte positions remain small. No checksum spelling enables
an include, macro, listing, debug, alternative input or target option.

## Invocation and evidence correspondence

The original captured binder body/spec are byte-identical to the accepted
output-binder options packet. Each of the four case bodies is identical;
each spec changes only the eight hexadecimal digits in the unique `u00001`
Version_32 declaration. The actual invocation join's shorter body differs in
trailing path comments, as its existing source projection requires. This
review does not treat an arbitrary same-size body as an accepted family member.

The capture used compiler `-S` and directly invoked GAS with three environment
entries. The proposed compile graph uses `-c`, the internal object-output
option, a driver-generated assembly temporary, the raw relocated GAS pathname
and its additional `GCC_EXEC_PREFIX`, `COLLECT_GCC` and `COLLECT_GCC_OPTIONS`
entries. Those are explicit interface differences. The source basename and
semantic compiler options are preserved; the internal object-output name
matches that basename, and the existing output-path transfer excludes the
assembly operand from semantic source and recorded option text.

For GAS, both interfaces have five arguments and exactly `--64 -o OBJECT
INPUT`. The argv-pointer request is therefore 48 bytes, and the same output
name copy is twelve bytes including NUL. The raw executable/input paths fit
the selected P=512 interface. The additional driver environment names select
no GAS/BFD mode; neither environment supplies `AS_EMULATION`, `GNUTARGET` or
an optional assembly/debug selector. Startup retains the existing fixed
options, allocator and host-library premises. The retained `.s` input name
does not become the `.file` source basename or enable source debug scanning.
This justifies the named interface transfer without relabeling the capture
as an execution of the proposed graph.

The four independently parsed ELF objects are each 17,952 bytes. Each has
exactly one public four-byte `mainB` in `.rodata`, at file offset 1,360.
Masking precisely those four bytes makes all four objects byte-identical.
Deleting precisely the following data-directive line after the single
`mainB:` label likewise makes all assembly streams byte-identical. The
baseline object reproduces the accepted predecessor SHA-256
`b668f70341f147da7340df4ad5436206b052ec158a7108cd4bbc1b11fd9f3b4a`.

## Focused verification and limits

The author's **34 checks** passed, with its output redirected into reviewer
scratch so the frozen `checks.json` was not rewritten. A separate scratch
checker passed **663 assertions** across source equality, quartet assembly
and ELF parsing, 62 arithmetic boundary values, installed identities,
supplementary source pins and rejection cases. Its measured duration was
0.207498795 seconds, including the author's 0.011062663-second checks.
Changed compiler/assembler options were rejected. Changed fixed assembly,
fixed object data and checksum bytes were also rejected after repairing their
per-case hashes, exercising semantic comparison rather than only hash failure.
The scratch checker SHA-256 was
`c5849b68daf8befa01ac3741b07e67a55788f971064355ebb86bb81858840212`.

The archive retains the successful managed run
`20261019T145323-b23fa45c07bb` and the earlier attempt that stopped before tool
launch. Its eight retained executions, 0.226930716 tool seconds and
2.286502532 managed seconds remain historical evidence, not reviewer runs.

`Context.result` is intentionally a conditional family result. It does not
recognize a fresh Main, validate an arbitrary process graph, or check live
installed binaries; the manifest describes the retained tools. A complete
adapter must still bind the freshly computed Main-checksum edge, exact binder
source and selected invocation/configuration to this family. An opaque true
result or supplied success flag cannot replace that join. The installed
behavior, ordinary allocator, standard-library, OS/filesystem and physical
resource assumptions keep their established scope. No total/peak RAM bound,
new trusted-library audit, Oracle amendment or admission change follows.
