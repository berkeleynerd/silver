# Rosetta Code/Tasks without examples

**Excluded from Silver: network.** The task is a scraper that fetches the category pages, follows each task link, and extracts the text between the infobox div and the toc div. A Silver-friendly version can do this with a bounded list of task URLs, a loop over them, substring search for the two markers, and a text file as output. The only conflicts are effects Silver lacks (network, files), which are not fixed-rule conflicts. The existing Phix solution's deliberate divide-by-zero crash on a missing marker is not a task requirement, so it is not reported as a runtime-error conflict.

## Language surface recorded by this assessment

Loops, arrays, string operations, characters and integers.

## External effects

- **network** (not allowed): The task requires fetching the Rosetta Code category page and each linked task page over HTTP.
- **files** (allowed): A Silver-friendly solution writes the extracted task descriptions to a text or HTML output file and may cache downloaded pages on disk.
- **console output** (allowed): Progress or a summary (such as the task count) can be printed as text.

Assessed on 2026-10-15 against page revision 377553 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Tasks_without_examples) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
