# Distinct palindromes within decimal numbers

**Candidate: proofs likely to discharge automatically.** All loops are for loops over array ranges with small fixed bounds and the only arithmetic is on three-digit values, so every check follows from types and guards just before indexing, with no loop-carried value needing an invariant.

Position 980 in the [progression](../../progression.md#stage-16), in stage 16.

## Approach

Task 1 turns each integer 100..125 into a three-character String using digit extraction with / and mod, enumerates all substrings by nested for loops, tests each for palindrome with a for loop comparing mirrored indices, and skips a substring already seen earlier in the enumeration to keep results distinct. Task 2 keeps the 13 numbers as embedded String literals (so no big-number arithmetic is needed) and a procedure with an unconstrained String parameter scans for an adjacent equal pair or an equal pair two apart, since any palindrome of 2 or more digits contains one, and prints true or false. Output lines are built in a bounded buffer and printed with Put_Line. About 90 lines.

## Proof obligations to watch

- **index**: Palindrome checks index a String parameter with loop variables, discharged by iterating over S'Range and testing I + 2 <= S'Last just before reading S (I + 2).
- **length**: Output lines are assembled in a fixed 80-character buffer, so a guard on the remaining capacity precedes each append, and the sizes are small enough (at most six substrings of at most three digits) that the guard never fires for the required data.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, characters, Boolean objects, unconstrained arrays, string indexing, string building, for loops, procedures, functions, Put without a newline and 'Image of scalars.

## External effects

- **console output** (allowed): Prints a line per number in 100..125 listing its distinct palindromic substrings, plus a true/false line for each of the 13 listed numbers.

Assessed on 2026-10-15 against page revision 376224 of the [task](https://rosettacode.org/wiki/Distinct_palindromes_within_decimal_numbers) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
