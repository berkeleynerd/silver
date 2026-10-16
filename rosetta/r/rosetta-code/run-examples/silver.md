# Rosetta Code/Run examples

**Excluded from Silver: network, processes, terminal control.** The task is a tool that downloads, displays and runs other people's Rosetta Code solutions, which is an external-effect program and not a computation. Its requirements (network download, running external processes, checking tool presence, graceful failure) are effects that Silver lacks, not conflicts with the Oracle rules. Only the Oracle-compatible core (string handling, looping, a command-line argument) would be expressible in Silver, so the task is a poor fit for Silver today and even in the envisioned language.

## Language surface recorded by this assessment

String operations, arrays, loops and subprograms.

## External effects

- **network** (not allowed): The task requires downloading the solution source for a named task and language from Rosetta Code over the network.
- **files** (allowed): The program saves the downloaded source to a temporary file before running it, and expected-output files are loaded by task name.
- **console output** (allowed): The program presents the source and the run output to the user as text.
- **arguments** (allowed): The task name and language are taken as input, and a command-line argument is the natural interface.
- **processes** (not allowed): The program checks that compilers or interpreters are present and runs the chosen solution as an external command.
- **terminal control** (not allowed): The FreeBASIC solution prompts for input interactively, though a command-line argument interface also satisfies the task.
- **exit status** (allowed): The task requires a graceful exit when a solution cannot be run, so the program must set a process exit status.

Assessed on 2026-10-15 against page revision 385084 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Run_examples) by claude-haiku-5-5 at low effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
