# Composite numbers k with no single digit factors whose factors are all substrings of k

**Candidate: proofs plausibly discharge automatically.** All arithmetic is bounded by declared ranges and for-loop bounds, and the only while loops are in a procedure, so no annotation is needed. The risk is limited to a few loop-carried counters and image-string indexing that need careful guards.

Position 559 in the [progression](../../progression.md#stage-11), in stage 11.

## Approach

Main iterates odd k from 11 over a bounded Integer range with an early exit once twenty hits are printed, trial-dividing by f from 11 up to 10,000 with an exit when f*f exceeds the remaining cofactor v. Each prime factor found is checked as a substring of k's decimal image by a Boolean function using nested for loops with explicit length guards, and the cofactor greater than one is checked likewise; hits are printed with Put_Line of the image. About 85 lines.

## Proof obligations to watch

- **overflow**: The factor counter is a small ranged subtype that saturates at 2 (only 'more than one factor' is tested, so results are unchanged), while k, v and f*f stay within 99,999,999 and 10,000-squared by type ranges.
- **index**: The substring function indexes the image strings only after a guard that offset plus pattern length does not exceed the text length, so the loop-carried index is bounded by the for-loop range.
- **termination**: The inner division while loop and the outer search live in procedures (the substring check is a function with only for loops), so no variant is needed.
- **range**: Divisions by f are safe because f starts at 11, and v only shrinks by exact division, so its subtype range holds without an invariant.

## Language surface recorded by this assessment

Integers, integer division, ranged subtypes, Boolean objects, string indexing, 'Image of scalars, for loops, while loops, procedures and functions.

## External effects

- **console output** (allowed): The twenty qualifying numbers are printed one per line with Put_Line.

Assessed on 2026-10-15 against page revision 413671 of the [task](https://rosettacode.org/wiki/Composite_numbers_k_with_no_single_digit_factors_whose_factors_are_all_substrings_of_k) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
