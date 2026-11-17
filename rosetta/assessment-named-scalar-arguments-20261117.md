# Named parameters assessment — 2026-11-17

This review updates only **Named parameters**, cached revision 411871, for the
owner-authorized [named scalar arguments](../docs/named-scalar-arguments.md)
capability, #392. The original 2026-10-15 assessment and its model/effort remain
attributed in `coverage.json`; the new review has separate metadata. Broad
procedures, functions and stage issue #11 remain distinct.

The task requires a function whose arguments can visibly bind by formal name
independently of written order. Omitting actuals and defaults are optional. The
old stored `Show` procedure with a default did not isolate that requirement.
The new [sample](../samples/rosetta_named_parameters.adb) defines the scalar
function `Subtract (Left : in Small; Right : in Small) return Difference` and
shows positional, reordered named and mixed calls. A fourth call exchanges the
values, making incorrect binding observable.

`Small = -100 .. 100` and `Difference = -200 .. 200`. Independent enumeration of
all 40,401 integer pairs confirms that subtraction spans exactly `-200 .. 200`.
The four call bindings yield `2, 2, 2, -2`. Standard Integer Image adds one leading
space to nonnegative results and none before the minus sign, giving:

```text
Positional: 2
Named, reordered: 2
Mixed: 2
Reversed values:-2
```

The precise construct is `named-scalar-arguments`; it composes with existing
`scalar-functions`, `named-integer-subtypes`, `bounded-mutable-integers` and
`integer-image`. No other task is reassessed. The precise identifier is now in `supported`
after successful sample execution and complete native/Lean assurance.

Static task/source comparison and independent arithmetic/output derivation are
complete. Focused native run `20261117T030042-d612d38a0399` compiled the unchanged
source and checked exactly the output above. Both auditors accepted its complete
five-unit report (20 flow checks, 51 proof checks and one function termination
witness); the [behavior packet](../docs/evidence/named-scalar-arguments-392-20261117/behavior/README.md)
retains original reports and source/binary hashes. Complete native run
`20261117T034048-8c22c1e6a33d` passed all 19,726 required checks; complete
Lean/source/module/axiom run `20261117T064945-d458c99ae977` passed its fresh
166,332-declaration audit on matching implementation inputs. The earlier Lean
memory failure and unchanged single-thread check are retained in the
[capability record](../docs/named-scalar-arguments.md#delivery-assurance-and-validation).
The capability record tracks the final repository suite and closing independent
review separately from these completed proof and sample checks.
The selected project lead setting is Astra Extra High; live identity and
whole-team cost are not independently exposed.
