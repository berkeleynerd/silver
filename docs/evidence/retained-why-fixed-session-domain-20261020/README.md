# Four fixed-session captures and five retained binder charges

2026-10-20, resumed #119 / #153, authorized by PR #152. See the
[bounded research note](../../research/retained-why-fixed-session-domain.md).
This packet packages **four already successful native captures** and their four
already successful offline analyses. It separately reuses Input_Is_Valid's prior
PID 97103 evidence; no fifth new capture or new replay is claimed.

| Process | PID | Captured phase | B_binders | Forest visits | Distinct formulas |
| --- | ---: | --- | ---: | ---: | ---: |
| Silver_IO.Put_Line | 3085 | Pre-scheduling registration | 41,946 | 65 | 308 |
| Silver_IO.Put | 3323 | Pre-scheduling registration | 33,252 | 54 | 297 |
| Silver_Arguments.First_Or_Default | 3470 | Pre-scheduling registration | 10,195 | 33 | 108 |
| Silver_Arguments.Is_Message | 3568 | Pre-scheduling registration | 744 | 4 | 57 |
| Silver_Arguments.Input_Is_Valid | 97103 | Prior first-inline entry | 966 | 5 | 66 |

The new endpoint is `camlGnat_checks__iter_2373`. Input_Is_Valid is reused from
[retained-why-session-save-state-20261019](../retained-why-session-save-state-20261019/README.md),
stopped at its first Input_Is_Valid/cvc5 inline entry. These phases are distinct;
the B=966 charge is not applied to the other four processes. Input_Is_Valid is
reused within its accepted logical-forest preservation scope; this does not
assert identical registration-state addresses, counters or auxiliary domains.
Further later-entry source-domain and whole-process joins remain separate.

## Capture provenance and retained files

Managed run `20261020T071442-a3e5fa7cb995` completed in **247.745976497 s**,
using one worker and four serial cases. The four debugger intervals were
88.567598439, 82.554981004, 42.923317718 and 31.048642379 seconds, respectively.
Each summary records completion, no failures/guard hits and zero hits at the
named scheduling, driver-preparation and prover-request sites. The capture
runner checks its **201 input identities both before and after** execution and
rechecks driver-import resolution. The saved success and runner establish that
historical check; packaging does not rehash all 201 installed files today.

The inherited runner prints **“All five registration segments completed”** and
its docstring also says five. These original bytes are preserved. The actual
plan/results enumerate four new processes; Input_Is_Valid is the separately
reused fifth retained process.

- `capture-common.tar.gz` retains plan, original run/probe/observer scripts,
  driver-resolution inputs, overlay drivers/configuration, preparation script,
  aggregate result and `managed/events.jsonl` / `managed/native.log`.
- `capture-{put-line,put,first-or-default,is-message}.tar.gz` retain each input,
  debugger script/log, exact process/environment, raw memory reads, projections,
  counters, Hsdecl/representative/auxiliary data and capture/server results.
- [capture-manifest.json](capture-manifest.json) records every archive and member
  byte count/SHA-256, plus original capture results. All five archives are below
  **100,000,000 bytes**; the largest is 21,357,322 bytes. Their 136 regular-file
  members expand to 610,836,367 bytes in total.
- The four `*-analysis.json` files are original successful analyzer outputs,
  including full per-task/formula/visit certificates. [summary.json](summary.json)
  collects all five process-specific charges and phase/provenance distinctions.
- [analyze-original.py](analyze-original.py) preserves the exact analyzer used
  for those four outputs. [analyze.py](analyze.py) changes only how two identity
  keys are looked up after relocation: original `case['cwd']` identifies the
  input key, and its recorded parent identifies `session_observer.py`. Actual
  bytes are read from the chosen extraction root. Replay/counting code is
  unchanged. The selected two-file identity test passes in a fresh temporary
  layout; the four successful analyses were **not rerun** for this lookup fix.
- [package-capture.py](package-capture.py) preserves the already executed
  archival script, including historical local paths. It was not reexecuted here.
  [provenance.json](provenance.json) records original/retained script, analysis
  and dependency hashes; [round.json](round.json) separates the old native and
  offline costs from this packaging work.

## Verification and portable offline use

The smallest fresh check streams hashes without extracting full captures:

```sh
python3 -B docs/evidence/retained-why-fixed-session-domain-20261020/verify.py
```

[verification.json](verification.json) records the successful check in
1.579881406 s: all five archive hashes and all 136 member hashes match, native
result/plan/process/guard facts agree, and one relocated input/observer identity
lookup succeeds. Reads use at most 1 MiB chunks; selected metadata is capped at
4 MiB per member and 16 MiB total. These are checker buffers, not tool or
admission bounds. Verification executes no native capture, analyzer replay or
binder computation. [summarize.py](summarize.py) only checks/collects saved
certificate fields and dependency identities; its summary took 0.078520510 s.

To extract for an intentional offline replay, use a **new** directory. The
checker writes only the manifest's exact, hash-checked regular-file members;
absolute/parent paths and links are rejected, and existing destinations are
not overwritten. Do not broadly extract arbitrary tar members.

```sh
python3 -B docs/evidence/retained-why-fixed-session-domain-20261020/verify.py \
  --extract /path/to/new/fixed-session-capture
python3 -B docs/evidence/retained-why-fixed-session-domain-20261020/analyze.py \
  --capture /path/to/new/fixed-session-capture/put_line/capture \
  --scratch /path/to/owned/offline-scratch \
  --output /path/to/owned/put-line-replayed.json
```

The second command deliberately repeats only the selected offline analysis;
it is supplied as a reproduction instruction and was not run in packaging.
Replace `put_line` with `put`, `first_or_default` or `is_message` for the other
retained cases. Historical native `run.py`/`probe.gdb` paths are provenance,
not instructions to launch another native capture.

## Limits

Original analyses exactly replay the typed session roots/forest/helpers and
reproduce 11 projection files per process, then count saved formulas with the
existing binder interpreter and explicit-alpha cross-check. Their sequential
read counts are 771,608 / 641,314 / 226,338 / 40,058. The analyzer checks the
transition to the next observer; it does **not** replay the remaining private
counter, Hsdecl, representative or auxiliary reads. Those bytes remain retained.

These are conditional, instance-specific binder charges under the existing
source/runtime/cache premises. The packet does not establish full ordinary
ending or all-pair preparation capacity, a deterministic input graph for every
future run, cross-process B transfer, complete R, or a whole-pipeline bound.
The listed B charges are per save, with forest visits recording that saved
forest's traversal count; they are not whole-process registration endpoints.
Separate scheduler/preservation/ordinary-ending source work is not incorporated
by this packet. #153 remains incomplete. Oracle, installed tools and current
admission are unchanged.
Selected packaging worker: GPT-6.1 Sol / Extra High, runtime confirmation and
token/monetary measurements unavailable. No capture, solver request, proof or
successful binder analysis was repeated by packaging.
