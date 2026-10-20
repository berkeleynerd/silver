# Retained CVC5 registry/name evidence

Research #119 / #153, 2026-10-20. See the
[argument](../../research/retained-cvc5-registry-domain.md).

Inputs are the existing complete archive
`../retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz` and its
`registration-sites.json`, at CVC5 revision
`86cecd83b685f59e884094693b9a4c5c90a62e03`. The archive SHA-256 is
`19d7bbe18166fa175ff537f226e8df5e229b6a28497cb823f82eb734ceed684c`.
No new source fetch or installed executable is used.

- `check.py` rescans all source-file suffixes for registration spellings,
  checks retained source anchors, expands the reviewed constructor domains,
  deduplicates names independently in the two registries, and checks arithmetic.
- `expanded-sites.json` maps each of the 354 direct sites to its name domain
  and owning registry. The equality-engine counter family is separately symbolic.
- `records.json` contains the static registry/name/type superset and every
  contributing registration site. Histograms use canonicalized type labels.
- `source-identities.json` hashes all source members used by the scan or anchors;
  their complete bytes remain available in the existing archive.
- `source-anchors.json` retains checked source snippets for the reviewed chains.
- `result.json` contains deterministic counts and symbolic interfaces.
- `check-result.json` retains the final offline check output and measured time;
  `round.json` records scope, selected setting, elapsed time and limitations.

Run from any directory:

```sh
python3 docs/evidence/retained-cvc5-registry-domain-20261020/check.py
```

`--write` regenerates deterministic packet data after an intentional source
argument change. A passing checker is a source-byte, lexical and arithmetic
check; it does not establish compiler-complete reachability, generated-command
preservation, native/source correspondence, full output capacity or discharge.
The note's conditional zero/default projections require their explicit premises.
No solver/native/proof/full-suite work or GitHub mutation belongs to this packet.
