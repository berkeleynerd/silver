# Platform regression refresh after source-proof repairs

Managed Linux run `20261030T185425-5e8a367d56b1` passed all 16 tests in
`test_platforms.py`: 274.264 s unittest time and 277.110 s managed time, one
reserved worker. Inputs were the integrated proof-repair target `b6aeb9f978`.
The runner's successful terminal input comparison passed.

The [independent applicability review](../../../../reviews/review-boolean-proof-repairs-b6aeb9f978.md)
identified 13 affected top-level identities that copy or recursively exercise
the changed generator/proof fixtures. The whole-file run includes three
unaffected installation checks. These 16 successes replace their earlier
full-suite results; they do not add new identities to the 568-test inventory.

Together with the 12 source-certificate tests and three earlier repair passes,
537 retained results plus 31 refreshed results cover the current 568 identities
(559 underlying methods). The final Rosetta metadata change still requires its
three focused test refreshes, yielding 534 retained plus 34 refreshed results
if no additional governed input changes occur. Complete native and Lean/source
assurance remain separate pending requirements.
