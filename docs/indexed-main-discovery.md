# Indexed Main discovery repair

2026-10-18, [#123](https://github.com/berkeleynerd/silver/issues/123).

The generated project now selects its known Main explicitly:

```gpr
package Naming is
   for Body ("Main") use "main.adb" at 1;
end Naming;
```

Silver already admits exactly one library-level Main, so index 1 selects the
first and only compilation unit. The author source, source snapshots, admitted
language and selected tool releases are unchanged. The naming declaration applies
only to Main; the fixed runtime sources retain their ordinary naming.

The [discovery record](research/cr-comment-gpr2.md) and its offline-checkable
evidence preserve the CR failure, LF control, source route and candidate
proof/build/run. GPR2's indexed naming-exception path bypasses its basic Ada
reader, which otherwise consumes CR-terminated comments through the next LF.
Ordinary unindexed explicit naming still invokes that reader and retains wrong
unit metadata, so it is insufficient. Native GPRbuild's separate subunit scanner
recognizes CR and stops at `procedure`. This is a configuration repair, not
a modification of either external tool.

## Artifact and assurance effects

| Item | Selected identity |
| --- | --- |
| Author snapshot and JSON source locations | `main.adb` |
| Main entity | `Main`, with Ada's case-insensitive name meaning |
| Main report and ALI artifacts | `main~1.spark`, `main~1.ali` |
| GNATprove text coverage-summary unit | `main~1` |
| Main Image model | `main.gnat-json` |
| Data-representation JSON | `main.adb.json` |
| Native executable | `bin/main` |

The SPARK driver reads only the exact indexed report path. The Python evidence
auditor takes an explicit `indexed_main=True` for generated applications and
requires the matching artifact inventory and summary name, then audits entities,
source locations and dependencies using logical `main`. No alternate filename
is accepted when the selected report is absent. Compiler audits and generic
unindexed fixtures retain their existing policy. Production tests and external
tool fixtures select the indexed paths explicitly.

The retained producer source creates `.spark`'s filename separately from the
JSON fields (`gnat2why-driver.adb:350–382`); its Image filename uses the entity's
full name (`:316–345,600–604`). Index selection introduces no declaration,
expression, executable action, proof site or reported entity. It changes neither
the diagnostic source spelling nor the JSON schema. Consequently the existing
[report envelope](bounded-mutable-report-capacity.md), including its fixed
metadata allowance, remains applicable; neither its bound nor an acceptance
policy is enlarged. Native observations exercise that route but are not the
universal report-size argument.

The candidate phase1 adds the eight-byte compiler switch `-gnateI1`: nine stored
A records with total payload 53 and longest payload 9. Main and System remain
the two D dependencies. The historical unindexed producer descriptor remains
evidence for its own configuration. Research #119 must use the indexed project,
switches and artifact names in its final capacity conjunction; that research is
still incomplete.

`silver.adb` is not one of the embedded Ada sources in
`proof/generate_source_certificate.py::SOURCE_BINDINGS`. No existing Lean pin or
semantic model encodes this project text, so there is no pin-only refresh or
new whole-CLI correspondence claim. Native SPARK verification covers the changed
driver; the existing source/model proof tree receives the required complete
cached build and fresh audit at the stable checkpoint. The
[assurance boundary](assurance.md) continues to distinguish those arguments.

## Validation

The implementation worktree is `tmp/indexed-main-discovery` on Linux x86-64,
bootstrapped at its own path with the unchanged Alire-selected releases.
Focused checks:

- Build `20261018T085358-871d98dedac3` passed.
- Evidence audit suite `20261018T085504-1ebe6ccb2efd`: 54 tests passed, including
  exact indexed report/summary identity and stale/unexpected artifact rejection.
- Native regression `20261018T085521-08d5afa2ae98`: five program cases passed,
  covering the original CR witness, LF control, all-CR mixed trivia/case,
  static Image with mutable Integer/String loop assignments, and argument input.
  Both `compile` and `run` preserve the author bytes and build runnable `bin/main`.

The initial native regression `20261018T085416-3be1b006b1a5` proved and built all
five programs, then failed in the Python coverage-summary audit: the text summary
uses `main~1`. The auditor was corrected to map that exact selected name as well
as the report path; the successful run above covers the correction. Those
development artifacts remain retained.

The stable implementation and review target is `ce4d2fee36`. The complete
checkpoint uses that commit's actual source, scripts, proof and test trees in
every validation lane; final evidence/documentation edits do not change them.

| Check | Actual workspace and result |
| --- | --- |
| Complete native audit `20261018T085735-f1f2c112a63d` | `tmp/bounded-mutable-integers-native`, 4 workers, 315.614 s: 75 units, 1,000 entities, 1,295 flow checks and 13,860 proof checks (15,155 total); complete report/provenance audit passed. Original-path sessions and solver cache were retained. |
| Complete cached Lean `20261018T085735-f1237f05d1fa` | `tmp/review-b79-b1-lean`, 4 Lake workers and 4 threads per process, 35.541 s: 466 modules and 89,369 declarations; fresh audit passed with only `propext`, `Classical.choice` and `Quot.sound`. `--provenance` records shared, workspace and compiled-object hashes. |
| Full suite `20261018T085735-b252c88fe515` | `tmp/indexed-main-discovery`, 4 reserved workers, 473 methods in 1,399.748 s: 466 passed, 7 skipped because this fresh native installation has no Lean executable. All seven tool-dependent methods passed in the identical frozen Lean lane in the two runs below. |
| Native Lean module/certificate tests `20261018T090210-375df9aed269` | The same frozen Lean lane: all 3 methods passed in 82.655 s. |
| Native Lean evidence tests `20261018T090350-32ee26af82c4` | The same frozen Lean lane: all 4 methods passed in 173.087 s. |

The native lane began at `1023037fcb` with three prior tracked modifications.
Their exact bytes already matched the stable implementation. Its HEAD, status,
binary diff and those three files were copied to
`/tmp/silver-indexed-main-validation-20261018` before switching to the frozen
commit; the post-switch bytes were checked equal. The Lean lane began at
`de693e8822` without tracked modifications. Both lanes retain their existing
installation paths, caches and untracked `tmp/` material.

The [portable evidence packet](evidence/indexed-main-20261018/README.md) retains
the native and Lean manifests, focused native witnesses and test logs. Its
offline checker verifies the retained file hashes and checks all 141 shared native
inputs, 581 shared Lean inputs and 680 full-suite source/test/proof inputs
against the implementation. The manifests
retain installation-specific generated inputs separately. This is a complete
cached checkpoint, not a clean rebuild or independent kernel replay. No native
macOS or hosted CI run is claimed.

Independent source review of `ce4d2fee36` covered the driver, exact report and
summary mapping, production fixtures, source-preserving regressions and the
assurance/trust record; no remaining material finding was identified. The
language and catalogue need no amendment because no membership rule changed.
Repairing #123 does not complete capacity research #119 or authorize a wider
admitted domain by itself.
