# GPR parsed configuration and shared-table baseline

This #212 increment under #119 supplies sufficient source/configuration bounds
for the three producer GPR tables left conditional by the accepted
[prospective native packet](../prospective-native/README.md): Project_Nodes,
String_Elements and Name_Lists. It attaches that packet's additional RTS
demands of 20, seven and seven respectively. Each datarep, phase1 and
translation GPRbuild child has its own bounds; their process-local tables are
not added together. **The complete GPR.Names and producer-process baseline is
still open.** The exact residuals below remain owned by #212.

The accepted author is `4aab5b0e9cc931965c68bf2450473d3b63f7841a`; independent
review `cd21bcc14f7b561cf58a999e435153f734e6e761` is present at this worktree's
base `30ef5c9c05`. Earlier packets remain immutable. This is offline research,
with no Oracle, source admission, production, tool pin or physical-premise
change. Global e <= 2, two save-entering callbacks and three saves are unchanged.
Each object is checked separately; no aggregate RAM or stack gate is introduced.

## Exact inputs and method

[source-manifest.json](source-manifest.json) pins 11 accepted provider files,
26 complete selected members of the pinned GPR archive, the complete source-site
inventory and the pre-existing research-note prefix. The full archive is also
pinned, so excluded callers can be checked in context. The SPARK producer entry
is `spark/src/gnatprove/gnatprove.adb` in the pinned orchestration sources archive.
Line references below are to those exact sources, not installed binaries.

The 541-byte [user project](inputs/program.gpr) is reconstructed from the selected
`src/silver.adb` generated-project branch. Its seven named sources determine
project metadata; their contents do not enter GPR project syntax. The three
configuration inputs come from the accepted orchestration archive. Each has
only its two old runtime-prefix occurrences replaced by the accepted R/ macro
value. Original comments are retained, and the two extra RTS clauses are
excluded so their accepted allocation delta can be attached separately. This
also preserves the existing linker literal's R//adalib spelling. These are
source-derived prospective syntax inputs, not a new native capture.

`capacity.Shape` is a small evidence lexer/shape reader. It accepts these fixed
project/package/attribute/variable/list/concatenation/reference forms and the
single GCC_Prefix case with empty alternatives. It rejects imports, extensions,
aggregates, builtins and unsupported syntax, and checks that each declaration's
right-hand side contains at most one reference. It is not a general GPR parser
or a source admission change. The accepted native-source semantics, manual
control-flow argument and pinned concrete inputs are essential to the bound;
matching source snippets alone does not prove it.

The user project has 92 tokens, eight declarations, two packages, 21 terms,
18 string tokens, 13 list items and no references. The configurations have:

| Phase | Tokens | Declarations | Terms | String tokens | References | Combined L |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| datarep | 736 | 82 | 142 | 157 | 6 | 182 |
| phase1 | 752 | 84 | 144 | 161 | 6 | 186 |
| translation | 762 | 85 | 146 | 163 | 6 | 188 |

Every configuration has five packages. The maximum literal payload is 186
bytes, within the scanner's 10,000-character String_Buffer
(`gpr-err-scanner.adb:53`). The combined literal payload also bounds the
selected expression concatenations and fits the 1,000,000-character Name_Buffer
(`gpr-names.ads:27`). Those are syntax bounds; unrelated path/environment names
are not thereby bounded.

## Traversal and process correspondence

`gnatprove.adb:180–330` supplies an explicit `--target` to Call_Gprbuild and
documents that this avoids an extra Gprconfig invocation. The three selected
GPRbuild invocations each have their own Gprconfig child. GNATprove's own GPR2
project processing is a different process/service boundary and is not counted
as a GPRbuild table traversal.

`gprbuild-main.adb:1790` onward initializes Snames, the tree/environment and GPR;
`:2579` onward invokes Parse_Project_And_Apply_Config once. The explicit -P
selects a real user project, so no implicit-project synthesis is needed.
`gpr-conf.adb:1745–2089` disables Fallback_Try_Again for the explicit target.
There are no imports to make Incomplete_With true, and no implicit target
origin to trigger the target retry. Thus the selected path does not reach
Parse_Again. It performs one user Part.Parse and one user Phase_1, then passes
Do_Phase_1=False to Process_Project_And_Apply_Config. Configuration processing
at `gpr-conf.adb:1669` onward performs one additional Part.Parse and Phase_1
with Reset_Tree=False; `:2514–2516` applies the configuration once and runs
Phase_2.

