# Frontend tool availability and GNATprove interfaces

**2026-10-17, research #113.** This is source and package research on Linux
x86_64. It selects no toolchain, changes no implementation and makes no native
near-limit observation. The [result](frontend-representation-result.md) combines
this evidence with the wider and deferred storage designs.

## Available candidates inspected

The [retained evidence](../evidence/unbounded-programs/frontend-representation-20261017/toolchain/MANIFEST.json)
includes exact API responses, retrieval metadata, source snapshots, comparisons
and a verifier. All references below are immutable commits observed on this date.

| Candidate | Exact source / package reference | Result of inspection |
| --- | --- | --- |
| GCC 16.1 baseline | `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` | The [previous complete Ada-tree audit](unbounded-frontend-lifetimes.md) establishes the shared signed-Int character-pool obstruction. |
| GCC releases/gcc-16 | `ad2160df97c4f99427f0a9042e884a143c315a93` | `stringt.adb` is byte-identical to the baseline. This inspected maintenance branch supplies no replacement Stringt implementation. |
| GCC master | `9e5dc38543418730291b90de2d03263a60ce5b8f` | `types.ads` and `table.adb` are byte-identical to the baseline. The only `stringt.adb` change simplifies Character conversion; `stringt.h` retains Int offsets. No wider/deferred implementation in these components. |
| Recent integrated patch history | 30 `stringt.adb` and 20 `table.adb` commits ending at that master | The newest Stringt change is the Character conversion cleanup, `ae59b39ffb2e`; the Table abstraction change `9d052b444f4c` is already in the baseline. The retained history is a bounded search of integrated changes, not all mailing-list submissions or vendor patches. |
| GNAT LLVM | `AdaCore/gnat-llvm` at `4ba5c6c11b1ff91ff0fa692bdc0c86be6364de79` | README/build instructions obtain GCC's Ada frontend and symlink it into `llvm-interface/gnat_src`; LLVM/Clang 21.1.x replaces the backend. This does not avoid the earlier static folding or Stringt pool. |
| Alire stable index | `alire-project/alire-index` at `332896ab4cc8e4a075e23abe2253c2c2de471b8b` | Complete, untruncated 3,478-entry inventory lists `gnat_native` and `gnatprove` through 16.1.0, using the existing GNAT-FSF-builds archives. No `gnat_llvm` package path in this inventory. |
| SPARK fsf-16 | `42554fc241fcd1fdf08d3a2feccb3f86912acbc0` | Separately builds GCC Ada sources into gnat2why. Its String literal translation expands one predicate per character; details below. |
| SPARK master | `08eb41dfbe42336e19a3bbc7063793319209a229` | The inspected literal translation and Why node types still contain that per-character path and 30-bit node IDs. This is not a compatible replacement-tool claim. |

No inspected candidate supplies the required end-to-end replacement off the
shelf. This is not an exhaustive absence claim about proprietary tools,
uninspected branches or unmerged patches. No vendor or upstream maintainer was
contacted. A guessed `AdaCore/gnat-llvm-gnat` repository returned 404; the actual
GNAT LLVM README resolved the frontend source route. A separate malformed API
request with a leading space also returned 404 and is retained as a request
error, not negative availability evidence.

## GNATprove has its own frontend

The Alire GNATprove 16.1.0 Linux manifest selects
`gnatprove-x86_64-linux-16.1.0-1.tar.gz`, SHA-256
`82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191`.
The installed package resides under
`.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef`.
The GNAT-FSF-builds `gnatprove-16.1.0-1` tag resolves to recipe commit
`0334dd54a2c479faa3dfad47a911373581b11739`.

At that recipe, `specs/spark2014.anod` downloads the GCC 16.1.0 release and
SPARK/sparklib's **floating `fsf-16` branches**. It patches `comperr.adb`'s
bug-report text, copies the GCC Ada directory into `gnat2why/gnat_src`, then
builds `all-nightly`. `gnat2why_gnat.gpr` selects `gnat_src` and replaces the
normal backend/driver. Production uses `-gnatpn`; do not interpret source
subtype checks as a measured checked-build failure threshold.

Changing only the compiler selected as `gnat_native` therefore leaves the
separately built GNATprove frontend unchanged. A candidate must reach both
products, with matching Stringt semantics and the appropriate consumer APIs.
The separate `gnatutil.anod` recipe is not the gnat2why source-selection path.

The recipe establishes the build route, not the exact SPARK commit used for the
installed archive. The current `fsf-16` commit above is an exact inspected
snapshot; it is **not** asserted to be the installed binary's source. The Alire
manifest itself describes an intermediate SPARK Pro commit rather than a
particular Pro release. Binary attestation or reconstructing the distribution
was not needed for this research. Any adoption must establish the relevant
source/tool correspondence, including the producer path, instead of transferring
this snapshot's conclusions to an unidentified executable.

## String consumers and producer growth

The SPARK snapshot's complete `src/**`, `gnat2why/**` and three root build/version
files were retrieved: **320 files**, each checked against the untruncated Git
tree's blob identity. A retained literal-token search gives **51 lines** for
Stringt, Strval and selected String APIs. This is a search inventory, not a
resolved call graph; overloads and `To_String` uses require contextual reading.
The important production path is independently visible in these exact sources:

