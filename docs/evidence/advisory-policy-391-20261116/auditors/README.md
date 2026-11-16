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

## Integrated correspondence failure and focused repair

The first complete native checkpoint, `20261116T225639-1d97eb007a5a`,
ran in the original integration workspace with its retained canonical cache.
It failed after 653.163 s on one obligation: the `Mixed_Report` postcondition
at line 5338, with `Object_Policy` expanded from line 2480. All 353 flow
checks and 3,481 of 3,482 proof checks in this unit passed. CVC5 and Z3
reached the canonical 30-second limit on the remaining check; Alt-Ergo
reported high failure. The original terminal session 77798 completed with
exit one. The build and full suite did not run.

`native-correspondence-failure.json` records the failure and resources.
The accompanying archive preserves every canonical `.spark` report and Why3
session, the failing generated task and `Mixed_Object` task, source/script
bytes, previous report identities, managed history, terminal log, input hashes,
resource samples and postflight. Native inputs remained unchanged throughout
the run; the intervening integration commit `c45fe22dc` changed Lean only.
All 12 workers were available. Peak sampled tree RSS was 6,510,128 KiB and
minimum available memory was 9,762,752 KiB; the 1.5 GiB headroom guard did
not fire. This remains failed evidence, not a completed native audit.

Independent Astra Max review and the lead agreed on a local abstraction repair:
hide the expression bodies of `Raw_Object_Policy` and `Object_Policy` inside
`Mixed_Report`, so its wrapper proof uses `Mixed_Object`'s already proved
exact policy equality. The edit contains one comment and two `Hide_Info`
annotations, five lines total. It changes no contract, input domain, policy
definition, runtime instruction or control-flow branch. Removing those exact
five lines restores the repaired advisory body from `2288af600` byte for byte
(SHA-256 `3f761cd823acc39ddbf904626ac2b8ea3f71938ccbc0071825f99fe608a5842c`).
This is distinct from the original pre-advisory implementation at `877c382f6d`.
The annotated body has SHA-256
`204a3aef6442a3708a54d081d75680e24c3b8ddae0e96c074dc1c3de14e81e70`.

Focused run `20261116T231315-0432a9be858c` selected every line of the complete
`Mixed_Report` declaration, contract and body. It passed 353 flow and all
18 selected proof checks in 41.205 s under the unchanged canonical policy,
12 workers and 16 MiB stack. All 66 selected Why3 goal nodes are proved;
both identity and projected-report branches and all permitted empty/malformed
states remain covered. Original terminal session 11577 completed with exit
zero. Native input hashes remained stable, and the resource guard did not fire.
`native-correspondence-focused.json` and its archive retain the exact selection,
source comparison, reports, generated task, session, command, resources and
managed history. Existing vendor Big_Integer validity warnings, recursion/
variant limitations and reassociation notes remain distinct from obligations.

Matching neighbor contracts from the complete failed run are reused:
`Mixed_Object` passed 1 flow and 52 proof checks; application projection
correspondence passed 1 and 28; runtime projection correspondence passed 1 and
3; `Audit_Normalized_Report` passed 5 and 48. The local annotations change none
of those contracts or definitions. Earlier successful formal-helper checks also
remain applicable. The next required checkpoint is complete native proof and
build on the integrated annotation commit, followed by complete Lean and the
full suite on the final stable inputs. The lead coordinates those runs.

## Source-policy allowlist follow-up

During the next complete native run, the lead found that the compiler source
policy still omitted the four new reviewed `Hide_Info` targets. The old Python
auditor rejects the exact annotated report body with `forbidden
assumption/check-policy pragma annotate`; the focused proof run does not execute
that complete source audit. The active integration inputs and productive proof
run were left untouched while this repair was prepared in the separate native
worktree. Its actual completion remains a separate evidence record.

The follow-up adds only `formal_advisory_message`,
`raw_formal_advisory_message`, `object_policy` and `raw_object_policy` to the
existing target tuple. The exact complete pragma shape and
`silver_library_reports.adb` restriction remain unchanged; no other annotation,
suppression directive or source file gains acceptance. Ada sources, contracts,
domains and proof obligations are unchanged by this follow-up.