Apply_Config iterates the two process project records but skips Config_File
(`gpr-conf.adb:430–502`), leaving one user application. There is no aggregate
recursion. Phase_2's naming traversal follows the user project/import graph
(`gpr-proc.adb:2749–2910`, `gpr-nmsc.adb:9302–9540`); here there is one project,
one Ada language and no imports. The configuration project is not separately
processed as another user project by naming.

The complete project-parser entrypoint inventory includes the two selected
GPR.Conf calls, the excluded aggregate branch in GPR.Proc and the excluded
import/extension/virtual-project paths in GPR.Part. Runtime directory discovery
does not parse a runtime GPR project. `gpr-nmsc.adb:2900–3078` selects directory
metadata directly, with the two runtime pathfiles absent under the accepted
recipe, and reads the first system.ali line into a fixed 1,000-character local
buffer for version detection. The generated 327-byte naming .TMP is compiler
input, not another project-parser input. Gprconfig constructs configuration text
from its KB; it does not parse this user project's AST.

This yields, per GPRbuild process: user parse 1, configuration parse 1, user
evaluation 1, configuration evaluation 1, Apply_Config 1 and naming/language
conversion traversal 1. These are source-selected multiplicities, not defaults
silently inserted into a whole-process interface.

## Shared-table bounds

Let T, D, Q and P be the combined user/configuration token, declaration, term
and package counts. Let L be all string-token occurrences, including index
strings, plus reference occurrences, plus one. Because each RHS has at most
one reference, the temporal dependency of each value is a chain. A self-attribute
reference reads its preceding value; it cannot double it as X & X would. Charge
every literal along the chain, and conservatively allow a singleton default per
reference. No builtin split, external list, loop or nonempty conditional body
introduces uncounted elements. Consequently each selected value list has at
most L cells. The pinned user declarations contain no references to the
configuration, so the selected Apply_Config joins do not duplicate a shared
literal origin across the user and configuration values.

There are 34 Default_Project_Node construction sites across GPR.Part (11),
GPR.Dect (10) and GPR.Strt (13). The selected successful parser advances through
tokens monotonically. At any one site, another execution requires advancing to
another token or entering another top-level file. Recursive terms consume their
opening token before descending; list/declaration/choice loops advance at their
separators. The identifier lookahead at `gpr-strt.adb:1599–1605` saves and
restores one scanner state but allocates no syntax node. Nested-file scanner
save/restore has no selected import or extension traversal. Recovery,
synthetic/virtual projects and comment-node construction are excluded; selected
Store_Comments=False is pinned. Charging each of the 34 sites once for every
token plus one end slot per file gives the sufficient bound 34 * (T + 2).
This is a monotone-token charging argument, not an assertion that a constructor
site count by itself bounds executions.

`gpr-proc.adb:207–285` creates Variable_Elements for predefined attributes;
default lists are Nil_String and create no list cells. Selected literal/list
and referenced-list evaluation (`:663–760`, `:1181–1255`) allocates at most L
cells per term, hence Q * L including obsolete/replaced results. Split and
external allocation paths are excluded by the fixed syntax. Apply_Config's
three copying paths (`gpr-conf.adb:200–410`) copy the configuration list and
link to the user tail, while missing/default attributes and arrays use shallow
copies. Each nondefault configuration value originates in a declaration, so
D * L conservatively bounds all such copied cells. It does not count only the
final retained list.

GPR.Initialize always resets its supplied tree, although Attr initialization
and PATH adjustment are once-only (`gpr.adb:1236–1270`). Main initialization and
Parse_Project_And_Apply_Config therefore create two reset Dot_String_List cells
(`gpr.adb:1645–1710`), both retained in the gross event bound. The node table is
initialized once (`gpr-tree.adb:929–934`), and user/configuration ASTs coexist.
Naming adds one source-directory String_Element and Number_List cell
(`gpr-nmsc.adb:6244–6252`). The interface source-list allocator at `:3426` is
excluded: the selected executable project has no Interfaces, Library_Interface
or --src-subdirs. Thus String_Elements <= 2 + Q * L + D * L + 1.

The selected naming/configuration loops visit each final nonempty declared
list at most once for the one project and Ada language; unset default lists
are nil. `GPR.Util.Put` (`gpr-util.adb:2479–2527`) copies each cell once into
Name_Lists, giving at most D * L. `GPR.Util.Duplicate` at `:570–600` has no
selected caller in the full source inventory. With both runtime pathfiles absent,
`gpr-nmsc.adb:2832–2972` adds exactly two directory Name_List cells. Hence
Name_Lists <= D * L + 2. GPR's internal runtime strings can contain R//adainclude
and R//adalib; compiler search strings retain the accepted single-slash
normalization from the preceding packet. These metadata and child-search
coordinates are separate.

