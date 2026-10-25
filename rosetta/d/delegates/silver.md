# Delegates

**Candidate: proofs likely to discharge automatically.** The program has no arithmetic, indexing or loops, and each function returns a String literal chosen by an if statement on Boolean record components, so the only checks are initialization checks, which aggregates satisfy.

Position 577 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

A Delegate record carries a Boolean component saying whether it implements Thing, and a Delegator record holds a Boolean Has_Delegate flag plus a Delegate component. The function Thing returns "delegate implementation", and the function Operation returns Thing when a delegate is present and implements Thing, or "default implementation" otherwise. Main builds three delegator values (no delegate, a delegate without Thing, a delegate with Thing) and prints Operation for each one. About 40 lines.

## Language surface recorded by this assessment

Records, Boolean objects and functions.

## External effects

- **console output** (allowed): The program prints the result of Operation for each of the three delegator configurations with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413171 of the [task](https://rosettacode.org/wiki/Delegates) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
