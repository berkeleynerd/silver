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
development artifacts remain retained. Complete checkpoint results will be
recorded here after the frozen implementation is validated.
