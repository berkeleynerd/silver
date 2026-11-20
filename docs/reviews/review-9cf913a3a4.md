## External review of this PR at `9cf913a3a4`: interim result

**Reviewer:** Claude (Fable 5.2), independent external review. **Date:** 2026-11-20. **Status:** interim, light review.

### Bottom line

**Nothing found blocks the merge.** No blocker and no medium-severity finding: one low finding (a gap in a record) and six observations. This was a light review: it covered the changed lines and what they claim, nothing more. The compiler and the proofs were not re-examined, because no compiler build input changed relative to the baseline. The two wider passes of a full review (capturing every source the test suite compiles, and sweeping newly admitted programs through proof, build and run) were not run.

### Scope

- **Target:** commit `9cf913a3a4a69cb40fe99ea39f21d0e237647fe1` (`develop/issues-400`), 2 commits, on Linux x86-64, with a compiler the reviewer built from these sources.
- **Baseline:** `a03c7987bbba29569db2709820bd26ced20bed40`. 520 files changed: 476 under `rosetta/`, 35 under `docs/`, 5 under `samples/`, 1 under `tests/`, plus `language.md`, `roadmap.md` and `rosetta.md`. Nothing under `src/`, `proof/` or `scripts/`, and no build file, catalogue entry or Oracle text.
- **Lanes:** three of the four review lanes examined the diff. The fourth, on proof statements, reported nothing in its subject (no file under `proof/` or `src/` changed); it did not look and find nothing.
- **Not covered:** ARM64 and macOS; GitHub (issue #400, the owner amendment, this PR's state); and the items under "Not examined".

### Blockers

None.

### Checked and found sound

| Area | Result |
| --- | --- |
| Complete test suite on the reviewer's build | 724 tests, all pass, at a recorded stack limit of 16,384 KiB |
| The four new samples | Admitted on this head and on a baseline build; proved, built and ran with output byte-equal to the manifest (append 33 bytes, prepend 31, bottles 11,357, repeat 11) |
| The six positive test programs | Admitted on both builds; ran with the tests' own expected bytes |
| The five claimed rejections | All five rejected on both builds; the near-identical variant paired with each is admitted |
| The new tests can fail | Forward-shift variants of two prepend fixtures print bytes the tests would reject |
| Regression accounting | Retained ARM log: 724 ids, 722 pass, 2 skipped; the same 724 ids as the reviewer's suite, where the two skipped tests pass |
| Sample manifest | 86 → 90 programs, 149 → 153 cases; the 86 earlier entries are unchanged |
| Rosetta accounting | Supported identifiers 16 → 17; Stage 1 85 → 89; 472 changed pages = 12 changed assessments + 460 position-only |
| Evidence packets | `probes.tar.gz` hash, `inputs.sha256` (27 of 27), delivery `SHA256SUMS` (28 of 28) and both suite-log hashes are as stated |

The lanes made 120 admission checks and 38 full runs over 44 distinct programs; a separate challenge reran 18 of those programs. Every run matched an expectation fixed beforehand.

### Low finding (affects no admitted program)

1. **The retained ARM suite run has no recorded stack limit.** 722 of the 724 test results the delivery relies on come from one retained Linux ARM64 run. `development.md:297-301` says of such runs: "Capture the actual limit with run evidence." The retained records hold none (`"invoking_stack_limit": "not recorded"`). The documents say so (`docs/bounded-string-building-samples.md:38-39`), yet the record is headed "Validation complete" (`:5`). The previous delivery's suite record did capture the limit (`docs/evidence/named-scalar-arguments-392-20261117/complete-suite/README.md:20-31`). All 724 test ids passed in this review on x86-64 at 16,384 KiB. The ARM setting itself cannot be reconstructed here.

### Observations (informational)

1. The rejected control for the append idiom (`append-with-loop-local-len`) differs from the admitted sample in two ways, each refused on its own: indexing with `Len` inside the copy loop, and updating `Len` after it. The documents name only the first (`docs/bounded-string-building-samples.md:70-72`). Their explanation is right; this control alone does not isolate it.
2. The prepend sample prints the same bytes with `reverse` removed from its shift loop. Two new test fixtures do detect the order.
3. Seven of 29 line citations in added text are 2 to 24 lines off, because this change inserts lines into the cited files; the record pins its citations to main `5af7edc5cd` (`:13`). Five further passages still describe the state before this change.
4. The changed assessments cite planning runs whose sources are not in the tree; the results for the eight further tasks are record-only, as the assessments say.
5. For four of the 32 files in the closing review's input manifest, the reviewed bytes are in no commit of the range; the review states the reason (`docs/reviews/review-bounded-string-building-closing-20261120.md:197-198`).
6. The recovery checks ran on two archives that are not in Git (`pr403-records.tar.gz`, `lean-392-cache.tar.zst`), so this review could not repeat them.

### For the owner's judgment

- **Does disclosure satisfy the rule?** `development.md:303-312` lets a completed suite plus repair reruns stand when a recorded review "establishes which successful results remain applicable to the final inputs and settings", and adds: "If coverage or applicability cannot be established, rerun the full suite." The delivery relies on this with one setting unknown, and chose disclosure over a rerun. No recorded owner decision waives the recording rule.

### Not examined

- Proofs: no Lean or proof job ran; the proof totals are the project's retained records.
- The baseline build was used for admission only.
- Unchanged compiler behaviour, beyond the paired programs the claims needed.
- The project's scripts, including the Rosetta renderer, were not run by a lane.
