# Callable words in the catalogue (#372)

The catalogue's `word_tokens` omitted `function`, `return` and `out` even though
the callable construct descriptions use those words. The existing
`Silver_Catalogue.Export_Tokens` enumeration now emits all three. The generated
JSON changes only `word_tokens`, from 45 to 48 distinct entries. The existing
catalogue equality and exact word-inventory test now requires these words.

This bounded repair was authorized by the lead after the isolated capacity check
completed. It was implemented on base
`279c0f368cdfe7c98be81559d1e44aa979fc6cd8`, branch
`fix/catalogue-callable-words-372`, in
`tmp/scalar-procedures-capacity-native-370`. No helper, contract, admission rule,
output-profile declaration or Lean proof changed. The lead owns integration and
the complete #29/#370 assurance checkpoint; these focused results do not establish
scalar-procedure acceptance.

## Native Linux validation

All three managed runs used the explicitly allocated two-worker share, ran
serially, and completed with actual tool/test exit code 0. The host was
`linux-x86_64`. The tools were GNATprove 16.1.0, GPRbuild 26.0.0, CVC5 1.3.2,
Z3 4.15.4 and Alt-Ergo 2.6.1; exact binaries/configuration are recorded in the
retained ledger events.

| Check | Managed run | Result | Managed elapsed |
| --- | --- | --- | --- |
| Compiler build | `20261110T083150-27abbcf93bc9` | Passed | 17.979 s |
| Existing `test_catalogue_is_json` | `20261110T083248-2bd9d1eb953c` | Passed; one test, 0.170 s test time | 4.085 s |
| Whole `silver_catalogue.adb`, flow and proof | `20261110T083333-03d6f4b959c1` | 27 proof + 6 flow checks proved | 145.628 s |

The proof used `--mode=all --report=all --warnings=error --checks-as-errors=on
--level=2 --prover=cvc5,z3,altergo --steps=100000 --timeout=0 --memlimit=1000`,
unit selection `-u silver_catalogue.adb`, and isolated output subdirectory
`explore/procedure-catalogue`. It covered all eight catalogue entities, including
the complete `Export_Tokens` and `Export` bodies. Retained `.spark` records show
18 range checks, three index checks and six precondition checks, all proved;
all six flow checks passed. There were no non-info diagnostics, skipped proof or
flow entries, or `pragma Assume` statements. Six informational loop-unrolling
diagnostics remain. This was a whole-unit check in a separate native workspace,
not a complete compiler proof or a cold-performance measurement.

After actual completion, all recorded build (2,595), test (1,294) and proof
(2,595) input hashes were compared with the worktree bytes: zero mismatches.
The test's retained input record includes the regenerated JSON, test source and
rebuilt executable. The final source diff was reviewed and `git diff --check`
passed.

## Retained evidence and exact inputs

The shared checkout retains the exact events, native logs, `.spark`, SARIF and
GNATprove summary, changed input bytes, generated native configuration, patch,
per-file hashes and a derived result record in:

`tmp/procedure-native-entry-inventory/catalogue-372/evidence.tar.gz`

Archive SHA-256:
`b7baa21c688d590b10107fe7d41ef895eba59594982f4acdf025fd96f57f58b8`.
The adjacent `result.json` records the actual commands, phase exit codes,
timestamps, managed durations and input comparisons. This is retained local
evidence, not a replacement for the complete assurance manifest.

| Changed file | SHA-256 |
| --- | --- |
| `src/silver_catalogue.adb` | `0a89693a789c19a30c6c8b8abf72d4531c60f6012afeb918022b9569ec20f932` |
| `tests/test_silver.py` | `eb1aaa31aa61f02676531443c2a3006e6199699983d98c5aa58f2dd856084304` |
| `catalogue/silver.json` | `f8b3348555ea1d13f486836ae62b313248fe0833fe705e6c03a96228ac5a48ab` |

The inherited review assignment selected GPT-6 Astra / Max; live model and effort
were not independently exposed. This round delivered the bounded correction and
focused evidence without proof rework. Native durations are listed above; total
agent elapsed time, tokens and cost are unavailable. No CLI memory update or
GitHub write was made by this subthread.