| Phase | Project_Nodes before RTS | String_Elements before RTS | Name_Lists before RTS |
| --- | ---: | ---: | ---: |
| datarep | 28,220 | 46,049 | 16,382 |
| phase1 | 28,764 | 47,805 | 17,114 |
| translation | 29,104 | 48,883 | 17,486 |

The accepted +20/+7/+7 delta applies once. Its two new clauses reuse existing
array/index entries, and the selected Apply_Config branch makes shallow copies.
The table growth bound and source record widths are inherited from the accepted
generic table arithmetic, evaluated with actual instance parameters. The final
separate objects are:

| Phase | Nodes demand / object bytes | String cells demand / object bytes | Name cells demand / object bytes |
| --- | ---: | ---: | ---: |
| datarep | 28,240 / 19,881,312 | 46,056 / 7,369,040 | 16,389 / 1,048,928 |
| phase1 | 28,784 / 20,264,288 | 47,812 / 7,650,000 | 17,121 / 1,095,776 |
| translation | 29,124 / 20,503,648 | 48,890 / 7,822,480 | 17,493 / 1,119,584 |

`result.json` also exports bounded Variable_Elements, Arrays, Array_Elements,
Packages, Number_Lists, Reference_Prefix, Case_Choices and Case_Stack coordinates.
Variable_Elements uses 216 * (P + 2) + D, overpaying all predefined attributes
for each package and both project scopes. Arrays and Array_Elements each use
2 * D for parsed plus applied entries; Packages uses parsed packages plus all
five configuration package copies. Reference_Prefix has peak one and records
the separate reset-event allowance; the empty case has one literal choice and
depth one. These supporting bounds do not assert that all parser storage has
been priced. The four additional parser-local backing objects below are joined
by the separate focused receipt, preserving the original successful baseline.

`gpr-part.adb:64–156` declares Withs, Project_Stack and Extended_Projects;
`gpr-tree.adb:60–65` declares Next_End_Nodes. All have low bound 1, initial
capacity 10 and growth 100. With_Record has five scalar fields, Names_And_Id
four, Name_And_Path two, and Project_Node_Id one, giving conservative component
widths 80, 64, 32 and 16 bytes respectively. The only Withs increment is the
context-clause path at `gpr-part.adb:791`; the selected inputs have no imports.
The only Extended_Projects append at `:1842` is in extension processing; no
extension is selected. Both zero-demand tables still receive an initial-backing
allowance.

Project_Stack.Init runs in each top-level Part.Parse (`gpr-part.adb:586`). The
single append site at `:1434` is reached once per selected parse and the normal
return pops at `:2143`, so gross pushes are two and peak depth one. This does
not erase either reset epoch. Next_End_Nodes is pushed for a project
(`gpr-part.adb:1991`), package (`gpr-dect.adb:1584`) or case (`:926`), and is
popped at their corresponding ends (`:2020`, `:1629`, `:1033`). These calls
still occur with Store_Comments=False. The two projects, seven packages and one
case give ten gross pushes. Using that gross count as demand also covers the
peak backing, without relying on the smaller selected nesting depth. The RTS
clauses add none of these constructs. `auxiliary_parser_tables` therefore
exports, for every phase:

| Auxiliary table | Gross entry demand | Separate backing bytes |
| --- | ---: | ---: |
| Withs | 0 | 1,680 |
| Project_Stack | 2 | 1,344 |
| Extended_Projects | 0 | 672 |
| Next_End_Nodes | 10 | 336 |

The machine flags `parser_shared_tables_closed` and
`parser_shared_table_baseline_closed` mean only the explicitly enumerated
`gross_shared_table_bounds` coordinates. They do not mean every parser or
process allocation is closed. Gross appended-cell demand bounds each relevant
table epoch conservatively; object bytes are maximum individual backing sizes,
not cumulative allocation bytes. The two reset epochs, scratch resets,
reallocations and frees remain events for the later parent-allocation join.

## Startup contributions and remaining #212 obligations

The source Initialize block has 216 Add_Attribute and 19 Add_Package calls
(`gpr-attr.adb:137–1424`). Attrs initial 50/growth 100 with a conservative
144-byte component gives capacity 432 and a 62,352-byte backing object.
Package_Attributes initial 10/growth 100 with a 48-byte component gives capacity
38 and 1,872 bytes. Package_Names starts with 20 pointers and does not grow for
19 requests (`gpr-attr.adb:34–67`); each selected name String fits 48 bytes.
The associated set-container allocation provider is not attached.

