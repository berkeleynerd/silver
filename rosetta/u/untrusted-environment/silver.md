# Untrusted environment

**Candidate: proofs likely to discharge automatically.** The demonstration only validates a bounded argument: it checks lengths against literals and indexes characters in a for loop over the string's own range, so every check comes from static bounds and guards. "Untrusted code" needs no program construct, because Silver has no way to evaluate code at run time and the prose explanation says so.

Position 504 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

Main reads the first argument with First_Or_Default, rejects it through Input_Is_Valid and Reject when malformed, and rejects it when its 'Length is outside a documented limit. A for loop over the argument's own index range sets a Boolean flag if any character falls outside an allowed set (letters, digits, space), tested with plain character comparisons. Only input that passes every check is echoed with Put_Line, and anything else gets a visible rejection message. The prose explanation covers what the Oracle guarantees: no eval or dynamic code, no exceptions, no unchecked conversions, external effects only through admitted operations, and every check proven. About 35 lines.

## Language surface beyond today's Silver

Characters, string indexing, for loops and Boolean objects.

## External effects

- **arguments** (allowed): The untrusted input being demonstrated is the first command-line argument.
- **console output** (allowed): The program reports whether the input was accepted, and echoes it only if accepted.
- **exit status** (allowed): Rejected input ends with the specified failure outcome through Silver_Arguments.Reject.

Assessed on 2026-10-15 against page revision 383719 of the [task](https://rosettacode.org/wiki/Untrusted_environment) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
