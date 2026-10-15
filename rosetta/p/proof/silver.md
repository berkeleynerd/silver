# Proof

**Excluded from Silver: annotations, other.** The task asks for Peano naturals and addition to be defined in the language, and for theorems about every natural number to be proved constructively by the type checker or proof assistant, including attempted false proofs that must be rejected. Silver forbids author-written contracts and lemmas, and it only admits programs that prove, so no future Silver can express these proofs. The sample is excluded.

## Language surface beyond today's Silver

Integers, subprograms and recursion.

## Oracle conflicts

- **annotations**: The task requires the program itself to state and prove universally quantified theorems about all natural numbers (even+even is even, associativity, commutativity, even+even is not odd). It explicitly rules out checking by enumeration. In SPARK this can only be written as ghost lemmas with postconditions, quantified contracts and loop invariants or induction, and rule 3 forbids authors from writing any of those.
- **other**: The task requires showing that false propositions ('even+even is odd', 'even+even cannot be even') are rejected by the proof checker. That means submitting source whose proof fails, but rule 2 only admits programs that prove automatically, so the required rejected proofs cannot be Silver programs.

Assessed on 2026-10-15 against page revision 386741 of the [task](https://rosettacode.org/wiki/Proof) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence high. The inclusion policy is in `rosetta/coverage.json`.
