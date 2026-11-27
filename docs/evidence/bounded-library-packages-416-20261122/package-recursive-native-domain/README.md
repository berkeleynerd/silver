# Native recursive input domains

The focused Linux x86-64 check covers the complete shared native
Basic/Statement/Tail preconditions and derives the actual conditional and loop
child inputs. The original native Body_Context witness retains dynamic-name
positions. Both condition refinements preserve the full scalar-flow domain;
the loop proof preserves all context fields, widens existing mutable cells and
appends the captured readonly iterator over its full declared interval.

The check and fresh axiom audit passed 31,487 declarations, using two Lake
workers, two Lean threads and 8192 MiB per process on CPU 0–1. The retained
evidence records the exact run and captured input bytes. No successful run was
repeated. This remains partial assurance; complete recursive extraction,
semantic checking and the original application/tool endpoint are outstanding.

The first attempt found a stale inherited six-field ScalarExpression.Binding
constructor. Its existing primary repair from aa360256ff was synchronized here.
Later attempts resolved local native-context projection and tactic parsing
issues; the checkpoint records the focused diagnostic. Native source, declared
domains and the Oracle are unchanged. In particular, package metadata validity
and completion are not added to the shared native precondition.

Selected setting: GPT-6 Astra Max. Live model/effort and token/cost measurements
were unavailable. Input hashes were verified when evidence was retained.
