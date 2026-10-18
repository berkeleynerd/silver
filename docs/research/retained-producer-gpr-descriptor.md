# Selected null-producer GPR descriptor

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Updated for the delivered [indexed-Main repair](../indexed-main-discovery.md).
This joins the [generic ALI equations](retained-producer-ali.md) to the
candidate production invocation derived from the selected GPR/SPARK sources
and installed configuration bytes. It covers the complete null token family
with permitted case/trivia. It does not close GPR's project/configuration and
process capacities or establish installed-executable/source identity. The
[evidence](../evidence/retained-producer-gpr-descriptor-20261018/README.md)
contains an offline reconstruction; no compiler, prover or other toolchain
execution was performed.

## Selected configuration branches

Silver emits one executable project with one Ada source, `main.adb`, explicit
`for Body ("Main") use "main.adb" at 1;`, no imports and the three compiler
switches `-gnat2022 -gnata -gnato` (`src/silver.adb:103–122`). The selected compiler is GNAT16.1, default runtime,
canonical target `x86_64-linux`. No owner/project/command-line compiler or
configuration override, cross target, alternate database, second source unit,
CodePeer, distributed build or make jobserver is selected. The fixed effective
source/search environment and source correspondence remain the existing
candidate-descriptor premises; a version string alone does not establish them.

The installed native and producer GPR configuration directories contain
byte-identical XML/entity inputs. The checker parses all63 XML files, including
local external entities, and evaluates their compiler/target/host filters.
Exactly four configurations affect Ada's Compiler package for this selection:

| File and configuration index | Effect |
| --- | --- |
| `0_default.xml`,0 | Default `.ads`/`.adb`, lowercase, hyphen naming; unit-based Ada |
| `gnat.xml`,0 | `-c -x ada -gnatA`; `-gnatem=` mapping; `-gnatec=` configuration; include-path-file attribute |
| `gnat.xml`,8 | Default naming-pattern templates; optional multiunit switches; Config_File_Unique=False |
| `gnat.xml`,11 | Defines `-fPIC` for library compilation; this executable project does not select it |

The selected GPR matching source uses OR within one compiler filter group,
AND between groups, and the explicit negate/host/target conditions
(`gpr-knowledge.adb:980–1040,3130–3147,3230–3307`). The offline check gives
the same selected set for `x86_64-linux` and `x86_64-pc-linux-gnu`.
Neither selected compiler configuration supplies an include-switch, dependency
switch, source prefix, object-file switch, trailing switch or compiler response
format. Those Language_Config fields default to empty/None
(`gpr.ads:792–910,986`). The Linker response-format setting is a different field.

GNATprove adds the `frames/config.xml` database for phase1: object suffix `.ali`
and ALI_File dependencies. Translation adds `gnat2why/config.xml`: object suffix
`.spark`, ALI_Closure dependencies and `-gnateO=`. Neither modifies naming or
compiler arguments other than that object-path switch. `--gnatprove` makes
`Get_Compiler_Driver_Path` select `gnat2why` (`gpr-util.adb:3798–3831`).
Data representation omits this mode and uses GCC.

## Compiler argument and ALI-switch counts

`Set_Options_For_File` appends required switches, the project switches, then
explicit `-cargs:Ada` (`gprbuild-compile.adb:2163–2301`). The selected GNATprove
caller adds `-gnatc -gnates=<options>` and, in phase1, `-gnatis`
(`gnatprove.adb:180–330`). Native-target selection supplies no `-gnateT`
(`configuration.adb:310–358`). The remaining GPR additions are one generated
configuration argument, one mapping argument, the absolute Main path, and
only in translation an object-path-file argument (`gprbuild-compile.adb:2478–2578,
2656–2837,3528–3537`). Its empty Include_Option does not generate `-I`; the
mapping-file selection plus default Use_Include_Path_File=False does not create
an include-path file through that branch (`:3248–3400`). Inherited search
variables remain an environment premise, not additional compiler switches.

The explicit index adds `-o main~1.ali -gnateI1` in phase1 and
`-o main~1.spark -gnateI1` before the object-path argument in translation.
GPR derives the indexed name with the configured suffix (`gpr-util.adb:2074–2086`);
its nonzero-index branch supplies `-o` even without Object_File_Switches
(`gprbuild-compile.adb:2507–2543,2759–2789,3527–3537`). This is source-derived,
not a retained full argv capture.

The checker retains the ordered path-parameterized argv lists. **Both
producer phases have 16 arguments excluding the executable.** If P bounds each
full path, phase1 argument payload is at most `4P+91`, translation at most
`5P+94`, and an individual argument at most `max(12,P+8)`. NUL termination and
pointer vectors are additional independent objects; the frontend Args array
has 16 entries. The selected compiler response format is None, so the GCC_GNU
response-file branch is not entered (`:2986–3068`). These argument bounds do
not establish GPR's other containers or process-launch capacity.

SPARK's alternate Back_End instantiates **Adabkend**, rather than the GCC
Back_End (`src/why/back_end.adb:45–52,133`). Adabkend discards `-c`, explicitly
stores both `-x` and `ada`, and sends frontend switches to Switch.C
(`adabkend.adb:106–200,252–283`). It discards `-o` and consumes its following
argument (`:110–117`); neither creates a stored A row. `-gnateI1` sets
Multiple_Unit_Index and is stored (`switch-c.adb:692–696,1692–1694`). `-gnatA`, the three project switches, `-gnatc`
and `-gnatis` each store one switch. `-gnates=`, `-gnatec=`, `-gnatem=` and
`-gnateO=` return without storing their pathname payloads
(`switch-c.adb:311–315,497–529,710–732,738–754,790–812`). Therefore:

