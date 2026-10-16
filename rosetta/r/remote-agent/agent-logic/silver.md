# Remote agent/Agent logic

**Excluded from Silver: network.** The task asks for an agent that talks to a simulated world through a remote interface and tries to get balls into matching-colored squares, with the exact behavior unspecified. A deterministic bounded loop (pseudo-random or systematic moves with a turn limit) can do this, so no fixed Oracle rule is broken. The only real need is a network connection, which Silver lacks today.

## Language surface recorded by this assessment

Enumerations, records, arrays, loops, subprograms, integers and string operations.

## External effects

- **network** (not allowed): The agent must connect to the remote simulation server and exchange commands over the Remote agent interface.
- **console output** (allowed): Optional logging of agent progress or the final outcome as text.

Assessed on 2026-10-15 against page revision 381257 of the [task](https://rosettacode.org/wiki/Remote_agent/Agent_logic) by claude-sonnet-5-5 at medium effort; confidence medium. The inclusion policy is in `rosetta/coverage.json`.
