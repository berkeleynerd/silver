# SOAP

**Excluded from Silver: network.** The task is a SOAP client that POSTs two fixed XML envelopes to a fixed endpoint and prints the responses. The only missing capability is a network effect, which is an effect, not a conflict. The envelopes are fixed strings, and the response can be read into a bounded buffer under an explicit size limit, so no feature beyond today's string and text handling is required. The response should be checked for an invalid or failed outcome under a specified visible result. Nothing in the task requires an exception, annotation, or unsafe construct.

## External effects

- **network** (not allowed): The task requires sending SOAP (HTTP POST with XML envelopes) requests to http://example.com/soap and receiving responses. Silver has no network access today.
- **console output** (allowed): The results of calling soapFunc() and anotherSoapFunc() are shown as printed text, so the program prints the responses (or labels) to standard output.

Assessed on 2026-10-15 against page revision 413897 of the [task](https://rosettacode.org/wiki/SOAP) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
