# Flattened-certificate repair regressions

Managed Linux run `20261030T184849-3885f48eaec2` passed all 12 source-certificate
tests in 82.533 s, with one reserved worker. It ran in the isolated repair
worktree on generator/certificate/test bytes subsequently committed as
`49a9c76b47` and integrated in `b6aeb9f978`. The existing pinned Lean installation
was reused through a read-only tool-directory symlink; the tests compiled their
small fixtures in separate temporary directories.

All 28 certificates regenerate byte-identically. Only OutputBody differs from
the preceding snapshot, and only its `_values` proof changes. The existing
native witness test now also forces the large-list strategy on a tiny fixture:
the correct value is kernel-checked and a wrong flattened token list is rejected
with a kernel declaration type mismatch. The ordinary small-list path and its
existing negative controls remain exercised.

The [independent applicability review](../../../../reviews/review-boolean-proof-repairs-b6aeb9f978.md)
confirms the results apply to the integrated target despite its two additional
proof-only fixes. Complete checking of the real OutputBody certificate and the
whole source/module/axiom chain remains required.
