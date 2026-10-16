# Yahoo! search interface

**Excluded from Silver: network.** The task needs a search object, which can be a package with a record or tagged type. It also needs a Next Page operation and parsing of the returned HTML into bounded URL, Title and Content strings. None of that breaks an Oracle rule; the only thing Silver lacks is an admitted network (HTTP) library operation, so the task is a future candidate.

## Language surface recorded by this assessment

String operations, records, arrays, loops, subprograms, packages, tagged types, characters and integers.

## External effects

- **network** (not allowed): The program has to send HTTP requests to Yahoo! search and fetch the result pages, including the next page of results.
- **console output** (allowed): It prints the URL, title and content read from each search result.

Assessed on 2026-10-15 against page revision 399556 of the [task](https://rosettacode.org/wiki/Yahoo!_search_interface) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
