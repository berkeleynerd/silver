# Linear congruential generator

**Candidate: proofs likely to discharge automatically.** Modular arithmetic cannot overflow and is never checked, and dividing by a static nonzero constant produces no division check, so every remaining obligation is routine initialization and flow.

Position 1266 in the [progression](../../progression.md#stage-22), in stage 22.

## Approach

Declare a modular type with modulus 2_147_483_648 so that State * Multiplier + Adder wraps exactly as the task's mod 2^31 formula requires, and keep one state variable for each generator, seeded with an embedded constant. Two for loops over 1 .. 10 update each state and print it, BSD directly and Microsoft divided by the static constant 65_536, using 'Image. About 25 lines.

## Language surface beyond today's Silver

Modular types, integer division, 'Image of scalars and for loops.

## External effects

- **console output** (allowed): Prints the first ten values of the BSD and Microsoft sequences with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414308 of the [task](https://rosettacode.org/wiki/Linear_congruential_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
