# Isolated final compiler regressions

These fresh runs resolve the three compile timeouts from failed run
`20261108T093645-d959cfabae08`. Each ran separately through `scripts/dev.py test
--jobs 22` on unchanged regression checkout `4aedc16404`, with the approved
auditor correction, original methods/assertions, compile and execution deadlines,
and production proof options. No competing managed native or Lean run was active.
The earlier failed run remains failed.

| Selector | Managed run | Test seconds | Original compile deadline | Actual driver exit |
| --- | --- | --- | --- | --- |
| maximum dynamic expression | `20261108T172103-a3522f3d8dea` | 171.737 | 300 s | 0 |
| Boolean/Integer self actuals | `20261108T172448-d43073aeb848` | 14.879 | 120 s | 0 |
| ordered calls, snapshots and unused-function coverage | `20261108T172546-80a42bd29b42` | 15.010 | 120 s | 0 |

Each packet retains exact input/binary identities, command, complete test log,
managed events and actual exit/postflight records. All 1,100 explicitly indexed
tracked regression inputs and both binary hashes matched after each run; managed
records additionally retain their own input/configuration capture. The maximum
expression and ordered-call observers sampled only full 22-CPU affinities and
found no remaining live descendants. The quick self-actuals test finished before
its observer could launch; its actual exit and explicit postflight process scan
are retained, without a continuous-observation claim or a redundant rerun.
All 28 compressed payloads were decompressed and checked against indexed sizes
and hashes. Successful test fixture workspaces were removed by the original
unchanged tests' cleanups; no separate application-report archive is claimed.

These are three fresh successes added to the prior independently reviewed
629 applicable results. The platform wrapper and its twelve nested bodies still
remain outstanding, as does the later refresh of the three existing Rosetta IDs.
The final independent inventory reconciliation remains required.
