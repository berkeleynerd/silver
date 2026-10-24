# Prospective fixed-report configuration

2026-10-24, owner-authorized #212 under #119. Author base
`bc889215882ea5e3725e593fd092d058504746b5`; accepted path review
`30ccdb6607f5c5f6d4a71bf6a07d40d2f943591e`. This is a constructive design
interface for #88/#89, **not a production launcher or an executed GNATprove
configuration**. The existing path, Arguments, IO and specification packets
are unchanged. Historical environment reconstruction is unnecessary for this
prospective design.

The recipe has an exact initial environment, preserves the existing Image
overlay and adapter route, explicitly selects the same bundled runtime, and
uses a fresh physical `/tmp/program-<six ASCII alphanumeric characters>`
workspace W with private T=`W/tmp`. Its source-derived common report path
bound is **P=188 UTF-8 bytes**. The new serialized command has **19 entries**,
435–444 joined bytes and 609–618 configuration-file bytes across represented
worker widths. The #194 reader guards pass. Worker availability and reservation
remain physical-resource obligations; this arithmetic reserves no workers.

`recipe.py` specifies the pure byte-level interface. `check.py` checked the
changed inputs and created/removed one fixture. `result.json` retains its
actual names and observations. The fixture is not a captured GPR execution:
its mapping, naming and pathfiles were prepared directly from the source
contract. `actual_complete_common_path_bytes` remains **null** and effective
native child inputs were not observed.

## Initial configuration and discovery

Let V be the already-selected vendor installation:

```
/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef
```

Let I be the existing Image overlay:

```
/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/image-tools
```

Launch `I/bin/gnatprove` directly with cwd W, an explicit argument vector and
an environment constructed from empty containing **only**:

| Name | Value |
| --- | --- |
| `PATH` | `I/bin:/usr/bin:/bin` |
| `LC_ALL` | `C` |
| `TMPDIR` | `W/tmp` |

In particular there is no inherited `GNSA_ROOT`, `ADA_INCLUDE_PATH`,
`ADA_OBJECTS_PATH`, `ADA_PRJ_INCLUDE_FILE`, `ADA_PRJ_OBJECTS_FILE`,
`GCC_EXEC_PREFIX`, `GCC_ROOT`, `GNAT_ROOT`, `GPR_CONFIG`, `GPR_PROJECT_PATH`,
`GPR_PROJECT_PATH_FILE`, `ADA_PROJECT_PATH`, `GPR_RUNTIME_PATH`, `WHY3*`,
`TEMP`, `TMP`, `PWD`, `HOME`, dynamic-loader override or Alire environment.
This is an exact three-entry environment, not an incomplete deny-list. No
inherited shell startup, shell parsing or Alire subprocess is part of the
prospective exec transition. Source/configuration files in W and the
installation are required to remain stable through consumption.

The exact future argv is exported by `configuration(W, workers)` and retained
at both worker-width endpoints in `result.json`. It preserves the accepted
18-entry #88 design (report-all, mode-all, brief output, checks-as-errors,
zero steps/timeout/memlimit, counterexamples off, explicit workers and the
forwarded `-Wno-free-nonheap-object`) and inserts before `-cargs`:

```
--RTS=V/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0
```

`gnatprove.adb:736–744` serializes `Simple_Name(Command_Name)`, so the absolute
exec pathname becomes `gnatprove` in `cmdline`; the longer absolute exec
pathname remains a separate process operand. The six-field configuration
schema and single object directory are preserved. All bytes in these selected
path/argument spellings are ASCII; the helpers nevertheless count UTF-8 bytes.

`scripts/bootstrap.py:270–375` deliberately **copies** GNATprove into I and
links other vendor paths, except `I/libexec/spark/bin/gnatwhy3`, which links to
the compiled Silver Image adapter. The new observation verifies:

* `I/bin/gnatprove` is ordinary, physical and byte-equal to the accepted vendor
  ELF, SHA256 `544e6da2eedc24ce87d9200d44f61e8e789726466e81e68bf8935489d7f5323e`.
