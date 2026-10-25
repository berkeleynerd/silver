# Tamagotchi emulator

**Candidate: proofs likely to discharge automatically.** All state lives in small ranged counters that are guarded before each update and the input is a fixed embedded command script, so every check follows from types and guards with no recursion, while loops or annotations needed.

Position 1173 in the [progression](../../progression.md#stage-19), in stage 19.

## Approach

The pet is a record of ranged-subtype counters (hunger, boredom, age, hygiene) plus a pooped Boolean and an alive flag, and a constant array of enumerated commands (wait, feed, play, clean) embedded in the program is replayed by a for loop. Each command is a procedure taking the pet in out, using if guards before every increment so a counter reaching its maximum causes a printed death or sickness outcome instead of a range error. After each step a status procedure prints age, hunger, happiness, an ASCII avatar and a poop marker with Put_Line, using 'Image of small ranges. About 150 lines.

## Proof obligations to watch

- **range**: Hunger, boredom, age and hygiene counters are incremented in a loop-carried record, so each increment is guarded by a comparison against its subtype maximum just before use, with the pet dying (a visible outcome) when the limit is reached.
- **length**: Status lines are assembled from fixed text and 'Image of small ranged values into a bounded buffer whose size is chosen to exceed the longest possible line.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, enumerations, arrays, records, case statements, for loops, procedures, 'Image of scalars, string building and Put without a newline.

## External effects

- **console output** (allowed): The program prints the pet's status, avatar, poop and event messages as text to standard output.

Assessed on 2026-10-15 against page revision 414541 of the [task](https://rosettacode.org/wiki/Tamagotchi_emulator) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
