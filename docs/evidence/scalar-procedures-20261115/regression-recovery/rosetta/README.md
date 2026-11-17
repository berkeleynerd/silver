# Final Rosetta metadata validation — 2026-11-15

This packet validates the isolated final Rosetta metadata for authorized #370
and #29. It supplements proposal
`dea5d04ad708d2c0d710b99c276a8b27526f975e`, based on
`8ccbc84210346596bc8417cbf8b6bc40f8075ed7`, on branch
`recovery/procedures-rosetta-20261115` in
`/home/agent/silver-workspaces/recovery-volume/rosetta`.

The lead released this reconciliation after independent Astra Max review
accepted complete regression coverage: 26 fresh passes, 663 retained passes
and two expected skips before these final Rosetta updates. All 12 final-byte
Rosetta passes replace their 12 retained results, producing **38 fresh passes,
651 retained passes and two expected skips** across all 691 IDs. Both original
failing test IDs are resolved by the separately reviewed repair/environment
results; the original full-suite run remains failed. The
[capability delivery section](../../../../scalar-procedures.md#delivery-assurance-and-validation)
owns coordinated support claims and the separate final integrated
feature-delivery review. This reconciliation does not record that later review
as already completed or authorize a merge, broad #11 closure or #373 work.
Unrelated untracked `tmp/` is preserved.

## Exact changes and controls

The follow-up changes only current assessor wording, the Return multiple values
risk/summary/targeted-review wording, its generated page, and a separately
attributed [validation addendum](../../../../../rosetta/assessment-scalar-procedures-20261115.md#final-validation-addendum).
The original static task review and historical pending evidence retain their
scope. The sample, expected stdout, sample manifest, cached task and Ada
solution are unchanged.

[controls.json](controls.json) retains byte sizes and SHA-256 for every render
input (`rosetta/manifest.json`, `rosetta/coverage.json`, `rosetta/refresh.py`),
the assessor, test module, task/Ada/sample inputs and original pending review.
[check-controls.py](check-controls.py) reproduces the checks without native
tooling or a managed integration workspace. It establishes:

- Exactly one task assessment changes from the pre-proposal baseline:
  **Return multiple values**. Only `scalar-procedures` is added to `supported`;
  no supported identifier is removed.
- Stage 1 grows **83 → 84**. Return multiple values alone changes stage,
  **rank 85 / Stage 2 → rank 59 / Stage 1**. No mapping leaves Stage 1.
- All **44** stage drivers and introduced-construct lists stay unchanged.
  Stage 2 is still Law of cosines - triples, introducing `for-loops`, `integers`,
  `procedures`, `ranged-subtypes` and `scalar-image`. Broad #11 remains open.
- Original assessment provenance stays revision `412999`, assessed
  `2026-10-15`, rubric `2`, tier `deep`, model `claude-opus-5-5`, effort `high`.
  The 2026-11-09 assessment stays byte-identical, including its pending status.
- The original proposal has exactly 40 changed paths. The final tracked
  Rosetta diff remains within those paths; this bounded evidence
  directory is the only added scope.
- The unchanged 912-byte sample has SHA-256
  `fe82cee9e09fb5911c02049998bb580defec6168af792664427231880c7b547d`.
  Independent exact arithmetic covers all 40,401 declared input pairs and
  derives the same 67-byte stdout, SHA-256
  `4af8f788ee41cd6f93e9d9f7bd4c98550618eeea59c5f53f16329781b8cd138a`.

[generated-file-hashes.json](generated-file-hashes.json) binds all **1,784**
rendered pages/indexes, including unchanged outputs. Its canonical digest,
computed from sorted compact JSON as recorded by the control script, is
`79de546605ddca5ae6039bd408d9b98b3fd8b9af6a45c3a7d1ec4433a9ce683f`.
The only generated page changed since the original proposal is
`rosetta/r/return-multiple-values/silver.md`. No generated page was edited
independently.

## Actual validation

The native host is **Linux ARM64** (`linux-aarch64`); the repository path is
not a macOS evidence claim. The Python executable and platform identity are
in `controls.json`. All commands used `PYTHONDONTWRITEBYTECODE=1`; they used
the isolated Rosetta checkout and no native, Lean or build job, toolchain
installation, bootstrap or integration lease.

| Command | UTC interval | Result |
| --- | --- | --- |
| `python3 rosetta/refresh.py --render` | 22:39:38.718–22:39:39.224 | exit 0; 0.505 s; existing manifest/assessments, no network |
| `python3 -m unittest tests.test_rosetta -v` | 22:39:39.224–22:39:42.649 | exit 0; all 12 tests; unittest 3.178 s, subprocess 3.425 s |
| `python3 docs/evidence/scalar-procedures-20261115/regression-recovery/rosetta/check-controls.py` | 22:40:41.477–22:40:42.270 | exit 0; all input/mapping/attribution/output controls |

[commands.json](commands.json) binds exact command arguments, environment,
timestamps, exits, elapsed time and log hashes. It lists all 12 unique complete
test IDs and their actual passed results, checked against unittest's expected
inventory. The tests cover cache preflight preservation, offline rebuilding,
pending-design treatment, complete deterministic rendering across hash seeds,
and risk counting. [tests.log](tests.log) retains every original terminal line.

The first result collector expected `... ok` on one line and did not recognize
the mocked online-preflight test's interleaved diagnostic lines before its
terminal `ok`. The test process itself exited 0 with all 12 tests passing.
Collection was corrected from the retained log and expected-ID inventory without
repeating execution. A draft control assertion omitted the existing Stage 2
`for-loops` and `integers`; comparison showed those same five identifiers in
both baseline and final mappings, and the assertion was corrected. A subsequent
control inventory attempted to hash nonexistent `tests/__init__.py` in this
namespace package; its failed log is retained separately. Removing that
nonexistent inventory item yielded the recorded successful controls. None of
these evidence-collection corrections changed any render/test input or result.

The later complete native, cached Lean/source, full-regression and repair-run
records are linked separately from the assessment addendum. The failed full
regression remains failed; this packet supplies final Rosetta checks within the
reviewed inventory, not a replacement full suite or universal proof.
The successful tests may be reused only while their recorded render/test
inputs remain byte-identical. A later change to the capability prose or this
evidence prose alone does not change those test inputs.

Selected role under the repository policy: **GPT-6.1 Sol / Extra High** for
bounded metadata extraction and reconciliation. Independent live model/effort
confirmation, token/cost telemetry and total subthread elapsed measurement are
unavailable. Actual command durations are reported above. CLI memory was not
updated. The lead owns final integrated review, issue/board and memory updates,
publication and the final support claim.
