# Speech synthesis

**Excluded from Silver: sound.** The task needs one fixed text string spoken aloud, with no input, no randomness and no run-time error cases, so it needs only audio output. The existing FreeBASIC solution relies on Windows vbscript and a message box-free shell call, which is not evidence of a Silver conflict. A Silver-friendly version would synthesize the sentence from a fixed phoneme or sample table held in bounded arrays and play it, so no Oracle rule is broken.

## Language surface recorded by this assessment

Arrays and loops.

## External effects

- **sound** (not allowed): The task is to render the fixed sentence 'This is an example of speech synthesis' as spoken audio, so the program must produce audio output.

Assessed on 2026-10-15 against page revision 414887 of the [task](https://rosettacode.org/wiki/Speech_synthesis) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