* GPRbuild, GPRconfig, GCC, gnat2why, spark_report and gnatls discovered in
  `I/libexec/spark/bin` resolve to the same selected vendor installation.
  Accepted producer/reporter/GCC/gnat1 identities are checked, not replaced.
  Separate metadata checks bind cvc5, z3, alt-ergo and why3server discovery
  to their existing vendor symlinks; they are not executed or repinned.
* `gnatwhy3` resolves to
  `/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/compiler/bin/silver_image_adapter`.
  The generated `silver_image_config.ads` still names the original vendor
  gnatwhy3 and contains its actual hash. Observing this routing does not
  establish a new source/binary correspondence or implement a private protocol.

GNATCOLL `gnatcoll-utils.adb:404–513` obtains and link-normalizes the executable
pathname, then strips its `bin` directory. Its system-query and argv fallback
routes both preserve this ordinary copied ELF's I prefix under the existing
native-service premise. `configuration.ads:259–297` derives support paths from
that prefix and selects GNSA during elaboration. Hence absence of `GNSA_ROOT`
must hold **before** entry, not merely after `Set_Environment`.

`gnatprove.adb:882–934` then prepends `I/libexec/spark/bin` twice to PATH, sets
`GPR_TOOL=gnatprove` and sets
`GPR_PROJECT_PATH=:I/lib/gnat:I/share/gpr`. The leading empty component refers
to controlled cwd W. The selected project has no imported/extended projects;
W initially contains only its seven sources, exact project and controlled
ordinary directories. This generated environment is exported separately from
the initial one. Later socket/semaphore variables and private Why-service
operands retain their own owner domains; they are not guessed from report P.

## Explicit runtime and the changed GPR descriptor

The explicit runtime root R is the same already-selected 162-byte physical
root under V. Its `adainclude` root is 173 bytes. The new metadata observation
establishes physical equality of R and its `adainclude`/`adalib` directories,
and **absence including dangling symlinks** of both `R/ada_source_path` and
`R/ada_object_path`. The successful previous complete 1,575-file runtime
inventory and its `Source_Reference` exclusion are reused at their accepted
manifest `76a5413f5083da098347755f795a1d1d84804c9984ffc97da8199b0c3e77014c`;
the checker does not rescan that successful corpus. The unchanged source
identity/stability premise still applies.

The source route is explicit:

1. `configuration.adb:1715–1716` supplies RTS to GPR2's tree options;
   `gnatprove.adb:271–274` forwards it to **all three** GPRbuild phases.
2. `gpr-conf.adb:1519–1606` normalizes an absolute runtime directly and checks
   its runtime directory/pathfile branches; `GPR_RUNTIME_PATH` search is not
   selected. The checked directories and absent files select the directory
   branches here. `gpr-conf.adb:1418–1420` supplies that runtime argument
   to gprconfig. `gpr-knowledge.adb:4638–4645` assigns both Runtime and
   Runtime_Dir from an absolute argument, and `:3968–3973` preserves both in
   the selected compiler. Thus the XML runtime selector is the absolute R,
   not the label `default`. The focused `runtime-selection.py` source check
   attaches that exact argument-to-selector correspondence.
3. The new check compares all 72 retained installed XML/entity/config files
   plus `gnatprove.conf`, parses all 63 base XML files and evaluates the changed
   runtime argument. The selected Ada compiler fragments are the accepted
   `0_default.xml[0]`, `gnat.xml[0,8,11]`, plus **`gnat.xml[13]`**. This last
   nondefault-runtime fragment appends exactly `--RTS=${RUNTIME_DIR(ada)}`
   to compiler leading switches and binder required switches. It leaves
   naming, mapping and include-path configuration unchanged. Both selected
   target spellings agree. No config/prover executable was run to obtain this.
