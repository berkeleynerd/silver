# Installed solver identities and the retained launch gap

2026-10-20 UTC, native Linux x86_64, #119 / #153; inventory base
`3042c7431f3f82a4ddde9fd9df56e5729ff7258e`.

**The packaged solver files are now identified exactly; their execution by the
retained server remains unattached.** CVC5 embeds the retained candidate source
revision. Z3 and Alt-Ergo have matching embedded versions, without an identified
embedded revision. These observations do not establish build recipes or binary
refinement of those source trees, and supply no solver-output bound O.

The [static inventory packet](../evidence/retained-solver-identity-20261020/README.md)
retains identities, ELF metadata, embedded-string byte offsets, package manifests,
the complete selected driver/import graphs and exact five-case launch joins.
Its checker reads existing archives and, when explicitly requested, installed
files. It never executes a solver or a proof task. Frozen predecessor packets
are unchanged.

## Exact installed files

`scripts/dev.py paths` on the actual host identifies `.tools/linux-x86_64`.
The package root is
`/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef`.
Each file below is a regular mode-0755 native ELF executable at
`<package-root>/libexec/spark/bin/<name>`, with no symlink or script wrapper.
Paths and realpaths coincide at collection.

| File | Bytes | SHA-256 | Embedded version evidence |
| --- | ---: | --- | --- |
| `cvc5` | 31,321,528 | `eb2f46a6bc5fb8a3c81b3387fecb0e68ef5ed1a0c0c5908557254ceb8091b232` | `1.3.2` at byte 27,332,808; separate `This is cvc5 version ` prefix |
| `z3` | 34,951,392 | `44c00197fc576e02775a493dad255a20bb41fa5b4c47378a5f9d090cbc1a25c5` | `Z3 4.15.4.0` at bytes 26,383,370 and 26,599,096; installed `z3_version.h` agrees |
| `alt-ergo` | 21,812,216 | `b21825912f28802662caee0005e4ea761a5087ce8c21f4dae510ae21bcc34189` | `Alt-Ergo version 2.6.1` at byte 11,810,568 |

These are static, NUL-terminated embedded strings. No `--version` invocation was
performed. An embedded string identifies what the file says, rather than proving
the implementation's behavior.

All three files are 64-bit little-endian x86_64 ELF. CVC5 is ET_EXEC with no
PT_INTERP or dynamic section. Its GNU build ID is
`5b19738ea894241e5e3230fde78655c985c8d29d`. Z3 and Alt-Ergo are ET_DYN with
`/lib64/ld-linux-x86-64.so.2` interpreters and no RPATH/RUNPATH. Their build IDs
are `034a16b1c1938d0524a24388588a70fd71a9fed3` and
`33f2ccfec63a2daca2171a282e44532e4d7fc068` respectively. Z3 requests
`libstdc++.so.6`, `libm.so.6`, `libgcc_s.so.1`, `libc.so.6` and
`ld-linux-x86-64.so.2`; Alt-Ergo requests `libgmp.so.10`, `libm.so.6` and
`libc.so.6`. This packet inventories those names without claiming identities
for the resolved loader/shared-library bytes.

## Source and recipe confidence

The retained source candidates in
[the response identity record](../evidence/retained-producer-response-20261018/identity.json)
remain:

| Solver | Candidate repository/revision | Installed-file relation |
| --- | --- | --- |
| CVC5 | `cvc5/cvc5` / `86cecd83b685f59e884094693b9a4c5c90a62e03` | The exact revision is a NUL-terminated string at byte 27,233,392; version agrees. |
| Z3 | `Z3Prover/z3` / `745087e237e669d709ae35694728a0c479e572b3` | Embedded version and installed version header agree with 4.15.4; exact revision is unattached. |
| Alt-Ergo | `OCamlPro/alt-ergo` / `80cf48b3b878b416dea7500a060132c024bf69c4` | Embedded version agrees with 2.6.1; exact revision is unattached. |

A bounded scan of each complete binary for ASCII lowercase 40-hex tokens finds
only CVC5's displayed token; it finds none in Z3 or Alt-Ergo. This is a literal
scan result, not a claim that revision metadata could not use another encoding.
CVC5's token strengthens build-identification consistency without excluding
local patches, a dirty source tree, modified dependencies or build options.
The packet verifies every retained candidate-source member against its prior
identity entry; it fetches no new source.

The installed `alire.toml` and `alire/alire.toml.upstream` are byte-identical and
declare the binary origin
[gnatprove-x86_64-linux-16.1.0-1.tar.gz](https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnatprove-16.1.0-1/gnatprove-x86_64-linux-16.1.0-1.tar.gz),
with declared SHA-256
`82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191`.
This records local package metadata; the tarball was not fetched or independently
rehash-checked here. Those manifests do not specify the solver revisions, patch
sets or build recipes. No source-to-binary attestation is supplied for any solver.
The manifests prepend `<package-root>/bin` to PATH; this alone does not identify
the later server's resolution of files in `libexec/spark/bin`.

## Commands and selected drivers

The current installed `share/spark/config/gnatprove.conf` is retained verbatim.
Its selected records produce these ordinary, non-step command templates:

```text
cvc5 --prenex-quant=none --stats-internal %f
z3 -smt2 -st smt.arith.solver=6 %f
alt-ergo --max-split 5 --disable-weaks %f
```

For all three, `args_time=[]`; the positive-step variants insert respectively
`--rlimit=%S`, `rlimit=%S` and `--steps-bound %S`. The selected `--steps 0`
leaves the positive-step option unset (`gnat_config.ml:125–126,630–641`), so these
variants do not apply. Selected ordinary timeout and memory limits are zero.
The configured version fields are `0.0.7-gnatprove`, `4.5.1-gnatprove` and
`1.30-gnatprove`. They are prover-record identities and must not be substituted
for installed binary versions.

