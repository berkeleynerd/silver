# Bounded String and Character development evidence

This packet retains successful focused Linux observations for
[#296](https://github.com/berkeleynerd/silver/issues/296). Complete native compiler
proof/audit passed on the repaired source. Complete Lean/source assurance,
final regression coverage and independent delivery review remain outstanding. The
[capability record](../../bounded-string-characters.md) governs the current scope.

| Packet | Exact scope |
| --- | --- |
| [Discovery archive](string-discovery.tar.gz), [index](string-discovery.json) | Run `20261031T162539-96d0ba9159be`: 14 pinned frontend/prover cases, nine build/proof successes and five expected frontend rejections. Includes all printable Character literals, actual/noncanonical/null bounds and dead-code acceptance boundaries. |
| [Stress/driver archive](string-stress.tar.gz), [index](string-stress.json) | Run `20261031T165409-9c2dd4f813bc` at native implementation `9c4afd3c5b`: eight exact cases with admission, application/runtime proof, strict Python/native report audits, build, exact execution and unchanged author-source hashes. Includes the three prepared Rosetta drivers, 4,096-byte dense inputs and 64-leaf boundaries. |

Each gzip-compressed tar contains its original summary and every input/artifact
named in that summary, retaining the original relative paths. The JSON indexes
bind all original bytes and each archive by SHA-256; all original file hashes
were rechecked when exported. No validation was rerun to make these archives.
The summaries preserve expected failures and the earlier stress wrapper's
preanalysis failure reference. Native run logs and the managed history remain
under the repository's shared Git run registry.

These results apply to their recorded inputs and native host. They are neither
universal assurance nor a completed final compiler/feature checkpoint. The
[producer account](../../bounded-string-characters-report-capacity.md) keeps the
source-derived reasoning separate from these finite observations.

## Resumed validation records

The [validation directory](validation/) preserves terminal managed records,
original logs and available detailed proof evidence. Each packet's `index.json`
or `archive.json`/`files.json` records its source and retained SHA-256 values. Exporting these existing
bytes did not rerun validation. Failed runs retain their failed status.

| Run | Result and scope |
| --- | --- |
| `20261103T174436-6fdd4028770c` | Failed focused source checkpoint: the output-body certificate reached its 8 GiB kernel memory allowance; the separate helper banner syntax defect was subsequently repaired. Successful other module builds do not make this a successful checkpoint. |
| `20261103T174845-2485475c8238` | Isolated helper repair passed with a fresh 12,818-declaration audit. |
| `20261103T190906-eeb647b2db40` | Integrated helper repair passed with the same fresh audit scope. This is partial validation. |
| `20261103T175811-5ecfadfa25c5` | Failed Predicate candidate check at 4 GiB: scalar and Character candidate kernel memory limits. An unchanged-input retry is separately tracked. |
| `20261103T182419-61bbb1c84d64` | Failed Predicate candidate retry at 8 GiB: scalar and Character subcandidates passed, but the final candidate reported eight kernel memory-limit diagnostics. No fresh audit ran. |
| `20261103T192928-ecb0a9199439` | Intentionally interrupted old-source 24 GiB check for the subsequent Character guard repair. No memory or source-equality failure occurred in this attempt. |
| [`20261103T201920-c39bcc381ac2`](validation/20261103T201920-c39bcc381ac2/archive.json) | Native run intentionally interrupted when available host memory fell below 4 GiB during concurrent dense source validation. Exit 130, no failure keys, all 2,582 inputs unchanged; 75 partial SPARK reports and native cache retained. It is not a completed proof/audit. |
| [`20261103T220251-899976574bd0`](validation/20261103T220251-899976574bd0/summary.json) | All 17,404 native checks proved, but strict audit failed on seven arithmetic-reassociation warnings. Exhaustive diagnostic traversal found no other audit blockers. The seven warnings also existed in the earlier failed native run; its initial diagnosis missed them. This remains a failed checkpoint without a completed provenance manifest. |
| [`20261103T203357-33c8b5720ddd`](validation/20261103T203357-33c8b5720ddd/index.json) | Intentionally interrupted after 10,560.372 seconds for the required seven-site native grouping/model/pin repair. The old-source output certificate passed in 5,090 seconds; complete build and fresh whole-project audit did not finish. A [later full-log correction](validation/20261103T203357-33c8b5720ddd/diagnostic-correction-20261104.json) identifies the missed `ComposeSourceChecks` wrapper failure. All 738 captured inputs remained unchanged at termination. |
| [Scoped arithmetic grouping repair](validation/parenthesis-scopes/summary.json) | Four canonical scoped native proofs passed 69 checks; matching build and all ten affected StringCharacter regressions passed. The packet retains both corrected setup failures and their actual successful reruns. Complete native audit remains separate. |
| [Grouping model equivalence](validation/parenthesis-model/index.json) | Successful focused run `20261103T232749-c3db83b33386`: 121 modules and fresh 14,821-declaration audit, three unrestricted whole-body evaluation equalities, and three repaired-pin rendering checks. Initial scratch reduction failure retained. Fresh generator/pin diagnostics match the integrated four-file repair, accepted by the [independent bounded review](../../reviews/string-arithmetic-grouping-20261103.md); complete source correspondence remains separate. |
| [`20261103T234601-0e070300d2d7`](validation/20261103T234601-0e070300d2d7/summary.json) | Complete canonical native proof, strict report audit and provenance passed: 76 units, 1,099 entities, 15,916 proof and 1,488 flow checks. Reused ordinary solver work; 87.226 managed seconds. Actual repaired source matches `119cfa0c73`; no reassociation warning. Matching build and ten affected tests remain applicable. The final 578-method inventory and seven-fixture dependency comparison are retained separately from pending suite execution. |
| [Explicit source-wrapper unfolding](validation/translation-unfold-20261104/index.json) | Run `20261104T011006-21d49eb8b36b` checks an exact scratch copy of `ComposeSourceChecks` with one explicit definitional step before its existing rewrite; fresh 61,362-declaration audit passed. The production proof edit remains queued while independent heavy source builds finish under their frozen inputs. Full cached source validation remains mandatory afterward. |
| [Character progress equivalence](validation/character-progress-equivalence/index.json) | Successful focused run `20261103T202419-5f35a847709a`: both helper targets, fresh 14,821-declaration audit, exact provenance and retained failed development attempts. Accepted by the [bounded repair review](../../reviews/string-character-progress-guard-20261103.md); complete native/source assurance remains separate. |
| `20261031T214130-1e0195247bd5` and `20261031T215153-7280a74a41c2` | The first installed-Lean fixture run failed one of seven methods; the subsequent two-method module-fixture repair passed. The [fixture packet](validation/installed-lean-fixtures/index.json) retains logs, exact inputs and the original prepared reuse account. The [independent bounded review](../../reviews/string-character-fixture-reuse-20261103.md) approves those seven results for the reviewed inputs. |

These records include a successful complete native checkpoint. Complete
Lean/source assurance, final regression coverage and closing delivery review
remain outstanding.
