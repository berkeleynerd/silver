# Round 37 integration reconciliation

This packet compares the three exact author freezes and the cleanup-option
source supplement against aggregate `f1b1abb858`. All 34 author files, eight
supplemented/corrected paths, 94 retained native pins, five Python parses and
14 local links reconcile. The fifth Python file is the new reconciliation
checker; the initial aggregate contained only the four author Python files. The pre-correction check passed in 0.296198 seconds;
its result is retained separately. The changed-input check after the reviewed
raise-path correction is recorded in the round ledger. No component checker or predecessor run was
repeated by this reconciliation.

```sh
python3 -B docs/evidence/retained-why-save-round37-20261020/check.py
```

`inputs.json` identifies the author and review revisions;
`integration-result.json` records checked paths and identities. The checker is
reused with new round inputs; it is not a rerun of Round 36's reconciliation.
These identities do not establish the source arguments or complete #119/#153.
See the combined Round 37 review for substantive conclusions and residuals.
