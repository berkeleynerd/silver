# Restrictions and capacity audit

## Scope and status

On 2026-10-12 the owner authorized the first
[existing-feature consolidation item](../roadmap.md#existing-feature-consolidation):
inventory the current restrictions, investigate native tool/report capacity,
repair catalogue inconsistencies, and specify the foundation for shared bindings
and expressions. The input is `a68d0b7f84`. The supported language remains
[six output shells plus null](../language.md), with fifteen concrete output
forms. The unfinished repeated-output edit is excluded from this audit's
supported source and validation.

This record distinguishes inherited meaning, library contracts, explicit
resource policies and temporary grammar choices. A restriction can serve more
than one purpose. Removing a temporary choice still needs the complete assurance
argument for its replacements; passing a probe does not admit it. The
[Oracle](../oracle.md), [assurance argument](assurance.md) and
[trusted boundary](trusted-boundary.md) remain unchanged.

The inventory and catalogue repair have independent source review. Native build,
focused catalogue/copy tests, incremental compiler proof and a complete cached
Lean check with a fresh axiom audit passed. The native capacity measurements
below are separate exploratory evidence; they do not extend membership.

## Complete current-language inventory

### Source, names and program structure

| Restriction | Classification and reason | Consolidation disposition |
| --- | --- | --- |
| Complete source is 1–4096 bytes, including all trivia and literal escapes | Explicit resource policy, enforced by both profile recognizers and the driver | Retain for this audit; measure dense programs within it. It is not an Ada/SPARK Silver-level rule. |
| Only ASCII 32–126, HT, LF and CR; comments end at LF, CR or EOF; whitespace is space/HT/LF/CR | Explicit lexical domain, implementing a decidable subset of Ada | Preserve throughout new grammar positions. No Unicode, BOM, VT, FF or NUL extension is implied. |
| Whole word tokens compare ignoring ASCII case; identifier continuations cannot be attached to fixed keywords | Inherited Ada case-insensitive naming plus explicit ASCII domain | Share existing lexical rules; do not replace whole-name comparison with prefixes. |
| Names follow `[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*`; all 74 Ada reserved words are excluded | Inherited identifier rules within the chosen alphabet | Preserve. Names have no additional size limit beyond complete-source size. |
| `String` and `Silver_IO` are excluded; argument-bearing forms also exclude `Silver_Arguments` for every declaration | Binding discipline protecting the fixed type/library references | Preserve the intended bindings in the shared environment. `Main` remains legal as an object name, and `Silver_Arguments` remains legal when its package is absent. |
| Declared names are distinct ignoring case; every reference resolves to an earlier available binding | Scope/uniqueness requirements for the selected single declaration region | Preserve; constant aliases and mutable-source copies require value snapshots, not textual replacement by the source's later value. |
| One library-level parameterless `procedure Main`, matching closing name, no exception handlers, exactly one initial `pragma SPARK_Mode (On);` | Deliberate language scope; author proof annotations and other pragmas are forbidden by the Oracle | Retain. General subprograms, units and author contracts are outside consolidation. |
| Null has no context clause; output has exactly `with Silver_IO;`; argument forms add exactly `with Silver_Arguments;` in that order; no `use` | Current fixed-shell organization and explicit library selection | Shared rules must specify needed context explicitly. Reordering/optional contexts are not implied by this audit. |

Printable literal contents already vary freely within their domain: empty values,
doubled quotes, spaces, letter case and `--` are all supported. Literal bytes are
32–126; tabs and line endings inside quotes are excluded. `:=` and `<=` are each
contiguous tokens; trivia may otherwise separate tokens where Ada permits it.
All consumed tokens, trailing trivia and end-of-source are checked. These rules
are implemented in [the lexical helpers](../src/silver_output_lexical.ads) and
[the recognizer](../src/silver_output_profile.adb).

### Inherited value semantics and library contracts

| Rule | Meaning that generalization must preserve |
| --- | --- |
| String initialization fixes object bounds; assignment preserves them | Equal-length replacement is required, including zero-length values. An upper bound alone does not establish assignment compatibility. No resizing, truncation or padding. |
| Copies read initialized values at the point of execution | Constants cannot be assignment targets; later writes to a copied mutable source cannot change the earlier copy. All reads need established initialization. |
| Concatenation preserves operand byte order; flat chains associate to the left | Bound every intermediate String and its index arithmetic, not only the final call argument. Parentheses later alter grouping without authorizing new operations. |
| Predefined String equality is case-sensitive and compares decoded values | Unequal lengths compare false; equality neither resizes nor case-folds operands. |
| `Silver_IO.Put_Line` receives at most 4096 bytes in admitted programs | Requests those bytes followed by LF. The wrapper checks its own input length and failures; that guard does not justify admitting a statically oversized expression as a successful output. |
| Output success requires every byte write and `fflush(NULL)` to succeed | Host-stream acceptance is the effect, not reader consumption or durable storage. Detected failure sets status 1 and returns; partial accepted output, environmental blocking and signals retain the documented boundary. |
| `First_Or_Default` observes the immutable argument vector | No argument selects the literal default; exactly one printable argument of length 0–4096 preserves its bytes, including empty. Invalid input produces an internal empty result, but the current guard rejects instead of printing it. The returned String is one-based. |
| `Input_Is_Valid` and the initializer observe the same vector | Extra arguments, nonprintable bytes and length above 4096 reject. Reading an argument occurs before its length check, so this bound is not an allocation limit on GNAT's retrieval. |
| Explicit capacity applies equally to argument and default | An over-capacity default is legal source and reaches rejection when selected. Omitting the dynamic value from output does not bypass the declared capacity test. |
| `Reject` sets failure status and returns normally | It is not an abrupt exit. With future following statements, both rejection and output failure must retain their actual returning-call semantics; later successful output must not reset failure status. |

The contracts and implementations are [Silver_IO](../src/silver_io.ads),
[its body](../src/silver_io.adb), [Silver_Arguments](../src/silver_arguments.ads)
and [its body](../src/silver_arguments.adb). Their external interfaces are
documented in the [trusted boundary](trusted-boundary.md). Admission of those
operations does not admit other operations in their packages or implementation
features used by their bodies.

### Restrictions imposed by the current shells

These are actual membership rules today, even when their origin is staging.

| Area | Current restriction | Required replacement |
| --- | --- | --- |
| Declarations | Direct output has none; static output has one literal-backed constant; assignment/selected-result forms have one mutable result and zero through two literal-backed constants; argument forms have one immutable input in a fixed position | Finite declaration lists with shared scope, type, initialization, mutability and fixed-bound rules. Declaration count should follow justified source/tool capacities rather than one/two named slots. |
| Initializers and assignment values | Mutable initializer/RHS is one literal or preceding literal-backed constant; constants cannot alias; dynamic and mutable sources, self-copy and expressions are excluded | One value judgment for earlier initialized names and expressions in all these positions, with snapshot semantics and exact assignment lengths. |
| Output expressions | Flat chain of 1–16 literal/name operands; no parentheses; one dynamic occurrence at most; any static name may repeat | Shared expression trees, multiplicity-aware bounds and justified translation/report capacity. Empty operands still count toward work even though their lengths are zero. |
| Required uses | An assignment-bearing output must reference its result; literal-backed constants may be unused | Do not retain compulsory use solely to preserve a shell. Classify native unused/overwritten-value diagnostics precisely when broader data flow is implemented. |
| Assignments/null | Exactly one assignment per executed assignment path, to the sole mutable target; null is a separate complete program | Finite sequencing with initialization and bounds preserved after every statement. Neither self-copy nor an overwritten store changes Ada's assignment meaning. |
| Validity and capacity predicates | Exactly `Input_Is_Valid`, optionally followed by `and then D'Length <= C`; canonical decimal `C` in 0–4096; no reordered/negated/extended condition | Explicit predicate grammar with sound path facts. Canonical numeral syntax is a chosen grammar restriction, not a solver requirement. |
| Equality and branches | Exactly `D = L`; one inner choice between two outputs, or two assignments followed by one common output; no nesting, reversed comparison or Boolean combination | Reuse value judgments in comparison, then define finite conditional composition and sound state/fact joins. No admission of arbitrary Boolean computation is implied. |
| Effects | One terminal output per executed output path; rejection is terminal; no interleaving or repeated calls | Cumulative call/byte observations, each call's outcome, continued execution after returning failures and sticky status. No separate four-call limit. |
| General compositions | Fixed statement and declaration order; no extra null, declaration, output, statement or unmatched suffix | Replace combinations of whole-program templates with the shared rules as the corresponding roadmap areas are implemented. |

For each current expression, membership computes `W + (C if D occurs else 0)
<= 4096`, counting each static occurrence. `C = 4096` without an explicit clause;
therefore an unguarded-capacity dynamic expression has zero total static length.
Each alternative branch is checked independently. This is a resource/domain
condition combined with guard reasoning, not a count of distinct source literals.

The inventory covers all 23 catalogue IDs: `main_procedure`, `spark_mode_on`,
`null_statement`, `runtime_context`, `argument_context`, `string_literal`,
`named_string_constant`, `named_string_variable`, `string_copy`,
`string_expression`, `string_concatenation`, `literal_output`, `named_output`,
`concatenated_output`, `expression_output`, `argument_initialization`,
`input_guard`, `capacity_guard`, `argument_rejection`, `string_equality`,
`input_branch`, `string_assignment` and `result_branch`. Overlapping output IDs
are descriptions of the common expression/output rule, not independent licenses
to repeat or combine calls.

Loops, recursion, application subprograms, extra library APIs, resizable Strings,
indexing, slices, conversions, other operators, user types, access values and file
handles remain outside the selected fragment. Their exclusion is deliberate
scope, rather than an unexplained restriction on an otherwise admitted operation.

## Tool and storage capacities

| Capacity/policy | Enforcement and implication |
| --- | --- |
| Source: 4096 bytes | [Profile](../src/silver_profile.ads), [output profile](../src/silver_output_profile.ads), source-read buffer and exact source grammar. A short source can still duplicate a value or generate many obligations. |
| Argument/output item: 4096 bytes; successful line: at most 4097 bytes | [IO contract](../src/silver_io.ads), argument wrapper and expression admission. This is per call, not a cumulative future-output bound. |
| 16 operands, at most one dynamic occurrence | [Expression parser](../src/silver_output_profile.adb). Both bound the current obligation fragment; source size alone does not establish the adequacy of removing them. |
| Main and individual library reports: 262,144 bytes | [Null checker](../src/silver_reports.ads), [library/application checker](../src/silver_library_reports.ads), and [platform file domain](../src/silver_platform.ads). Driver/library buffers read complete reports and detect overflow; truncation is not accepted. Any increase must reconcile all these bounds and their proofs. |
| Application solver: 10,000 steps; timeout/memory flags zero | [Driver proof command](../src/silver.adb): all selected units, mode/report all, CVC5/Z3/Alt-Ergo, level 2, checks-as-errors, all available workers. Zero timeout/memlimit does not supply a universal runtime or resource bound. |
| Main safety records: proved/info range checks only | All output policies require full Main coverage and approved dependencies. Static elimination may leave no checks. New expressions can produce different obligation classes; inspect and model them instead of weakening the accepted record predicate. |
| At most one exact ineffective-initialization advisory | Assignment/selected policies use `--warnings=continue` but still audit the precise `INEFFECTIVE` record; other policies use `--warnings=error`. Additional declarations/stores may exceed this allowance without having a safety defect. |
| Six runtime source files, each at most 16,384 bytes | [Library snapshot helper](../src/silver_libraries.ads). Every output shell selects the same six files and four complete runtime reports; null selects none. This is compiler storage, not an author-source allowance. |
| Paths: 4096 bytes; command text: 16,384 bytes | [Platform interface](../src/silver_platform.ads), with stricter directory reserves for appended paths. Infrastructure capacities are distinct from program membership and need no arbitrary expansion for this audit. |

The template token-array bound of 100 and fixed token spelling bound of 16 in
the output profile describe the existing recognizer tables, not a 100-token or
16-character-identifier limit on author source. The initializer-advisory parser's
4096-character name bound accommodates the complete source domain; it is not a
new author name restriction.

Lean proves its mathematical discharge checker terminates and succeeds for the
admitted model. Faithful and complete external obligation generation, static
elimination, report production and pinned solver completion remain explicit
[premises](assurance.md#automatic-completion-and-the-external-boundary). Native
measurements can expose capacity defects and quantify observed margins; they
cannot prove worst-case solver completion or all producer behavior.

## Proposed shared binding and expression foundation

This is the proposed next implementation fragment, **not current support**.
Keep the single Main declaration region, current lexical domain and existing
library identities. Replace named binding slots by a finite ordered environment.
Each declaration contains one name, `String`, optional `constant`, and a required
initializer. Earlier initialized constants and mutable objects are readable;
only mutable objects are assignable. Names retain the current exclusions and
case-insensitive uniqueness. New binding counts derive from source size and
justified native capacity instead of an unrelated fixed number.

Use one String-value syntax in constant/mutable initialization, assignment RHS,
String comparison and output:

```text
expression ::= atom { "&" atom }
atom       ::= string_literal | earlier_or_current_initialized_name
             | "(" expression ")"
```

At declaration time, names are restricted to earlier bindings; at statement
time they mean the current values of initialized bindings. Existing argument
initialization remains a separately specified admitted API call; retain its
single immutable input binding until the argument-operation composition item
specifies broader placements. The grammar does not introduce arbitrary function
calls. Comparisons reuse the same value
judgment when the predicate extension is implemented. Statement sequencing,
nested branches and repeated effects retain their explicit later proof work;
a binding/expression milestone must not claim those areas are closed.

The environment must record object bounds separately from current bytes.
Initialization establishes bounds, copies capture bytes, and assignments require
RHS length equal to the target's fixed length under the available facts.
Expression checking supplies value semantics, length information and a safe
bound for every intermediate concatenation. For one symbolic argument length
`d`, repeated occurrences require `W + k*d`, not a Boolean “dynamic seen” flag.
Copies retaining that length relationship must retain it in the length model
as well; treating each alias as one independent unconstrained value needlessly
loses usable facts. A guarded bound can use `W + k*C <= 4096` for output.
All analysis arithmetic itself must be bounded or checked before operations.

**Declaration initializers run before body guards.** A later `D'Length <= C`
cannot justify an earlier concatenation. The initializer must be safe for its
full currently known input domain. A copied argument's object bounds may depend
on the execution's selected argument length, yet remain fixed after declaration.
Neither a copied name nor a body guard permits those bounds to change. The
4096-byte output contract does not, by itself, select the allowed domain of
every future non-output expression; that value/intermediate-bound policy must be
explicit in the implementation specification.

Before calling these foundations closed, cover constant aliases, mutable-source
copies, empty values, repeated aliases/dynamic uses, parentheses, differing fixed
lengths, equal-length assignments, invalid/forward/cyclic references, name
collisions, mutations after copies, and declaration-time versus branch-local
facts. Any retained operand or value bound needs a stated resource or assurance
reason and evidence that the full admitted fragment fits it. Additional stores,
unused declarations and varying output dependencies also require a precisely
classified report policy; blanket warning acceptance is not a substitute.

## Native measurements and integration

The retained evidence is under
`.silver/linux-x86_64/restrictions-capacity-20261012T170230Z/`, with local pointer
`tmp/restrictions-capacity-active.json`. Native Linux x86-64 exposes 12 CPUs and
about 31 GiB RAM without swap. Tools are GNATprove FSF 16.1.0, Why3 1.8.2+git,
CVC5 1.3.2, Z3 4.15.4, Alt-Ergo 2.6.1 and GPRbuild 26.0.0. Lean is pinned to
4.34.1. The owner's 96 GB physical RAM is distinct from this sandbox allocation.

`generate_probes.py` and `generate_supplementary_probes.py`, their manifests,
per-case sources/projects/runtime hashes, command arrays, logs and results
retain the experiments. All sources are unannotated Ada within 4096 bytes. The
same six runtime files and project compiler options (`-gnat2022 -gnata -gnato`)
are copied byte-for-byte. Silver's actual `check` command decides membership;
GNATprove and GPRbuild run separately for these experiments. Only the ordinary
and padded 16-operand controls are current members. Successful exploratory proof
or execution does not admit any other case.

Proofs use the application's `-U --mode=all --report=all`, checks-as-errors,
level 2, CVC5/Z3/Alt-Ergo, 10,000 steps, zero configured timeout/memlimit and
`-j0`, under `--subdirs=explore/capacity` with separate native filesystem caches.
Assignment-bearing experiments use `--warnings=continue`; others use
`--warnings=error`. Runs are sequential and reuse their experimental caches and
available analysis artifacts, so elapsed times are observations, not cold-build
benchmarks. External experiment budgets are 300 seconds for repeated-output
stress and 180 seconds otherwise. Those harness budgets are not new language
or production-proof limits.

The Main report byte counts below are the actual `main.spark` files consumed by
the application checker, not diagnostics or SARIF. Native translation/execution,
full native proof and current report-policy acceptance are separate results.

| Case (source bytes) | Native proof, seconds | Main safety records | Main advisories | Main report bytes |
| --- | --- | --- | --- | --- |
| Admitted mutable control (143) | passed, 6.30 | 15 range | 1 | 28775 |
| 77 outputs, each 16 mutable operands (4,096) | stopped, 300.01 | not produced | unknown | not produced |
| 73 outputs, dynamic plus 15 empty mutable operands (4,096) | stopped, 300.00 | not produced | unknown | not produced |
| 17 repeated dynamic operands (302) | passed, 6.50 | 16 range | 0 | 31649 |
| 32 repeated dynamic operands (332) | passed, 15.81 | 31 range | 0 | 57220 |
| 64 repeated dynamic operands (395) | unproved check, 91.39 | 63 range (one unproved) | 0 | 111804 |
| 186 declarations/copies, two outputs (4,096) | passed, 3.18 | 1 length | 4 | 7333 |
| 790 assignments, two outputs (4,096) | stopped, 180.01 | not produced | unknown | not produced |
| 72 nested equality branches (4,096) | passed, 43.38 | 72 range | 0 | 122683 |
| Equality-refined `R := D & D` (324) | passed, 2.08 | 1 range, 1 length | 1 | 8898 |
| Admitted control padded to source limit (4,096) | passed, 7.56 | 15 range | 1 | 28775 |
| Grouped static/dynamic concatenation (304) | passed, 2.23 | 3 range | 1 | 9797 |
| Copy, mutate original, print snapshots (162) | passed, 2.58 | 4 range | 0 | 10142 |
| 16 outputs, each 16 mutable operands (923) | stopped, 300.02 | not produced | unknown | not produced |

The 64-occurrence dynamic expression leaves one intermediate range check
unproved. At source column 345, all three ordinary solvers exceed their step
limits; the counterexample attempt also times out. The final concatenation check
still proves. This is a prospective automatic-discharge gap, not evidence of an
unsafe expression or a sharp safe operand-count threshold. The 32-occurrence
case succeeds even though some Alt-Ergo attempts hit their limit, because Z3
proves those subgoals. Do not interpret successful-attempt maxima as spare margin
for every solver, or these examples as universal permission to raise a bound.

The 77-call, 73-call and smaller 16-call repeated-output cases do not produce
Main reports within 300 seconds. The 790-assignment case likewise stops at
180 seconds without its Main report. The earlier estimate of 1,155 checks and 2.2 MB
for the 77-call case remains unverified. The highest sampled individual `gnatwhy3` RSS was
17.05 GiB for 77 calls, 15.99 GiB for 73 calls and 7.85 GiB for 790 assignments.
Sampling began during the first dense run; these are observed values, not full
process peak accounting or a worst-case requirement. Partial reports and logs
are retained. External interruption does not establish solver failure.

No completed report exceeds the current 262,144-byte domain; the largest is
122,683 bytes. **Report capacity for the dense repeated cases remains open.**
Neither the old extrapolation nor these time-limited runs justifies choosing a
larger buffer or removing expression/statement restrictions. A follow-up tied to
the corresponding implementation must establish both practical proof completion
and complete report capacity; do not replace the rejected four-call cap with
another arbitrary call count.

The dense copy case produces a proved `VC_LENGTH_CHECK`. Its two output calls
also produce four `INEFFECTIVE` advisories about overwritten/unused ghost
outputs (`Written_Count`, `Flushed`, `Succeeded`, `Written_Bytes`). These are not
the existing permitted initializer advisory. Broader copies/assignments need
complete length-check handling; repeated effects need their own precisely
classified diagnostics and cumulative semantics. Increasing report storage alone
would resolve neither requirement nor the observed solver/translation costs.

All fourteen programs build with GPRbuild and pass all 28 recorded exact-byte/status
executions, including the interrupted and unproved experiments. These runs are
separate from Silver compilation and do not substitute for failed/missing proofs.
The dynamic cases include at-capacity, over-capacity and invalid-input checks;
the grouped expression also covers empty/default input and extra arguments.
Copy-then-mutate prints `old/old/new`, demonstrating the intended value-snapshot
case. Both currently admitted controls pass membership, proof and execution;
the other twelve sources are rejected by membership as expected.

The scratch native checker uses unchanged production checker sources and checks
all four policies without increasing their input domain. It rejects the unproved
64-occurrence report, the dense-copy length/advisory report and the refined
assignment's length-check report under every current policy. Expected compatible
reports pass their matching policy; several also fit other report shapes, which
is why source membership must select the route. Missing reports are not parsed.
Checker boundary controls cover empty/malformed-at-limit input and refusal above
262,144 bytes, without truncation. `checker/build.json` and
`checker/runs/20261012T173049.013563Z/results.json` retain source/executable hashes
and actual verdicts.

Independent source and evidence review confirmed the inventory, catalogue repair,
all fourteen source/report hashes and membership outcomes, the result table,
native checker verdicts and scoped validation claims. It found no material
correction. These reviews do not turn the interrupted experiments into completed
proofs or establish a worst-case capacity bound.

The primary harness initially omitted creation of its scratch cache directory;
all ten setup failures are preserved in `failed-missing-cache/`, then the directory
was created and the same commands rerun. The earlier catalogue-only `prove -u`
invocation was rejected by the development CLI before proof execution; the
normal incremental command succeeded. These setup/command corrections changed
no source, solver policy or production capacity. No failed proof was retried
with weaker options.

### Catalogue repair and proportionate validation

The catalogue repair adds `preceding_literal_constant_identifier` to
`selected_result_output.initializers` in both the checked JSON and
[SPARK exporter](../src/silver_catalogue.adb). This describes already supported
behavior, matching the neighboring `mutable_value_operands`. The existing native
catalogue test now compares both mutable-result shells' initializer metadata
with the shared construct. Native export consistency and the copy-position
regression pass. No further definite catalogue discrepancy was established by
this source inventory; contextual fields must be interpreted with their complete
composition rather than as an independent grammar.

| Adopted-change validation | Native Linux result |
| --- | --- |
| `python3 scripts/dev.py build` | Passed; catalogue exporter rebuilt and compiler linked. |
| Existing catalogue regression and copy-position regression | Both passed, including actual native export/checked-JSON equality and already admitted initializer variants. |
| `python3 scripts/dev.py prove` | Passed; incremental run reported 2,623 checks proved. Native sessions/cache were reused; this is not a new full compiler audit. The earlier completed manifest keeps its original scope in `preserved-before/`. |
| Complete cached `check_lean.py --workers 12 --threads 12 --memory-mb 16384` | Passed in the isolated supported snapshot: 109 modules, 33,044 declarations, fresh whole-project audit, only `propext`, `Classical.choice`, `Quot.sound`. Runner elapsed time 11.060 seconds; no independent replay. |
| Preservation | Canonical Lean inventory of 982 files is unchanged, including hashes, lengths and modification times. The exact unfinished `ComposeAdmission.lean` edit is preserved and excluded from the snapshot and scoped commit. Prior native compiler/cache/generated/context state is copied into `preserved-before/`. |

The catalogue source is not one of the twelve embedded Ada certificates, so the
complete Lean check reused their objects. It still synchronized the supported
inputs and freshly audited the project. `native-build.log`, `catalogue-tests.log`,
`compiler-incremental-proof.log`, `compiler-reports-after/`, `lean-complete.log`
and the snapshot's Lean evidence record retain exact results. The native
experiments use separate outputs/cache; none changes supported source or proof
options. Linux is primary; GitHub Actions remains disabled. CLI recall tools and
conventional recall directories are unavailable, so only checked-in handoff and
session memory were updated.

Completion of this audit records measured constraints and a concrete next
fragment; it does not establish that the broader fragment already proves or
that report capacities may safely be relaxed. Apply the existing
[proportionate validation workflow](../development.md#proof-loop-and-validation)
to the actual adopted changes. Preserve earlier evidence/caches and the unrelated
unfinished proof edit. No new architecture, assurance exemption or release gate
is introduced.
