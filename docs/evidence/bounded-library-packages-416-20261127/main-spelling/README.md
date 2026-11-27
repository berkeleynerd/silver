# Main package spelling — 2026-11-27

`ApplicationPackageSpelling` interprets the original comparison over arbitrary
Ada String lower bounds for both Text and Word. It reuses the existing package
metadata expressions and their precedence/scope checks, with a local command
adapter for tests, source-range iteration and Boolean returns. Invalid names and
unequal lengths return before indexing. The loop binds an Int index at
Word.First + offset, propagates an early return and leaves outer bindings intact.
The proved result is independent of Word.First; Text.First is retained because
Valid_Name rejects non-one-based Text. No source or language rule changes.

Run `20261127T204748-4848ee80401d` passed the full-domain execution equation,
imported metadata interpretation, Word.First independence, and candidate exact
header/body match, with a fresh audit of 15,398 declarations. All 1,571 captured
inputs hash-match. The three preceding proof-draft failures and their diagnostic
are retained as failed. Repairs addressed explicit Nat/Int callback types,
arithmetic normalization, an induction rewrite and an unused simp argument;
no domain or proof budget changed.

The authoritative Output_Profile extraction and existing Lowercase source
binding are prepared separately for the next source checkpoint. Candidate token
matching alone does not establish that final authoritative link. The complete
application endpoint remains pending.

Settings: two Lake workers, two threads per process, 8,192 MiB per process,
within the host's shared eight-CPU allocation. Matching cached dependencies were
reused; this was focused validation with a fresh audit, not complete assurance
or independent kernel replay. The [independent proof review](review.md) found no defect in the model/candidate
scope and preserved the pending authoritative-source and native-validation requirements.
