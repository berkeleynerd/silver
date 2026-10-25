# Multiton

**Candidate: proofs likely to discharge automatically.** Every check is an array index by an enumeration, a bounded serial counter or a bounded string concatenation, all following from declared types and guards, with no loops carrying unbounded values and no recursion or heap use.

Position 1160 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

An enumeration Key (Zero, One, Two) indexes a fixed array of records holding a Created flag and a Serial in a declared range; a procedure looks up a key name by String equality, creates the instance with a deterministic serial counter on first request, and returns the stored instance on later requests. A disallowed name such as "three" takes an explicit else branch that prints a rejection message and creates nothing. A test sequence over embedded names prints each identifier built from the key text, an underscore and the serial image, showing repeated requests return the identical instance. About 70 lines.

## Language surface recorded by this assessment

Enumerations, ranged subtypes, integers, records, arrays, procedures, Boolean objects, for loops, case statements, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): Prints each requested instance's identifier and the rejection message for a disallowed key.

Assessed on 2026-10-15 against page revision 413508 of the [task](https://rosettacode.org/wiki/Multiton) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
