# Independent contract-builder review evidence

Review target: `49c18b7ef37967c8b6f486721fd006d61857a8fb`.
Provisional disposition: material R1 remains; see the
[report](../../reviews/review-main-contract-builders-20261024.md).

`audit.py` checks exact inputs and source identities, independently inventories
the eleven clone ancestors and four executable definitions, exercises request
and cumulative-owner diagrams, and reproduces R1's zero map demand on a first
mismatching argument. Its tree-shape check supports the set-submap source
argument. It imports builder code as the subject under test, with accepted
bridge/kernel providers, but no author or predecessor checker.

The sole run passed 2,711 assertions in 1.608728722 seconds on Linux. A pass
means the requested audit assertions hold, including the material finding;
it does not mean the author packet is accepted. No native tools were run.
The recorded 256-second review interval excludes later report/commit work.

To rerun this independent audit from this worktree's repository root:

```sh
python3 docs/evidence/review-main-contract-builders-20261024/audit.py
```

No rerun is required solely to reproduce a successful receipt.
