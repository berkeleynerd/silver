# Typed package procedure control — 2026-11-22

The [focused run](evidence.json) checks the complete typed procedure-control
module and freshly audits 20,412 declarations using only the standard
foundations. It uses two Lake workers and two threads per process on Linux
x86-64, within the host's shared eight-CPU allocation. Original input digest,
log and managed events are retained in this directory.

The interpreter handles assignment, fixed signature/formal/completion calls,
blocks, void returns, range loops and bounded-evaluator while loops. Lexical
restoration preserves outer bindings and propagates procedure returns. The
state-table growth/write idiom has an explicit constructor and a full-storage
projection theorem based on the checked spare-capacity lemma. Its right-hand
side scope excludes the mutated metadata, preserving the native order of the
paired writes. No truncating active-prefix setter is treated as count growth.

This only checks the interpreter infrastructure and projection. Complete native
helper command trees, their source renders/equations, all callee contracts and
original-Bundle semantic decoding remain open. While fuel is not an admission
condition. Native progress/bounds must eliminate exhaustion at each helper.
The run used the checked shared Declaration API while its branch import was
being resolved; the resolved dependent files retain those exact bytes. An
unrelated missing Names expression module was then copied from the same checked
commit; it is outside this target's audited import closure. No repeat of the
successful target was needed. Selected agent setting was Astra Max; live
model/effort telemetry and CLI memory updates are not claimed.
