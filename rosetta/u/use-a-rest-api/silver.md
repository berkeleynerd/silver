# Use a REST API

**Excluded from Silver: network.** The task needs generic get and post functions over HTTP, with the API key read from a file. That requires a network effect that Silver lacks today, plus files and console output, and nothing in it breaks a fixed Oracle rule. A bounded-string solution can handle the details and URL, validate the response, and report failures through specified outcomes.

## Language surface beyond today's Silver

String operations, records, arrays, loops, subprograms and enumerations.

## External effects

- **network** (not allowed): The task requires HTTP GET and POST requests to the Meetup.com REST API.
- **files** (allowed): The API key is read from api_key.txt.
- **console output** (allowed): Responses and failure outcomes are printed as text.

Assessed on 2026-10-15 against page revision 383539 of the [task](https://rosettacode.org/wiki/Use_a_REST_API) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
