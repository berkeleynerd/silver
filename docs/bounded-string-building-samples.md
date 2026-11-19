# Bounded text buffer samples

## Status and scope

**Implementation authorized for [#400](https://github.com/berkeleynerd/silver/issues/400), 2026-11-18; final validation and closing review pending.** The owner requested development of this samples-only work package, including the multi-character append/prepend amendment below. The earlier planning evidence is retained as history. Broad [#395](https://github.com/berkeleynerd/silver/issues/395) remains open.

Deliver four faithful Rosetta samples that append, prepend, repeat text and generate the complete 99-bottles lyrics using existing Silver. Document the bounded-buffer idiom, its full-buffer outcome and measured limits, and correct the affected assessments.

Route: **samples-only**, one work package in **Bounded text buffer samples**. No compiler, runtime, admission rule or Oracle change is planned. Samples-only delivery is an existing option (`development.md:37–54`; `docs/planning.md:137–162`).

The precise Rosetta identifier **`bounded-string-building`** records the composition of a fully initialized fixed-bound String, a separately bounded logical length, checked Character stores, counted-loop copying or shifting, and filled-prefix output. It describes existing operations used together; it introduces no new source form or library API. It is registered in `rosetta/refresh.py`'s `ADMISSION` dictionary and `SURFACE_LABELS` and in supported coverage, using the display wording “bounded String building with initialized buffers.” The renderer rejects unknown supported identifiers (`rosetta/refresh.py:338–350,741–747`); this metadata registration changes no Silver admission rule. The existing catalogue entries remain authoritative (`catalogue/silver.json:1339–1394`). Broad `string-building` stays unsupported; these samples do not cover arbitrary append sources, String parameters or resizable strings. Partial identifiers must retain their broader exclusions (`docs/planning.md:224–238`).

The retained planning citations refer to published main `5af7edc5cd2501f8d1a21c778706dee135c057fa`. That planning pass used try compiler `07422adb2d211304f3ebfeed92b0eaf798957d41`, with only documentation differences reported. Implementation starts from `a03c7987bbba29569db2709820bd26ced20bed40`; the supplied delivery try compiler is `9b5b2d99aaf6f4bfca5226b36af744502b095990`, whose sources differ from that main only under documentation according to the workflow scope. No unmerged feature is credited. The historical PR-status paragraph in #395 is not the language baseline. Preserve the recorded #373 recovery work and PR #385 hold; this proposal does not select a new execution order (`roadmap.md:40–96`; `docs/session-memory.md:60–85`). Planning approval remains separate from implementation and merge authorization (`docs/planning.md:157–162`).

The historical planning packet reports **1,588** likely/plausible candidates and **16** supported identifiers. Broad `string-building` occurs in **1,009**, would alone unlock **157**, of which **112** are likely; its pair with `while-loops` has **163**. The generated stage has **18** samples, **2** only plausible, with overflow flagged in **11**, index in **6**, length in **4** and range in **3**. These unchanged assessment counts are upper bounds, not this batch's promised gain. Count delivered programs, runtime cases and task mappings separately.

## Implementation handoff — 2026-11-18

The four sample sources, manifest entries, seven boundary/control test methods,
twelve targeted assessment corrections and renderer registration are prepared.
The [implementation packet](evidence/bounded-string-building-400-20261118/README.md)
identifies exact inputs and retains all fifteen candidate sources, complete
execution streams, application proof reports and fresh report-audit results.
Ten candidates completed admission, proof/audit, build and execution with exact
stdout, empty stderr and status 0; five negative controls rejected as expected.
These focused results do not complete the shared validation checkpoint.

The append sample saves its guarded original length in Start, declared
`0 .. 5`, and updates Len before the counted copy loop. Loop entry widens mutable
scalar facts, so the saved offset's declared bound is needed. The earlier
documentation variant that indexed with Len directly inside the loop rejected;
the complete example below now matches the admitted sample bytes. Several-character
refusal fixtures inspect the whole buffer and Len with one free cell, detecting
partial mutation. The repeated-prepend fixture makes shift order observable;
the repeat fixture executes every count from 0 through 10. Historical B1/B2/B3
sources and results remain below with their original attribution.

The integrated `rosetta/refresh.py --render` passed with the precise identifier
registered. Stage 1 gains exactly the four delivered tasks, **85 to 89**:
append, prepend and bottles move **4 to 1**, repeat moves **10 to 1**. All
**63 existing construct Stage values remain unchanged**, including broad
`string-building` at **4**. The manifest grows **86 to 90 programs** and
**149 to 153 execution cases**; no fifth sample is delivered. Of 472 changed
generated task pages, twelve contain assessment changes and 460 change position
only. Generated pages were produced by the renderer.

The live try service identifies compiler checkout `07422adb2d`, rather than the
scope's `9b5b2d99aa`. Both commits have identical compiler/runtime/proof/auditor,
build, catalogue and Oracle inputs; all 1,187 governed tracked files also match
byte for byte between the actual service checkout and this work tree. The
packet records this discrepancy and the limits of that source comparison.
The complete native/Lean evidence packets are omitted from this checkout;
their applicability and required fresh audits remain for the workflow check
step, together with the final manifest/boundary/Rosetta tests and complete final
regression inventory. Independent closing review follows those results. No
compiler, proof, source-certificate, report policy or capacity change was made.

The focused pass had ten successful full-route attempts and five expected
admission refusals, with no proof failure or interruption. Its candidate result
window was 17:23:41–17:26:18 UTC; full delivery elapsed time and final checkpoint
attempts remain to be recorded at closeout. The request host was Linux aarch64;
native child stack, worker allocation and cache hits were not reported by the
try results. The final checkpoint must record its actual settings.

The operator leaves all GitHub issue and board edits for **after merge**.
Keep #395 open for its remaining broad scope and reconcile every existing stage
card against the final render, preserving status and authorization. Supported
closed cards retain Stage 1 and Closed/Done; the render changes no existing
construct's Stage. The live card inventory has not been inspected or edited in
this pass. Issue #400 remains pending its complete validation and closing review.
The remaining design and planning evidence below is retained as history and
does not substitute for that checkpoint.

## Faithful drivers and alternatives

The upstream planning probe ran all four drivers through admission, proof/report audit, native build and execution. Its output comparisons were separate from the try service: `stdout_match=None` did not perform an expected-output comparison. The original D1/D2 probes used single-character literals. The owner subsequently required several-character literals; the selected drivers below reflect that amendment. The original result identities remain below as historical evidence, not evidence for the amended source bytes.

| Driver and primary requirement | Selected program and observed result |
| --- | --- |
| **String append**, `rosetta/s/string-append/task.wiki:11–15`: initialize text, append another literal and display the resulting variable. No callable interface is required. | The amended D1 starts with logical `Hello` in 13 initialized cells and copies the eight-character literal `, world!` with a counted loop after one whole-literal fit check. A second attempt refuses. Expected output, fixed before execution, is `Hello, world!\nfull\nHello, world!\n`. |
| **String prepend**, `rosetta/s/string-prepend/task.wiki:10–17`: prepend a literal and display the variable. | The amended D2 starts with logical `World!` in 12 initialized cells, shifts the existing text right by six in reverse order and copies the six-character literal `Hello `. A second attempt refuses. Expected output, fixed before execution, is `Hello World!\nfull\nHello World!\n`. |
| **99 bottles of beer**, `rosetta/0-9/99-bottles-of-beer/task.wiki:4–24`: complete verses from 99 through the transition to zero; singular grammar is optional. | D3 computes counts in `for N in reverse 1 .. 99`, using `Integer'Image (N)` and `Integer'Image ((N - 1))` in output expressions. The probe compared the complete retained stdout: 495 lines, 11,357 bytes, ending with ` 0 bottles of beer on the wall` and the verse separator. Retain standard Image leading spaces (`language.md:1026–1031`). |
| **Repeat a string**, `rosetta/r/repeat-a-string/task.wiki:3–7`: repeat a string a chosen number of times, including the `ha` five-times example. The repeat-character variant is optional. | D4 copies `ha` with nested loops into 20 initialized cells, with Count declared `0 .. 10`, then prints length `Count * 2`. Count 5 produced `hahahahaha\n`. New boundary probe B2 below additionally executes every Count from 0 through 10. No String-valued function is required by the task. |

All four original planning executions returned status 0 with empty stderr. D1/D2 below are the superseded single-character drivers; their identities must not be used for the amended samples:

```text
D1 sha=18c9c0ca9634
20261118T020433-343539199-plan-try-78f400 check[head] exit=0 accept: Accepted: silver.
20261118T020433-405594490-plan-try-155816 full stage=ran :: Executable published
D2 sha=0da4fd2bcc1f
20261118T020629-876121504-plan-try-bccc3a check[head] exit=0 accept: Accepted: silver.
20261118T020629-937633254-plan-try-69eb8a full stage=ran :: Executable published
D3 sha=ddf00d40cffa
20261118T020743-219694372-plan-try-5c6d2b check[head] exit=0 accept: Accepted: silver.
20261118T020743-280915331-plan-try-8cea41 full stage=ran :: Executable published
D4 sha=d188e02bb926
20261118T020925-160521588-plan-try-2b9745 check[head] exit=0 accept: Accepted: silver.
20261118T020925-223087963-plan-try-d2c265 full stage=ran :: Executable published
```

Each corresponding probe reports compiler exit 0 and GNATprove exit 0 with `--mode=all --warnings=continue --checks-as-errors=on`. These application runs corroborate existing rules; they do not replace universal or exact-source assurance (`oracle.md:9–14,26–29`; `docs/assurance.md:54–58`).

Alternatives:

- A new buffer type or Append/Prepend library operation would be a convenience for these drivers. D1/D2 already perform the required mutations and refusal. Its new signatures, state contracts and correspondence work have no measured necessity here.
- Direct output concatenation suffices for 99 bottles, as D3 shows. It would fail #395's additional requirement if substituted for the append/prepend buffer demonstrations.
- The owner amendment selects several-character literals and whole refusal for those fixed literals. Arbitrary dynamic sources and optional repeat-character output remain outside this sample commitment. There is no general buffer API or new admission rule.
- Correct the stale “only missing piece” and missing computed-length/slice claims in the append/prepend assessments through their source records (`rosetta/s/string-append/silver.md:3–9`; `rosetta/s/string-prepend/silver.md:3–9`; `docs/planning.md:235–238`).

## Admitted forms and rules

These are existing rules applied to the samples, not proposed additions. In the explanations, capacity C is the initialized buffer's fixed positive length; the amended drivers use 13, 12 or 20; the retained boundary probes also use 2 or 6. Logical length is an ordinary Integer object. It does not change the String's bounds or its Ada Length.

### Declaration, initialization and counted literal append

The amended append driver uses this complete source:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Buffer : String := "Hello        ";
   Suffix : constant String := ", world!";
   Len : Integer range 0 .. 13 := 5;
   Start : Integer range 0 .. 5 := 0;
begin
   for Attempt in 1 .. 2 loop
      if Len <= 5 then
         Start := Len;
         Len := (Len + 8);
         for J in 1 .. 8 loop
            Buffer ((Start + J)) := Suffix (J);
         end loop;
      else
         Silver_IO.Put_Line ("full");
      end if;
      Silver_IO.Put_Line (Buffer (1 .. Len));
   end loop;
end Main;
```

The declaration syntax is initialized `String`, not a new `String (1 .. C)` buffer declaration. Every cell, including spare capacity, is initialized by the literal. Bounds are fixed by initialization; Len's initializer must fit its static declared range (`language.md:234–280,299–324`). There is no partially initialized tail or new definite-assignment analysis.

The bare-name guard `Len <= 5` narrows Len's incoming `0 .. 13` interval to `0 .. 5`. The program saves that value in Start and updates Len before the copy loop. With J in `1 .. 8`, `Start + J` lies in `1 .. 13`, and the guarded `Len + 8` lies in `8 .. 13`. Both buffer indexing and length assignment fit their declared bounds. Loop-body analysis widens mutable scalar facts to their declared ranges; Start's declared `0 .. 5` range therefore preserves the required copy bound. Using Len directly inside that loop would lose the guard refinement. Each `Suffix (J)` has Character type. The one guard ensures the entire literal fits before any store; no loop-carried invariant is needed (`language.md:409–439,738–768,953–973,1194–1209`).

At full capacity the source-written else branch performs no buffer or length assignment. It prints `full`, then the unchanged filled prefix. The sample treats refusal as an ordinary handled outcome: exit status remains 0 on healthy output. It does not truncate or silently drop part of an append.

### Prepend and repeat

D2 has the same outer structure and refusal/output placement as D1. Its declarations and successful arm are:

```ada
Buffer : String := "World!      ";
Prefix : constant String := "Hello ";
Len : Integer range 0 .. 12 := 6;
-- Inside the same two-attempt loop:
if Len <= 6 then
   Len := (Len + 6);
   for J in reverse 1 .. (Len - 6) loop
      Buffer ((J + 6)) := Buffer (J);
   end loop;
   for J in 1 .. 6 loop
      Buffer (J) := Prefix (J);
   end loop;
else
   Silver_IO.Put_Line ("full");
end if;
Silver_IO.Put_Line (Buffer (1 .. Len));
```

The increment fits `6 .. 12`. Loop bounds are captured before mutable variables widen. The shift loop's J interval is `1 .. 6`, so reads fit `1 .. 6` and writes fit `7 .. 12`. Reverse order prevents a write from destroying a character still to be read. String element assignment preserves every other cell and the fixed bounds; the full branch changes neither bytes nor length (`language.md:760–768,931–973`). The following counted copy fills positions `1 .. 6` from the literal. The single guard precedes the length update, shift and copy, so refusal leaves all three untouched.

For repeat, use `Source : constant String := "ha";`, a 20-space Buffer and `Len : Integer range 0 .. 20 := 0;`. The admitted copying body is:

```ada
for I in 1 .. Count loop
   for J in 1 .. 2 loop
      Buffer ((((I - 1) * 2) + J)) := Source (J);
   end loop;
end loop;
Len := (Count * 2);
Silver_IO.Put_Line (Buffer (1 .. Len));
```

With Count in `0 .. 10`, I's checked body interval is `1 .. 10`, J is `1 .. 2`, and the destination interval is `1 .. 20`. All intermediate arithmetic fits Integer. Len is `0 .. 20`; zero iterations produce the empty prefix, and Count 10 fills the buffer exactly. There is no overflow/refusal path for this declared domain and no claim for a larger domain. These deductions use the ordinary independent interval rules and finite-loop semantics (`language.md:365–373,931–973`); B2 executes all eleven values.

### Append sources, clearing, output and interfaces

| Requested form | Exact scope and checks |
| --- | --- |
| Literal | D1/D2 copy indexed Characters from named several-character String literals after checking that the whole literal fits. A direct printable Character literal can also be the element RHS under `language.md:719–749,760–768`. A one-byte String is not implicitly a Character. |
| Character | `Buffer ((Len + 1)) := Item;` uses an initialized `Item : Character := 'x';` and the same guard/index/range checks. B1 below runs this form. Characters cannot be passed directly to String output or concatenated as String atoms (`language.md:731–736,1059–1061`). |
| Integer Image | D3 uses Image in bounded output concatenation. No Image-to-buffer append API is added. Existing fixed-length Image initialization or assignment remains governed by exact inferred lengths, not merely a maximum that fits (`language.md:1026–1040,1095–1121`). Arbitrary Image append is not claimed by this identifier. |
| Another buffer's prefix | Existing `Other (J)` may supply one Character when Other has known fixed bounds and J's entire inferred interval fits; the destination independently needs its own capacity guard (`language.md:738–767`). The batch delivers no generic whole-prefix append, aliasing contract or two-length relational rule. Such implementations must be assessed individually. |
| Slice | `Other (L .. U)` is an existing String expression, subject to the slice rules below and equal-length whole-String assignment. It is not a Character RHS; slice targets and resizing are excluded (`language.md:768,1046–1061,1065–1121`). No general slice-append operation is added. |
| Clear | `Len := 0;` performs logical clearing, since 0 fits the declared range. Buffer remains initialized and keeps its bytes and bounds; clearing does not erase storage. Later prefix output is empty and later writes replace cells normally (`language.md:1194–1210`; B1). |
| Print the filled prefix | `Silver_IO.Put_Line (Buffer (1 .. Len));` appears after `end if;`. Len in `0 .. C` gives length `0 .. C`; nonnull endpoints fit Buffer, and `1 - 0 <= 2147483647` satisfies the additional endpoint-separation rule. Null output still appends LF (`language.md:1065–1090`; `src/silver_io.ads:18–26`). |
| Pass buffers to user subprograms | No. Existing function/procedure signatures are scalar, and their local-state/effect restrictions do not provide a buffer helper. Keep operations in Main. This does not remove the already admitted Silver_IO String argument (`language.md:497–503`; `docs/scalar-functions.md:73–98`; `docs/scalar-procedures.md:181–187`; `src/silver_io.ads:18–36`). |

Slice admission is decidable from endpoint intervals. For lower `[a,b]`, upper `[c,d]` and prefix `B .. E`, both intervals must be nonempty; either `a > d`, or `a >= B` and `d <= E`; also `b - c <= 2147483647` in wide arithmetic. Inside any conditional region, including its conditions, and after a Boolean-chain token since the preceding semicolon, both endpoints must be Ada-static (`language.md:1065–1090`). The probe's X1 conditional prefix output was rejected, `20261118T020911-878482415-plan-try-c85fe2 check[head] exit=2`; X2 moved it after the conditional and was accepted, `20261118T020912-954188457-plan-try-67cf47 check[head] exit=0`. The selected samples use X2's placement.

Guard composition remains unchanged. A bare Len compared to a static threshold refines; `Len + Source_Len <= C` is not a general relational refinement rule. Short-circuit `and then` passes reached facts, but saving a predicate in a Boolean does not preserve its relationship to Len. Branch exits join intervals, and loop entry widens mutable scalars (`language.md:409–439,476–483,953–973`). Never rely on a particular successful value, contradictory arm or empty loop to excuse an illegal index.

The capacity-full outcome above is distinct from I/O failure. Put_Line detects write/flush failure, sets sticky status 1 and returns; later statements continue. Partial output and external blocking retain the existing boundary (`docs/trusted-boundary.md:791–821`). This batch adds no exception, status-reset rule or new environmental assumption.

Excluded from this commitment: resizable/unbounded Strings; general indexing of input-dependent Strings; Unicode and new Character conversion syntax or attributes; String or array parameters/results; partial initialization; slice assignment; Character concatenation; general String libraries or arbitrary-source bulk append; new source/report limits; and author-written contracts, invariants or variants (`language.md:719–768,1065–1121`; `docs/scalar-functions.md:62–66`; `docs/scalar-procedures.md:181–187`; `oracle.md:3–7`). Operations already admitted elsewhere keep their existing scope.

### Additional measured boundaries

The drafter ran these two programs on 2026-11-18 using only `silver-try --run`, serially. Both completed admission, proof/audit, build and execution with compiler/GNATprove/runner exit 0 and empty stderr. Expected output was compared with the reported stdout; the service itself reported `stdout_match=None`.

**B1: empty, fill, full, clear, reuse.** Exact candidate `395-plan-buffer-boundaries.adb`:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Buffer : String := "  ";
   Item : Character := 'x';
   Len : Integer range 0 .. 2 := 0;
begin
   Silver_IO.Put_Line (Buffer (1 .. Len));
   for Attempt in 1 .. 3 loop
      if Len < 2 then
         Buffer ((Len + 1)) := Item;
         Len := (Len + 1);
      else
         Silver_IO.Put_Line ("full");
      end if;
      Silver_IO.Put_Line (Buffer (1 .. Len));
   end loop;
   Len := 0;
   Silver_IO.Put_Line (Buffer (1 .. Len));
   Item := 'Z';
   if Len < 2 then
      Buffer ((Len + 1)) := Item;
      Len := (Len + 1);
   end if;
   Silver_IO.Put_Line (Buffer (1 .. Len));
end Main;
```

```text
20261118T021848-067027231-plan-try-26e0d6 check[head] exit=0 accept: Accepted: silver. sha=2b2690110025
20261118T021848-128129815-plan-try-071eed full stage=ran :: Executable published
compile exit=0; gnatprove exit=0
run0 args=[] exit=0 stdout_match=None stdout='\nx\nxx\nfull\nxx\n\nZ\n' stderr=''
```

**B2: all repeat counts.** Exact candidate `395-plan-repeat-boundaries.adb`:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Source : constant String := "ha";
   Buffer : String := "                    ";
   Len : Integer range 0 .. 20 := 0;
begin
   for Count in 0 .. 10 loop
      for I in 1 .. Count loop
         for J in 1 .. 2 loop
            Buffer ((((I - 1) * 2) + J)) := Source (J);
         end loop;
      end loop;
      Len := (Count * 2);
      Silver_IO.Put_Line (Buffer (1 .. Len));
   end loop;
end Main;
```

```text
20261118T021917-349901453-plan-try-49f191 check[head] exit=0 accept: Accepted: silver. sha=cd6a3c9fee15
20261118T021917-411327245-plan-try-1bd988 full stage=ran :: Executable published
compile exit=0; gnatprove exit=0
run0 args=[] exit=0 stdout_match=None stdout='\nha\nhaha\nhahaha\nhahahaha\nhahahahaha\nhahahahahaha\nhahahahahahaha\nhahahahahahahaha\nhahahahahahahahaha\nhahahahahahahahahaha\n' stderr=''
```

B1/B2 are boundary fixtures, not extra Rosetta mappings. The challenge reran both successfully and also executed B3 below. These runs did not perform a new whole-compiler native or Lean checkpoint.

**B3: repeated prepend from empty through full.** The challenge ran this complete source; the changing prefix makes incorrect shift order observable:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Buffer : String := "      ";
   Prefix : String := "W";
   Len : Integer range 0 .. 6  := 0;
begin
   for Attempt in 1 .. 7 loop
      if Len < 6 then
         Len := (Len + 1);
         for J in reverse 1 .. (Len - 1) loop
            Buffer ((J + 1)) := Buffer (J);
         end loop;
         Buffer (1) := Prefix (1);
         Prefix (1) := 'X';
      else
         Silver_IO.Put_Line ("full");
      end if;
      Silver_IO.Put_Line (Buffer (1 .. Len));
   end loop;
end Main;
```

```text
20261118T023223-316826745-plan-try-119721 check[head] exit=0 accept: Accepted: silver. sha=37fe198c62dd
20261118T023223-378297287-plan-try-c903bd full stage=ran :: Executable published
run0 args=[] exit=0 stdout_match=None stdout='W\nXW\nXXW\nXXXW\nXXXXW\nXXXXXW\nfull\nXXXXXW\n' stderr=''
```

The challenge also tested exact substitutions in D1: `if True then`, `if (Len + 1) <= 6 then`, and a stored `Room : Boolean := Len < 6;` used as `if Room then`. All rejected, respectively in `20261118T023309-744191059-plan-try-b767b8`, `20261118T023310-862168934-plan-try-9811d6` and `20261118T023311-975138268-plan-try-ece6fe`, each `check[head] exit=2 reject: Rejected: source is outside the Silver catalogue.` These results confirm the documented refinement boundary; they do not motivate a new rule in this batch.

## Implementation and assurance obligations

No native helper, SPARK contract, Lean statement, source certificate, report policy or runtime import is new or changed. The delivery must establish that this remains true on its actual inputs. Reuse the following existing machinery and its complete applicable evidence:

| Layer | Reused files and obligation |
| --- | --- |
| Native admission and contracts | `src/silver_output_profile.adb:743–824` supplies Indexed_At's index/slice checks and SPARK domain/progress contracts; `826–881` supplies Character_At; `5988–6040` dispatches typed writes and equal-length String assignment. `src/silver_scalar_expressions.ads:83–99` supplies the scalar reader contract; `src/silver_scalars.ads:49–69` supplies threshold refinement. No new “buffer” recognizer is needed. |
| Integer Image | Reuse `src/silver_image_adapter.adb` and `proof/Silver/ImageProducerEndpoint.lean`, `ImageRefinementEndpoint.lean` and `ImageConsumerEndpoint.lean`. Their native contracts, exact theorem installation, source refinement and original-vendor ordering remain required for D3 (`docs/assurance.md:1220–1234`; `docs/trusted-boundary.md:540–549`). No adapter or formatting change is planned. |
| Element/slice semantics | `proof/Silver/StringIndexing.lean:19–27,57–75,139–162`: indexCheck_sound, sliceCheck_sound, sliceCheck_nativeSpan, replace_length, replace_same, replace_other and replace_printable. `proof/Silver/CharacterExpressions.lean:67–120` connects checked Character expressions with safety, printable bytes and evaluation. |
| Scalar and loop composition | `proof/Silver/ScalarFlow.lean`, `IntegerMutable.lean`, `PredicateStatements.lean` and `PredicateExecution.lean` supply refinement, assignment, captured-loop bounds, widening and execution composition as documented in `docs/assurance.md:619–667`. These are existing compiler proofs, not annotations to put in samples. |
| Authoritative source | `proof/Silver/PredicateStringAssignmentMeaning.lean:94–102` connects accepted writes to well-formed checked assignments; `PredicateStringActualAssurance.lean:127–134` exposes source_actual_string_bounds_assured. `PredicateSourceChecks.lean`, `PredicateSourceBridge.lean` and `PredicateCorrespondence.lean` retain actual-source, interpreted-source and executable-wrapper dependencies (`docs/assurance.md:699–753`). No pin-only update can substitute for this chain. |
| Automatic discharge and output | `proof/Silver/PredicateObligations.lean`, `PredicateChecks.lean` and `Current.lean` cover all required source schemas and automatic-discharge endpoints under the existing ToolContract (`docs/assurance.md:1111–1174`). Reuse `src/silver_io.ads:18–36`, `src/silver_io.adb`, `src/silver_output_libc.ads`, and `proof/Silver/OutputRuntime.lean`/`SequenceEffects.lean` for guarded output and sticky failure (`docs/assurance.md:975–1004`; `docs/trusted-boundary.md:759–821`). |

Keep complete Bronze/Silver compiler/runtime assurance, every application obligation, report coverage, source identity and the Lean actual-source/module/axiom audit. Retain existing external assumptions (`docs/trusted-boundary.md:40–52`). Sample output does not establish those universal guarantees.

Capacity account:

- **Source/expression:** retain 4,096 source bytes including comments/whitespace, 64 leaves per applicable expression and 63 shared arithmetic/concatenation operators. Indexed target and RHS budgets are independent; slice leaves include both endpoints. No limit is increased for a sample (`language.md:91–95,747–750,765–766,1053–1055,1108–1146`).
- **Storage:** use literal-initialized 13-cell, 12-cell and 20-cell sample buffers, plus the small boundary fixtures. Physical storage never grows with Len; prepend shifts existing cells. The existing source-derived tables have 341 String-binding slots and 585 scalar slots (`language.md:268–280`). No new buffer pool or allocation is introduced. The 4,096-byte value bound is not a universal stack/heap or solver-time guarantee (`docs/trusted-boundary.md:832–846`).
- **Reports:** reuse index, range, length and overflow channels and existing exact advisories. The String/Character account charges slice/index sites and nested-loop initialization advisories to existing source budgets (`docs/bounded-string-characters-report-capacity.md:25–102`). Its historical 32 MiB allocation is not today's global allocation: the current combined envelope is **49,279,744 bytes** within **67,108,864 bytes**, with **17,829,120 bytes** headroom (`docs/scalar-procedures-report-capacity.md:239–249`). This samples-only subset adds no source form, record class or multiplicity, so no revised envelope is planned. Observed small reports are not a replacement for that account.

If an admitted sample fails proof, auditing or build, preserve the failure as a defect. Diagnose it under the existing workflow; do not narrow the declared domain, change a diagnostic policy, suppress a check or silently turn this batch into a compiler repair (`oracle.md:13–14`; `development.md:162–179,331–337`).

## Increments

### 1. Deliver the four samples and reconcile their assessments

[#400](https://github.com/berkeleynerd/silver/issues/400) owns the whole batch and its shared final validation/review checkpoint. No separate final issue is needed for a single increment.

**Owned files:**

- New `samples/rosetta_string_append.adb`, `samples/rosetta_string_prepend.adb`, `samples/rosetta_99_bottles_of_beer.adb` and `samples/rosetta_repeat_a_string.adb`; their entries in `samples/manifest.json`.
- `tests/test_string_characters.py` for retained B1/B2-style full-route boundary coverage and the existing slice-placement controls as needed. Reuse the manifest runner in `tests/test_samples.py`; change its code only if a demonstrated need arises, not to weaken auditing or expected-byte comparison.
- `rosetta/coverage.json` for the four delivery mappings and targeted corrections for the eight further probed tasks; `rosetta/assess.js` for the precise identifier and current-language explanation; `rosetta/refresh.py` for `ADMISSION` and `SURFACE_LABELS` registration of bounded-string-building. Use a registry description of the existing initialized-buffer, guarded-store, counted-copy/shift and filled-prefix idiom, including unchanged refusal when full. Reuse the affected checks in `tests/test_rosetta.py`. Render `rosetta/progression.md` and affected generated task `silver.md` pages through `rosetta/refresh.py --render`, not independent edits.
- `docs/bounded-string-building-samples.md`, `roadmap.md` and explanatory sample links in `language.md`. Reconcile catalogue/specification/manifest consistency together. Reuse existing catalogue construct IDs, including string_element_assignment and string_slice; the hyphenated Rosetta identifier is not a new catalogue admission rule (`tests/test_samples.py:73–81,102–123`; `catalogue/silver.json:1339–1394`).
- The batch's ordinary evidence and independent review records under `docs/evidence/` and `docs/reviews/`, linked from this record; existing issue/roadmap bookkeeping for #395 and every existing stage issue affected by the final render. Preserve issue status and authorization; closed issues whose constructs are supported carry Stage 1 and remain Closed/Done (`docs/planning.md:214–220`). No new runner or evidence format.

**Assessment corrections, limited to measured claims:**

| Further probe task | Correction and evidence limit |
| --- | --- |
| S1 Character codes | Preserve the probe's isolated `Character'Pos` refusal and Integer-literal control; `Character'Val` was not separately isolated. Add the challenge's executed lookup-table alternative for both directions over printable ASCII 32 through 126, independently rerun by the finalizer below. Character attributes remain excluded (`language.md:719–723`), but this bounded task no longer has an unresolved conversion blocker. It is an assessment correction, not a fifth delivered sample or a new general-conversion identifier. |
| S2 Array length | String array components reject; array Length separately rejects. Integer-array counting admits but does not solve the required String-array example. Padding must not change the task's text values (`language.md:772–801,858–862`; probe S2-a–f). |
| S3 Numeric separator syntax | Candidate admitted; no execution was requested. Do not retain a missing string-building explanation or present this as delivered application evidence (probe S3-a). |
| S4 Apply a callback to an array | Candidate calls an actual scalar function per element and admits. The task does not require first-class callback parameters. Execution remains unmeasured (probe S4-a; `rosetta/a/apply-a-callback-to-an-array/task.wiki:4–5`). |
| S5 Ones followed by 3, squared | The direct wide-integer approach rejects; the required larger Integer square also rejects. Required n remains 0 through 7. Alternative digit/multiword algorithms were not explored (`language.md:286–294`; probe S5-a–e). |
| S6 Selection sort | Candidate admits with bounded scalar indexes and includes negative/duplicate values. It has admission evidence only, not a new delivered sample (probe S6-a). |
| S7 Taxicab numbers | `others => 0` is the isolated first refusal; explicit expansion also exceeds the documented source-derived 2,048-component capacity. Correct the sum bound to 810448 for 74 cubed plus 74 cubed; the full numeric result and claimed 25th-number bound remain unmeasured (`language.md:796–818`; `rosetta/t/taxicab-numbers/silver.md:9–14`; probe S7-a–c). |
| S8 Decreasing contiguous subsequences | The full 901-value candidate admits and runs, producing bins 7, 6, 4, 2, 2, 0. Preserve that measured scope and its 3,855-byte source size; it is not an additional sample deliverable in this batch (probe S8-a, run `20261118T021000-631616188-plan-try-200bb9`). |

The original further-task observations above come from the upstream probe; the Character-code lookup result below is additional challenge/finalizer evidence. These are its retained admission result lines; exit 0 is admission only unless an execution is separately recorded:

```text
S1-b 20261118T020846-027091486-plan-try-40a680 check[head] exit=2 reject: Rejected: source is outside the Silver catalogue. sha=0a6b31a3a8b7
S1-c 20261118T020858-673882658-plan-try-0d6be0 check[head] exit=0 accept: Accepted: silver. sha=1e9dfe73e625
S2-b 20261118T020859-785431242-plan-try-8d45e2 check[head] exit=2 reject: Rejected: source is outside the Silver catalogue. sha=71ce0613d488
S2-c 20261118T020900-894913243-plan-try-897c15 check[head] exit=0 accept: Accepted: silver. sha=bd1420217b0d
S2-d 20261118T020901-005884035-plan-try-1fea29 check[head] exit=2 reject: Rejected: source is outside the Silver catalogue. sha=b9221dc57b33
S2-e 20261118T020903-120904744-plan-try-3690ab check[head] exit=0 accept: Accepted: silver. sha=700a9b89cb85
S3-a 20261118T020730-483823033-plan-try-8ebb9f check[head] exit=0 accept: Accepted: silver. sha=c4d0fadbbccb
S4-a 20261118T020731-596550784-plan-try-0b2364 check[head] exit=0 accept: Accepted: silver. sha=82ca18c3acaf
S5-b 20261118T020904-236718703-plan-try-7bac8f check[head] exit=2 reject: Rejected: source is outside the Silver catalogue. sha=6e97cad68a6b
S5-c 20261118T020905-353150828-plan-try-9ad271 check[head] exit=0 accept: Accepted: silver. sha=c54cc29b2f90
S5-d 20261118T020906-467163912-plan-try-366109 check[head] exit=2 reject: Rejected: source is outside the Silver catalogue. sha=32ae7216b87b
S5-e 20261118T020907-582276788-plan-try-7b3e4f check[head] exit=0 accept: Accepted: silver. sha=748722b17803
S6-a 20261118T020733-827821826-plan-try-3e4f2f check[head] exit=0 accept: Accepted: silver. sha=b6c06e0c7ba7
S7-b 20261118T020908-695186622-plan-try-954aed check[head] exit=2 reject: Rejected: source is outside the Silver catalogue. sha=5b92dbcb2049
S7-c 20261118T020910-805026414-plan-try-78e086 check[head] exit=0 accept: Accepted: silver. sha=7d34c4b86a90
S8-a 20261118T020736-063709869-plan-try-96fa2c check[head] exit=0 accept: Accepted: silver. sha=8e96a9cee0e6
```

The probe's four primary refusals originally tied at one task each. Preserve that measured history, but no longer count S1's attribute refusal as a remaining blocker for the bounded task: its lookup-table alternative now runs. S2, S5 and S7 still have rejected approaches; these do not prove the tasks impossible by every algorithm. Preserve original assessment attribution and add dated review evidence distinguishing admission-only, executed, blocked approach and unassessed alternatives. Do not replace every broad tag automatically, promote the eight tasks as delivered, or count all 157 as gained. Map 99 bottles through existing loop/Image/output identifiers; map only actual buffer-building uses to bounded-string-building.



**Character-code alternative added after challenge (C2).** The task requires both character-to-code and code-to-character output (`rosetta/c/character-codes/task.wiki:8–14`). The challenge's single-character table search produced ` 97\na\n`, with admission `20261118T023124-383377217-plan-try-f430c8` and full run `20261118T023124-444899134-plan-try-7ec799`, compiler/GNATprove/execution exit 0, empty stderr, source sha `dca6518550ce`. The search computes the answer from the Character; it does not print a precomputed code.

The following complete variant exercises all 95 printable Characters and codes. Its indices infer `1 .. 95`; `I + 31` fits `32 .. 126`. Typed Character comparison selects the matching table cell, and a one-cell String supplies output (`language.md:365–373,738–767`). It uses no conversion attribute:

```ada
with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Codes : constant String := " !""#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
   Letter : Character := 'a';
   Found : Integer range 32 .. 126 := 32;
   Text : String := " ";
begin
   for Code in 32 .. 126 loop
      Letter := Codes ((Code - 31));
   for I in 1 .. 95 loop
      if Codes (I) = Letter then
         Found := (I + 31);
      end if;
   end loop;
   Text (1) := Codes ((Code - 31));
   Silver_IO.Put_Line (Integer'Image (Found) & ":" & Text);
   end loop;
end Main;
```

```text
Challenge full-domain run, sha=e8b832b8cd56:
20261118T023316-324065854-plan-try-698e7d check[head] exit=0 accept: Accepted: silver.
20261118T023316-388064520-plan-try-bf8431 full stage=ran :: Executable published
compile exit=0; gnatprove exit=0; run0 exit=0; stderr=''

Finalizer independent rerun of the same source, sha=e8b832b8cd56:
20261118T023905-488453062-plan-try-6e80ff check[head] exit=0 accept: Accepted: silver.
20261118T023905-549479145-plan-try-e1d8b1 full stage=ran :: Executable published
compile exit=0; gnatprove --mode=all --warnings=continue --checks-as-errors=on exit=0
run0 args=[] exit=0 stdout_match=None stderr=''
```

The finalizer read the complete retained stdout and compared it independently with the ASCII sequence: exact match, 95 lines and 597 bytes, from ` 32: ` through ` 126:~`. The try service itself supplied no expected-output comparison. The full route also reported an `INEFFECTIVE` flow advisory for Letter's overwritten initializer; it still completed successfully. No result is claimed for nonprintable codes or Unicode. Retain the direct-attribute rejection, original assessment attribution and dated review evidence alongside this successful alternative.

**Focused checks and completion criteria:**

1. Review all four primary tasks against the exact committed sources and declared domains. Keep real buffer mutation and full refusal in append/prepend; keep the complete lyrics, Image spacing and repeat-five result.
2. Admit, prove/audit, build and execute every new sample with independent exact stdout, stderr and exit expectations through the existing manifest route (`tests/test_samples.py:63–142`). Compare the entire bottles output, not the 600-byte try preview. Recheck unchanged author bytes.
3. Exercise empty, one-free-cell/exact-fit, full unchanged refusal, logical clear/reuse, reverse-shift order and Count 0/5/10. B1/B2/B3 provide concrete boundary sources; retain B3's bounded repeated-prepend case to detect wrong shift direction. Keep the neighboring conditional-slice rejection and after-conditional acceptance under existing rules. These fixtures test semantics and composition, not a new admission mechanism.
4. Correct the targeted assessment source records and register bounded-string-building in the renderer before adding it to supported coverage. Require a successful integrated `rosetta/refresh.py --render` with that identifier and run the affected Rosetta checks. Inspect the generated changes and reconcile the Stage field of every affected existing stage issue, open or closed, from the final render. Closed issues whose constructs are supported carry Stage 1 and stay Closed/Done; preserve all other status and authorization (`docs/planning.md:214–220`). Only the four reviewed sample mappings are delivery commitments. Keep broad string-building unsupported and #395 open for its remaining broad scope; update its description/Constructs/Stage from the actual reconciliation.
5. Complete the single combined checkpoint below and obtain independent review of task fidelity, full-buffer behavior, assessment claims and final evidence applicability. Record actual mappings gained, delivery elapsed time, failures/interruption and expensive checkpoint attempts as `docs/planning.md:157–162` requires.

**One shared final validation and review checkpoint:** freeze the combined sample, manifest, assessment and evidence inputs. Cover the complete final regression/sample inventory through the ordinary full-suite or independently reviewed reuse provision; newly added or affected cases require successful final-input results (`development.md:283–322`). Run affected sample/boundary checks and `test_rosetta.py` during iteration via the existing managed test runner; final validation must account for their integrated versions.

For unchanged compiler/runtime/proof/audit inputs, verify and reuse complete applicable native and Lean/source checkpoints, with every required fresh audit. Do not rebuild all source certificates solely for adding samples. This follows the delivered samples-batch precedent (`docs/scalar-function-rosetta-batch.md:482–499`) and invalidation matrix (`docs/proof-iteration.md:135–157`). A new sample always needs its own application proof/audit/build/execution. Any changed governed input or missing applicability requires the corresponding complete checks under `development.md:162–215,283–314`; expected reuse does not excuse them. On Linux ARM64 retain the documented 16 MiB invoking stack and record actual host/settings (`development.md:297–301`).

Independent closing review identifies the reviewed inputs, fresh versus retained evidence, all material finding dispositions and any remaining work. Complete the sample issue only when all criteria pass; do not close broad #395 merely because these four samples work. No additional release gate, approval ceremony or mandatory cold/replay run is proposed.

## Risks and open decisions

- **Owner selection and naming:** the development request authorizes this single samples-only work package and the metadata-only bounded-string-building identifier. It chooses no successor queue order; preserve #373 recovery and the PR #385 hold.
- **Breadth of the literal drivers:** the owner amendment supersedes the original single-character recommendation. Deliver the two fixed several-character literals with a whole-literal fit check, exact fit and unchanged refusal. Arbitrary-source buffer helpers remain outside this work package.
- **Evidence availability:** the supplied planning checkout omits retained `docs/evidence/` packets. The cited delivery records identify past checks, but exact applicability to the future combined snapshot is **not found** in this planning pass. Retrieve and compare those inputs during delivery, or run the necessary checks. Do not present this plan or its planning challenge as an independent completed delivery review.
- **Formatting and boundaries:** moving dynamic prefix output into a conditional changes admission; static narrowing can also make a loop body fail the existing nonempty-index rules. Preserve checked forms and verify boundary fixtures instead of assuming that all textually similar rewrites work (`language.md:738–745,953–978,1082–1090`).
- **Coverage and rendering:** only four driver deliveries are promised. S3/S4/S6 lack execution results. S1 now has both a rejected attribute approach and an executed printable lookup alternative; S2/S5/S7 retain rejected approaches, not impossibility. Neither S1 nor S8 commits an extra sample. Planning performed no render or board operation. The implementation handoff above now records the successful integrated render, exact gains and unchanged existing construct Stage values. Live issue/card reconciliation remains for after merge under the operator's instruction.
- **Next planning target, recommendation only:** withdraw Character-code conversion as the recommended missing capability for S1. The measured lookup-table solution already meets the bounded task; direct Pos/Val would be a possible convenience requiring its own justification. Recommend a separate feasibility probe for S2 Array length, whose required `apple`/`orange` String-array example remains unmet by the measured candidates (`rosetta/a/array-length/task.wiki:5–8`; probe S2-b–f). First seek a faithful current-language alternative; only then settle whether String components or an array query need new admission. The owner chooses whether and when to investigate it. This recommendation creates no additional issue, sample, language change or authorization in this batch.
- **Challenge disposition:** adopt C1 by owning the renderer registration and requiring an integrated render; adopt C2 by retaining both the attribute rejection and the executed lookup alternative, and revising the successor recommendation; adopt C3 by reconciling every affected existing stage issue. No required challenge change is rejected. The remaining uncertainties are delivery-evidence applicability and actual render/board results, addressed by the checks above.
- **Oracle:** no amendment is needed for this samples-only route. Any defect or scope change must preserve the existing all-program, same-source and automatic-discharge guarantees (`oracle.md:1–19,24–29`).

The planning finalizer read the scope, probe, draft, issues, challenge and cited source/policy, applied all three required changes, and independently reran the challenge's full-domain Character-code program with silver-try. B1/B2 are inherited drafter runs; B3 and the guard substitutions are inherited challenge runs. That planning pass performed no compiler implementation, standalone prover/Lean/test/render run, board operation or repository publication. These observations are planning evidence, not delivery assurance or implementation authorization. Live model/effort confirmation and total token/cost measurements are unavailable.
