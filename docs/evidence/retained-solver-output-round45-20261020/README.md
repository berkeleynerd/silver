# Round 45: solver identities and output components

This joins the frozen [identity inventory](../../research/retained-solver-identity.md),
[CVC5](../../research/retained-cvc5-output-capacity.md),
[Z3](../../research/retained-z3-output-capacity.md) and
[Alt-Ergo](../../research/retained-altergo-output-capacity.md) components with
their [independent review](../../reviews/review-solver-output-and-identity-20261020.md).
`inputs.json` records exact author/review freezes and retained input manifests.

The integration checker compares frozen files, existing input identities and
unchanged native pins, then joins candidate revisions, selected commands,
five process identities and the existing conditional JSON multiplicities.
It parses Python and checks local links. It does not replay the component
checkers, source censuses, installed-file reads or native tools.
The check passed **43 frozen files, 58 retained input identities, 94 unchanged
native pins, five Python parses and 23 local links** in **0.527084709 seconds**.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-solver-output-round45-20261020/check.py
```

`integration-result.json` retains the combined result. The CVC5 response-pair,
Z3 statistics-render and Alt-Ergo status-data numbers are separate conditional
family interfaces. They do not bound complete files or establish native/source
correspondence. All complete q and weighted O exports remain null. Retained
single-worker prefixes do not establish the intended concurrent confirmation
configuration. The global callback/save budget is unchanged.

The [round record](../retained-tool-rounds.md#round-45--solver-identities-and-output-components)
records review scope, checks, measured costs and the next missing joins.
