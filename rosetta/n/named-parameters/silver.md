# Named parameters

**Candidate: proofs likely to discharge automatically.** The cached task requires a function whose arguments can visibly bind by formal name irrespective of order. The noncommutative Subtract driver meets that interface and distinguishes an incorrect permutation. Defaults and omission are optional. Focused run 20261117T030042-d612d38a0399 compiled the unchanged source, audited its complete five-unit report and checked all four predicted output lines. Complete native run 20261117T034048-8c22c1e6a33d and complete Lean/source/module/axiom run 20261117T064945-d458c99ae977 passed on matching implementation inputs; the precise construct is now included in the supported mapping. Final delivery evidence is tracked separately in docs/named-scalar-arguments.md.

Position 71 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

samples/rosetta_named_parameters.adb defines a Main-local Subtract function with explicit in Small formals Left and Right and a Difference result. Main calls it positionally, with reversed named order, with a positional prefix and named suffix, and with the two values exchanged. It prints the independently derived results 2, 2, 2 and -2 with Integer Image. Every formal is supplied; optional default arguments are outside the selected capability. About 30 lines.

## Proof obligations to watch

- **overflow**: Small inputs span -100 .. 100; their difference spans exactly -200 .. 200 over all 40,401 input pairs and fits Standard.Integer and the declared Difference result subtype.

## Language surface recorded by this assessment

Small nonrecursive scalar functions, named scalar arguments, named Integer subtypes, bounded components and scalar signatures, bounded mutable Integer objects and Integer image.

## External effects

- **console output** (allowed): Main prints the Subtract result for positional, reordered named, mixed, and swapped-value calls.

Initially assessed on 2026-10-15 against page revision 411871 of the [task](https://rosettacode.org/wiki/Named_parameters) by claude-opus-5-5 at high effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-17 by Codex through targeted source review; see the [review record](../../assessment-named-scalar-arguments-20261117.md).
