# Current literal GCC drivers and collect2 shared shell

2026-10-19, selected Linux x86_64 configuration, [#145](https://github.com/berkeleynerd/silver/issues/145)
within [#119](https://github.com/berkeleynerd/silver/issues/119).

This source argument closes the representation/capacity component of the three
GCC driver processes selected by the accepted [literal invocation join](retained-literal-invocation-join.md),
and the previously separate collect2 diagnostic/static initialization component.
It does not close the child compiler, assembler, binder-generator or linker
bodies. It changes no admission rule, production launcher or Oracle requirement.
The [callable packet](../evidence/retained-literal-driver-completion-20261019/compose.py)
accepts actual recognized source bytes and optionally an actual invocation;
the latter must equal the freshly derived accepted graph, including its source
identity, materialized files, environment and child interfaces. Historical
fixture artifacts never replace a generated Main or binder input.

The guarantee is conditional on the established relevant-source/tool-behavior,
LP64 ABI, stable selected configuration, complete resolved-path, successful
allocation and standard-library/OS interface premises. Allocation, process and
filesystem failures remain unsuccessful external outcomes. They cannot become
successful completion or redefine language membership. The existing interface
boundary does not require recursively proving libc or the C++ string allocator.
Every eventual Silver-owned implementation still needs SPARK Bronze/Silver and
Lean source correspondence; this Python packet is research evidence only.

## Exact read projection and child interfaces

The driver reads argv, its explicitly constructed environment, fixed compiled
specs/options/multilib tables, and pathname metadata/search results. Its input
lookup (`gcc/gcc.cc:9070–9107,9400–9470`) selects a compiler by the filename and
explicit language, without reading the input file. No selected driver opens or
parses the bytes of Main, generated binder source, ALI or object files. The
selected routes through `expandargv`, specs readers, compare-debug, response-file
output and spec functions are excluded below. Thus changing recognized Main
bytes cannot change this driver's control/data projection. Child return status
is a separate bounded scalar; child stderr/stdout are inherited streams, not
buffers captured or parsed by the driver.

All three current driver argv vectors have **17 positions**. The accepted
Main frontend allowance remains **25**, while source specialization of the
present relative `-o main~1.o` gives **23**. This is a derivation, not a new
capture. Binder's exact frontend has **20** positions; the retained binder
frontend witness corroborates its spelling/order. The link child has **47**
collect2 positions and **46** ld positions, including the executable each time.
The source of the last two counts is the accepted link join, not the old
45/44-position standalone link packet.

The packet exposes both frontend vectors and their generated environments.
Ada's `%{g*&m*&f*}` preserves retained switch order, its separate `%{W*}` emits
one warning option, and `%{o*:%w%*-gnatO}` emits `-gnatO` and the object name
(`ada/gcc-interface/lang-specs.h:35–52`, `gcc.cc:7680–7725`). A relative output
has no directory prefix, so no frontend `-dumpdir` is emitted. The output
basename without `.o`, followed by the source `.adb` extension, gives
`main~1.adb` and `b__main~1.adb` as **dumpbase**; Main's input remains the
actual `root/main.adb` (`:5250–5280,5430–5465,11027–11120`). The temporary
assembly argument has six generated characters; the graph's fixed-width
placeholder denotes that same producer/assembler-input edge.

Main's frontend receives ten environment entries; binder's receives six:
their seven/three initial entries plus GCC_EXEC_PREFIX, COLLECT_GCC and
COLLECT_GCC_OPTIONS. None of the selected fields needs apostrophe escaping.
The packet retains exact generated field order, argv/environment byte lengths,
and the general `A=max(24,P+8)` argument bound for later frontend composition.
At the retained paths, maximum individual argv storage is164 bytes including
NUL for both frontends; maximum environment entry storage is371/178 bytes.
These counts do not claim closure of frontend decoding or its N_OPTS classifier.

## Driver records, defaults and spec execution

`process_command` drops the `-x ada` pair, saves ordinary switches and stores
separate `-o` operands in an additional two-pointer array. In the linker route,
`-l` and each `-Wl,` comma fragment become infiles, not switches
(`gcc.cc:3851–3915,4450–4518,4730–4745`). The partitions are:

| Driver | Original switches + inserted defaults | Infiles | Separated output-pointer request |
| --- | ---: | ---: | ---: |
| Main |12 +2 =14|1|16 bytes|
| Binder compile |12 +0 =12|1|16 bytes|
| Link |7 +2 =9|12|16 bytes|

Binder's duplicate `-c` and `-gnatA` remain counted. Its explicit tune/arch
suppress target defaults. Link has five file operands, one `-ldl`, two fragments
from the first `-Wl` and four from the second. Switch/infile arrays including
sentinels fit their initial16 records: **384/512 bytes**. Initial decoded storage
is at most17*96=**1632 bytes** per driver; each inserted target default separately
needs192 decoded bytes and16 temporary argv bytes. There is no increase hidden
in the standalone13/14-position evidence. Each outfile array requests8*n_infiles;
each explicit-link-file array requests n_infiles bytes. The C driver hook adds
no extra outfile (`gcc/c/gccspec.cc`).

Configured languages are C, Ada and C++. The complete default compiler table
contains50 base records, five Ada records,27 C++ records and one terminator:
**83*32=2656 bytes** for its startup copy (`gcc.cc:1420–1550,8506–8515`,
`cp/lang-specs.h`, `ada/gcc-interface/lang-specs.h`, `Makefile.in:2680–2686`).
The installed `tm.h` selects no EXTRA_DEFAULT_COMPILERS. There are45 static
spec-list entries, one x86 `cc1_cpu` extra record (**48 bytes**), and the separate
link-command spec:47 dumped blocks in total. This count is checked against the
retained complete dump and selected target headers, not extrapolated from
which specs happened to execute. Builtin libgcc/link-spec initialization only
concatenates their fixed pieces (`:1850–2052`); the final retained strings and
each contributing piece fit2902 bytes including NUL. No specs reader adds
records or alters strings.

The five exact initial specs candidates from the [environment argument](retained-native-environment.md)
are checked absent again by the new Context. No argv starts with `@`, no user
spec/plugin/compare-debug/wrapper/save-temps option is supplied, and environment
search/spec overrides are absent. Native CPU detection is excluded by generic
x86-64 defaults. The selected interpreter graph is:

- Compile: Ada -> cc1 -> cc1_cpu; Ada -> invoke_as -> asm_options ->
  asm_debug_option and asm; the asm-final dispatch is empty.
- Link: link_command -> linker, link, startfile, link_libgcc (`%D`), link_ssp,
  link_gcc_c_sequence -> libgcc twice and lib, endfile, post_link.

Named/letter dispatch has no selected cycle. The deepest literal brace nesting
is12 in link_command; its longest selected named chain has three edges. Paying
four levels each of12 brace layers plus dispatcher/helper slack fits the
conservative64 spec-expansion nesting allowance. This counts nested spec
expansions; fixed C++ parser frames and sufficient stack retain their established
interface premise. Skipped brace syntax still scans only
the finite containing fixed spec. Each input/mark/switch loop is bounded by the
arrays above; each local copied spec/function substring is bounded by2902.
No source text enters this syntax. `give_switch` sets `inswitch=1`, so pathname
bytes are data, not freshly interpreted specs (`:6170–6208,7680–7725`).

Compile has three helper calls: self-spec `gt(1)`, dumps with zero arguments,
and assembler `debug-level-gt(0)` (the `gnat*` flags match `g*`, but debug level
is zero). Link has the self-spec gt, one link gt and nine sanitize predicates.
Those predicates return null under the exact options. The otherwise reachable
include, pass-through-libs, local_cpu_detect, debug comparison and dwarf helpers
are not selected. Helper argument count is at most one and helper nesting one;
its fresh ten-pointer vector requests88 bytes. Its saved partial-object size
is covered by the string bound before narrowing to int (`:7050–7185`).

The compiler argument buffer pays the accepted25-position Main bound, plus
terminator/transient pipe marker: capacity30, request**248 bytes**. Binder's
20+1 also grows to30. Collect2's47+1 grows10 ->20 ->30 ->45 ->67, request
**544 bytes**. `%@{L*}` and `%o` do not open response files when
at_file_supplied is false (`:6560–6675,6695–6728`). The transient `|` between
frontend and assembler is removed before execution without `-pipe`, so every
execute has one command. There are at most128 argument/temporary-queue events
per driver on the selected expansion, including helper/default contexts;
actual child argument totals are28/25/47. Counts are fixed independently of Main.

## Strings, paths, obstacks, multilib and launches

P=512 bounds each complete raw, resolved, generated and search path, including
NUL under the accepted graph. Bounds below deliberately retain an extra byte
where older component formulas used P as non-NUL characters. The path alphabet
excludes whitespace, apostrophes, percent signs, dollars and commas in variable
roots; the link's fixed `$ORIGIN` is an ordinary argument byte string.

Let F be the number of retained switches **plus the separated output operand**.
The individual COLLECT_GCC_OPTIONS object is at most
`20+F*(4*(P+8)+4)+4*P+14` bytes, paying quoting and optional dumpdir. Omitting
the output operand would undercount the current command. COMPILER_PATH and
LIBRARY_PATH objects are bounded by `14+6*(P+1)` and `14+19*(P+1)` from the
exact two/five prefix records and their six/nineteen candidate enumeration.
Directory filtering can only remove those candidates (`:2818–3031`). Three
command-line `-L` switches do not create more driver prefix records. Each prefix
node is32 bytes (two pointers, three ints and padding); the include-prefix list
stays empty.

Other individual objects are bounded by P+1 for copied paths, 2P+1 for quoted
paths,6P+37 for the dumps helper result,5P+1 for relocation output and8*(P+2)
for relocation directory pointers. The selected lrealpath branch has a4096-byte
local buffer and a separate P+1 copy, including canonical input/output comparison
(`libiberty/filename_cmp.c:213–221`); P must cover the resolved pathname too.
The selected prefix/keyed environment excludes GCC_ROOT and BINUTILS_ROOT.
The earlier driver/environment source arguments establish the concrete Unix
realpath/posix_spawn selection; this join changes their bounded arguments.

Even with both no-LTO flags, the **link driver searches `lto-wrapper` and builds
COLLECT_LTO_WRAPPER**. The guard is `have_c`, not fno-lto
(`gcc.cc:8754–8772`). Its search/path and P+20 environment object are paid;
LTO execution and plugin insertion remain excluded. COLLECT_GCC needs P+13,
and GCC_EXEC_PREFIX P+17, conservatively including the key and NUL.
`driver(false,false)` disables the env-manager restore cache; putenv receives
these already allocated strings without an additional GCC key/value vector.

For ordinary obstack unfinished size s, the selected chunk request is at most
`max(4064,s+15+s//8+100)`; adding15 for alignment also fits PTRDIFF_MAX.
This covers main spec, collection and multilib obstacks separately. Each
option canonical object is bounded by `W=4*(max(24,P+8)+67)`, and each options
chunk by `max(4096,W+116)`, using its whole-object allocation pattern. All signed
narrowings and individual requests are checked. These are **individual object**
bounds; neither summed RAM, address-span nor the parent arena is used as a child
admission bound.

Multilib strings have maximum unfinished size85; the one default record is16
bytes, two temporary match records48, and the retained match array is at most
`(1+14)*24=360`. Recursive used_arg sees the already allocated array and cannot
reenter its initialization. The OS/multiarch strings are9/17 bytes. This is the
current14-switch substitution of the older11-switch source derivation, not a
replay of its288-byte result.

Each compile driver creates one `.s` association (40-byte node and three-byte
suffix copy). TMPDIR length48 dominates all selected fallback directories, so
choose_tmpdir requests50 bytes and its `ccXXXXXX.s` name60. The same association
feeds both compiler and assembler. At most two distinct names (assembly and
object output) enter16-byte deletion-queue records; copies are bounded by P+1.
Repeated recording is a bounded scan of this list. Link has at most its one
output name and no `.s` association. Cleanup deletes/frees existing records;
no new contents are read (`:2680–2800,6380–6555,9352–9386`).

Main/binder launch two sequential children; link launches one. Each command
record is16 bytes, each selected PEX object144, and each one-element PID/status
array and local wait status4. No wrapper, pipe, timing report, file-action list
or internal-error retry is selected (`:3258–3600`; `pex-common.c`, `pex-unix.c`).
Normal nonzero child status stops the remaining spec; bounded signal/status
handling does not replay compiler output. Exit/signal counters cannot exceed
the fixed child count. Source-linked service failures report failure using
fixed format strings, bounded program/path values and the established C-locale
errno/signal interfaces; they do not import arbitrary source text into a driver
message. The zero-message successful route has no diagnostic source-cache read.

`detect_jobserver` runs even after successful compile-only input processing.
With MAKEFLAGS absent, it constructs the fixed `--jobserver-auth=`, `fifo:` and
unset-variable strings; the longest final std::string value is71 characters,
72 including NUL (`opts-common.cc:2095–2158`, `opts-jobserver.h`). Three string
controls and scalar fields fit128 bytes under the selected ABI. No FIFO/token
operation or replacement MAKEFLAGS occurs. The C++ string library's capacity
policy remains its existing interface, rather than a fictitious empty jobserver
constructor or a new library-internals proof obligation.

## Fresh diagnostic initialization and executable lifecycle

Both `driver::global_initializations` and collect2 main call
`diagnostic_initialize(global_dc,0)` (`gcc.cc:8393`, `collect2.cc:915`). Their
classifier allocation request is **zero**, not frontend N_OPTS*4=10224.
The fixed [process-shell layout derivation](retained-native-expansion.md#current-command-and-initial-diagnostic-buffers)
transfers by these explicit calls to common constructors: initial16 file-cache
slots4104 bytes; each slot's256 recent-line records6152; each control object at
most512; each initial printer obstack chunk at most4096; sink vector40. This is
a type/constructor transfer into each fresh process, not a compiler-root claim.
Driver adds one GCC URLifier and its72-byte vector. Collect2 installs none.
No options manager/compiler client-data hook is installed by these driver roots.

Main/link (and inherited collect2) have LANG=C and select ASCII. Binder lacks
LANG, so context initialization selects **emoji**, despite LC_ALL=C. The
ASCII/Unicode/emoji theme subclasses add no fields beyond their common virtual
control (`text-art/theme.h:29–145`);512 also bounds emoji. Controlled environments
exclude diagnostic logging, extra-output, color/URL overrides and GLIBCXX_TUNABLES.
No frontend file-cache contents or frontend-specific static-prefix claim is
silently imported.

The packet retains a new bounded read-only ELF inventory for **gcc and collect2**,
including all `.init_array` entries, both `.fini_array` entries, `.init`/`.fini`
and complete instruction bytes of every GCC-owned initializer. Installed binary
identities and each retained window are checked. Replay needs no disassembler.
The initial extraction used the already available Capstone5.0.7 Python package;
no native target was executed. Source correspondence uses the same GCC revision
and selected generated headers, without introducing deployment attestations.

| Executable | GCC initializer roots | GCC registrations | Distinct targets |
| --- | ---: | ---: | ---: |
| gcc |8|30|9|
| collect2 |4|3|3|

Each also has one CRT and one linked C++ emergency-pool initializer, kept at
the existing runtime boundary. GLIBCXX_TUNABLES is absent in all actual child
environments. There is no `.preinit_array`. Every GCC initializer is a
straight-line fixed store/call sequence, with no read of argc, argv, environment,
source, object or filesystem contents. Its only allocation calls create three
statistics maps, with <=96-byte controls and13-entry208/312-byte backings
(`vec.cc:114`, `mem-stats.h:557–579`, `hash-map.h`, `hash-table.h`). Installed
GATHER_STATISTICS=0 keeps those maps empty. The other constructor call clears
the fixed diagnostic counter array.

The source dispositions of the registered targets are independently attached:

- One statistics descriptor and one diagnostics::context in each executable.
  Statistics destruction frees the three empty maps; the implicit context
  destructor releases its sink vector, without invoking context::finish.
- One bidi semi_embedded_vec in each executable; no lexing fills it on this
  route, and destruction releases only existing extra backing.
- gcc alone has27 borrowed JSON-property keys across six destructor targets.
  Their initializers store fixed literal pointers and false ownership bits;
  `json.h:125–137` and `label-text.h:31–46` make destruction release-only.

This separately establishes zero new GCC-owned static-exit requests for these
executables. The old gnat1 lifecycle census was used for source dispositions,
not as an inventory of different executable roots. A conservative full-.text
relative-call/tail search finds exactly two additional __cxa_atexit byte
candidates per executable: the GATHER_STATISTICS-disabled function-static
hash-table statistics descriptor and the linked atexit wrapper. The latter
serves the explicit driver deletion/collect2 cleanup callbacks already covered
by their selected source tails; it is not another unknown static object.
The source and retained windows distinguish these from the initializer sites.

The standalone gcc main constructs driver(false,false). Its ordinary destructor
frees decoded and explicit-link arrays. It **does not** run driver::finalize,
whose elaborate environment restore/diagnostic teardown serves in-process reuse.
Collect2's explicit cleanup and successful no-collecting early exit remain the
[collect2 source transfer](retained-link-inputs.md#collect2-argument-and-launch-storage).

## Current collect2 shell substitution

The accepted47-position child updates the existing collect2 array formulas:
first ld `(47+4)*8=408`, second unused ld `(47+11)*8=464`, input list47*8=376,
unused C command `(47+9+8+4)*8=544`. Write demands including terminators are
bounded by48,49,47 and20 slots respectively. The four copied `-f`/`-m` fields
are unchanged; the two added object operands affect input/ld counts only.
Current COLLECT_GCC_OPTIONS has the retained driver fields plus output/dumpdir;
its bounded field lengths feed the same per-field obstack rule, not a whole
source/file buffer.

Prefix lists have at most six COMPILER_PATH and three PATH nodes,16 bytes each;
filtering can shorten the former. Finder strings are bounded by2P+1 and splitter
scratch by the enclosing environment length+3. Two unused collect2 temporary
names are each48+18=66 bytes. No response-file argument or plugin is supplied;
-fno-lto and the explicit option field set LTO_NONE. No collecting/nm/generated-C
or relink route follows the selected first link. There is one PEX launch with
the previously established one-child records. Object/linker interiors stay at
the explicitly separate ld/BFD join; the successful no-LTO witness is reused
only for its fixed interface projection.

## Evidence and integration status

The new packet retains71 complete source/configuration files, their correspondence
to the existing GCC revision manifests,22 repository inputs, and both executable
root inventories. The checker exercises actual raw-source variants, accepted
runtime-path variations, descriptor/environment/source-identity mutations,
frontend spelling against the retained binder capture, vector boundary counts,
all individual arithmetic and malformed ELF/root-record mutations. These are
focused offline checks; no compiler, assembler, binder, linker, prover, Lean or
broad predecessor corpus replay ran.

The unchanged fixed version/configuration initialization also has the identical
read projection in the retained successful no-LTO driver-only result: version
copy (`gcc.cc:4818`), generated option-structure defaults (`opts.cc:437–465`)
and fixed target setup read no Main bytes. This is a fixed-request acceptance
transfer for those same constants. The changing arguments, path-derived copies,
LANG-selected theme and arrays are independently priced above; success of the
old smaller argv does not pay their new sizes.

The output has no remaining **driver/collect2-shell** capacity obligation under
this source projection. It exposes its child interfaces for the aggregate native
composition. Whole-native/whole-pipeline capacity, production adoption and
SPARK/Lean correspondence remain false here. The source argument and independent
review are required along with successful checker output; a hash match or sample
success alone establishes neither universal source projection nor tool behavior.
