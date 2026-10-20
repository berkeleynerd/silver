# Fixed-domain warning-attempt exclusion, 2026-10-20

The [note](../../research/retained-why-warning-exclusion.md) proves the source
closure argument for the five selected retained library domains. Their
`GP_Check` attributes all map to nonwarning kinds, and the only loop-kind
refinements remain nonwarning. Under the accepted registration/metadata and
selected-continuation relation, scheduled attempts have `warning=false`.
The default one-second warning timeout is unreachable in these domains.

From the repository root:

```sh
python3 -B docs/evidence/retained-why-warning-exclusion-20261020/check.py
```

- `certificate.json` retains every classified label, raw/source-linked
  identities, old/fresh process joins and the explicit result scope.
- `source-witnesses.json` retains 22 slices and complete-member identities from
  the pinned Why3 source archive.
- `inputs.json` binds all consumed files, including this checker and its
  certificate, accepted atom/correspondence inputs and raw capture archives.
- `verification.json` and `round.json` record the focused check and its scope,
  selected settings and available timing.

The self-contained checker derives the source parser/kind partition, verifies
all stored term attribute memberships and captured attribute records/bytes,
checks label classification and joins the exact old/fresh graph identities to
the accepted status projection. It imports the accepted typed term-edge
coverage, opening invariants and successful graph correspondence; it does not
rerun them or mechanically prove OCaml control flow. Raw attribute checking is
a new narrow read of retained bytes, without target execution or term opening.
The check rejects an unexpected kind or failed identity/coverage/join premise.
`--write` creates an absent first certificate/source manifest; normal checking
compares deterministic content exactly.

This closes only warning-attempt exclusion for these domains. Actual queued
limits and all other timing/configuration/prefix/grammar/full-q obligations
remain separate. Diagnostic warnings are not warning-kind proof attempts.
One global e<=2/two-callback/three-save budget remains per process. No native,
solver, proof, capture, predecessor checker or graph comparison runs; no
installed, Oracle, admission, production or adapter edits occur.
