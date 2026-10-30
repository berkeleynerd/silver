# Boolean terminal regression reruns

Issue #291, native Linux, 2026-10-30. The reviewed branching correction and the
unchanged maximum-expression test now pass. The full-suite and earlier rerun
failures remain retained as failures.

| Managed run | Scope and allocation | Result |
| --- | --- | --- |
| `20261030T155127-bf12fb89db9a` | Two corrected branching methods and unchanged maximum-expression method; two reserved CPUs, affinity `[0,1]` | Both branching methods pass; maximum-expression hits 300-second deadline. 302.871 s unittest / 306.484 s managed. |
| `20261030T160408-2c742ff18bd0` | Only unchanged maximum-expression method; eight reserved CPUs, affinity `[0,1,2,3,4,5,6,7]` | Pass. 150.108 s unittest / 153.669 s managed. |

The source correction is exactly integration commit `29bc1d44d7`. The three
fixtures retain the outer validity guard while admitting an inner
`Mode="verbose" and then True`, an inner `if True`, or an additional nested
`if True`. Invalid syntax and outer guards that fail to establish the required
input-validity facts remain negative controls. The helper is unchanged.

The maximum-expression method itself, its 300-second test-only deadline and
all production settings are unchanged. Production proof keeps its existing
100,000 normalized steps and no wall-clock proof limit. In the original full
suite, the test's Silver parent was stopped by `subprocess.TimeoutExpired`, but
its producer descendants continued and then exited naturally. No signal was
sent. Their byte-identical 64-leaf main source and five reports independently
audit successfully: 19 flow checks and 110 proof checks, with no advisories.
Those late reports establish completed proof work, not a passing compile and
execute test. They are retained in `first-timeout-producer/`.

The second deadline at two-CPU affinity prompted the retained diagnostic
checkpoint. After its remaining descendants exited, the agent checked host
headroom and ran the unchanged method with eight reserved CPUs. Concurrent
reservations were native proof two, Lean one, and this test eight: 11 of the
host's 12 available CPUs. The temporary wrapper printed the actual affinity.
The successful method checks admission, proof-backed compilation, original
source correspondence, production proof policy and report audit, and execution
for both empty input and a 4,096-character output. No production proof option,
source admission rule, test expectation or deadline was weakened.

The allocation change is a practical response to the imposed two-CPU restriction.
It is not a controlled speed comparison. The application command has no
memcached option, and this record does not claim that native compiler proof-cache
reuse accelerated the application test. The separate compiler cache correction
belongs to the native proof record.

All 839 captured inputs were explicitly rechecked after each rerun, including
the nonzero two-CPU outcome; they match. `final-snapshot-verification.json`
additionally checks all 12,053 snapshot files with only the reviewed branching
file override. `final-coverage.json` records 565 retained passing IDs plus two
fresh branching IDs plus the fresh maximum-expression ID: all 568 IDs, covering
559 distinct methods. `original-checkout-restoration.json` records restoration
of the owned original-root inputs. The compiler binary and other artifacts
remain retained; the separate pending native proof workspace is untouched.

Selected native subthread: GPT-6 Astra / Extra High. Live model confirmation and
token/cost measurements are unavailable. Test and managed elapsed times above
are actual measurements and are not a model-quality comparison.
