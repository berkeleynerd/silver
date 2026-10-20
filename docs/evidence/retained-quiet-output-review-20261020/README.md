# Quiet-route and output-consumer independent review packet

Supports [the review](../../reviews/review-quiet-output-20261020.md) of the two
exact author freezes in `inputs.json`. No native tool, solver, proof runner or
capture was executed.

- `inputs.json` pins every author file and the inherited source/requirement inputs.
- `checks.json` records the focused author/reviewer checker runs, elapsed times,
  matching inputs and reporting scope.
- `check.py` verifies author-file identity against both hashes and exact Git
  objects, checks selected source witnesses, and independently calculates the
  finite response sizes from all ten CVC5 reason spellings.
- `source-review.json` retains the independently inspected source excerpts and
  complete-member hashes. `result.json` retains the finite calculations and
  explicitly null complete q/O.

Run from the repository root:

```text
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-quiet-output-review-20261020/check.py
```

`--write` regenerates the two derived source/result files. The finite-language
calculation does not execute Why3 regular expressions or prove selected task
acceptance. Manual review covers the reached control and conditional partition;
the exact scope and remaining sufficient-input/output relation are in the review.
The whole capacity goal remains incomplete; this packet selects no research-stop
completion and changes no tool configuration or admission.
