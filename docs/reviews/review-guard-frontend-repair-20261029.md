# Scalar-guard frontend repair review — 2026-10-29

Independent critical review of #284, selected GPT-6 Astra / Extra High. Runtime
settings were not independently confirmed; token/cost measurements are
unavailable. Inspection ran 08:02:03–08:09:35 UTC (7m32s), read-only: no builds,
proofs, edits or GitHub writes.

## Target and verdict

Base `7f53618ca0e277c6a0e586b1c19f9fa54dcb0b83`; final implementation
`039daa30341e6a2e042c9e930568ef16eff97bf3`. The six-file diff SHA-256 is
`f611452a9987617682c190ff1d617cef42e34412668b7d17fa4e75d6959bbf5a`.
It covers the driver, three regressions, assurance/boundary/repair records and
`Current.ToolContract` commentary. No unresolved implementation finding remains.
Final focused driver validation and native regressions were pending when this
review finished; later outcomes belong to the [evidence packet](../evidence/scalar-guard-frontend-20261029/README.md).

The native-only correction is supported by the reviewed frontend mechanism.
It blocks the identified literal-substitution route while preserving author
source and admission. Static evaluation and the range-check fallback remain
active; the additional nullness consumers conservatively withhold facts.
`buildCompletes` remains an external premise, not a universal proof of GNAT.
Complete native and Lean/source/module/axiom checkpoints remain required before
merge after applicable external feedback is integrated.

## Findings resolved during review

- **Medium:** the initial shared-project option changed GNATprove's embedded
  frontend, while the exact source audit covered native GCC only. The final
  patch moves `-gnatdM` to `Build_Command` as `-cargs:Ada -gnatdM`, preserving
  generated-project and proof options. The original-source regression checks
  project absence and native Main ALI presence of the option.
- **Low:** the matrix contains 17 admitted baseline failures, not 18. The
  final record corrects the count. The analyst also narrowed an overbroad
  `Current_Value` wording to the inspected range-inference path.

## Reviewed evidence and limits

The reviewer independently inspected the native flag consumers, replacement
gate, static evaluation, range-check fallback, actual patch, and three tests.
The shared test helper verifies byte-identical captured source and complete
Main/selected-library reports. The tests include live updates and argument,
array and loop compositions.

The compile-only matrix has 27 admitted shapes; all 17 original failures compile
with M. Its actual static range error remains rejected. Both dynamic controls
retain runtime `Constraint_Error` and unproved GNATprove checks. Those controls'
shared-project proof configuration is correctly labeled diagnostic evidence,
not final proof-configuration evidence.

| Input | Identity |
| --- | --- |
| Native GCC | `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` |
| Retained source analysis SHA-256 | `ab5160c1f755f19575c817f2e9279f2c316e1ab7a7fa1c870065679a6a4c24a9` |
| Matrix results SHA-256 | `628e07c0dcfff6dd232ef3f80cec712011cc83ebc25477e525e0f4ff95aff205` |
| Control results SHA-256 | `70fca97dda2a39a455fc80cc94ea1ff140bd4ae9a3e6bfcd79599be91d4c8039` |

The source audit is explicitly limited to native GCC's pinned frontend. Its
source provenance is release-derived, not reproducible binary attestation.
The detailed argument and exact inputs are retained with the evidence packet.
