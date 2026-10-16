# HTTPS/Authenticated

**Excluded from Silver: network.** The task asks only for an authenticated HTTPS request and display of the response. A Silver-friendly version would use fixed host, path and credential constants, one HTTPS GET through an admitted network library, and a bounded buffer read in a loop that prints the bytes. Nothing in the task requires a run-time error, annotations, exceptions or unsafe code, so the only gaps are the network effect and the console output. The existing FreeBASIC solution uses WinINet, but that is evidence only and does not change the analysis.

## Language surface recorded by this assessment

Arrays.

## External effects

- **network** (not allowed): The task requires making an HTTPS GET request to a remote host, which needs network access through an admitted library operation with specified failure outcomes.
- **console output** (allowed): The task requires printing the response body to standard output.

Assessed on 2026-10-15 against page revision 413996 of the [task](https://rosettacode.org/wiki/HTTPS/Authenticated) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