| Source in fsf-16 | Interface / consequence |
| --- | --- |
| `src/why/gnat2why-expr.adb:30221–30370`, `Transform_String_Literal` | Reads `Strval`, retains `Nat` length and calls `Get_String_Char`. For ordinary Character literals, allocates `W_Pred_Array (1 .. Natural (Length))`, then builds index, array-access, character and comparison nodes for every character. The module cache avoids regenerating the same literal module; it does not compress a newly translated literal. |
| `src/why/spark_atree.adb:541–584` | `Has_Wide_Character` and `Has_Wide_Wide_Character` scan characters, traversing the complete literal for ordinary Character content, because generated literals do not reliably carry the source flags. They can return early for wide content. A DAG accessor preserves correctness but makes full scans expensive unless exact summary flags/cursors are added. |
| `src/why/why-gen-expr.adb:3533–3569` | `New_And_Pred` allocates a second length-sized array, filters it, then forms an n-ary conjunction. It avoids a deeply nested binary tree, not the per-character population. |
| `src/why/why-types.ads:35–43` | `Why_Int` is signed 32-bit; `Why_Node_Id` is `0 .. 2^30 - 1`; list IDs occupy the other half. These are representations, not physical memory limits. |
| `src/why/xgen/why-atree.ads-tmpl:104–111`; `xtree_builders.adb:238–249`; `why-gen-expr.adb:4289–4331` | The node vector is indexed by `Why_Node_Id`; `New_Comparison` constructs a `New_Call`, whose generated builder appends a fresh node. `why-atree.adb:86–98` also appends nodes. There is no per-character node reuse in this construction. |
| `src/why/why-gen-hardcoded.adb`, `src/spark/spark_util.adb`, annotation and counterexample consumers | Some routes materialize host Ada Strings or name buffers. Reachability depends on selected libraries/features; compatibility with all selected support sources still needs accounting. |

For this inspected literal path, a new length-2^30 Character literal needs at
least 2^30 comparison nodes, before the other nodes. That alone exceeds the
1,073,741,823 nonzero node identities. The array and node growth can exhaust
ordinary hosts much earlier. This is a conditional source-derived obstruction
for a literal that reaches this path, not a measured installed-tool cutoff or
a claim that every declaration is translated regardless of reachability.
SPARK master retains the corresponding array/loop at lines 27969–28007 and the
same node type; it does not remove this inspected path.

Widening Stringt removes neither this population nor its ID limit. A deferred
Stringt DAG also loses its compression at this API boundary. For a fully
scalable producer, the concrete interface extension would expose immutable
literal/concat structure and exact length to gnat2why, produce one shared Why
definition per unique representation node, and encode concatenation by an
index-selection equation with the original lower bounds. Literal leaves still
need exact character facts. Correctness needs preservation of all checks,
content, equality and bounds; compressed terms also need a renewed automatic
discharge argument. This is a specified subsequent design obligation, not an
implemented or proved solution. Merely widening Why IDs addresses identity
capacity but leaves expanded-length work and the remaining table/byte bounds.

The proposed non-gating confirmation architecture already distinguishes named
producer boundaries from build membership. This finding does not silently add
a language cap or adopt a new confirmation classification. A later detection
rule would need the actual selected producer and reliable diagnostics. Reporting
an incomplete confirmation never proves the missing obligations; neither this
boundary nor a generic sufficient-resources premise resolves known finite
representation limits. The larger universal assurance and producer premises
remain unestablished.

## Integration and platform requirements

Alire can distribute distinct externally maintained builds, but a manifest is
packaging, not a source fix or ownership exemption. Current `alire.toml` and
`scripts/bootstrap.py` require the GNAT/GNATprove 16.1 major/minor family and
verify resolved selections. A later adoption must deliberately update matching
packages, origins and configuration; preserve the existing host installations;
and regenerate the installation-bound Image overlay and support-tool identities.
An ordinary upstream version change does not itself require an Oracle amendment.

Both GCC and GNATprove need exact build inputs for the affected code. Widened
Ada/C record fields need agreed layout, offsets, alignment and signedness, plus
safe conversion to `size_t` and pointer offsets. All four published Linux/macOS
x86_64/aarch64 origins are present in the inspected Alire manifests; their
existence says nothing about a modified frontend's availability. An `int64_t`
interface must be checked independently on each target rather than assuming
Ada `Long_Long_Integer` and C `long` always coincide. Linux remains primary;
macOS ABI/build evidence is independent and nonblocking for this result.

The prior Linux medium/large-model probes show only small complete Ada links.
They do not demonstrate near-Integer'Last initialized literals, all GCC emission
options, Mach-O limits, enlarged runtime contracts or the changed producer.
The [deferred-storage record](frontend-deferred-storage-feasibility.md) identifies
the remaining GCC literal materialization and merge-string option boundary.

## Verification and retained artifacts

`raw-evidence.tar.gz` contains the selected sources, complete API inventories,
retrieval records, exact diffs and collection helpers. The archive's manifest
checks every member; `verify.py` also checks all 320 SPARK files against their
Git blobs and every retained GitHub contents source. The original 12,757,241-byte
SPARK archive remains at
`/tmp/silver-frontend-representation-20261017/availability/spark-fsf16.tar.gz`;
its SHA-256 is `17bb4e856b8eddfde94859129a862233ae9457fd6b92d0f70f34bd21093f73f8`.
The package contains the selected source bytes rather than the unrelated full
testsuite archive. GCC baseline bytes remain in the earlier evidence.

No compiler build, application/prover invocation, native near-limit probe,
complete native audit, Lean build, full test suite, macOS run or CI run was
performed for this source/package analysis. Documentation consistency and
artifact/hash checks are its validation, not a new capability checkpoint.
