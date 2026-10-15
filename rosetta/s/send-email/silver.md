# Send email

**Excluded from Silver: network.** The task needs only network access to an SMTP server plus bounded string handling for the addresses, subject and body, with the server name and login as parameters. Nothing in the task requires exceptions, assertions, unchecked code or recursion, and the Ada solution's use of AWS and pragma-free exception-based reporting is not a fixed-rule conflict. Status is reported by returning a result the caller can inspect, so no conflict arises from the reporting method. The network effect is a missing capability, not a conflict under the Oracle.

## Language surface beyond today's Silver

String operations.

## External effects

- **network** (not allowed): Sending email requires an SMTP conversation with a mail server over TCP, which is an external effect that Silver does not yet have.

Assessed on 2026-10-15 against page revision 413903 of the [task](https://rosettacode.org/wiki/Send_email) by claude-haiku-5-5 at low effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
