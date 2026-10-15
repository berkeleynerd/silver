# Repairs from review-343c2f8

Authorized on 2026-10-15 by the owner's instruction to fix the selected findings
before further feature work. Baseline is `39d0ad38e6`, including the published
[review of e2c4fc2..343c2f8](reviews/review-343c2f8.md) and the later owner decisions.
The implementation branch is `fix/review-343c2f8`. This record distinguishes
repairs to the admitted language from the unfinished loop/integer implementation.

## Scope and order

1. **Report capacity and placement:** B1/#17, L2/#19 and L4/#21. Derive capacity
   from report format and admitted source bounds, move the report buffer off
   Compile's stack, verify readers and report policies, add a format-based
   regression, and correct claims based only on measured specimens. Include a
   review of the eventual scalar/Image checks before that feature is admitted.
2. **Automatic proof policy:** L1/#18 and L3/#20. State and pass the effective
   prover memory allowance explicitly, pin actual options and effective limits,
   and retain a real 64-leaf compilation regression.
3. **Lexical regression and catalogue agreement:** L6/#23 and L7/#24. Add the
   missing rejected bracket-literal cases and admitted siblings, verify their
   native meaning, and align the catalogue producer and checked-in catalogue.
4. **Scope, planning and Rosetta:** L8/#25, L9/#26, L10/#27 and L11/#28. Apply the
   settled Integer `'Image` scope to the plan and motivating sample, correct the
   Colour bars assessment and SPARK rubric, make rendering deterministic, and
   synchronize reachable issue links and board status with authorization.

Independent repair streams may proceed together; no language-feature work
precedes completion of the repairs. Existing issue scopes supply completion
criteria. Review suggestions outside this list remain separately tracked.
No new construct is marked supported by this task.

## Validation and delivery

Implementation and evidence are pending. Each stream uses focused native tests
and proof checks appropriate to its changes. Once the integrated source is
stable, run the required native Linux proof/build/test and Lean correspondence
checks without changing captured inputs. Preserve successful caches and the
review's retained evidence. macOS validation remains independent and nonblocking;
no hosted CI or independent kernel replay is claimed.

Record findings, fixes, actual input commits, checks and limitations here and on
the affected issues. Complete issue closure only after validation and publication.

## Report-capacity correction

L2 corrects the earlier inference from the Larger Expressions argument-shell
specimen. Its 2,065,005-byte report left 32,147 bytes (1.5%) in the historical
2 MiB buffer; its deterministic floor is 2,060,006 bytes and timing-dependent
credits contribute 4,999 bytes. It was produced by a separate runner using the
production options and policy, rather than by `silver compile` itself.

The review's denser static-shell construction with one output call measured
2,091,011–2,091,380 bytes across five proofs: 5,772–6,141 bytes (0.28–0.29%) of
headroom. Timing-dependent prover credits can exceed that margin. The review's
2,370,822-byte maximum concerns this construction, not all admitted programs.
Those retained inputs are the current capacity reference pending B1's derived
bound. The review observed the near-limit reports and credit growth, not an
overflowing dense execution. No new dense proof run is claimed by this correction.

## Lexical and catalogue repair evidence

L6 adds the missing elsif/final-bracket-with-escaped-quote neighbours and rejects
GNAT's encoded-character spelling `"["41"]"` in initializer, output and comparison
positions. Admitted quoted siblings retain ordinary Silver byte values. L7 now
states the exact final-decoded-character condition in the native catalogue
producer and checked-in JSON, with an assertion that pins the normative wording.

Focused Linux x86_64 validation passed: native build; three bracket regression
methods including real proof/build/exact-byte execution; and the native catalogue
comparison/assertion. Logs are in the repair worktree's `tmp/lexical-build.log`,
`tmp/bracket-tests-final.log` and `tmp/catalogue-test.log`. A first test invocation
used unsupported unittest-discover positional selectors and was corrected; its
mixed redirected log is not used as successful evidence. No admission rule or
Lean source interpretation changed. Full integrated validation remains pending.
