# Independent provider-attachment review evidence

Exact author: `e363118b9343dbae72127411f9bc21cc199e2070`, #201 under #119.
The [review](../../reviews/review-provider-attachment-20261024.md) requires a
repair for confirmed medium [#218](https://github.com/berkeleynerd/silver/issues/218):
the claimed frontend-known-lower-one property is not preserved by a nullable
concat. Native equal-arm folding occurs later and does not establish the
missing frontend premise.

`audit.py` is a new independent, offline source/math audit. It imports no
author/predecessor code. It binds all thirteen target files and accepted
review/repair inputs, checks the archived source identities and selected
LF-delimited witnesses, corroborates the frontend/native stage distinction,
and checks coefficient arithmetic without accepting its disputed attachment.
The focused model is not GCC execution. No compiler, generated matcher,
prover, Lean, native target or native service is run.

`frontend-sources.tar.gz` adds the complete exact-pin `sem_eval.adb` and
`checks.adb` sources used to resolve the disputed frontend behavior. Both
digests match the existing retained native-expansion manifest. Retrieval URLs,
complete hashes and five additional source witnesses are recorded in
`frontend-sources.json`. Existing author sources remain immutable and are
read directly from their archived locations.

Selected reviewer: GPT-6 Astra / Extra High. Runtime confirmation, tokens and
cost are unavailable. `current.json` records actual Linux host and elapsed
time. `manifest.json` binds this review's files, excluding itself.
