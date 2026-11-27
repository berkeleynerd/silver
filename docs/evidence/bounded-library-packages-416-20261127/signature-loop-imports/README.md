# Whole Signature loop imported-call closure — 2026-11-27

The complete Signature loop now preserves its native reader frame across every
continuing formal step. The source/type/name guards supply each imported call’s
domain; rejected returns retain their exact partial metadata. The checked whole
procedure relation computes the same total result as `readSignature`, including
zero-formal, completion-mismatch, capacity and malformed-input branches.

The loop-domain check passed a fresh 46,743-declaration audit. The whole imported
loop/execution check passed a fresh 46,755-declaration audit. Both used two Lake
workers, two Lean threads per process and 8,192 MiB per process within the host’s
eight-CPU allocation, reusing the existing private workspace’s matching objects.
The preceding failed domain draft exposed record-update inference and nested-if
tactic selection. Explicit frame application and top-level conditional induction
resolved those proof errors without a native, input-domain or budget change.

The files are focused semantic/import checks, not a complete source or feature
checkpoint. The imported native Append_Package_Formal contract projection remains
its existing separate source obligation. Final authoritative Signature and
Specification source binding and the application endpoint remain outstanding.
The run list and compressed runner logs preserve the outcomes and input inventories.
