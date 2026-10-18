# Independent review of the Per_Check prefix join

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
Initial target: `aa5d8a24a6445a8272120526e3725b1bfc88066f`, integrated as
`94a60ed280c39a0b05e435006dc2352cc68f25aa`. Reviewed correction:
`5e5970478d` (local cherry-pick `8099865cae`). Selected reviewer: GPT-6 Astra,
Extra High; runtime model/effort confirmation is unavailable. Measured review
interval: 18:08:17–18:10:41 UTC (144 seconds), excluding report authoring and
commit. Token use and cost are unavailable.

**Accepted after one configuration-description correction; no unresolved
material finding.** This review covers the delta from the previously accepted
progressive prefix at `74b788520a`, the new capture/replay packet, the exact-input
join to task/response bounds, and the changed historical overlay wording in
`retained-producer-tail.md`. It reuses the original inspected operation partition
and its explicit source/runtime contracts. Acceptance ends before the body of
`Gnat_checks.init`; it does not certify the solver tail or whole pipeline.

The initial document called the local `why3.conf` unused and said the installed
base configuration was read. This contradicted both `gnat_util.ml:46`, which
sets `gnatprove_why3conf_file = "why3.conf"`, and the first actual-open event in
every case, which resolves to that case's working-directory file. The reviewer
reported this before acceptance. Correction `5e5970478d` now identifies the
local base file and its merge with the explicitly supplied private extra config.
The existing evidence already pins and joins both files, so the correction
changes no allocation result, driver identity or replay input. The successful
replay was retained without an identical rerun.

The focused checks support the remaining joins:

- `gnat_checks.ml:284–322` constructs the Per_Check strategy and successor
  table without applying a transformation. The new configuration requires a
  new allocation/count observation; the packet correctly makes no domination
  inference from the progressive result.
- `driver_lexer.mll:126–133` and `sysutil.ml:261–270` require exactly one
  existing import candidate. The retained `gc6` error names both `cvc5.gen`
  paths and never reaches the endpoint. The `gc6` to `gc7` overlay delta is
  exactly the private file rename and its single parent import replacement.
  All other overlay bytes match, preserving the earlier six directive deletions.
- Top-level driver resolution is separately governed by
  `gnat_util.ml:61–108`. The pinned local base config maps the selected
  cvc5/z3/altergo identities to the private top-level drivers. The runner checks
  fresh working directories and the 14-file import graph before and after the
  run. Other configured drivers can still load, as `controller_itp.ml:114–122`
  requires; their step parsers do not populate the selected driver records.
- The retained `caml_sys_open` disassembly supports the observer at offset 208:
  `rbp` holds the pathname copy, `eax` the returned descriptor, and `ebx` the
  original flags before the next instruction overwrites it. The observer checks
  instruction bytes, reads resolved file identities, and makes no inferior
  function call or data write. Each successful case records 81 successful
  protected read opens covering 51 distinct pinned paths, including all private
  files and the complete selected driver closure.
- The probe delta preserves the prior collection and arithmetic observers and
  adds only the file-open observations/completion checks. All five captures
  retain the same 13 protected guards, no guard/new-thread event, the same
  endpoint and the controlled runtime settings. Independent snapshot subtraction
  reproduces every allocation total. The resulting maximum is
  `W=86,627,697`; adding the maximum startup overcount 43,192 and static-image
  overcount 2,152,771 gives `B=88,823,660`. The 146,259 semantic operations and
  maximum 47 are recomputed from the new operand streams.
- All five complete native JSON identities join directly to the fixed task
  records. The unchanged selected transformation names preserve the response
  schema's configuration premise. The sums `G=2,981`, `R=51`, `N<=8,943` and
  raw-response constant 38,739,343 reconcile with the existing conditional
  response/diagnostic formulas. Fresh sessions, all-proved results and the
  environmental timing premise remain explicit conditions.

Independent offline validation ran `check.py` with output directed to
`/tmp/silver-prefix-per-check-review-20261018.json`. Its six top-level dependency
checker invocations passed, and the result was byte-identical to retained
`result.json`. Review also read the archived runner/probe, launch plans,
open/disassembly records, failure log and successful summaries. Retained native
evidence is Linux x86_64: `gc6` failed in 2.562282516 managed seconds; `gc7`
completed five prefixes in 30.690766144 managed seconds, including
28.32482163800023 debugger seconds. Those are author capture measurements.
This review launched no native producer, debugger, solver or broad suite.

The corrected import changes filenames/source locations and initialization
allocations, which the new capture accounts for. It does not bound solver
output bytes, transformed formulas, later lifetime allocations or final `.spark`
representations. The absent selected step regexps mean unavailable statistics
(`-1`, normalized to `1`), not one measured solver step. Production adoption
and whole-pipeline capacity remain false.
