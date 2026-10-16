# Active Directory/Connect

**Excluded from Silver: network.** Fits the Oracle's rules (a candidate): the task only needs a connection and bind to an LDAP/AD server. That fits the Oracle's rules as long as an admitted network/LDAP library operation exists with specified failure outcomes. Silver has no such operation today, so this is a missing effect, not a fixed-rule conflict.

## Language surface recorded by this assessment

String operations, integers, records and packages.

## External effects

- **network** (not allowed): The task needs a connection to an Active Directory or LDAP server over the network, plus a bind, which needs an admitted LDAP or socket library operation.
- **console output** (allowed): The program prints whether the connection or bind worked, and prints the error if it failed.
- **exit status** (allowed): A failed connection or authentication should end with a non-zero exit status, so the failure is visible.

Assessed on 2026-10-15 against page revision 375420 of the [task](https://rosettacode.org/wiki/Active_Directory/Connect) by claude-opus-5-5 at high effort; confidence high. The inclusion policy is in `rosetta/coverage.json`.