4. GCC `switch-c.adb:204–283` sets `No_Stdinc`/`RTS_Switch`, resolves R and
   calls `Get_RTS_Search_Dir` for sources and objects. `osint.adb:1542–1685`
   **still checks R's pathfiles first** even for an absolute R. Their checked
   absence selects `R/adainclude` and `R/adalib`. `osint.adb:509–568` then
   bypasses the ordinary default-runtime search branch. Explicit `-gnateO`,
   GPR-generated ADA_PRJ files and any explicit include/object switches are
   earlier inputs at `osint.adb:460–505`; they must satisfy the next section.

The extra switch has 168 bytes. `lib.adb:1173–1192` stores at most one additional
switch-table entry and one String payload, rewriting driver `-fRTS` to `--RTS`
in place. That routine creates no Atree node. **Its other native storage is
not free**: table growth, pointer/String storage, search-directory strings,
GPR configuration and child argv must be composed by their existing owners.
For the accepted indexed-null descriptor after the forwarded warning switch,
the phase 1/translation argv counts become 18 and data-representation becomes 20
(excluding executable). Phase 1 has 11 stored A rows with payload 245; translation would have 10
rows with payload 238 if its output were enabled (it remains disabled). The
null ALI envelope gains 171 bytes and one line: **29,622,975 bytes**, 77,552
lines; the existing 789-byte maximum record still dominates the 171-byte row.
These null-descriptor deltas do not replace fixed-library or general Main
storage composition. Same-runtime selection preserves the source corpus;
it does not assert that the old entire native allocation trace is unchanged.

## Effective child, source and filesystem predicates

The following is the exact **refine-and-check contract**, to be realized by
source proof of the future launcher/GPR route or checked before each affected
native consumption. A failure requests configuration refinement or reports an
actual infrastructure failure; it does not reject an otherwise valid Silver
program, weaken an obligation or impose a cap on its original user filename.

| Input | Required relation |
| --- | --- |
| W and initial cwd | Atomically create fresh `/tmp/program-<six ASCII alphanumeric>` with mode 0700 under physical `/tmp`; W must be physical and cwd must equal W. Initial content is the exact existing Output_Mode `program.gpr`, authoritative unchanged `main.adb`, six unchanged fixed Silver files and controlled ordinary directories. |
| Source closure | Current admitted Main and the six fixed Silver sources, plus the accepted same-runtime corpus. No additional import/extension, source filename override, preprocessing, hidden source replacement or Source_Reference origin is selected. `-gnatA` retains exclusion of implicit `gnat.adc`. |
| Mapping | When GPR supplies a mapping, exactly the seven triples `(lowercase unit%s or unit%b, fixed basename, W/basename)`, one per source, in arbitrary GPR iteration order. Main is `main%b/main.adb/W/main.adb` and keeps its explicit index 1 naming. No suppressed `/` path, foreign target or unexamined extra map is allowed. `check_mapping` checks content and multiplicity. |
| Naming/config pragmas | Exactly the accepted 327-byte three-pragma `Source_File_Name_Project` naming projection, with `.ads/.adb`, lowercase, `-` and Main index 1. No Source_Reference pragma. Its path is a physically bound GPR temporary name. |
| Effective source search | Every source directory introduced by child `-I`/include switches, ADA_INCLUDE_PATH or ADA_PRJ_INCLUDE_FILE belongs to `{W, R/adainclude}` (optional trailing slash). Generated project search is W and the explicit runtime appends R/adainclude. A pathfile is LF terminated; every entry is checked by `pathfile_entries`. Inherited values are absent. |
| Effective object search | Every directory introduced by object switches, ADA_OBJECTS_PATH, ADA_PRJ_OBJECTS_FILE or `-gnateO` belongs to `{W/obj, O, O/phase1, O/data_representation, R/adalib}`, where `O=W/obj/gnatprove`. File ordering and multiplicity remain the source-generated GPR sequence and must be charged by their storage owner. No cardinality bound is inferred from this pathname predicate. |
| Child pathfile/mapping filenames | Each is a physically unchanged controlled GPR temporary filename, or a specifically source-generated file in the phase directories already bounded by the path hull; no arbitrary inherited file is permitted. Actual filename and complete contents, not just the environment variable's presence, must be bound before consumption. |
| Saved/active cwd | Only W, T, `W/obj`, O, `O/phase1`, `O/data_representation` and GPR's physically controlled temporary child occur at the relevant save/change/restore points. Actual physical equality is required, not lexical shortening of an unbounded symlink target. |
| T and GPR descendants | T starts empty, physical and private. Only the selected implementation creates its ordinary children; no foreign mutation or symlink replacement occurs through the final native read. Generated `T/GPR.<positive int32 PID>/GNAT-TEMP-<six digits>.TMP` must remain physically equal to its spelling after **final filename normalization**, not merely after T normalization. |
| Installation | Copied parent, linked vendor children, linked Image adapter, installed configuration bytes, explicit runtime directories and pathfile absence remain the checked selections through consumption. Source/binary relevant-behavior assumptions are inherited unchanged. |

