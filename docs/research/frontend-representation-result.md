# Frontend representation feasibility result

**2026-10-17 — research #113.** The smaller concrete candidate is a checked
64-bit String character pool, matching Ada/C descriptor changes, and a
zero-mantissa scanner optimization. It removes the two specific storage
problems identified in the [previous research](unbounded-feasibility-result.md)
without changing the author source or deferring Ada static legality to runtime.
It is a reasoned component design, not an implemented toolchain or a proof of
tractability for the complete proposed language.

**Implementation remains at a full stop.** None of the inspected external
tools supplies this paired GNAT/GNATprove change. The concrete designs change
compiler bodies, including the C/C++ interface; no fully verified SPARK-owned
replacement route has been demonstrated. GNATprove also has a separate
expanded-literal producer limit. Calling a private fork external, or making
confirmation non-gating, does not settle these requirements. Do not begin
#88–#94 or adopt a smaller language domain on the strength of this research.

## What the comparison establishes

| Candidate | Concrete benefit | Cost and remaining limit | Assessment |
| --- | --- | --- | --- |
| [Checked local widening](frontend-wide-storage-feasibility.md) | Retains existing static evaluation and String APIs; widens only shared pool positions/counts and the C descriptor offset. With checked descriptor and per-value bounds, the aggregate payload fits a derived 64-bit representation. | Still materializes values: the two-chain witness alone needs at least 8 GiB of Char_Code payload. All table growth, ABI and allocation arithmetic must change coherently. Other compiler tables and source accounting remain open. | Preferred first frontend component: the narrowest semantics-preserving repair identified. It buys the intended per-value composition space for this pool, subject to the remaining constraints. |
| [Deferred immutable structure](frontend-deferred-storage-feasibility.md) | A balanced concatenation DAG shares repetitions; the two chains can use two character leaves and 60 concatenation roots, excluding ordinary compiler/descriptor overhead. Length and static value stay exact. | Current mutable descriptor semantics must coexist with immutable snapshots. Raw C pool readers need a new bridge; random access, comparisons, serialization and diagnostics need review. GCC and gnat2why still expand the value later. | Credible representation design, broader implementation/assurance surface. Not needed merely to remove the known pool-width obstruction; preferable only when avoiding materialization is part of the selected end-to-end design. |
| Keep existing pin and derive aggregate restrictions | Avoids a tool change, with explicit source-sensitive accounting. | Excludes otherwise intended compositions; complete whole-program accounting is still absent. A uniform low cap is not justified by the current evidence. | Comparison alternative only. No lower cap or rule is selected. |
| Select an available replacement package/backend | Would preserve an external-tool ownership route if a suitable pair existed. | Inspected Alire releases and GCC branches retain the obstruction; GNAT LLVM uses the same frontend. | No suitable off-the-shelf candidate found in the inspected set. This is not a global absence claim. |

The widening arithmetic is specific. The nominal String ID range has
99,999,999 descriptor identities after excluding `No_String`, including the
null descriptor. With per-descriptor length at most 2,147,483,647, their product
is 214,748,362,552,516,353 characters, below 2^58; four-byte payload and array
bit size also fit the proposed scalar arithmetic. The current descriptor table
uses `String_Id'Base` and does **not** enforce this nominal count. The design
therefore includes checked descriptor allocation, reserved in-flight charges,
bounded designated arrays, safe saturated growth and byte conversions.
It still needs source/phase accounting proving that admitted programs and
their selected dependencies cannot hit a representation guard. This is not a
newly adopted count cap or a proof that 64 bits suffices for the whole compiler.

For `0E799999`, skipping power construction after the existing exponent and
syntax checks removes work whose result would be multiplied by zero. Changing
only multiplication is too late. The candidate preserves the rejection of
`0E800000`, real-literal behavior and syntax-only paths. It does not settle the
numeric tables used by arbitrary generated compiler values.

## The producer is a separate requirement

The [toolchain investigation](frontend-toolchain-feasibility.md) verifies that
GNATprove's build recipe copies GCC Ada sources into its own frontend; changing
`gnat_native` alone cannot change it. In the exact inspected SPARK snapshot,
`Transform_String_Literal` allocates arrays and new comparison/access nodes per
character. Why node identities occupy only `0 .. 2^30 - 1`. A length-2^30
literal reaching this path needs more comparison identities than are available,
before its other nodes. This is a source-derived conditional limit, not a native
failure observation or an attestation of the installed SPARK source commit.

