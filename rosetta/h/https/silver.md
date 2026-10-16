# HTTPS

**Excluded from Silver: network.** The task asks for an HTTPS GET of a fixed URL and printing the response body. That needs network access plus console output. No fixed Oracle rule is broken: a future admitted HTTPS client library whose failure outcomes are specified, writing into a bounded buffer, would be enough. So this task is a candidate, waiting on a network effect.

## Language surface recorded by this assessment

String operations, arrays, loops and packages.

## External effects

- **network** (not allowed): The program has to send an HTTPS GET request over TLS to https://www.w3.org/ (certificate checking is recommended) and receive the response.
- **console output** (allowed): The program has to print the fetched resource to the console.

Assessed on 2026-10-15 against page revision 413995 of the [task](https://rosettacode.org/wiki/HTTPS) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
