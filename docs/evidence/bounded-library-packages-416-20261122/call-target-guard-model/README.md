# Writable-target guard semantics — 2026-11-22

`20261122T191729-c19267394feb` passed `Silver.ApplicationPackageCallsEffects` and
`Silver.ApplicationPackageCallsImports`, with a fresh audit of 25,427 actual
imported declarations. Linux x86-64, two managed workers/two Lean threads.

The raw alias equation exactly includes the zero target-endpoint rejection in
native repair `d52a34aaa9`. The actual payload branch is factored without a
behavior change. Its successful writable progress implies a positive target
endpoint; the checked alias equation with that filled payload is identical with
or without the added guard. No property is assumed for empty/default storage or
for an unsuccessful imported reader. Successful alias stages now export the
positive endpoint as well as their existing explicit/implicit disjointness,
and retain the exact effect-footprint theorem.

The complete typed Call interpretation, actual filling coverage, native helper
check and authoritative source binding remain outstanding. This focused model
check is partial validation. Selected role GPT-6 Astra Max; live model setting
confirmation and token/cost measurements unavailable.
