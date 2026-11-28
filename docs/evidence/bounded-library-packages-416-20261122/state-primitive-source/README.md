# State-validity primitive source checks — 2026-11-27

Focused run `20261127T124051-b297166e4b86` passed `Silver.ApplicationStateValidityImports` and
`Silver.ApplicationStateValidityPrimitiveCandidate`, with a fresh axiom audit
of 29,016 declarations. The only foundations remain `propext`,
`Classical.choice` and `Quot.sound`. Linux x86-64, Lean 4.34.1, two managed
workers and two threads per process, within the host's eight-CPU allocation.

The imported Valid_State interpretation now evaluates both its direct
Valid_Name_State calls and all six table helpers through the checked primitive
trees. Full function/procedure/array metadata subtype domains remain explicit;
no successful parsing or table-validity premise is added. The two primitive
source proposals include the exact headers, expression bodies, precedence and
scope checks. Their final connection to certified original lexical/profile
source remains pending in the aggregate source check.

Earlier run `20261127T123724-a695a09bea93` checked the primitive source
candidate and six-table wiring in 162.127 seconds of build/audit phases.
This follow-up adds the direct name-state wiring, reuses that unchanged
candidate through ordinary Lake checks, and audits the full imported closure.
The earlier copied dependency seed is disclosed in `../support-domain-closure/`.
The retained events contain the exact captured input maps; neither run is a
cold build or kernel replay. No complete feature assurance is claimed.

Proof work followed the repository's Astra Max role selection. Runtime-confirmed
model and effort are not independently exposed.
