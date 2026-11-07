# Retained Sequence-context integration failure

Linux focused run `20261107T224846-c33ea7d88705` failed in
`SequenceNativeProjection.context_same`. ComposeEquations (353 s),
ComposeModelLegal (253 s), ComposeModelHelperEquations (665 s) and
ComposeModelEquations (28 s) compiled successfully; their objects were retained.
The build lasted 723.051 s. No fresh axiom audit or complete assurance is claimed.
The run used four Lake workers and 22 Lean threads per process.

The native Sequence context already carried the five added parser fields,
but the SameContext relation still omitted their equalities. The next focused
repair extends that relation and its existing preservation/projection proofs;
it does not narrow valid inputs or change native behavior. The managed diagnostic
records this next step. Compressed logs and events are verbatim runner records;
`index.json` lists hashes of their uncompressed contents.
