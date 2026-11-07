# Final Boolean-array regressions

Native Linux x86-64 evidence for #297. Original snapshot: `b63e81aa98c5cf02357a3fdf1dedd47e1a3f9613`, installed at `tmp/image-case-repair`. Final fixture snapshot: `9d9c786dceac6160c6fff521ed273fddfdfa628b`, carrying root fixture correction `689aef86bf`. Prior branches, caches and scratch were preserved.

| Check | Managed run | Result |
| --- | --- | --- |
| Actual native build | `20261106T230245-a19eaca75889` | Passed; 20.633537 s managed |
| Original full suite | `20261106T230401-5dde322e2782` | Failed; 612 executions, 602 passes, eight skips, one error, one failure; 5398.383089 s managed / 5394.101 s unittest |
| Corrected catalogue assertion | `20261107T003941-d065e68c8b90` | Passed, one test; 5.860265 s managed / 0.043 s unittest |
| Lean evidence/module fixtures | `20261107T004018-4c44e5aa8153` | All 55 passed, zero skips/failures; 920.540377 s managed / 915.669 s unittest |
| Full manifest fixture rerun | `20261107T005845-c136b4eb6271` | Passed, all 61 sources / 117 execution cases; 1026.747413 s managed / 1021.976 s unittest |
| Retained native certificate fixture | `20261106T225857-e507df7ab57e` | Successful 16-test root run includes explicit native certificate fixture pass; 98.101159 s managed / 93.985 s unittest; reuse proposed for independent applicability review |

The original failed run remains failed. Its 612 executions represent 603 distinct source methods and nine imported SharedBindings duplicate executions. Its eight skipped native Lean controls now have seven fresh passes in the 55-test selection and the eighth in retained root certificate evidence. The maximum dynamic-expression test passed both execution cases in the original run and was not repeated.

The original manifest fixture exercised 61 sources: 60 completed all 116 argument cases; `rosetta_shell_one_liner.adb` timed out during compilation at the unchanged 120-second fixture deadline, leaving its one execution case uncovered. Available host RAM fell as low as 212 MiB during concurrent proof pressure. This records correlation, not a source-defect conclusion or proven cause. The complete manifest-only rerun passed with unchanged timeout and proof options; its lowest observed available RAM was 11983 MiB. The failed workspace archive and orphan inspection remain retained.

The original catalogue failure was a stale expectation: the binary catalogue exactly equals checked-in JSON, whose text says “Integer-array components.” Root corrected two expectation literals in `tests/test_silver.py`; the targeted test passed. All other 8,685 captured files remain byte-identical, and the current tracked input path set equals the captured 8,686-file set. Binary SHA-256 remains `c3f97c7f6477931ad01c76c3be658db06fc4c02f997a6475f921eee9a5362790`. See `final-input-correspondence.json` for exact old/final fixture hashes.

Retained certificate reuse compares 802 selected source/script/proof/fixture/project hashes against the original snapshot. The broad managed input maps include `tests/test_silver.py`, which is outside those 802; the reuse record explicitly identifies its two-string final delta and the selected fixture's direct imports. Whole final input-map equality is not claimed. Final composition requires independent inventory and applicability review.

Exact test identities, all original 612 outcomes, full managed input maps/events/logs, tracebacks, skips, tool identities, failed workspace/source hashes, and affinity/resource histories are retained here. Native application children inherited CPU affinity 8–11 after the runner reserved four workers with normal 12-CPU visibility; observed descendants retained that mask. Bulky originals are gzip-compressed. `artifact-sha256.json` covers every other artifact in this directory.

No complete language/source assurance or support claim follows from these regression results. Root retains the independent final review, complete native/Lean assurance, metadata validation and publication work.

Agent model/effort: inherited lead settings; runtime identity was not exposed in this subthread. Token/cost evidence unavailable. Durations above describe managed native execution, not whole-team cost. Follow-ups closed the two original regression failures and covered the skipped fixture controls without repeating the expensive dynamic-expression success; retained certificate applicability remains an independent review obligation.
