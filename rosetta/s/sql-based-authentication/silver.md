# SQL-based authentication

**Excluded from Silver: network, other.** The task needs a MySQL connection, so it needs a network and database effect that Silver lacks today, and it needs an MD5 hash over a 16-byte salt plus the password. Nothing in it breaks a fixed Oracle rule, because bounded strings, a deterministic salt generator and iterative MD5 can be written in SPARK once a database library operation is admitted.

## Language surface beyond today's Silver

Integers, characters, string operations, arrays, loops, subprograms and packages.

## External effects

- **network** (not allowed): The task requires connecting to a MySQL database server and running queries against it.
- **standard input** (allowed): Usernames and passwords for creating and authenticating users would be read from standard input.
- **console output** (allowed): Reports the outcome of connecting, creating a user and authenticating (success or rejection).
- **other** (not allowed): A database client interface (MySQL) is required, with specified failure outcomes. No admitted library operation provides this.

Assessed on 2026-10-15 against page revision 413898 of the [task](https://rosettacode.org/wiki/SQL-based_authentication) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
