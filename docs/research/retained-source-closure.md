# Source ranges for the retained tools

**2026-10-17 — partial derivation for [#119](https://github.com/berkeleynerd/silver/issues/119).**
This supplements the [capacity contract](retained-tool-capacity.md). It closes
the direct allocation-site inventory in the inspected sources and derives
concrete fixed-input contributions with explicit premises. It does **not** establish the full
physical/virtual range inventory for every production phase, an enlarged
language, or a complete source-capacity admission rule. The current language
and tool pins remain unchanged.

The subsequent [fixed-support component](retained-fixed-support.md) supplies
virtual-source and binder-source bounds for an explicit 42-specification
helper closure, and makes effective-search control a concrete #89 invocation
requirement. Whole-language helper-dispatch coverage remains an integration
obligation.

No compiler, GNATprove, Lean build or new admission experiment was run. The
new [collector and inventory](../evidence/unbounded-programs/retained-source-closure-20261017/)
use source inspection, file hashing and a retained trace. Native environment:
Linux x86_64. All upstream line references below count LF characters; form feeds
are not line separators.

## Source and process identities

The GCC Ada baseline is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Every one of the 2,319 `.adb`/`.ads`
files scanned here matches the previously retained
[complete source manifest](../evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json),
with no missing or additional Ada file. The inspected SPARK snapshot is
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`; its 279 `src` Ada files were scanned
separately. That snapshot's identity as the installed producer archive's source
commit remains unestablished. Byte agreement for runtime source files below
does not establish identity of either executable's frontend implementation.

The current Silver driver, `src/silver.adb:103–125`, generates a project with
`main.adb` alone for null, or Main plus six Silver-owned runtime source files
for output. Ada switches are `-gnat2022 -gnata -gnato`; build is
`gprbuild -P ... -p`. No optimization, frontend-inlining, debug-generated-code
or code-model override is selected. The driver currently proves before building;
the proposed separation of build and confirmation is not yet delivered.

Proof uses the Image overlay with `-U --mode=all --report=all`, the current
warning/check policy, `--level=2 --prover=cvc5,z3,altergo --steps=100000
--timeout=0 --memlimit=1000 -j0 --no-loop-unrolling`. Bootstrap fixes its Alire
context and environment (`scripts/bootstrap.py:156–170`); the overlay replaces
gnatwhy3, not the embedded frontend (`278–291`). In the inspected SPARK driver,
`src/gnatprove/gnatprove.adb:178–323,1315–1319` dispatches these separate phases:

| Process family | Relevant source-range accounting |
| --- | --- |
| Native application compilation | Main, selected Silver/runtime dependencies, configuration and virtual copies |
| Native data representation | `-S -gnatR2js -gnatws -gnatx`; separate frontend process for each selected compilation unit |
| gnat2why ALI and translation | `--gnatprove` selects the driver; `-gnatc -gnates=...`; separate frontend processes and their own dependency/copy closures |
| Fixed Silver library compilation/verification | Fixed source bytes, independent of growing Main; still distinct input configurations to reconcile |
| Binder-generated Ada compilation | Generated source, separate process; needs its own generation and dependency bound |

Do not sum their source cursors into one global counter. Conversely, do not use
the closure of a semantic-only Main probe as the closure of every phase.

## Direct allocation sites and physical loads

The complete lexical scan finds four direct Source_File allocation sites:

| Pinned GCC site | Allocation route | Treatment |
| --- | --- | --- |
| `sinput-l.adb:143` | `Create_Instantiation_Source` appends a virtual source | Count every call, including repeated copies of the same text |
| `sinput-l.adb:398` | `Load_File` loads physical/configuration/preprocessing input | Deduplicate only by the actual `File_Name_Type` request name |
| `sinput-d.adb:71` | Generated debug-source output | Requires `Debug_Generated_Code`; `sprint.adb:611–637`, enabled by `-gnatD` in `switch-c.adb:455`, absent here |
| `sinput-c.adb:65` | Checksum/preprocessor-tool source loading | Used by `gprep.adb:243,508` and `ali-util.adb:107`; keep its process scope distinct |

The scan also records initialization, release/free/lock operations and two
failure decrements; it finds no other direct append/increment. The inspected
SPARK `src` adds no direct Source_File append/increment, physical loader call,
or `Create_Instantiation_Source` call. This is an exhaustive lexical search of
the recorded corpus, with manually reviewed callers; it is not a mechanically
verified call graph or a binary coverage result.

Physical load callers narrow further:

| Caller | Meaning and current consequence |
| --- | --- |
| `lib-load.adb:124,332,738` | Auxiliary/main/library unit loading; the unit table reuses an existing unit at `695–729` |
| `gnat1drv.adb:1060–1066` | Initial target parameters from mapped `system.ads` |
| `gnat1drv.adb:789–809` | Check whether a forbidden package body exists; Main is a procedure body, while fixed-library processes need separate accounting |
| `frontend.adb:168,217` | `gnat.adc` and explicit configuration files; must bind the actual generated configuration/search environment |
| `frontend.adb:266–276` | Target-dependent information for `-gnateT`; absent the current driver selection |
| `prepcomp.adb:223,666` | Preprocessing data/definition files; `584–621` returns without preprocessing data/defaults; the current project selects none |
| `sem_ch3.adb:3946–4033` | `External_Initialization` reads a data file as source; unavailable in the author grammar and absent the selected Silver sources |
| `gnat1drv.adb:953–979` | JSON representation files loaded as source; invoked only by debug `-gnatd_j`, at `1512–1515`, absent here |

The last row is not GNATprove's ordinary JSON consumption. The inspected
`gnat2why-data_decomposition.adb:220–248` reads data-representation JSON with
`Read_File_Into_JSON`, without Source_File allocation. Its data and JSON
representations still need their own producer capacity argument.

`Sinput.C`'s checksum route is reached for minimal recompilation
(`ali-util.adb:433–463`); current build does not select `-m`. This excludes a
specific route, not all possible binder/build-driver source processing.

## Physical runtime contribution

`sinput-l.adb:369–383` reuses a matching request name unless
`Multiple_Unit_Index /= 0`. `osint.adb:2709–2735` reads binary bytes, places EOF
after them, and gives a successfully read unpreprocessed file of `b` bytes
extent `Source_Last - Source_First = b`. Accordingly define:

```text
q(b) = 4096 * ceil((b + 1) / 4096)
```

Both installed runtime directories contain the same 1,575 file names and
identical bytes, checked across the complete directories. Their raw sum is
17,847,599 bytes; the sum of `q(size)` over the entire directory is
**20,496,384**. This includes unused runtime files deliberately. It is a usable
fixed overapproximation of *one physical range per runtime request name*;
selecting more helper families cannot exceed that union when requests remain
inside it. The six selected Silver source files add **24,576** by the same
calculation. File-set digest and encoding are recorded in the inventory.

This removes the need to find the exact minimum runtime-unit set merely to
bound physical bytes. It does not establish the request-name premise:
deduplication uses `File_Name`, not resolved filesystem identity. Aliased or
mapped names for one file must be counted separately or proved impossible.
Generated configuration inputs, nonruntime search paths, preprocessing and
binder output are not included in this directory total. None may be silently
assigned zero. The following reconciliation supplies a fixed configuration
charge and narrows the name-map premise, conditional on the inspected driver
route and its source-search environment.

### Generated configuration and request names

The [driver reconciliation](../evidence/unbounded-programs/retained-source-closure-20261017/driver-reconciliation.json)
retains two older producer command snapshots, their surviving GPR temporary
files, and the current `program-Z0j19G` project's native ALI, phase switches
and binder files. The older commands identify `/tmp/GPR.293256` and
`/tmp/GPR.293263` exactly. Their generated `-gnatec` inputs are byte-identical:
**244 bytes**, containing just the default `.ads`/`.adb`, lowercase,
hyphen-separated `Source_File_Name_Project` patterns. Therefore each costs
`q(244) = 4,096` source positions. Their maps contain 24 and 23 distinct
basenames respectively, resolving only to their seven workspace files or the
installed producer runtime. Runtime mapped bytes match the native runtime.

These older records are **stopped exploratory runs**, not successful proof
evidence. Their project naming/source-file shape agrees with today's driver,
but four of their six library source files differ from current sources. The
current retained workspace has all six current library sources, the driver's
460-byte project, a native ALI with `-gnatA`, and separate Main switch records
for phase 1, translation and data representation. Its 32 native ALI dependency
names are basenames in the workspace/runtime union. Its `.cswi` files omit the
temporary configuration/map arguments; those historical temporary files were
not located. No sample is being promoted to a universal dependency closure.

The installed native and producer GPR databases both supply `-gnatA`,
`-gnatem=` and `-gnatec=` (`share/gprconfig/gnat.xml:15–22`). The producer's
custom database adds `.spark`, ALI-closure dependencies and `-gnateO=`, without
changing the naming patterns. The retained generated configuration projects
agree. In GCC, `switch-c.adb:313–315` sets `Config_File := False` for `-gnatA`,
so the implicit `gnat.adc` load at `frontend.adb:167–168` is excluded on this
route. Explicit configuration files still use `Load_Config_File` at `217`.

To inspect the generator, GPRbuild tag `v26.0.0`, peeled commit
`bdfb879cf03643ec8e48a09ce07b08c4a6ff0263`, was retrieved without building it.
The installed native Alire version `26.0.1` points to the binary release
`gprbuild-26.0.0-1`. That correspondence is a source-selection clue, **not** an
established source identity for either installed GPR executable. Under this
inspected source route:

- `src/gprbuild-compile.adb:682–703` emits each distinct naming scheme once.
  `832–941` adds a per-unit pragma only for a naming exception. The fixed
  `main.adb` and six Silver filenames use the single default scheme, with no
  naming exceptions or multiple units per file. The emitted pattern pair is
  independent of Main's declarations, statements and identifier spellings.
- `2583–2635,2658–2686` adds global/local/command-line configuration inputs
  only when selected. None is selected in Silver's generated project or
  commands. Thus the candidate production route has one 244-byte generated
  configuration input: **`C = 4,096`**, without a Main-size term.
- `gpr/src/gpr-env.adb:835–984` builds a unit map from project sources and
  writes each selected source's display filename separately from its path.
  `fmap.adb:278` reads that map directly through `Osint.Read_Source_File`,
  bypassing `Source_File` insertion. `osint.adb:360–429` reads include/object
  path files directly as well. These have their own storage costs, but their
  bytes do **not** contribute to the aligned source cursor.
- Main's command-line absolute path is reduced to its basename by
  `osint.adb:2012–2061`. `fname-uf.adb:236–243` returns mapped basenames for
  library units; default lookup adds and reuses a unit-to-filename/path map
  at `363–371`. `osint.adb:1263–1278` uses the resolved path only to find the
  file, leaving the request-name key used by `sinput-l.adb:369–383` intact.
  A directory prefix therefore does not itself create another Main range.

With exactly this project naming/map configuration, no source-name overrides,
one unit per source, and resolution confined to the recorded workspace/runtime
bytes, **`A = 0`**: all successful physical requests use the once-charged
filenames. The whole-runtime union deliberately permits selecting additional
runtime basenames without enlarging `R`. This reasoning concerns requests;
it does not claim that distinct filesystem paths are deduplicated automatically.

The search-environment qualification remains explicit. `osint.adb:474–504`
reads project include/object path files and `ADA_INCLUDE_PATH`/
`ADA_OBJECTS_PATH`; the wrapper's `TOOL_ENVIRONMENT_OVERRIDES` removes
`ALR_CONFIG`, `GPR_CONFIG`, `GPR_PROJECT_PATH`, `GPR_PROJECT_PATH_FILE` and
`ADA_PROJECT_PATH`, not these frontend variables. The retained snapshots do
not contain their inherited values. A universal application of `R`, `C` and
`A` must establish the installed generator/source relation and the fixed
effective source search, or supply a larger justified file/name universe.
The [follow-up invocation requirement](retained-fixed-support.md#concrete-invocation-requirement-for-89)
specifies inherited-search sanitization and the fixed layout for #89;
this is a concrete implementation obligation, not a recommendation to accept
arbitrary inherited paths. Changing Main alone cannot establish these premises.

## Virtual ranges: eight sites, not eight possible copies

`sinput-l.adb:127–145,231–236` copies the *whole originating source-file extent*,
even when the semantic copy is just one declaration or body. Repeated
instantiation/inlining can therefore consume source-position space without
loading more physical files. All eight external calls occur in `sem_ch12.adb`:

| LF line | Enclosing operation | Author-source exclusion or remaining dependency |
| --- | --- | --- |
| 3788 | Formal package declaration | Main admits no generic declarations/formal packages; runtime templates still matter |
| 5164 | Package instantiation | Main admits no instances; runtime specs instantiate Image support |
| 6979 | Subprogram instantiation | Main admits no instances; runtime specs instantiate Unchecked_Conversion |
| 10078 | Generic node copying for original separate body/stub | Main has no subunits; dependency/body-copy reachability remains relevant |
| 13652 | Package body instantiation | Need the package-body demand conditions below |
| 14156 | Subprogram body instantiation | Intrinsic Unchecked_Conversion has no ordinary body; other selected instances must be enumerated |
| 18679 | Inherited pragma wrapper | Called by `sem_prag.adb:32997` for an inherited classwide contract |
| 18691 | Inlined-body wrapper | Called by `inline.adb:3839` during actual frontend body copying |

The obvious compiler-created generic instantiations outside this machinery
are shared-passive variable support (`exp_smem.adb:413`, caller
`exp_ch3.adb:7861`) and remote-call-interface support (`exp_dist.adb:11233`).
Those features are absent from Main. The constructor in `sem_ch12.adb:12542`
serves formal-package conformance, also unavailable there. Parser/semantic
recognition of explicit generic instances cannot manufacture an admitted
generic construct. These exclusions do not alone close runtime-template paths.

### Identified fixed template contribution

The eight virtual entries in the retained
[mixed expanded trace](../evidence/unbounded-programs/feasibility-20261017/source-capacity/trace-summary.json)
have the following matching source declarations:

| Runtime source | Instance declarations | Copied template |
| --- | --- | --- |
| `a-stuten.ads:108,111,114` | Three conversions | `a-unccon.ads`, 1,554-byte extent |
| `s-stalib.ads:70–71` | One conversion | `a-unccon.ads` |
| `a-tags.ads:628–635` | Three conversions | `a-unccon.ads` |
| `s-imgint.ads:41` | `Image_I(Integer)` | `s-imagei.ads`, 3,367-byte extent |

For these identified spec instantiations, the aligned contribution is exactly
`7 * q(1554) + q(3367) = 32,768`. The templates and the relevant declaring
specs match both installed runtimes and the GCC baseline. Sixteen explicitly
selected baseline/runtime files were compared, including Image's body and all
eight concat helper specs. The whole installed runtime comparison above is
broader, but does not assert that every target-selected runtime file has the
same relative path in the upstream source layout.

This is an accounted component, **not** a universal virtual-source total.
The trace is a retained discriminator; its eight entries do not prove that
every production phase creates only eight entries or selects the same files.

### Body, inline and inherited-contract exclusions

`Needs_Body_Instantiated`, `sem_ch12.adb:4881–4944`, instantiates bodies in Main
or its auxiliary declarations, but in GNATprove mode excludes bodies outside
Main. Native demand outside Main depends on inlining. `Image_I` has no
Inline/Inline_Always annotation; Unchecked_Conversion is intrinsic. These
facts address the identified templates' ordinary body route.

Do not infer `Inline_Processing_Required = False` merely from the absence of
`-gnatn`: expression-function analysis sets it (`sem_ch6.adb:326`). Ordinary
pragma Inline is inactive across units without `-gnatn`, while Inline_Always
can remain active (`sem_prag.adb:20575–20628`). Native body preparation has the
additional conditions at `sem_ch6.adb:4356–4388`.

GNATprove's automatic frontend inlining is separate
(`sem_ch6.adb:4436–4448`). `inline.adb:1970–2030` excludes package-spec APIs,
other-unit definitions, contracted subprograms and expression functions. Thus
the current exported Silver APIs and its private expression-function helper
do not cause repeated frontend body-source copies through that route. Native
expression-function substitution itself uses `New_Copy`
(`exp_ch6.adb:5536–5543`), not the virtual-range allocator.

For the one identified `System.Img_Int.Impl` instance, a conservative native
body charge can be supplied without deciding whether the body is demanded:
**at most one additional `q(4898) = 8,192` virtual range**. The pinned
`s-imagei.adb` is 4,898 bytes, has no nested generic instance, tagged
derivation, subunit, null procedure or inline annotation. Its ordinary local
scalar/String operations do not re-enter its own generic instantiation.
`Instantiate_Package_Body` returns when the instance spec already has a body
(`sem_ch12.adb:13510–13513`) and rechecks after loading a parent (`13600–13602`).
The sole body-source allocation on this route is `13652`; it then analyzes
the created body (`13882–13888`). Package-body analysis selects the instance
spec (`sem_ch7.adb:746–748`) and sets its `Corresponding_Body` at `909`, before
analyzing its declarations/statements. Later demand therefore returns before
allocating a second range. This is one instance's bound, not an assertion
that the complete virtual-source contribution is 40,960. GNATprove's explicit
outside-Main exclusion at `sem_ch12.adb:4915–4922` makes this body contribution
zero for a Main translation process.

Likewise, marking a generated equality helper inline is insufficient to show
that it allocates virtual source. The fallback equality helper is a body
declaration (`exp_ch4.adb:2035`); actual frontend inlining requires a separate
subprogram declaration and `Body_To_Inline` (`exp_ch6.adb:5561–5565`). Complete
generated-helper coverage is still required.

Inherited contracts require particular care: `a-sttebu.ads:55–65` contains
classwide contracts, and `106–150` declares a generic derived-buffer type.
The runtime is not contract-free. The copy route requires an inherited
condition (`sem_prag.adb:32986–33012`); its GNATprove collection requires a
source overriding primitive (`freeze.adb:1940–1972`). Main provides no tagged
derivations or overriding declarations. Native contract-body expansion and
fixed runtime template analysis are reconciled for the explicit selected
closure in the [fixed-support component](retained-fixed-support.md#the-text-buffer-contract-path).
Applying that component universally still requires complete helper dispatch.

### Generated-helper inlining: a narrower dependency

For current native options, `gnat1drv.adb:691–707` sets
`Back_End_Inlining = True`: GNATprove mode, explicit frontend inlining and
debug `.z` are its disabling conditions. In this mode, a scalar/procedure
helper's `Is_Inlined` flag does not allocate a virtual source range. Actual
frontend call copying still requires a separate declaration with a populated
`Body_To_Inline` (`exp_ch6.adb:5644–5654`). The complete source scan finds the
following setters, besides the generated accessor machinery:

| Setter | Role and effect under current options |
| --- | --- |
| `inline.adb:1370` | Legacy/GNATprove body preparation; native invocation is behind the disabled frontend-inlining branch of `sem_ch6.adb:4363–4369` |
| `inline.adb:2404` | Splitting a source function returning an unconstrained type; `inline.adb:2725–2735` requires that source-body flag and Inline_Always or positive optimization |
| `inline.adb:2857` | Clears an existing body-to-inline pointer |
| `freeze.adb:434` | Renaming shortcut stores an entity, not a body; `inline.adb:3807–3809` returns without allocating virtual source |
| `sem_ch6.adb:1516` | Null-procedure body; unavailable to Main, so any selected support call to one would have to be identified separately |

This disposes of several apparent per-expression/per-scope copy multipliers:

- Native concat expansion (`exp_ch4.adb:2552–3639`) creates temporaries,
  assignments or calls to the fixed concat helpers, with no subprogram body.
- Fallback equality (`exp_ch4.adb:2035`) is a generated body-as-declaration;
  generated Put_Image (`exp_put_image.adb:1084–1103`) is likewise a body, with
  no inline annotation. Neither satisfies the separate inline-body route.
- The generated finalizer has a separate specification and `Is_Inlined`
  (`exp_ch7.adb:1980–2061`), but no inline pragma/body-to-inline preparation.
  Its calls remain backend work under current options. GNATprove explicitly
  skips `Build_Finalizer` (`exp_ch7.adb:3144–3152`).

GNATprove returns from `Expander.Expand` after `Expand_SPARK`
(`expander.adb:110–129`), bypassing ordinary concat/equality/finalizer expansion.
The light-expansion cases in `exp_spark.adb:119–202` introduce no corresponding
helper subprograms for this grammar: its loop transformation needs an array
iterator (`907–912`), and object transformation needs an uninitialized DIC
object (`932–938`). Main has ordinary range loops and initialized Integer or
String objects. The type-freezing subprogram constructors at `1139–1251`
require invariants, DIC or tagged-record types; these are absent from Main's
types. Its direct call-resolution inlining route (`sem_res.adb:7384–7387,
7489–7518`) uses the same API/contract/expression-function exclusions already
identified. Fixed dependency processing remains separate.

These are source-derived zero virtual-copy transfers for the named helper
families, not zero AST/backend cost. What remains for source ranges is narrower:
runtime bodies/templates and any selected external target whose Inline_Always
unconstrained-return or null-procedure status escapes these exclusions.
In particular, the absence of an Inline annotation on `Image_I` alone does
**not** exclude a body copy: `Needs_Body_Instantiated` returns true when
`Inline_Processing_Required and Back_End_Inlining` (`sem_ch12.adb:4937–4938`).
Its body contains no further generic instantiation, but the body's demand and
at-most-once property must be resolved before adding a fixed body contribution.

The complete installed-runtime annotation inventory narrows those external
targets too. Exactly ten specs contain Inline_Always annotations:
`g-altcon.ads`, `g-alveop.ads`, `s-addope.ads`, `s-aoinar.ads`, `s-aomoar.ads`,
`s-aotase.ads`, `s-atocou.ads`, `s-atopex.ads`, `s-auxdec.ads`, `s-veboop.ads`.
Of these packages, the Rtsfind entity map exposes
`System.Atomic_Operations.Test_And_Set` and `System.Aux_DEC`. The former's
callable target is the Boolean-result intrinsic `Atomic_Test_And_Set`
(`rtsfind.ads:806–819,2466–2479`); the latter entries are AST/type-class
descriptors, not its generic `Fetch_From_Address` or other inlined functions.
The Boolean-array helpers selected by `RE_Vector_*` belong to
`System.Boolean_Array_Operations` (`rtsfind.ads:2517–2523`), not the annotated
`System.Vectors.Boolean_Operations` package. None of Main's authored APIs
comes from these annotated packages. These facts exclude an unconstrained
Inline_Always return at the direct Main-to-runtime helper call boundary.

Null-procedure specs are confined to `Ada.Finalization`'s controlled-type
operations, `System.Storage_Pools.Subpools.Deallocate` and
`System.Soft_Links.Null_Set_Address`. Main's Integer/String types require no
controlled/subpool dispatch; `Null_Set_Address` initializes access-to-subprogram
soft links (`s-soflin.ads:258–266`), rather than being a direct RTE target.
There are also null procedures and Inline_Always annotations inside fixed
runtime bodies, recorded separately by the collector. Calls generated inside
those bodies belong to the fixed dependency contribution; they are not evidence
of a fresh source-range copy for every Main expression.

## Grammar helper coverage already narrowed

| Family | Established dispatch fact | What it does not establish |
| --- | --- | --- |
| String concat | `exp_ch4.adb:3470–3545` selects `System.Concat_2` through `_9` for the applicable retained operand counts at `-O0`; larger concatenations lower to assignments | An unbounded number of helper package families is unnecessary; generated nodes/copies and operand evaluation still need bounds |
| Integer Image | `exp_imgv.adb:1113–1116,1329` selects `RE_Image_Integer`, mapped to `System.Img_Int` by `rtsfind.ads:2653` | Does not bound source copies in every producer/native phase by the single trace |
| String equality | `exp_ch4.adb:8594–8671` uses bytewise comparison for the ordinary elementary case, with a generated-function fallback | Target/alignment/validity conditions and all fallback generation must be covered |
| Runtime entity lookup | `rtsfind.adb:1102–1111` returns when its unit is already loaded; `1563` loads the selected entity's unit | Unit reuse does not deduplicate semantic bodies or virtual instances |
| Integer arithmetic/checks | Overflow expansion is routed through `exp_ch4.adb:7918,9935` | Standard exception, elaboration, secondary-stack and default Put_Image/tag helper closure remains to be established |

## Conditional arithmetic result and exact remaining work

Let `R = 20,496,384`, `S = 24,576` for output (`0` for null), `n` be Main's
byte length, `C` the aligned charge of actual configuration/other physical
inputs, `A` the charge for any additional physical request-name aliases, and
`V` the sum of aligned extents of **all** virtual copies for that process.
For a Main frontend process with initial cursor zero, no preprocessing/debug
source replacement, and the physical-universe premises above:

```text
source_budget(n) = q(n) + R + S + C + A + V
source_budget(n) <= 2,147,479,551
```

is sufficient for the aligned source-range recurrence and its stated signed-Int
headroom in the [capacity contract](retained-tool-capacity.md#reusable-source-position-component).
It conservatively charges an aligned full block for the final range as well,
so loading order cannot make the final position larger than this sum. `R` and
`S` are justified concrete fixed contributions. The inspected project/generator
route supplies **`C = 4,096`, `A = 0` under its explicit source/search premises**;
the fixed-support component supplies **`V <= 40,960` for native Main and
`V <= 32,768` for gnat2why Main under its explicit helper closure**. The
installed-driver relation, #89 invocation controls and complete grammar-to-helper
coverage remain integration obligations. Consequently this formula is not an implemented or
complete decidable membership test. It also says nothing yet about line-table
growth, other source-pointer operations, parser/copy nodes or producer data.

The smallest next source-closure steps are specific:

1. Establish the installed GPR/source relation and effective source-search
   configuration for each frontend family. The retained pattern/map artifacts
   and inspected generator agree on the one-block configuration charge and
   basename requests; account for any remaining nonruntime search input before
   applying those conditional contributions universally. A new run is warranted
   only if a named source/artifact contradiction requires it.
2. Finish the generated-helper dispatch for the grammar's scalar, String,
   branch and loop compositions against the explicit 42-specification closure.
   Its generic, inline and inherited-contract contribution is now bounded;
   any newly selected helper must extend that closure explicitly.
3. Integrate the binder source bound from the fixed-support component and
   establish its controlled source/object search. Reconcile the fixed-library
   frontend inputs independently; a
   retained successful run for an exact fixed input can answer that singleton
   capacity question, but cannot establish a bound for variable Main.
4. Establish the relevant installed-producer/source relation before applying
   the inspected SPARK route to the installed executable. Complete line-table
   and remaining source-pointer arithmetic alongside the other #119 components.

These are unresolved derivation obligations, not an impossibility result or a
recommendation to change toolchain ownership. The fixed physical union and
identified template contribution reduce their scope without bypassing them.

The feasible next derivation is targeted helper dispatch, not reviewing all
runtime bodies. No direct author construct in this grammar creates a generic,
derived tagged type or frontend-inlinable subprogram. If the remaining generated
helpers also exclude the virtual-copy routes, `V` reduces to a fixed runtime
template closure per phase. If a generated helper does inline, its call count
must be bounded from the grammar/expansion events and charged per copied
template extent; the fixed runtime-file union cannot bound that multiplicity.
No unavoidable user-dependent virtual-copy route has been demonstrated here.

## Reproduction

The [evidence README](../evidence/unbounded-programs/retained-source-closure-20261017/README.md)
records the source-only command, paths, digest encoding and checks. The collector
preserves LF coordinates while masking Ada comments/string/character literals
for its lexical searches. Its occurrence lists include definitions as well as
calls; the caller interpretation above distinguishes them. It is research
instrumentation outside `scripts/`, not an admission implementation or proof.
