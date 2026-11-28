# Independent metadata-abstraction policy review

Read-only source review for #416, 2026-11-28. The source-bridge agent reviewed the repair separately from the lead who implemented it. Parent selected Astra Max; actual live model/effort settings are not independently exposed. No native source, contracts or proof settings were changed by this review.

The original failure is in the existing package work: commit `e35fd0a741` (private original `8dea77baad`, 2026-11-22) added two caller-local annotations in `Audit_Normalized_Report`, at `silver_library_reports.adb:5762` and `:5764`. Their exact targets are `Application_Metadata.Valid` and `Application_Metadata.Owned_Views_Match`. `audit_source_policy` admitted only its listed unqualified 12-token pragma forms; these qualified targets each require 14 tokens. This mismatch predates the separate timeout-policy change and belongs to #416.

The abstraction has a concrete justification at this boundary. The executable rejection guard at lines 5766–5767 and declarative `Object_Policy` at lines 2570–2571 invoke both predicates on identical arguments. `Application_Metadata` is the package rename declared in `silver_library_reports.ads:8`; the two total expression functions remain defined in `silver_application_report_metadata.ads:70` and `:104`. Hiding these expression bodies from this caller removes definitions from its proof context. It does not assume either guard true, remove the executable tests, weaken the result postcondition or suppress an obligation. Their owning-unit validation remains required. The retained `report-policy-focus` packet records the earlier 53-check helper and 3,999-check unit success after the annotations; it did not establish success of this failing source-policy regression.

Reviewed repair: the diff in `tmp/packages-416-proof-timeout` against `82a03c1413`, restricted to `scripts/check_evidence.py`, `tests/test_evidence.py` and `docs/trusted-boundary.md`. The new set contains only the complete 14-token forms with package token `application_metadata` and selector token `valid` or `owned_views_match`, still only in `silver_library_reports.adb`. The original 12-token set remains unchanged. Exact producer, annotation kind, quoted string, separators, closing parenthesis and semicolon are preserved. Arbitrary qualified targets, other packages, unqualified aliases, other selectors and other files remain rejected. The existing positive/layout, malformed-complete-form and wrong-file tests now cover both targets and qualified near misses. Guidance names both and also restores four already-allowed unqualified targets that its prose omitted.

No issue found in this bounded repair. The lead reports managed run `20261128T004851-ac8b9ff03797` passed 79 tests; this reviewer did not rerun them. This source review does not substitute for fresh complete native/source assurance after the auditor input changes.

Reviewed repair file SHA-256 values:

| File | SHA-256 |
| --- | --- |
| `scripts/check_evidence.py` | `fe3713c8b3ba692df70564cc71cc454946da1c85550dcb0f3a58ee7c0106527a` |
| `tests/test_evidence.py` | `dbf606330f97dde75d9462c95e6082ebb5c789747676e6668ee1d4a28535a642` |
| `docs/trusted-boundary.md` | `ee0739a09fdadacca76a1dbb226ab599a285826eead908d83e282e8e7de9cccb` |
