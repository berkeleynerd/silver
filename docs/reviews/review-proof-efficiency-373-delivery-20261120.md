# Independent delivery evidence review for #373

## Final delivery disposition, 2026-11-20

I accept the final evidence candidate `4fafe1592b6ba158ebe0b9fdb4204b6da94096b4` with the verified historical wording correction at `2b554549a075e9a801c874a71cc08c9f045c9d30`. The evidence supports the selected #373 package for delivery in PR #406. The independent implementation review targeted `f0a773fbcb`. The root ran final validation at `8836c38bac`, with identical runner, test, compiler and proof sources. All 757 regression IDs and the two real canonical focused checks accepted below remain applicable. #381 and #382 remain deferred, PR #385 remains held, and merge authority remains with the owner.

| Final Linux x86-64 check | Managed run | Result | Managed / wrapper seconds |
| --- | --- | --- | ---: |
| Build | `20261120T184456-c31fb2e1ef2e` | Both production binaries reported up to date | 2.436 / 3.196 |
| Complete Lean/source check | `20261120T184511-73f46c783731` | Fresh module and axiom audit covered 1,035 modules and 166,332 declarations | 26.069 / 26.960 |
| Forced complete native proof | `20261120T184557-91d29a88ed8f` | 78 units, 1,252 entities and 19,726 successful obligations | 47.260 / 48.245 |

All three commands exited successfully with 22 automatically granted workers and a recorded 16,384 KiB invoking stack. Lean also selected 22 process threads. The build and complete native proof captured identical preflight inventories. I matched every one of their 2,585 input hashes and 12 tool binary hashes to the validation checkout and matched its 148 tracked native inputs to the reviewed Git blobs. The fresh build invocation confirmed the selected executable paths, and the compiled binary hashes match the final archive. This closes the build condition for the independently reviewed use of 475 retained application-test passes. GPRbuild reused the existing binaries.

The native invocation forced all units under the canonical three-solver, 30-second policy. Its manifest records pre-existing sessions and a populated lock-keyed cache. The retained and working native evidence match, including all 80 hashes in the complete manifest and the SARIF command and successful termination. Reviewing the 78 SPARK reports reproduced 1,751 flow and 17,975 proof checks. All reached proof completion, and the skip and assumption lists were empty. The 80 spec-only entity entries are the 18 approved imported and 62 vendor entries classified by the complete source-bound auditor. These counts accompany the successful full audit.

The final Lean build used prepared Lake objects and took 4.840 seconds. The 7.126-second fresh audit reported the exact expected set of 1,035 distinct module markers and 166,332 declarations with only `propext`, `Classical.choice` and `Quot.sound`. The root and managed evidence/log records agree. I verified all 1,143 source-input hashes against the checked-out bytes and reviewed Git blobs, all 1,037 generated/workspace inputs, both selected Lean/Lake binary hashes and all 6,202 compiled artifact hashes. The 1,037 workspace and 6,202 compiled-artifact hashes also match the completed dense preparation. No cold rebuild or independent kernel replay was requested. Neither the focused chunk preparation nor the old-runner native evidence substitutes for either final audit.

I compared all final archive payloads with the original records, including the 1,152 source/setup and 1,037 workspace members, the 82 native report/manifest members, and the individual immutable managed/wrapper records. The archive manifest checks matched. The guidance addition at `e97257ac30` describes an observed use of existing focused targets and preserves the complete-check requirement. The elapsed preparation and final-check timings have different input, cache and concurrent-work scopes and do not measure a controlled speedup.

The preparation opener still described final audits as outstanding in the original evidence candidate. I confirmed the corrected Git blob links the successful final checkpoint at `2b554549a0`. The final build paragraph now identifies the matching preflight inventories precisely. The full-range whitespace check passed. All identified findings are resolved.

Selected GPT-6 Astra at Extra High. Runtime model, effort, tokens and costs were unavailable for independent confirmation. The reviewer used read-only record inspection and hashing and launched no build, solver, Lean or test command.

