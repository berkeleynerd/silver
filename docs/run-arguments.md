# Run Arguments

Status: complete, authorized and validated 2026-10-15 against `4f86f08dcc` on Linux x86-64.
The [roadmap](../roadmap.md#run-arguments) records this single CLI milestone.

## Scope and completion criteria

Support `silver run SOURCE -- [arguments...]`, including empty arguments and
shell-sensitive bytes, without changing the program's argument boundaries.
Retain the no-argument invocation. Preserve ordinary child exit status and use
accurate diagnostics for application and launch failures. Both intentional
`Reject` and detected output failure use status 1 today; that status does not
identify which occurred.

| Order | Work | Status |
| --- | --- | --- |
| 1 | Specify forwarding, resources and process-status boundary | Complete: existing GNAT direct spawn and owning-list cleanup |
| 2 | Verified SPARK implementation, affected Lean assurance and focused regressions | Complete: exact copying, ownership/cleanup and status propagation; unchanged language/source proofs; focused regressions pass |
| 3 | Stable Linux validation, independent review, documentation and publication | Complete: native audit/build, cached Lean check, full suite plus final formatter recheck, real smokes and independent review; this record accompanies the delivery commit and publication |

Language membership, application APIs, source/value limits and proof-report
acceptance stay unchanged. Existing source correspondence and complete native
obligation discharge remain required. This is not a general process-management
framework or a new proof engine.

## Behavior and implementation

```sh
silver run samples/release_report.adb -- production
silver run samples/command_line.adb -- ""
```

The separator is required before application arguments and is consumed by the
driver. A bare trailing `--` forwards an empty vector, as does the existing
`silver run SOURCE`. Every suffix argument retains its exact bytes and position;
the driver does not filter non-ASCII/control bytes or apply the application's
4096-byte/one-argument rules. The selected program applies those rules itself.
`check` and `compile` still accept only their source operand. Invalid CLI forms
return status 2 before source or external-tool processing.

`Silver_Platform.Run_Application` copies the suffix into an owning SPARK list,
asserts exact equality with the original immutable runtime vector before
spawning, and frees its strings and list afterward. Loop invariants establish
nonnull initialized entries, exact values, NUL exclusion and the untouched null
suffix. These invariants are Static: GNATprove checks them, while runtime
assertions do not repeatedly scan the growing argument list. The NUL violation
path also frees partially populated storage. The
nested driver's publication contract carries the argument-offset bound, as well
as all earlier source, proof-report, library-identity and build-success guards.

`Silver_Process_Runtime` declares two existing GNAT Ada entry points: Spawn and
whole-list Free. The evidence checker pins the complete interface and allows
specification-only coverage for exactly those two imported entities; their
emitted obligations remain mandatory. There is no Silver-owned unchecked or
SPARK-off body. The [process boundary](trusted-boundary.md#application-process-boundary)
records ABI/default-heap compatibility, exact Unix delivery, process/resource
and deallocation premises. Proof/build tools retain their existing shell path.

The existing shell buffer is unsuitable for general argv: quoting can expand
even valid application arguments beyond it. Direct GNAT spawn avoids another
argument encoding and buffer limit. No separate process framework, shell escaping
logic, new application runtime snapshot or Lean CLI bridge was introduced.
All seventeen Lean source bindings and the language proofs are unchanged; native
SPARK proves this driver's copy/ownership work. The existing assurance scope does
not claim a single end-to-end Lean theorem for the OS/toolchain/CLI.

| Returned process result | Driver behavior |
| --- | --- |
| 0 | Status 0, `Execution completed successfully.` |
| 1 through 255 | Preserve status; `Execution returned status N.` |
| Outside 0 through 255 | Status 3; `Execution failed: application did not exit normally.` |

GNAT may return 1 when the image cannot be executed. That result is indistinguishable
here from child status 1, which can be Reject or detected output failure. The
diagnostic deliberately states only the result. Ordinary child statuses may
overlap driver error codes. This interface does not reproduce child signals in
the driver. Successful allocation, sufficient stack and OS argument/environment
and process resources remain environmental premises; there is no new Silver
argument-count or aggregate-byte cap.

The later [report-capacity repair](report-capacity.md) moves the driver's report
buffer off the primary stack before spawning and removes its normal auditor's
report-sized copy. This addresses review L4's 190,000-argument failure; GNAT's
own spawn storage and ordinary OS resource limits still apply.

## Validation

Focused driver tests passed **22/22** and evidence-policy tests **39/39**.
The real driver with fixture proof/build tools exercises exact argument vectors:
no arguments, empty values, spaces/quotes/backslashes/metacharacters, leading
dashes, control/non-ASCII bytes, 4096 apostrophes, a 4097-byte value and 8192 empty
arguments. It also checks ordinary exits 1/9/127/255, absent executable, SIGTERM,
usage errors and existing publication-integrity failures. These fixture cases
exercise real process spawning but do not claim real application proof evidence.

The separate runtime ABI prototype additionally checked every byte 1 through
255 and a 65,536-quote value. Its isolated 22-check SPARK proof demonstrated
feasibility; the production checkpoint below is the implementation evidence.

The first exploratory driver proof exposed a missing argument-offset condition
on the nested publication routine. Adding that condition preserved all gates;
the focused publication recheck passed. The early full-suite attempt was stopped
after about a minute and its partial logs retained. Independent review then
identified that runtime loop invariants would repeatedly scan earlier arguments;
making those invariants Static removes that quadratic work while preserving their
proof obligations. The second preliminary native/test checkpoint was stopped
before that edit, with logs and cache retained. The final stable checkpoint
starts after both fixes and rebuild; no incomplete attempt is counted as a
passing suite.

Independent final source review found no remaining actionable defect and confirmed
the runtime's copy-before-normalization and whole-list cleanup against the pinned
GNAT source. Its ABI premise is explicit above. A separate documentation review
confirmed CLI/status/trust consistency and local link targets. No new dense-capacity
experiment is needed: this CLI change does not
alter the admitted language, application proof options or report policy.

The complete **Lean 4.34.1** check passed **252 modules**, with a fresh inventory
of **56,885 declarations** and only `propext`, `Classical.choice` and `Quot.sound`.
The final runner took 12.557 seconds: its cached build phase took 3.923 seconds
and fresh audit 5.275 seconds. This reused the unchanged language/source proof
artifacts; it is neither a cold build nor independent kernel replay. Four Lake
workers, four threads per process and a 16,384 MiB per-process threshold were
used. All **345** captured implementation/proof/test/sample/configuration inputs
remained unchanged. The complete input digest is
`3081edc08fdb23689af6b5ab00b4821dc0141347938290a1e113983576a08e36`.

Two final-driver real proof/build/run smokes passed, using isolated fresh program
directories and the unchanged production application proof options:

| Invocation | Result | Seconds | Retained directory under `.silver/linux-x86_64/` |
| --- | --- | ---: | --- |
| `run samples/release_report.adb -- production` | Exact expected report; status 0 | 12.564 | `program-9ufHiT` |
| `run samples/command_line.adb -- first second` | No application output; status 1 with neutral diagnostic | 9.647 | `program-hgSsy5` |

The compiler executable digest was
`795054a05aae920b02648b5c97e6e13d32d39e6e35b07d001091c6c69b891508`.
Sources and executable hashes stayed stable across each invocation; the snapshots
matched the original sources. Earlier smoke records and program directories
remain separate supporting evidence from before the contract, invariant and
diagnostic-rendering fixes.

The first complete native attempt discharged all 3234 checks, but its evidence
audit rejected the new `imprecise-image` note on generic integer formatting.
That attempt is not a passing audit. The existing verified `Silver_Numbers.Decimal`
helper supplies an exact decimal relation without this warning. After the frozen
full suite finished, the sole implementation change was importing that helper
and using it for the diagnostic, preserving the text. The failed audit is retained
under `checkpoint/pre-format-*`; report acceptance is unchanged.

The full suite passed **312/312**, with no skips, in **1153.942 seconds**
(1154.433 seconds for the outer command). All 345 captured inputs stayed unchanged.
After the formatter repair and rebuild, all **61 affected tests** passed: nine
driver tests, thirteen output-integrity/process tests and thirty-nine evidence
tests. Their outer commands took 12.705, 6.095 and 0.926 seconds respectively;
all captured inputs were stable again. This is a frozen full-suite pass followed
by a narrowly scoped code repair and affected recheck, not a second full-suite
run against the final formatter. The final native and Lean checkpoints use the
repaired source; no proof or application source changed during any completed run.

The final complete native audit passed **3235 checks**: 575 flow and 2660 proof
checks, covering 21 units and 317 entities. It took **166.028 seconds** with four
workers and retained solver sessions/cache available, not a cold measurement.
All 80 existing classified tool-limitation notes and 16 approved imported
entities remain explicit; no required check is unproved or suppressed. The
subsequent build passed and exported catalogue matches the checked-in JSON byte
for byte. All 345 captured inputs stayed unchanged throughout. Final provenance
validation confirms **2409 input identities and 23 reports** match the final
source, tools and reports. After the full suite, only `src/silver.adb` changed,
for the decimal helper call described above; no other implementation/proof/test
input changed. The final native, Lean and affected-test captures agree with the
implementation in this delivery. Documentation-only closure does not invalidate
them.

## Recovery and evidence

`tmp/run-arguments-active.json` identifies the local record and preserved prior
native/Lean evidence. Retain all caches, earlier successful program directories
and unrelated Rosetta/scratch work. Publication remains authorized. No replacement
harness goal was requested; its historical completed goal is separate from this
milestone. CLI memory tools were unavailable and were not updated; checked-in
memory and RESUME carry the handoff. macOS proofs, hosted CI and independent replay are outside scope.

The retained Linux record is `.silver/linux-x86_64/run-arguments-20261015T132237Z/`.
`checkpoint/` holds per-phase logs and before/after fingerprints; `prior-evidence/`
preserves earlier successful native and Lean evidence. Failed exploratory and
interrupted pre-contract logs remain separate. Real smoke logs retain source,
compiler, snapshot and application binary identities and their program directories.
