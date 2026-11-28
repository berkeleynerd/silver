# Main body and footer composition — 2026-11-27

Run `20261127T220902-a1d4d6187906` passed the focused MainBodyComposition target and a fresh
audit of 75,566 declarations across 607 imported modules. All 1626
captured inputs match the checking worktree. Every existing captured primary
input matches; the new MainBodyComposition module is the sole absent input
before integration. No cache transfer was performed for this check.

BodyLibraries composes the original Main context, header, optional arguments,
imported frame and declarations with Context_Of/Body_Of and recursive Tail.
Its full-domain theorem derives the body-reader domain, uses the original
recursive return contract to bound each footer-token and EOF call, and covers
all rejection paths and arbitrary original native local storage. It does not
assume an accepted decoder or a semantic checker result. The recursive
interface remains explicit typed-body equations on the native domain; its
actual primitive import interpretation and final semantic endpoint are still
required, not claimed complete by this packet.

The first draft failed namespace/alias resolution; the second failed two
rewrite matches across token and call-wrapper definitions. The final repair
gives those equalities their exact consumer types and changes no domain,
contract or budget. Both failed runs remain failed in the managed ledger.

Linux x86_64, Lean 4.34.1, two workers and two threads per process, 8192 MiB,
actual guest CPUs 4–5 within the host eight-CPU allocation. Build took
6.232 seconds and fresh audit 3.981 seconds after earlier dependent-module
builds. This is incremental focused validation, not a clean build, kernel
replay or complete feature assurance. Selected proof role: Astra Max; runtime
settings are not independently exposed.
