# Procedure metadata header normalization — 2026-11-15

## Exact complete-run failure

Complete continuation `20261115T195423-d7650f191422` ran on reviewed production
`ca1c9b2ce` (integration `dbdec4b22`). Its contract-source candidate, declaration
composition, and procedure high-level body/outer specification and implementation
header fragments passed. The `ProcedureDeclarationHighSourceParts.Body` module
then reported an explicit 8 GiB kernel-memory failure at line 26, in the second
theorem `metadata_append_header`. The original `ordinary_0` proof was not the
reported failure; the failed module itself had no successful imported audit.

The exact expected metadata-append header contains **646 characters and 138
tokens**. Its procedure name is `lemma_procedure_metadata_append`, and its
complete-source selector terminates at `is`. The original `metadataAppendHeader`
definition, complete native pre/postconditions and caller/domain claims remain
unchanged. This is a kernel-resource failure while checking a source equality,
not evidence of a changed contract or runtime behavior.

The module failed after 57 s. The first-memory-diagnostic guard sent source-only
SIGINT, interrupting the subsequently started `Outer` source module. Managed
build elapsed 936.276 s; the monitor elapsed 946.159 s. Original execution session
`4737` returned **outer launcher exit 254**; the monitor recorded **child return
-2**, distinguishing the shell status from SIGINT's child-process representation.
No complete module/axiom/source audit occurred. Process peak was 8,394,704 KiB
RSS, tree peak 9,184,752 KiB, and minimum available host memory 3,573,632 KiB.
Neither the 10 GiB source-tree nor 1.5 GiB host guard caused the stop.

All 1,111 prior focused captured-input hashes and both Lean/Lake tool hashes
still matched before repair. Exact failure logs, resource samples, terminal
summary, registry events, original leaf and high-source declaration are retained
here. The exact managed log SHA-256 is
`9851d43ed1b26530239f5e5ab55aac9302b8ca0d05af589586479cc67c489f2f`.
All **621** completed module objects and 3,722 captured variant/hash files were
inventoried before repair and retained. The prior 289-object checkpoint and its
focused success remain distinct from this interrupted complete run.

## Bounded repair and focused gate

The parent authorized exactly `ProcedureDeclarationHighSourceParts/Body.lean`
and the new isolated `MetadataAppendExpectedTokens.lean` helper. The repair uses
the already reviewed function metadata-header normalization mechanism: prove
that the exact literal has the stated character list using checked
`String.toList_ofList`, then kernel-check the unchanged alphabet, fuel and lexer
computation. The original source theorem expands only the unchanged metadata
header definition, rewrites its proved token equality and kernel-checks the
same full-source `procedureHeader` equality. No extraction, uniqueness or source
binding check is omitted.

Both original theorem statements remain byte-identical. The complete
`ordinary_0` declaration and proof remain byte-identical. No metadata definition,
public candidate conjunction, native source, source pin, contract/domain, other
leaf, or script changes. Existing corruption controls apply to the unchanged
character/lexer mechanism; they are not claimed as new extractor-specific tests.
The exact proposed patch and all literal/character/token data require independent
critical review before another complete attempt.

The focused gate is the full `Silver.ProcedureDeclarationHighSourceCandidate`,
covering both new helper facts and every body/outer header and ordinary-source
fragment, including the interrupted `Outer` leaf. Use one Lake worker, automatic
twelve Lean threads and the unchanged 8,192 MiB threshold. The host still has
15.8 GiB total memory and a productive two-worker native run, so two dense Lean
workers remain unsuitable. Keep the existing 10 GiB tree, 1.5 GiB headroom and
first-memory-diagnostic guards. Full focused success and independent review
precede a complete cached retry; there is no speculative additional normalization.

| Work | Model / effort | Result and remaining work | Available cost evidence |
| --- | --- | --- | --- |
| Exact procedure metadata-header diagnosis/repair | Selected Astra Max for source correspondence; live lead setting not independently exposed | Exact failure and bounded two-file repair identified; complete focused gate and critical review pending | Failed complete run 946.159 s monitored elapsed; token and whole-team cost unavailable |
