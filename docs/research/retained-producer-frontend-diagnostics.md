# Fixed proof-mode frontend diagnostic carry

2026-10-24, research #119 and #193. This attachment concerns GCC diagnostics
already present before SPARK flow/proof reporting. It is distinct from the
[incoming SPARK report transfer](retained-producer-report-incoming.md), and
from native compilation's Warnsw defaults and native fixed captures.

The selected source model is GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and SPARK
`42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. The retained Linux producer identity
is SHA-256 `343682de485bb151e1817615acebab5b185504efdf2b082f1647cd41a14241f1`.
The existing source-to-installed-tool premise remains explicit. No compiler,
prover, provider or debugger was rerun.

## Exact prior evidence being promoted

The [fixed Main light capture](../evidence/retained-main-semantics-20261018/fixed-capture/README.md)
and [four fixed-library captures](../evidence/retained-main-semantics-20261018/library-capture/README.md)
already recorded 121 table-position lifetime vectors. Their original reports
promoted the node/entity domains, not these diagnostic fields. This attachment
selects the following existing positive-growth fields, independently of A/E:

| Fixed contribution or complete fixed process | Non_Instance_Msgs | Errors | Locations | Edits | Fixes |
| --- | ---: | ---: | ---: | ---: | ---: |
| Main fixed source closure | 0 | 0 | 0 | 0 | 0 |
| Silver_IO body | 12 | 12 | 12 | 0 | 0 |
| Silver_Arguments body | 7 | 7 | 7 | 0 | 0 |
| Silver_Output_Libc specification | 0 | 0 | 0 | 0 | 0 |
| Silver_Runtime specification | 0 | 0 | 0 | 0 | 0 |

These are **whole-prefix** positive increases through `before_symbol_free`,
not an observation of the isolated GCC phase or a claim that GCC emitted 12/7
warnings. SPARK flow messages also use these tables. Using the complete
nonnegative total for its earlier GCC subset deliberately overcharges those
messages when the incoming SPARK transfer is added later. No subtraction of
the flow messages is needed.

The exact identity is `positive = final - initial + all decreases`. The
existing ELF/source audit covers all stores to these positions: 2,299 stores,
1,265 decrease-capable/unknown hooks and 1,034 source-proved monotone stores.
Unknown stores are included; table initialization/reset is not silently
ignored. These diagnostic positions have zero decreases in the selected
completed captures. The new offline reader reconciles the exact positions,
source/options/tool identities and prior coverage artifacts. It does not
re-execute the capture or turn a table count into a string-length measurement.

The four library processes have fixed source and imported prerequisites and
cannot name Main. The existing
[fixed-process source reduction](retained-producer-fixed.md#separate-fixed-library-processes)
therefore applies to their complete earlier GCC phase: runtime argument values
remain symbolic, not fresh compiler inputs. Capture configuration permits
asynchronous `/usr/bin/false` launches and stops before result collection;
those later children cannot affect earlier GCC diagnostics. The fixed Main
component additionally requires the established root/reset/first-freeze and
coherent all-miss reduction in
[Main semantics](retained-main-semantics.md#conditions-before-an-additive-fixed-measurement-is-sufficient).
It is not the zero count of an arbitrary sample.

## Configuration and source noninterference

All five retained proof captures have `global_gen_mode=false`,
`warning_mode=SW_TREAT_AS_ERROR`, `report_mode=GPR_ALL`, no inlining or loop
unrolling, and pretty-simple output. Current ordinary execution uses warning
mode Normal; the null configuration uses Treat_As_Error. The selected output
proposal changes pretty to brief and retains Report_All.

`Back_End.Scan_Compiler_Arguments` sets GNATprove_Mode before scanning compiler
arguments and selects Warning_Mode from the proof option
(`back_end.adb:126–187`). The frontend then resets all style checks and enables
only Elab_Warnings and Warn_On_Suspicious_Contract, while preserving the
documentation-switch flag (`gnat1drv.adb:517–529`). A string-of-switches Warnings
pragma is ignored in GNATprove mode (`sem_prag.adb:28781–28801`). Thus native
Warnsw defaults do not describe this execution.

For the retained fixed inputs, changing Treat_As_Error to Normal leaves the
earlier diagnostic **attempts and raw recipes** unchanged:

* The semantic Warning_Mode tests distinguish Suppress from enabled warning
  processing (`sem_warn.adb:1249,1937`; `sem_elab.adb:17911`). Both selected
  modes take the enabled branch. Internal-unit suppression and restoration
  preserve that distinction. Per-location suppression likewise distinguishes
  Suppress, not Normal from Treat_As_Error (`erroutc.adb:1995,2039,2149`).
* `Error_Msg_Internal` records Warn_Err only after appending the error object
  (`errout.adb:1515–1545`). The mode changes that classification, not the raw
  message, location, fix or string constructor. Final output/count conversion
  is later (`:3216–3220`). The completed Treat_As_Error capture has already
  passed `Finalize` and `Compilation_Errors` before entering the backend
  (`gnat1drv.adb:1199–1216,1535`); Normal does not unblock a previously
  unexecuted fixed semantic suffix here.
* Brief versus pretty changes Debug_Flag_FF and color-output selection
  (`back_end.adb:143–157`). The native Debug_Flag_FF reads are output choices
  (`errout.adb:3017`; `erroutc.adb:1000`), after message construction. Report
  mode is a SPARK-flow choice, and remains All; the earlier GCC caller set is
  unchanged. No driver/provider response has arrived during this phase.

Main varies only within its established typed closure. It cannot insert a
declaration or contract into a reset fixed unit, alter a fixed warning pragma,
or supply a different operand to a fixed semantic range query. The coherent
all-miss argument preserves the mathematical return values; cache hits can
omit fixed arithmetic, not change a warning predicate's result. Package/spec
analysis is reused after its analyzed guard. Main's calls do not trigger
GNATprove frontend body inlining: unit/package-spec subprograms and expression
functions fail the corresponding eligibility gates (`inline.adb:1950–2030`).

The possible cross-unit warning dependencies are accounted for separately:
unreferenced/could-be-constant/modified-unread and inherited-aspect listing
flags are disabled; Main has no warning or style pragma; suspicious-contract
checks read the fixed callee contract/formals, not an arbitrary caller body;
elaboration-call warnings on variable Main retain the established up-level
target exclusion. Main's own loop and context warnings remain the existing
`J_Main=2F_loop+N_with` allowance. This attachment does not replace that term
with zero. A different fixed unit, contract, runtime, naming configuration,
frontend option or Main construct invalidates this reduction.

The fixed source closure comprises the six Silver files and the selected
runtime specifications listed in the evidence. The dependency chain includes
Ada.Text_IO's stream/CRTL prerequisites and the predefined Text_Buffers,
UTF_Encoding and three Unchecked_Conversion instances. It is not limited to
the visible Silver package declarations. System uses the Linux x86 variant;
Interfaces uses `interfac__2020.ads`. The only warning/style/compile-time-warning
pragma in that closure is System's `Warnings (Off, Default_Bit_Order)`; it does
not change global warning switches. The evidence checks exact source bytes;
source-record extents corroborate the closure but are not filename identities.

## History and formatted strings have different owners

Raw histories are appended before suppression (`errout.adb:550–697`). Let
`J_fixed` be the corresponding row's Non_Instance_Msgs count. Then the earlier
GCC history has at most `J_fixed` entries, even if no warning is eventually
shown. Errors and Locations have the separate bounds in the same row. They
must be carried alongside Main's additions and the SPARK suffix, without a
counter reset.

A deliberately broad raw-template envelope avoids borrowing Main's
64-character loop-template bound. Let `C_front` be the byte total of the 474
pinned top-level GCC Ada `.ads`/`.adb` files: **27,301,966**. Let `N_fixed` bound
the selected fixed name spelling and `P` the configured source/reference name.
For this selected successful semantic prefix use

```text
R_fixed = 2 C_front + 2 N_fixed + 2 P + 128.
raw-history lifetime characters <= J_fixed R_fixed.
```

This is a source-recipe envelope, not a measured message length. The ordinary
warning recipes are fixed literals, optional fixed alternatives, or forwarding
wrappers. The selected dynamic wrappers retain or slice their argument and
add fixed prefixes: suspicious-contract `Adjust_Message` adds `conjunct in `
(`sem_util.adb:4321–4350`); `Fix_Error` copies/replaces/shrinks its argument
(`sem_prag.adb:8190–8267`); compile-time-constraint reporting adds at most three
control characters (`sem_util.adb:6020–6131`). Quantified-expression diagnostics
choose `conjunct` or `disjunct` and emit a fresh message per visited expression,
not one accumulating string (`sem_ch4.adb:4744–4790`). Elaboration diagnostics
likewise emit separate messages for successive scenarios. Native entity/name
and location arguments normally occupy Errout substitution slots, not a
repeated raw-message accumulator. The factor two also covers a repeated fixed
modifier in one recipe; numeric images of fixed target sizes fit the 128-byte
allowance. The complete source-text total overcharges the decoded literal
catalogue.

The supplementary raw-argument census inventories 4,422 direct Errout calls
across all pinned top-level Ada bodies, with 228 nonliteral first arguments;
the largest direct literal argument has 147 bytes. It includes forwarding
wrappers and unselected binder/chopper/error families. These are audit inputs,
not invocation counts or a replacement for the dynamic-recipe classifier.

The remaining dynamic error-text paths require parser recovery, failed
legality/name lookup, dimension-system diagnostics, invalid aspect or
representation clauses, or source-supplied compile-time-warning/error text.
The selected successful fixed syntax and the pragma inventory exclude these
paths. Native contextual-inlining diagnostics are excluded by the earlier
eligibility/predefined-unit gates (`inline.adb:1950–2030,2150–2169`). No arbitrary
source diagnostic payload is imported into this raw bound. This classifier is
a manual source argument; the script does not infer it from a lexical census.

Formatted text remains capped by `M_diag=66558` through Set_Msg_Char. The
selected compiler arguments contain no `-gnatj` override, so
`Error_Msg_Line_Length=0` (`opt.ads:535`; its sole setter is
`switch-c.adb:1003`). The continuation-join replacement branch at
`errout.adb:1378` is therefore absent; every stored continuation has its own
error record. With `J` earlier appended error records and no supplied
labels/fixes/extra spans, formatted-string lifetime characters are at most
`J M_diag`, and raw plus formatted heap-string requests are at most
`J_fixed+J`. These counts do not borrow Main's two-message chain. Apply the
existing native table/heap-layout transfers and separate index/one-past guards.
Zero Edits/Fixes lifetime growth excludes their retained records; caller-side
temporary recipes are bounded above rather than inferred from display.

## Earlier native display

Treat_As_Error reaches the backend only after `Compilation_Errors` is false;
that predicate includes Warnings_Treated_As_Errors (`erroutc.adb:228–232`).
All ordinary native warnings are classified as errors in that mode. Selected
sources contain no Compile_Time_Warning pragma, the exceptional untreated
warning family (`errout.adb:1538–1544`). Thus no undeleted primary compiler
warning survives the pre-backend finalization for these fixed inputs. Its
attached continuation chain cannot independently survive a removed primary.
Changing to Normal preserves those earlier caller/recipe/suppression choices;
it does not add a formerly absent displayed GCC warning.

Native informational routes are separately excluded: body-required and
inherited-aspect listing use disabled warning flags; parser-placement/type-
inference explanations require recovery/debug modes; contextual-inlining
messages require the excluded inline candidates; elaboration info uses the
disabled `Elab_Info_Messages` flag. This is not a claim that successful
compilation inherently excludes informational messages.

Consequently the fixed GCC contribution to **displayed** source/text lines is
zero under the selected source/configuration reduction, while its conservative
raw-history/table contribution remains 12/7/0/0. Main's own diagnostics and
SPARK flow/proof messages retain their independent rendering bounds. In
particular `R_fixed` is not a native line-buffer length: applying its broad
raw-history envelope to an actually printed line would be the wrong owner.

## Status and work record

The focused independent source review found no blocker in this fixed-source,
history and display reduction. This attachment promotes specific prior
proof-mode positions under the stated source/configuration
reduction. It does not promote native captures, infer diagnostics from typed
node counts, assert complete #119 admission, or discharge fixed-library VCs.
All scalar arithmetic, object extents and native indices retain their own
representability checks; physical RAM/stack/disk and faithful external behavior
remain existing premises.

The reviewer independently checked the complete GCC Warning_Mode/Warn_Err
read frontier, the pre-backend Finalize/Compilation_Errors gate, native
Debug_Flag_FF reads, fixed pragma/inline premises and the dynamic raw wrappers.
The review expressly retains the manual recipe classifier: compiler source
bytes alone do not bound an arbitrary message accumulator. It also preserves
the distinction between the 12/7 whole-prefix supersets and actual GCC warning
counts, and the separate informational-message exclusions needed for zero
display. Whole #193 integration remains a separate review target.

Reviewed note SHA-256:
`002777d2dcc06cce6d6a5cdf20eda6baf1439d7e2c9ecbc74522d1a3211b5204`.
Selected reviewer: GPT-6 Astra / Extra High, runtime confirmation unavailable;
source-only review with no checker/native execution. Review elapsed time and
token/cost data were unavailable. Later edits record that disposition and the
supplementary lexical inventory without changing a bound or prerequisite.

Selected author setting: GPT-6 Astra / Extra High, inherited; runtime model
confirmation and token/cost measurements unavailable. The prior captures'
actual times remain in their original evidence. This round performs only
source inspection and offline artifact reconciliation. The final recorded
review checkpoint was 2026-10-24 01:34:45 UTC.
