# Raw library-probe path evidence

2026-10-23 UTC; Linux x86_64; #119 / #153; author base `f795674a1c`.
The [source argument](../../research/retained-why-library-probe-paths.md)
attaches all configured directories and registered extensions, including
unsuccessful stat candidates. Independent review is pending at author freeze.

The focused check passed **3,221 checks in 2.151922 seconds**. It pins 17
provider files, 29 source members/45 strict ranges, 12 selected native functions
and three decoded static strings. It checks 2,888 retained disassembly lines
against exact ELF bytes and derives all 80 candidate paths across four bases.
No target or predecessor program ran. The check invokes no disassembler.

```sh
PYTHONDONTWRITEBYTECODE=1 python3 docs/evidence/retained-why-library-probe-paths-20261023/check.py
```

Exports in `projection.json`:

* `P_stat=167`; four immutable directories and five registered extensions,
  including sexp; at most 20 candidates per selected locate invocation.
* Up to 52 direct string allocation requests, 98 new cons cells, 47 fixed
  closure words and at most 4 source exception-record words; direct managed
  requests total at most 870 words per invocation.
* A single native pathname-copy request is at most 168 bytes including NUL;
  their prospective sum is at most 3,188 bytes per invocation.
* Concrete string/index/list representation guards hold. Global locate-call
  count, FileTags capacity and whole-process capacity are not asserted.

The direct request envelope excludes GC/runtime-service internals and
independently charged signal/save callbacks. It does not infer process RAM
from the final candidate list. Physical-resource and source/native premises
remain unchanged; all failures/prefixes are covered, and global e<=2, two
save-entering callbacks and three saves are not renewed. The previous R69
unresolved four-extension display is explicitly corrected; its diagnostic
path theorem remains unchanged.

`inputs.json` pins retained inputs. `source-ranges.json` and
`source-witnesses.md` retain exact strict excerpts; `registration-census.json`
contains all registration references in retained Why3 src/plugins source.
`providers.json` joins each actual process, resolved-executable collector,
complete config and mapped-plugin identities. `projection.json` includes
the complete candidate strings and intermediate allocation lengths.
`result.json` and `check-attempt-1.log` retain the single passing focused run.

The generated Config implementation was unavailable as source, so a narrow
target-free native attachment was necessary. `native-inspection.json` pins
the installed ELF, disassembler, exact symbols, complete function bytes,
decoded static OCaml strings, commands and elapsed times;
`native-disassembly.txt` retains the output. `elf_reader.py` only reads ELF
symbol/code/data bytes. `inspect_native.py` records disassembly without
executing gnatwhy3 and reuses already retained identical function results.

Exploration first tried `nm`, which was absent (`command not found`); the
alternative was the small ELF reader. One narrow exploratory Config-entry
objdump invocation took 0.052352132 seconds. The subsequent persisted extraction
recorded nine functions, then three additional functions needed for dirname
correspondence and fixed closure accounting. Its 12 calls took 1.932760 seconds
in total; it did not repeat the first nine when expanded. Thus 13 target-free
disassembler invocations occurred in this author task, with zero target
executions. The Config entry appears in both exploratory and persisted output
because the initial discovery was then attached to a reproducible exact
code/data/consumer witness. No expensive validation or successful checker
was repeated. `attempts.json` preserves this accounting.

The full staged whitespace check flags objdump's trailing spaces on wrapped
instruction-byte lines in `native-disassembly.txt`. Those raw bytes and their
identities are deliberately preserved. Authored files pass whitespace checks
with that single raw artifact excluded; this cosmetic finding requires no
change to the checked native/code/source inputs or replay of the check.

Selected author: GPT-6 Astra / Extra High. Runtime setting confirmation and
token/cost telemetry are unavailable. Preparation began 19:22:02 UTC; elapsed
check and extraction times above are observed tool evidence, not comparative
model-efficiency measurements. No compiler, solver, proof, capture, fetch,
GitHub, shared-record, harness-state or CLI-memory write occurred.
