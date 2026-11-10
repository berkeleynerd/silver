# Procedure report policy: focused Python checks

Managed run `20261110T001444-6cb1be2b5661` passed five selected methods in
`tests/test_evidence.py` on Linux x86_64 with one reserved worker. The test
process returned 0; unittest reported 0.074 seconds and the managed run reported
2.154325804 seconds. The original events and log are retained compressed.
`summary.json` and this README are integration-lead indexes, not runner output.

The methods cover exact procedure/output inventory and initialization witnesses,
required no-inlining, irrelevant projected proof-tree data, and preservation of
the existing function inventory/termination policy. Shared mutations reject
missing/duplicate/wrong-owner records, wrong names or result fields, unproved
safety checks and missing unused-procedure coverage.

This is Python auditor evidence only. It does not compile the native fixture,
exercise the 64 MiB boundary, establish procedure admission or replace complete
compiler/native/Lean/source validation. Those checks remain pending. The earlier
reservation attempt did not execute tests because another run acquired the
worker budget first; it has no test result to reuse.
