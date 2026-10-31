# Named Integer subtype tests and drivers review — 2026-10-29

**Bounded verdict: one minor documentation correction; no actionable test or
driver defect found.** This review does not establish delivery or complete
native/Lean/source assurance for #286.

Reviewed commit: `1b3596b52106d0eca16022a1d64a46758ac6526c`. Inputs were
`tests/test_named_integer_subtypes.py`, the `tests/test_silver.py` changes,
`samples/rosetta_sum_of_squares.adb`, `samples/rosetta_sum_and_product.adb`, their
manifest entries, the relevant language/catalogue and capability sections, the
two cached `task.wiki` descriptions, targeted Rosetta mappings and the dated
assessment. Compared the documented rules with the subtype/type/constraint,
array initialization/read/store/iteration and capacity definitions in the native
sources at that same commit. No broad Rosetta reassessment was performed.

The retained stream-selection record identifies GPT-6 Astra / Extra High.
Original spawn arguments and runtime model/effort confirmation are unavailable
after context handoff; the resumed review's selection/runtime settings cannot be
independently verified. Review began at 14:57:43 UTC; substantive review finished
at 15:03:10 UTC (327 seconds elapsed, including context handoff), followed by this
report write. Token/cost measurements are unavailable. No tests, builds or proofs
were rerun, and no implementation files were edited.

## Finding

**Minor — distinguish String and scalar binding capacities.**
`language.md:218` says native binding storage has `4096 / 7 = 585` slots in the
paragraph explaining String initializer lengths. The new value applies to scalar
storage (`src/silver_scalar_expressions.ads:11`), while the String table still has
`4096 / 12 = 341` slots (`src/silver_output_profile.ads:13`). The capability record
already distinguishes these correctly. Name both tables in the language text so
the storage description agrees with the implementation. This is documentation
precision; no program-admission discrepancy was found. Disposition at review:
reported to the integration lead for correction.

## Reviewed behavior

The ten new test methods exercise direct and argument shells; Integer endpoints,
singleton and narrowed ranges; recursive staticness; invalid and overflowing
bounds; aliases and derived types; initialization and assignment containment;
case-insensitive namespace conflicts; type/operation hiding; metadata-only subtype
names; scoped loop binders; mutable widening; narrow stores after guards; source
and operator budgets; and native snapshots/argument handling. The same initialized
array tested with bounded and Full components discriminates declared-range
reasoning from incidental initializer values. Cell comparisons do not create
cell refinement. Invalid stores in an unreachable arm or empty counted loop are
explicitly rejected. The 370-binding check crosses the old scalar table capacity;
the 4096/4097-byte cases retain the complete-source boundary. The native
contradictory-guard regression preserves the #284 composition case.

The Sum of squares task (cached revision 415389) requires an empty-vector result
of zero. The sample's fixed-capacity representation uses logical count zero for
that case; its separate nonempty traversal computes
`3² + 1² + 4² + 1² + 5² + 9² = 133`. The addition threshold is Integer'Last minus
81, and every square lies in `0..81`. The Sum and product task (revision 413444)
uses the actual array `1..10`; its results are 55 and 3628800. Its sum and product
thresholds are Integer'Last minus 10 and floor(Integer'Last / 10), respectively.
No sample overflow guard can fail for the selected data. Manifest output bytes
include the required Integer Image leading spaces and final newlines.

The reviewed grammar/catalogue changes consistently restrict subtype parents to
visible predefined Integer, retain nonempty static bounds, allow further scalar
narrowing and bounded array components, and exclude aliases, conversions, inline
component constraints and dynamic bounds. Component intervals propagate to reads
and foreach elements; snapshots remain nonstatic where their sources are
nonstatic. The two targeted Rosetta changes preserve the broader unimplemented
subtype/array scope and historical assessment attribution. Candidate status and
pending complete assurance remain explicit in the capability and assessment
records. Execution and universal assurance are separate integration obligations.
