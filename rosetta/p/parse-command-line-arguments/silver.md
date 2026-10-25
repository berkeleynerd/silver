# Parse command-line arguments

**Candidate: proofs likely to discharge automatically.** Every check comes from the for-loop range, a 'Length guard just before each character read, and the library's bound on argument length. No loop-carried arithmetic or termination obligation remains, so proof should discharge without annotations.

Position 1436 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

Main loops over 1 .. Argument_Count with a for loop and keeps a Boolean that says whether the previous argument was a value-taking option (-w). Each argument is guarded by a 'Length test and then classified by its first character: "-x" is a flag, "-w" sets up a pending value, and anything else is a positional operand or the pending option's value. Each result is printed with its index image. A trailing -w with no value goes to Reject, which gives that input a specified outcome. About 45 lines.

## Proof obligations to watch

- **index**: Reading the first and second characters of an argument to spot a leading '-' discharges because each read is guarded by a 'Length test just before it.
- **length**: Concatenating labels with argument text discharges only if the admitted argument operation's contract bounds argument length so the bounded concatenation cannot exceed its capacity.
- **range**: Argument indexes come from a for loop over 1 .. Argument_Count, so the library's index precondition follows from the loop range.

## Language surface recorded by this assessment

Further arguments, for loops, integers, Boolean objects, characters, string indexing, unconstrained arrays and 'Image of scalars.

## External effects

- **arguments** (allowed): The program reads every command-line argument (for example nc -v -n -z -w 1 192.168.1.2 1-1000) and classifies each one.
- **console output** (allowed): Each parsed flag, option with its value and positional operand is printed on its own line.

Assessed on 2026-10-15 against page revision 411102 of the [task](https://rosettacode.org/wiki/Parse_command-line_arguments) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
