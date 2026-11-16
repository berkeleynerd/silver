# Formal advisory auditor repair (#391)

The owner-authorized repair adds `INOUT_ONLY_READ` and `UNUSED_INITIAL_VALUE`
without changing language membership or any required proof obligation. The
implementation baseline is `877c382f6d07c1e0a2573d4cf70fa13876a399b4`.
The issue and both external review comments were read in full before editing.

Production changes are confined to `src/silver_library_reports.adb` and
`scripts/check_evidence.py`. No bindings package, JSON parser, report-capacity
constant, termination policy or AoRTE requirement changes in this subthread.

## Exact policy and full helper domains

Both entries require warning severity, flow provenance and list membership,
file `main.adb`, positive line and column, and absence of each `justification`,
`justified`, `suppressed`, `annot_kind` and `justif_msg` field, including empty,
false and null values. Existing record checks supply those requirements.

`INOUT_ONLY_READ` accepts exactly `"NAME" is not modified, could be IN` for a
declared procedure's `in out` formal. `UNUSED_INITIAL_VALUE` accepts exactly
`unused initial value of "NAME"` for a procedure's `in` or `in out` formal or a
function's `in` formal. The name uses the declaration's exact case. Main,
runtime callees, unrelated owners, output-only formals, other templates and
other rule/template pairings are excluded. Locations are not bound to declaration
columns, and record order is unrestricted.

The native owner/pool predicates follow the existing `Output_Formal` guards:
they handle all typed entity identifiers and metadata, including empty pools,
zero or invalid owner slices, and malformed source bounds. No
`Valid_Metadata` precondition was introduced. `Formal_Name_Valid` and
`Formal_Advisory_Text` accept arbitrary Strings and Natural bounds and guard
every source slice. The quantified executable classifier has only the existing
bounded-text precondition. The raw-byte classifier has no report length bound;
`Mixed_Formal_Advisory_Message` proves equality under the existing field
observation relation, for both rule selectors and all typed metadata. Existing
diagnostic branches remain literal disjuncts in both bounded and raw policies.

The Python interface previously supplied function names and procedure output
names only. Its new optional `application_formals` parameter is **trusted source
inventory supplied independently of the reports**:

```python
{"Id": (("X", "in"),), "Clear": (("Value", "in out"),)}
```

Keys must identify source-declared local subprograms from the existing
inventories. Formal names are bounded identifiers with no case-insensitive
duplicates; modes are `in`, `out`, or `in out`. Functions permit only `in`;
the output formals of a supplied procedure entry must exactly agree with its
existing output inventory. The total supplied formal count is source bounded.
Omitting this parameter supplies no acceptance for the new advisories and
preserves old calls. No report-derived default or new production source parser
was added. Test-only full-route plumbing is owned by the regression subthread.

## Mutation coverage

The two auditor suites share 1,076 negative records and 20 accepted formal
records across Static, Argument, Assigned and Selected bases. Each base contains
declared procedures and a function; the Static and Argument bases include their
appropriate runtime callee inventories. Mutations cover Main/runtime/unknown/
other local owners; function and procedure modes; exact spelling; no formal;
swapped rules/templates; info/medium severity; non-flow provenance; foreign files;
invalid/missing locations and required fields; both other record lists; and all
five justification/suppression fields with four values each. Positive controls
change locations, reverse records/entities and omit optional assumption claims.
The Python suite additionally checks inconsistent or absent source inventories.

## Genuine accepted reports

`accepted-reports.tar.gz` contains six bounded, unmodified source/report sets
read from the owner's untracked external-review archive. The original archive
was not modified or committed. `accepted-reports.json` identifies every original
job, the review target/archive digest, exact file digests, application kind and
independently read source inventories. It includes all five original `.spark`
files and the original summary and SARIF for each case. No warning was removed
or report reserialized.

The cases are literal output, an input/output copying procedure, an output-only
procedure, a function with a used input, a Main-only argument program with
25 existing flow advisories, and an argument program with an uncalled procedure.
The review ledger records successful proof, compile and run for each. This
subthread re-audits those original bytes; it does not claim a fresh program run.

`accepted-python-results.json` records successful audits using the original
Python auditor extracted from the exact baseline commit, and the repaired auditor
both with and without the new inventory. Every verdict and statistics map is
identical. Both test suites retain these corpus cases as additive-regression
controls. `accepted-native-results.json` records the native comparison: the
baseline auditor built from the exact original body accepts all 30 original
unit reports and rejects all 20 new-formal advisory controls. The repaired native
test run accepts those same 30 original reports and all 20 new controls. The
corrected byte-stream test harness feeds each original report unchanged.
`native-additivity.tar.gz` retains both managed runs, the comparison program,
baseline source and test harness. Native build run
`20261116T224834-8bb169fa0548` used two workers; serial comparison
`20261116T224935-51e241ca8feb` used one. Both original terminal sessions
(5369 and 87953) completed with exit zero.

## Validation status

Native host: Linux aarch64, 12 available CPUs, approximately 16 GiB RAM, no swap.
Compiler/test children use the existing 16 MiB soft stack limit. The helper run
uses the canonical 30-second CVC5/Z3/Alt-Ergo proof policy; no proof timeout or
input domain was weakened.

The Python suite passed 78 tests after the corpus addition (1.308 s). Focused
native run `20261116T223829-a66b58aff2d9` selected all 498 lines of the complete
new helpers and the affected diagnostic and record correspondence callers;
its selection and coverage map are retained in `native-focused.tar.gz`, together
with original reports, log, run events, all 12 helper/caller sessions and the
audited source/script bytes. It passed 353 flow and 317 proof checks in
291.151 s using 12 managed workers after the focused Lean run released its
reservation. Original terminal session 8963 returned zero. Every selected
session has zero unproved goal nodes; all four affected postconditions passed.
The report's warning records are existing vendor Big_Integer validity premises,
numeric-variant/recursive-contract limitations and operator-reassociation notes,
not failed selected obligations. `native-focused-summary.json` identifies their
exact counts, source hashes and the focused scope. The managed runner confirmed
stable input bytes; this is not a complete native audit.

Native report tests passed all 42 methods in 7.483 s under managed run
`20261116T224802-ca1cbe3b87c0` (two reserved workers, original terminal session
9595, exit zero). `native-tests.tar.gz` retains its log, events and harness
inputs. The first run `20261116T224535-115792dc7b22` passed the formal mutations
but failed all 30 genuine-report controls: the old test probe read only the first
line of each pretty-printed report. This was a harness defect, not an auditor
failure. The repair reads Standard_Input's byte stream to EOF without JSON
reserialization. `native-test-failure.tar.gz` retains the failure and pre-fix
harness inputs. No production source/script byte changed after focused proof.

The lead owns the final complete native, Lean and full-suite checkpoint. A
separate whole-unit exploratory reproof would duplicate the complete native
audit after the focused helper/caller gate and is not scheduled.

Model and effort are inherited from the lead and are not independently exposed
to this subthread. Token/cost measurements are unavailable. The lead reports an
independent Astra Max review of the exact Ada/Python hashes in the focused
summary, with no actionable defect. Final integrated review and publication
remain owned by the lead.
