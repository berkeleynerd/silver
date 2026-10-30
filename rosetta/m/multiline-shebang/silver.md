# Multiline shebang

**Candidate: proofs likely to discharge automatically.** The multiline header lives entirely in Ada comments, so the Silver source stays ordinary SPARK. The only executable logic is a for loop over the argument count with indexing that the loop range guards, which discharges routinely once the argument library exposes the command name and the argument count.

Position 1430 in the [progression](../../progression.md#stage-26), in stage 26.

## Failure paths to test

- **further arguments**: too few or too many arguments, and an empty or invalid argument.

## Approach

The file is a shell/Ada polyglot: its first lines are Ada comments that start with `---` followed by `2>/dev/null;` and then shell commands to strip the header, compile and exec the binary with "$@", so the shell runs them (through its fallback for files with no #! line) and the Ada compiler skips them. The Ada body is an ordinary Main procedure that prints the command name and then loops with a for loop from 1 to the argument count, printing each argument's index image and text. About 16 lines.

## Proof obligations to watch

- **length**: Joining a label, an Integer'Image and an argument of unknown length must stay within the bounded concatenation limit, so the program either prints the pieces with separate output calls or uses an admitted operation whose contract bounds argument lengths.

## Language surface recorded by this assessment

Further arguments, for loops, integers and 'Image of scalars.

## External effects

- **arguments** (allowed): The program prints its own command name and every command-line argument, showing that the shell header passed them through.
- **console output** (allowed): The command name and each argument are written to standard output, one per line.

Assessed on 2026-10-15 against page revision 412071 of the [task](https://rosettacode.org/wiki/Multiline_shebang) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
