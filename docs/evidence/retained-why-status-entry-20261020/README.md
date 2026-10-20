# Retained initial status fields

This packet supplies the five initial status/attempt/parent projections needed
by the authorized #119/#153 status-invariant investigation. It is a narrow
projection of retained fresh captures, not a new target run or a continuation
proof. The [short note](../../research/retained-why-status-entry.md) explains the
observed facts and their boundary.

`result.json` records actual PID/root/controller/session joins, each cache's
scalar size and full binding sequence, missing/duplicate key domains, goal/task
and parent edges, attempt memberships, decoded `proof_state`/answer and obsolete
flags. Each source getter value and entry update-formula value is separately
labelled; a cache miss stays an absent observation. All five entry getter and
update-formula values agree. This does not claim that absent cache entries were
observed false, or establish a later status invariant.

The extractor uses only manifest-bound archive members and existing accepted
comparison/replay identities. It checks overlapping raw identities, binds the
fresh projection to the repaired state join, and independently checks only the
needed session-block fields against that projection and retained source layout.
It reuses the accepted serializer packet's archive-reader/identity helpers,
recording that helper file's identity. No prior collector, binder or alpha
analysis is replayed. All old packets remain unchanged.

From the repository root:

```sh
python3 -B docs/evidence/retained-why-status-entry-20261020/extract.py
python3 -B -m unittest discover -s docs/evidence/retained-why-status-entry-20261020 -p 'test_*.py' -v
```

The default command verifies exact deterministic equality; `--write` creates an
absent first result and refuses to overwrite one. Focused checks reject raw
identity and record-layout mismatches, preserve unknown result bytes, separate
absent caches from cached false, and retain duplicate binding visits/first lookup.
The selected model/effort and measured check evidence are in `round.json`.
