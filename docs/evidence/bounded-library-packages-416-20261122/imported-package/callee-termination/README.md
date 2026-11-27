# Import-scanner callee domains and termination

Linux focused run `20261127T151131-ab9ff5025a7b` passed
`Silver.ApplicationPackageImportImports` and its dependency closure, with a
fresh **35,602-declaration** axiom audit. It used two managed workers, two threads
per Lean process and an 8,192 MiB per-process limit, sharing the host's eight-CPU
allocation. Ordinary Lake reuse applies; no full build or kernel replay is claimed.

`innerStep_meaning`, `innerLoop_meaning` and `outerStep_meaning` discharge the
lexical and package calls only on their native domains. Cursor/name bounds come
from the actual guards and scanner results. Both loops retain the original
candidate span and advance on every repeating iteration. `innerLoop_total` and
`outerLoop_total` establish finite execution including rejected inputs;
source length plus two supplies enough fuel. `execute_imports` combines these
results with the complete typed-tree execution and existing source-interpretation
premises for lexical/package operations and normalization, for arbitrary scratch
storage. It neither assumes successful package admission nor imposes a new
language bound.

The recorded input map is in `events.jsonl.gz`. This private workspace reused
the previously disclosed cache seed and synchronized the already-checked
package-name primitive modules from the integration branch. Its full Ada snapshot
still has output-profile digest `c37214cd9bc8772c84b2f4cd775d6582748e4499f829bf282bfe81e1264871af`;
the import-scanner body is unchanged on the current integration source. This
run proves the scanner's execution, primitive-domain and termination arguments.
Binding its candidate to the current authoritative full-profile certificate is
the separate queued source checkpoint. No complete feature assurance is claimed.

Earlier source-callee attempts remain failed. Their retained driver logs include
the missing synchronized module, its older token-contract mismatch and the
subsequent record-projection/normalization repairs. No domain, native contract,
proof budget or required obligation was weakened to obtain this success.
