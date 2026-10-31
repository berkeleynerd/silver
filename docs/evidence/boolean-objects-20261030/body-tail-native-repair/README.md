# Body_Tail return assertions — 2026-10-31

The later [complete native run](../full-native/README.md) passed on this repair;
the focused-round account below preserves the evidence available at that point.

For [#291](https://github.com/berkeleynerd/silver/issues/291), three checked
`Static` assertions now state the exact original output/model equality before
each unchanged return in `Body_Tail`. This decomposes the previously merged
postcondition. Executable statements, contracts, models, admitted input domains
and production solver limits are unchanged.

The prior complete run
[`20261030T214853-f14ff090b11a`](../full-native-failed-214853/README.md)
proved 17,224 of 17,225 checks. Its sole failure was the merged Static
`Body_Tail` postcondition at `silver_output_profile.adb:4003:20`, under the
original 30-second timeout and 1000 MiB prover memory limit. It did not produce
a counterexample or complete native assurance. The two Boolean reader repairs
passed in that full run.

## Focused result

Native Linux x86-64 managed run `20261031T021634-ccc87594f70c` selected the complete
`Body_Tail` subprogram at specification line 3995. It passed **74 checks: 3 flow
and 71 proof**, with no warnings, errors, unproved checks or `Assume` statements,
in **372.166857 seconds**. All 421 Why3 goal nodes are marked proved.

| Obligation | Source location | Successful reported prover and time |
| --- | --- | --- |
| Invalid result inside the loop equals the original model | `4042:29` | CVC5, 5.582 s |
| Invalid result after the loop equals the original model | `4060:26` | Z3, 0.407 s |
| Normal result equals the original model | `4072:23` | Z3, 0.603 s |
| Original combined postcondition | Reported at contract start `4001:28` | All five primitive goals proved; maximum selected proof time 4.403 s |

The diagnostic found no failing return assertion. Its result supports retaining
these assertions as the bounded proof repair; it does not identify one return
as uniquely responsible for the earlier merged failure. All three assertions
are proved obligations themselves. The downstream postcondition is not being
claimed independently of their discharge.

The effective command retained four native workers and:

```text
--mode=all --report=all --warnings=error --checks-as-errors=on
--level=2 --timeout=30 --prover=cvc5,z3,altergo
```

It used the existing exploratory cache and a separate
`explore/boolean-body-tail-return-cuts` output directory. The original 1000 MiB
prover memory limit was unchanged. The exact launch is in
[`return-cuts/launch.json`](return-cuts/launch.json).

## Inputs and retention

Candidate `src/silver_output_profile.adb` SHA-256:
`bb3bd71eb53e7f0637ed27ac4b5eb7c283b66dc0fb81131ebe73543c3950d01f`.
Its baseline is source `88b54a1d` from native repair commit `598a56b969` and
integration commit `87dd912436`.

The terminal retainer verified all **2,561 captured input hashes** and the exact
candidate source. A separate comparison verified that the other **142 of 143
tracked native inputs** match both baseline commits. Both original source
backups and all seven unrelated dirty/untracked files outside `tmp/` remain
unchanged by hash and mode. Nothing has been restored or handed to regressions.

The compact packet retains the source, run journal/log, complete focused report,
SPARK report, Why3 session and shapes. All eight compressed artifacts, including
the large local task file, were independently decompressed and rehashed. See
[`return-cuts/verification.json`](return-cuts/verification.json) and
[`return-cuts/assessment.json`](return-cuts/assessment.json). The helper's local
task directory is named `supplemental-failed-task`; that historical helper label
does not describe this successful run's outcome.

This is focused native evidence, not a complete native assurance manifest.
Complete native proof/audit, matching build and final source/pin/certificate
correspondence remain required on stable bytes. The lead owns integration and
the independent source-correspondence review. The current Lean checkpoint stays
on its earlier frozen inputs; no experimental source was copied into it.

## Round record

The native subthread's selected setting is GPT-6 Astra / Extra High; runtime
confirmation and token/cost measurements are unavailable. The intended outcome
was to identify a failing return before proposing a broader repair. The achieved
result is complete focused discharge with three local checked assertions and
unchanged solver policy. Managed native run wall time is reported above; it is not a
whole-team cost measurement. No further proof run was launched in this round.
