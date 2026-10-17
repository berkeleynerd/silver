# Operator precedence

**Candidate: proofs likely to discharge automatically.** The program is a fixed sequence of Put_Line calls with String literals, which Silver already supports, so no check can fail and nothing needs an annotation.

Position 30 in the [progression](../../progression.md#stage-1), in stage 1.

## Approach

A parameterless Main procedure with SPARK_Mode On prints one Put_Line per precedence row in descending order (highest-precedence operators such as ** abs not first, then multiplying, unary adding, binary adding, relational, and logical operators), each with its associativity. It finishes with lines stating that parameters of elementary types are passed by copy and that composite or tagged parameters are by reference or by copy as the compiler chooses. There are no variables, loops or inputs, so there is nothing to guard. About 25 lines.

## External effects

- **console output** (allowed): The program prints the precedence and associativity table and the parameter-passing statement with Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 414371 of the [task](https://rosettacode.org/wiki/Operator_precedence) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
