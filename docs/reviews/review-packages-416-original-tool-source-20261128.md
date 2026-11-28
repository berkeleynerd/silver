# Original package tool/source endpoint review — 2026-11-28

No consequential semantic or contract finding in the two new endpoint modules
reviewed below. Their proof argument retains the original Bundle, derives the
complete finite obligation fragment from native acceptance, and composes the
same-source tool and runtime boundary. The initial authoritative-source draft
still has a known namespace elaboration correction pending; its final validation
is not claimed by this review.

The lead requested this independent, read-only review within owner-authorized
#416 completion and #428 repair. The unchanged Oracle requires original-source
correspondence, complete obligation discharge, every admitted input and path,
and no assumed accepted-program checker/safety certificate. This review owns
only this report in `tmp/packages-416-visibility-proof`; no implementation,
proof artifact or shared validation job was changed or started.

Reviewer selection: GPT-6 Astra, Max, for critical proof review. Runtime model
and effort are not independently exposed by available tools. Total review
elapsed time, tokens and cost are not measured. Actual host: Linux x86-64.
No proof workers were reserved; CPUs 4–5 remain with the coordinated validation
stream. The live harness goal is absent, and no CLI memory update was performed.

The reviewed checkout is `tmp/packages-416-proof`, based at
`01144d9a99e26aed1400ee516d9fbeb4a5eb9dde`. Both targets were uncommitted new
files with their dependency closure synchronized separately; the hashes below,
not the base commit alone, identify the reviewed implementation. Their complete
contents were inspected.

| File under `proof/Silver/` | SHA256 |
| --- | --- |
| `ApplicationPackageOriginalToolAssurance.lean` | `865a810a9df5e54eb8623dd063f4ab7eadcb7f627cd9a01263918d12f63d90b4` |
| Initial `ApplicationPackageOriginalSourceAssurance.lean` | `e3578de943084aea9d221c38d1b7ce60448de8c01b176d7717988ee68a4c0ef2` |

The directly inspected context includes the already-reviewed aggregate source
relations and their semantic/runtime results, the native wrapper interpretation,
the actual extraction companion, exact schema refinement, and the native library
interfaces. The critical context hashes are:

| File under `proof/Silver/` | SHA256 |
| --- | --- |
| `ApplicationPackageOriginalAssembly.lean` | `7a8ca8e2fe2d9b3cb491c3f69053cdd07f4a14ad43aee6f76a64190537b8aa21` |
| `ApplicationPackageOriginalAssurance.lean` | `a9fa9c89f3e36ef854dab3732335814856cf52a0754293be476bb43ffce7f42b` |
| `ApplicationPackageSourceBridge.lean` | `aab4513d00b781c8edc037af33daaabbdb69122d240ea4b60665059fda5a1812` |
| `ApplicationPackageSourceActual.lean` | `33f4da999838b7a4affbcc967011ced780be5b9e6a30c6690f6b197a601eca39` |
| `PredicateChecks.lean` | `f532c833dfb5021b62a13aaa37076b52f651cfa69c500bb494c4dd838c54e18c` |
| `ApplicationPackageMainRuntimeInitialization.lean` | `8286a003dbd4ff3db6df0c9f3ba3d0abbf10138f775796b1d775c272dcab53d2` |

The substantive checks were:

- **Complete exact typed inventory.** ToolAssurance lines 19–67 wrap the full
  original package header and routine obligations plus Main's String/Character,
  predicate and canonical Boolean declarations. `checks_exact` proves equality
  after mapping to `Semantics.Obligation`; no list filter or caller-supplied
  coverage relation appears. The previously reviewed raw package-local and
  Main/local-callable range families remain inside those aggregates. Fragment
  membership is derived from the separate semantic discharge result. The
  String range case additionally proves the required uniform coefficient
  domination from original declaration validity, rather than replacing
  `Check.InFragment` with a bare discharge Boolean.
