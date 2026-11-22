# Complete named-array Lean/source checkpoint — 2026-11-21

Run `20261121T215449-12cec2fc5976` passed on `7f449246ce`: **1,083 project
modules and 173,026 declarations**, with only `propext`, `Classical.choice`
and `Quot.sound`. This is a complete incremental build and fresh module/axiom
audit on Linux x86_64, using six managed workers and six configured Lean threads
on guest CPUs 2–7 alongside the two-worker regression run on CPUs 0–1.
Managed duration was 27.798 seconds. Existing successfully checked objects were
reused through Lake; no clean build or independent kernel replay is claimed.

The [independent coverage review](../../../reviews/review-named-array-audit-coverage-20261121.md)
matched every prepared module and the captured Ada inputs to the final tree,
recounted the emitted module inventory and verified the terminal managed record.
The earlier [focused source packet](../focused-source-continuation/README.md)
records the actual-source checks and cross-worktree cache handoffs used by this
integration. The retained source/trace identities remain part of the evidence;
the final incremental duration is not the total proof-development cost.

| Run | Scope and outcome | Managed seconds |
| --- | --- | ---: |
| `20261121T210604-4b2b25ed79cf` | Complete build failed in three stale source/flag consumers. | 960.770 |
| `20261121T212510-16882cbcff36` | Both source candidates passed; focused batch failed on flag-proof elaboration. | 873.907 |
| `20261121T214023-0f622151717c` | Five-target repair batch passed, 111,610 declarations. | 23.583 |
| `20261121T214156-37d0db242e83` | Complete build failed in the old scalar-only procedure metadata interpretation. | 14.224 |
| `20261121T214735-7e1a499a3d93` | Source-derived procedure metadata interpretation passed, 148,749 declarations. | 23.883 |
| `20261121T214832-3b05e086bcb8` | Imported declarations passed; complete run failed on the missing orphan module. | 26.771 |
| `20261121T215031-4717b14d556a` | The orphan's full-domain helper proof passed individually, 15,393 declarations. | 19.189 |
| `20261121T215140-529c8575a3d7` | Complete build failed because that orphan duplicated an already imported theorem. | 11.566 |
| `20261121T215449-12cec2fc5976` | Complete build, source, module coverage and fresh axiom audit passed. | 27.798 |

The first repair matches two retained token requirements and an auxiliary
Boolean body literal to the already-modeled native source, and covers array-type
declarations in the retained assignment-flag proof. Its public theorem statements
are unchanged; see the [consumer review](../../../reviews/review-named-array-final-consumers-20261121.md).

The procedure metadata repair changes its signature interpretation to use the
type table from the same selected native scan. An empty table cannot describe
positive nominal array-formal IDs. The source-derived interpretation preserves
the program hypotheses, native selection and count/report equation; see the
[metadata review](../../../reviews/review-named-array-procedure-metadata-20261121.md).

The orphan repeated the already-consumed `appendArrayParameter_valid` theorem
over the identical full domain. Removing it preserves that canonical proof and
all three consumers. The complete inventory check remains unchanged, with no
exception or exclusion list. Failed runs retain their failed outcomes.

`runs/` contains gzip-compressed copies of the original managed events and
retained reports. `sha256.json` binds both their uncompressed original bytes and
stored compressed bytes; `run-summary.json` extracts terminal outcomes and phase
times. The original worktree paths in those records identify where the runs
occurred. Final regression coverage and Rosetta delivery remain separate checks.
