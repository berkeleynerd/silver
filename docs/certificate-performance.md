# Bounded source-certificate investigation

On 2026-10-09, the authorized investigation tested two reconstruction approaches
and found **no validated improvement**. Retain the existing implementation and
stop this investigation. No candidate proof, generator or test changes are
adopted. The separate guarded-greeting capability continues under its own
assurance and validation requirements.

## Scope and measurement

The actual host was Linux ARM64 with 12 CPUs and approximately 12 GiB RAM,
without swap. The pinned tool was Lean 4.34.1. Fixed authoritative Ada bytes
were those of the five-production implementation `a73f85e`; the recorded
baseline snapshot was `fee3afe`, followed by documentation-only authorization
commit `653fe52`. The ten embedded source files remained byte-identical during
these measurements. Concurrent report-policy changes were excluded from the
prepared performance-only validation snapshot.

Each dominant trial directly rebuilt `Silver.OutputBodyCertificate`, whose
authoritative Ada input was 42,994 bytes. Trials used isolated workspaces, CPU 0,
one Lean thread, a 3,300-second limit, `-M4096`, warning-as-error and profiling.
`-M4096` is Lean's allocation limit; it is **not** a total-process RSS limit.
The other modules' existing objects were retained as dependencies. This measures
a forced certificate rebuild, not a clean whole-project build.

| Trial | Observed duration | Peak child RSS (KiB) | Outcome |
| --- | ---: | ---: | --- |
| Existing reconstruction | 3,115.75 s | 4,747,104 | Exit 1: repeated kernel memory-limit errors |
| Candidate 1: structural character lists | 193.69 s | 4,195,104 | Exit 1: kernel memory-limit error at final source equality |
| Candidate 2: decode authoritative string | 323.68 s | 8,591,200 | Exit 143: explicitly interrupted for host memory safety |

These are failed or interrupted trials, **not successful replay timings**.
They establish no speedup ratio. Candidate 2 had no reported Lean memory error
when interrupted: its rising RSS triggered the explicit host safeguard at about
8 GiB RSS, before exhausting the VM. The safeguard was distinct from the original
Lean allocation limit. No larger-limit retry or third approach was attempted.

## Approaches and assurance

The existing balanced reconstruction stores whole strings at internal nodes.
Candidate 1 instead carries exact character lists, checks small leaf conversions,
and combines lists through a proved generic join theorem. Its final equality
still reduces a whole-file `String.ofList`, which exceeded the trial limit.

Candidate 2 keeps that structural representation and checks equality against
the authoritative string's decoded characters. A generic theorem derives exact
string equality through `congrArg String.ofList` and `String.ofList_toList`.
Its helper checked, but the dominant certificate did not complete before the
host-memory interruption.

Independent inspection found no weakening in either approach's equality
argument. All ten candidates retained byte-identical per-line text, tokens,
lexing proofs and newline checks. That review and those identity checks do not
substitute for a successful complete certificate or kernel replay.

Across all ten generated modules, source size fell from 4,696,064 bytes to
1,329,843 bytes for candidate 2; the dominant module fell from 3,225,133 to
821,851 bytes. Smaller generated source did not establish acceptable checking
cost. No successful candidate object-size comparison is claimed: copied cached
objects in experiment directories may still belong to the baseline.

Because neither candidate passed the bounded trial, their prepared mutation,
cache and full-replay checks were not run to support adoption. There are no new
successful full-replay phase timings or warm-cache measurements from this
investigation. Existing cache behavior and earlier full evidence remain as
recorded in [the greeting evidence](greeting.md); normal caches and all other
hosts' state were preserved. Retaining unchanged proof code does not require
claiming that the failed experiments passed its checks.

## Evidence and follow-up

Native experiment state is retained under
`.silver/linux-aarch64/certificate-performance/`, including:

- `baseline-inputs.json`, `tools.json`, and `before-measurements.json` for
  captured source, tool, generated-source and prior-object identities.
- `baseline-output-certificate.{log,json}` and
  `candidate1-output-certificate.{log,json}` for completed failed trials.
- `candidate2-output-certificate.{log,json}` and
  `candidate2-resource-interruption.json` for the explicitly interrupted trial.
- `candidate2-line-identity.json`, `candidate2-frozen-source-identity.json`,
  and `candidate2-review.json` for the scoped identity checks and review.
- Candidate workspaces, the unused `validation-repo` directory snapshot and
  `resume-checkpoint.json`. These are experimental artifacts, not adopted code.

Older logs also remain: an initial run interrupted by a sandbox restart, an
intentionally stopped run of the wrong smaller module, and a candidate-2 helper
elaboration failure subsequently corrected. None is counted as a completed
dominant benchmark. No process remains running from this investigation.

The former 60-minute CI Lean budget has no demonstrated headroom; hosted CI has
never run. A failed 52-minute local certificate trial cannot certify capacity for
a clean whole-project CI run. Use a conservative 120-minute job allowance,
subject to reassessment from the final feature replay and first hosted run.
That allowance is a workflow budget, not a measured speedup or a language
acceptance threshold. The bounded investigation is closed; further reconstruction
redesign requires a separately authorized task.
