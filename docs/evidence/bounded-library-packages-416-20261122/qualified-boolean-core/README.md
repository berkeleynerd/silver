# Qualified names and Boolean elaboration core — 2026-11-22

Run `20261122T144616-ad3413eb69a4` passed six complete module targets and freshly
audited **6,128 declarations** on Linux x86-64 with pinned Lean 4.34.1. The
explicit two-worker/two-thread allocation shared the host's eight CPUs with
other focused work. Compiled dependencies were retained; this was neither a
clean build nor an independent kernel replay.

The targets were `QualifiedNames`, `BooleanBindings`, `BooleanElaboration`,
`ScalarExpressionEnvironment`, `ScalarExpressionGrammar`, and
`IntegerSubtypeBindings` in namespace `Silver`. The checked core establishes:

- Independent bare/qualified identifier syntax, reader bounds, soundness,
  completeness, uniqueness, and distinct qualified/bare identities.
- Qualified scalar lookup and atomic grammar, retaining interval safety and
  masks; scalar/Boolean/subtype metadata retains qualifier spans.
- Exact known Boolean values during elaboration, loss of mutable known values
  in routine bodies, and preservation of the ordinary Boolean analysis.
- Soundness of exact Boolean evaluation over every Integer store fitting the
  inferred ranges and every Boolean store fitting the known metadata. The
  result uses the existing `Predicate.Condition` execution semantics.

This is a model/helper checkpoint. The changed native lookup/atom readers,
`Read_Reference`, `Static_Boolean_*`, their actual-source equations/checks and
downstream callers still require correspondence work. Complete native compiler
proof and whole-application assurance are not established by this packet.

The initial focused iterations corrected a reserved Lean identifier, record
projection normalization, a deprecated lemma name, added constructor fields,
and explicit qualifier argument/transitivity plumbing. No declared domain or
semantic condition was weakened. The managed history retains those failed
runs and the diagnostic checkpoint. The successful run reused the already
compiled complete leaves and freshly performed its scope and axiom audit.

`lean-focused-evidence.json` records the input digest, selected scope, tool
identities and settings; `events.jsonl` retains the managed input inventory.
`cache-seed.json` identifies the copied retained cache without treating it as
validation of the new inputs. `sha256.json` hashes these retained records.
