# R56 fixed-domain solver request bytes

The [research note](../../research/retained-solver-request-bytes.md) supplies the
source argument and its interfaces. Reproduce the focused, nonmutating check:

```sh
python3 -B docs/evidence/retained-solver-request-bytes-20261020/check.py
```

Run the displayed command from the repository root. The packet uses retained
inputs only; it starts no native target, solver, proof run or predecessor
checker. It checks:

- Exact R53 JSON function locations, R54 raw header values and R55 argv relation.
- All five selected driver transformation lists, the 14-file driver/import
  closure and its unique filename directives.
- Every permitted positive ID, both 0./1. time strings, both command profiles
  and two adapter lengths against the symbolic serialization formulas.
- Pinned source excerpts and a full retained Why3 ML/MLI inventory for temporary
  directory setters and encoding-dispatch registrations.

`projection.json` exports L_d, M_d, m_d and the separate original/wrapped argc,
field and semicolon counts. `source-witnesses.json` is source correspondence
material for review, not a semantic proof. `inputs.json` freezes external and
packet identities. `check-result.json` and `round.md` record focused evidence
and diagnostic history. Neither input pins nor results are rewritten by the
checker. The combined quiet+timeless+J12+logging startup join is explicitly
separate. No complete q, implementation, production adoption or new native
filename-table/getcwd observation is claimed.