GPR.Snames Initialize (`gpr-snames.adb:50–356`) contains 300 literal Add_Name
requests, maximum payload 32. A conservative allowance of two additional
reserved positions makes 302. GPRbuild loads the standard KB with
Parse_Compiler_Info=False (`gpr-util-knowledge.adb:59–87`) plus the selected
phase database. Structural XML inventory, including entity expansion, contains
65 inputs and 9,492 elements: 63 base XML files plus the two phase additions.
This is the union inventory, not a claim that each process loads both extras.
There are 104 targetsets; the extras add none. The canonical-or-first-target
branch (`gpr-knowledge.adb:1079–1177`) gives at most one intern request per set.
Full compiler/configuration KB parsing belongs to the separate Gprconfig child.

Scanner strings and identifiers (`gpr-err-scanner.adb:337–354,2107`), including
one-token lookahead, plus parsed-name and expression concatenations contribute
at most 2 * T + 2 * D + Q requests. The resulting known contributions are
2,405 / 2,443 / 2,467 across the three phases. **These are not complete
GPR.Names demands.** GPR.Names is a global indefinite vector with separate
Name_Entry allocations, not GNAT Namet. `attach_names` requires explicit
additional, prior-capacity and later-request operands and never marks the
missing provider attached merely because arithmetic succeeds.

The following joins remain concrete #212 obligations under #119:

| Process / object family | Remaining source/configuration join |
| --- | --- |
| GPRbuild global Names | Command, environment, PATH mutation, directory/path normalization, naming and other nonparsed requests; prior vector capacity and later ALI/process requests and variable-sized entries. |
| GPR parser/startup backing | Remaining initial project/tree/environment/hash/set/list/comment objects, allocator events across resets and growth, and remaining command/OS buffers. The four enumerated auxiliary tables above are now joined. |
| GPRbuild KB | XML/Ada DOM, input, entity and node containers; regexp compilation of anchored patterns; directory/file sorted sets, target/fallback vectors, fallback Strings and RTS_List backing. |
| Separate Gprconfig | Full compiler-description/configuration KB containers, directory entries and executable candidates, candidate command output, selection/substitution/merge/generation objects and its own startup/Names state. |
| Separate GNATprove GPR2 | Startup, project and runtime discovery objects; retained indexed Main content parsing does not discharge these. |
| Later producer joins | Existing source-dependent fixed/Main semantic, ALI and process/report providers must be composed with these prefix objects. |

For the next increment, `gpr-knowledge.adb:1195–1363` shows deduplicated database
directories, sorted file sets, DOM parsing and per-file DOM freeing. Freeing
does not erase cumulative allocation events. RTS_List starts with four slots
(`:496`); the selected database-directory count is one for datarep and two for
phase1/translation. Gprconfig's directory/candidate discovery at `:2791` onward
and batch iterator at `:3900–4075` require bounds for unsuccessful preceding
candidates and their output, not merely the final selected compiler. These are
source/recipe obligations; no new capture or exact historical AST reconstruction
is imposed as a prerequisite.

## Validation and handoff

The first focused offline source/data/arithmetic check passed in **0.177625
seconds** on Linux x86_64. It verifies provider/source pins and concrete
project/configuration reconstruction, counts predefined sites and XML structure,
checks source branch receipts and evaluates the table guards. It does not rerun
the accepted all-package XML selector or any predecessor checker. The successful
receipt is retained unchanged in `result.json`, `check.stdout` and `check.stderr`.

After that check, the parent requested closure of the four parser-local
auxiliary backings within the same freeze. The final documentation also made
the enumerated-table scope explicit, and the unused future Names interface
lost its default later-request operand, so no unresolved contribution can be
silently supplied by omission. `check-boundary.py` checks those new table
obligations against three complete pinned source files and the retained baseline
receipt, together with the changed callable boundary. It passed first attempt
in **0.125175 seconds**. It does not replay the baseline calculation. No numerical baseline formula or retained result changed.
No native compiler/prover/Lean/service execution,
capture or runtime-corpus rescan occurred.

[handoff.json](handoff.json) exports the concrete coordinates and residuals;
[round.json](round.json) records selected GPT-6 Astra / Extra High, exact local
check timings and unavailable runtime model/token/cost telemetry. Independent
review of this author freeze remains pending. Parent integration, issue status
and publication are separate; this subthread made no GitHub or CLI-memory write.
#212/#119 and complete producer configuration capacity remain open.
