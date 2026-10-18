# Admitted CR-comment failure in GPR2 unit discovery

2026-10-18, blocker [#123](https://github.com/berkeleynerd/silver/issues/123),
found during [#119](https://github.com/berkeleynerd/silver/issues/119)'s producer
orchestration inspection. **The installed pipeline rejects a currently admitted
null program.** Indexed explicit naming of Main is a successful same-source
candidate repair; it has not yet been implemented in Silver by this record.

## Reproduction and root cause

The exact [CR input](../evidence/cr-comment-gpr2-20261018/probe/cr/main.adb)
contains `procedure -- note` followed by a bare CR, then `Main is` followed by
LF. Its remaining bytes are the ordinary null shell. Silver permits comments
terminated by CR or LF (`language.md:28–42`). The LF control differs in precisely
that one byte. Installed `silver check` accepts both. GNATprove succeeds on the
LF control, but rejects the CR program before phase1:

```text
main.adb: warning: unit name "SPARK_MODE" does not match source name. The source will be ignored.
Stopping analysis due incorrectly named source files
```

The ordinary installed `silver run` then exits3 with
`Verification failure for admitted Silver: toolchain or implementation defect.`
This is an Oracle violation for admitted source, not a capacity estimate or an
observed resource exhaustion. No larger-language construct is needed.

GPR2's basic Ada reader uses its generated project lexer. The inspected
`gpr_parser-lexer_state_machine.adb:814–835,1382–1403,1809–1830` accepts every
character except LF in a comment, including CR. Consequently it consumes
`Main is` as part of the preceding comment. `Parse_Unit` then selects the next
identifier other than `body`, which is `SPARK_Mode` in this witness
(`src/lib/gpr_parser-basic_ada_parser.adb:325–386`). Its default-naming caller
compares this inferred unit name against `main.adb`, emits the quoted warning
and discards the source
(`src/private/gpr2-build-view_tables-update_sources_list.adb:1016–1037`).
GNATprove deliberately makes that warning fatal in
`src/gnatprove/configuration.adb:265–289`.

The fallback does not protect this case. It restores the filename-derived unit
only when parsing fails to find a name (`:1065–1072`); this parser returned a
wrong name successfully. Cases where a leading CR-terminated comment hides the
entire procedure token may take that fallback and behave differently. This
record makes no exhaustive classification claim for all CR placements.

## Same-source project candidates

Ordinary `for Body ("Main") use "main.adb";` changes the GPR2 path to a naming
exception. It succeeds on the witness, but still runs the heuristic parser and
emits a warning that `SPARK_MODE` differs from declared `MAIN`. It retains
misidentified metadata, so this is not the preferred repair.

The indexed declaration is stronger:

```gpr
package Naming is
   for Body ("Main") use "main.adb" at 1;
end Naming;
```

GPR2 skips the basic Ada parser for an indexed naming-exception list
(`gpr2-build-view_tables-update_sources_list.adb:1077–1081`), preserving the
explicitly supplied known unit metadata. Silver already admits exactly one
library-level Main per source, so index1 names the existing first and only unit.
No author source byte changes, language restriction or toolchain modification
is required by this candidate. Old GPR still uses its separate Ada scanner for
subunit detection; that scanner recognizes CR and stops at `procedure`
(`gpr-sinput.adb:694–724`; `gpr-err-scanner.adb:2340–2385`).

Installed GNATprove accepts the indexed candidate without a warning, and native
GPRbuild compiles, binds and links it. Its `bin/main` exits0 with no output.
The candidate adds `-gnateI1` and produces `main~1.ali` and `main~1.spark`.
The representation JSON remains `main.adb.json`, and the executable remains
`bin/main`. The proof report still identifies entity `Main` and source
`main.adb`. Silver currently reads `main.spark`; implementing the candidate must
update the exact report path, source correspondence/pins and affected tests
together, and verify broader current-language behavior proportionately.

For the [producer descriptor](retained-producer-gpr-descriptor.md), the candidate
phase1 has nine stored A switches, payload sum53, maximum9, with the additional
eight-byte `-gnateI1`. Its two D dependencies remain Main and System; U/D/X source
filenames remain `main.adb`/`system.ads`. The previous unindexed descriptor is
historical evidence for its stated configuration, not automatically the final
repair descriptor. Generated naming text, indexed native/producer arguments,
report consumers and the data-representation join need coordinated refresh.

## Evidence and remaining work

The [offline evidence packet](../evidence/cr-comment-gpr2-20261018/README.md)
retains exact inputs, outputs, selected artifacts, native executable digests,
immutable GPR2 sources and managed records:

| Managed run | Scope | Tool elapsed |
| --- | --- | ---: |
| `20261018T084310-df364b9e436a` | Two admissions, LF/CR GNATprove pair | 1.025s |
| `20261018T084412-2f5b3939c9fd` | Ordinary installed Silver failure | 0.393s |
| `20261018T084437-03b3359918e6` | Unindexed naming candidate | 0.823s |
| `20261018T084527-85a1cdc08914` | Indexed naming candidate | 0.826s |
| `20261018T084609-50fab428d21d` | Indexed native build and execution | 0.492s |

The GNATprove diagnostics use production proof settings except isolated
`--subdirs=explore/cr-comment` and one worker. The ordinary `silver run` uses
its actual production wrapper/configuration, including `-j0`. No complete
native audit, full test suite, Lean build or replay was run. One program directory
was created in the original installation and retained; other writes were isolated.

The GPR2 revision is current immutable source selected through the dependency
recipe, not an attestation of the installed historical revision. The recipe
forces regeneration of the parser; the source argument retains the selected
relevant-behavior premise. Installed observations establish the actual defect
and candidate outcomes separately.

Repair #123 now takes priority. #119 remains incomplete: the complete null
family cannot be declared pipeline-safe while this rejection remains, regardless
of successful capacity calculations. GPR/GPR2 fixed project/configuration
containers and orchestration capacity, the native data-representation invocation
and the whole-rule conjunction are still outstanding.
