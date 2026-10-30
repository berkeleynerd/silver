# Final Rosetta regression refresh

All three Rosetta renderer tests passed for delivery metadata `1d6d1b4ffde8b0cdc24212b6c6dd3842880a7cc2` with
source/proof/scripts/tests frozen at `d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`. Managed run `20261030T031457-868467f2105b` took
8.008 s; unittest reported 4.499 s.
It reserved one worker on native Linux x86_64 and exercised actual renderer CLI
output across hash seeds plus two renderer fixtures; no native compiler/proof
work was invoked by this slice. Selected model/effort: GPT-6.1 Sol / Extra High;
runtime confirmation and token/cost measurements are unavailable.

Coverage is 506 applicable original results plus 49 refreshed identities,
comprising 28 latest proof-tree passes, 18 earlier compiler-fixture passes and
these three final Rosetta passes.
All 555 inventory identities remain covered (546 distinct methods); the
52 sample sources / 108 application executions retain their earlier reviewed
results. The original full-suite success and every earlier refresh remain history.
This packet establishes regression evidence only; complete native and Lean
checkpoints retain their separate input and outcome claims.

Original managed events and log are retained with unchanged decompressed bytes;
`retained.json` records their hashes, terminal event and captured input comparison.
`coverage.json` lists every retained and refreshed identity. Prior inventory and
reconciliation bytes remain alongside this record. No tests were added or changed.
