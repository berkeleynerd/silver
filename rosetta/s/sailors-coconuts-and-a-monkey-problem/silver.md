# Sailors, coconuts and a monkey problem

**Candidate: proofs plausibly discharge automatically.** Everything is bounded integer arithmetic in procedures with explicit limit guards, so no annotation is needed, but the loop-carried pile, division by a variable and the subtract-after-test pattern make discharge depend on careful typing and guards.

Position 245 in the [progression](../../progression.md#stage-7), in stage 7.

## Approach

A search procedure takes a sailor count (subtype 2..9) and, starting from a candidate pile, runs a while loop that tests the tale's constraints on each candidate: for each sailor, check that pile mod n = 1, record pile / n in a hidden-counts array, and reduce the pile, then check that the final pile divides by n. Candidates step by n up to a declared limit, and reaching the limit yields a printed 'no solution within limit' outcome. Main calls it for 5 and 6 sailors and prints results using 'Image-built strings. About 80 lines.

## Proof obligations to watch

- **overflow**: The candidate pile is a loop-carried value, so a guard against a declared upper limit (with a visible 'not found' outcome) precedes each increment.
- **range**: The subtraction nc - (nc / n + 1) inside the sailor loop needs nc >= 1, which the preceding remainder test (nc mod n = 1) supplies, though the provers must handle division by a variable n.
- **termination**: The search loop is a while loop, so it lives in a procedure, where no termination check applies, and the upper-limit guard also bounds it.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, arrays, for loops, while loops, procedures, Boolean objects, 'Image of scalars and string building.

## External effects

- **console output** (allowed): Prints the minimal pile size and each sailor's hidden count for 5 and 6 sailors.

Assessed on 2026-10-15 against page revision 414456 of the [task](https://rosettacode.org/wiki/Sailors,_coconuts_and_a_monkey_problem) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
