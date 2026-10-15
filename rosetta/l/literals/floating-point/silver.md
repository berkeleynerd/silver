# Literals/Floating point

**Candidate: proofs likely to discharge automatically.** This should prove automatically (outlook likely). The program only declares static floating-point constants and prints them, so no run-time check can fail and none needs an annotation. All it adds to today's Silver is floating-point types and float-to-text formatting.

Position 1037 in the [progression](../../../progression.md#stage-18), in stage 18.

## Approach

Main declares Float constants written in each literal form Ada allows: plain decimal (0.13), digit groups with underscores (3.141_592_6), exponent notation (1.0E-12, 6.022_140_76E+23) and based literals (2#1.1#E+1, 16#F.8#). For each one it prints the source spelling as a String literal, followed by Float'Image of the constant. There are no loops, no input and no guards. About 22 lines.

## Proof obligations to watch

- **floating point**: All values are static constants written as literals well within Float's range, so the compiler checks their range statically, no arithmetic happens at run time and the only operation is formatting them as text.

## Language surface beyond today's Silver

Floating point and floating-point images.

## External effects

- **console output** (allowed): The program prints each literal form next to the value it denotes, using Silver_IO.Put_Line.

Assessed on 2026-10-15 against page revision 413381 of the [task](https://rosettacode.org/wiki/Literals/Floating_point) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
