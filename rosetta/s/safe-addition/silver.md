# Safe addition

**Candidate: proofs plausibly discharge automatically.** The only nontrivial check is floating-point overflow of A + B, which a simple operand-range guard with a visible invalid outcome discharges; the remaining uncertainty is GNATprove's support for the Float'Adjacent attribute, not any annotation need.

Position 1044 in the [progression](../../progression.md#stage-17), in stage 17.

## Approach

An Interval record holds Lower and Upper Float components plus a Valid flag, and a side-effect-free function Safe_Add computes the machine sum after a range guard on both operands, then widens it to the adjacent machine numbers towards Float'First and Float'Last (giving the zero case the smallest symmetric interval around 0.0). Main applies Safe_Add to embedded example pairs such as 1.14 and 2000.0 and prints each interval with Float'Image, or a rejection line when the guard fails. About 45 lines.

## Proof obligations to watch

- **overflow**: The machine sum A + B can overflow Float for arbitrary operands, so the function first tests that both operands lie within plus or minus Float'Last / 2 and otherwise returns an interval marked invalid, which Main reports visibly.
- **floating point**: The bounds come from Float'Adjacent (Result, Float'First) and Float'Adjacent (Result, Float'Last), which never step past the type's extremes and so carry no range check, but whether GNATprove models 'Adjacent precisely enough (rather than rejecting or approximating it) is the main uncertainty.
- **length**: The output line concatenates two Float'Image results with a separator, whose lengths are statically bounded by the attribute so the concatenation length check is routine.

## Language surface recorded by this assessment

Floating point, floating-point images, records, functions and Boolean objects.

## External effects

- **console output** (allowed): The program prints the lower and upper bounds of the interval for the embedded example sums.

Assessed on 2026-10-15 against page revision 413899 of the [task](https://rosettacode.org/wiki/Safe_addition) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
