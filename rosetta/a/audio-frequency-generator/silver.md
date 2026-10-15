# Audio frequency generator

**Excluded from Silver: sound.** The task asks for an audible, continuous tone whose frequency and volume can be changed, plus a hardware availability check and a clean silence on exit. Silver will need an admitted audio library with specified failure outcomes to do this. No fixed Oracle rule is broken: adjustment commands can come from standard input, frequency and volume can be bounded integer ranges with visible rejection at the limits, and the optional waveform selector is an enumeration.

## Language surface beyond today's Silver

Floating point, integers, loops, subprograms and enumerations.

## External effects

- **sound** (not allowed): The task needs live audio. The program must check whether sound hardware is available, play a continuous tone through it, change the tone's frequency and volume while it plays, and silence or reset the hardware on exit.
- **standard input** (allowed): Frequency and volume adjustment commands (for example up/down for each) can be read from standard input while the tone keeps playing. This replaces raw arrow-key handling.
- **console output** (allowed): The program reports whether sound hardware is available, shows the current frequency and volume, and gives a visible message when an adjustment is rejected at a documented limit.

Assessed on 2026-10-15 against page revision 415042 of the [task](https://rosettacode.org/wiki/Audio_frequency_generator) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
