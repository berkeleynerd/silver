# Checked-in certificate synchronization

The first complete #392 suite at `dd0c9faad108f9bab2448db2ce1b692d72d0ea3c`
exposed stale checked-in generated output-body certificates. Two methods in
`tests/test_lean_source.py` compare repository copies with fresh generation and
ordered reconstruction. The original full run `20261117T070433-0b21916222cf` finished with exit 1:
715 tests in 1,160.365 seconds, three failure records across these two methods,
and two expected platform skips. Its [failed record](failed-full-suite/summary.json)
retains the original journal, logs, frozen input hashes and collected terminal.
All frozen test/review inputs were rehashed unchanged after the run.

Exactly nine files require synchronization: `proof/Silver/OutputBodyCertificate.lean`
and `OutputBodyLines0.lean` through `OutputBodyLines7.lean`. The
[comparison](comparison.json) records old and proposed SHA256 values. Fresh
scratch generation from the frozen authoritative source and unchanged generator
matches all nine files in both the successful complete Lean workspace and its
retained input archive exactly. The source owner and independent Astra Max
reviewer verified these comparisons separately.

`scripts/check_lean.py:107` intentionally excludes generated candidate copies
from captured repository proof inputs. It regenerates them from captured source
and generator inputs, then hashes the actual workspace and audits its module
closure. All nine replacements are already covered by complete run
`20261117T064945-d458c99ae977`, including their retained compiled objects. The
synchronization changes no Ada source, handwritten proof, generator, effective
Lean proof inputs or native provenance input. It requires no new native or Lean
proof run. This is an omitted repository-artifact update, not evidence that the
actual-source proof used stale candidates.

All nine files were synchronized together to the independently verified hashes
after the original suite finished. Next run the complete `test_lean_source.py` file (17
methods, including the native certificate probe). Then run a fresh unfiltered
715-test suite on a newly committed/frozen snapshot. No test or contract is
weakened. The original failure and repair checks remain separate records.

Diagnosis used Astra Max for source correspondence and independent critical
review; monitoring used Sol High. These are selected assignments, with live
model/effort and token/cost telemetry unavailable. Scratch generation took
0.397 seconds; no proof/build/test was run for the diagnosis itself. CLI memory
was not updated.
