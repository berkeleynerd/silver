# Stable shadow-frame rows — 2026-11-27

Focused run `20261127T130132-5fa521fea1e6` passed a fresh audit of 43,083 declarations, with only
the three permitted foundations. Linux x86-64, Lean 4.34.1, two managed workers
and two threads per process within the eight-CPU host allocation.

For every successful Hide_Outer model result, all three scalar, Boolean and
subtype tables are ordered sublists of the original rows. Combined with the
complete imported-source interpretation in `../hide-complete-imports/`, this
preserves original declaration spans and stored values through shadowing.
The only premise is nonzero successful result position; no caller history,
metadata validity or initialized values beyond the model's own checks are assumed.

The first focused attempt left the final validity conditional unreduced; the
second used a deprecated conditional lemma rejected by warning-as-error. Explicit
reduction with the pinned version's lemma passed. Both failures remain failed
in the managed ledger. This incremental check reuses prior compiled dependencies;
it is not a full feature checkpoint or a kernel replay.
