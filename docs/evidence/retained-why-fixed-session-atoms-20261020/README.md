# Retained fixed-session atom projection, 2026-10-20

This #119/#153 packet projects typed atoms and attributes from five already
retained logical forests. It imports the saved occurrence certificates without
rerunning logical opening, binder counting or alpha replay. No new capture,
native target, solver, public evaluator or source fetch runs.

The five `*-atoms.json.gz` files preserve original identifier bytes, integer
representations and values, constructor censuses, term and identifier attributes,
goal identifiers and complete imported certificates. Counts retain the original
APn multiplicity and detachment fields. Atom coverage alone deduplicates objects.
The shape attribute union includes all stored term attributes, including deferred
substitutions, and every proposition identifier's attributes. It bounds unions
made by opening; a maximum over individual stored nodes alone would not suffice.

`summary.json` is the small join input for the separate functional J/L argument.
`inputs.json` pins scripts, source archives/files, saved certificates, capture
archives and output packets. Exact raw session-block member identities also occur
inside each output. `source-excerpts.json` retains the relevant source text and
complete-member identities. These use the accepted source-family contracts;
they do not establish historical installed-source identity.

The bounded source-derived Zarith custom layout is supported, including unused
allocation words beyond the used limbs. Unexpected numeric layouts are retained
as explicit unsupported records, and prevent numeric completeness. Every current
packet has complete typed and numeric coverage, with no unsupported records.
Actual mutable `expl_prefixes` configuration remains unknown; the source defaults
are `expl:` and `infer:`.

Smallest verification from the repository root:

```sh
python3 -B docs/evidence/retained-why-fixed-session-atoms-20261020/check.py
```

The checker checks input/output/source identities, direct atom-byte and attribute
membership correspondence, imported certificate equality and J arithmetic. It
does not repeat the typed term-edge closure traversal. The latter is explicit in
`extract.py` and its pinned imported `Atoms` class, for independent review.
`check-result.json` records the Linux x86_64 result on these exact inputs.

To reproduce only a new atom projection, select one case per invocation:

```sh
python3 -B docs/evidence/retained-why-fixed-session-atoms-20261020/extract.py \
  --case put_line --output /tmp/put-line-atoms.json.gz
```

Extraction output includes measured elapsed time, so compare fields after
removing that field rather than expecting a new gzip hash to match. `freeze.py`
packages already-existing projections; it does not recompute their coverage.

The four registration cuts and the earlier Input_Is_Valid inline-entry cut are
not interchangeable native snapshots. Their logical-forest use has the existing
accepted preservation scope. The combined 161 APn visits differ from the
scheduler's 153 registered-task envelope. This packet supplies finite atom inputs
and per-save J; it does not prove whole-ending capacity, future graph closure,
admission, numeric-library internals or a source/client behavior relation.
