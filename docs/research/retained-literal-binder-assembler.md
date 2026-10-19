# Selected output-binder assembler checksum family

2026-10-19, owner-authorized [#145](https://github.com/berkeleynerd/silver/issues/145)
within [#119](https://github.com/berkeleynerd/silver/issues/119), Linux x86-64.
This closes a named composition gap between the reviewed output-binder
compiler family and its assembler. It is conditional on the accepted selected
source/options/invocation and relevant installed-behavior premises. It does
not establish complete native capacity or change admission. Independent review
is pending.

The [packet](../evidence/retained-literal-binder-assembler-20261019/README.md)
retains the missing assembly inputs, four focused compiler/assembler executions,
source identities and a callable offline replay. The existing compiler family
proof is reused; no collector or compiler proof suite is repeated.

## Fixed family and the only variable assembler datum

The [binder invocation join](retained-literal-invocation-join.md) selects the
fixed output binder, with an arbitrary uint32 Main checksum. The
[compiler checksum proof](retained-binder-checksum-closure.md) establishes the
unchanged executable semantic graph, fixed symbol/section/relocation layout,
and the separate variable integer/cache allocation bound. The generated
Version_32 scalar is public, readonly, non-COMMON and never read by executable
binder code. Its only assembler effect is the four bytes at `mainB`.

This argument uses those source projections, not object size as a proxy for
assembler allocation. `varasm.cc:2452–2480` emits four zeros when the scalar
is zero. The target's `ASM_OUTPUT_SKIP` is `\t.zero\tSIZE\n`
(`gcc/config/elfos.h:106–111`). Otherwise the integer arm, `gen_int_mode` and
`assemble_integer_with_op` emit one signed SI constant as `.long`
(`varasm.cc:3122–3160,5534–5548`, `emit-rtl.cc:525–553`).
`final.cc:3720–3722` prints `CONST_INT` using signed decimal. Thus the complete
variable line is exactly one of:

```text
        .zero   4
        .long   d
```

Here `d` is the signed-32 interpretation of the nonzero uint32 checksum.
It has at most ten digits and one minus sign. The maximum directive including
tabs and LF is 19 bytes, attained by `-2147483648`. Changing this datum adds
no declaration, semantic identifier, emitted label, filename, instruction,
relocation, CFI directive or section selection. The accepted compiler argument
also covers checksum-dependent integer-cache allocation without promoting it
to a label or executable expression. The captured assembly equality below
checks this implication on the four probes; it is not its universal premise.

## GAS source projection and representability

For nonzero checksums, `gas/expr.c:261–370` accumulates at most ten decimal
digits into a 64-bit value. Every prefix is at most 2147483648. The ten-digit
length is below the 18-digit conservative small-number threshold; the bignum
branch and its alternative expression objects are absent. There is no local
label suffix, symbol, relocation operator or general expression. A negative
number adds one recursive operand frame and applies the existing unsigned
negation (`:1091–1121`); the resulting signed value fits int32 and int64.

The `.long` route always reserves four data bytes. In
`gas/read.c:4547–4773`, it is `O_constant`, size four is below the eight-byte
`valueT`, no relocation is requested, and no `fixS`, broken-word record,
bignum or symbol is created. The truncation-warning condition is false for
every signed32 operand. `md_number_to_chars` writes four bytes; subsequent
fragment, relaxation, section, symbol and BFD representation demands do not
read their value. Negative/positive spelling changes neither the allocation
graph nor the per-line count; its bounded local arithmetic is given above.

The zero case is a distinct fixed successful stream. `s_space` reads repeat
four and the default zero fill. Its constant path creates an `rs_fill` fragment
(`gas/read.c:3505–3600`), unlike `.long`'s byte append. The zero witness therefore
owns its actual fragment allocation; no claim that zero and nonzero have the
same fragment count is made. There is no value-dependent family left within
that case. Both streams write the same four-byte extent and preserve all
symbol values, section sizes and fixups.

The complete generated assembly has 1262 LF lines, at most **31743 bytes**
and longest line **87 bytes**. The one varying line is shorter than that fixed
maximum. GAS's input block is 32768 bytes (`gas/input-file.c:40–74`), and its
initial scrub allocation has 65536 payload bytes (`gas/input-scrub.c:148–149`).
Short OS reads do not change these capacities: the unfinished line is bounded
by 87, and its buffer-growth threshold is 32768 (`:429–436`). Source and
line-position arithmetic is well inside its signed/unsigned representations.
The checksum never selects a new input, macro/include, listing or debug path.

The successful zero and nonzero executions establish representability of
their respective **fixed** assembler requests and selected fixed control
paths. The source projection transfers the nonzero case to every other
nonzero signed32 datum; the zero stream is itself fixed. This is the same
fixed-request method already used for the binder compiler. It claims no
ordinary-heap peak, total-RAM bound or universal property of arbitrary GAS
source. Variable raw path spelling and argv storage remain charged through
the selected assembler invocation/startup interface, with P=512 and five
arguments. The fixed object name `b__main~1.o` occupies 12 bytes including NUL.
The `.file` name is the fixed source basename, not a parent-directory string;
there is no source-file debug read. The later complete native adapter must
bind these premises to its freshly computed actual-source invocation.

## New evidence, cost and limits

Managed run `20261019T145323-b23fa45c07bb` reserved one native worker and
completed four compiler `-S` calls followed by their four assembler calls.
The checksums were the retained `d02a2ed5`, zero, `80000000` and `ffffffff`.
The four assemblies are byte-equal after replacing the single `mainB` data
directive. Every tool exited zero with empty stdout/stderr. The baseline object
is byte-equal to the earlier accepted output object:
`b668f70341f147da7340df4ad5436206b052ec158a7108cd4bbc1b11fd9f3b4a`.
All objects occupy 17952 bytes; their only differences are the four checksum
bytes. The offline checker verifies this last property separately.

This observation deliberately retains assembly using `-S`; it is not relabeled
as an execution of the entire proposed four-job graph. The semantic compiler
options, indexed source basename and 113-byte source directory are preserved.
The controlled temporary directory has 55 characters, within P=512; the
assembler reads a named retained `.s` instead of a driver-deleted temporary.
Those source/path interface changes are explicit. No binder generation,
Main compilation, link, prover, Lean or full test suite ran.

The four pairs took **0.226930716 seconds** inside the capture script and
**2.286502532 seconds** including managed-run overhead. The first managed
attempt `20261019T145309-7071318b310c` stopped before native tool launch because
the integration worktree has no toolchain setup. The successful run used the
existing root installation, with an isolated owned workspace; no bootstrap,
toolchain change or shared artifact deletion was performed. Both run records
are retained. The initial offline replay took 0.015248806 seconds.

The lead did this bounded integration/source work; runtime-confirmed lead
model/effort and token/monetary cost are unavailable. Independent source and
composition review remain separate. Installed behavior, ordinary allocator,
OS/filesystem and physical-resource premises retain their established scope.

