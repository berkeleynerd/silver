# Native library report policy — 2026-11-22

Canonical whole-unit run `20261122T144237-3583a335264c` passed all **3,999 checks**
(371 flow and 3,628 proof) across **268 owned entities** on Linux x86-64.
The final policy used four workers on CPUs 2–5 and took 4,183.193 seconds.
The private installation was bootstrapped from the pinned GNAT/GNATprove 16.1.0
toolchain; this reused the retained final-policy cache and was not a cold run.

The earlier complete helper check `20261122T143913-d90494b9e30f` passed 53 checks
after `8dea77baad` kept the quantified metadata predicates abstract at the policy
composition boundary. This final unit run also proves the formerly failing
`Audit_Normalized_Report` postcondition at line 5756. No source contract or input
domain was narrowed.

`raw-evidence.tar.gz` retains the exact managed events/log, raw unit report and
SARIF, source/scripts/project and generated input snapshot. `summary.json` records
the managed input identity and hashes the captured inputs. The source tree stayed
frozen throughout this run; the unrelated test fixture copy was not an input.

Projection/platform and complete native/Lean/source integration remain separate.
This packet does not claim the completed bounded-package capability.
