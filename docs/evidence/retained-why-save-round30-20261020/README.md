# Round 30 integration evidence

The [combined review](../../reviews/review-save-capacity-round30-20261020.md)
accepts author aggregate `8f17435e429ae145dc5aeae50926452100034dba` at its
conditional scope. Reviewer freeze `72431f1dd7` is integrated as `551ff3bc60`.
The [round record](../retained-tool-rounds.md#round-30--selected-cache-control-and-formatter-core)
records outcomes, costs and remaining work. Author records retain their
pre-review freeze status; the combined report supplies the later disposition.

`check.py` compares all 35 author files byte-for-byte with their exact author
Git objects, checks all 94 frozen native aggregate input pins, parses eight
author Python files and checks 17 local document links. It compares this result
with `result.json` when present. It does not replay any native proof, capture,
solver, observer, binder or previously successful broad analysis.

```sh
python3 docs/evidence/retained-why-save-round30-20261020/check.py
```

The four packet checks and five status boundary tests passed during the
independent review; their actual inputs, scope and elapsed evidence are in the
report. The formatter's first packaging check found a multiline-regex byte-count
discrepancy in its scratch generator; counting the same retained instruction
lines individually repaired the count to 4,864 before author freeze. ELF byte
comparison and the final focused check then passed. No native result was rerun
or changed. There was no source-fetch, target, disassembler, proof, Lean or
full-suite execution this round.

The source control result attaches the earlier first-resize bound conditionally.
Actual native/service/input joins, useful restored-path U and complete save and
whole-pipeline capacity remain open. No Oracle, tool/pin, admission or production
code change is claimed. PR #121 remains draft and unmerged.
