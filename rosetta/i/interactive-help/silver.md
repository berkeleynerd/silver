# Interactive help

**Candidate: proofs likely to discharge automatically.** The task asks only for command-line help or a message on where to find more information, and today's Silver can already do that with string literals, argument comparison, if/elsif and Put_Line. Every check is a static string length or equality, so proof is routine.

Position 55 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

Main reads the first argument with Silver_Arguments.First_Or_Default and compares it, using String equality guarded by 'Length comparisons, against "--help" and "-h". On a match it prints a fixed usage summary of the program's options and a line saying where the Silver/SPARK documentation can be found; with no argument it prints a short hint to run with --help, and any other argument is rejected with Silver_Arguments.Reject. About 25 lines.

## External effects

- **console output** (allowed): The help text and the pointer to further documentation are printed with Silver_IO.Put_Line.
- **arguments** (allowed): The first command-line argument is read with Silver_Arguments.First_Or_Default to recognise a --help or -h request.

Assessed on 2026-10-15 against page revision 353733 of the [task](https://rosettacode.org/wiki/Interactive_help) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
