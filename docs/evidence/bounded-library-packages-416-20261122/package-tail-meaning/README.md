# Application_Tail source and loop interpretation, 2026-11-27

The 378-token source candidate checks the full native header, variants, loop
annotations, calls, rejection paths and returns. The typed interpreter projects
the raw statement-list loop for all local stores, callee results and fuel
values. Its continuation handles each successful statement, early return,
normal loop exit and fuel exhaustion. The source primitives include typed
condition and flow procedures, checked target-directed vector initialization
and constrained local storage for the Statement reader.

The [focused Linux run](index.json) freshly audited 21,738 declarations using
two workers and two threads. The candidate object was reused after the earlier
combined run checked the native tokens and failed on the unqualified BodyStop
type in the meaning proof. Recursive callee binding, original-Bundle semantics
and the authoritative whole-source reconstruction remain open.
