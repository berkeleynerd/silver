# Recovered PR #403 regression applicability review — 2026-11-20

**Accepted: the complete 724-ID final regression inventory is covered by 722 retained Linux ARM passes and two fresh Linux x86-64 passes. No full-suite fallback or repetition of passing affected modules is required.** This review covers regression applicability, samples and Rosetta accounting. Complete native/Lean/source audits and closing delivery review remain separately owned.

Reviewed target: PR #403 / issue #400, commit `001c50dce1bcf3ad2d174b4426f684fe78cb2e64`, tree `77b0d2c24ebc37a69fcca2edabf5ddd93aee391a`, based on main `a03c7987bbba29569db2709820bd26ced20bed40`. All comparisons were read-only; this reviewer started no native tests, proof jobs or GitHub writes. The lead ran the two fresh x86 tests, whose original records were then independently checked here.

## Input and execution correspondence

The recovery collector scripts were read before using their results. Independent scripts `verify-recovered-regressions.py` and `verify-x86-regression-composition.py` recompute the hashes, identities and outcomes directly from recovered raw files. Detailed results are `recovered-regression-verification.json` and `x86-regression-composition.json`.

- The four original managed test runs have identical prepared maps of **1,348 inputs**. All **1,340 repository hashes** match PR Git blobs. All **8 support hashes** match recovered bytes: ARM compiler, three generated Ada files, three Alire context files and original ARM Python. Compiler SHA-256: `ab4a751b3b49733b14af62e37508ef7d299ffabb1e2433cc7725f21c5e8e2992`.
- The recovered checked commit self-hashes to `7d5967240779a46f73d1c29746d77e530f81f906`, with the PR tree and main parent above. Its original reflog enters that commit before testing and restores compiler build head `9b5b2d99aaf6f4bfca5226b36af744502b095990` afterward. Independent comparison finds unchanged compiler/runtime/proof/scripts/build/catalogue/Oracle inputs between that build head and the PR.
- Each original workflow log equals its managed `native.log` after the managed-run banner. Original `results.tsv` records exit **0** for all three focused runs, render and suite. Each event stream records test-phase exit **0** and final outcome **success**. The final event's `returncode: null` is the context manager's normal successful `finish()` default; it is preserved as null rather than relabelled zero.
- Matching runner source enforces selected-input hash stability after tests. The separately retained contemporaneous criteria output additionally reports **1,340 matched, no absent or mismatched repository inputs**. The collector copied that output verbatim from the criteria transcript, whose member hash and line are recorded. This is distinct from the new recovery-time comparison. No separate managed postflight-map file was emitted, and none is needed to replace this ordinary evidence chain.

## Complete inventory and outcomes

Fresh discovery at the PR finds **724 distinct unittest IDs**, including the existing imported shared-binding bodies under their separate discovery IDs. The original full log has exactly that same ID set. Every successful test has a terminal `ok`, including interleaved/multiline output.

| Run | Original outcome | Unittest seconds | Managed seconds |
| --- | --- | ---: | ---: |
| `20261118T173513-f3c45b223d1e` | String/Character: 18 passed | 22.123 | 22.424669344 |
| `20261118T173536-c2d8662ad230` | Samples: 2 passed | 230.875 | 231.147969152 |
| `20261118T173927-90b8193aa993` | Rosetta: 12 passed | 2.466 | 2.788850585 |
| `20261118T173931-305d1781f71e` | Full suite: 722 passed, 2 ARM-specific skips | 1128.481 | 1128.900073705 |
| `20261120T125015-03ea0dfd16e0` | The two skipped IDs: 2 passed on x86 | 3.816 | 4.748639677 |

The original suite's raw trailer is `Ran 724 tests in 1128.481s`, `OK (skipped=2)`, with no failures/errors. Log SHA-256: `304837c29f3dd304cb7a9f97dc9d7081dbd9e7dab7c79ec6140fe4021b63c29c`. Correct the historical 712/710 headline to **724 tests / 722 passes / 2 skips**. The subtotal consists of 706 single-line passes, four two-line docstring passes and two skips. Twelve further headers have printed output before standalone `ok`; all pass. Their exact IDs are in `parser_missed_ids` in the detailed verification JSON. The original parser implementation was not transferred, but the raw output shape reconciles the count exactly.