GPR's source derivation is `gpr-env.adb:785–1005` (mapping triples),
`:464–754` (naming), `:1011–1044` (temporary delegation) and `:1642–1850`
(LF-terminated directory files). `gprbuild-compile.adb:3218–3425` can pass
includes through switches, files or environment according to configuration,
and `:3516–3529` changes to the object directory before preparing includes.
The contract covers the effective route; it does not assume ADA_PRJ variables
stay absent in child processes. GCC `fmap.adb:110–139` consumes the mapping
filenames/paths rather than inventing a new source location.

The existing seven-source, no-import project makes these domains constructive:
its mapping is a finite function exported by `mapping_triples`; its sole
project source directory is W; each phase object directory is the corresponding
source-constructed member above; its runtime source/object directory is the
explicit R selection. The fixture writes these bytes and inhabits the
directory predicates. The future transition still must establish that the
actual native inputs are these source-derived values. Existing source-count
and storage owners must retain any additional GPR/ALI cardinality terms.

`gpr-tempdir.adb:68–177,230–293` selects the first valid absolute TMPDIR/TEMP/TMP,
normalizes T, appends `GPR.<PID>`, creates the fixed-width temporary name and
normalizes that final filename. Here only TMPDIR exists and it is valid.
Fresh controlled descendants establish that normalization cannot lengthen the
path through a pre-existing symlink. A short normalized T alone would be
insufficient. Mode 0700 does not by itself exclude same-owner interference:
the ordinary isolation/stability relation remains explicit.

## Path and configuration joins

| Prospective demand | UTF-8 bytes |
| --- | ---: |
| W / T | 19 / 23 |
| Project argument | 31 |
| O, allowing trailing slash | 34 |
| Largest named phase cwd | 53 |
| GPR final temporary filename | 59 |
| Longest copied fixed source path | 42 |
| Longest absolute fixed flow trace | 76 |
| O + slash + bounded Why JSON basename | 98 |
| Explicit runtime / adalib | 162 / 169 |
| Runtime source root + slash + longest accepted basename | **188** |

The `gnat2why-driver.adb:226,316–345,600–604` basename constructor includes the
extension in its 64-byte bound. The installed config filenames, including
their vendor realpaths, fit below 188. GPR's PID child is below the final
temporary bound; `hull` conservatively retains P=188. Requested, full and
reference source names use the same accepted corpus and copied-name domains.
The original user pathname is not copied into the tool project; it retains
its separate owner/interface.

The unchanged four fixed report byte bounds at P=188 are reused directly from
the accepted path result: 216,990,962 (Libc), 295,151,978 (Runtime), 773,102,165
(IO), 977,010,142 (Arguments). All four writer/reader joins already passed at
this P. This check recomputes only the changed 19-argv configuration shape and
reader guards at worker widths 1 and 10. It does not replay the old report or
runtime-corpus checkers. Native max-path/page operands remain 4096/4096;
Arguments' sufficient endpoint remains 395. No new report cap is an admission
rule.

