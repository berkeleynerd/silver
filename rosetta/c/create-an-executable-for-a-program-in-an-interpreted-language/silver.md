# Create an executable for a program in an interpreted language

**Excluded from Silver: processes.** The task asks for an executable that embeds an interpreted program's source and runs it. In a Silver-friendly solution that means writing a constant string to a temporary file, spawning the interpreter and removing the file. That needs the files and processes effects but breaks no fixed Oracle rule.

## Language surface recorded by this assessment

String operations.

## External effects

- **files** (allowed): Writes the embedded interpreted-language source to a temporary file and deletes it afterward.
- **processes** (not allowed): Launches the external interpreter on the generated source (or a compiler/build command), as the task describes.

Assessed on 2026-10-15 against page revision 407213 of the [task](https://rosettacode.org/wiki/Create_an_executable_for_a_program_in_an_interpreted_language) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
