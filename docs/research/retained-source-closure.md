# Source ranges for the retained tools

**2026-10-17 — partial derivation for [#119](https://github.com/berkeleynerd/silver/issues/119).**
This supplements the [capacity contract](retained-tool-capacity.md). It closes
the direct allocation-site inventory in the inspected sources and derives two
concrete fixed-input contributions. It does **not** establish the full
physical/virtual range inventory for every production phase, an enlarged
language, or a complete source-capacity admission rule. The current language
and tool pins remain unchanged.

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
assigned zero. The current fixed project/source configuration makes their
closure tractable, but the generated driver configuration and name map have
not been reconciled here.

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
fixed runtime template analysis still need to be reconciled before assigning
the dependency contribution a universal number.

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
`S` are justified concrete fixed contributions; **`C`, `A` and complete `V`
are not yet supplied**. Consequently this formula is not an implemented or
complete decidable membership test. It also says nothing yet about line-table
growth, other source-pointer operations, parser/copy nodes or producer data.

The smallest next source-closure steps are specific:

1. Reconcile retained production command/configuration/name-map artifacts for
   each frontend family. Prove a finite physical request-name set, account for
   generated configuration bytes, and exclude or charge each nonruntime path.
   Source inspection of GPR generation can settle these questions; a new run is
   warranted only if the retained artifacts and generator disagree.
2. Finish the generated-helper dispatch for the grammar's scalar, String,
   branch and loop compositions. Then enumerate generic spec/body instances,
   source overriding contracts and Inline_Always targets in that finite closure.
   Bound their multiplicities from deduplicated analysis and actual copy sites.
   Check native expansion and GNATprove modes separately.
3. Derive the binder-source size from its finite unit closure and selected
   switches. Reconcile the fixed-library frontend inputs independently; a
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
