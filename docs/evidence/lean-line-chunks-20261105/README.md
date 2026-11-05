# Line-certificate sample comparison — 2026-11-05

The [experiment](../../lean-line-chunks.md) completed one ordered 512-line sample
comparison at implementation commit `c7c0f175c09f8b27b4783d592121373c0cfa9b42`,
based on `617547bd0dd62bb5aa58b2b4833959e7a068dc19`. Native host: Linux x86_64;
pinned Lean: 4.34.1. Both trials used the same four 128-declaration chunk modules
and aggregator, one thread per Lean process and a 4,096 MiB internal allowance
per process. The complete prepared candidate remains **UNVALIDATED**.

| Measurement | One Lake worker | Four Lake workers |
| --- | --- | --- |
| Timed wall | 1,081.519 s | 383.054 s |
| User CPU | 1,004.247 s | 1,298.313 s |
| System CPU | 75.107 s | 121.106 s |
| Total CPU | 1,079.354 s | 1,419.419 s |
| Sampled peak aggregate RSS | 2.210 GiB | 4.630 GiB |

Observed wall improvement: **2.823×**, or 64.58% less time; total CPU increased
31.51%. Common-import setup took 27.210 timed seconds outside the trials. The
timed interval covers Lake launch/reap; managed durations include surrounding
checks. CPU uses `RUSAGE_CHILDREN` user/system deltas. RSS and available memory
are samples, not exact peaks or hard aggregate limits.

All three managed phases succeeded: setup `20261105T164133-c09f71599053`, one
worker `20261105T164223-81a2973a395c`, and four workers
`20261105T170047-20bc9f578a1a`. All five candidate modules built in each trial.
The first trial started without candidate artifacts; the second deleted 80
candidate artifact files. All 25 common compiled-object hashes are identical
across setup and both trials and matched the final workspace. All phase
manifests match the reviewed manifest SHA-256
`0f208309224c987c947da9f39a0c69c596c67388c2fe9e3c356561a254d8cf5f`.
Retention also verified the manifest's 12 original inputs, 25 prepared outputs
and three tool binaries against their current bytes.

Native verification `20261105T110725-477d91dbd07d` overlapped both trials.
Pin-budget repair `20261105T170530-55ec63277225` joined near the four-worker
trial's end. Mean sampled one-minute host load was 4.97 versus 9.68; host load
also includes the experiment. This single ordered sample under changing load
does not establish causal timing or full-certificate timing/memory forecasts.
No complete reconstruction, complete source/module/axiom audit, independent
kernel replay or formal acceptance was performed.

Recommendation: stop after retaining the sample result; consider a separately
selected full-certificate trial with capacity planning. Production adoption is
not authorized.

## Retained records

- [pair.json](pair.json) is the exact harness output, SHA-256
  `6abded5ae6a9a082a235cbd1b8d0fd6e024073bbfed23c221053ed65afbfcd36`.
- [manifest.json.gz](manifest.json.gz) preserves the exact reviewed manifest.
- [common-artifacts.json](common-artifacts.json) preserves the shared object map.
- `common/`, `workers-1/` and `workers-4/` preserve each phase's exact managed
  events, result, build log and samples. Samples substantiate the memory and
  load summaries; gzip changes only storage encoding.
- [summary.json](summary.json) records arithmetic, module counts, contexts and
  the shared identity checks. Duplicate phase manifests and object maps are
  retained once, with each original path and digest recorded in that summary.
- [retained.json](retained.json) maps copied records to their original absolute
  locations and records both original-byte and retained-file digests.
- [SHA256SUMS](SHA256SUMS) binds the packet's files, including this README,
  summary and retention index.

From this directory, verify stored and decompressed bytes without the original
worktree:

```sh
sha256sum -c SHA256SUMS
python3 - <<'PY'
import gzip, hashlib, json
from pathlib import Path
for item in json.loads(Path("retained.json").read_text())["files"]:
    path = Path(item["retained"])
    stored = path.read_bytes()
    assert hashlib.sha256(stored).hexdigest() == item["sha256_retained"], path
    raw = gzip.decompress(stored) if path.suffix == ".gz" else stored
    assert hashlib.sha256(raw).hexdigest() == item["sha256_uncompressed"], path
print("All retained original bytes verified")
PY
```

Monitoring and evidence preparation selected GPT-6.1 Sol / High; runtime-confirmed
model/effort and token/cost measurements are unavailable. This round retained
the successful sample results and checked identities, arithmetic, links and
whitespace. No phase failed and no proof was rerun for recordkeeping. Historical
implementation and independent-review settings remain in the experiment record;
this retention work is not another independent review of the harness.
