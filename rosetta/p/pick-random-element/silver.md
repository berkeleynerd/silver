# Pick random element

**Candidate: proofs likely to discharge automatically.** The task only needs a deterministic pseudo-random index into a fixed array, and the index is bounded by mod on a modular type, so every check follows from types and static bounds with no loop-carried facts.

Position 1262 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

Constant fixed-bound Character arrays hold the vowels, consonants and punctuation, and a modular-type linear congruential generator with a seed embedded in the program supplies pseudo-random values. A pick function reduces the generator value with mod by the array length into a subtype index, and for loops build three 20-letter words, printing them with Put and Put_Line. About 45 lines.

## Proof obligations to watch

- **overflow**: The deterministic generator state is a modular type, so wraparound in the update is defined and raises no overflow check.
- **index**: The picked index is the generator value reduced with mod by the array length, so it lies within the array's constrained index range by type and guard.

## Language surface recorded by this assessment

Integers, integer division, modular types, ranged subtypes, characters, arrays, for loops, procedures, functions and Put without a newline.

## External effects

- **console output** (allowed): The program prints the picked elements and generated words to standard output.

Assessed on 2026-10-15 against page revision 415280 of the [task](https://rosettacode.org/wiki/Pick_random_element) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
