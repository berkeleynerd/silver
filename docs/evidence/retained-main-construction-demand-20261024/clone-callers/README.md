# Source-attached clone callers

Continuation of #202 under #119, after accepted bridge/repair
`3f4f6143c206518bf257d3d9b63cee2a08d14bcd` and independent review `536c35cd2c`.
See the appended source-attachment section in the
[research note](../../../research/retained-main-construction-demand.md).

`inventory.py` performs the new finite origin/global-state classification.
It reuses only the retained import tokenizer/comment masker and accepted
import-result graph; it never invokes that predecessor checker's main.
`callers.py` records the source-constructor history and direct-root recurrences.
`check.py`, `identity.json`, `result.json` and `round.json` bind the new-only
source/structural evidence. Fixtures exercise the induction; they are not
external admission certificates. The old bridge, checker and receipts remain
unchanged.

The bounded result concerns actual clone-map coverage/capture safety and
direct clone_term/clone_cty/direct c_app multiplicities for the inventoried
frontier. Complete native byte demand and kode/SPWP demand remain open.
No compiler, native target, capture, prover, solver, Lean, GitHub write or new
subagent is used.

The checked frontier has 64 fixed explicit origins plus five additional Main
origins (69 total), 97 dependency modules and 26 lexical nullary-let
candidates. The complete corpus has four global objects: standard Main's
`__HEAP`, `no__return`, attribute-bearing `spark__branch`, and Random63's `s`.
None supplies a foreign free variable to a reached cloned origin. The source
argument also checks the converter/type-instantiation boundary and the fixed
parser's branch constructors; it does not infer this from literal corpus
absence alone or exclude state from ordinary Main bodies.

Run only the new checker from the repository root:

```sh
python3 docs/evidence/retained-main-construction-demand-20261024/clone-callers/check.py
```

The final author run passed 674 counted checks in 1.283644 seconds on Linux
x86_64. These are source identities, finite inventory and structural
diagrams; the universal scope/history argument is in the research note.
The example count (27 term roots, three contracts, three direct applications)
is a diagram, not a measured whole-Main total. Later clones must count the
actual stored records output by earlier clones, not unchanged ancestor
weights. Internal builder operations still need their separate demand bounds.

Independent review is pending at this author freeze. The process-wide
`e <= 2`, two save-entering callbacks and three saves are unchanged, as are
Oracle/admission, source/tool pins and deferred production #88–#94.
