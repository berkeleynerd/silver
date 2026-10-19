# Selected literal SSA lifetime source packet

The [source argument](../../research/retained-literal-ssa-lifetime.md) extends
the accepted initial Main SSA allowance through selected O0 teardown. It
adds zero events to that owner. The existing arithmetic guards remain required.

`inputs.json` records exact complete GCC/repository source identities and
selected excerpts. `check.py` checks those identities/excerpts and reconciles
the retained initial result's event ownership and guard conjunction. It does
not prove source reachability or rerun an aggregate/previous suite. Independent
review of the argument is required. `result.json` and `round.json` separate
new checks, reused evidence and open whole-capacity obligations.

Run only when these inputs change:

```sh
python3 docs/evidence/retained-literal-ssa-lifetime-20261019/check.py
```

The retained GCC tree default is `/tmp/silver-backend-compose-20261018/full-source`.
It is read-only; there is no compiler/prover/native subprocess.
