# Application_Basic reader interpretation, 2026-11-27

The exact 597-token candidate checks the complete header, contracts, native
declarations, assignments, branches and returns. The typed evaluation agrees
with the raw Basic reader for all stores and callee results. The proof covers
qualified function assignment, fallback expression effects, package procedure
routing, ordinary statements, state writes, stalled cursors and invalid input.

The [Linux run](index.json) freshly audited 20,248 declarations using the
standard Lean foundations and two workers and two threads. The complete
candidate compiled in the preceding batch and its compiled object was reused.
The earlier failed meaning check and source-directed normalization changes are
retained in the ledger. Actual callee binding and the authoritative whole-file
token reconstruction remain separate obligations.
