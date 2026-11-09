# Hamiltonian Cycle via Chvátal Closure

**Candidate: proofs plausibly discharge automatically.** All indexes come from for loops over the static Vertex range and the closure's while loop sits in a procedure, so the only non-routine check is the degree accumulator's increment, which depends on loop unrolling or careful typing rather than an annotation.

Position 694 in the [progression](../../progression.md#stage-12), in stage 12.

## Approach

The example graph is a constant two-dimensional Boolean adjacency matrix over a Vertex subtype 0..4, copied into a working matrix H; a Degree function counts neighbours with a for loop. Main runs a while loop with an Added flag whose body scans all pairs U<V with nested for loops and adds the first non-edge whose degree sum reaches N, then a nested for-loop completeness check selects the verdict line, with degrees and adjacency lists printed using Put and 'Image. About 75 lines.

## Proof obligations to watch

- **overflow**: The degree counter is incremented in a for loop without an invariant, so it discharges only through GNATprove's automatic unrolling of the small static 0..N-1 loop or by declaring the counter Natural over a loop of statically known length that the provers can bound.
- **range**: Returning the count as a Degree subtype 0..N-1 and comparing Degree(U)+Degree(V) >= N stays within Integer because the function's return subtype bounds each operand.
- **termination**: The repeat-until-no-edge-added closure loop is a while loop placed in the Main procedure, so it needs no variant, and the degree and completeness functions use only for loops.

## Language surface recorded by this assessment

Integers, ranged subtypes, Boolean objects, arrays, multidimensional arrays, for loops, while loops, functions, 'Image of scalars and Put without a newline.

## External effects

- **console output** (allowed): The program prints the original degrees, the closure's adjacency lists and the Bondy-Chvatal verdict.

Assessed on 2026-10-15 against page revision 414243 of the [task](https://rosettacode.org/wiki/Hamiltonian_Cycle_via_Chv%C3%A1tal_Closure) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
