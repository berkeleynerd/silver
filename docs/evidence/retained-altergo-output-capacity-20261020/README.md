# Alt-Ergo selected output evidence

This packet supports the [bounded source argument](../../research/retained-altergo-output-capacity.md).
`inputs.json` pins the downloaded archive and the selected source files retained
in `sources.tar.gz`, as well as existing repository inputs. `excerpts.txt`
retains line-numbered source intervals with trailing display whitespace removed;
the archive preserves exact source bytes. It contains candidate source,
not an attestation of the installed executable's build.

`check.py` checks identities, excerpt reproduction and status-payload arithmetic;
`result.json` preserves its scoped exports. Run without tools or network:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-altergo-output-capacity-20261020/check.py
```

No complete output-file bound is exported. Formatting/layout, occurrences,
other output families, generated-task exclusions and native correspondence stay
open. Check time is recorded in `check-run.json`; author total time/model and
token/cost data are unavailable. No target program, proof or solver was run.
