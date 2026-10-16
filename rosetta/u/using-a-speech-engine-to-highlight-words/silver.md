# Using a speech engine to highlight words

**Excluded from Silver: sound, processes, delay.** The task needs a fixed text split into words, each word printed (the permitted fallback to cursor highlighting) and then spoken through an external speech engine. That requires sound and process effects Silver lacks today, but no Oracle rule is broken. Word splitting can use bounded strings and iteration.

## Language surface recorded by this assessment

String operations, arrays and loops.

## External effects

- **console output** (allowed): The text is displayed, and each word is printed as it is spoken. The task allows this when highlighting is not possible.
- **sound** (not allowed): The task requires spoken audio output from a speech engine.
- **processes** (not allowed): Producing speech means invoking an external speech engine or command, as the existing solution does with a shell command.
- **delay** (not allowed): Each word's output has to be paced to match its speech, either by waiting for the speech engine to finish that word or by sleeping.

Assessed on 2026-10-15 against page revision 375438 of the [task](https://rosettacode.org/wiki/Using_a_speech_engine_to_highlight_words) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
