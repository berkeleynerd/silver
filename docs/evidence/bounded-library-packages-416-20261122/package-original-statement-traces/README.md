# Complete original conditional and loop traces

The focused `Silver.ApplicationPackageStatementReading` check passed on Linux
x86-64 with a fresh 23,644-declaration audit. [index.json](index.json) retains
its exact run and inputs; every captured source hash matched before retention.
The check used two workers, two threads and 8192 MiB per process. Dependencies
were reused where available. No complete feature check or kernel replay is claimed.

Every accepted native statement-fuel result yields its actual selected branch.
The conditional trace retains every IF/ELSIF arm in source order, each original
condition and child-tail invocation, the optional ELSE, and the exact final
joined scan. The loop trace retains its original header, widened input, inner
context, mandatory body invocation and final flow/cursor. Both kinds retain the
native progress and validity checks. These readings contain no semantic checker
or safety certificate. They apply to every completing accepted reader execution,
without adding any source nesting or arm limit.

The first draft exposed nested Option equalities, local expression typing and
let normalization. The second had only two redundant dsimp lint errors. Failed
runs and the diagnostic are retained. Native source, declared domains, trust
assumptions and proof budgets were unchanged. Recursive syntax/semantic lowering
and the final original-source/external-completion endpoint remain outstanding.
Selected GPT-6 Astra Max; runtime model/effort and cost/token measurements were
not independently exposed. Phase timings are recorded in the evidence.
