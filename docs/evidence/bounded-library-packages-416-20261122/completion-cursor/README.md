# Signature result cursor

Authorized #416 Completion caller-domain closure, 2026-11-27. Selected proof
role: Astra Max; live model/effort is not independently exposed.

`readSignature_header_cursor` bounds the header position for both modes and
every result, including partial-write failures. No valid-frame, valid-metadata
or successful-result premise is used. Early returns have zero position; the
successful final position is bounded by the original `is` or semicolon token.

Focused managed run `20261127T221423-1fe24d9d68b3` passed with a fresh axiom audit
of 46,846 declarations. Linux x86-64 / Lean 4.34.1, explicit affinity 4–5, two
workers, two threads/process and 8192 MiB/process; prerequisites were cached.
The captured input comparison is retained in `input-recheck.json`.

Three preceding focused attempts exposed local tactic issues: an implicit
induction state, an unnecessary `dsimp`, and a split selecting an inner guard.
The final proof uses an explicit result conditional lemma. These were not
domain changes; no source change or increased proof budget was needed. The
managed checkpoint records the diagnosis. This is focused helper evidence,
not a complete native or repository assurance claim.
