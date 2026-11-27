# Typed package declaration procedures

Linux x86-64 run `20261127T123004-bb30b7648f33` checked the complete typed Signature and
Specification bodies and the full-storage Append contract projection with Lean
4.34.1, two workers and two threads per process. The fresh audit
covered 22,233 declarations. The input digest is `9edfd1569c96f7c9e2d8b97f98ef9cb7cbe647acd2c08fac4d7ddf2c3554efcc`.

The two source trees retain the guarded and unconditional loops, procedure
returns, loop exits, block-local restoration, native pragma syntax and
conditional table-count assignments. Both pass structural, scope and named
association checks. The control relation has no fuel or termination assumption.

The Append projection covers both fixed arrays, arbitrary inactive values,
capacity failures and every native-typed frame. It interprets the functional
branches of the full verified postcondition. Separate source and semantic
targets connect the procedure trees, complete native headers, inherited
callees and raw reader execution.
