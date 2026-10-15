# Self-hosting compiler

**Unlikely to prove automatically: index, length, overflow, termination, other.** Each run-time check could in principle be guarded by a capacity test or a ranged index subtype, but the program would be about 20,000 lines of loop-carried pool cursors. It would also have to embed a verifier to decide Silver admission, so automatic discharge of the whole compiler without annotations is unlikely.

## Approach

The compiler is a set of packages: a lexer that fills a fixed-capacity token array; a parser that uses an explicit stack (no recursion) to build an array-pool syntax tree linked by ranged indices; a semantic checker with an array-based symbol table that enforces Silver's restrictions; and a code generator that writes assembly or C text to the output file. Every pool allocation, buffer append and literal conversion is guarded, and a guard that fails rejects the source with a diagnostic and a non-zero exit status. The checker must also include Silver's proof-based admission rule. About 20000 lines.

## Proof obligations to watch

- **index**: Token, syntax-tree and symbol-table pools are fixed-capacity arrays whose cursors are loop-carried, so every allocation needs a capacity guard that rejects the source program, and every stored link needs a ranged index subtype, across tens of thousands of lines.
- **length**: Identifiers, string literals and generated code lines are built in bounded buffers, so each append needs a guard that rejects input that would exceed the documented limit.
- **overflow**: Folding static integer expressions and parsing numeric literals needs range guards before each operation, with out-of-range constants reported as compile errors.
- **termination**: Lexing, explicit-stack parsing and tree walks use while loops, so they must sit in procedures, because functions cannot carry the variants that would justify them.
- **other**: A faithful Silver compiler must decide whether a program discharges its Silver-level proofs, so it would have to embed a verification-condition generator and a decision procedure, and no unannotated proof of that would plausibly discharge automatically.

## Language surface beyond today's Silver

Integers, integer division, ranged subtypes, Boolean objects, characters, enumerations, arrays, unconstrained arrays, records, string indexing, string building, 'Image of scalars, text parsing, case statements, for loops, while loops, procedures, functions, packages, further arguments, exit status, standard error, file input and file output.

## External effects

- **arguments** (allowed): The compiler takes the source file name and the output file name from the command line.
- **files** (allowed): It reads Silver source files, including its own source and the Silver_IO and Silver_Arguments specs, and writes the generated target code to a file.
- **console output** (allowed): It reports diagnostics and a compilation summary.
- **exit status** (allowed): A failed compilation must be signalled to the build environment with a non-zero status.

Assessed on 2026-10-15 against page revision 385383 of the [task](https://rosettacode.org/wiki/Self-hosting_compiler) by claude-opus-5-5 at high effort, escalated from claude-sonnet-5-5; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
