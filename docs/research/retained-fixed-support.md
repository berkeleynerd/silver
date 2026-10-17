# Fixed support source ranges

**2026-10-17 — source-only component for [#119](https://github.com/berkeleynerd/silver/issues/119).**
This follows the [source-range derivation](retained-source-closure.md).
It supplies conditional virtual-source and binder-source contributions for
the selected helper closure. It does not establish the entire language's
helper-dispatch coverage, other frontend representations, or a new admission
rule. Current language limits and tool installations are unchanged.

The [collector and result](../evidence/unbounded-programs/retained-source-closure-20261017/fixed-support-closure.json)
read installed support specifications, retained ALIs and pinned generator
source. No compiler, admission probe, GNATprove or Lean run was performed.
Coordinates count LF characters. GCC and GPR source identities and their
qualifications remain those in the preceding source-range record.

## Explicit seed set

The source closure starts with the following selected support families:

| Root family | Why included |
| --- | --- |
| `Ada.Text_IO`, `Ada.Command_Line`, `Interfaces.C` | The six selected Silver runtime source files use these APIs/types |
| `System`, `System.Standard_Library`, `System.Exception_Table`, `Ada.Exceptions`, `System.Soft_Links`, `System.Stack_Checking` | Core native elaboration, exception and stack support; present in retained native dependencies |
| `Ada.Tags`, `System.Put_Images` | Tagged runtime specifications and default image support; present in retained native dependencies |
| `System.Secondary_Stack` | Temporary String results and cleanup |
| `System.Img_Int` | Integer Image, `exp_imgv.adb:1113–1116,1329` |
| `System.Concat_2` through `_9` | Concat helper dispatch at `exp_ch4.adb:3499–3507` |
| `System.Compare_Array_Unsigned_8`, `System.Compare_Array_Signed_8` | Conservative inclusion of both byte-comparison fallback branches, `exp_ch4.adb:1300–1345`; ordinary String needs only the unsigned case |
| `Ada.Assertions`, `System.Assertions` | Fixed Silver library contracts; present in retained `silver_arguments.ali`/`silver_runtime.ali` |

The collector resolves context `with` clauses and parent specifications to a
fixed point. This gives **42 specifications**, whose summed aligned physical
charge is **409,600**. Their exact filenames, hashes and dependency edges are
recorded. The larger whole-runtime physical union from the earlier derivation
remains a valid overapproximation under its naming/search premises.

This closes the dependencies of the named seeds, rather than assuming that
all 1,575 runtime files can create an arbitrary number of virtual copies.
The remaining integration obligation is to show that every admitted grammar
production and its generated helpers selects only these seeds or another
explicitly accounted family. The fact that a retained ALI has no extra unit
does not by itself discharge that obligation.

## Virtual ranges inside this closure

The specification scan finds exactly these eight explicit instances:

- Three `Ada.Unchecked_Conversion` instances in `a-stuten.ads:108,111,114`.
- Three more in `a-tags.ads:628,631,634`.
- One more in `s-stalib.ads:70`.
- `System.Img_Int.Impl`, an `Image_I(Integer)` instance, in `s-imgint.ads:41`.

There are no `Inline_Always` annotations or source-name overrides in the 42
specifications. The only null procedure is
`System.Soft_Links.Null_Set_Address`, `s-soflin.ads:258`; its occurrences in
that specification initialize soft-link addresses (`258–266`). It is not a
direct RTE call target. The only classwide contracts are the three already
identified in `Ada.Strings.Text_Buffers`.

Each loaded unit is analyzed once (`lib-load.adb:695–729`, `sem.adb:104–116`),
so these distinct instance declarations are not multiplied by the number of
Main references. The seven conversion templates are intrinsic and have no
ordinary body. `Image_I` has no nested instantiation or derived tagged type;
the [body guard/set argument](retained-source-closure.md#body-inline-and-inherited-contract-exclusions)
charges at most one additional 4,898-byte body range if native processing
demands it. Its physical body is already inside the runtime physical union.

### The text-buffer contract path

`a-sttebu.ads:53–65` gives `Increase_Indent` one classwide postcondition and
`Decrease_Indent` a classwide precondition and postcondition. Each refers to
`Current_Indent`. The nested generic `Output_Mapping` derives `Buffer_Type`
from `Root_Buffer_Type` and overrides six abstract output operations
(`132–150`). None of those six has a classwide contract. It does not override
`Current_Indent`, `Increase_Indent` or `Decrease_Indent`.

In GNATprove mode, inherited-condition collection is restricted to a
source-defined overriding primitive (`freeze.adb:1946–1972`). The six actual
overrides have no inherited classwide condition; the three indent operations
are inherited, not source-defined overrides. Consequently this template
does not reach the virtual-source copy in
`sem_prag.adb:33426–33427,32997–32998`.

Native inherited-condition handling first tests `Needs_Wrapper`
(`freeze.adb:1837–1887`). A wrapper requires a referenced primitive to map
to a source-defined overriding subprogram. `Current_Indent` remains inherited,
so the indent contracts do not satisfy that test. The other abstract output
overrides cannot make these contracts require a wrapper: they do not appear
in those conditions. Thus there is no native inherited-contract body copy
from this generic declaration. There is no instance of `Output_Mapping` in
the selected specifications or six Silver source files.

### Why ordinary support bodies do not enlarge the source closure

For current native `-O0`, backend inlining is enabled but ordinary pragma
Inline does not prepare a frontend copy. `sem_ch6.adb:4356–4388` requires
Inline_Always or positive optimization in that mode.
`exp_ch6.adb:5659–5664` similarly restricts backend body registration;
expression-function substitution follows its separate copy path. The selected
specifications have no Inline_Always. Legacy package-body loading is behind
`not Back_End_Inlining`, `inline.adb:2873–2876`; the native route does not take
it. `Image_I`'s possible generic body demand is charged explicitly above.

The generated-helper exclusions in the preceding record apply here. Add the
array-ordering fallback: `Make_Array_Comparison_Op`,
`exp_ch4.adb:14005–14218`, returns a body-as-declaration with no inline
preparation. Its construction therefore does not satisfy the separate
declaration/body-to-inline route. This conclusion concerns virtual source
ranges, not generated AST nodes or backend code.

GNATprove has no normal expansion and does not instantiate generic bodies
outside Main (`sem_ch12.adb:4915–4922`). Its automatic inlining excludes
package-spec APIs, other-unit bodies, contracts and expression functions as
already recorded. There is no new author-specified inlineable subprogram.
Fixed Silver body analysis remains a separate fixed-input process; its APIs
and local expression helper do not introduce another virtual-source route.

Under this seed/caller closure, the resulting per-process upper bounds are:

```text
V_native_main = 7*q(1554) + q(3367) + q(4898) = 40,960
V_gnat2why_main = 7*q(1554) + q(3367)          = 32,768
```

The native bound also conservatively covers the native data-representation
pass. Reference counts, loop trip counts and Main byte length do not multiply
these fixed contributions. Any newly reachable helper family must be checked
against the closure before reusing the numbers.

## Binder source generation

The binder does not compile Main's body again. Its generated Main call uses an
imported fixed link name (`bindgen.adb:1978–2003`), and it imports elaboration
and finalization entry points for selected units. Local object/index names in
Main therefore do not become binder unit names.

The retained application ALIs plus every concat/comparison/Image helper variant
above close under ALI `W`/`Y`/`Z` dependency edges at **98 ALI files and 169 unit
entries**. The collector records the exact graph and raw input hashes. The
maximum encoded unit name is 44 bytes including its `%s`/`%b` suffix; the
maximum link-name prefix after replacing dots with double underscores is 45.
The graph has one linker-option record, `-ldl`, and no interrupt-state or
priority-specific-dispatching records. It contains neither tasking/GNARL nor
`System.Restrictions`. The author's grammar has no construct that creates
additional compilation units, linker options or those configuration pragmas.
Completeness of the helper seeds remains the same explicit premise as above.

The source writer inventory and manually reviewed loop placement give:

| Generator | Fixed line-write upper bound | Per unit upper bound |
| --- | ---: | ---: |
| `Gen_Adafinal` | 19 | 0 |
| `Gen_Adainit` | 170 | 0 |
| `Gen_Main` | 56 | 0 |
| `Gen_Output_File_Ada` | 84 | 0 |
| `Gen_Elab_Calls` | 0 | 5 |
| `Gen_Elab_Externals` | 1 | 1 |
| `Gen_Elab_Order` | 3 | 1 |
| `Gen_Finalize_Library` | 10 | 10 |
| `Gen_Versions` | 2 | 2 |
| Total before object/options comments | **345** | **19** |

This deliberately counts both sides of conditional branches. The finalize
header is emitted at most once, guarded by `Lib_Final_Built`; its per-unit
sites are inside one loop over elaboration order. Version and elaboration
loops visit each unit once. CUDA, CodePeer, binder environment injection,
dynamic stack measurement and special library-binding options are not selected.
`Gen_Restrictions` returns because `System.Restrictions` is absent. The two
policy-string loops in `Gen_Output_File_Ada` are empty because their records
are absent. These exclusions are why a lexical writer count alone would not
be a sufficient bound.

Ordinary generated lines use fixed names, the bounded unit names, fixed-size
checksums or small numeric fields. The relevant buffered constructions fit
the 1,000-byte `Statement_Buffer` (`bindgen.adb:46`): no selected construction
accumulates a list of units in one buffer; the name-expansion loops append at
most 45 bytes, unit/finalizer counters need at most three digits, version
labels have their fixed six-character format, and the policy
strings are empty. The fixed secondary-stack declaration has bounded scalar
fields, rather than one initializer per stack.

Direct `WBI` calls bypass that statement buffer, so their operands need their
own bounds. GPR supplies the fixed `b__main.adb` basename
(`gprbind.adb:502–503,568–569`); `osint-b.adb:81–89` preserves that name for
the generated Source_File_Name lines (`bindgen.adb:2790,2798`). The version
string is at most 256 bytes (`gnatvsn.ads:80–87`, emitted at
`bindgen.adb:2648`). The Ada main name is the fixed default with at most a
two-digit collision suffix, or a fixed fallback (`bindgen.adb:3124–3184`); the exported main name
is fixed (`3191–3222`). These direct lines also fit within 1,000 bytes under
the selected invocation. Charge **1,001 bytes** per ordinary emitted line,
including LF (`osint.adb:3255–3259`). This charge is not
an argument that a buffer overflow would be acceptable; the bounded operands
and reset after every statement establish the required construction premise.

Object and directory comments bypass that buffer. Let `P` bound the actual
object/directory path lengths, `D` bound the effective object-directory list,
`L` be the number of linker-option segments (each at most 1,000 bytes here),
and `U` bound units. `Gen_Object_Files_Options`, `bindgen.adb:2237–2461`, adds
four fixed lines, at most one object comment per unit, one `-L` comment per
directory, and the linker-option segments. Each segment also has an eight-byte
comment prefix and LF (`bindgen.adb:2290`). Therefore the **combined raw byte
length** of generated spec and body is bounded by:

```text
B(U,P,D,L) = 1001*(349 + 19*U) + 1009*L + (P+9)*U + (P+11)*D
B(169,4096,3,1) = 4,270,635 bytes
q(spec_bytes) + q(body_bytes) <= B + 8,192 = 4,278,827
```

The retained fixed route has two entries for the workspace object directory
and one for installed native `adalib`; its object paths are shorter than 4,096
bytes. The next section requires #89 to establish this effective layout, not
inherit an arbitrary object search. The sample binder files are 21,302 and
10,628 bytes; those measurements reconcile the retained route but are not the
derivation of `B`.

`gprbind.adb:865–869` supplies `-gnatA -gnatWb -gnatiw -gnatws`. At `913–920`
it excludes Main's `-gnat*`, `-I*` and `--RTS=*` switches from the copied
backend arguments. No `-gnatec` input is selected for this generated source;
`C_binder = 0`. The generated `Source_File_Name` pragmas map `ada_main` to the
already charged `b__main.ads`/`.adb`, not another alias. The binder frontend
loads `System`, `System.Parameters`, `System.Secondary_Stack` and, when
finalization is needed, `Ada.Exceptions`; their nine-specification source
closure has only the single Standard_Library conversion instance. It uses
Ada 95, so it does not add default Ada 2022 Put_Image helpers. Thus
`V_binder <= 4,096` on this route.

Even retaining the earlier whole-runtime physical overapproximation, the
binder's source-range charge is at most:

```text
4,278,827 + 20,496,384 + 4,096 = 24,779,307
```

This is below the source-cursor sufficient ceiling. It is not a bound on the
binder's ALI parser, other tables, generated code, relocation fields or linker
representations; those remain distinct capacity obligations.

## Concrete invocation requirement for #89

The source-search premise is an implementation requirement for
[#89](https://github.com/berkeleynerd/silver/issues/89), not an unspecified
assumption that inherited environment happens to be empty. After Alire has
constructed its tool environment, the production wrapper must clear inherited
`ADA_INCLUDE_PATH`, `ADA_OBJECTS_PATH`, `ADA_PRJ_INCLUDE_FILE` and
`ADA_PRJ_OBJECTS_FILE` before invoking GPRbuild/GNATprove. Retain the existing
GPR/Alire project-selection exclusions. GPR may then install its own generated
project path files for child processes.

The invocation must bind the selected tool/runtime database, the fixed project
with its declared source files, and the generated workspace paths. For native
binding, establish at most the two workspace object-directory entries plus
the installed `adalib`, with the stated path-length bound. Additional runtime,
project, naming or compiler/binder options require recalculating the affected
closure; operational configuration failure is not a language rejection.
This record changes no wrapper or production source. The existing installed
GPR and producer source-identity qualifications remain visible; version labels
alone do not establish those identities.

## Evidence and remaining integration

The result records all 42 source hashes, the 98-file ALI graph, the writer-site
inventory and the arithmetic inputs. The collector's lexical inventories are
checked inputs to the manual caller/control-flow argument, not a mechanically
verified call graph. An independent source-only review confirmed the writer
coefficients, direct-line operands and binder virtual-source closure; its
linker-comment-prefix correction is included in the formula above. Remaining
work is to integrate complete grammar/helper coverage and source/tool premises
with the other #119 representations. One concrete selector still being traced
is concat's secondary-stack allocator route (`exp_ch4.adb:3382–3419`): its
generated access type and allocator must be checked for additional runtime
families before this selected closure is applied to every concat expression.
Then
implement the #89 invocation controls and the authorized dependent increments.
No change in toolchain ownership is needed by these contributions.
