# Report pathname/configuration join, 2026-10-24

This is a partial #212 result under #119. It constructs the common pathname
operand required by the frozen specification, IO and Arguments reports and
#194, without changing those providers. For the installed root spelling and
the configuration relation below, **P=188 bytes** suffices. The four report
writer/reader interfaces and the prospective configuration interface fit at
that P. This is a useful configuration class, **not a complete attachment to
the historical runs or current launcher**, and not an adopted path limit.

The decisive new distinction is that historical fixed-producer records specify
their cwd and some environment overrides, but the frontend runner explicitly
inherits `os.environ`. Its record is not a complete effective environment.
The generated Silver build constants likewise establish lexical installation
paths, not every physical cwd or compiler search-path choice. Therefore this
packet leaves `actual_complete_common_path_bytes` null. It does not turn an
illustrative substitution into an observation, require a new capture, or
declare either issue complete.

Historical environment reconstruction is **not** a prerequisite for the
prospective design. The next obligation is to choose and attach a new,
decidable effective configuration satisfying the predicates below under the
selected sources/tools. This freeze supplies that conditional interface and
its source-derived demands; it does not claim a completed constructive
launcher configuration or ask for irrecoverable historical state.

## Exact inputs and scope

The author branch starts from Arguments `6a29a2b8c241924f842fc1d6afeb2e1617c2d3f8`.
Dependency-only cherry-picks bring in native parent/reporter `9bb63660fd`, its
combined review `d39dc7cff`, and producer configuration `260af764d5`. The accepted
Arguments/native review `b3f6b4591eab2bb8604be528dcbd697c70899b7d` was read from
Git at `docs/reviews/review-arguments-configuration-20261024.md`. No previously
accepted packet was edited or replayed. The four fixed sources' report shape,
CP, obligation and emission domains are inherited unchanged.

`source-manifest.json` binds complete tool files, the frozen provider functions,
the two historical invocation archives, and the accepted whole installed
runtime manifest. `configuration-snapshot.json` records a read of the existing
generated `silver_build.ads`; it is a configuration-source snapshot, not proof
that a running compiler was built from it. The new check reads the entire
selected runtime corpus and compares its aggregate manifest with the accepted
source-closure provider before using any filename or pragma census.

## Path producers and process boundaries

Let W be a fresh program workspace, O its phase-two object directory, C the
actual physical initial/saved cwd, and T the selected normalized GPR temporary
root. These names denote byte strings, not source-size limits.

| Role | Source construction and owner |
| --- | --- |
| Original user filename | Silver's initial file read/diagnostic owner, before the snapshot. It is not forwarded to `program.gpr` or embedded in a Source_Reference directive. Its capacity remains separate. |
| W | `silver_platform.ads:71–73`, `.adb:194–232`: configured root + `/program-` + exactly six alphanumeric bytes on success. The content of the fresh suffix does not affect width. |
| Project and copied sources | `silver.adb:93–120`: W/program.gpr, W/main.adb, six fixed library filenames, `Source_Dirs=(".")`, explicit `Source_Files`, no project import/extension, Object_Dir="obj", one indexed Main. `silver_libraries.adb` reads the installation library directory and writes the same source bytes under those fixed names. |
| Parent initial cwd | `bootstrap.py:156–171` places an explicit `cd <toolchain context>` before Alire. The shell changes directory on the successful branch. The physical pathname returned later by getcwd must still match the supplied configuration root; shell spelling alone is insufficient. |
| O | `configuration.ads:313` and `.adb:1637–1644` select subdir `gnatprove`; GPR2 `Apply_Root_And_Subdirs` (`gpr2-project-view.adb:150–226`) joins project directory, "obj", then that subdir. No --subdirs/build-tree override is selected. Directory values can end in slash; the formula conservatively keeps it. |
| Producer cwd and Why3 saved cwd | GPR `gprbuild-compile.adb:3516–3529` changes to the object's directory before compilation. `gnat2why_opts-writing.adb:171` sets why3_dir from Obj_Dir. `gnat2why-driver.adb:1222–1299` saves the current cwd, composes its input name, changes to Why3_Dir for spawn, then restores the saved cwd. These are producer paths, not evidence of the separate retained Why client's historical cwd. |
| GNAT2Why options | `gnat2why_opts-writing.adb:57–75`: O + slash + eight SHA1 hex bytes + ".tmp". It temporarily changes to O and restores the saved parent cwd. |
| Report config | `gnatprove.adb:680–820`: O/gnatprove.alfad, serialized object directory from the same project view, exact parent argv. `Artifact_Dir` returns that object directory for the selected nonaggregate project. |
| Reporter cwd | The parent's `Call_With_Status` does not change cwd. `spark_report.adb:769–780` saves its initial cwd, enters each supplied object directory, reads the `.spark` basenames, and restores the saved cwd on ordinary and exception paths. The second SARIF pass has the same save/change/restore route at `spark_report-generate_sarif_report.adb:151–162`. |
| Reports, summary, SARIF | `gnat2why-driver.adb:350–357` uses Unit_Name + ".spark". `spark_report.adb:1468–1474,1576–1580` uses dirname(config) + gnatprove.out/gnatprove.sarif. Silver's five read paths use W/obj/gnatprove plus their fixed names. |
| Flow trace | `spark_util.ads:1185–1191` strips to a basename for Unit_Name and appends only the selected multiple-unit index. `flow_error_messages.adb:1013–1018` adds `__flow__`, at most ten decimal counter bytes, and `.trace`. The longest of all five unit stems is silver_output_libc: 42 relative bytes. Absolute form is O + slash + that name. Trace counter safety is inherited, not proved by this width. |
| GPR configuration/naming files | `gpr-tempdir.adb:68–97,103–177,230–293`: selected normalized T/GPR.<PID>/GNAT-TEMP-<six digits>.TMP. Positive signed32 PID gives ten bytes. `s-os_lib.adb:77–85,781–870` retains the fixed-width temporary name even across counter carry. Width is T+36, including both separators. |

