# HTTPS/Client-authenticated

**Excluded from Silver: network.** The task needs an HTTPS connection with a client certificate, and Silver does not have network access yet. That makes it an effect, not a fixed-rule conflict. A future admitted TLS client operation that takes the certificate and key files and has specified failure outcomes would let a Silver program connect, check the result and print the response, with no exceptions, annotations or unsafe code.

## Language surface beyond today's Silver

String operations and records.

## External effects

- **network** (not allowed): The program must open an HTTPS (TLS) connection to a web server and present a client certificate during the handshake, which needs an admitted TLS/HTTP client library operation with specified failure outcomes.
- **files** (allowed): The client certificate and private key the program presents are normally loaded from named PEM/PKCS#12 files.
- **console output** (allowed): The program shows that the connection worked by printing the server's response or a status message.

Assessed on 2026-10-15 against page revision 413997 of the [task](https://rosettacode.org/wiki/HTTPS/Client-authenticated) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
