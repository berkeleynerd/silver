# Independent delivery review of For loops and integers

Reviewed on 2026-10-16 on Linux x86_64. The implementation target is
[`410ed2c83e`](https://github.com/berkeleynerd/silver/commit/410ed2c83e90dca6265723b3359cfdfc1a47a8b5),
plus the prospective language/catalogue/sample, documentation and Rosetta
changes applied for the final checkpoint. The exact inputs are recorded in the
[review manifest](../evidence/for-loops-image/delivery-review-inputs.json).
The tracked delivery diff has SHA256
`e92bf7ca937f88cd908f068c62ee02daab20d0d53cecf30bd5a31aa4238dabb6`;
new delivery-file hashes are recorded separately because an ordinary Git diff
does not include untracked files. The implementation target, review snapshot,
validation inputs and eventual completion commit are distinct. This record and
the accompanying boundary/history wording clarifications are review outputs.

The initial source/semantic, producer/refinement/consumer and delivery-scope
reviews found no material issue within their recorded scopes. The initial
full-project Lean check exposed stale `SequenceNativeState` conversions after
`ParserState` gained the scalar environment. The five-proof-file repair, its
independent review and successful complete audit at `b5cd3f0231` are recorded
below. Subsequent native validation exposed the two low findings
[#48](https://github.com/berkeleynerd/silver/issues/48) and
[#49](https://github.com/berkeleynerd/silver/issues/49); both repairs are integrated and passed complete native/Lean validation;
the full suite subsequently exposed only the four #50 subcases, repaired and
rechecked as recorded below. The native snapshot sync/hash handoff also passed. The
[capability checkpoint](../for-loops-integers.md#stable-delivery-evidence) and
[durable validation record](../evidence/for-loops-integers/delivery-validation.json)
keep original results separate from repaired inputs. The final reviewed
implementation base is `62f472c35d` after the four-snapshot #50 refresh.
Native and complete Lean runs used base `4cd2fe8aae` plus coordinated
working-tree changes, including the catalogue source committed in delivery
`65de28b64e` (merge `b8f1d0b9a8`). Their retained input hashes/digests, not the
base commit alone, identify what was executed. The original review snapshot
remains separately identified; the input-scope correction below is subsequent
review bookkeeping.

## Review method and scope

The review combines separately owned implementation streams with focused
read-only checks. Reviewers did not rerun native proofs or Lean builds while
the coordinated validation workspaces were active. The planning reviewer
inspected the final producer and consumer endpoint statements and their source
boundaries, checked the durable delivery patch, reran the two read-only finite
constructor reconstructions, and compared the entire applied Rosetta diff with
the previously tested isolated draft. Separate reviewers checked the producer
resource/array-head argument, the final consumer interpretation, and the
language/catalogue/sample delivery scope. Root separately reviewed the applied
metadata and samples, including exact leading spaces in Integer Image output.

The source-correspondence review is supported by the detailed
[output-source mapping](../for-loops-output-source-review.md),
[producer schema review](../for-loops-image-schema.md) and
[complete producer/consumer review](../for-loops-image-producer-review.md).
The last review records pinned upstream revisions and every constructor field;
its scripts are review witnesses, not execution or verification of GNATprove.
This record does not claim a new exhaustive reassessment of every historical
Rosetta task, an independently rebuilt toolchain or binary-source attestation.
The committed feature spans substantially more code than the final Image
endpoints. The final endpoint/metadata review does not purport to rereview every
committed file; the following index identifies the earlier review and evidence
scopes. The separate core integration review below then checks the scalar/loop
admission-to-assurance and native/report connections directly.

| Scope | Existing record and limits |
| --- | --- |
| Prior review repairs and native report foundation | [Selected repairs](../review-343c2f8-repairs.md) and [report storage/projection](../report-capacity.md) retain their implementation targets, independent review dispositions and complete historical validation. They do not themselves validate the new language fragment. |
| Scalar literals/intervals, expressions, declarations, loop semantics and native report checks | [Resumed integration evidence](../for-loops-integers.md#resumed-integration-evidence-2026-10-16) identifies focused source/native runs; [historical pre-Image evidence](../for-loops-integers.md#historical-pre-image-evidence-and-recovery) distinguishes the earlier literal/interval checks, frontend differentials and native probes. These are evidence records with explicit input scope, not a newly claimed scalar-only independent review. |
| Actual scalar/loop/Image source changes and composition | [Output source-shape review](../for-loops-output-source-review.md) independently maps every changed native group to scalar/Predicate/Compose interpretations, helper contracts and complete source pins. Its focused validation is separate from the final whole-project build. |
| New frontend/report envelope | [Frontend and warning-capacity source review](../for-loops-report-capacity.md) covers scalar/loop proof-record sites, signed-literal/operator accounting, warning multiplicity and fixed retained metadata. [The derived extension](../report-capacity.md#for-loops-and-integers-extension) states the resulting bound; it is not a generated-JSON model-size theorem. |
| Image source, parser, templates and external constructor meaning | [Schema record](../for-loops-image-schema.md) and [complete producer/consumer review](../for-loops-image-producer-review.md), followed by the final endpoint checks in this record. |
| Coordinated language/catalogue/samples and narrow Rosetta split | Independent read-only delivery-scope review and [Rosetta mapping review](../../rosetta/for-loops-delivery-review.md), plus the exact applied-diff comparison below. |

The final delivery-scope reviewer compared scalar grouping and signed minimum,
the shared 63-operator budget, names and loop hiding/bound timing, empty-loop
transfer, Image intervals and directional fixed-bound assignment, and sample
bytes with the current implementation. Direct inspection of
`Silver_Length_Intervals`, `Silver_Path_Facts` and native report rules found no
material mismatch. Prior catalogue/export parity checks remain retained; no
additional build, proof or test workload was started for that read-only review.

## Core scalar and loop integration review

Two additional independent read-only reviewers examined the core integration at
`410ed2c83e` with the applied delivery metadata. Both found **no material
findings** in the scopes below. These checks supplement the earlier records;
they do not infer review coverage from successful proof runs. Neither reviewer
edited files or ran tests, native proofs or Lean builds. The manifest retains
the reviewed source hashes.

The semantic/source reviewer followed:

- `ScalarExpressionAdmission.admission_iff` and `at_safe`, the scalar literal/
  expression grammar and source correspondence, and
  `IntegerExpressions.infer_sound` through checked execution. Admission uses
  explicit grammar, resource bounds and intermediate-interval safety.
- `ComposeScalarDeclarations.scalar_declaration_checked`, the ordered scalar
  traces, `ComposeInitializerTrace.initializer_checks_discharge`,
  `PredicateHeaderDecode.prefix_decoded_valid` and
  `PredicateGrammar.meaning_initializer_trace`. Raw String Image initializer
  arithmetic remains in the check inventory after `freezeImages`
  specialization; it is not lost when scalar values become known.
- `IntegerIteration` and `PredicateExecution.iterations_execution_sound` /
  `statement_execution_sound`. Bounds are evaluated once in the incoming scalar
  store. Finite ascending/reverse traversal handles null ranges, threads String
  state/effects, restores the scoped index and justifies the post-facts for
  empty, definitely nonempty and uncertain loops.
- `PredicateObligations`, `PredicateComposition.Program.all_obligations_discharge`,
  `PredicateChecks` and `Current.all_obligations_discharge`. The complete modeled
  inventory retains scalar declaration initializers, unfrozen Image initializer
  arithmetic, both loop-bound expressions and body paths. The source-specific
  theorem is distinct from the deliberately narrower uniform
  `automaticDischarge` certificate.
- `PredicateSourceBridge`, `PredicateEquations`, the loop helper/import
  interpretation, and `PredicateCorrespondence.executable_main_correct` /
  `executable_pipeline`. These wire the full source-specific result into the
  endpoint. `Predicate.completed` describes invalid-input rejection, not
  external solver completion.

The native/report reviewer followed:

- `Silver_Output_Profile.Read_Form`, `Accepts`, `Uses_Arguments`,
  `Uses_Assignment` and loop propagation of classification flags through
  `Silver.Compile`'s application-kind selection, `Proof_Command`, `Read_Proof`
  and build/publication gates. The command includes `--no-loop-unrolling`.
- `Silver_Report_Reader.Read_Report`,
  `Silver_Report_Projection_Audit.Application` / `Runtime` and
  `Silver_Libraries.Check_Proof_Evidence`. Complete reads and raw/projected
  policy correspondence feed mandatory acceptance.
- The executable, bounded and unbounded `Silver_Library_Reports` policies,
  application-kind alternatives, proved/info Main overflow checks, exact Image
  advisory classification, `Mixed_Record_Congruence` and `Mixed_Object`.
  Projection preserves `warn_error` bytes; advisories cannot replace safety
  checks. The 16,777,216-byte application storage exceeds the separately derived
  15,028,224-byte extended envelope; runtime limits remain unchanged.

The source chain retains typed source interpretation and callee links, native
contracts/wrapper refinement, complete native obligation coverage and the
external tool completion/preservation boundary. No hidden solver-success or
Image-assertion premise was found. The native review inspected capacity wiring;
it did not independently reconstruct the entire producer/front-end size
calculation. The known `SequenceNativeState` failure and repair
`d313c43f30` were outside this core review target; the separate validated
integration/addendum below records their final disposition.

## Reviewed assurance connections

| Connection | Review result and retained boundary |
| --- | --- |
| Scalar and loop source composition | The changed native output groups map to typed source interpretations, callee links and independent complete source pins. Grouped arithmetic, bound evaluation, scoped indexes, path joins and Image-sensitive String lengths are covered by the recorded scalar, Predicate and Compose chain. A source pin alone is not the semantic argument. |
| Exact selected producer schemas | Constructor-directed reconstruction matches every field and canonical byte of Integer, String and Image. The Standard-before-current-unit route, fixed metadata/fresh translation lifecycle, printing-plan uniqueness and Image dependencies establish the precise external producer contract for Main and fixed-library invocations. Samples are not the applicability argument. |
| Forward scanner completion | `ProducerSchemas.envelope` derives the scanner requirements from exact erased schemas and finite template validity. `producer_finishes` and `FilesSource.native_producer_finishes` derive the appropriate initialized Finish result, including models without Image. Scanner acceptance, matcher state and offsets are not producer premises. |
| Complete JSON and original bytes | `ImageModelRefinement` and `FilesSource.native_refined_document` connect selected schemas and derived offsets to complete transformed-document spelling. The native file contract and syntax-splice results retain original bytes in order; erasing the two inserted spans recovers the original file. All 23 inserted IDs are unique, fresh and representable. |
| Finite consumer interpretation | `ImageModelConsumerBoundary` restricts its constructor law to the actual checked `Clone.substitutions` and exact clone/include shape. Complete selected schema identities and a valid original typed context resolve the qualified type/function roles. `RefinedDocument.consumer_instance` uses the same actual refined entry/output spelling, derives its Image scope and the interpreted signature, then obtains the Image assertion. |
| Report policy | Current Main safety handling accepts proved range, length and overflow classes with their required provenance. Raw/report-projection congruence includes overflow. The precise Image advisory is classified independently and waives no required safety check. The earlier shared-binding range/length policy is retained as history. |
| Delivery scope | The coordinated metadata admits only the selected immutable signed-32-bit scalar, inclusive forward/reverse loop and standard Integer Image fragment. The shared arithmetic/concatenation budget is explicit. Broader integer forms, mutable scalar objects, custom subtypes and other scalar images remain excluded. |

The final source argument consists of separate producer, initialized native
execution, document-refinement, byte-recovery and consumer lemmas. The consumer
endpoint establishes interpretation of the inserted occurrence; byte recovery
is retained separately by `FilesSource.native_refined_document`. This review
does not present a single theorem covering the entire CLI, shell, filesystem,
external tools or solver execution.

## External premises and reviewed corrections

The following assumptions remain explicit in the
[trusted boundary](../trusted-boundary.md#image-proof-adapter-boundary):

- The faithful pinned producer supplies Standard metadata, complete selected
  schemas, unique selected names, dependencies and the independent broad
  serialization grammar. Complete automatic discharge additionally requires
  every admitted Main Integer Image occurrence to use the reviewed
  `Standard_String__Img.to_string` translation at size 12. The scanner does
  not inspect Main occurrences; the [pinned translation routes](../trusted-boundary.md#image-proof-adapter-boundary)
  state this applicability premise and its producer-change recheck trigger. Its occurrence counter stays in the intended Natural
  domain for the configured scope. Binary inspection found an unchecked
  increment; the source subtype is not a runtime enforcement proof, and no
  universal per-node or generated-model size theorem is claimed.
- A completed stable regular model file fits the supported signed-64-bit
  filesystem representation. Complete document punctuation derives the
  per-theory scanner room from that whole-file premise. This argument is
  separate from the producer's machine counters and from scanner acceptance.
- Partial external JSON parser soundness preserves semantic integer values and
  independently valid spellings; successful parsing is assumed only for the
  three finite canonical templates. Arbitrary raw-number serialization is not
  assumed injective, and unbounded numeric-token parse success is not assumed.
- The original model is a valid typed name environment, including namespace
  uniqueness, and external lookup selects the exact checked
  `silver_image.Integer_Image_Length` text. The finite constructor and primitive
  correspondence laws interpret the actual fixed substitutions. Their
  `Signature` is a predefined-source semantic view of symbolic instantiation,
  not the OCaml return type or a solver result. Neither scanner acceptance nor
  an Image assertion nor solver success is a consumer-interpretation premise.
- Matching external tools, stable inputs, successful infrastructure operations,
  sufficient resources and the documented bounded-fragment solver completion
  remain external premises. Silver-owned source correspondence, acceptance and
  complete obligation handling are not delegated to these premises.

The reviewed `W_` array-head argument covers every primitive string-leading
array family. Labels have safe fixed prefixes or copy existing safe sets;
source literals use numeric character nodes. Source locations use simple
filenames, so directory prefixes cannot become array heads. The installed
runtime/GNATprove Ada-source inventory covers vendor basenames as well as
`main.adb` and owned `silver_*` files. The stale narrower filename wording and
an over-early statement that final audits were already recorded were corrected
before this review snapshot.

The consumer law was narrowed before the target commit to the actual checked
substitution list. Equal decoded role rows alone do not establish acceptance
of arbitrary malformed trees. The final independent consumer review found no
remaining material issue in the exact constructor, schema, scope, signature or
assertion connection.

## Delivery metadata and Rosetta evidence

The reviewed language/catalogue/sample draft adds three motivating programs:
the nested triangle, computed step sequence and reverse countdown. The step
example computes `(I * Step)` while the immutable index advances by one; it
introduces no stride clause. Integer Image retains Ada's leading space for
nonnegative values and its minus sign for negative values. Sample expectations
are byte-specific and do not substitute for universal assurance.

All 1,743 changed Rosetta tracked files in the applied snapshot match the
reviewed isolated draft byte for byte. Exactly three of 1,782 assessment records
change: Loops/For, Loops/Downward for and Loops/For with a specified step.
Only `integer-for-loops`, `immutable-integers` and `integer-image` are added to
supported identifiers. The broad `for-loops`, `integers` and `scalar-image`
identifiers remain unsupported. The drivers move to stage 1; residual broad
forms remain stage 2, procedures stage 3 and arrays stage 4. Other generated
pages change only their progression line or surface heading. The
[Rosetta review](../../rosetta/for-loops-delivery-review.md) records the prior
two renderer tests and determinism check; this read-only comparison did not
repeat those tests or authorize a later stage.

The 13-file delivery-document patch passed strict applicability/whitespace
checking and all 32 added local links/anchors resolved. Both constructor
reconstruction scripts passed complete tree and canonical-byte parity against
the current native template source. Those are documentation/source-review
checks; they are not the complete compiler or whole-project proof checkpoint.

## Validation evidence and repair addendum

The focused final consumer run `20261016T181946-7b6c0b241b3c` passed
`Silver.ImageConsumerEndpoint` and a fresh 15,974-declaration axiom audit on
Linux x86_64. Its evidence records `clean_build: false`; retained matching
artifacts were reused, and no independent kernel replay is claimed. The exact
input digest and evidence-file hash are in the review manifest. Earlier source,
selector, finite-validity and Compose checks retain their recorded scopes in
the capability and source-review records.

The initial complete Lean run `20261016T182210-c5c7e1fc74a1` failed in
`SequenceNativeState` because earlier context/state conversions omitted the
scalar environment. Successful source certificates and the failed diagnostic
remain retained. The repair is five proof files only, integrated as
`e962f6c130` and `b5cd3f0231` from lane commits `d313c43f30` and `9387c14e2c`:

- `SequenceNativeState` carries scalar names through context conversion,
  expansion and validity proofs.
- `SequenceBodyContext` preserves scalar-name equality through body scans.
- `SequenceNativeExpressions` renders the actual scalar fields in the typed
  conversion bodies.
- `SequenceNativeProjection` passes the actual scalar environment through
  expression progress/validity and context preservation.
- `SequenceEquations` supplies validity of the empty initial scalar environment.

Root and an independent reviewer checked the repair; the planning reviewer also
inspected all five final diffs and found no material issue. No native source,
script, language rule or obligation was weakened. Focused run
`20261016T183321-18be4f8b7386` passed `SequenceEquations` with a fresh
17,497-declaration audit before integration.

The subsequent complete root run `20261016T183420-1c5451b2e0df` passed all
458 modules and a fresh 87,185-declaration axiom audit on Linux x86_64 with
Lean 4.34.1, four Lake workers and one thread per process. It reused matching
artifacts, took 21.189 seconds as recorded by the evidence file and was not a
clean rebuild or optional independent kernel replay. The exact tool/input
digests and evidence hash are retained in the durable validation record.

That complete Lean result predates the native-audit repairs below. It remains
successful evidence for its recorded inputs; the changed Ada grouping and its
matching Lean correspondence require a new final input-specific checkpoint.
The successful repaired native and root proof results are recorded below for
their actual workspaces; the full-suite and focused snapshot-repair results are
recorded separately below. Source equality
does not turn a focused result into a complete audit.

## Native audit findings and repaired validation

Original full native run `20261016T174150-cf80d84be8db` on Linux x86_64 took
7,957.651 seconds. GNATprove exited zero with all 15,083 checks proved and
74 unit reports retained, but the following audit failed. The managed run's
outcome is **failure**; prover success is not complete delivery validation.
The original log, reports and ledger remain retained with their hashes in the
validation record.

- **#48, low: exact vendor-conversion classification.** The first audit failure
  was `silver_image_files: entity outside full SPARK`. Two `spec` entries,
  `Silver_Image_Files.Counts.To_Big_Integer` and `From_Big_Integer`, originate
  at `a-nbnbin.ads:82:16` and `85:16`, each instantiated at
  `silver_image_files.ads:16:4`. The instance package itself has `all`
  coverage. These are the actual vendor `Signed_Conversions (Model.Byte_Count)`
  operations omitted by the exact classifier, not unproved Silver-owned bodies.
  The repair must validate the source instance and exact declaration origins,
  retaining rejection of other entities and every owned-code obligation.
- **#49, low: explicit ceiling-expression grouping.** Inspection of the retained
  report then found `possible reassociation due to missing parentheses
  [operator-reassociation]` at `silver_length_intervals.adb:24:50`.
  Replacing `(Numerator + Difference - 1) / Difference` with
  `((Numerator + Difference) - 1) / Difference` states the intended grouping.
  The Ada change, matching Lean source interpretation/equations and source pins
  must be reviewed together; a matching pin alone is insufficient.

Both findings are confirmed. The #49 Ada/Lean repair was integrated as
`19b2f6c6b6` from `515a23fee9`, changing only `silver_length_intervals.adb`,
`LengthIntervalExpressions.lean` and `LengthIntervalsCapture.lean`. Root reviewed
the actual grouped evaluation and exact capture. Focused `LengthIntervalsSource`
run `20261016T200019-35e244ca5e83` passed a fresh 10,850-declaration audit in
62.645 seconds with two workers and one thread per process. It does not replace
complete validation. #48's checker/test repair was integrated as `4cd2fe8aae`
from `ab2f7dd5cc`, changing only `scripts/check_evidence.py` and
`tests/test_evidence.py`. It validates the actual source context, generic/type
instance and both exact vendor declarations; rejected counts/origins are now
reported without changing owned coverage. Root reviewed the final actual diff
with no material finding. A separate reviewer approved the diagnosis and
approach before that final diff; that narrower review is not presented as a
final-diff review. Focused run `20261016T200038-4ff6886d5c6a` passed all 53
`test_evidence.py` tests in 1.403 seconds (managed elapsed 2.038 seconds).
Both repairs are integrated. Complete repaired root Lean run
`20261016T200453-9fe1b554e036` passed all 458 modules and a fresh
87,185-declaration audit with base `4cd2fe8aae` plus coordinated working-tree
content, including the delivered catalogue source. It used
Lean 4.34.1, four workers and one thread per process: build 17.115 seconds,
audit 4.279 seconds, evidence elapsed 25.420 seconds (ledger 25.113 seconds).
Five source-matched artifact groups were manually reused in the final
restoration step after comparing 462 proof inputs and 32 bound-native sources.
That step does not describe all objects previously assembled from other
workspaces. Lake's dependency traces selected reuse; the final run elaborated
11 modules. The [cache inventory](../evidence/for-loops-integers/delivery-cache-inventory.json)
and correction below retain the origins and trust boundary. This is a cached
build with a fresh audit, not a clean rebuild or independent kernel replay. Its input digest and evidence
hash are in the durable record. The scalar/native lane owns repaired native run
`20261016T200519-b3b644edcb13`, which completed successfully at 20:05:59 UTC.
The cached native run took 40.299 seconds overall (native phase 31.587 seconds,
audit 5.377 seconds). All 15,083 checks proved; the complete audit covered
74 units and 991 entities, with 1,283 flow and 13,800 proof checks, 290 limitation
notes, 17 imports, 6,236 trusted mathematical notes and 62 exact vendor specs.
Its retained `proof-evidence` contains 78 files; the provenance manifest has
SHA256 `af2522a3bec4ace16e420dfd6e735059e458b7f6a2f665c7e35957107bcce2e3`. The repaired native checkpoint used the existing full cached runner after the
actual changes, without new re-audit tooling. Focused positive/negative checker regressions and focused/complete Lean checks
are recorded above. Complete native audit/provenance and full Lean validation also passed as
recorded above. Both low findings are repaired and validated; their closure
remains part of the coordinated delivery commit after full regression/sample
results. Compiler/adapter build `20261016T200635-f7611c4d608c` passed in
3.899 seconds. Full test run `20261016T200650-91510d356211` completed with four workers; its
failed original result and focused repair are recorded below. The original failed run is never relabelled.
The #48/#49 repair target is `4cd2fe8aae`; its coordinated execution inputs
are distinguished above. Root's final-diff review and the separate
independent diagnosis/approach review retain their actual scopes.

## Certificate snapshot finding and focused recheck

Full suite `20261016T200650-91510d356211` completed 450 tests in 1,355.313
seconds (1,355.967 seconds managed) and exposed four failing
subtests in `CompilerSourcePolicyTests.test_checked_in_certificates_equal_regeneration`.
The initial explanation attributed this to isolated native-lane snapshots outside
an earlier synchronization set. That explanation was corrected: the failing
`OutputSpecCertificate`, `OutputBodyCertificate`,
`ScalarExpressionSpecCertificate` and `ScalarExpressionBodyCertificate`
snapshots already equalled root's checked-in `4cd2fe8aae` versions. The Output
snapshots lagged existing Ada source; the ScalarExpression differences were only
the generator comment's curly-to-ASCII apostrophe. This was not a new native
source defect.

Confirmed low finding [#50](https://github.com/berkeleynerd/silver/issues/50) was
repaired at `62f472c35d` by refreshing exactly those four generated snapshots.
Root checked their byte equality with the successful complete Lean workspace
and independent native-lane regeneration. The authoritative shared-input digest
remained `15412eec1ffa7bf87e2b8aa0abac38474261f68cb85bd9f366ae9f530fbf0ff8`;
the validated workspace bytes also remained unchanged. The runner's
`capture_shared_inputs` excludes generated `CANDIDATES`, while its workspace
capture records the actual regenerated bytes. The full Lean evidence remains
valid for these identical inputs/workspace, and no native or Lean reproof/build
was needed or performed for the snapshot refresh. Before/after snapshot hashes
are retained in the durable validation record.

Root focused run `20261016T202127-4facdb2ce8b3` passed the affected method across
all 26 certificate/source pairs: 2.163 seconds test time, 2.919 seconds managed
elapsed. The original full suite remains a failure with exit 1, exactly those
four subcases and no additional failures/errors; all 21 manifest samples passed,
including the three new loop samples with byte-specific expected output. The
native lane synchronized the four snapshots and verified byte identity at
20:30:13 UTC. All 26 snapshots match root/regeneration and all 204 native
code/test/sample inputs match root. The synchronization manifest has SHA256
`704dcdf7ef492a5af88a4074730fc4d4789d088724bc6ad9bdca6c6a6ffea008`;
its exact file hashes are retained in the durable validation record. Root already
passed the exact affected
method at the final snapshot; no duplicate native-lane test is required. This
full-suite/focused-repair combination establishes the repaired regression
coverage for its recorded input scopes and is not a single clean passing
full-suite run. The suite used the lane's older proof tree, while the root
certificate recheck and complete Lean run covered their separately recorded
delivered inputs; the later review checks below address proof-tree-sensitive
tests. #50 is repaired and validated; closure follows through the coordinated delivery
commit, together with #48/#49 and the milestone work packages.

Delivery updates the language, catalogue, samples, roadmap and Rosetta stage
records together and closes the tracked work through the completion commit.
Native macOS validation remains independent and nonblocking; no hosted CI
result or clean rebuild is inferred from these checks. CLI memory was
unavailable and was not updated.


## Subsequent input-record correction — review b8f1d0b9a8

The [independent post-delivery review](review-b8f1d0b9a8.md) confirmed the
native and complete Lean evidence applies to delivered content, while finding
the base-commit labels and full-suite proof-tree disclosure incomplete. The
[corrected manifest](../evidence/for-loops-integers/delivery-validation.json)
retains the original outcomes and hashes. Native `silver_catalogue.adb` was
already the delivered version during execution; base `4cd2fe8aae` contains an
older version and does not alone reproduce the native or Lean input digest.

The regression lane recorded 343 proof-directory files (340 `.lean`), versus
462 (459 `.lean`) in delivery: 39 differed and 119 modules were absent.
Its native/test/sample inputs matched delivery. The 204-file sync consists
of 128 `src/`, nine `scripts/`, 44 `tests/`, 22 `samples/` and one
`catalogue/` file; it excludes `proof/`. The review independently ran the
affected proof-tree-sensitive tests on the delivered tree with documented
native-Lean skips. Those results are retained as review evidence, not
relabeled as a managed full-suite pass or repeated for this correction.

Artifact reuse was manual and accumulated over several workspaces; the final
five-group restoration was not the whole history. The review's all-trace
inventory identified 255 foreign-origin modules and reported matching hashes
for 457 closure objects and 847 import entries. A later
[retrospective inventory](../evidence/for-loops-integers/delivery-cache-inventory.json)
records origins, trace hashes and retained object hashes for the final run's
458-module list, before remediation proof work. Its different scope and
collection time are explicit. Neither inventory is an execution-time import
log. Lake matching and honest local cache records remain assumptions; these
records add no claim of a clean build, kernel replay or binary attestation.

Original finding aliases are #48/L1 (vendor conversion), #49/L2 (grouping)
and #50/L3 (certificate snapshots). They are separate from L1–L15 in the
post-delivery review. [The remediation record](../review-b8f1d0b9a8-repairs.md)
tracks that later disposition without reopening the completed milestone.
