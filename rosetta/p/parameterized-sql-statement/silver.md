# Parameterized SQL statement

**Excluded from Silver: other.** The task binds four values (a text name, an integer score, a boolean flag and an integer jersey number) to a parameterized UPDATE and executes it. Nothing in it breaks an Oracle rule. It needs an admitted database library operation, which is a new external effect, and the program itself is plain bounded strings and integers.

## Language surface recorded by this assessment

String operations and integers.

## External effects

- **other** (not allowed): The task requires preparing and executing a parameterized SQL UPDATE against a database through a SQL driver or library. Silver would need an admitted database operation that specifies how it binds parameters and what happens when it fails.

Assessed on 2026-10-15 against page revision 410703 of the [task](https://rosettacode.org/wiki/Parameterized_SQL_statement) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
