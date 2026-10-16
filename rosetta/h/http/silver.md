# HTTP

**Excluded from Silver: network.** The task only asks to fetch a URL over HTTP and print what comes back. A future Silver could do this through an admitted HTTP client library operation that specifies what happens on failure, so no fixed Oracle rule is broken. What is missing today is the network effect.

## Language surface recorded by this assessment

String operations and packages.

## External effects

- **network** (not allowed): The program has to fetch a resource over HTTP from a URL, so it needs an admitted network/HTTP client operation with specified failure outcomes.
- **console output** (allowed): The fetched resource content is printed to the console.

Assessed on 2026-10-15 against page revision 413994 of the [task](https://rosettacode.org/wiki/HTTP) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
