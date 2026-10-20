# Five fresh stopped save-state captures

2026-10-20, active owner-authorized #119 / #153 Round28. This packet retains five
new stopped native Linux x86-64 captures, including the missing save-table,
Buffer and serializer backing observations. It packages completed evidence;
the numeric attachment and comparison packet is separate. No capacity bound,
complete R, language admission or #153 completion is established here.

| Process | Fresh PID | Actual stop | Debugger seconds |
| --- | ---: | --- | ---: |
| Silver_IO.Put_Line | 17310 | Registration, before scheduling | 99.504757509 |
| Silver_IO.Put | 17514 | Registration, before scheduling | 83.601457910 |
| Silver_Arguments.First_Or_Default | 17631 | Registration, before scheduling | 41.727867855 |
| Silver_Arguments.Is_Message | 17704 | Registration, before scheduling | 33.418594920 |
| Silver_Arguments.Input_Is_Valid | 17869 | First cvc5 `inline_trivial` entry | 37.541028053 |

The four registration cases ran serially with one managed worker in
`20261020T091152-10d928ebc9aa` (**260.507296925 s**). The fresh Input_Is_Valid
case ran separately with one worker in `20261020T091635-344f0aadb4bb`
(**39.734988919 s**). Each case records completion, return code 0, no failures,
no protected-interval guard hits and zero hits at its named forbidden calls.
Startup guard observations before `camlWhy3__Exn_printer__entry` are retained;
“no protected-interval guard hits” does not erase those startup observations.
The registration capture stops at `camlGnat_checks__iter_2373`; the inline
capture stops at `camlWhy3__Driver__apply_3383` after the recorded directive
sequence `counterexamples_dependent_intros`, `inline_trivial`, before printing
or a prover request. Captured preparations and registration are distinct phases.

The exact plans retain source revision
`9390baf120ef260547dfa14f08e11c890b203d9c`, runtime candidate
`8eb41f72ded84df884c3671734c947f612091f84`, executable/driver identities,
arguments and environment. The frozen collector is
`f3baf9cdfa068496a4034c16f77e9fbcd756420a`. Native runner success records the
original before/after checks of **202** registration and **206** inline input
identities. Packaging rehashed the **20 / 24 retained local inputs** and binds
them to the plans and archive members; it did not repeat the installed dependency
audit. Managed run events and native logs are retained verbatim.

Two historical discrepancies are preserved and bounded explicitly. The four-case
runner's docstring/stdout says “five”; its plan and aggregate result enumerate
four processes. Its plan also retains the historical statement about reused
PID 97103; this packet's fifth process is the separate fresh PID 17869 capture.
The inline plan's `endpoint` remains inherited registration metadata; the exact
probe's `InlineEntry` observer, `entry_observers.apply`, recorded preparation
sequence and `summary.inline_entry` identify the actual first cvc5 inline stop.
No historical runner or plan bytes were corrected during retention.

## Portable contents

- `capture-common.tar.gz`: exact helper scripts, plans, driver resolution,
  configuration overlays and aggregate results under `registration/` and
  `inline/`; `managed/<run-id>/{events.jsonl,native.log}`; and the seven allowed
  root-preparation/extension-preflight inputs under `preparation/`.
- `capture-{put-line,put,first-or-default,is-message}.tar.gz`: each complete
  regular-file capture tree under `registration/<case>/`.
- `capture-input-is-valid.tar.gz`: the fresh Input_Is_Valid tree under
  `inline/input_is_valid/`.
- [capture-manifest.json](capture-manifest.json): every archive/member byte
  count and SHA-256, exact original roots, run IDs, phase distinctions, process
  results and retained local plan-input identities.
- [package-capture.py](package-capture.py): the executed retention script;
  original roots are defaults, and its CLI can select relocated inputs/output.
  It refuses incomplete managed/case results and existing archives/manifests.
- [provenance.json](provenance.json) and [round.json](round.json): package/code
  identities, scope, selected worker settings and measured costs.

All **six archives** are below 100,000,000 bytes; the largest is **23,663,346
bytes**. Their **253 regular-file members** expand to **775,434,841 bytes**.
The case archives include `capture/save-missing-state.json`,
`capture/save-state-memory-reads.jsonl`, `capture/session-root.json`, per-attempt
address logs, earlier raw reads/projections, exact process/environment and
debugger/server results. Sockets, directories and Python bytecode are excluded.
Comparator/replay outputs in the preparation directory belong to the separate
numeric packet and are excluded. The full older capture roots remain untouched.

## Cheap verification and optional extraction

```sh
python3 -B docs/evidence/retained-why-save-state-capture-20261020/verify.py
```

[verification.json](verification.json) records all archive/member hashes and
saved completion/process/phase/preflight checks passing in **2.031884305 s**.
The checker streams raw data in chunks of at most 1 MiB; selected metadata is
capped at 4 MiB per member and 16 MiB total. These are checker buffer limits.
It performs no observer/session replay, binder/alpha analysis, native capture,
solver request or proof execution.

For offline consumption, choose a new extraction directory:

```sh
python3 -B docs/evidence/retained-why-save-state-capture-20261020/verify.py \
  --extract /path/to/new/save-state-captures
```

The checker first validates the packet, then rechecks archive/member hashes as
it writes only the manifest's exact regular files. It rejects existing roots,
links, absolute/parent paths and duplicate members; it never calls `extractall`
or overwrites an existing destination. [extraction-verification.json](extraction-verification.json)
records successful extraction of the actual packet in **4.734375556 s**, selected
portable members found, eight unsafe-name cases rejected and an existing root
rejected before archive reads. The temporary extraction was then removed.
Historical native runner paths are provenance, not replay instructions.

Selected packaging worker: **GPT-6.1 Sol / Extra High**; runtime confirmation and
token/monetary measurements unavailable. Sealing took **10.655233828 s**. The
packet retains diagnostic observations under the existing source/runtime
premises. Semantic comparison, numeric joins, source-correspondence assurance
and remaining #153 obligations are separate. Oracle, installed tools, source
pins and admitted production source are unchanged.
