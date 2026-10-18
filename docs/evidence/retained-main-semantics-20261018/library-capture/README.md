# Separate fixed library frontend captures

Linux x86_64, 2026-10-18, Refs #119. These four isolated producer executions
supply the frontend Node_Id domains missing from the earlier
[fixed library Why captures](../../retained-producer-bodies-20261018/README.md).
They reuse the exact current-source phase-one ALIs, selected library sources
and configuration recorded there. No global-generation rerun, solver, assurance
audit, Lean run or test suite was performed.

| Process | `A_total` | Conservative `E_total` | Debugger/producer seconds |
| --- | ---: | ---: | ---: |
| Silver_IO body | 19,837 | 19,837 | 11.18 |
| Silver_Arguments body | 19,921 | 19,921 | 11.24 |
| Silver_Output_Libc specification | 18,575 | 18,575 | 10.43 |
| Silver_Runtime specification | 1,510 | 1,510 | 5.78 |

Each `A_total` includes sentinels 0 and 1 and every allocated ordinary/entity
node through `before_symbol_free`. All four Node_Offsets positions have zero
lifetime decreases. Every entity is an allocated Node_Id, giving the stated
conservative `E_total`. These domains are per process: do not add them to Main
or sum them into a simultaneous vector. They are distinct from the earlier
Why node counts and from Main's fixed allowance of 12,784.

The fixed-process source reduction is the one in
[retained-producer-fixed.md](../../../research/retained-producer-fixed.md#separate-fixed-library-processes):
the source and imported prerequisites are fixed and cannot name arbitrary Main.
No range-cache manipulation or cache-pattern extrapolation is needed for these
complete fixed processes. The reader reuses the audited 121-position static
store inventory and 1,265 decrease-capable/unknown hooks from the
[Main light capture](../fixed-capture/README.md), including its ELF coverage
supplement. It writes no inferior memory and makes no inferior function call.
The identity `positive = final - initial + total decreases` includes discarded
work. No successful prior frontend count was repeated.

The runs allow the explicitly disabled `/usr/bin/false` backend to launch
asynchronously (respectively 2, 3, 0 and 0 times); all stop before collecting any
result. Zero solver or proof success is inferred from reaching that boundary.
The full retained 121-position vectors are useful observations, but this record
promotes only the fixed frontend node/entity domains. Generated-name spelling,
installation/source path lengths, heap maps, stack maxima and other capacity
components retain their separate source arguments.

`captures.tar.gz` retains exact invocation/options, debugger scripts, results,
logs and pool vectors. `archive-manifest.json` hashes every member. `inputs.json`
hashes the reused library sources, ALIs and naming configuration; their bytes
remain in the earlier dependency archive. `tool-identities.json` records the
installed producer/debugger hashes. `managed-runs.tar.gz` retains all four
managed event logs; run IDs are in `summary.json`.

```sh
python3 docs/evidence/retained-main-semantics-20261018/library-capture/verify.py
```

This offline reconciliation does not execute a compiler or prove the source
reduction. Scratch scripts use `/tmp/silver-fixed-library-frontend-20261018`;
reconstruct an isolated workspace before running them. Do not execute them in
the evidence directory.
