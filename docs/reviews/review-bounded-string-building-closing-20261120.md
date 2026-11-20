# PR #403 / #400 independent closing review — 2026-11-20

**Accept the implementation and delivery continuation described below. No
material finding, required source repair or further proof/test rerun remains
from this review.** C8's combined validation, C9's assurance applicability and
C11's available accounting are supported; this report supplies C10's independent
closing review. The historical ARM invoking-stack setting remains explicitly
unknown. External Claude review is still pending, and merge remains the owner's
separate decision. No issue/board closeout or merge is authorized by this review.

The reviewed implementation is
`001c50dce1bcf3ad2d174b4426f684fe78cb2e64`, tree
`77b0d2c24ebc37a69fcca2edabf5ddd93aee391a`, based on main
`a03c7987bbba29569db2709820bd26ced20bed40`. The uncommitted delivery continuation
was frozen as the 32-file input manifest reproduced below. Its original
`closing-review-inputs.json` SHA-256 is
`78e141ef93c94410ac6ac98189443fabbb0cffcf5a23f8de838e4c8c865f6589`.
All 32 files matched at the beginning and end of inspection. The delivery
packet's complete 28-file payload inventory matched its SHA256SUMS. Compressed
JSON payloads match the corresponding original receiver results byte for byte.

This reviewer did not implement the sample/test/Rosetta changes or the delivery
status edits. I previously performed the independent assurance applicability
and recovery checks retained in this packet. This closing pass reads those
results together with the separate regression review, current source and final
records; it does not present those earlier checks as newly repeated proof work.

## Task fidelity and boundaries

I read the four cached primary task statements, the four delivered sources,
their manifest records, the changed boundary/control methods, the existing
manifest runner, and the relevant issue criteria/owner amendment. Independent
expected-output calculations agree with all four manifest records. The prior
86 complete sample records are unchanged, and the resulting inventory is 90
programs and 153 executable cases.

| Sample | Reviewed behavior |
| --- | --- |
| String append | Initializes a 13-cell String with `Hello`; one `Len <= 5` guard admits the entire eight-character `, world!`. The saved `Start : 0 .. 5` retains the index bound through loop entry. Positions Start+1 through Start+8 lie in 1..13. First attempt exactly fills the buffer; second changes neither buffer nor length and prints `full`. Complete stdout is `Hello, world!\nfull\nHello, world!\n`. |
| String prepend | Initializes 12 cells with `World!`; one `Len <= 6` guard admits six-character `Hello `. Reverse copying shifts the old prefix right six positions without overwriting a source character before it is read. Prefix copying fills positions 1..6; the first attempt exactly fills the buffer. Second attempt leaves buffer/length unchanged. Complete stdout is `Hello World!\nfull\nHello World!\n`. |
| Repeat a string | Keeps declared Count 0..10 and demonstrates five repetitions of `ha`. The nested indexes stay in 1..20 for executed iterations; Count=0 executes no copy and produces the permitted empty prefix. The separate fixture executes every count 0..10, including 0/5/10. Complete sample stdout is `hahahahaha\n`. |
| 99 bottles of beer | Reverse loop 99..1 emits all verses and the final transition to zero. Standard Integer Image leading spaces are retained. Independent construction agrees with all 495 lines and 11,357 bytes. Singular grammar is optional in the primary task. |

Source sizes are respectively 556, 591, 439 and 445 bytes, within the unchanged
4,096-byte bound. The samples use existing catalogue capabilities and ordinary
Ada/SPARK source, with only the permitted SPARK_Mode pragma. No declaration
domain, admission rule, resource budget, proof policy or runtime operation is
changed to obtain their results.

The added boundary tests inspect empty output, Character append, exact fit,
unchanged refusal, clearing by length and reuse. The two whole-literal refusal
fixtures inspect the entire buffer and logical length with one free cell, so
they detect partial writes as well as incorrect prefix output. Repeated prepend
uses W/XW/XXW/... to expose wrong shift order. The conditional-slice control
rejects the excluded inside-conditional form and executes the allowed form
after `end if;`; three non-refining guard alternatives reject. These are
membership controls, not suppressed proof failures.

