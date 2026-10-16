# Active Directory/Search for a user

**Excluded from Silver: network.** The task is to connect to Active Directory over LDAP and search it for a user. That needs a network/LDAP library operation Silver does not have yet, but it breaks no fixed Oracle rule, so a future Silver with an admitted, specified directory-access operation could cover it.

## Language surface recorded by this assessment

String operations and records.

## External effects

- **network** (not allowed): The task requires connecting to an Active Directory (LDAP) server and running a search query against it.
- **console output** (allowed): The search result (the matching user entry or its attributes) has to be printed.

Assessed on 2026-10-15 against page revision 375444 of the [task](https://rosettacode.org/wiki/Active_Directory/Search_for_a_user) by claude-opus-5-5 at high effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
