TITLE: Unbounded programs: Parameterized Lean assurance
LABELS: type: work package, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in session memory. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#research-evidence) and its [evidence record](https://github.com/berkeleynerd/silver/blob/main/docs/evidence/unbounded-programs/scoping-research.json) govern it.

**Order 5.** Generalize the Lean assurance from the 4096-byte bound to symbolic limits. Admitted programs do not change.

- **One source of truth.** One named Lean constant per limit, tied to the native tokens for the source length, value domain, identifier, exponent and, while they exist, the operand and operator limits. This replaces the hard-coded `4096`/`4097` legal-domain literals.
- **Exact length-range schema.** Replace the uniform ⟨L,L⟩ length-range schema and the coefficient-wise `Refines` with the exact sum schema S + K·C ≤ V ≤ 2,147,483,647, using the pinned target's `Integer'Last`. Retire or restate the historical `Guarded.uniform*` theorems. This is the only change to what is true: today's schema is valid only while 2L ≤ 32,767, so any bound of 16,384 or more makes `Current.uniform_discharge` false.
- **Split roles.** Separate the roles of `maxSourceLength` (source, value, argument, per-call output, exponent, identifier) with order lemmas where needed.
- **Parameterized theorems.** Quantify the theorems over a capacity record with minimal side conditions. Repair the proof-local roots, and instantiate examples at concrete values next to the bounds they test.
- Restate the trusted premise for String index arithmetic in terms of the pinned target's `Integer'Last`.

**Completion criteria**

- Each step builds in focused targets with a fresh axiom audit allowing only `propext`, `Classical.choice` and `Quot.sound`. The complete Lean run belongs to the milestone checkpoint.
- Top-level theorems carry no size hypothesis beyond the explicit limits.
- Certificates and source pins are regenerated together with #{D}, with one proof-workspace writer at a time.
