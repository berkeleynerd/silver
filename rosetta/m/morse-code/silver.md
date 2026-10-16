# Morse code

**Excluded from Silver: sound.** The Silver-friendly solution holds the input text as a constant or bounded string, maps each character through a constant lookup array of dot/dash/gap symbols (enumeration plus array, no recursion or pointers), skips characters with no Morse code, and sends the resulting timed tones to an audio device through a sound library operation. The only missing piece is audio output, which is an effect Silver does not yet have; no rule is broken. The existing Ada solution's Windows-only Beep import and its Ada-specific packaging are not treated as requirements.

## Language surface recorded by this assessment

Arrays and enumerations.

## External effects

- **sound** (not allowed): The task requires sending the Morse signal as audible tones to an audio device such as the PC speaker. Silver has no audio admitted today, so this is a missing effect, not a conflict. Tone durations for dots, dashes and gaps are passed to the device, so no separate delay effect is needed.

Assessed on 2026-10-15 against page revision 404776 of the [task](https://rosettacode.org/wiki/Morse_code) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
