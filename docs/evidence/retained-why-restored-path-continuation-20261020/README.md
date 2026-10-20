# Restored-path continuation packet

Round 30, 2026-10-20, research #119 / #153. See the
[source result and residual](../../research/retained-why-restored-path-continuation.md).

The small serializer U candidates remain conditional. This packet derives the
larger bound `U_supplied <= C + N*144115188075855863` for valid strings actually
supplied to serializer arguments. It does not bound attempted path construction.
All five applications reject useful Format headroom. That rejection is retained
as a result, not converted into a capacity claim.

- `source-excerpts.json` contains exact source/member identities for the private
  path writers, selected driver/task frontier, numeric-tag equality, ephemeron
  partial mutation and String.concat.
- `private-writer-census.json` retains all `store_path`, `store_theory` and
  `id_to_path` references in the retained ML/interface archive. It distinguishes
  Theory's table from Pmodule's separate table; the census is not an indirect
  callback completeness proof.
- `inputs.json` pins imported accepted serializer, runtime, driver and review
  evidence. The original five-process extraction/correspondence is reused.
- `result.json` retains multiplicities, subtotals, absent-ID tags, larger
  bounds, rejected guards and focused challenge results.
- `transfer.py` keeps supplied bytes distinct from unknown construction work.
- `build_packet.py` reconstructs excerpts and identities from retained bytes.
- `round.json` records selected settings, measured checkpoints and scope.

From the repository root:

```sh
python3 -B docs/evidence/retained-why-restored-path-continuation-20261020/check.py
git diff --check
```

The default checker compares with the recorded result. `--write` intentionally
regenerates it. No native, capture, compiler, solver, proof, source fetch,
observer replay, binder recomputation or alpha replay occurs.

Next boundary: bound selected `store_path` payloads from lazy int/real libraries,
tuple-theory construction and selected indirect helpers, or prove disjointness
from captured tags with justified freshness. Weak-key liveness alone does not
preserve reachability through the early-publication ephemeron resize.
