# Native backend capacity component evidence

Supports the [location, String and constant-pool derivation](../../research/retained-backend-capacity.md)
for #119. No compiler, GNATprove, Lean, suite or near-limit allocation was run.

`source-manifest.json` identifies eighty-three complete GCC source files at
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`. Six newly retrieved files are retained
in `new-sources.tar.gz`; their immutable retrieval URLs are in the manifest.
The three additional allocator sources are in `allocator-sources.tar.gz`;
six constant-pool/header/generator sources are in `pool-sources.tar.gz`.
Five Ada files reuse the complete frontend inventory, and three generic GCC
files reuse the earlier emission archive. Eight vector/register/configuration
sources are in `vector-sources.tar.gz`. Eight block-operation files are in
`block-sources.tar.gz`. Seven cleanup/control-flow sources from the already
retained complete source inventory are in `cleanup-sources.tar.gz`; four
initial-CFG/location sources are in `cfg-sources.tar.gz`;
the additional libiberty hash source is in `location-sources.tar.gz`;
four constant-folder/pattern/configuration files are in `folding-sources.tar.gz`;
eighteen type/layout/hook and selected Linux header files are in
`type-sources.tar.gz`, reconciled against the retained complete source manifest;
the tree-walker declaration header is in `copy-sources.tar.gz`;
nine bitmap/obstack/pool sources are in `bitmap-sources.tar.gz`;
`target-options-query.json` retains the selected compiler's target-option query,
which compiles no source. These identities describe source
bytes, not a binary attestation. The ordinary Linux LP64 layout remains an
explicit premise of the String allocation arithmetic.

`selected-auto-host.h` retains the installed native compiler's relevant
statistics and host-word configuration; its digest is recorded in
`configuration-inventory.json`. This is a build-configuration premise, not
binary attestation.

`check.py` verifies all eighty-three complete-file hashes, checks reused identities
against their earlier manifests, extracts LF-numbered source ranges and
recomputes local integer arithmetic, including ordinary-map growth and the two
GNAT-node association backbones, constant-label mutation inventory and label
buffers, constant-pool hash capacity/probe arithmetic, and the 32-bit RTL
alignment-mask boundary (including its counterexample above that boundary).
It retains the gigi ordinary Main literal traversal sources and the resulting
event/byte interface; the report supplies that manual caller argument. It also
checks ordinary heap/GC vector capacities, the rounding counterexample,
pseudo-register backbone growth, and the O0 label-event exclusions.
The block-operation check reconciles the direct movmem primitive sites, the
manually derived bounded-helper subtotals, and the early fallback ordering.
Those primitive counts are not transitive RTL or machine-code bounds.
The cleanup check verifies the CF/EH pass order, O0 copy gate and default Ada
hook, then enumerates the continuation flags to check the manually derived
constructor sums. It includes the implicit return's preceding conversion to a
goto; it does not infer absence of generated transfers from source syntax.
The selected clobber/stack-restore copy continuation checks the exact empty
constructor and walker stop rules; its one-node operand-copy bound relies on
the source argument's two cleanup shapes, not arbitrary GIMPLE operands.
The initial-CFG continuation checks the ordinary block/edge/vector and location
discriminator formulas against the explicit no-abnormal-goto frontier. Later
CFG cleanup and loop discovery are separate stages.
The ad-hoc-location continuation checks backing growth and the separate
libiberty hash table's prime sequence and arithmetic. It retains the conservative
twice-live-entry sufficient region and leaves all-phase request counts explicit.
The constant-folding continuation checks Integer constant limb/cache arithmetic,
the selected sharing-limit default and generated recursive folder calls. Its
two-request fold row covers only the report's enumerated successful scalar
constant cases; symbolic folding and arithmetic scratch remain separate.
The type continuation checks the selected Linux hook/header exclusions,
scalar-layout constructor arithmetic, type UID/cache domains and a conservative
fixed-size type-node bound. Aggregate layout, language-specific type data and
all-phase request counts remain separate.
The Character-array continuation closes constant layout and its x86 empty-array
query, verifies the mode-selection fallback and records the dynamic layout's
symbolic-helper interface. It does not price those symbolic helpers or infer a
String length limit from the scalar-mode lookup's unsigned-int temporary.
The expression-copy continuation checks the callback/walker stop boundaries and
constructor-vector copy path, and contrasts shared DAG occurrence counts with
SAVE-protected inputs. It does not claim a source-to-whole-body copy bound.
The whole-body continuation retains the three initial roots, protected-node
set and declaration/type metadata traversal. Its manual transfer is at most
three times the completed incoming-edge forest weight per function invocation;
the checker verifies those source sites, not the missing source-to-forest join.
The placeholder-substitution continuation reconciles the primitive sites and
no-inline route; the source argument distinguishes its original-operand recursion
from folder allocations and establishes the unchanged, placeholder-free case.
The size-extrema continuation checks the body-inlining gate, direct helper
sites and the signed byte-length limit in variable-arity call construction.
Its manual transfer covers scalar size expressions without a reached
placeholder-reference or inlineable body; symbolic folder work is separate.
The bitmap continuation checks word/configuration and sparse fixed-object
allocation facts, then evaluates dense size/vector products at representation
boundaries. Linked sparse allocations have no aggregate byte-span gate; their
callers still supply the bit universe, valid views and obstack nesting bound.
`checks.json` and `source-excerpts.md`
retain its outputs. The script does not establish caller coverage or replace
the report's manual source argument.

From this directory, using the pinned source tree retained by the earlier audit:

```sh
python3 check.py --ada /path/to/gcc/ada --output /path/to/new-scratch
```

`configuration-inventory.json` retains the complete non-tests GCC source
search for static-space calls, partition-flag writers and pseudo-register
number writers, plus the selected installed target-header inventory. To
reproduce those optional broad searches too, add
`--gcc-root /path/to/pinned/gcc-source` and
`--plugin-include /path/to/selected/compiler/plugin/include`. The source tree
was retrieved from the immutable codeload archive for the manifest's commit;
only its non-tests C/C++/header/configuration files were extracted into scratch.
The optional inventory check compares exact file-list digests as well as
the search results. Ordinary archive checks do not claim to rerun that scan.

Compare both generated files with the retained outputs. The script reads the
archives directly without extracting them or executing any upstream program.
Keep the input tree, archives and existing caches intact.
