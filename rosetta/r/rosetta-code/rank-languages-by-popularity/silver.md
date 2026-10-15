# Rosetta Code/Rank languages by popularity

**Excluded from Silver: network.** The task needs only a network fetch of one category listing, string scanning of its HTML, a bounded array of (count, language) records sorted by count and name, and printed output, all of which Silver can express with bounded sizes and explicit guards for malformed or missing input. The existing Ada solution's AWS library, exceptions and Ordered_Sets are not required by the task, so no fixed-rule conflict is raised.

## Language surface beyond today's Silver

Integers, characters, string operations, arrays, records, loops and subprograms.

## External effects

- **network** (not allowed): The Silver-friendly solution fetches the Rosetta Code Special:Categories page (limit=5000) over HTTP to obtain per-category member counts; the task requires live data from the site.
- **console output** (allowed): Prints the ranked list of languages with their entry counts, as the sample output shows.

Assessed on 2026-10-15 against page revision 413892 of the [task](https://rosettacode.org/wiki/Rosetta_Code/Rank_languages_by_popularity) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
