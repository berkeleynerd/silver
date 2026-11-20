# Bounded String building implementation evidence — 2026-11-18

Historical focused checkpoint. The [final external suite and merge](external-20261120/README.md)
record completed delivery. The [2026-11-20 delivery continuation](delivery-20261120/README.md)
supersedes the pending-validation state below with recovered complete regression
coverage and reviewed native/Lean applicability; closing and external review
are recorded separately.

Issue [#400](https://github.com/berkeleynerd/silver/issues/400), based on main `a03c7987bbba29569db2709820bd26ced20bed40`. **Focused implementation evidence; the shared complete validation checkpoint and independent closing review remain outstanding.** The workflow check step owns compiler-dependent regression runs. No issue or board edit, commit or publication was made.

## Inputs and scope

The [input hashes](inputs.sha256) identify the four sample sources, manifest, changed boundary tests and their shared helpers, Rosetta inputs, catalogue, language text and all twelve primary task texts. The [probe archive](probes.tar.gz) retains every exact candidate source, verdict and execution preview; successful candidates also retain the complete expected/actual stdout, stderr, original SARIF/SPARK reports and fresh audit statistics. Each archive source hash appears below. Environment/artifact-path lines are omitted from result excerpts; source bytes and reports are preserved. The archive SHA-256 is `2640f9bf99d5796a1325e21aa07b2c8ccb09a4b34be4e70ecbe04f3b0d2057f5`.

The scope names compiler checkout `9b5b2d99aaf6f4bfca5226b36af744502b095990`. The live try service actually identifies checkout `07422adb2d211304f3ebfeed92b0eaf798957d41`. A Git comparison shows no difference in `src/`, `proof/`, `scripts/`, `alire.toml`, `silver.gpr`, `catalogue/silver.json` or `oracle.md`; all **1,187** tracked files in those paths were also compared byte for byte between the actual service checkout and this implementation tree. The service checkout has no changes in those paths. Only documentation, sample-manifest and named-argument-test files differ between those two cited commits. This establishes source applicability for the focused candidates; it is not a new complete compiler/Lean checkpoint or a binary provenance audit.

The request host reports Linux `7.0.14`, `aarch64`. The try-service child stack, worker allocation, effective solver limits and cache-hit counts were not exposed by these results; do not substitute request-shell settings for measured native child settings. The final check step must record its actual host/settings, including the required 16 MiB invoking stack where applicable. The reported GNATprove route used `--mode=all --warnings=continue --checks-as-errors=on`; retained SARIF records the remaining command options. The ordinary manifest runner still checks effective prover limits and proof/build source identity.

## Four sample results

Expected bytes were fixed from Ada semantics before these calls. All four sources admitted, completed the try full route, returned application status 0 and empty stderr, and matched the independently derived complete stdout. Each retained `workspace/main.adb` matched the candidate and repository sample byte for byte. Fresh `audit_reports` calls using the unchanged auditor passed all five units for each candidate, with `indexed_main=True`, the existing assigned policy for mutation and the static policy for bottles. No check or advisory policy was changed.

| Source | SHA-256 | Complete stdout | Fresh proof checks | Admission / full IDs |
| --- | --- | --- | --- | --- |
| `rosetta_string_append.adb` | `881ef9b89a7048693ebf32669dba7acba011109223b23048d605210f936bc4fa` | 33 bytes / 3 lines | 50 | `20261118T172351-020643555-plan-try-8fc023` / `20261118T172351-082666555-plan-try-2f39c0` |
| `rosetta_string_prepend.adb` | `cf7fb7530002c1b3a378f4d8a32d24ee88a201bb8ecb03304a2308985532e442` | 31 bytes / 3 lines | 51 | `20261118T172347-842954637-plan-try-83b08a` / `20261118T172347-904841845-plan-try-7d7c76` |
| `rosetta_99_bottles_of_beer.adb` | `ddf00d40cffaff5451600773f2f2b50f0a6b36bccf7510bd4277ba37b6ce3898` | 11,357 bytes / 495 lines | 50 | `20261118T172341-517860134-plan-try-294526` / `20261118T172341-577908592-plan-try-6065e6` |
| `rosetta_repeat_a_string.adb` | `d188e02bb926737f29ed07f008df9181ad1c6cb33bed140c7f37b1c9e4e8fd23` | 11 bytes / 1 lines | 51 | `20261118T172344-700598135-plan-try-3a89c1` / `20261118T172344-761427177-plan-try-f37085` |

Append prints `Hello, world!\nfull\nHello, world!\n`; prepend prints `Hello World!\nfull\nHello World!\n`. Both use actual counted Character stores, one whole-literal guard, exact fit and unchanged whole refusal. The append offset has a declared `0 .. 5` range so widening at copy-loop entry retains the bound. Prepend captures its shift bound before loop-body widening; reverse order preserves the existing prefix. Their else arms update neither buffer nor length, and prefix output follows `end if;`.

The bottles comparison read all **495 lines / 11,357 bytes**, including Image leading spaces and the final transition to zero. It did not compare the service's 600-byte preview. Repeat retains `Count : Integer range 0 .. 10 := 5` and prints `hahahahaha\n`; its declared domain was not narrowed.

## Boundary and negative controls

Seven new test methods produce six positive full-route sources and four rejection sources. Together with the samples these are ten full-route executions. The additional rejected documentation variant below makes fifteen candidate programs in this implementation pass.

| Fixture | Source SHA-256 | Exact stdout bytes | Fresh proof checks | Admission / full IDs |
| --- | --- | --- | --- | --- |
| `test_native_bounded_character_append_clear_and_reuse-0` | `34663a3262a786b454cd32461d9cea67bb3019268bd56412e442e361e6f445b8` | 17 | 55 | `20261118T172354-682798765-plan-try-36d6c8` / `20261118T172354-744357057-plan-try-42143c` |
| `test_native_bounded_repeat_all_declared_counts-0` | `1a9253c90c8eab67a5a30c7e16362c03438563006e509555a58013752595d9ae` | 121 | 51 | `20261118T172358-875878684-plan-try-938941` / `20261118T172358-937272142-plan-try-41fa9b` |
| `test_native_bounded_repeated_prepend_shift_order-0` | `9169bde17b3a0ab20b433f4cf431d85bcb08bd7751f0f5fdefd3307baa6b7ef7` | 39 | 51 | `20261118T172403-051669477-plan-try-9458ff` / `20261118T172403-113921644-plan-try-5b6256` |
| `test_native_bounded_literal_append_refuses_whole_with_one_free_cell-0` | `89d5504ad378ffb88ee1e44af1fa019cbf716f1893e9688ca115d295a1b693b2` | 45 | 50 | `20261118T172407-249291354-plan-try-008987` / `20261118T172407-310510313-plan-try-02602a` |
| `test_native_bounded_literal_prepend_refuses_whole_with_one_free_cell-0` | `0c3b80d224c86bc76037908b1b7844d279c606a098cc7224a3741948091c3065` | 45 | 51 | `20261118T172411-447136356-plan-try-940b65` / `20261118T172411-508350148-plan-try-4a4b13` |
| `test_bounded_prefix_output_after_conditional_control-1` | `5aa39f3dc2600450da52fa56752952a5c3ca8153295053f6ecfda15fc6021a54` | 2 | 50 | `20261118T172416-730308692-plan-try-df5dc0` / `20261118T172416-792177525-plan-try-b5234f` |

The Character append case covers empty prefix output, the one-free-cell transition to exact fit, full unchanged refusal, logical clear and reuse. The repeat fixture executes every count 0 through 10 in one program. Repeated prepend begins empty and changes its inserted Character so a forward-shift corruption becomes observable. The two several-character refusal fixtures begin with four used cells in capacity eight, successfully copy three cells, then refuse with one free cell; they inspect the complete buffer and Len as well as its prefix, detecting partial writes or length changes. The after-conditional control executes `x\n`. Historical B1/B2/B3 sources/results remain in the capability record; these compact test-fixture bytes have their own fresh identities.

| Expected rejection | Source SHA-256 | Result |
| --- | --- | --- |
| `test_bounded_prefix_output_after_conditional_control-0` | `63e5a7ae8596d42123eee64698a89556cce264834c254aed8fa0b9608fba79a5` | `20261118T172415-642095525-plan-try-93ff67 check[head] exit=2` |
| `test_admission_bounded_append_requires_bare_name_refinement-0` | `3354b8f98234c0ba7ce532328b822fefa815fe53908487ed7e27293df5cbe32b` | `20261118T172420-932026986-plan-try-55a9fd check[head] exit=2` |
| `test_admission_bounded_append_requires_bare_name_refinement-1` | `a68ce6577e78021a0b169647393f2065360bb32b8f22dc86058365e1019f844b` | `20261118T172422-032191861-plan-try-a9956d check[head] exit=2` |
| `test_admission_bounded_append_requires_bare_name_refinement-2` | `98cf3b17f3ab03b8838d6096132ab4493637fda27599dee1032d4e85cf6d1f1e` | `20261118T172423-138890195-plan-try-ce5f69 check[head] exit=2` |
| `append-with-loop-local-len` | `855b9e7047f5a7a9cfb85274a5de6f08da2cc420dd7b3d3033ef044d4e5503b2` | `20261118T172618-679679917-plan-try-a8f912 check[head] exit=2` |

These controls retain conditional nonstatic-slice rejection and reject `True`, arithmetic and stored-Boolean substitutes for the required bare-name guard. The extra documentation variant uses guarded Len directly inside the copy loop instead of a separately bounded saved offset; it rejects after loop-entry widening. The actual sample and corrected capability example use Start. No valid-program proof/build failure was observed. All emitted advisories were accepted under the existing exact audit policy; overwritten Start/Len initializers and unused output bookkeeping remain visible in the retained diagnostics.

## Metadata and render

The [render output](render.txt) records a successful integrated render after registering `bounded-string-building` in both renderer dictionaries and supported coverage. Only four task surface mappings change; all eight further-task surface lists and original assessment attributions remain unchanged. All twelve targeted records receive dated review metadata. Character codes retains the isolated Pos refusal, unisolated Val limit and the executed printable lookup alternative; S3/S4/S6 retain admission-only limits, S8 retains its 901-value execution, and S2/S5/S7 retain their measured obstacles.

The render adds exactly four Stage 1 task mappings, **85 to 89**: append/prepend/bottles move **4 to 1**; repeat moves **10 to 1**. Supported precise identifiers increase **16 to 17**. Of **472** changed generated task pages, **12** change assessment content and **460** change position only. The generated listing and progression also change. All **63 existing construct Stage values remain unchanged**, including `string-building` at **4**, `integers`/`ranged-subtypes`/`for-loops`/`scalar-image`/`procedures` at **2**, `arrays` at **3**, `while-loops` at **7**, `characters` at **9** and `string-indexing` at **10**. Previously supported constructs retain Stage 1; the new precise identifier is also Stage 1. Broad `string-building` remains unsupported.

The manifest grows **86 to 90 programs** and **149 to 153 execution cases**; the four added programs have one primary execution case each. Existing entries remain byte-equivalent as JSON values. All sample sources occur exactly once, capability IDs are existing catalogue IDs and specification targets exist. No catalogue admission or compiler budget changes. The existing String/Character producer account and current **49,279,744-byte** report envelope within **67,108,864 bytes** remain applicable to these unchanged forms; historical 32 MiB allocation is not the current allocation.

## Remaining checkpoint and post-merge actions

The current native/Lean evidence pointers are in [named scalar arguments](../../named-scalar-arguments.md#delivery-assurance-and-validation): complete native `20261117T034048-8c22c1e6a33d`, build `20261117T055412-08a00820e2ef`, complete Lean/source/module/axiom success `20261117T064945-d458c99ae977` and final suite `20261117T072619-37479dd61ba9`. Those historical packets are omitted from this checkout and were not retrieved or freshly audited in this implementer pass. Matching governed source bytes alone do not close evidence applicability. The check step must obtain the packets and complete required fresh audits or run the necessary complete checks. Every new sample still requires its ordinary final-input manifest route; every added/affected test requires fresh success and the complete final inventory needs coverage. A source-certificate rebuild is not required solely by these sample/metadata changes.

The final complete regression checkpoint, retained native/Lean applicability review, affected Rosetta test run and independent closing review are pending. No full suite, standalone compiler/prover/Lean command or source-certificate rebuild was run here. There were **ten focused full-route attempts**, all successful, and **five expected admission refusals**, with no interruption or failed proof repair. Reported application compile elapsed time totals 24.209 seconds; fresh execution does not imply a cold solver cache. Candidate result timestamps span **17:23:41–17:26:18 UTC** (157 seconds, including the later documentation control); this is a focused evidence window, not total delivery elapsed time. The inherited draft and work outside that window were not timed; final delivery elapsed time remains to be recorded at closeout.

Per the workflow operator, **all GitHub issue and project-board edits are left for after merge**. Keep #395 open for broad string-building, record the four delivered mappings and its remaining exclusions, and reconcile the existing open and closed stage cards against the final render. The render does not require an existing construct to change Stage; verify the live card inventory rather than claiming it was inspected here. Preserve status and authorization, including Closed/Done with Stage 1 for supported constructs. Issue #400 is not ready for closeout until its remaining validation and independent review criteria pass. Preserve #373 recovery and the PR #385 hold; the Array length feasibility recommendation creates no new work in this batch.
