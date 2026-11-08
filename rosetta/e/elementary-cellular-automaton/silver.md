# Elementary cellular automaton

**Candidate: proofs likely to discharge automatically.** The program implements all 256 local transition rules by their eight decoded bits, reads a separate unchanged generation and wraps both edges, as the cached task requires. Width, initial state and rule choices are static source configuration within Silver's budgets; the demonstration selects width 21, 16 rows and rules 90, 30 and 122. Independent expected rows use neighborhood bit shifts. Native driver execution is retained separately from complete resulting-language assurance; the [mapping record](../../assessment-boolean-arrays-20261106.md) records the bounded interpretation and historical provenance.

Position 71 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Use samples/rosetta_elementary_cellular_automaton.adb: iterate constant Integer rule values 90, 30 and 122; decode each rule into eight Boolean cells by repeated / 2 and mod 2; reset a width-21 state to one central active cell; display 16 generations. For each new generation compute 4 * left + 2 * current + right using wrapping modulo neighbors, write a separate Boolean Next_State, then copy components into State. Print #/. directly with Put, without a String buffer or user routine. Static declarations configure rule values, width and arbitrary initial contents within source/storage bounds. About 61 lines.

## Proof obligations to watch

- **index**: With I in 0..20, positive Width=21 and ordinary modulo bounds, both wrapped neighbor indexes stay in 0..20. Guarded Pattern updates retain 0..7 for the rule table.
- **range**: Rule_Number retains 0..255 through nonnegative division by 2; Pattern assignment uses declared containment and bare-name refinement after each reached assignment.

## Language surface recorded by this assessment

Immutable Integer arithmetic, bounded mutable Integer objects, named Integer subtypes and bounded components, interval-checked Integer division, Integer range for loops, Integer image, scalar guard refinement, constant Integer-array iteration, fixed-size Integer arrays, fixed-size Boolean arrays and Put without a newline.

## External effects

- **console output** (allowed): Prints each generation as a row of #/. using Put and Put_Line, with Integer'Image rule headers.

Initially assessed on 2026-10-15 against page revision 414941 of the [task](https://rosettacode.org/wiki/Elementary_cellular_automaton) by claude-sonnet-5-5 at medium effort; current confidence high. The inclusion policy is in `rosetta/coverage.json`.

Revised on 2026-11-07 by Codex through targeted source review; see the [review record](../../assessment-boolean-arrays-20261106.md).
