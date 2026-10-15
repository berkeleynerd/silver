# Web scraping

**Excluded from Silver: network.** The Silver-friendly solution is an admitted network-fetch library operation that returns a bounded body, followed by a loop over bounded lines and a fixed-pattern search for "UTC" to print the time fragment. The existing AWS solution uses a status-code check and string search, which fits the Oracle's rules once the fetch has a specified failure outcome. Nothing in the task requires an exception, assertion or unsafe construct, so there are no fixed-rule conflicts; only the network effect is missing from Silver today.

## Language surface beyond today's Silver

Characters, string operations, loops and arrays.

## External effects

- **network** (not allowed): Downloads the timer page over HTTP from tycho.usno.navy.mil (or, as the fallback, the talk page). Silver has no network access, so this is an effect it lacks, not a conflict.
- **console output** (allowed): Prints the extracted UTC time line to standard output.

Assessed on 2026-10-15 against page revision 413963 of the [task](https://rosettacode.org/wiki/Web_scraping) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