The Python auditor suite passes 79 tests in 1.381 s. Existing positive tests
cover the four new targets with Ada case/comment/layout variants. Existing
negative tests now apply 14 malformed/unreviewed pragma variants and three
wrong-file variants to each new target as well as `Raw_List_Spec`. A new test
audits the actual current report body, covering the integration omission that
the prior synthetic fixtures missed. The other forbidden-directive tests remain.
`source-policy-followup.json` and its archive retain the before-fix rejection,
exact old/new auditor and source hashes, bounded diff and successful test log.
The production diff is checked to contain exactly the four-name extension.
Independent Astra Max review found no issue with the exact diff and confirmed
the repaired checker accepts the actual report body. A cheap read-only policy
scan also accepts every current integration source/generated Ada file using
the isolated repaired checker; its file hashes are retained. This is source
policy preflight, not a proof, report audit or completed provenance claim.

Changing the auditor changes recorded native/Lean input provenance. After
integration, complete assurance still requires a new full native audit and the
final Lean checkpoint on those inputs; matching solver work can be reused.

The preserved run `20261116T231645-98dfa4e47215` then completed at integration
head `66e04090d`: GNATprove proved all 19,515 checks across 78 units
(1,724 flow and 17,791 proof), including all 353 flow and 3,482 proof checks
in `Silver_Library_Reports`. The following source-policy audit rejected the
old allowlist exactly as predicted. Original terminal session 99543 returned
one after 508.943 s; native inputs remained stable, the guard did not fire,
and build did not start. No completed provenance manifest was issued. Peak
sampled tree RSS was 5,046,896 KiB and minimum available memory was
11,146,400 KiB. This run remains failed despite successful obligation discharge.

`native-source-policy-failure.json` and its archive retain the actual outcome,
all completed reports and Why3 sessions, source/generated/script bytes,
generated `Mixed_Report` task, input identities, logs, resources and postflight.
Previous reports already retained in the earlier correspondence-failure archive
are not duplicated. Before integration or an expensive retry, the isolated
repaired checker also passed `audit_sources` over these completed reports using
the exact captured canonical command (1.005 s). The retained
`native-source-policy-preflight.json` records full report and source coverage.
Its checker hash differs from the old run input identity, so this preflight
does not claim completed content-bound native provenance. The final managed
full audit remains required after the four-name checker repair is integrated.

## Complete native checkpoint

Integration head `d60bd8a899fcc66e5ef40112423b7f94b2e4becc` includes the
reviewed four-name checker repair. Run `20261116T232749-c8fb976a6d5c`
completed the canonical full native proof and both source/report audits in
19.090 s. All 19,515 checks passed: 1,724 flow and 17,791 proof across 78
units. `Silver_Library_Reports` passed all 353 flow and 3,482 proof checks.
The new completed provenance manifest matches all 2,606 input hashes,
12 tool identities and 80 report hashes. A fresh `validate_provenance` call
confirmed the current source, scripts, reports, tools, projects and command
identities. The repaired Ada and checker hashes match the reviewed values.

This is a complete audit using retained matching sessions and solver cache,
not a cold proof run. The exact comparison with the prior all-proved run
shows that only `scripts/check_evidence.py` changed among the native inputs;
source, contracts, projects and tools remained unchanged. The original
integration workspace and productive cache were preserved throughout.
All 12 workers were available, the soft stack was 16 MiB, and the canonical
30-second CVC5/Z3/Alt-Ergo policy remained unchanged. Peak sampled proof-tree
RSS was 553,328 KiB and minimum available memory was 15,373,024 KiB.

The successful audit released build `20261116T232809-cb888d4b7deb`, which
recompiled the affected Ada units and linked `silver` in 1.699 s. The Image
adapter was already current. Both stages retained matching native inputs;
neither resource guard fired. Original supervisor terminal session 35541
completed with exit zero. `native-complete.json` and its archive preserve
the completed manifest, reports, Why3 sessions, actual source/generated/script
bytes, command and cache-state records, logs, resource samples, input comparison
and postflight. Archive member hashes were checked after creation.

Complete Lean and the final full regression/sample suite are still separate
requirements. The lead owns their final stable input selection and release of
the held full-suite run; native success does not substitute for those checks.
