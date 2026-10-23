# Canonical reader/parser capacity evidence, 2026-10-23

Author lane for #119 / #153, exact base
`2b9e9f780f9e747d0610663ead3f1e90a4a60c08`.
See [the research note](../../research/retained-why-canonical-parser-capacity.md)
for source arguments, ownership and the unresolved installed-Re numerical
attachment. The packet does not claim full installed-parser closure.

* `inputs.json` pins reused files; `source-spans.json` retains strict source
  ranges with complete member identities.
* `re-source/` adds Group, Mark_infos, Category and Pmark only, from the same
  exact reference commit used by earlier Re evidence. Its manifest records URLs,
  hashes and retrieval time. These sources do not identify the installed version.
* `check.py` is a new identity/arithmetic/fixed-operand checker. The fixed Emacs
  conversion to Python regular expressions checks byte spans for the31 canonical
  inputs, not answer reduction, engine storage, callbacks or native behavior.
  Source reasoning proves those separately and retains its correspondence input.
* `result.json` records the patterns, syntax limits,31 span rows and five-domain
  request counts. `run.json` records the focused check's actual time/platform.
* `round.json` records selected author setting and scope. No token/cost estimate
  or runtime-confirmed model identity is invented.

Run from any directory with `python3 <this-directory>/check.py`. It executes no
target/compiler/solver/Re engine, disassembler, native capture or predecessor
checker/model. No successful predecessor validation was rerun. New code is kept
inside this packet, outside production `scripts/` provenance inputs.
