# Fixed-size Integer arrays

Status: authorized design and implementation; not supported yet.

The [2026-10-27 owner instruction](session-memory.md#2026-10-27--fixed-size-integer-arrays-authorized)
selects one bounded array increment under
[milestone 10](https://github.com/berkeleynerd/silver/milestone/10) and
[#260](https://github.com/berkeleynerd/silver/issues/260), linked to the broader
[arrays stage #12](https://github.com/berkeleynerd/silver/issues/12).
Baseline: `7acddbcc0f4e7e1aec567f496539f956864ed294` (PR #259).

Start with one faithful Rosetta program and the minimum useful one-dimensional
Integer-array declarations, initialization and element access/update rules it
needs. Exact grammar, component and index bounds, name resolution, initialization
and composition rules are design obligations, not current language claims.
Record focused producer probes before extending report handling. Keep the
current 4,096-byte source and 63-operator limits; derive feature-local storage
and report accounting within them.

Completion requires agreement among the native compiler, specification and
catalogue; universal composition, automatic-discharge and exact-source arguments;
complete native and Lean/source/module/axiom assurance; regression/sample
validation; and independent review. Update the Rosetta mapping for precisely
the delivered fragment. Broader arrays remain unsupported where their forms
exceed it. Ordinary cached iteration and the existing stable-checkpoint workflow
apply; a focused pass is not the final delivery checkpoint.

General array expansion, other #11 constructs, capacity/assurance modes and
further #246 optimization work are outside this increment. The Oracle and
trusted toolchain remain unchanged. Avoid new infrastructure unless the selected
capability requires it.

| Round | Selected model/effort | Intended result | Result and available measurements |
| --- | --- | --- | --- |
| Initial design | GPT-6 Astra / Extra High for assurance; GPT-6.1 Sol / Extra High for driver/native design | Select a faithful driver and a compositional fragment | In progress; no proof or native validation has run. Lead runtime setting and token/cost measurements are unavailable. |
| Authorization review | GPT-6.1 Sol / High | Check the three planning files against the owner instruction and current sequence | No blocking finding; one wording clarification applied. Relative links and whitespace checked. Runtime settings and elapsed/token/cost measurements are unavailable. |
