# Complete native proof and audit after Body_Tail repair

For [#291](https://github.com/berkeleynerd/silver/issues/291), native Linux x86-64
run `20261031T022711-e4258c225793` passed the complete strict proof and provenance
audit at **2026-10-31 06:20:19 UTC**. All **17,234 checks** passed: **1,468 flow
and 15,766 proof checks**, across **76 units and 1,091 entities**. No required
check remains unproved in this run.

The validated source is commit `f5ab46cdeff361c8072e089c0ae52619e70aba2a`.
`src/silver_output_profile.adb` has SHA-256
`bb3bd71eb53e7f0637ed27ac4b5eb7c283b66dc0fb81131ebe73543c3950d01f`.
The [matching build](../full-native-build-bb3bd71e/README.md) passed immediately
before this run; the [focused repair](../body-tail-native-repair/README.md)
previously discharged all three added Static assertions and the original
`Body_Tail` postcondition under unchanged production limits.

## Scope and result

The managed command was `scripts/dev.py prove --full --jobs 4`. Its effective
GNATprove command retained:

```text
-U --mode=all --report=all --warnings=error --checks-as-errors=on
--level=2 --prover=cvc5,z3,altergo --timeout=30 -j 4 -f
-XSILVER_HOST=linux-x86_64
```

The original 1000 MiB prover memory limit and managed filesystem-cache
configuration were unchanged. The exact command is retained in the launch,
journal and provenance files. This forced complete run regenerated reports and
performed the strict audit while reusing populated sessions and cache entries;
it is not a cold-cache measurement. No scheduling suspension occurred during
this run.

The audit also classified 312 limitation notes, 18 imported entities, 6,236
trusted-math notes, 62 vendor-spec entities and five array-initialization
advisories under the existing policy. These classifications are distinct from
the proved checks and do not waive any required obligation.

The fresh full-run `Body_Tail` Why3 session has **421 proved goal nodes**. Its
retained SHA-256 is
`ba6e24785989e7ee4b304d58612127b8657c7e3e8ac005ab4f5ee7e63c8b9b38`.
The earlier observation records its success before the whole run terminated;
the complete terminal journal and audit now establish the whole native result.

| Timing from managed journal | Seconds |
| --- | ---: |
| Complete managed run | 13,985.692110 |
| Native tool phase | 13,964.266925 |
| Strict audit phase | 14.507682 |

Only the output-profile source hash changed from the
[previous failed full run](../full-native-failed-214853/README.md). The other
2,560 captured hashes, effective command and prepared tool/settings fields
match. `prior-run-comparison.json` records this comparison. The source repair
adds three checked return/model assertions; executable operations, contracts,
models, admitted domains and proof budgets remain unchanged.

## Retained evidence and restoration

The terminal retainer verified all **2,561 captured input hashes** before
restoration. The complete provenance manifest binds those same inputs and 78
reports. This packet retains **80 report/input/provenance files**, the original
journal and native log, the exact **143 tracked native inputs** in
`native-inputs.tar.gz`, their `snapshot-manifest.json`, and the successful
`Body_Tail` session. `report-sha256.json` records uncompressed report hashes.

Independent retention verification decompressed and rehashed all 80 reports,
checked every provenance report binding, compared the journal/log with the
managed originals, and matched all 143 archived source files to both the
manifest and commit `f5ab46cdef`. It also rechecked the matching build's retained
log/journal and both binary identities. See
[`independent-retention-verification.json`](independent-retention-verification.json).

After verified success, only the two temporarily replaced installed source files
were restored from their original backups. Both original hashes and all seven
unrelated dirty-file hashes/modes were independently verified. Rehashing the
installed inputs found exactly those two intentional restorations and no other
change. `checkout-restoration.json` records the originals and validation hashes.
Native reports, sessions, exploratory evidence and caches were preserved.
The retained proof result therefore applies to the archived validation inputs,
not the restored installed source. Managed status confirms the run is inactive
and no workers were reserved at the verification checkpoint.

Native verification is complete. Final integrated source/pin/certificate
verification, the complete Lean checkpoint and the reviewed regression refresh
remain separate delivery obligations owned by the integration lead. Regression
handoff awaits that lead's final integrated commit and explicit workspace
release; native success alone does not declare the Boolean capability complete.
Both feature PRs remain open.

## Round record

The native subthread's selected setting was GPT-6 Astra / Extra High; runtime
confirmation and token/cost measurements are unavailable. This round's intended
outcome was the complete native checkpoint on the reviewed repair. It achieved
all native obligation, coverage, input/provenance and restoration checks without
further source changes or a repeat run. The prior merged postcondition failure
is resolved in the complete run. The timings above describe native execution,
not total team elapsed time or a controlled model-performance comparison.