Both full-refusal branches contain no buffer/length assignment and continue to
prefix output after the conditional. Healthy output returns status zero; the
unchanged runtime retains sticky failure status one on detected output failure.
Logical clearing does not erase storage. No String parameter, partial
initialization, resizing, arbitrary bulk append, Unicode or Character conversion
support is implied.

The unchanged manifest runner checks admission, complete application/library
report policy, byte-identical proof/build source, exact stdout/stderr/status,
and preservation of the author's sample bytes. Its successful final-input
runs therefore supply the required application route, separately from universal
compiler/language assurance.

## Assessment and source scope

The diff changes exactly twelve task assessments and four surface mappings.
The broad `string-building` identifier remains unsupported. The new
`bounded-string-building` identifier is registered in both renderer dictionaries
and describes the already admitted initialized-buffer/guarded-store/counted-loop
composition. The assessor text makes the same exclusions and explicitly maps
bottles through existing loop/Image/output machinery.

I checked the preserved original attribution and spot-checked the consequential
assessment corrections: Character codes retains Pos refusal/unisolated Val and
the executed complete printable lookup alternative; Array length distinguishes
Integer-array admission from the required String-array example; Selection sort
remains admission-only; Taxicab's 810448 sum bound is separated from its unmeasured
complete output and source/component obstacles. These checks agree with the
earlier criteria review and independent final render/accounting review. No fifth
sample or additional supported mapping is smuggled into those observations.

Accepted accounting is four new mappings, Stage 1 85→89, and 472 changed task
pages: twelve assessment-content changes and 460 position-only changes. All 63
existing construct Stage values are unchanged. The live card inventory and
#395/#400 edits remain expressly post-merge; no current board reconciliation is
claimed. #395 stays open for its broad scope, #373 remains separate, and PR #385
remains held.

The continuation changes only capability/roadmap/evidence documentation. A direct
diff against the implementation shows no source, proof, scripts, tests, samples,
catalogue, language, Rosetta, project, manifest or Oracle change. None of its 32
paths occurs among the 1,340 captured repository test inputs. The native/Lean
enumerators likewise do not select this documentation, and the unrelated report
fixture read from docs/evidence is unchanged. Retaining helper scripts under this
evidence directory does not add them to scripts/ proof-provenance inputs. Existing
evidence applicability is therefore not invalidated by this continuation.

## C8/C9 validation and assurance

The separate recovered regression review supplies exact inventory and raw-log
reconstruction, with reviewed receiver scripts and retained original events.
The original full suite contains exactly all 724 final unittest IDs: 722 passed
and two x86-specific tests skipped on ARM. The old 712/710 headline omitted twelve
successful multiline results. Their complete output is preserved; failures are
not reclassified as passes. Four original runs share all 1,348 captured inputs:
1,340 repository files match the PR, and eight recovered support files match.
The recovered check commit identifies exactly the PR tree, and the cited compiler
build head has identical governed compiler sources.

Fresh x86 run `20261120T125015-03ea0dfd16e0` covers precisely the two skipped IDs
on matching PR inputs. Its phase and launcher exits are zero. Thus the reviewed
composition covers all 724 final IDs, including all added/affected sample and
boundary cases. It is not described as a fresh x86 full suite. Original managed
final-event returncode null is retained honestly alongside phase exit zero and
successful outcome; it is the runner's successful context-manager default.

I accept the retained assurance/recovery addendum and its exact scope. Native
run `20261117T034048-8c22c1e6a33d` discharged 19,726 checks; the unchanged Python
auditor freshly accepted all 80 retained reports. All 2,622 native inputs now
have matching locally checked bytes, including original generated/configuration
inputs. All 147 native and 1,142 Lean repository inputs match the implementation,
and all 40 regenerated source candidates match exactly.

Complete Lean run `20261117T064945-d458c99ae977` supplies the original successful
actual-source/composition proof and fresh 1,035-module/166,332-declaration audit
with only the permitted foundations. Recovery independently matches all 1,037
workspace inputs and 6,202 compiled artifacts, and all 1,035 build traces pass
the current bypass policy. The merged overlay view, private/server objects,
tool marker and source-link spelling were preserved.

