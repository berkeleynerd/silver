# FTP

**Excluded from Silver: network.** The task needs network access to an FTP server and a binary file write, both external effects that admitted library operations could provide. Nothing in the task requires exceptions, annotations or unsafe code, so no fixed Oracle rule is broken.

## Language surface recorded by this assessment

String operations, arrays, records, loops, subprograms and packages.

## External effects

- **network** (not allowed): The program has to connect to an FTP server and talk the FTP protocol: control connection, CWD, LIST, a passive-mode data connection and a binary RETR.
- **files** (allowed): The downloaded file has to be written in binary to a local file.
- **console output** (allowed): The directory listing and the server responses are printed.

Assessed on 2026-10-15 against page revision 413986 of the [task](https://rosettacode.org/wiki/FTP) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
