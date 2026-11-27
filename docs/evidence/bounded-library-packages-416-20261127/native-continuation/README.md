# Remaining native package contracts — 2026-11-27

Linux x86-64, issue #416 / draft PR #424. Selected proof setting GPT-6 Astra
Max; actual runtime model/effort is not independently exposed. These are
canonical whole-helper `scripts/dev.py prove --subprogram` checks, retaining
the complete flow/proof contract, unchanged input domain, level 2,
cvc5/z3/altergo and the unchanged 30-second timeout. Each run reserves two
workers within the shared eight-CPU host. The summary and managed ledger retain
actual affinity, source/input hashes, target coverage and precise timings.

The retained Main/Analyze failures on November 27 exposed three composite Main
preconditions and one application body-prefix precondition. The new Signature
and Spec contracts export preservation of `Info.Units` on every return, with
loop invariants retaining the same fact. They accept the same arbitrary metadata
as before, including rejected declarations. The Main diagnostic decomposes the
existing metadata/name/context/flow/catalogue facts into checked Static assertions
and names its existing input expression. All original preconditions and
postconditions remain; no obligation or executable branch is removed.

| Complete helper | Canonical run | Outcome |
| --- | --- | --- |
| `Package_Signature_At`, body declaration 8395 | `20261127T184159-a0acf00fba2f` | 79/79 (14 flow, 65 proof), selected entity `all`; 1,020.794 seconds. |

The source for this checkpoint is Output_Profile SHA-256
`f91894e7a0f7088abd621313e731b71424fd031783faa5d8b9a2f3a180f699da`.
Each run subdirectory retains checked source snapshots, full selected SPARK
and SARIF reports, output summary, raw command log and managed ledger. Source
bytes were compared to each recorded managed input hash before retention.
The separate [namespace packet](../namespace-regressions/README.md) retains the
#426/#427 implementation fixes, actual frontend controls and direct caller checks.

Spec, Main, Analyze and their four public wrappers remain pending at this
checkpoint. Complete native, Lean, original-source correspondence and final
regression/sample checkpoints remain required; these focused results do not
establish feature completion.
