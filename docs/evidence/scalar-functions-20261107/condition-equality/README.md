# Condition-worker equality repair — 2026-11-07

Both added assertions and both original failing endpoints are now proved in
focused native checks. This #298 repair adds two Static assertions to
`src/silver_output_profile.adb`, based on `96950ce3e8`. It preserves the worker
contracts, all original assertions, admitted input domains, and executable
behavior. No generic equality helper or increased solver budget is introduced.

The Boolean-atom branch of `Read_Primary_Into` now states its existing
`Primary_Model` equality after filling the result. The pure-context branch of
`Read_Relation_Into` now states `Result = Expected` after calling the Boolean
relation worker. These are separately proved branch-local facts used by the
original joined equalities, rather than unchecked assumptions.

## Inputs and focused results

All proof scopes use the same native source SHA-256:
`9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f`.
The Linux x86-64 runs use the pinned GNATprove 16.1.0 toolchain from the original
managed run `20261107T181811-5b7564ac5afc`, checking executable hashes before and
after each run. Each reserves six workers, uses level 2, CVC5/Z3/Alt-Ergo and a
30-second timeout, with separate writable proof objects and cache. Source,
project, runner, selection metadata and Python tooling hashes are captured in
each run's prepared record and checked again after the native command.

| Check | Managed run | Selected proof result |
| --- | --- | --- |
| Added Primary assertion, line 3769 | `20261107T225130-8170d01a2abf` | Assertion proved; its model-call precondition also proved. One assertion leaf and 19 precondition leaves. See corrected audit below. |
| Original Primary postcondition, line 3673 | `20261107T225518-9833ad1fcd84` | All four selected leaves proved, including the Static model equality. |
| Added Relation assertion, line 4076 | `20261107T225729-2e9deb20d0ee` | One selected assertion leaf proved. |
| Original Relation assertion, line 4141 | `20261107T230027-3e226abd3bd6` | Assertion proved; its model-call precondition also proved. One assertion leaf and 19 precondition leaves. |

Each actual proof command combines `--limit-subp` with a single `--limit-line`.
The recorded SPARK entity name, check kind, source location, successful proof
trees and retained Why3 session establish which obligations were checked.
Filtered Why3 sessions retain unrelated unchecked goals; an unproved session
root is therefore not an unresolved selected obligation. Native success is
checked through the selected report trees and managed unresolved-obligation
scan, not merely the process exit status.

The [index](index.json) records commands, exact historical managed outcomes,
durations, scope audits and SHA-256 hashes of the uncompressed retained files.
Packets contain native logs, managed events, source/configuration/runner copies,
SPARK reports, generated GNAT-Why3 tasks, and Why3 sessions/shapes. The compressed
[original diagnosis](original-diagnosis.md.gz) preserves the earlier unresolved
leaves and the rationale for this two-line experiment.

## Retained setup and audit failures

- `20261107T224942-369c977f6af6` rejected the combination of `--limit-subp` and
  `--limit-lines` before generating proof tasks. This is a setup failure.
- `20261107T225019-4cd5ced38c0f` started a whole-worker check, then was interrupted
  during representation generation at the lead's direction to use four precise
  checks. No whole-worker proof result is claimed.
- `20261107T225130-8170d01a2abf` completed native proof successfully, but the
  scratch audit incorrectly required the entire filtered Why3 root to be proved.
  Its managed outcome remains **failure**. The separate
  `corrected-scope-audit.json` confirms the exact assertion/precondition and
  direct Valid results for all 20 selected leaves; the diagnostic ledger records
  the correction. This native proof was reused without an identical rerun.

## Assurance boundary

These are focused repair checks. They do not constitute a complete native audit
or complete source correspondence. Integration, final source-shape pins and the
final complete assurance checkpoint remain the lead's work. The existing
contracts and original endpoints remain present for that checkpoint.

Selected agent setting: inherited GPT-6 Astra / Extra High. Actual runtime
model/effort and token/cost measurements were unavailable. No further agents were
spawned and no CLI memory was updated in this bounded repair thread.