| Phase | Stored compilation switches | A / payload sum / longest |
| --- | --- | --- |
| Globals/phase1 | `-x`, `ada`, `-gnatA`, `-gnat2022`, `-gnata`, `-gnato`, `-gnatc`, `-gnatis`, `-gnateI1` | 9 / 53 / 9 |
| Translation | Same without `-gnatis` | 8 / 46 / 9 |

Translation disables ALI output, so its eight switches are table/storage
population, not eight newly emitted A rows. The historical unindexed descriptor
had eight/seven switches. The indexed descriptor supersedes those counts; the
old direct probe's extra `-I` and non-temporary naming filename are not transferred.

Data representation has 18 arguments excluding GCC: the leading/project seven,
`-S -gnatR2js -gnatws -gnatx -gnatis`, config, map, Main, and
`-o main~1.o -gnateI1`. It remains a
separate native-invocation join. The ordinary native build's descriptor cannot
be substituted for it.

## Naming source exists but adds no ALI dependency

`Create_Config_File` writes each distinct naming scheme once and adds per-unit
pragmas only for naming exceptions (`gprbuild-compile.adb:682–703,808–941`). The
single project has two default patterns plus one explicit indexed exception:

```ada
pragma Source_File_Name_Project (main, Body_File_Name => "main.adb", Index =>  1);
```

The first two lines remain byte-equal to the retained 244-byte pattern pair.
The indexed template and Ada index image add 83 bytes including LF, for
**327 bytes in three lines**. This reconstructed configuration is not a new
temporary-file capture. Its aligned source-range charge remains 4096.
The [native indexed analysis](retained-native-expansion.md#indexed-main-invocation-and-source-buffer-delta)
prices the same frontend parser/configuration route: 18 ordinary nodes,
162 dynamic slots, two syntax-list headers, seven interned names/74 characters,
two String descriptors/16 characters, one SFN table entry and one hash wrapper.
The integer 1 needs no allocated Uint/digit entry. These must be added to
the producer frontend totals too; the 4096-byte aligned source range alone
does not account for them. The new pragma has no executable body. The project supplies no
global/local configuration, and no explicit configuration file is supplied
on the selected command line.

The generated naming file comes through GPR.Tempdir's String_Access overload
of `GNAT.OS_Lib.Create_Temp_File` (`gpr-tempdir.adb:103–176`). Its basename is
`GNAT-TEMP-` plus six digits plus `.TMP` (`s-os_lib.adb:77,756–763,780–906`).
The `.TMP` suffix is decisive: the frontend still loads/parses the file but
**does not call Prepcomp.Add_Dependency** for it
(`frontend.adb:196–240`). `-gnatA` disables implicit `gnat.adc`. No preprocessing
input is selected. Thus:

```text
configuration source files = 1
configuration source bytes = 327; aligned source charge = 4096
extra registered ALI dependency/unit entries = C_dependencies = 0
semantic and writer Units population = 2 (Main, System)
```

The source-range C used in the earlier source-closure packet is4096; the
ALI packet's C is a **count of dependency entries**, here0. They are different
quantities. The direct probe's manually named `naming.adc` creates one dependency;
its C1 would be wrong for production. Temporary-file allocation/success retains
the ordinary filesystem/environment premise; no new executable was run to
capture a production temporary file.

## Join to the ALI capacity equations

The descriptor also sharpens emitted **filename** lengths independently of
installation path lengths. `Next_Main_File` strips the absolute argument to
`main.adb` (`osint.adb:2012–2061`). GPR maps store display filename and resolved
path separately; the frontend requests the mapped basename
(`gpr-env.adb:951–984`; `fname-uf.adb:236–243`). Default lookup of System selects
`system.ads`. The indexed exception retains the same source filename. With no
Source_Reference, X headers use
these same Reference_Name values (`sinput-l.adb:510–529`;
`lib-xref.adb:2352–2357`). The only U/W/D/X
file spellings are `main.adb`, `system.ads` and `system.ali`, at most10 bytes.
There is no config D row and no stored A pathname. This uses the selected
Main/System source frontier; the unused broad Xref count does not introduce
other source files.

Consequently evaluate the generic ALI writer formula with:

```text
A=9, A_sum=53, A_max=9, C_dependencies=0, P_ALI_names=10.
R = 789 bytes including LF
F = 29,622,777 bytes (deliberately loose whole-file bound)
whole-file reader buffer <= 29,622,778 bytes
line-count bound = 77,550
```

The writer's R<=2112 condition and reader's signed32/one-past conditions hold.
The generic reader populations become ALIs2, Units2, Withs1, Args19, Sdep3,
five invocation constructs/signatures, and the already documented dummy/empty
tables. Their initial backing capacities suffice. Writer locals use u2; the
separate dependency vector reserves u+1=3 entries. The existing Xref sort and
backing allowances are unchanged.

Full command, input-search and output paths still require their own P-based
name-buffer, argv and filesystem conditions. They no longer enter this
**serialized ALI record** bound. This recovers the generic writer domain that
the previous deliberately loose P4096 illustration could not establish;
it does not introduce a path cap or weaken an assurance condition.

GPR2/GPRbuild startup/project/configuration/process objects, the data-representation
native invocation, fixed effective environment, and the complete null-pipeline
conjunction and independent review remain. #119 stays open; no language,
implementation, installation or admission bound changed.

Independent review of the indexed delta reproduced the reconstructed naming
and descriptor byte-for-byte, checked the GPR argument ordering, Adabkend
output-argument consumption and stored index switch, and accepted the ALI
arithmetic. The exact LF source citation for Adabkend was corrected. No native
job was launched; orchestration and whole-pipeline composition remain open.