`capacity.domain` generates these families, takes their maximum, and separately
reproduces every named #194 dominance demand. The conservative #194 extra slash
is charged even when O already has a trailing slash. It does not run `compose`
with a fabricated Main report. A caller must establish the source/configuration
relation and supply all additional source/config/reference paths before using
the resulting P.

## Source, reference and runtime filename closure

GNAT distinguishes several names. `osint.adb:2020–2062` strips the main source
argument's directory into the primary search directory and stores its basename
as Current_Main. `Locate_File` (`:1874–1923`) joins a requested filename with a
selected search directory, or preserves an absolute name. `Read_Source_File`
(`:2644–2663`) stores that result as Current_Full_Source_Name. `sinput-l.adb:507–530`
initializes File_Name and Reference_Name from the requested N, and full
file/reference/debug names from that selected full name.

SPARK's `File_Name(Source_Ptr)` is exactly the Sinput File_Name lookup
(`spark_util.ads:1190–1192`). It supplies report primary/secondary/VC locations
(`errout_wrapper.adb:82,100,145`) and assumption sloc fields
(`spark_util.adb:1925–1943`). Trace lines use the same source-file lookup
(`flow_error_messages.adb:5011–5028`). Generic/inline virtual copies start by
copying the source record (`sinput-l.adb:143`); they do not concatenate source
filenames. Instantiation depth is a separate storage/count operand.

Native diagnostics can instead use Reference_Name or Full_Ref_Name
(`erroutc.adb:939–948`, `erroutc-pretty_emitter.adb:1362–1371`). Therefore a
basename-only bound is insufficient for the common domain. This packet charges
the full joined source names as well. The only reference-name replacement is
the Source_Reference route (`sinput.adb:802–824`). It is excluded by the current
Silver grammar, absent from all six fixed library sources, and absent from the
**complete** selected 1,575-file installed runtime corpus. The latter matches
the accepted aggregate SHA-256
`76a5413f5083da098347755f795a1d1d84804c9984ffc97da8199b0c3e77014c`.
The selected naming/configuration contents must likewise introduce no foreign
Source_Reference or filename mapping; this is a configuration predicate, not
inferred from the runtime scan. A different selected mapping or reference name
is included explicitly in `additional_source_and_config_paths`.

The exact producer runtime root is 173 bytes. Across that complete corpus the
longest relative name is the 14-byte `standard.ads.h`; charging this non-Ada
header too gives **173+1+14=188**. This overbounds all actual runtime Ada source
filenames without guessing the subset reached by one successful run. The
corpus manifest is not itself a search-path closure theorem: selected source
identity, search-directory and mapping closure remain necessary predicates.

## Normalization and effective configuration predicates

GPR2 `Make_Absolute` (`gpr2-path_name.adb:91–101`) defaults to
Resolve_Links=False. Absolute root joins and dot/separator elimination cannot
lengthen the constructed spelling. In contrast, GPR.Tempdir explicitly calls
Normalize_Pathname with its default link resolution. The native implementation
(`s-os_lib.adb:2041–2480`) may prepend the actual cwd and replace symlink text;
its default true branch is **not** length-nonincreasing. `Configuration` thus
requires distinct lexical and physical workspace roots, initial/saved cwd
values, and lexical/normalized temporary roots. Any other normalized config
filename belongs to its additional family. The accepted native Max_Path=4096
and page-size=4096 are separate normalization/allocation operands; neither
implies an actual path is at most 395 or 188 bytes.

