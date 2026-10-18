# Zero-check source-path evidence

This is an offline source audit for
[the concrete producer derivation](../../research/retained-producer-zero-check-sources.md),
#119, 2026-10-18, Linux x86_64. No compiler, GNATprove, Why3, solver or Lean run
was made. `null.adb` and `literal_put.adb` contain the exact sources discussed.

`identity.json` pins the relevant SPARK files within the already retained full
frontend source archive, plus the local Silver dispatch, public IO specification
and null recognizer. The SPARK source-to-installed-tool premise is unchanged.

Run `python3 docs/evidence/retained-producer-zero-check-sources-20261018/check.py`
from any directory. It checks identities, selected source guards and fixture
arithmetic, then writes `result.json`. These assertions guard the audited
source anchors; they are not a formal proof of the branch exclusions. The
source argument is in the research document. The result records distinguish
zero Main tasks from the five still-unbounded fixed-library task-producing
files selected by output mode.

Independent focused review checked the driver/counter join, wrapper assembly,
generated-type early return, static literal guard and parent conversion. No
material discrepancy was found. Existing selected-call exclusions were not all
re-derived, and no toolchain or proof execution was used in that review.
