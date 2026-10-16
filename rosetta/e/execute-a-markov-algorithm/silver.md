# Execute a Markov algorithm

**Candidate: proofs plausibly discharge automatically.** Every access is an index or length computation on bounded buffers that explicit guards before each splice can discharge, and non-halting rulesets are handled by a visible step-limit and capacity rejection, so no annotation is needed. It is plausible rather than likely because the nested matching and splicing loops carry many loop-carried indices that each need a guard.

Position 863 in the [progression](../../progression.md#stage-14), in stage 14.

## Approach

Rules are held in a fixed array of records (pattern and replacement as fixed-capacity character buffers with lengths, plus a terminating flag), parsed from embedded text lines by finding the first ' -> ' and skipping comment and blank lines. The working text is a bounded buffer; a while loop in a procedure scans rules in order, finds the leftmost match with a bounded for-loop search, splices the replacement after capacity guards, restarts from the first rule, and stops on a terminating rule, no match, or the step limit. The five rulesets and their sample inputs are embedded and the results printed with Put_Line. About 230 lines.

## Proof obligations to watch

- **index**: Pattern matching, splicing the replacement into the fixed-capacity buffer and parsing each rule line all do loop-carried index arithmetic, so each access is guarded by explicit length and capacity comparisons immediately before use.
- **overflow**: The buffer length after a replacement (current length minus pattern length plus replacement length) is checked against the capacity before it is computed, and the step counter is a bounded range type guarded against its limit.
- **termination**: A Markov algorithm can run forever (Ruleset 3's W -> WW grows without bound), so the interpreter is a procedure with a documented step limit and buffer capacity, and exceeding either gives a visible Rejected outcome rather than silent truncation.
- **length**: Rule text and replacement are stored in fixed-capacity buffers with explicit lengths, and any rule line longer than the capacity or lacking the ' -> ' separator is rejected with a specified message.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, characters, arrays, records, string indexing, string building, for loops, while loops, procedures, functions and case statements.

## External effects

- **console output** (allowed): Prints the transformed text for each of the five embedded ruleset/sample pairs with Put_Line.

Assessed on 2026-10-15 against page revision 415192 of the [task](https://rosettacode.org/wiki/Execute_a_Markov_algorithm) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
