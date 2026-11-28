# Effect source imports — 2026-11-27

Focused run `20261127T123152-31d1c2fad870` passed
`Silver.ApplicationPackageEffectsImports` and
`Silver.ApplicationStateValidityPrimitives`, with a fresh audit of 41,625
declarations. Only `propext`, `Classical.choice` and `Quot.sound` remain as
foundations. Linux x86-64, Lean 4.34.1, two managed workers/two threads, host
eight-CPU allocation. Total recorded time: 19.939 seconds. Input digest:
`fa147c125fa0283cb98d784a83a94e1928cec7ba7a4490a061116ba1e2ab308a`.

The effect imports instantiate package-name/state lookup, scalar/Boolean lookup,
lexical reads and the Actual_Name_Free scanner using their existing native
definition equations and source interpretations. The resulting primitive
meaning supplies the full guarded Visible_State, State_Target and State_Reads
equations; no completed effect or scanner meaning is an assumption. The extra
state-validity primitives interpret the exact name-state Boolean expression and
reuse the existing typed fixed-bound expression over all arguments. Their final
profile/lexical source witnesses remain in the lead's pending aggregate work.

The first run `20261127T121826-eb6b57a10861` built missing package/scalar
certificates and their source checks, then failed on an unused variable warning
in the new import theorem after 646.876 seconds. Its input map and failed log are
retained separately. A subsequent small batch exposed namespace/binder notation
errors in the new primitive adapter. The successful run reused the completed
dependencies through ordinary Lake checks and audited the imported declarations
afresh; this is neither a cold build nor kernel replay. The earlier cache seed
is disclosed in the sibling `support-domain-closure` packet.

This focused result does not complete the package reader-to-safety chain or the
whole-feature native/Lean/regression checkpoint. Work followed the repository's
Astra Max proof-role selection; runtime-confirmed model and effort are not
independently exposed.
