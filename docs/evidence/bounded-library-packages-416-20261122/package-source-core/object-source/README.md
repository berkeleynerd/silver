# Object source proposal and suffix equations

Run `20261122T191027-0522c6b4d778` passed on Linux x86-64 at 2 workers / 2 threads,
with a fresh audit of 20,976 declarations. The exact original 730 body tokens,
header and result/default types, and Read_Expression omitted defaults are kernel
checked by ObjectSourceChecks.Checked on the copied source proposals.
Final/scalar/Boolean suffix equations hold for arbitrary primitive calls and
incoming local storage. Full-body composition and callee/domain closure remain
separate work. Authoritative final token streams must instantiate Checked.

Int.repr required import-all transparency, alongside the existing Nat repr
import. No source tokens, primitive domains or theorem budgets were relaxed.