The [driver inventory](../evidence/retained-solver-identity-20261020/drivers.json)
records both complete 14-file recursive import graphs, rooted at
`cvc5_gnatprove.drv`, `z3_gnatprove.drv` and `alt_ergo_gnatprove_smt2.drv`.
The corrected private configuration has four private files: those three roots
and `silver_cvc5_no_steps.gen`. Its other ten imported files retain installed
bytes. The checker verifies exactly six removed `steps` directives and the
single renamed CVC5 import; all other driver bytes remain the same. Solver
commands, including their statistics flags, remain the same. Omitting Why3 step
parsing does not suppress solver statistics output.

The old proposed private `cvc5.gen` conflicted with the installed same-named
import. The [corrected prefix record](retained-producer-prefix-per-check.md)
retains that failure and the later successful private-driver opens. Top-level
driver search first accepts an existing path in the working directory, then
tries beside the extra config, then the config-relative candidate, then the
installed driver directory (`gnat_util.ml:61–108`). Import resolution checks
both the importing and installed directories and requires exactly one existing
match (`driver_lexer.mll:126–133`, `sysutil.ml:261–270`). A fixed config identity
therefore includes directory contents and unique import resolution as well as
file hashes.

## Retained launch and available resolution mechanisms

The [launch record](../evidence/retained-solver-identity-20261020/launch.json)
joins the raw captured process/server JSON to `capture-common.tar.gz` plans and
the prior server attachment. The client PIDs are 17310/17514/17631/17704/17869
for Put_Line/Put/First_Or_Default/Is_Message/Input_Is_Valid. Each argv selects
`--prover cvc5,z3,altergo --proof per_check --steps 0 --timeout 0
--counterexample off --why3-conf <private-overlay>/why3.conf --socket <socket>`
with its exact entity and input filename. Each client environment is exactly
`PATH=/usr/bin:/bin`, `LC_ALL=C`, its captured private TMPDIR, and
`OCAMLRUNPARAM=s=256M,h=16M,M=1000`. The client has no `-j` and no `--memlimit`;
the relative working-directory `why3.conf` has `memlimit=0` and the same commands.
That base file, rather than an assumed installed-base read, is joined explicitly.

Each separate server is launched with absolute `why3server` path followed by
`--socket server.sock --single-client -j 1`, with exactly
`PATH=/usr/bin:/bin`, `LC_ALL=C`. Captured `/proc` argv/environment agree with
the plans. Server identity is 96,904 bytes / SHA-256
`143e182d167d3e290c974770d0b84b5f59cf70bf331de5208a36bd650b386a80`.
The retained observers stop before solver submission. The server later calls
`execvp(cmd,unix_argv)` (`server-unix.c:393–398`), so those bare solver names use
the server's PATH. No retained result identifies which executable that later
lookup would select. This is not a claim that `/usr/bin` or `/bin` historically
lacked a solver.

The supported surfaces need to be distinguished:

- `--why3-conf` selects extra config and influences driver lookup. gnatwhy3
  rejects extra-config records redefining built-in provers
  (`gnat_config.ml:283–290,350–379`). The selected extra config contains only
  `[main]` / `magic=14`. It cannot be treated as an available built-in executable
  override. The retained gnatwhy3 option table has no direct solver-path flag.
- The base `why3.conf` contains command strings. Whyconf reads their bytes and
  `get_complete_command` appends `extra_options`; command expansion preserves
  the executable token. An absolute executable token is representable on this
  path. This inventory has not established a production GNATprove control that
  generates and preserves such a changed built-in base command. Generic Why3
  extra-config/modifier APIs do not establish that gnatwhy3 permits this override.
- A launcher can supply a fixed server PATH beginning with the identified
  `<package-root>/libexec/spark/bin`, followed by `/usr/bin:/bin`, while preserving
  these bare-name templates. This is an available `execvp` resolution mechanism,
  recorded as an unadopted option. No launcher/configuration change or confirmation
  run is made here. The resulting executable selection, stable file identity
  and applicable dynamic-library relation still need attachment at adoption.

`altergo` is the selected shortcut/name; the executable is `alt-ergo`.
gnatwhy3 also normalizes selected `alt-ergo` to `altergo`
(`gnat_config.ml:298–300`). Its client option is singular `--counterexample`;
the intended outer GNATprove option is plural `--counterexamples=off`.

The owner-intended #88 confirmation selects
`--prover=cvc5,z3,altergo --timeout=0 --memlimit=0 --steps=0
--counterexamples=off -j max(3, available CPUs)`, with fresh Per_Check/private
no-step-parser session isolation and possible interruption of losing attempts.
The retained client default is parallel=1 and the server uses `-j 1`; the
five prefixes do not close this intended concurrency/cancellation configuration.
This inventory chooses no new path-resolution design.

## Verification and remaining scope

The packet checker verifies all 15 retained repository inputs, 61 selected archive
members, package snapshots, source excerpts, source-candidate joins, both driver
graphs, all five launch joins and local document links. Its explicit installed
mode additionally rehashes the three binaries, reparses ELF metadata, checks
embedded string offsets and compares the 14 installed driver files. This is
current static-file evidence; it does not reconstruct historical execution.

Selected worker settings are GPT-6.1 Sol / Extra High; runtime model/effort
confirmation and token/cost telemetry are unavailable. The
[round record](../evidence/retained-solver-identity-20261020/round.json) records
measured collection/check times and review status. No target, compiler, solver,
source fetch, installation, config mutation, Oracle change, tool/source pin
change or admission change occurs. #119 / #153 remain incomplete; production
#88–#94 remain unstarted and draft PR #121 remains unmerged.
