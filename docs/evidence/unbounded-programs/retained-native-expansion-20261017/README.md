# Native concat local accounting evidence

This supports the [native expansion component](../../../research/retained-native-expansion.md).
It is a source-derived direct emitter envelope, not a complete native construct
bound or a selected capacity rule.

Regenerate with Python 3, passing the complete pinned GCC `gcc/ada` source
directory and an output path:

```sh
python3 derive.py /path/to/gcc/ada /tmp/native-concat-local-envelope.json
```

`derive.py` verifies thirty-eight source files against the checked-in complete
manifest. It sums the manually derived control-flow rows and emits a lexical
call-site list to help inspect coverage. Neither the sums nor the lexical list
establish transitive helper closure. `local-envelope.json` is the retained
result; it includes the assumptions/omissions and bounded arithmetic examples.
No native compiler, GNATprove or Lean run was performed. No independent review
has yet been completed for this component.
