# Complete Lean attempt — 2026-11-08

Run `20261108T044143-17a94f7033eb` actually exited with code 1 at
06:31:02 UTC. Managed elapsed was 6,555.248 seconds; the build phase took
6,510.333 seconds. Its frozen governed inputs are `2a3badff5c`; a post-run Git
comparison confirmed no changes to proof, native source, scripts, tests,
samples, catalogue or native project configuration. Later integration commits
contain documentation and retained evidence only.

The complete cached build used eight Lake workers, 22 threads per Lean process
and no configured memory limit on Linux x86_64. It did not run a clean build or
optional kernel replay. The final module/axiom audit was not reached, so this
packet is failed evidence and does not establish complete assurance.

Exactly three required targets failed:

- `ComposeBooleanDeclarationCandidate` reported a false `candidate_matches`
  proposition: its candidate omitted five hiding checks already present in
  both native source and the model. The retained exact patch adds those tokens
  and has independent static review.
- `ComposeExamples` was deliberately sent SIGTERM at 05:04:02 to preserve
  headroom for the running source proofs. Lake records code 143 after 287 seconds.
- `FunctionSourceCandidate` was deliberately sent SIGTERM at 05:12:10 after
  repeated falling available-memory observations below 12 GiB; recorded RSS/HWM
  reached 38.31 GiB. Lake records code 143 after 1,735 seconds. Its independently
  reviewed decomposition retains every source requirement in 80 separate leaves
  and the original complete exported conclusions.

Both interrupted modules remain mandatory. The action records identify the
verified individual processes; no native proof process or Lake parent was
signalled. The complete memory-observation stream is retained. These were
explicit preservation actions, not an observed OOM or an obligation waiver.

Productive checks finished and their local object families remain available:
CharacterSourceCandidate (681 s), ScalarBodyCandidate (3,169 s),
NativeHelpersCandidate (3,327 s), FlowSourceCandidate (4,014 s),
NativeShapeCandidate (5,775 s), then PredicateSourceCandidate (17 s).
Individual compiled modules are partial results, not a successful complete run.

The [index](index.json) records ten compressed artifacts, their original paths,
uncompressed sizes and SHA-256 identities. Integration independently decompressed
and verified every indexed artifact. It includes the managed events and exact
build log, both signal records, memory observations, exact Boolean patch and
comparison, and the source-packaging plan, inventory and patch. Private runtime
settings and token/cost measurements are unavailable; prior review reports
record selected Astra Extra High settings separately from runtime confirmation.

Next: apply the two statically reviewed patches after this released workspace,
check the named header leaf serially, then all function-source leaves and their
actual-source consumer, and finally the mandatory complete cached Lean build
with a fresh module/axiom audit. Preserve completed objects, native validation
and all original failed outcomes.
