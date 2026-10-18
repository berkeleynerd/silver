# Selected native GPR parent: source and ALI join

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The [evidence](../evidence/retained-gpr-parent-20261018/README.md) joins the
indexed null family to native GPRbuild's own source reader. It supplies the
source-dependent representation terms and a successful fixed-context witness.
This is separate from the [native compiler](retained-native-expansion.md),
[binder](retained-binder-capacity.md), linker, and GNATprove's GPR2 parent.
It changes no language or production invocation.

## Exact selected execution

The selected fresh project has one Ada source, one source/object/executable
directory, no imports or extensions, and indexed Main naming. Its 411 bytes
equal the delivered generated null project. The compiler options additionally
select `-gnatx -Wno-free-nonheap-object`; linking additionally selects
`-fno-lto -fno-use-linker-plugin`, as in the existing candidate descriptor.
Native output directories start without objects, ALIs or binder exchange files.
Producer artifacts under `obj/gnatprove` are not native build inputs.

Two small Linux builds establish the parent configuration:

| Managed run | Purpose | Native duration | Outcome |
| --- | --- | ---: | --- |
| `20261018T122943-c12e0db35e8a` | Exact indexed project and combined proposed native options | 0.4591 s | Exit 0, empty stderr |
| `20261018T123112-8c4245919445` | Retain the otherwise-deleted generated configuration with `--autoconf=<path>` | 0.3446 s | Exit 0, empty stderr |

The second run answers the missing configuration-inventory question; it is not
a repeat proof audit. Both runs produce byte-equal executables and the accepted
13,432-byte binder object. The complete captured environment consists of PATH
(the selected GNAT/GPR bins and `/usr/bin:/bin`), `LC_ALL=C`, and a private
TMPDIR. Other source/project/configuration overrides are absent. The retained
configuration is 6,816 bytes, selects the installed native default runtime,
contains no imported project, and records its actual Gprconfig command.
The first run did not retain its temporary configuration; it must not be
described as having the second run's exact configuration bytes.

The existing relevant-behavior premise connects the inspected GPR source to
the installed tool. The successful executions establish acceptance of these
fixed inputs, not a source-wide numerical bound by sampling. Transfer below
uses the source read projection. Changed tool, environment, configuration,
path-length/equality class or directory inventory requires a new reconciliation.
No libc/OS implementation audit is added.

## Complete native Sinput load frontier

The inspected tree's six external `Load_File` call sites are:

| Caller | Selected input and branch |
| --- | --- |
| `gpr-part.adb:1516` | The fixed project and generated configuration, through the project parser; neither imports or extends another project |
| `gpr-nmsc.adb:8010,8983` | Main's naming-exception and object checks |
| `gpr-util.adb:2366` | Main's `Is_Subunit` check |
| `gpr-util.adb:162,204` | Complete-source checksum helpers, excluded in this fresh native build |

`Need_To_Compile` returns when the native object or dependency file is absent,
before `Process_ALI_Deps` and its checksum routes (`gpr-util.adb:4360–4385,
5719–5748`; the dependency parser begins at `:4862`). This argument concerns
fresh native builds, not arbitrary incremental GPR sessions.

The naming and subunit callers use Main's stored display path. `Load_File`
interns and deduplicates the pathname before incrementing the source table
(`gpr-sinput.adb:418–447`). Rechecking Main or reparsing the project therefore
does not add a source range. The selected process has at most **three distinct
physical source buffers**: project, configuration and Main. The source table's
initial ten entries suffice. Configuration XML belongs to Gprconfig's separate
fixed process, and GNAT's naming `.TMP`, System and runtime sources belong to
child processes; do not charge them to this Sinput table.

`Source_File_Is_Subunit` scans past trivia to the first compilation-unit token
(`gpr-sinput.adb:694–724`). Every null-family spelling reaches `procedure` and
returns false. It does not build Main's Ada tree or inspect its body. Its
source-dependent work is the physical buffer, leading-trivia scan and line
table; the token and name-table result is fixed. No author identifier text
enters the GPR project model through this path.

## Representation conditions

For each distinct physical file of B bytes, `Load_File` converts B to Integer,
allocates B+1 bytes including EOF, and starts the next source at
`4096 * ceil((last+1)/4096)` (`gpr-sinput.adb:450–478`). Define
`q(B)=4096*ceil((B+1)/4096)`. A sufficient order-independent condition is:

