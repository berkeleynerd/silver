# Selected save caller-stack composition

2026-10-20 UTC, #119 / #153 Round 38. The selected source-owned save caller
stack now composes from four closed components, under their existing retained
input, native-layout, control and service-interface premises. The result replaces
the earlier incomplete save-entry projections. It does not supply total process
stack, complete save capacity or physical-resource sufficiency.

| Component | Scope |
| --- | --- |
| S | [Serializer, Shape and identifier-printer callers](retained-why-save-serializer-stack.md) |
| T | [Task selection helpers](retained-why-save-stack-helper-closure.md): used theories, used symbols and local declarations |
| G | [Goal explanation and public binder openings](retained-why-save-binder-formatter-stack.md), including collect/concat X |
| F | Same binder/formatter packet's selected Format, decoded-name and constant descendants, including all selected simultaneous reentry |

For one active save, let `P = S + T + G + F`. Each imported component is charged
once. The serializer's exact import inventory supplies all of F's 24 printer
callbacks and `Shape.check`; conversely the frozen providers supply every T/G/F
callee used by S. The private formatter's bounded reentry and the caller's
forest/term ancestries are counted by their respective simultaneous-instance
arguments. This is a composition of invocation scopes, not a union of symbol
names or a bound inferred from a call-graph check alone.

G already contains X, and F already contains `const_shape` and `sn_decode`.
Shared List, Buffer and application-adapter symbols denote separately counted
invocation contexts. No old Round 36/37 binder, serializer, map, name or
output-accumulator projection is added on top of this replacement.

| Case | S | T | G | F | P bytes per active save |
| --- | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 106,788,096 | 94,218,928 | 22,250,024 | 23,008 | 223,280,056 |
| Put | 89,634,104 | 83,665,696 | 19,540,616 | 23,008 | 192,863,424 |
| First_Or_Default | 20,971,856 | 53,568,272 | 6,756,712 | 23,008 | 81,319,848 |
| Is_Message | 3,420,040 | 40,643,072 | 2,637,768 | 23,008 | 46,723,888 |
| Input_Is_Valid | 4,243,344 | 41,652,464 | 2,777,624 | 23,008 | 48,696,440 |

Under the one whole-post-cut allowance `r <= 3` saves and `e <= 2` selected
callbacks, the projection including the direct C/GC bridge high-water and
dispatch-to-save shell is

```text
K_save(r,e) = r * (P + 4,104) + e * 816.
```

At `(r,e) = (3,2)` this is **669,854,112 / 578,604,216 / 243,973,488 /
140,185,608 / 146,103,264 bytes** in the case order above. The maximum combines
conservative occupancies; it is not observed stack use. The bridge's transient
touch is charged even if not simultaneously live with every caller frame.
Neither a helper call, format invocation, retry nor nested save resets r or e.

This closes the previously unclassified **save-entry caller** component. The
following remain outside this projection and cannot be set to zero:

- Stack already suspended in preparation before a callback, `A_pre`.
- Runtime/GC/libc/OS service interiors and service-owned nested crossings, R.
- Signal-setter and exit phases, global formatter queues/wrappers, diagnostics
  and failure paths after leaving the selected save caller graph. The reviewed
  setter has a distinct 48-byte trapped handler; the save shell uses 32 bytes.

The total stack still requires those phase joins. In particular the numbers
above cannot be compared directly with a host stack limit to establish admission
or physical adequacy. Such comparison must use the completed requirement and
the actual configured resource contract. Large overcharges may need tightening
for the parent's useful-domain comparison even though they are sound local
upper bounds.

The [round integration packet](../evidence/retained-why-save-round38-20261020/README.md)
retains the exact input identities and derived sums. Complete-save stack and
capacity remain null/false. This is one retained-case component of #119, not
current-grammar generalization or a rule for admitting new programs.
