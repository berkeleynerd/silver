# Focused behavior and Python policy checks — #392

Linux aarch64 `silver-m4pro`, 12 CPUs, about 16 GiB RAM and no swap. Native
build/tests used the established 16 MiB process stack. Four workers were
reserved while separate source/model Lean checks used the remaining capacity;
Python-only controls reserved one worker. These are focused checks and do not
replace complete compiler proof or the final whole-suite checkpoint.

| Managed run | Result |
| --- | --- |
| `20261117T024551-3193d455f6c3` | Two early full-route named methods passed in 7.250 s using preceding exact-source build `024053-f027e2fd5fd4`. |
| `20261117T024722-468b377feac0` | Ten exact source-policy positive/mutation methods passed in 0.138 s. |
| `20261117T025534-e506f4e5ce46` | Complete Python evidence file passed: 85 tests in 1.331 s. |
| `20261117T025744-3512b9794d5e` | Incremental build recompiled `silver_output_profile.adb`, rebound/relinked Silver, and retained the matching Image adapter. This was not a clean rebuild. |
| `20261117T025819-c85791b031d5` | All 15 named-argument methods passed in 32.099 s. Positives run fresh application proof/build and output checks; negatives exercise admission. This is not the complete repository suite. |
| `20261117T030030-e4c2fbbc3df0` | Custom sample harness failed before compiler invocation because Alire changes the working directory. The harness now derives its repository root from its own filename. |
| `20261117T030042-d612d38a0399` | Named parameters sample compiled and produced exactly the four independently predicted output lines. Five-unit Python report audit counted 20 flow and 51 proof checks, one termination witness and only existing advisories. Original application source bytes were checked unchanged. |

Managed events/logs, the tested source snapshots and the corrected probe are
retained here. The [sample packet](sample/summary.json) retains all original
SPARK/SARIF reports, source and output with hashes. The compiler source still
contains an unconsumed ghost lemma with a pending native proof; behavior success
does not erase that failure. Each application uses a newly created workspace,
while the compiler build and retained Lean dependencies use caches as described.
The later shared checkpoint must validate the final combined source.
