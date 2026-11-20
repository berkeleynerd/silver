# Silver PR #403 / issue #400 recovery

Collected on 2026-11-20 on Darwin arm64 from evidence produced by `silver-m4pro` on Linux aarch64. The sandbox was stopped and detached. The collection read its retained disk images offline without mounting them or replaying their journals. Git objects and the existing worktrees were read in place. The destination is the restored primary Linux x86-64 host. These are ARM evidence and cache files.

| Archive | Bytes | SHA-256 |
| --- | ---: | --- |
| `pr403-records.tar.gz` | 3,787,888 | `1f870f13b0af2b761ee41d13e538fb7a2469ee10803f8568ab0f78444834dae9` |
| `lean-392-cache.tar.zst` | 645,062,353 | `591759f906e7648b52ffeb08e7922a7d7f79af237bab254254f575d41cf23ece` |

Both archives were read back. The Lean archive was also rehashed internally against the committed manifest. `SHA256SUMS` covers the two transfer files. The records archive includes the collection and verification scripts.

## Paths and Git identities

- Original and accessible Mac checkout: `/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver`. The local checkout was at `bf285bc571af8061489f6a057c99d870b369c63b`. The existing `origin/main` ref agreed with published main `a03c7987bbba29569db2709820bd26ced20bed40`. The PR head was `001c50dce1bcf3ad2d174b4426f684fe78cb2e64`.
- The recovered check commit object is `7d5967240779a46f73d1c29746d77e530f81f906`. Its tree `77b0d2c24ebc37a69fcca2edabf5ddd93aee391a` equals the PR tree. Its parent is the published main above. The check script identified compiler build head `9b5b2d99aaf6f4bfca5226b36af744502b095990`.
- The original check checkout was `/home/agent/silver-review/runs/pr402-9b5b2d99aa/checkout`. Its managed registry was recovered under `/agent-work/silver-review/runs/pr402-9b5b2d99aa/checkout/.git/silver-runs/linux-aarch64/e513549bff0f5897/runs` within `silver-m4pro-docker.img`. The original delivery workspace was `/tmp/silver-develop/dev400-a03c7987bb/work`. The full disk and original path mapping is in `provenance.json` and the records for each run.
- The #392 worktrees still exist under the original checkout's `tmp/`. `named-source-392` is at `c7388ab5d038ccbce9635ffaeec7df9189369366` and `named-native-392` is at `20e055be873f04a05d520b4e50f0e066515b7d4f`. The original native bind data was read under `/volumes/silver-recovery-370-20261115/_data/named-392-native-artifacts` in the same image.

## PR #403 regression and Worca records

| Check | Managed run | Original result |
| --- | --- | --- |
| Full suite | `20261118T173931-305d1781f71e` | `Ran 724 tests in 1128.481s`, `OK (skipped=2)` |
| Focused samples | `20261118T173536-c2d8662ad230` | 2 tests, OK |
| String/Character | `20261118T173513-f3c45b223d1e` | 18 tests, OK |
| Rosetta | `20261118T173927-90b8193aa993` | 12 tests, OK |

Each original managed log, event stream and lease is in `managed-runs-403/`. The four prepared inventories are identical. All 1,340 repository entries match the PR Git blobs and all eight additional entries match recovered bytes. The additional files and path mapping are included. The original suite output is preserved. The workflow report's 712/710 figures are its parser subtotal.

The original runner records include commands, start and end times, 12 available CPUs and a 12-worker reservation, test phase exit 0, and final outcome `success`. The final event's return code field is `null`. The ARM invoking stack limit is **not recorded** for #403. Child thread and cache settings are unrecorded. No failed or interrupted #400 test run was found in the retained managed registry. The workflow packet has one check round, and Worca's `develop-check-failed.md` duplicates the successful report. No separate managed input postflight file or event was found. The contemporaneous criteria tool output records its independent after-run comparison of the 1,340 repository inputs. That excerpt and the new recovery-time hash comparison are both preserved with their provenance.

The workflow archive supplies the full check report, original workflow logs and exits, `cycle-01.patch`, and check/publication identities. The selected Worca records supply the criteria report, implementation notes, and pipeline identities. The historical criteria report still records open assurance applicability and closing-review work.

## Final #392 Lean workspace

The original `tmp/named-source-392/.silver/linux-aarch64/proof` mount was absent at collection. The empty directory on the host was backed during validation by an overlay with:

- Lower donor `/home/agent/silver-worktrees/procedures-lean-370/.silver/linux-aarch64/proof`, recovered from `/agent-work/silver-worktrees/procedures-lean-370/.silver/linux-aarch64/proof` in the disk image.
- Upper `/home/agent/silver-workspaces/recovery-volume/named-392-lean-overlays/named-source-392/upper`, recovered from the corresponding path in the volume's `_data` directory.

The archive preserves both layers, their overlay metadata, and the merged view at `proof/`. It includes hidden Lake files, generated certificates, object variants, hashes, traces, and IR/native outputs. The adjacent `src` symlink target is `../../src`. The original `.silver-cache-tools.json`, adjacent evidence and logs, and final managed run `20261117T064945-d458c99ae977` are included. The offline reader preserved file bytes and recorded overlay attributes separately. Original Linux ownership could not be applied to the staging copies as a Mac user.

The merged and archived view matches **1,037/1,037 workspace inputs** and **6,202/6,202 artifacts**, with zero changed or missing. `hash-comparison.json` lists every path and also compares each layer separately. The lower alone has 42 changed and 26 missing inputs and 584 changed and 156 missing artifacts. These differences are covered by the merged view. The native files remain Linux ARM artifacts. The normal x86 runner invalidates the ARM cache, so preserve it separately for evidence checking.

## #392 native provenance

The proof and build settings and exit records are included for `20261117T034048-8c22c1e6a33d` and `20261117T055412-08a00820e2ef`. Their contemporaneous packet captures a 16 MiB invoking stack, four proof workers, and 11 build workers. The complete report packet remains in Git under `docs/evidence/named-scalar-arguments-392-20261117/complete-native/`.

| Comparison | Matching | Missing | Changed |
| --- | ---: | ---: | ---: |
| Native inputs at host paths | 2,616 | 6 | 0 |
| Native inputs with recovered bind data | 2,622 | 0 | 0 |
| Native tools at host paths | 11 | 1 | 0 |
| Native tools with original ARM Python recovered | 12 | 0 | 0 |

The recovered bind data contains the three generated Ada files and three toolchain context files. Other manifest-listed Alire inputs are included. The missing host tool was `/usr/bin/python3.14`, whose matching original ELF came from the sandbox's retained EROFS layer. The Image link layout and adapter mapping are included. The vendor `gnatwhy3` bytes match the SHA-256 in the generated configuration, and the copied `gnatprove` matches the manifest's original vendor binary. Per-path counts, hashes and source locations are in `native-392/hash-comparison.json`, `supporting-input-path-map.json`, and `image-overlay.json`.

## Transfer

Copy the two archives, this README, and `SHA256SUMS` over an existing SSH connection to the restored primary Linux host. For example, replace `PRIMARY_LINUX` with its SSH alias and run from this export directory:

```sh
rsync -avP pr403-records.tar.gz lean-392-cache.tar.zst README.md SHA256SUMS PRIMARY_LINUX:~/silver-pr403-recovery/
```

On the receiving host, run `sha256sum -c SHA256SUMS` in that directory. No transfer or publication was initiated.
