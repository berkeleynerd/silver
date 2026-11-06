# Split-certificate tooling tests — 2026-11-06

The selected implementation is `a179b4593d5553494d00e425f0ee09b5f35ed01c`.
Native Linux x86-64 results:

[Final-input applicability](applicability.md) maps the 87 distinct selected
methods and completed native evidence to integration `3f5d575635`, and records
the remaining complete Lean/source-correspondence obligation.

| Scope | Result | Time |
| --- | --- | --- |
| Source policy/parity and mocked runner/lease checks | 70 passed | 16.779 s |
| Mocked platform routing with real Python generation | 16 passed | 226.792 s |
| Real tiny split-certificate generation/module fixture | 1 passed | 115.994 s |

Managed source-policy/parity rerun `20261106T112137-dccd83f67d55` passed all
12 selected methods in 7.253 seconds (10.464 seconds managed) with one reserved
worker. Its `4f7de6594b` source, scripts, proof and test trees are byte-equal to
integration `3f5d575635`. These 12 methods are a rerun subset of the original
70, so they add no distinct test count. A preceding workspace-lease refusal
launched no tests and is not recorded as a failed test outcome.

[Summary](summary.json) records exact commands and scope. The first two commands
ran directly: their logs are retained, but no contemporaneous complete managed
input manifest was collected. The platform tools are mocked; its printed proof
messages do not establish production proof success.

Accepted native fixture run `20261106T104456-8030323f7a35` reserved one worker
and explicitly set every Lean build/audit process to `-j1/-M2048`. It exercises
actual production generation/pending-file publication and binary Lake source
dependencies on a tiny source. Real kernel checks and fresh legacy audits cover
token and CRLF edits with restored source timestamps, unchanged generated-file
reuse and preservation of unrelated module objects. It builds no full production
certificate and establishes no complete-project assurance.

Predecessor `20261106T104217-f6e8654eb12d` is **failed**. Its assertions passed,
but editing the test before the final input check caused the managed runner to
reject the run. Its initial build helper also omitted explicit Lean thread and
memory settings. The passed stable-input rerun supersedes that test evidence;
the failed ledger and wrapper diagnostic remain retained without relabelling.

[Artifact hashes](artifacts-index.json) bind all compressed logs and ledgers.
The summary points to their original local ledger/log paths. Selected worker
model/effort: GPT-6.1 Sol / Extra High; runtime confirmation and token/cost
measurements are unavailable. This packet reuses completed evidence and adds no
review, proof run, full regression run, macOS test or hosted CI result.
