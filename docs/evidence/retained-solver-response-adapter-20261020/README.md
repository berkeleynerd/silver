# Solver-response adapter design evidence

This packet supports
[the design note](../../research/retained-solver-response-adapter.md) for
#119 / #153. It does not implement #88 or replace the current full-file q.

`check.py` is an offline evidence script, not Silver-owned production adapter
code. Run from the worktree root:

```text
python3 docs/evidence/retained-solver-response-adapter-20261020/check.py
```

It verifies the retained driver/member identities, expands their response
directives in source import order, checks the complete pattern-shape partition,
records source excerpts, compares the token reducer with a direct source-shaped
evaluator, and checks the finite canonical table and wildcard endpoint rule.
It regenerates JSON evidence deterministically.

- `inputs.json`: source/member identities and the Why3 revision.
- `loaded-response-directives.json`: exact loaded response order, including
  distinct step-answer and steps-measurement concepts.
- `source-witnesses.json`: Why3 analyser, loader, timing, report and process
  source excerpts.
- `checks.json`: 106 reachable reducer states (bound 110), 354,312 concrete
  token comparisons, 31 canonical rows, maximum 76 output bytes.
- `canonical-table.json`: exact bytes and token witness for every row.
- `byte-construction-checks.json`: complete pattern-shape coverage, 1,555 CVC5
  and 11,111 Z3 endpoint cases, crossing checks, adversarial byte fixtures and
  the explicit 1,417,216-byte proposed storage reservation.
- `re-api-source/`: narrowly retrieved public ocaml-re API/source behavior at
  commit `f09672608781dc05172ad980a6e9a483c3b9d534`, with its manifest and
  license. This is not installed-version attestation.
- `round.json`: selected settings, elapsed time and work scope.

The token induction and endpoint/fallback/Alt-Ergo/rank arguments are in the
note. Finite examples do not replace those universal arguments. The fixture
reference maps the selected Emacs regular-expression syntax to Python's common
greedy/first-alternative byte-compatible subset; it does not run or attest
the installed Re.Str implementation. The endpoint oracle uses test-only
absolute offsets; the design replaces them with a bounded live rank order.
The script is not a full streaming implementation and does not verify the
future SPARK refinement, process record or launcher.

No native/solver/proof/capture/observer run or broad predecessor replay was
performed. The focused upstream source retrieval was authorized by the lead.
The finite corpus was rerun after adding complete pattern coverage and full
literal-containment checks requested during review; no expensive validation
was repeated. Current q, changed-prefix attachment, warning-timeout routing,
strict-policy/process joins and pre-entry output bounds remain explicitly
separate from the proposed bounded adapter protocol.
