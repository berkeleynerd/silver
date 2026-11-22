# Qualified core consumers — 2026-11-22

Focused run `20261122T150241-5292227c1477` passed the complete
ScalarArrayExpressionRecognition, ScalarArrayGrammarSyntax,
ScalarArrayGrammarFrames and IntegerSubtypeBindings modules and freshly
audited **7,155 declarations**. Linux x86-64, pinned Lean, two workers and two
threads, retained compiled dependencies; not a clean or complete assurance run.

The proof adds the explicit bare-reference delimiter lemma used by indexed
array grammar, updates atomic reads to qualified identities, and proves that
flow overlays preserve both qualifier fields and lookup for arbitrary
qualifier queries. Imported subtype tables do not hide bare operation or
Boolean-literal names; qualifying the table preserves metadata validity and
establishes the empty hiding flags used by the native import frame.

The semantic domains are unchanged. Failed focused iterations in the managed
history exposed ordinary constructor/projection and an unused simp argument.
The Boolean native/source chain and scalar native/source chain remain separate
unfinished work. This packet is suitable for integration of the core consumers
before the shared Compose and Predicate caller repair.
