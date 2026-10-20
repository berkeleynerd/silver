# Binder and private formatter stack closure

Run `python3 docs/evidence/retained-why-save-binder-formatter-stack-20261020/check.py`
from this checkout. Requires the retained disassembly and executable at their
recorded local paths; it does not regenerate them or execute the target.

- `check.py`, `formatter.py`, `formatter-spec.json`: focused closure/frame/input
  checker and explicit source-selected formatter specification.
- `call-closures.json`, `formatter-call-closures.json`: binder and formatter
  graphs, indirect targets, exclusions, exact public/static closure identities.
- `native-bodies.json`, `native-frames.json`: retained disassembly and checked
  own-frame/trap upper bounds.
- `source-witnesses.json`, `inputs.json`: exact source excerpts and input identities.
- `multiplicities.json`, `result.json`: source-context counts and resulting
  complete component bounds; whole-save/process bound stays null.
- `round.json`: authorization, selection, elapsed-time and verification record.

The [argument](../../research/retained-why-save-binder-formatter-stack.md)
provides the semantic premises and composition interfaces. The script is an
identity/arithmetic/finite-closure check, not a proof of the source/native
behavior relation or of the source context induction.
