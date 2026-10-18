# Literal GPR attachment review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
**The attachment is accepted within its conditional local scope**, with one
nonblocking documentation sync note. Exact target:
`f7dabafac5c6552ea60743efee6db296d1efc1eb`; reviewed diff:
`5ce9feb5d8..f7dabafac5`. This review reuses the
[accepted component review](review-literal-gpr-parent-f7904ce722.md) and does
not repeat the GPR source derivation or review unrelated aggregate formulas.

The known BIND-count defect [#130](https://github.com/berkeleynerd/silver/issues/130)
remains in this frozen target. Passing its aggregate checker verifies the
attachment and retained assertions; it does **not** validate the affected
native lifetime formulas or establish whole native/pipeline capacity. Their
repair and independent assessment remain separate work.

## Reviewed join

Reviewed the changed aggregate `compose.py`, `check.py`, `inputs.json`,
`result.json`, `check-results.json` and the added section of the
[pipeline argument](../research/retained-literal-pipeline.md). Applicable
Oracle, authorization and review requirements are unchanged from the preceding
component review. The frozen callable identities are:

| Input | SHA-256 |
| --- | --- |
| Aggregate `compose.py` | `79dc45b4f3cde2fa21bfaf3cef81a8883c1d885a590bd08cb3fb837ce08734be` |
| Aggregate `check.py` | `66a3b1d8ffd1d12faf0793c74b056b14b07de0ba5601d6e097ddf00ca2111c58` |
| Aggregate `inputs.json` | `5796df5d77d57fc0acd09b1160db013829f6037853c6493a77ffb8366bfd8d56` |

- The new callable receives the complete `raw` source and the descriptor's
  spelling-only P. Its result must match source identity, the complete source
  count dictionary, P and the **entire** previously evaluated Main ALI result.
  A changed nested byte bound cannot pass through a count-only comparison.
  The returned component is retained without projection or discarded premises.
- All 87 aggregate pins independently match. The six additions pin the accepted
  GPR callable, its input/source manifests, retained result, argument and review;
  the prior 81 entries are unchanged. The component's verified transitive
  archive/source identities remain active through its `Context` constructor.
- `GPR_parent_DW_local_interface` enters `conditions`, and
  `evaluated_predicates_pass` still uses the conjunction of those conditions.
  No local-failure result is overridden. P=976/977 and the physical-column case
  propagate the component's sufficient-condition outcome into the conjunction.
- The two added fault-injection cases independently change P and the nested
  Main EOF-inclusive reader bound. Both must raise
  `ValueError('literal GPR parent DW interface join')`; the original callable
  is restored in `finally`. Normal variants also check exact source/count/P/
  Main equality and the inherited local numerical result.
- The retained default nested GPR object equals the accepted standalone result
  exactly. Other changed top-level result fields are the local condition,
  open-join description and pin count, plus the actual-worktree source path.
  Its false fields preserve missing launch materialization, fixed-child
  correspondence, complete GPR.Names backing, output source buffers,
  whole-parent and whole-pipeline capacity. The historical binder-consumer
  parent-reader flag remains false in its own component. The new separate
  field supplies only the conditional local result.

The argument now explicitly requires the fixed U/W/Y/Z/D inventory to preserve
multiplicities as well as spellings and widths. It correctly leaves realization
of that producer contract open. No component equation, production invocation,
admission rule or Oracle guarantee changes in this attachment.

## L1 — Nonblocking README sync

The aggregate [README](../evidence/retained-literal-pipeline-20261018/README.md)
still says the checker runs **64** interface checks; this target has **66**.
Its final paragraph also retains the earlier blanket statement that the native
parent D/W reader remains open, without describing the newly attached local
reader. Update those statements to 66 and the remaining complete-parent,
producer-contract and shared-storage boundaries. The callable, output and
pipeline argument already distinguish those scopes correctly. This is a low
documentation discrepancy, not a defect in the join or evidence arithmetic.

## Replay, timing and limits

One completed focused aggregate replay ran on Linux x86_64:

```sh
python3 docs/evidence/retained-literal-pipeline-20261018/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --ada-root /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --plugin-include /home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include \
  --output tmp/gpr-attachment-review/check-results.json
```

The detached review worktree was
`/home/canto/src/github.com/berkeleynerd/silver/tmp/review-literal-gpr-attachment-f7dabafac5`;
the wrapper supplied the absolute output pathname. Start:
`2026-10-18T19:17:01.217237Z`; finish: `19:17:04.783188Z`; measured subprocess
time **3.562564307 seconds**. Exit status was zero and stderr empty. Stdout:

```json
{"cases": 66, "all_checks_pass": true, "native_tool_executions": 0}
```

The 10,474-byte output matches the frozen `check-results.json` exactly,
SHA-256 `b4ab055df396299fb52bce2180a6c55464ff07475d0da13005abb255fe8ddd04`.
An initial setup attempt used the Ada-source archive as `--gcc-root` and stopped
before evaluation because `gcc/gimplify.cc` was absent (0.088759318 seconds).
The retry used the full GCC tree documented in the existing CF/CFG review;
no source or pin was changed. Both attempt logs/argv/timings and the retained
result/pin inspection are preserved under `tmp/gpr-attachment-review/`.

The parent's reported 66-case replay (3.732 seconds) and default-result replay
(3.337 seconds) are separate attributed evidence. This reviewer did not rerun
the default callable or any native tool, proof audit, build or full test suite.

Selected reviewer: **GPT-6 Astra / Extra High**, continuing the parent-assigned
setting. Runtime model/effort confirmation and token/cost measurements are
unavailable. Worktree creation was `19:16:02Z`; review and report preparation
occupied approximately three minutes. The round accepted the attachment,
identified the low README sync, and corrected one local replay setup path.
Native execution time was zero. The live subthread goal was null; no goal,
GitHub state or CLI memory was changed.
