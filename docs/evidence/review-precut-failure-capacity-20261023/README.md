# Independent pre-cut failure-capacity review evidence

This packet supports the [review](../../reviews/review-precut-failure-capacity-20261023.md)
of exact author freeze `07e63b97f3623b2405172433ae093ce894defd23` for #119 / #153.
It changes no provider, production code, Oracle, tool identity or admission.

Run `python3 docs/evidence/review-precut-failure-capacity-20261023/check.py`.
The checker binds the complete author packet and note to that Git commit,
checks retained provider/archive identities and exact authored source spans,
retains supplementary loader/Printf/name-construction spans, checks the complete
selected-file Debian patch projection, independently checks all 21 original
library head envelopes and recomputes the separate returned/private arithmetic.
It does not import or execute the author's or any predecessor's checker.
`--write` creates this review's projections; normal execution compares them.

Source span coordinates use the author's decoded Python `str.splitlines`
convention, including formfeed separators. Member and span SHA256 identities
make the exact input bytes explicit. These coordinates can differ from an LF-only
editor display in glibc files containing formfeeds.

The script checks identities, projections and arithmetic. Semantic reachability,
exception-family closure and the copy ledger are reviewed source arguments,
not machine-proved by matching snippets. The report supplies the disposition.
Actual client cwd/joined P and full Sexp/Mlw serializer/configuration/native-layout
transport remain pending. Whole-process capacity is not established.

`check-attempt-1.log` retains the failed first check: my byte-based line splitting
did not match the author's decoded-line convention. The failed span was
`glibc-2.43/elf/dl-load.c:1587–1602`; that member contains three formfeeds.
Diagnostic extraction confirmed exact equality under decoded `str.splitlines`.
The checker was corrected, then `check-attempt-2.log` passed 269 checks in
18.12794034399849 seconds. There was no repeated successful expensive run.
`exploration-notes.json` retains two incidental exploration failures separately.

Selected reviewer model/effort: GPT-6 Astra / Extra High (`gpt-6-astra`, `xhigh`),
as confirmed by the delegating lead. Runtime confirmation and isolated token/cost
telemetry are unavailable. Actual platform/check timing is in `round.json`;
review interval and outcome are in `review-round.json`. Native target, compiler,
solver, proof, capture, disassembly, source-fetch and provider-checker runs: zero.
