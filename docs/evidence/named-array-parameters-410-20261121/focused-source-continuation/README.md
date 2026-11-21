# Focused source continuation — 2026-11-21

These retained successes establish only their named focused scopes. The
complete project Lean/source/module/axiom checkpoint remains pending.

| Scope | Managed run | Fresh axiom audit |
| --- | --- | --- |
| Compose source checks, Compose model and Sequence model | `20261121T194149-127c5bf09e72` | 96,072 declarations, 291 modules |
| Function actual-source checks | `20261121T193933-afb215e6c72b` | 89,212 declarations, 284 modules |
| Procedure source/model and String-bounds sources | `20261121T194543-302f3f4f1b24` | 65,809 declarations, 583 modules |
| Source-derived Compose array imports | `20261121T201800-abfe1344ac75` | 25,031 declarations |
| Source-derived Boolean wrapper imports | `20261121T203235-079f1f0196b2` | 46,520 declarations, 339 modules |

Each audit retained only `propext`, `Classical.choice` and `Quot.sound`. These
are cached/incremental managed checks with fresh audits, not clean rebuilds or
kernel replay. The two actual Output certificate builds each completed all
eight line chunks and certificate assembly; both productive runs were preserved
once their overlapping work was recognized. Root composition elapsed time was
4,206.139 seconds at two workers/two configured Lean threads.

Logs, evidence and runner events are compressed verbatim. `sha256.json` records
both compressed and original hashes. Root cache-transfer observations are
retained alongside them. Immutable handoff caches kept original companions and
Lake traces; only source-matching audited modules were imported. Canonical
certificate mismatches were skipped by these root imports, preserving the
root's freshly generated and checked Output objects. Subsequent managed rehash
and fresh audits remain required. The procedure top-level bridge run separately
compares generated/prepared inputs before using the completed root cache.

Selected function/procedure proof and independent critical review settings were
Astra Max; the lead's live model/effort and total token/cost measurements were
not independently available. The separate capability record retains failed
attempts and the unresolved global integration requirements.
