# Unbounded programs

**Capacity derivation deferred 2026-10-24.** The owner
[deferred](session-memory.md#2026-10-24--capacity-derivation-119-deferred-language-development-resumes)
the full #119 derivation after an
[independent assessment](evidence/119-sequencing-assessment-20261024/README.md);
language development resumes at the current 4,096-byte strict language, and
#88–#94 are re-sequenced as the later strict/loose
[assurance-modes](https://github.com/berkeleynerd/silver/pull/147) milestone.
Accepted #119 evidence is frozen at R92 (`f1920759b1`, draft PR #121, unmerged).
The design below remains the production design for the compiler, confirmation
and outcomes; its statements that #119 must complete before expanded admission
describe strict mode, whose rule #119 still defines, not the loose-mode route.

**Revised direction adopted 2026-10-17; capacity design in progress.** Retain
the existing GNAT/GNATprove toolchain and remove unnecessary Silver limits
within explicit, justified tool-capacity rules. The owner's
[instruction](session-memory.md#2026-10-17--retained-tool-capacity-direction-adopted)
resolves [decision #117](https://github.com/berkeleynerd/silver/issues/117).
External compiler support, a private fork and replacement frontends are no
longer prerequisites. The Oracle is unchanged.

[Work package #119](https://github.com/berkeleynerd/silver/issues/119), under
#91 and shared with #93, owns the unfinished source-sensitive capacity derivation.
Its [design contract](research/retained-tool-capacity.md) separates reusable
arithmetic from missing whole-program upper bounds. A representation obstruction
is not a safe admission threshold. Current support remains exactly
[language.md](../language.md) and the [catalogue](../catalogue/silver.json);
production packages #88–#94 are authorized and unstarted, pending the justified
capacity rule.
No arbitrary lower cap or new tool pin has been selected.

Completed research #107/#108 and #113, delivered through
[PR #109](https://github.com/berkeleynerd/silver/pull/109) and
[PR #116](https://github.com/berkeleynerd/silver/pull/116), retains its evidence
and review scope. The earlier recommendation to obtain external paired support
is superseded by the [disposition below](#frontend-representation-result-and-owner-disposition).
The [original review](reviews/review-ec82b4e5f2.md) and
[planning repair record](review-ec82b4e5f2-repairs.md) remain historical records.
Neither research closure nor this direction change establishes a larger language.

**Assurance modes (2026-10-19).** The owner adopted in principle a strict/loose
split, recorded in [assurance-modes.md](assurance-modes.md) with its proposed
Oracle amendment: strict programs prove by construction under the derived
capacity rules; loose programs beyond them compile only when their own proof run
succeeds. This scope's design sections remain the production design for the
compiler, confirmation and outcomes; the modes record states which of the limits
below loose mode may raise and which are hard in both modes.

## Goal and owner direction

The owner wants Silver without "unadjustable or unnecessary arbitrary limits"
and "the most expansive, expensive, and best option research can prove is
tractable in every case", without option menus, with any full stop reported.
Compilation should "fail through resource exhaustion, which is acceptable in
this profile, rather than a safe lower limit with a thousand knobs unless that
is truly the only way". Retain inherited Ada/SPARK meaning and necessary
pinned-tool rules; justify a conservative envelope instead of calling every
sufficient bound a tool maximum. The revised disposition explicitly accepts
representation boundaries in the unchanged tools. `Integer'Last` remains an
inherited ceiling, not a promise to admit every composition of values below it.

The owner also directed that, once the compiler's assurance is established,
running GNATprove on each program "should be nothing more than a safety check
with any failure a bug report". The proposed architecture makes compilation
verified admission plus build, with non-gating proof confirmation. It changes
the evidence collected before publication, not the universal guarantee or the
obligation to verify all Silver-owned implementation code.

The [Oracle](../oracle.md) requires "If it compiles, it proves", automatic
discharge of every required obligation, explicit decidable membership,
same-source correspondence and assurance for every admitted composition. It
approves Lean for completeness of automatic discharge; safety alone is not
proof success. No Oracle amendment is needed merely to separate confirmation
from build, provided those requirements and the explicit external premises are
retained. An inhabited tool-contract model does not verify the physical tools.

The operational aim is to remove unnecessary Silver-chosen size/resource caps.
Under faithful, functioning tools and services, remaining capacity failures
should be resource outcomes. Tool defects, rejected admitted source, invalid
configuration, identity drift and ordinary infrastructure failures remain
possible non-resource failures. They are reported as defects, not hidden by an
unconditional promise that only exhaustion can occur. Research does not prove
universal pinned-solver completion; it remains a [trusted premise](#trusted-premises).

## Full stops

- **Authorization.** Record the owner's implementation "proceed" on `main`
  before claiming implementation work, following [planning](planning.md).
  The owner has authorized #88–#94 after the capacity rule is justified; #119
  is the current dependency, and no production package is claimed yet.
- **Assurance.** A definite non-proof with resources remaining is a defect.
  If it cannot be fixed, stop and report it for the owner's decision; do not
  silently weaken assurance or introduce an assurance-motivated membership rule.
  Removing the per-program gate does not resolve solver completeness.
- **Frontend/source capacity.** #91 must derive a sound explicit capacity rule
  and justify it against the owner's expansiveness requirement. A uniform
  worst-case source bound is a candidate, not an established uniquely necessary
  maximum. Compare a plausible source-sensitive alternative, or document why
  the envelope is the best tractable choice. If no justified rule can be
  established, report that stop before #92 removes the existing source cap.
- **Large static data.** #93 must investigate frontend, object-format and linker
  acceptance of static String data approaching the proposed value domain before
  fixing that domain. Derive explicit source-sensitive restrictions under the
  selected unchanged-tool route, coordinating #119/#91. A failure on admitted
  source is a defect; a demonstrated representation obstruction can justify a
  proposed pre-admission restriction, never an arbitrary lower cap. Begin with
  source analysis and cheap discriminating probes; a multi-gigabyte experiment
  is conditional on its concrete hypothesis and host resources.
- **Unresolved tool behavior.** Verify confirmation configuration and named
  producer boundaries before depending on them. An ambiguous failure is a
  defect report pending diagnosis, not evidence that a new language cap is needed.

The research's proposed escalation ladder is replaced by uncapped racing
confirmation. The tool-derived lexical rules are explicit pre-1.0 language
changes, not Oracle amendments. Neither choice proves future tractability or
resolves the conditional stops above. An implementation authorization accepts
this research plan, not an unestablished derivation or a weakened guarantee.

## Research conclusion and next decision

The #107/#108 continuation identifies a representation obstacle in the inspected
GNAT 16.1 frontend. Two live, disjoint constant Strings of length 2^30 each fit
the intended per-value `Integer'Last` bound, but together require at least 2^31
characters in a signed-Int-indexed frontend character pool. The pinned-tree
lifetime audit closes the earlier reclamation question. This is a source-derived
argument under the recorded tool/source correspondence premise, not a giant
native failure run. The default allocation-growth recurrence is another concern,
but compiler build switches prevent treating it as an exact measured native cutoff.

Linux Ada probes with a 1 MiB final String compiled, bound and linked using
medium and large code models. They strengthen the earlier backend evidence;
they do not solve the frontend materialization limit or establish full-domain
build feasibility. The [result](research/unbounded-feasibility-result.md)
keeps those observations, the retained macOS evidence and the lifetime argument
separate. Independent review is complete, with no remaining material finding;
the review record preserves the two corrected wording findings.

No complete whole-program source-capacity rule was derived. Physical and
virtual source-position accounting has a reproducible recurrence, but every
construct's allocation and expansion across compiler phases still lacks a
closed cost argument. A source-sensitive capacity vector is preferable to a
uniform worst-case byte cap if the frontend pin is retained: it can distinguish
sparse source from dense syntax and semantic expansion. It still needs the full
soundness argument and would exclude some intended otherwise valid compositions.
The source-sensitive direction is now selected; no complete predicate or
numeric envelope is adopted. Incompleteness is not proof that no tractable rule
can exist.

The owner resolved [decision #112](https://github.com/berkeleynerd/silver/issues/112)
by authorizing the research-only investigation below. This follows the
expansiveness direction without establishing tractability or authorizing a
production toolchain change. The later #117 disposition selects retaining the pin with justified aggregate
restrictions; it does not select a numerical lower cap. Implementation #88–#94 remains unstarted. Publication of the reviewed
#107/#108 stop did not complete #91, #93 or milestone 5.

## Frontend representation feasibility research

This is the historical scope of completed research #113. The owner's
[research-only instruction](session-memory.md#2026-10-17--frontend-representation-feasibility-research-authorized)
selected one cohesive [work package #113](https://github.com/berkeleynerd/silver/issues/113).
Parallel analyses contribute to this one deliverable; they are not separate
implementation increments. The research covers:

- Available upstream and off-the-shelf alternatives: relevant releases,
  development branches, patches and packaged toolchains, with exact evidence
  for what exists and what remains an untested proposal.
- Concrete wider and deferred/lazy representations: the Ada and C/C++ table,
  index, descriptor, growth, constant-consumer and lowering interfaces, plus
  the actual GNATprove producer path. Changing one generic index parameter is
  not assumed to widen every dependent representation.
- Static evaluation and legality, runtime meaning and same-source assurance:
  identify the semantic/correspondence and automatic-discharge obligations for
  each candidate, without substituting a different author source or accepting
  an unproved larger-language guarantee.
- Ownership and trust: distinguish external compiler dependencies from
  Silver-owned compiler/runtime work under the verified-SPARK rule. Identify
  actual policy conflicts or required Oracle amendments explicitly; calling
  a maintained fork external does not establish an exemption.
- Linux and Alire integration, distribution and maintenance constraints,
  with macOS constraints and evidence recorded independently. Native macOS
  validation remains nonblocking for the Linux research result.
- Proportionate isolated experiments for named unresolved hypotheses, after
  source inspection and retained evidence. Record inputs, tool identities,
  resource safeguards and outcomes; preserve failed and successful evidence.

Completion requires a reproducible comparison and concrete recommendation,
the relevant interfaces and obligations, a reasoned tractability assessment
or precise full stop with alternatives, independent review and dispositions,
publication, and a parent/scope handoff. A promising sketch alone is not the
deliverable. The conclusion must distinguish source facts, native observations,
derivations and premises; it does not claim production readiness or universal
assurance for a changed frontend.

That research authorization included tracking, documentation, commits and
publication, and excluded production changes, pin or membership adoption and
#88–#94. The newer retained-tool direction above supersedes its recommendation;
its technical evidence is preserved. No new harness goal was requested.

## Frontend representation result and owner disposition

The [#113 result](research/frontend-representation-result.md) identifies checked
64-bit shared String-pool storage, matching Ada/C descriptors and a zero-mantissa
scanner optimization as the smaller concrete frontend candidate. It preserves
the existing static-evaluation route. Deferred immutable storage can share
repeated values earlier, but needs a wider interface and assurance redesign.
Neither design is implemented, and the component arithmetic does not establish
complete source/phase accounting or whole-language tractability.

The reviewed stop applies to the originally proposed full composition domain:
no inspected external pair supplies the proposed widening, and the inspected
GNATprove literal route has a separate per-character Why-node limit. These
source-derived findings remain valid with their source-correspondence premises.
They are not native near-limit failures or safe admission thresholds. The
inspected SPARK snapshot is not established as the installed archive's exact
source commit.

The owner has selected the other route through
[decision #117](https://github.com/berkeleynerd/silver/issues/117): **retain the
unchanged tools and derive explicit capacity restrictions before admission**.
The absence of external widening support therefore ceases to block this plan.
No compiler fork, upstream adoption, maintainer contact or replacement frontend
is required. The full originally proposed value/composition domain changes;
current supported language does not change at this checkpoint.

[Capacity design #119](https://github.com/berkeleynerd/silver/issues/119) must
account for retained and temporary values, compiler-generated data, dependencies,
phase-specific duplication, representation arithmetic and allocation growth.
A per-String bound alone is insufficient. Its output must justify a decidable
rule, preferably by program structure; any conservative envelope needs a
reasoned comparison. An unfinished component or reviewed research stop does not
unlock expanded admission in #92/#93.

Both build and proof-essential producer representations belong in the capacity
argument. Non-gating confirmation cannot waive required obligation generation
or automatic discharge. An admitted program exceeding such a representation
is a defect even if the build succeeded. Physical resource exhaustion is a
separate operational outcome. A documented capacity restriction does not itself
require an Oracle amendment.

[Independent review](reviews/review-frontend-representation-0af844fb85.md) of
frozen #113 target `0af844fb85b48155b38f237a5437bc27f71e8563` remains complete;
low finding #115 was repaired at `042e35c40c62997544a11abb44f4169f12d0f1bd` and
independently verified. PR #116 merged as `11af48017a`. That review certifies
its historical research scope, not the new capacity design. #119 and all
production packages remain incomplete; milestone 5 is open.

## Design

### Compilation and confirmation

| Step | Role | Failure meaning |
| --- | --- | --- |
| Admission | Verified, decidable membership by explicit rules | Status 2 only for nonmembership or usage; read/allocation failures are operational outcomes |
| Build | Compile the admitted bytes with the identity-bound runtime through GNAT/GPRbuild | Defect 3 for non-resource failure; 4 for attributable resource exhaustion |
| Confirmation | GNATprove analysis and proof of the exact build inputs, followed by the outcome policy below | Never removes the executable or changes the recorded build result; reports confirmation separately |

- `silver compile` admits, builds and prints the executable path, then confirms
  unless `--no-confirm` is given. Its normal return reflects build success;
  a confirmation defect or inconclusive result is reported separately.
- `silver run` admits, builds and executes without confirmation. Its completed
  child application's exit status is forwarded unchanged.
- `silver confirm WORKSPACE` verifies the build-input witness before rechecking
  admission and confirming the inputs of that completed build. #88 retains that
  witness for Main, the selected library bytes and project configuration, checks it before and after
  GNATprove, and checks library identity against the compiler. Comparing only
  two reads in this later invocation does not identify the earlier build input.
  Missing or mismatched witnesses, including a modified snapshot that is no
  longer a member, are identity defects (3), not a fresh source rejection (2).
  Stable, private workspaces and faithful build tools remain premises; this is
  not executable attestation or
  protection against an adversary rewriting the workspace and its witness.
- Confirmation retains the source-selected `-U` project: output shells select
  Main and six runtime files, with Main plus all four library-unit reports.
  The null shell retains its exact Main-only project/report policy.
- Confirmation has no time limit. An explicit interrupt terminates its children
  and reports not confirmed. A previously established defect is not erased by
  interruption. Normal interrupted confirmation leaves the build result intact;
  an uncatchable death of the driver itself is a separate environmental termination.

`Publish` will require admission, build and identity evidence. Reporting
Confirmed will require the complete strict successful-proof audit. Bootstrap
binds runtime bytes by embedding them; it is not library proof. The selected
library implementation retains its complete Bronze/Silver verification and
confirmation includes its required reports. Keep `automatic_pipeline` and
`admitted_assurance`; add a build-only Lean endpoint with preservation,
realization and fixed-library evidence without substituting it for automatic
proof-completion assurance. No new project-specific axiom is authorized.

Runtime `-gnata -gnato` checks remain. They detect the runtime conditions they
cover; they do not detect every semantic, producer or compiler defect, replace
proof, or guarantee that an incorrectly built program cannot misbehave.

### Outcomes and exit statuses

Driver statuses apply before application execution and to standalone confirmation:

| Status | Meaning |
| --- | --- |
| 0 | `check`: admitted; `catalogue`: exported; `compile`: admitted and built; `confirm`: Confirmed |
| 2 | Nonmembership under an explicit rule, or usage error |
| 3 | Defect: non-resource tool/implementation/infrastructure failure, or insufficient evidence to attribute an unsuccessful tool phase |
| 4 | Attributable compiler/tool resource exhaustion; for `confirm`, also explicit interruption or a detected, independently justified observation-only boundary |

Once `run` starts the application, its normal exit code belongs to the application,
including 0, 1 or any value colliding with driver statuses. Exit 1 can mean Reject,
output failure or unhandled `Storage_Error`; do not infer its cause or translate
it to 4. A directly observed application signal termination is reported separately
and translated by a documented platform-specific CLI convention, not guessed from
an ordinary exit code such as 137. #93 raises the application's stack allowance
as for tools and documents that direct executable invocation inherits caller limits.

#88 specifies observations and their limits across admission, GNAT, gnat2why,
gnatwhy3, Why3/provers, the Image adapter, report I/O, GPRbuild/linker and Alire:

- Use growable argument vectors/process observations, preserving quoting and
  command identity. Decode directly observed wait statuses and failed exec
  errors; an outer shell/Alire exit cannot recover a grandchild's signal.
- Read `errno` at the failing owned I/O/process boundary for causes such as
  `ENOSPC`, `EFBIG`, `ENOMEM`, `EMFILE` and `E2BIG`; preserve operation/phase context.
  Add compiler/Image-adapter `Storage_Error` handlers. Other exceptions are not
  automatically resources.
- Attribute a tool outcome using its explicit resource answer or a phase/process
  observation that identifies the cause. A signal number alone, `High failure
  (signaled)`, a host-wide OOM counter, or generic exit 1/137 does not establish
  resource exhaustion. `SIGKILL` can have other causes. Ambiguous failures use 3.
  An unexpectedly binding Silver-configured cap is a configuration defect,
  even if the tool describes its result as a step/time/memory limit.
- Cover producer/translator failures before report generation and report-writer
  or reader failure, not just prover attempts. Identify a named producer limit
  only through a validated detection rule. Classify a proof-essential representation
  failure as a defect; a reporting-only boundary needs the independence argument
  below before it may be Inconclusive. An unexplained crash remains a defect.
- Either supervise the driver to preserve directly observed termination evidence,
  or document its uncatchable environmental deaths. A supervisor cannot recover
  every cause from a signal; uncaught termination need not return driver status 4.
- List new libc/process imports and assumptions in `docs/trusted-boundary.md`.

For confirmation, use this decision order:

1. Preserve the source/build witness and available phase/process evidence. Read
   complete usable reports even when GNATprove exits normally with nonzero status
   because checks were unproved. That exit alone is not a defect or an instruction
   to skip report analysis. Unexplained nonzero exits remain defects.
2. Check unsuccessful evidence separately for structure, identity, provenance,
   coverage and permitted diagnostics. An expected unproved safety record is not
   itself a structural defect. Missing/truncated evidence caused by an observed
   interruption, attributable resource stop or justified observation-only boundary is incomplete,
   not automatically malformed; unrelated malformed or inconsistent evidence is a
   defect. Record what coverage could and could not be checked.
3. For each check, any Valid attempt proves that check; a losing Unknown, crash or
   resource failure does not override it. With no Valid attempt, an Unknown,
   Invalid or unattributed crash is a defect. Resource-only failed attempts may
   support Inconclusive. A missing attempt requires an explained phase interruption
   or failure; otherwise it is a defect.
4. If every required check is proved, all phases completed consistently and all
   required reports are available, apply the **unchanged exact successful-proof
   policy** to the selected reports. Only its acceptance permits Confirmed.
   Rejecting an expected unproved record under this success policy is not a second
   audit that converts step 3's resource classification into a defect.
5. Aggregate the result: any established defect takes precedence, including one
   found before interruption. Otherwise incomplete confirmation is Inconclusive
   only with attributable resource exhaustion, explicit interruption or a detected
   observation-only boundary established as independent of required proof generation
   and discharge. Proof-essential representation overflow on admitted source is
   a defect. Unexplained incompleteness is a defect.

| Confirmation outcome | Standalone status | Required report |
| --- | --- | --- |
| Confirmed | 0 | All required checks proved and strict selected-report audit accepted |
| Inconclusive | 4 | Exact resource/interruption/boundary evidence and missing coverage; never called proof success |
| Defect | 3 | The inconsistent, non-proving or unexplained result and evidence available |

For **every** not-confirmed result, attempt to retain a diagnostic bundle with
inputs, reports, tool identities, commands/arguments, process observations and
classification. Bundle creation, workspace sizes and path reporting are best
effort: disk/memory exhaustion must not turn failure to write diagnostics into
success or hide the original outcome. Preserve existing workspaces and evidence.

### Confirmation prover configuration

Keep `-U --mode=all --report=all --checks-as-errors=on --no-loop-unrolling`
and the mode's `--warnings` setting; drop `--level` and use:

```text
--prover=cvc5,z3,altergo --timeout=0 --memlimit=0 --steps=0
--counterexamples=off -j<max(3, available CPUs)>
```

- `--level=2` supplies 1,000 MiB per launched prover even with `--memlimit=0`.
  Without `--level`, small probes removed that limit. The retained `Trivial`
  entry with 1,000 MiB is a synthetic Valid result in the producer, not a launched
  limited prover. #88 checks actual process/session settings on representative
  programs, retaining the original observation and its source-based explanation.
- Explicit `-j` at least 3 permits racing provers, interrupting losers after
  Valid. A check with no finishing prover can occupy its slots indefinitely.
  Interruption/host failures then follow the outcome policy, including defects
  already observed. `-j0` on one CPU would run the provers in turn.
- A finite `--steps` must not exceed 5,368,146: producer normalization above it
  exceeds Z3's 32-bit resource limit and wraps. This design uses unlimited zero.
- Re-execute the driver once after raising `RLIMIT_STACK` to the hard limit, or
  use explicit heap stacks for recognition. Tools and the Image adapter inherit
  the limit. Retain actual platform limits; this does not provide infinite stack.
- Use `unproved_status` and `check_tree` together. `gave_up` merges Unknown,
  Invalid and crashes; the pinned report loses numeric leaf-process signal status.
  Add direct/structured observations where required, retaining ambiguity otherwise.
- On Linux, attempt `oom_score_adj = 1000` for confirmation children. This biases
  OOM selection, does not reserve resources or guarantee victim order, and is not
  evidence of a particular kill's cause. Shared-host disruption remains possible.

## Limits

### Removed limits

| Limit today | Location | Replacement | Package |
| --- | --- | --- | --- |
| Source length 1–4096 bytes | Both profile recognizers and language | Justified tool-capacity rules researched below | #91, #92 |
| 63 operators per program | `Work_Tail`/`Within_Work_Budget` | No independent policy cap; charge necessary tool representations | #92 |
| 64 expression leaves | `Max_Expression_Operands`, `Max_Operands`; catalogue operand/reference fields | No independent policy cap; charge necessary tool representations | #92 |
| 341 binding slots | Profile/scalar environments (`Max_Source_Length / 12`) | Sized from input | #89 |
| 16 MiB retained reports; Natural indexing | `Silver_Report_Storage`, `Max_Report_Length` | Streaming or 64-bit-indexed storage | #89 |
| 16 MiB source/file reads and writes | `Silver_Platform`, ghost arrays and driver snapshots | Growable storage/sequences; operational read/size failures never mean nonmembership | #88, #89 |
| 4096-character report-policy names | `Silver_Library_Reports`, `scripts/check_evidence.py` | Explicit identifier rule | #89 |
| Exponent at most 4096 | Scalar/length numerals, `Max_Exponent` | Pinned maximum 799,999 | #92 |
| String/output/argument lengths and length literals at most 4096 | `Silver_IO`, `Silver_Path_Facts`, catalogue | Justified value/composition domain within Integer'Last and #91's aggregate rules | #93 |
| 100,000 steps and 1,000 MiB per prover | Driver proof command | No confirmation caps | #88 |
| 16,384-byte command text and fixed path buffers | Driver/platform contracts and bootstrap | Growable argv/path storage and sequence observations; actual OS failures classified by cause | #88, #89 |

#88 owns process invocation, argv and outcome observation. #89 owns path/file
storage, bootstrap installation validation and corresponding ghost/source models;
the packages coordinate their interface. The command cap is Silver-chosen, not
an OS maximum. Do not replace it with another arbitrary universal buffer. Real
OS argument/path limits remain platform-dependent operational conditions.

The source, value, argument, output and length-literal roles currently share
4096 through separate constants, including both `Max_Source_Length` values,
`Silver_IO.Max_Length` and `Silver_Path_Facts.Max_Length`. #89 separates native
roles; #90 supplies corresponding Lean constants and mechanical numeric ties.

### Pinned-tool and inherited language limits

| Rule | Proposed value | Evidence / status |
| --- | --- | --- |
| Physical line width, tabs expanded to next multiple of 8 columns | At most 32,765 | 32,765 accepted with LF, CR, CRLF or no terminator; 32,766 gives "this line is longer than 32766 characters". The retained 39-byte program padded with tabs passes at 4,130 bytes, fails at 4,131. |
| Identifier length | At most 4,096 characters | 4,097 gives "Name buffer overflow; Max_Length = 4096" and a GNAT bug box in tested roles/modes |
| Numeric literal exponent | At most 799,999 | 800,000 gives "exponent too large" in tested bases 2, 10 and 16/mantissas; scanner source corroborates |
| Source and aggregate representation capacity | No replacement predicate adopted | #119 develops the missing phase/construct allocation argument; #91 implements the justified result |
| Integer range; one-based String length | Pinned Integer range; length at most Integer'Last (2,147,483,647), additionally subject to the selected capacity predicate | Inherited ceiling, not a promise that every value/composition below it is admissible |

#119's design, implemented by #91, has two obligations: **soundness for every
admitted source**, and **justification of the most expansive tractable rule**.
It starts with pinned producer-source accounting and existing evidence:

- GNAT allocates units in a shared 2^31 source-position space with 4 KiB alignment.
  Count physical and virtual ranges, EOF positions and alignment in every selected
  phase. The [retained-trace reconciliation](evidence/unbounded-programs/feasibility-20261017/continuation/planning/source-position-reconciliation.json)
  verifies the exact recurrence for seven existing traces. Each nonfinal range
  consumes its extent plus 1–4096 positions for EOF/alignment; virtual entries
  share template text but reserve distinct position ranges. That accounting
  does not establish the complete runtime/virtual-source closure. The recorded
  2,130,706,432-byte accepted probe used `gcc -gnatc` (semantic checking only),
  not a full build; the largest recorded full `-O0` build was 100 MB. Neither
  observation establishes a universal maximum. In semantic checks, 2,147,483,647
  crashed and 2^31 did not terminate in the retained experiment.
- Fixed tables include 100,000,000 Names/Lists/Elists/Elmts/Strings/Ureal entries,
  100,000,000 table-coded Uint identifiers and 1,999,999,999 positive node
  identifiers. The earlier roughly 1.5e9 Uint figure includes direct-encoded
  values, not that many table entries; Udigits is a separate digit-word pool.
  String character storage, node slots and allocation-growth headroom also
  have independent budgets. Derive
  per-construct consumption and expansion factors; do not assume host memory
  always runs out first. The research's approximately 50 million `elsif` arms,
  1.5 GB source and 44 GB memory are estimates, not probed boundaries.
- A candidate uniform rule takes the smaller of a safe source-position envelope
  and a worst-case table-consumption envelope. Compare it with one plausible
  source-sensitive capacity rule, including cheap sparse/dense contrasts, or
  explain why the uniform envelope is the best tractable choice. No exhaustive
  optimality proof is required. The result may be far below 2^31 bytes.
- State assumptions, counted paths and remaining gaps; connect the selected rule
  to native/Lean membership, catalogue and frontend premise. Re-derive affected
  inputs when the runtime/toolchain changes, including #93 and native macOS.

These are obligations for the replacement rule, not a completed derivation.
The [design contract](research/retained-tool-capacity.md) adds the String/Uint
lifetime, generated-data, backend and proof-producer accounting to this inventory.
The original stop on the full composition domain is retained as evidence for
justified restrictions. An unproved table-overflow premise cannot replace the
missing upper-bound argument.

<a id="confirmation-only-tool-limits"></a>

### Producer and observation limits

The following limits need separate classification in #119/#91. A representation
needed to generate or automatically discharge required obligations constrains
admission, including when confirmation is optional. An admitted program hitting
that bound is a defect. A purely observational/reporting boundary can remain
confirmation-only only after establishing that it cannot prevent the required
proof and defining a reliable detection path. Naming a tool limit is insufficient.

The inspected literal producer's nonzero Why identities end at 2^30−1 and
`Transform_String_Literal` creates nodes per character. This is an additional
proof-essential capacity component, conditional on the recorded SPARK source
premise; the installed-source connection and complete accounting remain open.
The historical Image/report observations below remain useful, with this
classification requirement replacing their blanket confirmation-only treatment:

- **Image occurrence counter:** producer maximum 2^31−1. Recorded T4 points give
  approximately 6.685–52.266 identifiers per source byte, projecting approximately
  41–321 MB of source at that counter. These are illustrative extrapolations from
  two shapes; original model counts were not independently re-read because the
  archive omitted those models. Encoding width/growth may change the projection;
  memory need not exhaust first. #89 widens the adapter's own identifier while
  retaining the producer's actual counter width in #91's accounting and diagnostic
  rule. Widening the adapter alone does not widen the producer.
- **Report writer:** a possible approximately 2-GiB Natural-indexed writer limit
  remains to be verified from producer source in #89, with its role classified by #119/#91. Measured 19–350 report bytes
  per source byte project approximately 6–115 MB; that is not a guaranteed bound.
- **JSON depth:** the current auditor uses 64 levels; reviewed producer report
  nesting is fixed rather than program-AST depth. #88/#89 must recheck this for
  unsuccessful reports and the new classifier instead of assuming every schema
  change preserves it.

Fixed-input storage also needs a derived purpose: the 262,144-byte null/runtime
report policies and 16,384-byte runtime-file capacity are not OS maxima. #89/#93
re-derive sufficient capacities from selected fixed inputs/producer structure,
accounting for metadata that can grow with source positions, or remove a bound
that cannot be justified. Preserve complete reports and exact identity checks.

### Trusted premises

- **Solver completion:** every source schema accepted by Lean's endpoint checker
  has automatic proof by some pinned prover given sufficient resources. Removing
  policy caps broadens the premise's program family; with finite alphabet and a
  finite tool-source rule it is still finite. Symbolic theorems may quantify over
  arbitrary capacities. Linear interval/length and bounded nonlinear product
  goals do not establish that the actual portfolio completes every instance.
- **Frontend/build acceptance:** explicit rules cover the admitted sources for
  the pinned frontend and build tools. Source review and differential tests
  support, rather than prove, this external premise. Table/source/static-data
  feasibility remains subject to the research and stops above.
- **Producer and Image applicability:** faithful static evaluation, complete
  obligation/report generation, accepted producer shapes and per-program Main
  Image translation remain assumptions as precisely stated in
  [trusted-boundary.md](trusted-boundary.md). Confirmation checks reports,
  observed proof results, selected templates and identity. It does not prove
  that no obligation was omitted or check every Main Image occurrence. Those
  premises were not established by the old gate either; successful confirmation
  corroborates observable consequences without verifying every assumption.
- **Operational boundary:** faithful tools, stable inputs/workspaces and functioning
  filesystem/process services remain necessary. Failures include tool bugs,
  unsupported configuration, permission/I/O errors and identity drift as well as
  resources. Distinguish each observed phase and cause; a resource outcome is
  neither nonmembership nor successful completion of that failed phase.

The guarantee remains unchanged, while its pre-publication evidence architecture
changes. Keep these conditional claims explicit; detected prover incompleteness
is a defect, not a permitted exception to automatic discharge.

## Research evidence

The later [feasibility result](research/unbounded-feasibility-result.md) records
the completed source/lifetime reasoning and targeted Linux backend evidence,
with its completed [independent review](reviews/review-unbounded-feasibility-2b47dd8e27.md).
It preserves the first
[handoff](research/unbounded-feasibility-handoff.md) as a partial checkpoint.
Neither is an implementation or complete proof/test validation checkpoint.

The original five scoping tracks ran on Linux x86_64 on 2026-10-17 (22 CPUs,
31 GB RAM, no swap).
The [curated record](evidence/unbounded-programs/scoping-research.json) and
[immutable raw evidence](https://github.com/berkeleynerd/silver/tree/0cd253d05b2cb650cc8fca81255e9a711765e16a/tmp)
retain their input scope and corrections. The review verified the supplied
manifest and all 2,154 listed files; omitted large inputs/sessions remain gaps.

| Finding | Evidence class and limit |
| --- | --- |
| Uniform ⟨L,L⟩ schema valid iff 2L ≤ 32,767; exact S + K·C ≤ V ≤ 2,147,483,647 bounds every dominated intermediate | Standalone kernel-checked Lean probe; does not verify future native arithmetic |
| Lifting counts 4,154/4,347, 4,559/4,776 and 2,524/2,627 symbolic groups; 4,633/4,770 at 2,147,483,646 | Conditional kernel checks: failed declarations re-added unchecked; not proof of the enlarged language |
| No failure demonstrated essential dependence of decidability, termination, uniqueness or fuel on 4096 | Manual classification; uniqueness helpers and compiled fuel artifacts still failed mechanically |
| Resource-indexed contract composes with Current.ToolContract and is inhabited | Kernel-checked model; physical completion and outcome behavior remain premises |
| Lexical limits and sampled total sizes | GCC observations and producer-source review; not complete derivations of source/table/build capacity |
| 17 T4 runs: 16 completed, one stopped; all completed required checks proved | 14 scaling runs plus two option smokes; up to 32.5 KB mixed/16.3 KB straight-line source. No whole-run fatal tool failure; losing-prover High failure occurred in 11/16 runs and remains unexplained |
| Fitted proof-time exponents 1.82–1.99; gnatwhy3-memory exponents about 1.0 mixed, 1.43 straight-line, 1.98 dense | Host measurements under concurrent load; dense exponent uses only two sizes. Winning-step maximum 1,021 in the 14 tabulated runs; 1,340 belongs to earlier 4-KB reports |
| Dense 4-KB probe about 23 minutes/5.9 GiB; 8-KB probe stopped at its 14-GiB guard after 263 seconds | Measured stop; about 23 GiB projected, not observed completion |
| Binding-environment copies about 29 KiB/loop level at 4 KiB, 113 KiB at 16 KiB; parenthesized conditions quadratic; compile reparses up to six times | Production/scratch measurements. The 64-KiB build's retained 11,764-KiB depth-20 total does not establish a 576-KiB slope |
| GCC work superlinear in sequence/nesting; 100,000 nested loops exceeded 1,800 seconds | Host observation, not universal cost bound |
| Documented report envelope exceeds 16 MiB above 4,502 source bytes and reaches Natural'Last near 587 KB | Derived envelope, not observed writer failure |
| Linux single argument at most 131,071 bytes; larger exec gives E2BIG | Host observation, not a language input bound |

These are scoping measurements, source analyses and limited proofs, not an
implementation checkpoint or universal solver validation. Raw historical unit
and bookkeeping errors remain preserved with corrections in the evidence record.

## Work packages and order

| Order | Work package | Depends on | Admission effect |
| --- | --- | --- | --- |
| 1 | [#87 Scope and design](https://github.com/berkeleynerd/silver/issues/87) | — | None |
| 2 | [#88 Proof confirmation and resource outcomes](https://github.com/berkeleynerd/silver/issues/88) | #87 | None; build no longer waits for proof |
| 3 | [#89 Compiler storage and complexity that scale with input](https://github.com/berkeleynerd/silver/issues/89) | #88 | None |
| 4 | [#90 Parameterized Lean assurance](https://github.com/berkeleynerd/silver/issues/90) | #88; coordinates certificates with #89 | None |
| 5 | [#91 Pinned-tool capacity rules](https://github.com/berkeleynerd/silver/issues/91) | Complete #119 design; rules after #89/#90 | None while 4096 remains |
| 6 | [#92 Remove source, operator and expression caps](https://github.com/berkeleynerd/silver/issues/92) | #88–#91 and the justified #119 rule | Larger programs within tool capacity |
| 7 | [#93 String and argument capacity within pinned-tool limits](https://github.com/berkeleynerd/silver/issues/93) | #89/#90 and implemented #91/#119 rules; coordinates #92 | Longer values within justified aggregate capacity |
| 8 | [#94 Validation, review and delivery](https://github.com/berkeleynerd/silver/issues/94) | All | Records delivered support |

#89 introduces separated native constants; #90 ties and parameterizes their Lean
counterparts, replaces the uniform schema with the exact one, and retains source
correspondence. One agent writes a host's proof workspace at a time; coordinate
shared certificates and checkpoints. Each package leaves the project valid.
#93 refreshes bootstrap/library identity and fixed-input envelopes after runtime
changes. #94 reconciles catalogue fields/export, scripts/check_evidence.py,
README, samples/fixtures, Rosetta assessment text and all assurance records.
#119 is the current design work package under #91, shared with #93, before
capacity adoption. #88–#90 are separable foundations, but the owner selected capacity design first;
#92/#93 require the justified design and implemented rules, not just research
issue closure. The milestone closes only when #94 completes. Production remains
unstarted during this design step.

## Validation plan

Follow [development.md](../development.md#proof-loop-and-validation): focused
iteration for changed inputs and one complete capability checkpoint in #94.

- Check each chosen explicit boundary and adjacent rejection. Use unit-level
  arithmetic/scanner tests for huge bounds and source analysis for tool tables;
  do not require routine near-2-GiB compiles, proofs or allocation. A targeted
  expensive probe needs a concrete unresolved hypothesis, suitable resources,
  retained evidence and a memory guard; never repeat successful expensive work
  merely for a new record.
- Prove universal Lean results with only explicit language limits and documented
  side conditions (minimums, ordered separate domains, V ≤ pinned Integer'Last),
  tied to native source. Fresh audits allow only the three standard axioms.
- Test the exact confirmation decision order with fixtures and small genuine
  reports, including nonzero exits, mixed prover outcomes, completed defects
  followed by interruption, truncated evidence and producer failures before reports.
  Include proof-essential representation overflow as a defect and test any
  justified observation-only boundary separately. Update pinned proof-option/
  why3session assertions in tests/test_samples.py.
- Exercise build without proof, standalone confirmation witnesses and retained
  workspace identity. All supported samples must build, run and confirm.
- Test observed I/O/exec/resource failures under ulimit -v/-s/-f/-t, full disk and
  E2BIG. Admission/build failures publish no executable and never claim success or
  nonmembership; attributable resources return 4, ambiguous causes 3, and uncaught
  driver deaths retain their documented termination form. Confirmation-only
  failure preserves a successful build and is reported separately.
- Test application normal status forwarding and direct signal translation,
  including Reject/output failure, exit1/137, resource exceptions and signals.
  Never use an exit-code guess as a substitute for cause evidence.
- With implementation authorized, use a guarded geometric ladder from 4 KiB toward
  1 MiB for mixed code, straight-line code, dense copies, deep nesting, long
  expressions and nonlinear products. Record reached size, time, memory, steps,
  reports and stack; resource stops are results, not a mandate to force completion.
  Extend differential frontend fuzzing from the prior review harness.
- An unfixable non-proof or failed capacity/build-feasibility justification follows
  Full stops. Native macOS tool-limit/stack checks remain independent and nonblocking.

## Risks and non-goals

Confirmation and frontend costs are superlinear. Dense 16-KB confirmation near
90 GiB is a two-point extrapolation, not measured capacity. Uncapped confirmation
can disrupt a shared host despite OOM biasing; racing changes attempt histories,
winning provers and resource use. Defects/incompleteness remain possible under
unverified external premises. Large String objects can exhaust an application's
stack well before Integer'Last. Preserve diagnostics/workspaces where possible
and report their disk use; reporting alone cannot prevent a full disk.

New constructs and [Rosetta stages](../rosetta/progression.md), String values
beyond Integer'Last, compiler-chosen proof cut points, hosted CI and macOS as a
Linux completion gate remain out of scope. This checkpoint changes direction
and capacity design; production implementation is unstarted.

## Scoping validation

Original research used scratch with recorded side effects, including retained
Image workspace `.silver/linux-x86_64/imagews-n5nSxf`. The three pre-publication
reviews supplied recommendations, not a clean guarantee: process recommendation
1's before-claim authorization ordering and technical recommendation 10's precise
outcome wording did not fully land in PR #95. The published independent review
records that chronology; this correction does not rewrite it. The
[repair record](review-ec82b4e5f2-repairs.md) records dispositions and validation.

The earlier corrective pass changed planning documents and issue scope only.
This retained-tool direction/design checkpoint likewise leaves current language,
Oracle, production source and canonical proof artifacts unchanged. Link/anchor,
consistency and whitespace checks are proportionate; no compiler, GNATprove,
Lean build or full-suite validation is claimed for this checkpoint.
