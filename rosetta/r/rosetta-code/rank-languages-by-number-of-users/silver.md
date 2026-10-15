# Rosetta Code/Rank languages by number of users

**Excluded from Silver: network.** The task needs network fetching of Rosetta Code category data, string parsing of JSON-like responses, a sort, and console text output. All of this fits Oracle rules once network access is an admitted library effect: bounded arrays for the category and language lists, iteration for paging and sorting, and an explicit outcome for failed or malformed downloads. The task has no required exceptions, assertions, or run-time error demonstrations, so there are no conflicts. The sample date header is not required by the task text and is left out, so no clock effect is listed.

## Language surface beyond today's Silver

String operations, arrays, records, loops and integers.

## External effects

- **network** (not allowed): Downloads category member listings from the Rosetta Code MediaWiki API (rosettacode.org) to count users per language. Silver has no network access, so this is an effect it lacks, not a conflict.
- **console output** (allowed): Prints the ranked table of languages with at least 100 users as text.

Assessed on 2026-10-15 against page revision 413891 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Rank_languages_by_number_of_users) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
