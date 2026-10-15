# Inner classes

**Candidate: proofs likely to discharge automatically.** The task is a small demonstration with records, a constructor function and one method on bounded integers, so every check follows from declared ranges and one explicit guard; no loops carry unbounded values and no annotations are needed.

Position 589 in the [progression](../../progression.md#stage-13), in stage 13.

## Approach

Ada has no classes nested inside classes, so the program substitutes the equivalent structure: an Inner record type with a bounded Integer field is declared inside the Main procedure's declarative part, beside an outer record that holds an Inner component. A constructor function returns an Inner aggregate, and a method procedure increments the field only after a guard against the range limit, with a visible outcome when the guard fails. Main instantiates the outer and inner objects, calls the method, and prints explanatory String literals and the field value via 'Image. About 45 lines.

## Language surface beyond today's Silver

Integers, ranged subtypes, records, functions, procedures, for loops, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints a short explanation and the demonstration results with Put_Line.

Assessed on 2026-10-15 against page revision 411242 of the [task](https://rosettacode.org/wiki/Inner_classes) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
