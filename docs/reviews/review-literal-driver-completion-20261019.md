# Independent review: current literal driver and collect2 completion

2026-10-19 UTC. Owner-authorized research [#145](https://github.com/berkeleynerd/silver/issues/145)
within [#119](https://github.com/berkeleynerd/silver/issues/119).

**Accept the bounded driver/collect2-shell completion; no material findings or
implementation rework required.** The source argument covers the three current
17-position driver invocations and fresh collect2 representation/lifecycle
under the accepted literal graph. Child bodies, whole-native composition,
production adoption and SPARK/Lean correspondence remain separate.

## Frozen inputs and method

Original implementation: `63e7b6fb25acd6bae9fd7bb7cb3597cd071f9ab0`.
Integration input: `fcd2d99a6bd1c8f1143e9d3f5a7852644b4421f3`.
The separate review worktree was `tmp/literal-driver-completion-review-20261019`.
The [research argument](../research/retained-literal-driver-completion.md) and
all ten files of its [evidence packet](../evidence/retained-literal-driver-completion-20261019/README.md)
matched the original implementation bytes. Python syntax and JSON parsing passed.

The review examined the callable attachment, checker, retained results and
round record, source manifest/archive, input pins and gcc/collect2 lifecycle
inventory. A fresh Context checked the 22 repository inputs, all 71 selected
source/configuration files, installed configuration/executable identities and
absence of all five implicit specs candidates. Source inspection used the
pinned GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` from the packet;
coordinates below count literal LF characters, including across form feeds.
Existing driver/environment, initial diagnostic-layout and collect2 source
arguments were reused for their stated interfaces, not as evidence that a
historical smaller argv or another executable's roots cover the new inputs.

The accepted domain still requires actual recognized source bytes, exact
selected options/environment, stable configuration, LP64, complete resolved
paths bounded by P=512, relevant source/tool behavior, successful allocation
and established library/OS interfaces. Finite probes and matching bytes do not
replace the source argument. No candidate implementation file was edited.

## Source challenges and disposition

`gcc.cc` process-command, spec-dispatch and input-selection paths support the
source-independent driver projection. The selected driver consumes pathname
metadata and fixed specs; it does not parse Main, binder source, ALI or object
contents. Response files, external specs, wrappers, compare-debug, save-temps,
plugins and native-CPU detection are excluded by the actual graph. Path bytes
passed through `give_switch` use `inswitch=1` (`:6170–6208,7680–7725`), so they
do not become spec syntax. Child status remains scalar and inherited output
streams do not become GCC-owned capture buffers.

The current switch/infile partitions are 14/1, 12/1 and 9/12. Binder's duplicate
switches remain present; its explicit tune/arch suppress default insertion.
The separated `-o` operand has its own two-pointer request and contributes a
quoted COLLECT_GCC_OPTIONS field (`:5637–5715`). The sentinel slots fit the
16-record initial arrays. Decoded/default records, the 83-record compiler table,
45 static spec entries plus extra/link specs, and current multilib match-array
substitution have separate source owners. No historical 13/14-position driver
or 288-byte multilib value pays these current requests.

The fixed selected spec graph has no cycle. Guards exclude native CPU, dwarf,
comparison and pass-through helpers; retained `gnat*` switches do match `g*`,
but debug level zero stops the dwarf-helper branch. The named-chain, literal
brace and one-level helper bounds cover the selected interpreter recursion.
Each helper uses a fresh small argument vector; saved partial objects remain
covered before their signed narrowing (`:7045–7186`). The 128 event allowance
covers the fixed child arguments, default/helper contexts and temporary marks;
it is not a source-size-dependent allocation allowance. The pipe marker is
removed before separate frontend and assembler launches (`:5854–5874,6179–6208`).
The two compile argument vectors fit capacity 30; the 47-position collect2
vector plus terminator fits capacity 67. Ordinary obstack and option-obstack
formulas pay their own unfinished objects and alignment.

Ada lang-specs and the dump helper support exact frontend sizes 23/20, while
Main retains the accepted upper allowance 25. Output-derived dumpbases are
`main~1.adb` and `b__main~1.adb`; the actual Main input remains the source-bound
Main pathname. Compile-only processing does not set link-only COMPILER_PATH or
LIBRARY_PATH (`gcc.cc:9313–9316`). Its three added environment fields therefore
give 10/6 entries. Link nevertheless searches for `lto-wrapper` and constructs
COLLECT_LTO_WRAPPER: the guard at `:8754–8772` is `have_c`, not fno-lto.
The packet pays that owner without selecting LTO execution.

Temporary association and deletion queues are bounded by the selected `.s`
producer/consumer edge and object output. The suffix copy, chosen temporary
directory, filename, prefix searches, relocation/canonicalization, quoted
paths, environment strings and PEX records have explicit individual bounds.
The absent-MAKEFLAGS jobserver constructor still forms the 71-character
message (`opts-common.cc:2095–2149`). Its C++ string allocation policy stays at
the established library interface; no omitted GCC-owned request was assigned
to that boundary. Driver(false,false) does not run the in-process-reuse
`driver::finalize` path.

Collect2's source arrays use current argc=47 (`collect2.cc:921–928,1001–1047`),
including its unused second-link and C-command arrays. The four retained f/m
fields are unchanged by the two added object operands. All four write demands
fit their separately allocated arrays. Prefix splitting/search and two
unused temporary names remain paid. No-LTO/no-collecting takes the first-link
and early-return branch (`:1626–1655`); it does not execute the later object
scan, generated C compilation or relink. Looking up nm/strip before that branch
does not imply executing them or reading object contents.

Both gcc and collect2 explicitly call `diagnostic_initialize(global_dc,0)`;
frontend N_OPTS is not transferred into these fresh processes. The file-cache
constructor creates 16 slots and each slot reserves 256 recent-line records
(`diagnostics/file-cache.cc:459–462,509–518`). The previously established common
layouts pay these and initial printer/sink controls; driver alone installs the
owned URLifier. Context initialization reads LANG, not LC_ALL, for theme
selection (`diagnostics/context.cc:217–226`): binder therefore selects emoji.
The subclasses add no fields (`text-art/theme.h:29–145`), so the existing
control bound covers this difference. Controlled environment keys exclude
extra diagnostic logging and output routes.

A separate byte-level inspection covered every GCC initializer in both
executables. An independently written decoder for the small x86 instruction
subset present in these roots checked all **441 instruction boundaries** and
reconstructed direct calls/callback assignments without reading the packet's
mnemonic or operand labels. It reproduced gcc's eight roots, 30 registrations,
nine destructor targets and ten other calls, and collect2's four roots, three
registrations, three targets and ten other calls. Every root terminates in a
return or direct tail call; no conditional/indirect branch occurs in this
inventory. This check supplements the packet's installed-byte/root checks; it
is not a replacement general disassembler or a new native execution witness.

The statistics initializer's three controls/backings agree with
`mem-stats.h:557–579`; GATHER_STATISTICS=0 keeps the maps empty. Diagnostics'
implicit destructor releases its vector member and does not call `finish`.
Borrowed JSON keys have false ownership bits, and the bidi vector is unfilled
on this route. Their destructor dispositions create no new selected GCC-owned
request. The two additional direct-registration byte candidates per executable
are the disabled function-static statistics path and linked atexit adapter.
Explicit driver/collect2 cleanup is already covered by the selected source
tails. CRT and C++ emergency-pool roots retain the stated runtime boundary;
gnat1's root inventory was not reused as gcc/collect2 coverage.

## Fresh evidence and review record

Independent scratch probes passed **593 checks in 0.8368707089975942 seconds**
on Linux 7.0.14 x86_64, glibc 2.43, at
2026-10-19 15:11:56.637664–15:11:57.474514 UTC. A new physical 199-byte source
has C=5, N=3, literal lengths `[1,0,2,1,0]`, and SHA256
`8f8e32b5eca7dae87efc194b90caf3036b9630164e8b88dab1a8860d267b244d`.
The probes independently reconstructed switch/infile partitions, quoted output
operands, frontend identities/environments and individual byte lengths; checked
vector transitions and obstack rounding; changed literal contents while
preserving the driver projection; rejected ten altered graph/source inputs
and four lifecycle mutations; and performed the root decoding above.
Scratch code/results remain in the review worktree's `tmp/driver-review/`.

The author's retained **7451 checks / 1.0553652340022381 seconds** were inspected,
not rerun. No native compiler, assembler, binder, linker, target, capture,
prover, Lean, broad predecessor replay or dependency installation ran. Earlier
successful evidence was reused where its inputs and assumptions still apply.

Selected reviewer: **GPT-6 Astra / Extra High**, assigned independently by the
lead. Runtime model/effort confirmation and token/cost measurements are
unavailable. Review started at 15:04:07 UTC and reached its report checkpoint
at 15:13 UTC, approximately nine minutes. Intended outcome was independent
source/interface/lifecycle review; achieved outcome is acceptance of that
bounded input, with no material finding or implementation rework. The live
harness goal was null at handoff. This report is the only committed deliverable;
the lead owns issue, integration and durable-memory updates.
