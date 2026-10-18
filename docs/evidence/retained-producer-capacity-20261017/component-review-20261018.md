# Focused producer component reviews

## Storage arithmetic

2026-10-18. Reviewed the root lane's
[`retained-producer-storage.md`](../../research/retained-producer-storage.md)
at commit `c3dbe00ae8`, alongside this producer aggregate. No material defect
found. This was a focused source/arithmetic review, not a broader assurance
review or compiler/proof execution.

Checked the complete pinned GCC implementations of the one-item indefinite
vector Append path, first allocation, Insert growth/clamping, append copying,
Length and Clear, plus doubly linked-list Insert/Adjust. The two index bases,
empty sentinels, node-zero entry, largest guarded doubling and final-index
sums match the stated conditions. The eight-byte pointer backbone and
24-byte link-node layout agree with the retained installed DWARF inspection.
The record properly separates temporary copies, actual physical allocation
and other auxiliary container/tampering arithmetic.

Independently ran the root evidence checker against the pinned GCC source,
writing output only to `/tmp/silver-producer-storage-review-20261018`.
It checked five source identities and 174 boundary transitions successfully.
Those finite arithmetic checks corroborate the source argument; they are not
an exhaustive run over every possible vector length.

## Fixed dependency reduction and Main constant assumptions

A separate focused reviewer checked the producer report's additive
isolated-root envelope and zero extra external-constant assumption body in
Main. No blocker was found. The reviewer read and hash-matched seven retained
producer source files, then inspected the direct-module traversal and
assumption filter, entity symbol/module caches, ordered registration and
translation passes, hidden-global union, current-subprogram/result context
resets, and both selected public library specifications.

The accepted reduction is for the four-component Why node/list/element/
expanded-occurrence vector. It retains every witness's Main contribution and
the separate global import allowances. It does not establish name-byte or
symbol-counter bounds, auxiliary-container peak size, complete frontend
capacity, or source-to-installed-binary correspondence. The reviewer did not
execute the witnesses or claim an exhaustive whole-process review. Actual
measurement results belong to the root lane's fixed-producer evidence record.
