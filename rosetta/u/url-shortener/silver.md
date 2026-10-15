# URL shortener

**Excluded from Silver: network.** The task is an HTTP service with a POST endpoint that shortens a URL and a GET endpoint that redirects, so it needs network access, which Silver lacks today. The rest is in-memory bounded string and array handling with a deterministic key generator, which fits Silver once admitted library operations for bounded strings, tables and networking exist. No Oracle rule is broken.

## Language surface beyond today's Silver

String operations, arrays, records, loops, subprograms, characters and integers.

## External effects

- **network** (not allowed): The task requires an HTTP API: a POST / endpoint that accepts JSON and returns a short URL, and a GET /:short endpoint that redirects to the original URL.
- **console output** (allowed): A server-less form of the task would print the short URL and the redirect target as text.

Assessed on 2026-10-15 against page revision 392408 of the [task](https://rosettacode.org/wiki/URL_shortener) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
