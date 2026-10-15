# Sine wave

**Excluded from Silver: sound, delay.** The task asks for a 5-second sine wave at a chosen frequency, played as sound. A bounded loop can fill a fixed-size sample array using a bounded-range or fixed-point sine, so no Oracle rule is broken. Playing the audio is an external sound effect that Silver does not have yet.

## Language surface beyond today's Silver

Integers, arrays, loops, subprograms and floating point.

## External effects

- **sound** (not allowed): The task requires playing the generated tone as audio. Playback is the stated requirement, not an optional extra.
- **delay** (not allowed): A 5-second tone played in real time means the program must wait for playback to finish. The wait only applies to live playback.

Assessed on 2026-10-15 against page revision 414730 of the [task](https://rosettacode.org/wiki/Sine_wave) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
