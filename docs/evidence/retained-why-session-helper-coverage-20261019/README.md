# Remaining formatter input coverage

Research #119, Linux x86_64, 2026-10-19. This follows the independently frozen
[PID 97103 binder packet](../retained-why-session-save-state-20261019/README.md),
commit `98fdd88dbf4962c9140493dcf783beb66bf85144`; it changes none of that packet.

All **835,579** retained core raw-read records were scanned. No read overlaps
the first eight-byte word at any of the 16 pointer values in the captured
28-word Debug formatter, or either standard formatter global word read by the
actual exit hook: `camlStdlib__Format+0x360` and `+0x368`. `result.json` gives
all 18 exact runtime addresses and labels. This is a precise missing-input
result, not a claim that every other helper-related byte is absent.

The already byte-matched `pp_print_flush_938` calls `pp_flush_queue_779`, then
indirectly invokes formatter field 17. The standard-formatters hook fetches
its two formatters from those module globals and calls `pp_print_flush` on
each. Debug's newline wrapper captures the old output-function record. The
available shallow record therefore does not provide every reachable queue,
wrapper or global value. Static ELF initializers are not substituted for the
unobserved runtime words.

The source prefix narrows Debug to GNAT's buffer formatter (the captured exact
environment lacks `GNATWHY3LOG`). A source initialization/preservation proof
could still close these paths without a new capture. At this coverage checkpoint,
the existing retained source packets did not supply the pinned
`Format`/`CamlinternalFormat` implementation. Parent subsequently authorized
matching official-source retrieval for that separate route. `R` and full helper
preservation remain open; no numeric zero charge is asserted. This packet
neither requests nor performs another native run.

```sh
python3 -B docs/evidence/retained-why-session-helper-coverage-20261019/check.py
```

The checker reads the original archive and verifies its fixed identity and the
identities of every consumed member. The module address/offsets are from the
prior packet's retained native body. The selected model/effort remained GPT-6
Astra / Extra High; runtime confirmation, token and cost measurements were
unavailable. The inherited round began at 00:04:42 UTC. The helper scan is an
additional specific missing-input check, not a duplicate capture or binder run.
The retained checker generation passed in **2.7228424370005087 seconds**.
