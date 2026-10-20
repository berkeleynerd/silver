# Quiet-command prefix transfer evidence

2026-10-20 UTC, Linux x86_64, Round 49; #119 / #153.
See the [source argument](../../research/retained-quiet-prefix-transfer.md).

The exact ordinary CVC5 command changes from 44 to 167 bytes in the retained
base config. The source upper bound is 2,165 additional managed words through
registration, or 2,180 through Input_Is_Valid's first-inline cut; the selected
uniform allowance is 4,096 words. It covers both OCaml lexer generator modes,
position records, buffer growth, contents and complete-command copies.
Remembered-reference allowance is separately 4,096 entries. The conditional
first-event argument preserves the semantic graph and initial registrations
without assuming identical heaps or cache behavior after a collection.

Run the target-free check from the checkout:

```sh
python3 -B docs/evidence/retained-quiet-prefix-transfer-20261020/check.py
```

The checker verifies 19 pinned predecessor files and 45 archive members, checks
49 source excerpts against those complete files, reconstructs concrete lexer
action/size differences, scans command consumers, attaches each of the five
later capture snapshots to its invocation/config, and checks the GC/resource
and identifier inequalities. It separately checks the older five fixed-tail
captures' margins before extending that family's W/B inequalities. It neither
executes a target nor replays a predecessor checker. The reviewed source
simulation and ordinary source/runtime premises remain necessary.

- `inputs.json`: predecessor file/archive/member identities.
- `source-witnesses.json`: exact source excerpts and archive locations.
- `lexer-account.json`: concrete token/action and allocation arithmetic.
- `command-consumers.json`: source occurrence inventory, including other
  executable entry points that the note excludes by caller selection.
- `capture-resources.json`: the five later invocations and start/cut snapshots.
- `result.json`: bounds, preserved initial counts and separate older-family
  margin inputs.
- `round.json`: selected model/effort, measured phase and scope of work.
- `check-result.json`: final offline verification result.

Sources are retained Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml
4.14.2 `8eb41f72ded84df884c3671734c947f612091f84`, reused from accepted archives.
No source download, native/debugger/solver/capture/proof run, production change,
GitHub write or goal-state update occurred. The frozen Round 48 route packet is
unchanged. #119 remains incomplete and production #88–#94 remains unstarted.
