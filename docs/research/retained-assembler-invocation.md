# Indexed Main assembler invocation and subsidiary storage

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This joins the indexed native Main descriptor to the existing
[GAS](retained-assembler-capacity.md), [backing](retained-assembler-backing.md),
[startup](retained-assembler-startup.md) and
[ELF object](retained-elf-object-capacity.md) transfers. It also bounds the
remaining named parser scratch requests and the selected relaxation loop.
It does not establish complete GAS or end-to-end retained-tool capacity.
No compiler, assembler, linker, solver or Lean process was executed.

The [offline checker](../evidence/retained-assembler-capacity-20261018/check-invocation.py)
checks the existing seventy complete Binutils sources and six complete GCC
sources at `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Its retained indexed
descriptor is copied exactly from the independently reviewed native invocation
packet, commit `23f4ed506b`; this is a source-derived invocation, not a new
captured command. The production caller must supply that descriptor and its
controlled-environment, selected-target and input-search premises.

## GCC-to-GAS argument projection

The indexed native descriptor has thirteen GCC arguments excluding argv0:
`-c -x ada -gnatA -gnat2022 -gnata -gnato -gnatec=CONFIG -gnatem=MAP
SOURCE/main.adb -o main~1.o -gnateI1`. GPR compiles in the object directory
and supplies the explicit relative object name. The indexed change does not
rename the author source or Main entity.

The native Ada spec calls `invoke_as` when neither `-gnatc*` nor `-gnats*`
is present (`gcc/ada/gcc-interface/lang-specs.h:35–52`). With no `-S`, `-pipe`
or compiler-comparison switch, that spec supplies one temporary assembly file
to one assembler invocation (`gcc/gcc.cc:1328–1350`). The selected x86_64 GNU
target's default 64-bit mode supplies `--64`; no `-msse2avx` is present
(`gcc/config.gcc:2123–2130`, `gcc/config/i386/gnu-user64.h:34–53`).

The `asm_options` projection adds no verbose, warning, include, debug,
compression or explicit assembler-pass-through switches. Although `g*` can
lexically match `gnat...`, the debug fragment also tests
`debug-level-gt(0)`. Debug level starts at `DINFO_LEVEL_NONE`; the descriptor's
`gnat` options use their separate joined Ada option, so this test is false
(`gcc/common.opt:105–114`, `gcc/ada/gcc-interface/lang.opt:95–101`,
`gcc/gcc.cc:981–999,11142–11162`). The optional post-assembler command requires
`-gsplit-dwarf`, absent here (`:712–722`). No input argument is a response-file
reference and no user specs or plugins are selected.

Thus the derived assembler vector is exactly:

```text
AS_PATH --64 -o main~1.o ASSEMBLY_TEMP_PATH
```

Its **A=5** includes argv0. The actual output spelling has **P=9** bytes
including NUL. This P is the copied assembler output spelling, not the general
native descriptor's bound on every resolved pathname. The assembler executable
and temporary input paths remain under that independent path/environment
premise. This source projection does not claim a retained execution of the
indexed command or validate an arbitrary caller's environment.

GAS stores the existing argv pointers in a six-pointer notes object and copies
the output spelling (`gas/as.c:630–639,1173–1175`). There is no include option,
response file, command-line definition, listing, dependency generation,
synthetic CFI, compression, SFrame enabling option or extra input file. The
source-derived generated stream has no corresponding enabling directives.
The [installed SFrame defaults](retained-assembler-capacity.md#selected-installed-sframe-default)
therefore apply to this selected invocation.

The composed individual notes request/chunk bounds become:

```text
argument pointer request = 8*(5+1) = 48
Q = max(65528,48,9) = 65528
notes chunk <= max(4064,Q+241) = 65769 bytes.
```

The [output BFD lifetime](retained-assembler-startup.md#selected-output-bfd-lifetime-counter-join)
specializes to `P+32056 = 32065` cumulative requested bytes. Its separate
largest raw main-arena request remains 6,744 bytes. Neither the notes bound
nor BFD's counter includes the independent ELF string-table hash arenas.
This does not add a language total-RAM limit.

## Parser subsidiary requests

The prior generated-unit transfer bounds every assembly line by 64 bytes at
the selected 29-byte GCC identifier. The following direct-heap scratch requests
therefore have small source-derived ceilings, independently of the notes
and fragment obstacks:

| Request | Raw bytes, at most | Source |
|---|---:|---|
| Unquoted symbol-name copy | 26 | `gas/read.c:1763–1783` |
| Full instruction retry copy | 65 | `gas/config/tc-i386.c:7253–7257` |
| Register-expression fallback copy | 65 | `:17049–17091` |
| Pseudo-suffix expression copy | 65 | `:2187–2193` |
| GOT-token-removal scratch | 67 | `:13365–13447` |

The selected `.globl _ada_main` uses the unquoted-symbol route and frees its
temporary name (`gas/read.c:2450–2487`). Its actual name needs only ten bytes;
26 retains the prior compiler-label envelope. Quoted symbol names are absent;
quoted `.file`, `.ident` and section names use their separately bounded parser
routes. The instruction copies above are charged even when their fallback
branch is absent. Any copied instruction suffix is at most the 64-byte line,
and the GOT copy's `first+second+2` fits `64+3`. This bounds those individual
requests without depending on a brittle proof that every fallback is skipped.
The selected register-only instructions contain no GOT token and create no
GOT symbol.

Other expandable parser objects require source forms absent from the generated
stream: `.arch` stack pushes, `.pushsection`, section groups, macro definitions
or expansion, includes, `.func`/`.endfunc`, `.errif`/`.warnif`, `.startof.` or
`.sizeof.`, `.reloc`, `.eqv`, symbol versioning, general CFI escapes and state
stacks. Their branch conditions and constructors are retained in the excerpts.
Case-sensitive x86 lookup has no canonicalization hook and does not allocate
the alternate folded-name copy (`gas/symbols.c:216,959–989`). Low numeric
labels 0 through 4 use the previously bounded static counters. The conditional
obstack's initial 4,064-byte chunk was already charged; no conditional objects
are appended. The `.size` expression's at-most-40-byte notes request and its
single location symbol were already charged in the symbol transfer.

These bounds cover the named subsidiary sites. They do not expand diagnostic,
locale, stdio or allocator internals, and an exhaustive successful-path
GAS/BFD call inventory remains a separate completion check.

## Selected relaxation fixed point

The existing fragment transfer supplies at most 924 allocated fragments,
420 ordinary payload bytes and ten region increments per section. The
selected stream has fixed fill fragments, alignment fragments and CFI
location-advance variants. The conservative optional SFrame union adds only
its already bounded width variants; the actual indexed invocation excludes
SFrame. There are no branches, branch-padding options, `.org`, `.space`,
symbol-sized LEB128 fields, debug-line variants or broken-word reconstruction.
In particular, the `rs_leb128` oscillation repair cannot allocate another
fragment on this path (`gas/write.c:2955–2998`).

GAS creates `.text` before all compiler-produced and frame sections
(`gas/as.c:1425–1441`). Its instruction encodings are fixed; alignment depends
only on the already fixed prefix. The first forward address walk establishes
all text labels. Frame advances then depend only on those text-label
differences, not on their own frame-section addresses. Their estimator and
relaxer compute the same size from that unchanged difference
(`gas/ehopt.c:480–525`). The optional SFrame width has the same dependency on
the fixed text function size (`gas/sframe-opt.c:34–108`). Alignment in each
later section depends only on its established prefix. No reverse dependency
changes text when those metadata widths are chosen.

Consequently each selected `relax_segment` has zero growth on its first inner
sweep after the estimating/address walk. It adds no allocation and does not
reach the infinite-relaxation diagnostic. The outer section walk can report
changed addresses once through `last_fr_address`; the second walk has identical
addresses and terminates (`gas/write.c:2156–2184,2681–2784,2834–2859,3145–3186`).
Its signed pass counter reaches at most two. The unused safety counter still
fits its unsigned-long product: `frag_count^2 <= 924^2 = 853776`. Region and
address arithmetic retain the earlier independent bounds. This result uses
the selected fragment classes and dependencies; it is not a convergence
argument for arbitrary assembler input.

The remaining whole-assembler composition includes explicit input-line/event
counts, exhaustive successful-path call coverage and the documented host-library
premises. Binder-generated objects, final linker layout and other source
families remain separate. The indexed argument projection and these narrow
storage/fixed-point results do not close #119 or enlarge the admitted language.

Independent narrow review replayed the seventy Binutils and six GCC identities
and the indexed descriptor checker. It inspected the full selected driver
specs, scratch-copy arithmetic, initial address/alignment walk, CFI estimator
and relaxer, and outer changed-address loop. It accepted the argument projection,
request bounds and selected fixed point, retaining the earlier emitted-stream
and fragment/section inventory as inputs. It did not re-establish that earlier
inventory or exhaustive successful GAS coverage.
