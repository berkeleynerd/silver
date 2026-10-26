The final Linux frame evidence at
`docs/evidence/scalar-guard-refinement/final-frames-20261026/validation.json`
binds parser `956eff687472...` to scratch build `20261026T073737-a27ed2ad48a6`,
admission run `20261026T073838-e2c59da5cc8d` (18 tests/105 cases, zero failures
or errors), and shape run `20261026T073915-30f6eea23d83` (all 20 expected
4096/4097-byte statuses at 8192 KiB; all 183 captured input hashes match).
All 129 tracked source files and three generated source files are retained.
The final Body_Tail wrapper/body frame sum is **368 bytes**, down from 416;
Bare_Target is **256 bytes**, up from 240; the other nine listed recursive sums
are unchanged. This supersedes the earlier Body_Tail sibling-release claim for
this build: its former local secondary-stack mark/release pair is absent from
the final assembly. All **64 parser secondary-allocation sites** retain their
per-source-function counts. The conditional successful-body payload count
`S(B)*(4N+6L+9J+4E+3)` already counted every allocation, including formerly
released results, so its source/site-count assumptions remain applicable despite
the longer retention; rounding and successful-parse counting assumptions still
apply. These are feature-local observations under the existing sufficient-resource
premise, without a universal 8 MiB, malformed-prefix capacity or external
allocator-sufficiency claim. Complete native proof and complete Lean/actual-source
validation remain separate pending obligations.
