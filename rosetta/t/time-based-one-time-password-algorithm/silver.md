# Time-based one-time password algorithm

**Excluded from Silver: clock.** TOTP is HMAC-SHA1 over an 8-byte big-endian counter taken from the clock, followed by dynamic truncation and a modulo 10^6. A bounded-array implementation with 32-bit modular arithmetic, Base-32 decoding that rejects invalid input, and loops can be proven free of run-time errors. The only external effects are the clock, the argument and console output, and the optional random key generation can be skipped.

## Language surface recorded by this assessment

Integers, characters, string operations, arrays, loops and subprograms.

## External effects

- **clock** (not allowed): TOTP derives its counter from the current Unix time divided by the 30-second interval.
- **console output** (allowed): The computed 6-digit token is printed.
- **arguments** (allowed): The Base-32 secret key can be supplied as a command-line argument, which must be validated.

Assessed on 2026-10-15 against page revision 409119 of the [task](https://rosettacode.org/wiki/Time-based_one-time_password_algorithm) by claude-sonnet-5-5 at medium effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
