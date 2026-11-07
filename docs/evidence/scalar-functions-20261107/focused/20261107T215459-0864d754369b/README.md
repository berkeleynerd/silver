# Native function source bridge and model evidence

This is focused Linux evidence for #298, not complete delivery assurance.
Managed run `20261107T215459-0864d754369b` passed the
`Silver.FunctionDeclarationSourceBridge` and
`Silver.FunctionDeclarationModelSource` targets and their transitive closure:
258 build jobs and a fresh axiom audit of 30,919 declarations. The audit retained
only `propext`, `Classical.choice`, and `Quot.sound`.

The run used Lean 4.34.1 on `linux-x86_64`, four Lake workers and 22 threads per
Lean process. The incremental build reused accepted dependency objects; no clean
build or independent kernel replay is claimed. Build time was 111.772 seconds;
audit time was 21.453 seconds, ending at 2026-11-07 21:58:25 UTC.

The checked implementation is retained in commits `2b881165b4` (the lead's exact
call-helper normalization repair), `6cd11b595b` (source libraries and bridge),
and `6138f8d447` (model traversal contracts and concrete interpretation). These
commits contain the corresponding captured proof inputs; their hashes were
checked against the run's input manifest when this packet was retained.
`events.jsonl.gz` preserves the complete captured input identities, command,
resource settings, fingerprint, and outcome. The other two files retain the
structured evidence and full streamed build/audit log verbatim.

The concrete `model_interpreted` witness supplies the checked definition and
contract equations, direct library links, and existing model denotations. Its
inherited premise is `RawHelperEquations` plus the independently interpreted
Boolean declaration equation. It does not take a whole function-declaration or
body-scanner/model equivalence as a premise. The arbitrary-callee declaration
meaning is derived by the source bridge; model inhabitation establishes that the
interface is populated and is not a replacement for native source interpretation.

`HeaderLinks.take` states the direct callee identity at `.fixed word flag`
calls, matching every function-helper token callsite. This corrects an overbroad
identity on synthetic `ShellToken` cases. `HeaderLexical`, `ValidToken`, and all
native state domains are unchanged. There is no source-history restriction.

The complete native obligation audit, authoritative source candidates, outer
source integration, and complete assurance on final integrated inputs remain
required. In particular this run does not establish native discharge of the
strengthened `Function_Body_At` formal-pool precondition in `e56af1b1a2`.

The following SHA-256 values identify the uncompressed retained bytes:

| Artifact | SHA-256 |
| --- | --- |
| `events.jsonl.gz` | `e15d2a9758d0e322fc2477b884afee17e11e03a9e4a54b36960abaa1e61945ab` |
| `lean-focused-evidence.json.gz` | `827817e1c6e7c17142b9e0f18566134fa07f4d8c534602524cac345ca8ca18a7` |
| `lean-focused.log.gz` | `0d7fbb2a14550de6c0d178c94eaee8d61fab069ea7cc0fc845356d7e4cc0086d` |
