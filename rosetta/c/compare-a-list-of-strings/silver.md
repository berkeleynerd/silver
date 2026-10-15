# Compare a list of strings

**Candidate: proofs likely to discharge automatically.** Every check follows from bounded length subtypes and for-loop index ranges over the array's own bounds, and the functions need only terminating for loops, so no annotation is required. The required surface (records, arrays, slices, string ordering) is plain Ada with no loop-carried values.

Position 1480 in the [progression](../../progression.md#stage-29), in stage 29.

## Approach

The embedded list is a fixed-capacity array of records, each holding a bounded Length (subtype 0..16) and a 16-character buffer, plus a Count of used entries; two functions loop with for loops over adjacent index pairs and return False at the first violating pair. String comparison uses the slice Data(1..Length) of each entry (equality and less-than), and the empty or single-element case falls out of empty for-loop ranges returning True. Main fills several example lists (equal, ascending, neither, empty, single) and prints each result with Put_Line. About 55 lines.

## Proof obligations to watch

- **index**: Slices Data(1..Len) and the Idx and Idx+1 accesses are safe because Len is a subtype bounded by the buffer size and the for-loop ranges are 1..Count-1 or 2..Count over the array's own bounds.

## Language surface beyond today's Silver

Ranged subtypes, Boolean objects, arrays, records, string indexing, string ordering, for loops, functions, 'Image of scalars, integers and conditional expressions.

## External effects

- **console output** (allowed): Print the two Boolean results with Put_Line.

Assessed on 2026-10-15 against page revision 413669 of the [task](https://rosettacode.org/wiki/Compare_a_list_of_strings) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