## #88/#89 handoff and remaining owners

The exact handoff is also machine-readable in `handoff.json`:

* **#89:** realize the fresh physical W/T recipe, byte-identical authoritative
  source/project copying, current mapping/naming and complete effective
  pathfile predicates, physical cwd transitions and final normalized GPR child
  names. Check stable selected installation/runtime paths and runtime pathfile
  absence. Preserve the original user filename's separate interface.
* **#88:** construct the exact empty-derived environment and direct copied
  Image-overlay exec, preserve adapter routing, use the 19-entry command and
  unchanged report-all obligations, and retain the explicit RTS child argument
  and storage deltas. Integrate worker reservation from actual host headroom.
  The accepted private protocol/output route in
  [retained-backend-output-route.md](../../../research/retained-backend-output-route.md)
  still requires its own adapter refinement. Current adapter routing alone
  does not establish it. Likewise zero GNATprove timeout does not supply the
  fresh-session private Why timing/completion premises or transfer their
  reported-duration ceiling to other clocks.
* **#119/native owners:** join RTS switch/search-directory/descriptor storage;
  keep warning/header/source-span/private-fix storage and ordinary Main/full
  five-report collector/SARIF composition separate. Why-client requests,
  canonical directory, adapter/protocol and timing operands keep their existing
  domains. There is no renewed callback or save allowance.

The global e<=2, two save-entering callbacks, three saves and physical-resource
premises are unchanged. This packet completes a prospective design/evidence
step, not #212, #119, universal completion or production refinement.

## Validation and provenance

The selected author setting was GPT-6 Astra / Extra High; runtime model
confirmation and token/cost telemetry are unavailable. `round.json` records
the actual sequence. The first new check stopped at a fixture bookkeeping
assertion expecting 15 lines in the decoded current project; the exact source
literal has 14. Only that expectation changed. The created fixture was removed
by `finally`; no tool/project/source semantics changed. The corrected check
passed in **1.714730 seconds**. A final changed-input check added the missing selected cvc5/z3/alt-ergo/why3server discovery metadata
and installed-config realpath maximum 177; it passed in **1.702746 seconds**,
checking 18 complete source/config files, 42 repository providers,
73 installed configuration files, changed XML
selection, discovery identities, negative path/mapping cases and the fresh
physical fixture. The final fixture `/tmp/program-1a4206` was removed. The
earlier successful fixture `/tmp/program-9cd25c` was also removed. The exact first
failure command and traceback are retained in `first-check-failure.txt`.

One final, separate source-only check resolved the absolute-RTS-to-XML-selector
premise in **0.073653 seconds**, checking the complete retained
`gpr-knowledge.adb` and its archive identity. It ran no fixture or predecessor
checker and is recorded in `runtime-selection.json`; it does not repeat the
successful configuration check.

No compiler, prover, Lean, native target, predecessor checker or service probe
ran. Read-only hashes/metadata and Python filesystem operations are the new
observations. GNATCOLL's complete selected `gnatcoll-utils.adb` was fetched
once at revision `1d4374ae9187fd14d42ca99a3deb0ab2ff1ebc55`; all other tool
sources come from retained pinned archives or the accepted GCC complete-source
manifest. Full files, origins and hashes are in `sources.tar.gz` and
`source-manifest.json`. The established relevant-behavior/source-identity
premise is retained, including the historical SPARK source limitation; this
packet does not claim a new installed source attestation.

## F1 review repair: exact raw directory spellings

The [#215 correction](repair-f1/README.md) narrows `pathfile_entries` to the
documented exact directory or one trailing slash. The original implementation
accepted arbitrary trailing slashes, which native normalization can preserve.
The selected configuration and P=188 coefficients are unchanged. Original
author evidence above remains historical; a separate focused repair check
passed, with independent repair review pending.
