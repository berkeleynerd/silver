TITLE: Unbounded programs: Parameterized Lean assurance
LABELS: type: work package, area: assurance
---
**Backlog; not authorized.** This package needs the owner's "proceed", recorded in a dated session-memory entry on `main`, before it moves to Ready. It depends on #{B} and shares source certificates with #{D}. The [scope proposal](https://github.com/berkeleynerd/silver/blob/main/docs/unbounded-programs.md#research-evidence) and its [evidence record](https://github.com/berkeleynerd/silver/blob/main/docs/evidence/unbounded-programs/scoping-research.json) govern it.

**Order 4.** Generalize the Lean assurance from the 4096-byte bounds to symbolic limits. Admission is unchanged.

- **One source of truth.** Each native constant that #{D} separates gets one named Lean constant with a mechanical digit-fold tie, like `OutputSourceBridge.lean:85-86`. This covers the source length, String value domain, identifier length, exponent and, while they exist, the operand and operator limits. It replaces the hard-coded `4096`/`4097` legal-domain literals.
- **Exact length-range schema.** Replace the uniform ⟨L,L⟩ length-range schema and the coefficient-wise `Refines` with the exact sum schema S + K·C ≤ V ≤ 2,147,483,647, using the pinned target's `Integer'Last`. Retire or restate the historical `Guarded.uniform*` theorems. Today's schema is valid only while 2L ≤ 32,767, so any bound of 16,384 or more makes `Current.uniform_discharge` false. Apart from the domain-coupling lemmas (`healthy_effect`, `selected_domain`, `default_is_message`), this is the only change to what is true.
- **Split roles.** Separate the source-length, String-value and length-literal roles of `maxSourceLength`. Relate them to `Output.Runtime.maxLength` (argument and per-call output) and `maxExponent` with order lemmas, and add an identifier-length constant.
- **Parameterized theorems.** Quantify the theorems over a capacity record with minimal side conditions. Repair the proof-local roots, and instantiate examples at concrete values next to the bounds they test.
- Restate the trusted premise for String index arithmetic in terms of the pinned target's `Integer'Last`.

**Completion criteria**

- Each step builds in focused targets with a fresh axiom audit allowing only `propext`, `Classical.choice` and `Quot.sound`. The complete Lean run belongs to the milestone checkpoint.
- The universal theorems' only size hypotheses are the explicit language limits and the recorded side conditions: minimum bounds, the order between the separate bounds, and V ≤ the pinned `Integer'Last`.
- Certificates and source pins are regenerated together with #{D}, with one proof-workspace writer at a time.
