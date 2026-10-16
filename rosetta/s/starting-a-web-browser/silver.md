# Starting a web browser

**Excluded from Silver: processes.** The task needs a program that processes addresses (separates house number from street, using bounded strings and arrays), writes a colored HTML table to a file, and launches a browser on it. This is only a file-writing and process-launching effect, which a future Silver library operation could specify, so there is no fixed-rule conflict.

## Language surface recorded by this assessment

String operations, arrays, records, loops, subprograms, characters and integers.

## External effects

- **files** (allowed): Writes an HTML file containing the processed address table so the browser can open it.
- **processes** (not allowed): Launches the system web browser on the generated HTML file (start or xdg-open).

Assessed on 2026-10-15 against page revision 376755 of the [task](https://rosettacode.org/wiki/Starting_a_web_browser) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
