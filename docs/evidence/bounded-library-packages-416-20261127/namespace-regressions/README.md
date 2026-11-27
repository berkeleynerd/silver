# Application package namespace regressions — 2026-11-27

Linux x86-64, selected GPT-6 Astra Max; live runtime model/effort are not
independently exposed. This packet checks the two native admission defects
from the independent review of PR #424, within authorized issue #416.
It does not establish complete native, Lean or application assurance.

The identity rule follows Ada 2022 A.1 and 8.3: a library unit cannot be a
homograph of a declaration directly in Standard. Pinned GNAT's `gcc -gnat2022
-gnatS` representation identifies its implementation-defined numeric type
names. Ada A.1(36.3/2) supplies ASCII, which this compiler representation
omits. Ada 3.5.2 excludes character image labels such as Nul from identifier
declarations. Operator symbols and character literals cannot be admitted
simple package identifiers. The result is the explicit 28-name set in the
retained source and tests; Standard itself is permitted.

| Managed run | Result |
| --- | --- |
| `20261127T182448-e2480b117eee` | Pinned Standard representation captured. |
| `20261127T182754-2710eb0b0d02` | Initial inline Name_Is predicate in Operation_After failed native compilation with a missing-return diagnostic. |
| `20261127T182833-470be207c663` | Naming that same predicate Package_Hides in the declare expression built the actual admission harness successfully. |
| `20261127T182900-13ef5d868f3d` | All 84 original-unit cases agree with the expected analyzer and pinned frontend outcomes. |

The 84 cases cover all 28 excluded Standard identifiers in two case spellings,
Standard and Nul as legal identities, all five runtime operation names in two
case spellings with bare and qualified calls, and six root/universal-type
metanames that are not directly named Standard declarations. The runtime
operation fixtures exercise the shared Operation_After boundary, including
the direct argument initializer path. The 78 cases defined by the three new
regression methods were collected from those methods; the harness invokes
actual `Pack`, `Analyze` and `Imported_Package` on their exact source bytes.
This is an analyzer/frontend check, not execution of the complete Python
regression suite against a newly built command-line driver.

The frontend uses pinned `gnatmake -c -u -gnat2022 -gnata -gnato -gnatdM`
on each original Main and its selected specification. It neither links nor
proves these programs. Every negative Standard case fails on its package
identity; every bare runtime collision is rejected, and the qualified control
passes. Actual frontend commands, diagnostics and admission output are in
results.json.gz. The managed execution reserved two workers, inherited guest
CPU affinity 0–1, and used a 16 MiB stack. All runs used at most two workers.
Two earlier invocation failures (declared-input path and tool working-directory
path) are retained separately and are not source-check results.

The compressed input archive retains every original fixture, the generated
actual-source admission harness, its build project and the comparison script.
Its absolute paths identify the original worktrees; relocate those paths to
replay it elsewhere. The manifest binds the relevant native and regression
source snapshots. Logs and ledger events retain exact commands, tool identities,
input hashes and outcomes. No accepted input domain, contract or proof
obligation was weakened by this repair. Focused whole-helper contracts and
complete final assurance remain separate required checks.
