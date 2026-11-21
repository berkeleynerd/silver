# Shape-Machine

**Candidate: proofs plausibly discharge automatically.** All checks follow from the bounded float subtype and the capped counter, so no annotation is needed, but floating-point range reasoning plus the missing float parse and format library make it plausible rather than likely.

Position 1117 in the [progression](../../progression.md#stage-18), in stage 18.

## Failure paths to test

- **text parsing**: text that is not a number, a value outside the declared range, and empty text.

## Approach

Parse the first argument into a Double subtype bounded to +/-1.0e9 (reject otherwise), then in a procedure loop with while: compute next := (x+3.0)*0.86, stop and report if next = x, else print it and increment a bounded counter capped at a documented limit. Each printed value goes through an admitted float-to-text routine into a fixed-size buffer. About 45 lines.

## Proof obligations to watch

- **floating point**: The update (x+3)*0.86 on a Double subtype bounded to +/-1.0e9 stays inside that range by interval arithmetic, so overflow and range checks discharge without an invariant.
- **termination**: The quiescence loop sits in a procedure so it gets no termination check, and an explicit iteration cap with a printed 'not converged' outcome keeps it finite and visible.
- **range**: Parsing the user's number must validate syntax and the +/-1.0e9 bound, rejecting anything else, since the loop-carried value is known only by its subtype.
- **other**: Formatting a Double as text needs an admitted library routine with a specified result length, because 'Image-style output has no proven bound otherwise.

## Language surface recorded by this assessment

Floating point, ranged subtypes, integers, text parsing, floating-point images, 'Image of scalars, string building, while loops, procedures and Boolean objects.

## External effects

- **console output** (allowed): Prints each iterated value and the final iteration count.
- **arguments** (allowed): Reads the starting number from the first command-line argument, rejecting it if invalid or out of range.

Assessed on 2026-10-15 against page revision 414665 of the [task](https://rosettacode.org/wiki/Shape-Machine) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