- **Source-only executable witness.** ToolAssurance lines 84–113 retain
  `Program context sources`, its original `SourceMeaning`, and the original
  optional argument/fallback reading. `NativeFacts`, `Checked` and `Semantic`
  remain separate derived propositions. `Program.admitted` obtains the native
  whole-application acceptance equation from the same parsed Main result.
  Admission does not mention external proof or build success.
- **Same Bundle through the tool boundary.** ToolAssurance lines 186–219 and
  248–279 keep the Bundle as the index of every Program and as the explicit
  parse/build input. Generation receives that exact Program, proof receives
  its emitted check list, and the pipeline retains the corresponding artifact.
  Parse completion is required for admitted represented Bundle/Program pairs;
  generation and build completion start from that parse. This introduces no
  demand for unrelated source/program combinations and removes no represented
  native-accepted case from the final theorem. Scalar/path schema refinement
  remains exact; optimized String refinements use the existing checked rule.
- **Derived runtime initialization.** ToolAssurance lines 115–181 execute the
  retained original code with its imported package environment, package initial
  state, and Main's source-derived String, Integer and Boolean stores.
  `effects_valid` uses the Program's own argument witness for every runtime
  argument list. It derives the specification array seed, runtime store facts
  and initial flow before invoking statement soundness. It does not identify
  independent existential fallbacks without proof or require a fitting store
  from the caller. Lines 281–303 compose the specified external failure trace
  and healthy-output result with compilation preservation and realization.
- **Native acceptance to authoritative-source endpoint.** SourceAssurance
  lines 20–72 retain the existing full-domain native import interpretations and
  exact reader identities. `Imports.native` constructs the literal compiler
  extraction checks internally; `Imports.context` uses those same imports.
  `accepted_assurance` starts from the represented native `Analyze` call with
  arbitrary caller locals and obtains the original source witness, all checking
  and semantic facts, initialization, bounds and runtime safety as conclusions.
  `Bundle.Representable` is the native array/subtype storage domain; layout and
  successful parsing are derived separately. The final theorem at lines 78–107
  uses that witness to derive exact inventory equality, fragment membership,
  terminating discharge and the same-Bundle pipeline for every environment.
- **Explicit assumptions and consistency model.** Solver completion is a
  `ToolContract` hypothesis for the derived concrete schema fragment, not an
  axiom that accepted programs prove or a new membership rule. Faithful complete
  external generation, permitted static elimination, fixed-library proof
  completion and compilation/runtime preservation remain the documented
  trusted-tool boundaries. The model at ToolAssurance lines 221–246 stores the
  exact Bundle/Program pair and witnesses interface consistency only; it is not
  evidence that physical GNAT/GNATprove tools satisfy the contract.

One already-identified mechanical issue is present in the initial
SourceAssurance hash: lines 35 and 50 use `ReaderEffectsImports` without opening
`ApplicationPackageSourceEffects`. The implementation owner identified the same
namespace correction before receiving this review. It does not change the proof
contract, but that initial draft is not a compiled final endpoint. The final
delta and validation disposition will be recorded here when handed off.

Retained tool-only validation was read, not repeated. Run
`20261128T053009-4006d59f4aab` built
`Silver.ApplicationPackageOriginalToolAssurance` and passed a fresh
96,229-declaration axiom audit on Linux x86-64 with Lean 4.34.1. Its captured
target hash equals the reviewed ToolAssurance bytes. It used two automatic
workers/threads and 8192 MiB per Lean process and took 28.661 seconds including
setup. Its audit allows only the documented `propext`, `Classical.choice` and
`Quot.sound` foundations. This review did not rehash its complete captured input
set or independently replay the kernel.

The coordinated actual-source batch `20261128T053127-9c8c703174a1` is pending at
this checkpoint. Its completion, exact final source hashes and retained input
verification remain validation work owned by the semantic integration stream.
This review does not establish a complete project/native checkpoint, discharge
physical-tool assumptions, review every transitive native import from scratch,
or authorize publication. The lead owns the independent review of the #428
standalone repair; this reviewer does not independently review its own change.
