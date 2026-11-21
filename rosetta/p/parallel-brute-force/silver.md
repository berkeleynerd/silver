# Parallel brute force

**Candidate: proofs likely to discharge automatically.** Every check is either wrapping modular arithmetic, an array index taken from a static for-loop range, or a Character-to-word conversion bounded by its type. There are no while loops, no recursion and no loop-carried integer accumulators, so nothing needs an annotation. Leaving out the optional parallelism keeps the program faithful.

Position 1281 in the [progression](../../progression.md#stage-21), in stage 21.

## Approach

The program has its own single-block SHA-256: a mod 2**32 word type, a constant 64-word K array, and a compression procedure that pads the 5-byte message into 16 words (adding the 0x80 byte and a bit length of 40), expands the schedule with a for loop, and runs 64 rounds using rotate and shift operations on the modular type. Five nested for loops over Character range 'a' .. 'z' fill a 5-character String and its word block, hash it, and compare the 8-word digest with three embedded target digests. On a match, the program prints the target's embedded hex string and the password through Put_Line. It runs sequentially, because the task asks for concurrency only where the language supports it, and Silver can never admit tasking. About 130 lines.

## Proof obligations to watch

- **index**: Message-schedule reads such as W (I - 15) and W (I - 2) use a for-loop index over 16 .. 63 into an array indexed 0 .. 63, so every index follows from the static loop range.
- **range**: Converting Character'Pos of a letter (at most 255) to the 32-bit modular word type is in range by the type of Character'Pos alone.
- **overflow**: All SHA-256 additions, rotations and shifts happen on a mod 2**32 type, so they wrap by definition and need no overflow check.

## Language surface recorded by this assessment

Modular types, ranged subtypes, characters, arrays, for loops, functions, procedures and string building.

## External effects

- **console output** (allowed): Each matching password is printed on its own line with its SHA-256 hash in hex.

Assessed on 2026-10-15 against page revision 413832 of the [task](https://rosettacode.org/wiki/Parallel_brute_force) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