The fresh x86 run covers precisely the two formerly skipped IDs:

- `test_counted_bound_review.CountedBoundReviewTests.test_maximal_nested_loops_keep_filter_scratch_out_of_frames`
- `test_output_integrity.OutputIntegrityTests.test_large_argument_vector_with_eight_mib_stack`

It used the exact PR private checkout, with all **1,340 repository hashes matching the PR and retained ARM map** and all **8 current support files matching their captured hashes**. Original launcher/phase exits are 0; managed outcome is success. The x86 native-log SHA-256 is `de76b5b383b9affcfff75c7291d51cc09c78f9935f5af8a75c812ccdcfa16219`. The second test uses a real fixture compiler with mocked external tool/report effects; neither test replaces complete native proof or application assurance.

Thus **722 retained ARM successes + 2 fresh x86 successes = all 724 final IDs**. The passing manifest runner covers all **90 programs / 153 execution cases**, including the four new samples. No failed, missing or affected final-input regression remains uncovered. A later independent external review may run its own suite, recorded separately.

## Samples, Rosetta and historical limitations

Independent accounting confirms **86→90 programs**, **149→153 cases**, unchanged prior manifest entries, exactly four new mappings (**85→89 Stage 1 tasks**), twelve assessment changes and only four surface-list changes. All **27** focused packet hashes match final bytes. The retained archive has ten successful full routes and five expected admission refusals; successful complete streams match expectations, with empty stderr. Four sample outputs were independently derived, including the full 495-line/11,357-byte bottles output.

Pure rendering reproduces every changed generated task page and progression byte-for-byte: **472 changed pages = 12 assessment-content changes + 460 position-only changes**. Append/prepend/bottles move 4→1 and repeat 10→1; all **63 existing construct stages remain unchanged**. Broad `string-building` remains unsupported. Live stage/#395/#400 bookkeeping remains the expressly deferred post-merge work.

Original tests ran on Linux aarch64 `silver-m4pro`, with **12 available CPUs / 12 managed workers**. Their invoking stack, child thread allocations and cache-hit counts are **unrecorded**. This is an honest historical settings limitation, not evidence that the stack was wrong or that successful tests failed. The new x86 result does not reconstruct ARM stack settings.

Fresh x86 settings were measured: Linux x86-64 `silver`, **22 CPUs / 22 managed workers**, invoking stack **8 MiB soft / unlimited hard**; both selected tests explicitly set their tested child stacks to 8 MiB. Evidence: `x86-skipped-tests/launcher.json`, launcher log and the managed event stream. Test start/finish: **2026-11-20 12:50:15.590985–12:50:20.339708 UTC**.

The four original managed tests span **2026-11-18 17:35:13.835719–17:58:20.146428 UTC**, a wall window of **23 min 6.310709 s**; managed durations sum to **1,385.261562786 s**. Render exited 0 and left empty status, without its own duration. One complete regression attempt and three focused attempts are recovered, all successful. The earlier ten try full routes/five expected refusals are additional focused observations. The collector found no failed/interrupted #400 test run; the selected packet does not establish every earlier workflow launch. `develop-check-failed.md` is byte-identical to the successful check report and is not a second failed test run.

Authorization-to-PR-commit wall span is **19:23:01** (2026-11-18 17:14:53 to 2026-11-19 12:37:54 UTC), containing unmeasured waiting/review time. Record final delivery closeout separately, with host-transfer/wait intervals; active agent time, complete waiting time and token/cost totals are unavailable.

Selected settings in the published PR record: implementation **GPT-6.1 Sol / Extra High**, criteria review **GPT-6 Astra / Extra High**; tests are workflow scripts. This extraction was assigned **GPT-6.1 Sol / Extra High**. Live model/effort were not independently exposed by the retained records or this review interface. No broader model, assurance or runtime-performance claim is made.