Both storage candidates preserve that consumer interface and therefore leave
this problem. A compressed producer would need to consume shared literal/concat
structure, preserve exact indexing/lower bounds and content through shared Why
definitions, and retain all obligations with an automatic-discharge argument.
Wider IDs alone leave expanded-length work and further capacity arithmetic.
Neither design has been implemented or verified in this research. The proposed
confirmation-only boundary policy can report a reliably detected incomplete
confirmation; it cannot establish the missing universal assurance.

The GCC backend still materializes each emitted String. Its literal constructor
has enough unsigned allocation arithmetic for the intended Character length in
the inspected source, but option-dependent terminator/merging paths, initialized
object/link limits and all-platform lowering still need accounting. The earlier
small medium/large-model Ada links remain useful evidence with their original
scope. They are not near-limit validation.

## Ownership under the unchanged Oracle

The [Oracle](../../oracle.md) requires all Silver compiler and Silver-owned
runtime/library implementation code to be SPARK and verified to Bronze and
Silver levels. It separately names GNAT/GNATprove as trusted external tools.
The [trusted-boundary record](../trusted-boundary.md) explicitly says this is
not permission to introduce unverified Silver implementation bodies.

An unmodified, externally maintained GNAT/GNATprove release can fit the existing
external boundary; a version change alone is not an Oracle amendment. A change
accepted, integrated and maintained by upstream could supply that route, but
anticipated acceptance is not an available dependency. A patch submission,
renamed repository or Alire manifest alone does not transfer ownership.
The policy does not define a mechanical test for every vendor/fork arrangement;
unclear maintenance responsibility must remain explicit.

A Silver-owned implementation in verified SPARK is allowed in principle,
including import-only bindings to approved external services. All new storage,
transformation and interface bodies would need verification and correspondence;
Lean cannot exempt a new C++ or SPARK-off body. The narrow candidates inspected
here modify such bodies, and no all-SPARK implementation architecture covering
every required interface has been established. This is a limit of the
demonstrated routes, not a proof that every conceivable SPARK solution is
impossible or that every compiler fork inherently requires an amendment.

**Recommended disposition:** retain the unchanged Oracle and seek an actually
externally maintained paired frontend/producer solution, using the bounded
widening design as the concrete minimum frontend requirement. Resolve that
ownership and producer scope before commissioning implementation. This research
does not authorize contacting maintainers, submitting patches, changing policy
or beginning another open-ended investigation. If external support cannot be
obtained, the owner must explicitly choose a different permissible route; the
agent must not silently maintain unverified compiler bodies or lower the domain.

## Concrete scope after that disposition

The following is a dependency outline for a later authorized implementation,
not additional Ready work packages:

1. Establish exact maintained GNAT/GNATprove sources and the implementation
   ownership route. Close the selected producer strategy and actual diagnostic
   boundaries; preserve authoritative source and Ada static semantics.
2. Implement checked String storage/ABI and scanner semantics in both frontend
   products; establish operation invariants, failure behavior, layout and
   relevant proof obligations. For owned bodies, SPARK/Lean requirements apply.
3. Close whole-program source/descriptor/table accounting, selected runtime and
   generated-source closure, GCC emission options and backend capacity. This is
   still part of #91/#93's unfinished feasibility, not solved by the pool bound.
4. Integrate explicit Alire package identities and host-specific installations,
   refresh the Image producer/source correspondence and universal discharge
   argument, then implement the already scoped #88–#94 in their recorded order.
   Native Linux validation is primary; macOS evidence is independent.

Before starting any split implementation, create its actual increments and
completion criteria together as [planning](../planning.md) requires. This list
does not pre-approve a split, a new tool pin, a language restriction or an Oracle
amendment.

## Evidence and completion scope

The three linked technical records retain exact sources, interface inventories,
arithmetic and repeatable evidence checks. The full ownership-policy analysis
is retained with the toolchain evidence. This pass needed source and arithmetic
inspection, not a giant compiler build: none of the remaining ownership or
producer questions would be answered by repeating the existing large-value
allocation obstruction on this host.

No production source, proof, catalogue, sample, tool installation or Oracle
changes belong to this delivery. No new compiler/proof run or native macOS/CI
claim is made. Documentation/evidence checks and independent review validate
the research claims and packaging; they do not establish larger-language
support. #113 can complete as a reviewed research stop while #88–#94 and
milestone 5 remain incomplete. The earlier For loops and integers harness goal
remains complete; no new goal was requested or created. CLI memory is unavailable
and was not updated.
