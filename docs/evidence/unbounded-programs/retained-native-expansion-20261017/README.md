# Native Main expansion accounting evidence

This supports the [native expansion component](../../../research/retained-native-expansion.md).
It is a source-derived direct emitter envelope, not a complete native construct
bound or a selected capacity rule.

Regenerate with Python 3, passing the complete pinned GCC `gcc/ada` source
directory and an output path:

```sh
python3 derive.py /path/to/gcc/ada /tmp/native-concat-local-envelope.json
```

`derive.py` verifies132 source files against the checked-in complete
manifest. It sums the manually derived control-flow rows and emits a lexical
call-site list to help inspect coverage. Neither the sums nor the lexical list
establish transitive helper closure. `local-envelope.json` is the retained
result; it includes the assumptions/omissions and bounded arithmetic examples.
`representative-inputs.json` supplies hash-pinned current sample sources and
manually reviewed syntax counters. The same regeneration derives actual lexical,
scanner and parser inputs for those five programs and applies the22 selected
native table checks plus the parser's two auxiliary tables and loop serial,
conditional on the documented invocation/path premise.
The source/line/selected-name join also checks Source_File, Instances and
SFN_Patterns backing. The fixed vector now adds the two controlled GPR naming
pragmas absent from the direct compiler capture; GPR's additional map/path/
switch storage remains open and explicitly excluded.
The sources all pass those selected checks; these are not complete capacity or
admission results. Arithmetic fixtures remain separately labelled.
No native compiler, GNATprove or Lean run was performed for this source
derivation. The frozen initial component and first delta received
[independent review](../../../reviews/review-retained-native-cbcd679320.md) and
[delta review](../../../reviews/review-native-delta-26b438ab5c.md), respectively.
Those reviews cover their named commits; later scalar, loop, input and runtime
root additions still require review. Whole-Main composition remains open.
