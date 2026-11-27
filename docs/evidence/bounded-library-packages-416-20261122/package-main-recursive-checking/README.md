# Main original checker folds — 2026-11-27

Focused run `20261127T221747-be1e81defea4` passed MainRecursiveChecking and audited 37,611
declarations on Linux x86-64, two workers/threads,8192MiB,CPU0–1. All local
captured input hashes verified. Selected Astra Max; live model/cost unavailable.

Original Basic syntax has no recursive binders. The separate derived
MainChecked result carries well-formedness, exact full-table checker flow and
scalar-binder separation; its complete statement-list obligations follow by
existing discharge. Original sequential composition preserves each property.
main_basic_decoded now derives the source-only recursive Basic node and this
local semantic result from original typed-body equations and native domains.
No checker result is added to SourceMeaning or native helper preconditions.
Remaining conditional/loop recursive induction and effects are not completed
by this focused check. Complete assurance remains outstanding.
