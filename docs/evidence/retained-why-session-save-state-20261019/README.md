# PID 97103 retained session and binder evidence

Research #119, Linux x86_64, 2026-10-19. See the
[source argument](../../research/retained-why-session-save-state.md).

The new capture has **B_binders = 966** under the accepted source/runtime/cache
premises. Its own input/Hsdecl/private-counter join re-establishes the accounted
inline bound of **1,145** from **60,496**. Helper roots are captured, but **R and
the composed endpoint are not established**. This packet does not splice the
new state into historical PID 74171.

- `capture.tar.gz` / `capture-identities.json`: exact new harness, input, process,
  raw reads, projections, native result and managed events. The parent ran the
  one permitted attempt; this packet's analysis did not start a native process.
- `replay-check.json`: successful exact sequential session replay of 49,728 reads,
  reproducing all 11 projection files byte for byte before archival.
- `binder-certificate.json`: every task-chain declaration/proposition, distinct
  formula's opened count and each forest occurrence's explanation/shape charge.
- `binders.py` / `test_binders.py`: count interpreter and eight semantic
  regressions, including substitutions and occurrence multiplicity.
- `check.py` / `inputs.json` / `result.json`: pinned offline joins, current
  representative projection, private counter/auxiliary replay and formula-count
  cross-check with the existing explicit-alpha opener.
- `sources.tar.gz` / `source-identities.json`: 16 relevant Why3 files from pinned
  revision `9390baf120ef260547dfa14f08e11c890b203d9c` and the retained OCaml
  `stdlib.ml` from `8eb41f72ded84df884c3671734c947f612091f84`.
- `native-helpers.json`: nine bodies extracted from existing disassembly,
  byte-matched to the pinned ELF (1,008 bytes); no new disassembler execution.
- `round.json`: selected model/effort, timing, work scope and outstanding work.

Run the retained offline checks from the repository root:

```sh
python3 -B -m unittest discover -s docs/evidence/retained-why-session-save-state-20261019 -p test_binders.py -v
python3 -B docs/evidence/retained-why-session-save-state-20261019/check.py
```

The checker uses the installed executable as read-only ELF data and existing
pinned evidence. It uses repository `tmp/` for any expansion, executes no target,
debugger, compiler, build, proof or solver, and does not rerun the native capture.
`check.py --write` regenerates the two derived JSON files after intentional
checker changes; it does not regenerate native evidence. Independent replay of
the session observer can use the archived original directory layout and the
frozen prior packet's `replay.py`; no replay invokes the inferior.

The pre-helper session summary is 17,955 blocks / 511,712 header-inclusive bytes.
The final session-plus-helper stream is **17,985 blocks / 513,248 bytes**. Empty
registered statistics and resolved standard exit hooks do not imply complete R.
