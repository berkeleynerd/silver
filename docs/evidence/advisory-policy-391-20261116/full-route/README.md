# Issue #391: complete admission-fixture full-route twins

The owner authorized this regression repair without changing language membership
or existing verdicts. The baseline is PR #371 at
`877c382f6d07c1e0a2573d4cf70fa13876a399b4`. The full issue #391 and both external
review comments supplied by the lead were read before implementation.

## Inventory and source preservation

[`inventory.json`](inventory.json) maps every positive admission-only fixture to
its original and current test location, per-method check ordinal, exact source
bytes and SHA-256, policy kind, function/procedure inventory, exact formal
spelling/modes and expected execution cases. It contains **88 distinct sources:
24 in the function tests and 64 in the procedure tests**. This independently
agrees with the reviewer's total; the procedure count includes the fixture that
also declares a function.

[`inventory.py`](inventory.py) executes Python fixture construction with the
compiler/check/program interfaces replaced by capture functions. It compares
all 288 source/verdict pairs with those constructed by the baseline test files:
88 positives and 200 negatives, including check order within each method. All
are unchanged. It asserts that every positive has a compile and execution plan
and that no negative has one. This is a static inventory check, not a compiler,
proof, audit, build or program run.

The inventory expands the loops rather than counting check call sites. It
includes all 24 successful validity-selector matrix combinations, all seven
numeric-literal cases and three Boolean-literal conditions, the generated list
of 60 functions, 250 locals, 150 formals, operator limits and exact 4,096-byte
padding. The two test classes inherit from `unittest.TestCase`; their aliases to
shared check/compile/run methods introduce no inherited test methods. Other
test files were searched for local-subprogram source fixtures; the remaining
matches are compiler/library implementation fixtures, rejected constructs,
source-token tests or report-policy tests, rather than further positive
admission-only Silver subprogram fixtures.

Every positive retains its original admission assertion, then passes the same
source bytes to the existing compile helper. That helper runs `silver compile`,
checks the copied author source, audits all selected application/runtime reports
with the Python auditor, and locates the built executable. Each executable is
then checked for exact exit status, stdout and empty stderr. Procedure output
initialization witnesses and function entity/termination coverage remain part
of the full report audit. The explicit policy inventory is 55 assigned, 27
selected and six static fixtures; the static set includes the uncalled null-body
`in out` procedure from the review's smallest reproducer.

The shared helper accepts an optional formal inventory without changing older
callers. New twins obtain exact names/modes from their source headers after
masking comments and literals. This intentionally bounded test extractor accepts
these fixtures' explicit one-name scalar formals. It checks owner sets,
function/procedure kind and ordered `out` tuples against separately supplied
fixture metadata before forwarding the inventory to the auditor. No inventory
or expected output comes from a producer report.

## Independent expected outputs

No reviewer expected-output file or compiler execution was used to choose these
expectations. They were derived directly from the unchanged Ada sources before
toolchain validation. A meaningful sample covers the only five fixtures with
successful output, plus silent procedure/function cases:

| Fixture (original test and check ordinal) | Derivation | Expected stdout |
| --- | --- | --- |
| Function `test_local_hiding_is_independent_of_return_arithmetic`, check 1 | Local integer `A = 1` is returned; outer Boolean array `A(0)` remains true. | `" 1\n"` |
| Same test, check 4 | Local `K = 1` hides outer `K = 2`; the function returns the local value. | `" 1\n"` |
| Same test, check 7 | Local integer `S = 1` is returned; outer String `S = "ab"` is still printed first. | `"ab\n 1\n"` |
| Function `test_boolean_result_carries_no_argument_or_input_facts`, check 2 | Inside the real valid-input guard, `Flip(not Input_Is_Valid)` is true, so the inner branch prints `ok`. | `"ok\n"` for all three valid input cases |
| Procedure `test_calls_preserve_unrelated_scalar_and_input_facts`, check 2 | `Reset` changes only `R`; the following output prints the input unchanged. | `"old\n"`, `"\n"`, `"valid\n"` for default, empty and `valid` |
| Procedure `test_formal_modes_names_and_closing_name`, check 13 | The local procedure is uncalled and Main executes only `null`. | Empty |
| Function `test_local_initializers_are_independent_exact_snapshots`, check 1 | The function's overwritten local does not execute because the function is uncalled; Main executes only `null`. | Empty |
| Procedure validity-selector matrix, all 24 successes | Calls change only local scalar state; no body has an output call. The wrapper rejects invalid input before the call. | Empty |

The other 83 sources have no application output on successful execution. Their
expected stdout is therefore empty; executing them still checks that proof,
auditing, building and runtime completion all succeed on the original source.
Each argument fixture covers the default input, explicit empty input, printable
`valid`, invalid two-argument input and a non-printable byte. Invalid cases must
exit 1 without output. There are **196 expected execution cases: 142 successful
and 54 rejecting**. Every case requires empty stderr.

The review's repair-impact archive member
`artifacts/lanes/S2-refute/tables/suite-fixture-full-route.txt` was read for
comparison. Its 18 previously refused source-hash prefixes all occur in this
88-source inventory: one function and 17 procedures. This comparison is reviewer
history; it does not claim any current compiler result. The compact
[`reviewer-blocker-mapping.json`](reviewer-blocker-mapping.json) records the
archive hash, member, original reviewer job/rule and matching fixture for each.
No review archive or unrelated scratch directory is included in this evidence.

## Validation and remaining work

On Linux ARM64, the fixture capture confirms the complete source/verdict match,
all 88 compile plans, all formal-inventory consistency checks and all 196
expected execution cases. Python byte-compilation and `git diff --check` pass.

No compiler, prover, native build or real test job was started in this isolated
worktree: it has no bootstrapped tools, and the lead reserved repaired-compiler
validation for integration. The integrated focused tests and the owner's
required single complete final-suite invocation remain to be run and recorded
by the lead against the repaired head. This inventory must not be cited as
successful toolchain evidence.

Reproduce the inventory without invoking a toolchain:

```sh
python3 docs/evidence/advisory-policy-391-20261116/full-route/inventory.py
python3 -m py_compile tests/test_shared_bindings.py tests/test_scalar_functions.py tests/test_scalar_procedures.py
git diff --check
```