The final review interval was 2026-11-20 18:47:33–18:52:57 UTC (5 min 24 s wall). The earlier evidence review took 3 min 10 s. The interval between handoffs is separate.

## Initial evidence review at 16:17 UTC

Accepted the complete regression inventory and both real focused native checks at evidence revision `02b8ccf568`. The implementation and tests match the previously reviewed `f0a773fbcb`. At this earlier review, the complete native proof and provenance audit, current native build and complete Lean/source/module/axiom audits were outstanding. Their later results are reviewed above. The selected work is #377–380, #383 and #384. #381 and #382 remain deferred.

### Regression results

I independently paired every header in the two decompressed unittest logs with its own successful terminal result, including multiline output. The actual recorded sets agree with every row in `regression-accounting.json`. The fresh run `20261120T152415-e5e1f5ee6934` passed all 282 affected IDs. Its test phase exited 0, its managed result was success, and the log ends in OK with no skips. The #403 Linux x86-64 run `20261120T130632-15ab84282224` passed 724 distinct IDs. Of those, 249 also passed fresh and the remaining 475 retain the applicability established in the implementation review. All 33 added tests passed fresh. This accounts for exactly 757 unique tests. All 70 captured scripts/test hashes in the accounting match the `f0a773fbcb` Git blobs.

The fresh run used two requested/granted workers, with nine automatically available on the 22-CPU host and a 16,384 KiB invoking stack. The 1,193.641 s unittest interval and 1,196.143 s managed interval describe different measurement boundaries.

### Focused native producer evidence

I inspected each managed start, prepared input, actual command, phase exit and final event. I checked all 83 archived producer-file hashes against their inventories, inspected the selected SPARK records, matched the SARIF invocation to its command, and rechecked all 2,634 shared input hashes and all 12 named tool binary hashes in the focused integration installation. All 148 tracked prepared inputs match the `f0a773fbcb` Git blobs. The ordinary copied native installation was bootstrapped in the integration worktree. Both records use the canonical 30-second solver settings and their isolated focused cache. Three workers were requested and granted against eight automatically available, with the concurrent-workload reason retained.

- `20261120T161257-f32638bcdacc` checked `silver_numbers.ads:11`. The producer reports `Silver_Numbers.Decimal` as its sole fully covered selection, with two successful flow and six successful proof checks.
- `20261120T161351-6de9c718e3ad` checked the complete containing unit via `-u silver_numbers.adb`. The producer reports full coverage of `Silver_Numbers`, `Represents` and `Decimal`, with four successful flow and 14 successful proof checks.

Both runs report completed proof progress, no early stop, empty skip/assumption lists, literal effective argv and exit 0. The actual retained managed summaries identify final-policy scope and the same counts. The unit followed the subprogram in the same policy namespace. Their separate selected report snapshots remain available. The producer's diagnostic advisories have no unresolved VC result in these runs.

### Preparation and evidence consistency

The old-runner initial Lean journal ends in `phase_interrupted` at the recorded module boundary and has no successful terminal event. The later focused old-runner success built the six selected line chunks and its fresh audit counted 12 modules and 18,218 declarations with the three documented Lean foundations. The retained audit log's digest matches its evidence. Those results can support cache preparation only. I also verified the size and SHA-256 of all 58 entries in the three archive manifests.

The top regression and preparation packet openers at `a5b625e66a` described the real focused checks as still outstanding. Both were corrected at `5380b0267f`, which links the successful evidence and dates the preparation statement. Two raw setup snapshots caused a whitespace-check finding against their original extra final blank lines. Commit `02b8ccf568` stores them with gzip. I checked the archived and original SHA-256 values against the updated manifest, compared the decompressed 5,216- and 307-byte contents to the preceding Git blobs, and verified that `git diff --check a412827d6c..02b8ccf568` passes.

Selected GPT-6 Astra at Extra High. Independent live runtime, token and cost telemetry were unavailable. The reviewer launched no test, proof, or job-control command. Only the scratch review was written.

The initial review interval was 2026-11-20 16:17:34–16:20:44 UTC (3 min 10 s wall). The subsequent wait for final evidence is separate.