For the future #88/#89 launcher, the concrete attachment obligation is:

1. Preserve the selected generated project, source bytes and the explicit
   prospective argv (including brief/report-all, zero limits, CE off and the
   chosen represented worker integer). No project/config/runtime/subdir or
   source-name/preprocessor override may silently alter the families above.
2. Establish the effective compiler source/object directories and mapping
   files. `osint.adb:460–550` consumes `-gnateO`, `ADA_PRJ_INCLUDE_FILE`,
   `ADA_PRJ_OBJECTS_FILE`, `ADA_INCLUDE_PATH`, `ADA_OBJECTS_PATH`, --RTS and the
   selected default search files. `osint.ads:50–53` gives those exact environment
   names. Bind the contents of selected path files and source mapping/naming
   inputs, or ensure the unselected inputs are absent. It is not enough to
   unset only the current bootstrap's `ALR_CONFIG`, `GPR_CONFIG`,
   `GPR_PROJECT_PATH`, `GPR_PROJECT_PATH_FILE`, `ADA_PROJECT_PATH`.
   GPR may itself supply include switches/path files (`gprbuild-compile.adb:
   3218–3425`); establish the effective child result, rather than assuming that
   every variable must always be absent. This is source selection accounting,
   not an additional deployment/security requirement.
3. Bind GPR's temporary-root selection: first valid absolute directory among
   TMPDIR, TEMP, TMP; otherwise /tmp, /var/tmp, /usr/tmp on Linux, otherwise
   actual cwd. Supply the normalized result and its physical cwd spelling.
   A deterministic launcher choice can provide this relation; this packet
   changes no environment or production behavior.
4. Bind the successful cwd values at the source save/change points above, and
   the normalized roots under the same stable filesystem/service relation.
   No inference from textual `cd` or from a working checkout's pathname is
   sufficient. If a chosen installation does not fit this sufficient region,
   refine the workspace/configuration implementation or the bound; do not
   reject an otherwise valid Silver source or its original filename.

The generated configuration snapshot has root length67 and context length77.
With equal lexical/physical roots, selected runtime root above, temp root /tmp,
no additional reference/config spelling, and the selected source relation,
the generated workspace width is82, project94, object directory97 including
slash, longest absolute trace139 and #194 longest report demand122. Their
maximum with the runtime corpus is **188**, with 207 bytes of room to the
accepted Arguments sufficient endpoint395. These physical/environment
equalities are declared predicates, not historical observations.

## Reuse of R69/R70 and retained invocations

Both fixed-producer invocation families supply explicit cwd, -gnatec/-gnates/
-gnateO/-I/main operands, object-path file contents and why3_dir. Their recorded
operand families plus the selected complete runtime corpus fit188. Their
`why3_args=["/usr/bin/false"]` captures precede result collection: they are
not records of the later prospective launcher or backend protocol. The exact
frontend runner's `env=dict(os.environ);env.update(plan['environment'])` prevents
treating its two recorded variables as an exhaustive environment. Their full
historical physical-cwd and effective-path attachments remain unasserted.

R69's all-FileTags-origin180 and R70's raw-library-probe167 remain valid in
their accepted selected-client domains. R69's retained request bounds775–853
are **not** #194's P and cannot be forced into its395 interval. The separate
callable `why_domains` preserves PrecutP=max(180,|client cwd|+10), P_file=180,
P_stat=167, P_diag=max(F,R+24), canonical path R+24, and frame R+72. Actual
historical client cwd and canonical directory R remain unset. This packet does
not infer the former from a fixed producer's why3_dir or invent the latter.

## Evidence and residuals

The single focused changed-input check verifies the new source/configuration
joins and evaluates the four frozen report functions and #194 configuration
function at the newly derived conditional P. It does not replay successful
author/predecessor checkers. The source argument above, not the finite check,
supplies the path-family closure under its stated configuration relation.

Native warning chains, incoming counters, syntax-header lifetime, source-span
and private failed-fix storage remain separate owners. Full Main/five-report
collector/SARIF composition, actual effective configuration attachment, and
prospective launcher implementation remain open. The one global e<=2, two
save-entering callbacks, three saves, and physical-resource premises are
unchanged. No Oracle, admission, production, tool, pin, goal or GitHub write
was made. Selected author: GPT-6 Astra / Extra High; runtime confirmation and
token/cost telemetry unavailable. Timing and exact check outcome are in
`round.json` and `result.json`; CLI memory was not updated.