The records correctly distinguish receiver-local byte checks, collector tool/
Image-layout observations and historical complete provenance. No transferred
ARM cache was relabelled for x86, and no log/hash inspection is called a new Lean
import audit or kernel replay. Original failed #392 history remains failed;
it does not supply a success or become a #400 rerun. Accepted sample-batch policy
permits this exact unchanged-source reuse. No Oracle guarantee, source identity,
obligation, tool identity or declared domain has been waived. Another full proof
or successful regression rerun would add no missing evidence for this delta.

## C10/C11 disposition and remaining process

This review accepts the task interfaces, mutation/refusal semantics, precise
coverage changes and final evidence applicability. There are no ranked material
findings or required fixes. It supplies the independent closing disposition;
the coordinator can replace pending-closing wording with this acceptance and
refresh the affected documentation hashes. A change to validated implementation
or assurance inputs would require a new applicability assessment.

The packet records actual program/case/mapping totals, four original successful
managed test attempts, ten earlier full routes and five expected refusals, the
additional successful two-test x86 run, and zero complete native/Lean attempts
in this continuation. It distinguishes observed timing from unmeasured active
work/waiting. The original managed test window is 23 min 6.311 s, summed managed
time 1,385.262 s; the x86 follow-up is 4.749 managed seconds. Authorization-to-PR
commit is 19 h 23 min 1 s; the stated validation-recovery cutoff is 43 h 42 min
7 s after authorization. Review/publication and eventual merge are later events,
not falsely included as completed in that cutoff.

The historical ARM suite's invoking stack, child threads and cache-hit count
were not recorded. The documentation explicitly retains that limitation and
does not invent 16 MiB compliance or infer a failed execution from missing
settings evidence. Repeating a successful suite would not reconstruct its old
stack. Fresh x86 evidence records an 8 MiB soft invoking stack, unlimited hard
stack, 22 available CPUs/workers and the tests' explicit 8 MiB child limits.
This distinction is adequate accounting of available evidence, not an assertion
that the earlier recording requirement was fulfilled retroactively.

External Claude review remains pending. Its material findings, if any, must be
disposed of before the owner makes the requested merge decision. Issue closure,
post-merge Stage reconciliation and #395 bookkeeping are still future authorized
steps at their designated point; this review performs none of them and selects
no successor work.

Review began at **2026-11-20T13:00:21Z** and the report was finalized at
**2026-11-20T13:03:58Z**; wall interval **217 seconds**. This includes
read-only inspection and report drafting, not new proof/test execution. Selected
review configuration: **GPT-6 Astra / Max**. Runtime model/effort and token/cost
telemetry were not independently exposed. Actual review host is Linux x86-64;
no native macOS validation is claimed. The live harness goal was null. CLI recall
was not updated.

Only this scratch review report was written in the closing-review assignment.
No delivery file, shared cache, GitHub record, branch or commit was modified.
Read-only whitespace and local Markdown-link checks passed.

## Exact continuation input manifest

The base implementation Git object identifies the unchanged implementation.
The following complete manifest identifies the additional reviewed bytes before
the permitted final acceptance wording and checksum update:

