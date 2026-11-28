# Complete original Basic import composition — 2026-11-27

Run `20261127T232232-d73c17163abe` passed a fresh audit of 84,382
declarations across 739 imported modules. All 1,690 captured hashes match the
checking worktree. Before integration, primary differed in these two new modules
and two newer initializer modules outside this imported closure.

Every original Basic branch now consumes its actual inherited and package-call
libraries on derived full native callee domains. This includes rejected input,
failed package function fallback, procedure calls, assignment-result field
subtypes and the final semicolon. The whole Basic model equals the normalized
reader used by the semantic decoder. State-effect callbacks remain identical
on both sides for the separate effect join. No accepted source, successful
semantic check or narrowed native domain is assumed.

The first import draft needed explicit cursor arguments and local projections.
Two composition drafts failed to normalize local abbreviations before rewriting
the calls. Explicit normalization resolved them without budget changes. Their
logs remain failed. Linux x86_64 / Lean 4.34.1, two workers/two threads,
8192 MiB per process, guest CPUs 0–1 borrowed from the semantic stream and
returned at completion, within the host's shared eight-CPU allocation.
Incremental focused build/fresh audit; no copied cache, kernel replay or complete
feature assurance. Proof role follows Astra Max guidance; runtime settings and
token/cost measurements are not independently exposed. Original Statement/Tail
imports and the final declaration-derived application endpoint remain required.
