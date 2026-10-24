# Independent local native-capacity review evidence

Review targets are the kernel commit
`36d478da0cb3261920fd595ba4a9bdcde54b0cb5` and repair commit
`1604467b0f2892d3f92f4f40caaabcc05be52271`.
See the [review report](../../reviews/review-general-native-capacity-20261024.md)
for the source argument and disposition of #207.

- `audit.py` verifies both frozen packets, checks retained kernel identities
  and projections, then invokes only the current `repair-string-pack.py`.
- `audit.json` records exact inputs, scope, selected reviewer setting and times.
- `repair-check-result.json` is the one independent current-checker output.

The original kernel checker is not run: its document pin belongs to the exact
kernel commit. Historical inputs are read at that commit. The repaired current
export is compared with the author result excluding only elapsed time.
No predecessor checker, native compiler, prover or capture is executed.

For intentional reproduction at the reviewed author inputs:

```sh
python3 docs/evidence/review-general-native-capacity-20261024/audit.py
```

Selected reviewer: GPT-6 Astra / Extra High. Runtime confirmation and
token/cost measurements are unavailable. These offline checks do not establish
semantic branch coverage or complete native capacity.