```text
each B + 1 <= 2^31 - 1
q(Main) + q(project) + q(configuration) - 1 <= 2^31 - 1 - 4096
```

The final 4096 pays for `Set_Source_File_Index_Table`'s increment after the
last occupied block (`:645–658`). This is a genuine shared source-position
counter, not an aggregate memory cap. Each separate allocation is also checked
against its pointer-difference representation; physical exhaustion remains
separate. Under the retained configuration the fixed contribution is
`4096+8192=12288`; the 69-byte witness gives total extent **16384**.

GPR starts each line table at 500 entries and doubles it when full
(`gpr-sinput.adb:47,76–102`). The checker counts the whole source's lines even
though the subunit scanner stops earlier. Repeated scans append only when a
new line start exceeds the greatest existing one
(`gpr-err-scanner.adb:2372–2383`). Thus the smallest `500*2^k` covering the
physical-line count bounds its backing. Requiring `32*capacity <= 2^31-1`
also covers its doubling and index arithmetic. Old and new backing arrays are
separate allocations, not a summed gate.

**Only CRLF, CR and LF reset physical columns.** FF and VT terminate logical
lines/comments but return `Physical=False` (`gpr-err-scanner.adb:2335–2360`).
The checker consequently retains their byte columns in the physical span and
expands tabs to eight-column stops. A final column at most 32766 leaves the
required 16-bit-column headroom (`gpr-osint.ads:63–72`,
`gpr-sinput.adb:227–273`, `gpr-err-scanner.adb:2254–2329`). FF/VT are research
family inputs; the current language still excludes them. This distinction
also exposed a correction needed in the earlier native research shape helper.

## Main ALI and the fixed parent context

Fresh native compilation uses `Phase_2_ALI` with `Read_Lines=>"DW"`
(`gprbuild-compile.adb:2011–2065,3693–3700`). `Record_ALI_For` can request W
and reinitializes the ALI tables (`:1600–1633`). No split-unit option is
selected. Standalone-library/interface closure paths are excluded by the
executable project; existing-binder up-to-date scans are excluded by the fresh
exchange directory (`gprbuild-post_compile.adb:4340–4375`).

The [native null ALI projection](retained-binder-capacity.md#gprbinds-separate-main-ali-parser)
already bounds the complete no-Xref Main ALI by **378 bytes**. The two new
witnesses have 355 bytes, nine A rows, one U, zero W and two D. GPR's parser
always enables U but leaves A disabled for DW/W (`gpr-ali.adb:673–677`);
variable G coordinates are unknown lines and skipped. It creates at most one
ALI, one unit and two dependency records, with no argument or with records.
The EOF-terminated raw buffer is at most **379 bytes**
(`gpr-osint.adb:459–553`). Timestamp and checksum fields have fixed widths;
checksum multiplication is explicitly modular Word arithmetic
(`gpr.ads:80`, `gpr-ali.adb:1338–1373`). No author-dependent name pool or
coordinate-decimal allocation is hidden in this parser population.

After those variable inputs are accounted for, the project/configuration
parser, selected tool configuration, queue, command vectors, exchange paths,
file lists and fixed initialization see the same source-read projection:
one Main unit, no imports, the same dependency names, selected options and
path-length/equality classes. Main's larger source buffer or leading trivia
does not enlarge those contexts. Their ordinary fixed requests transfer from
the successful selected execution; no cumulative heap-byte bound is inferred.
The [binder component](retained-binder-capacity.md) separately prices the
exchange and runtime argument/path interfaces. Future production must realize
the selected descriptor and its path bounds, rather than merely assert them.

This closes the selected native parent's source/ALI dimension under that fixed
context and the child-success/interface premises. It does not close GPR2,
GNATprove orchestration, the rest of the whole-process conjunction, nonnull
grammar families, or #119. The offline checker marks whole-pipeline capacity
false even when all six local arithmetic conditions pass.

Independent source review accepted this scoped result and reproduced its
offline output byte-for-byte. It also checked the excluded standalone-library,
gprinstall/gprls and existing-binder ALI paths, and confirmed that
`Source_File_Trim` has no caller in the inspected tree. No further native
execution was needed for that review.