```json
{
  "base": "001c50dce1bcf3ad2d174b4426f684fe78cb2e64",
  "inputs": {
    "docs/bounded-string-building-samples.md": "7fe4ce9310086db75c4d7efb921d26fce5a32676f7fbd23a0fd1da84cf11416f",
    "docs/evidence/bounded-string-building-400-20261118/README.md": "554fafbc69973af007a643f7d7cb83c6ab23c1548e1a177feb977abd303c9bd8",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/README.md": "fa77a4858e71e6e5f3c2aae3086033b417a9e2f96696633d4dadd280a1e75650",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/SHA256SUMS": "8b2730d3706c458726c77f65e5ccc3d556fb92ff66d2b6defb797d2ed6038a1f",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/assurance-applicability-audit.log": "8adcc094f834c61bcdff9b449f148d99299fd01004c6f981404e523caafdb4a0",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/assurance-applicability-recovery-addendum.md": "78e11e7d985edd327900909b6c545a143b28d247bb4822d1fca13f8becf840ca",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/assurance-applicability-results.json.gz": "6ceeca17462e7cea24c0308ce98bdff441374a8db6b0ee6b0b7e3b448811db93",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/assurance-applicability.md": "72e3232e17bf7b741ca8642a2ae40f212a76051eaec192612ccf06baa4dae53e",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/assurance_applicability_audit.py": "436b917c94eaffc2a37297e6f134db9ddc0ffffa80e046a90fe0e80748d55a73",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/collector-observations.tar.gz": "c6140b213a28025744fee922999d4831632425f704dc2a7eb37856632fcf0e29",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/final-test-inventory.json.gz": "33d52cf6694721d0b114ed74711914ecacee082a95c5eef7d59108e19c475d1d",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/focused-artifact-accounting.json.gz": "808195a422e3c23817c10a98a8029311f72bb72647e507122632152596d092cc",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/original-test-records.tar.gz": "9569518b48a7fe61eaf81cd641c3d269c46b8aae6acf1b8b4ec9267ac79a09db",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovered-regression-review.md": "2828db949e73a8fade76b2f18d33546c5859b0ea393e2bf4d908a4d64db742a9",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovered-regression-verification.json.gz": "008a1c973f015c5e6a32fe3aeeabd95b15e416e201d870b797259f7b6a8c3ba8",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-README.md": "a191a352419b54582ff3781ed5e57296f69ab76adc78069e2d1fc8ff60b306e1",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-SHA256SUMS": "ce9a14f1ad76e4927e6d6f38f7e87672a743adecc40bb5bd37f28e82a893650d",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-assurance-audit.log": "8c8fa817aaced685406e9a34d2e2b20b45cbef9627865877bb6c18e69699522a",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-lean-archive-file-inventory.json.gz": "0055c1d85910e13371fb27bf1955befb6dac6ba725b24c86a6b2743f6ee9eeae",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-lean-assurance-results.json.gz": "fbe154643414afcd73c343aee988eba3953692e8ee5067365d9be381cdb1579f",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-native-assurance-results.json.gz": "39199bc737b661d7dfe5c2cf37385338f39103237b8b18d4c1a12854bc9a81b4",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/recovery-records-archive-verification.json.gz": "01762bf804bb567e36dbd899ac2142b52614f20c0aeb88824d208dfc41893a6a",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/rosetta-accounting.json.gz": "d4d7cd9ab50f944c871dce52bae518d1318294a29c24e2745dd2aefa19007202",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/verify-recovered-regressions.py": "3ecad2d4f36d4370c1e97e4ced1a3bd05febaf4f6452dd0fc7d892896b359f8f",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/verify-x86-regression-composition.py": "2af1f5bb95fdb95f693c7378e8a7888f67fb048a82bcf6fb7020d3d55f8de537",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/verify_recovered_assurance.py": "3f5889c6ae9f0af4f978794fd144e87e5fc0194a92323238e1c4e529eb0149a8",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/x86-regression-composition.json.gz": "fc8d93a6658262046f26df5b55bc355ae24525d0da49aa2d143c8a05048392b5",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/x86-skipped-tests/events.jsonl.gz": "97f9d8785811331a5a7d8c7c37c2f6c65e903e7f75be8e00c72736cc7461d543",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/x86-skipped-tests/launcher.json": "9298ecc51cee4b9bbe0b47f942d1ea07c47013e17b0035a828c0a6e687dd4c75",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/x86-skipped-tests/launcher.log": "0ce4467f951e5df3516f93e8572781c74653a627c2f05551e18f4ca6f9667012",
    "docs/evidence/bounded-string-building-400-20261118/delivery-20261120/x86-skipped-tests/native.log.gz": "0482ca79754be890a293270ff89fb4fda136b3c18a70211f34eaba6c91834d48",
    "roadmap.md": "b7ce5524bdad0c71749ad81e54b2ea865eea25563e96f17d3bac88ad3518e64f"
  }
}
```
