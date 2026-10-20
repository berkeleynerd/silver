# Retained response timing configuration

2026-10-20 UTC, Linux x86_64. Prospective research for #119 / #153;
production #88–#94 remains unstarted.

For the five fixed retained domains, configured, controller-queued and
server-sent resource limits are zero. A concrete private driver overlay can
remove output time parsing without changing answer rules, task preparation,
or the selected serial continuation. The source transfer below accounts for
its additional location-table name and the removed regular-expression work.
It preserves the initial identifier counts and relevant semantic graphs under
the named source/runtime relation; it does not equate complete captured heaps.

The [packet](../evidence/retained-response-timing-config-20261020/README.md)
contains the exact candidate bytes, source witnesses, capture joins and
arithmetic checker. The checker validates those finite inputs and calculations;
the control-flow and allocation simulation here is a source argument, not a
machine-checked OCaml proof.

## Scope and exact recipe

Use each retained fresh invocation, its base `why3.conf`, cwd, socket and
private-overlay pathname spelling, executable, source JSON, plugins and native
services unchanged. Keep CE off, serial `Per_Check`, non-replay mode,
`--steps 0 --timeout 0`, and
`OCAMLRUNPARAM=s=256M,h=16M,M=1000`. No warning-timeout or parallelism change
is part of this recipe. The retained server is `-j 1`; prospective parallel
execution still requires its own prefix/ownership transfer.

Materialize the packet's five driver files and 18-byte `overlay/why3.conf`
in a private copy of the retained overlay, using the original overlay path
within the paired invocation. This is a prospective filesystem configuration,
not an instruction to overwrite a live evidence workspace. The base config
remains exactly 1,946 bytes, SHA256
`f83746bab113aeaa0d1b3ccfd13a2ce0cd965f2673ac89b84973fd4b121dd1fb`.
The extra config is exactly `[main]\nmagic = 14\n`; it does not set memlimit.

Retain the original CVC5, Z3 and `silver_cvc5_no_steps.gen` bytes. In the
private Alt-Ergo driver, replace line 18's
`time "why3cpulimit time : %s s"` by the 31-byte comment
`(* time measurement removed  *)`, preserving its LF. Add a
private `smt-libv2.gen`, identical to the pinned installed file except for
the same replacement at line 23. Both lines remain 32 bytes. All other
bytes, including answer directives, imports, printer, transformations,
metadata, theory rules and preludes, remain identical.

`Gnat_util.find_driver_file` selects the existing three private roots;
`Driver_lexer.parse_file_gen` resolves an import beside the importing file
before the installed driver directory. Thus the three selected roots now
reach the private `smt-libv2.gen`. Its import list is empty. The other ten
installed members of the selected 14-member closure retain their paths and
bytes. Root/import order and logical source identities are unchanged except
for the two explicit time-directive omissions and the shared file's physical
path. Other configured roots remain installed and use their installed
imports. This does not silently change all nine configured drivers.

`Driver.add_global` dispatches `TimeRegexp` only to `timeregexps`; the other
driver fields do not read it. The loaded selected time-rule counts change
from CVC5/Z3/Alt-Ergo **1/1/2 to 0/0/0**. The answer-rule order is exact.
There are still no steps-measurement directives; direct
`StepLimitExceeded` answer directives remain present. `recipe.json` binds
all original members, every changed byte, the local files and the loaded
non-time response projection.

## Configured limits are the limits actually queued and launched

The composed [warning exclusion](retained-why-warning-exclusion.md), author
freeze `29e253ba8d4d7905336f137801e4ef6c39718d43`, establishes
`warning=false` for every selected attempt under its fixed-domain
registration/immutable-metadata and serial-continuation relation. This
includes permitted repeated selections after escaping save exceptions.
Its independent review is composed by the lead; this packet does not replace
that review or extend it to a different scheduling domain. The default
one-second warning limit is therefore unreachable here. Diagnostic warnings
from `Loc.warning` are a separate concept.

The source chain is as follows (complete slices are in `source-witnesses.json`).

1. `gnat_config.ml:23–29,110–129,567–575,629–655` starts `opt_steps=None`.
   `set_steps 0` leaves it `None`; `set_timeout 0` stores `Some 0`.
   With CE off and `warning=false`, time is `0.`. No memlimit argument is
   present, so the automatic-prover memory limit is the empty value `0`.
   The base config's memlimit is also zero, but the source proof uses the
   actual option-to-`limit_mem` path. The base **does contain `command_steps`**;
   unset raw steps bypass the CVC5 15,000 and Z3 450,000 conversion offsets.
   The configured record is `(time=+0., mem=0, steps=0)`.
2. `controller_itp.ml:619–652` passes the configured limits to
   `graft_proof_attempt`, but stores **adapted limits** in `spa_limits`.
   These are distinct objects/roles; reading `pa.limits` alone would not prove
   what is launched. Adaptation receives `use_steps=false` because configured
   steps equal `empty_limits.limit_steps`.
3. Every branch of `adapt_limits` (`:347–392`) preserves this zero triple.
   The nontrivial expression is
   `max 0. (min (1. +. 2. *. old_time) (2. *. 0.))`. In the retained OCaml
   `Stdlib`, `min x y = if x <= y then x else y` and
   `max x y = if x >= y then x else y`. For NaN the inner comparison is
   false and chooses `+0.`; for any non-NaN intermediate the outer maximum
   is `+0.`. This includes infinities, negative values, overflow to infinity
   and signed zero. It is not a real-number-only argument or an assumption
   that old times are finite. `3*0/2=0`, and the Valid branch chooses zero
   rather than evaluating `old_steps+1`. Failure/HighFailure and absent old
   results preserve zero directly. Thus the invariant holds across retries
   without resetting the global save/exception budget.
4. Queue removal (`:528–533`) preserves `spa_limits`.
   `build_prover_call` (`:412–431`) reads it, chooses
   `with_steps = (0>0) = false`, and passes it through `Driver.prove_task`
   and `prove_task_prepared` (`driver.ml:450–494`) to `call_on_buffer` and
   `call_on_file`. The ordinary selected commands contain `%f`, with no
   `%t`, `%.t`, `%T`, `%m` or `%S` substitutions imposing a solver limit.
5. `actualcommand` eagerly computes integer time substitutions even if unused
   (`call_provers.ml:404–429`). Here its `ceil`, multiplication by 1,000
   and float-to-int conversions receive exact finite zero; no NaN/native
   conversion ambiguity remains. `saved_data.limits` retains queued zero
   limits for result parsing. The second adaptation (`:448–458,507–534`)
   returns immediately on zero time, before the `2*t+1` / `4*t+1` branches.
6. `Prove_client.send_request` serializes `0.` and `0`; the native request
   parser uses `atoi`, yielding integer zero for both. `run_request` passes
   those values to `create_process`. The selected Unix server sets CPU/AS
   rlimits only under `>0`, and its conditional core-limit adjustment also
   does not run. This establishes absence of these **configured** limits;
   inherited OS/cgroup limits and attributable failures remain the trusted
   native-service/attempt-record question.

In `parse_prover_run`, both postprocessing guards require a positive limit
(`stepslimit>0`, `tlimit>0.`). Neither can turn an answer into a step limit or
timeout here. Direct answer rules can still return either kind. A native
signal is not by itself an OOM or timeout attribution.

## Results, warnings, scheduling and cost fields

Removing time directives does not change `analyse_result` or its warning
emission. Compose the [response adapter](retained-solver-response-adapter.md)
only at its accepted answer-kind/warning-presence quotient, retaining its
complete attempt-bound record before canonical bytes. Its canonical output
contains no `why3cpulimit time` line. This packet additionally ensures that
an arbitrary accepted raw output cannot inject a parsed timing value in the
candidate configuration.

With an empty time-regexp list, `grep_time` returns `None`; Why3 uses the
server time. On this Unix route, the server obtains it from `wait3`'s
`usage.ru_utime.tv_sec + usage.ru_utime.tv_usec/1000000.0`, emits `%.6f`,
and the client reads it as a float. Under the ordinary native accounting
relation those integer fields are finite and bounded by their native integer
representations, far below the double overflow range. A delivered response
therefore supplies finite nonnegative time. This is **the server's user-CPU
accounting for the launched/reaped adapter process**, with whatever child
accounting the native service supplies. It is not an established measurement
of raw solver wall time or raw solver CPU time. An oversized or malformed
server response is not silently accepted as a successful measurement.

The parser clamps a normal completed result to at least `0.000001` seconds.
The controller's `fuzzy_proof_time` may subsequently substitute an old time
for a same-group result; that does not change its answer. It can restore a
trivial proof's zero time, so the parser's floor is not asserted as a universal
final-session floor. Missing-file queued cancellation uses its separate
`Failure "interrupted"`, time and steps-zero path. Normal selected results
have `pr_steps=-1` because there is no steps measurement. GNAT's back
conversion reports **1** for that sentinel in each selected prover's JSON
cost field; this is not one observed solver step.

Time affects `find_successful_proof`'s fastest selection **among already Valid
results**, and therefore may change prover credit and max-time statistics.
`gnat_main.interpret_result` passes only `answer=Valid` to the proof result
handler. The serial best-untried route and the parallel callback's
Valid/cancel branch do not choose success from time; the latter source fact
does not claim a transferred parallel execution or identical callback order.
Changing real execution can change completion order even when the scheduling
predicates are unchanged.

The strict report predicates do not use time/steps to establish success.
`silver_library_reports.adb:2333–2345` requires empty `warn_error` for these
library audit kinds. Application audits allow only their exact
`Image_Advisories` exception; a generic consecutive-answer warning cannot
satisfy that shape (`:1248–1263`). The null report policy requires an empty
warning field (`silver_reports.adb:15,104`). However, `Loc.warning` reaches
`Gnat_report.add_warning` and its top-level `warnings` JSON list, and the
retained SPARK `gnat2why-error_messages.adb:1301–1312` **only prints those
strings with `Ada.Text_IO.Put_Line`**. It does not insert them into final
`warn_error`. Thus these auditor predicates do not establish rejection of
either raw or canonical consecutive-answer warnings. The adapter preserves
warning presence, with possibly different multiplicity/text; an explicit
future consumer policy and producer/report/attempt binding remain the lead's
separate outcome-policy join. No warning-rejection preservation theorem is
claimed here.

## Source prefix simulation

The paired boundary is the accepted first `Exn_printer.entry`, before Why3
counters and caches. Cuts are the four fresh registration endpoints and
Input_Is_Valid's first `inline_trivial` entry, before application. Use the
same relevant Why3/OCaml/tool-source relation and ordinary successful-prefix
native services as the retained prefix evidence: no delivered asynchronous
control change, injected fault, worker, profiling/GC override or failed
registration. Resource-triggered GC is ruled out below rather than assumed.

The lexical edit preserves every byte offset, line and column of each
remaining token. `Lexlib.comment` consumes the two replacement comments
without producing parser tokens. Removing the two `TIME STRING`
productions deletes their global AST/list entries. The grammar's right
recursive global/theory list otherwise performs the same reductions; its
token stack cannot require additional growth. Driver-global dispatch deletes
only four loaded time-regexp constructions. The driver theory traversal,
theories imported from the environment, syntax/metadata objects and fresh
driver-export identifiers are constructed in the same order.

The physical path change must be included. Each selected local import uses
the first candidate that the baseline already constructs and unsuccessfully
tests; the baseline then constructs the longer installed path. The candidate
removes that fallback work. There are no extra path allocations or extra
file opens. `Loc.FileTags` now recognizes the private spelling, while
unselected installed drivers can retain the installed spelling: **at most
one extra distinct filename**, not a bijection of every raw location field.
The recipe's exact paths are in `invocations.json`; both new spellings are
shorter than their old installed spelling.

Driver `loc` values are used for error attribution and the fresh export
theory's `id_loc`; successful rule lookup uses qualified symbol names and
identifier tags. `Ident.id_hash` / `id_compare` use `id_tag`, not `id_loc`.
The driver's export locations therefore do not change the metadata/task
cache keys or register new identifiers. For all other filenames, inserting
the possible extra file tag preserves the order and equality of their tags;
line/column values are unchanged. Their `Loc` equality/order decisions remain
equal. Term hashing has no location input; location-sensitive term comparison
keeps the same decisions. The selected source consumer inventory distinguishes
model/IDE/error paths from the actual prefix; CE is off. Sorting input-file
theories by locations also preserves their order. No assertion identifies
the split driver's original and candidate location-table integers.

Project onto raw task/check/session topology, immutable semantic objects,
sharing, identifier/driver tags, logical cache keys and driver-root/import
associations. Relate non-driver source locations by the order-preserving file
tag insertion; relate driver diagnostic locations by their import occurrence
and unchanged line/column, with the one explicit path substitution. Drop
time-regexp objects, parser scratch, location-table bucket layout and stale
regex match scratch from the projection. This is sufficient to preserve
symbol, type and task requests; it is not a claim of bit-identical driver
objects or full heaps. Initial registered check metadata remains the same
under the accepted warning-exclusion relation.

Deleting regex work also needs a source justification. The retained Re
behavior source at `f09672608781dc05172ad980a6e9a483c3b9d534` shows:

- `Str.compile_regexp` creates each AST and lazy compiled regexp independently.
  `Compile.compile_1` creates fresh automaton IDs, color map, group position,
  name list and set cache; `mk_re` creates its own working area/state table.
  Automaton IDs begin at zero **per compile**, not in a process-global counter.
  `Ast`, `Cset`, `Color_map`, `Parse_buffer` and `Bit_vector` supply no shared
  compilation cache on this path. The common unknown-state sentinel is read,
  not populated with a different regexp's transitions.
  This is the selected Str/Emacs path: the separate `Ast.mark` constructor
  calls `Pmark.gen`, but the Emacs parser does not invoke it. No claim of
  purity for every public Ast constructor is needed.
- Thus removed time-regexp work cannot remove a shared warmup that makes a
  later regexp allocate more. Existing constants/module initialization are
  unchanged. `Str.state` is separate last-match scratch. The removed
  `global_substitute` on the fixed time pattern finishes with a failed search,
  which sets this scratch to `None`. Remaining group/offset consumers in the
  selected source path execute their own match/search first; no caller uses
  the deleted match result. No interleaved callback is admitted at this cut.

These eight newly retained Re implementation files are **behavior-premise
evidence, not identification of the historically installed Re version**.
The relevant-source relation must cover this per-regexp allocation/state
property as well as R51's matching behavior. The exact reference implementation
settles the source-design question; it does not supply missing binary provenance.

## Conservative finite allocation credits

Charge all candidate `Loc.FileTags` work, rather than guess the delta of a
single insertion or a shifted resize. Its two `Hashtbl.Make` tables have one
four-word bucket cell per filename apiece. `get_file_tag` only finds/adds;
neither table is traversed during insertion, so resizing reuses bucket cells.
Each resize allocates a data array and a temporary tail array, doubles
capacity, and writes at most three pointer fields per existing entry, plus
the table field. Lookup hash/collision comparisons allocate no managed object.

Let A be the retained maximum cumulative major allocation, **945,213 words**,
and N the number of baseline FileTags names before a cut. For N>512, each
table's current capacity is at least N/2 and its backing is a major block
(capacity at least 512). Their two live backings therefore account for at
least N of A's words. For N<=512, N<=A directly. No collections or table
removals occur in the retained prefix. Both tables begin after the protected
boundary. Consequently baseline N<=A, and candidate **N'<=945,214**. This
bound derives from the two backing arrays, not an unobserved FileTags count.

Across geometric resizing, the sum of capacities is less than twice the
last capacity. For the two tables and their temporary arrays this is at most
8N' payload words (the small initial-capacity case is covered below). The
two tables' bucket cells cost 8N' words. Minor arrays through capacity 256,
all array headers and resize closures, two padded lexical lines loaded four
times, and parser/lexer scratch are covered by a separate **16,384-word**
allowance. The changed lines total only 128 loaded bytes; even charging two
six-word direct-lexer tuples plus a five-word position per byte costs 2,176
words. Table-generator lexing is cheaper. Existing string-buffer growth is
only removed/delayed; replacement comment tokens are at most three bytes and do not grow
the fixed 1,024-byte lexer backing. At most 20 table capacities per table
are relevant below N'; charging 128 words of closure/header overhead at each
capacity adds at most 5,120, and all minor data/tail arrays contribute below
4,096. The allowance covers these disjoint charges.

Use both a minor and major credit of

`Δminor = Δmajor = 8*945214 + 16384 = 7,578,096 words`.

This deliberately overcounts removed regex/AST work and all original
FileTags work. Pointer stores are bounded by four per insertion per table
and three per entry moved during resizing. The geometric sum of moved entries
is at most `2N' + 20` per table. Including closures/table fields and lexical
updates gives the conservative remembered-reference credit

`R = 20*945214 + 16384 = 18,920,664 entries`.

No candidate ephemeron or custom object/resource request is added. Other
matched allocations retain their sizes and minor/major classification;
FileTags allocation/writes are entirely included in these credits. The new
arrays can be major, so this proof does **not** import the quiet command's
minor-only 4,096-word estimate.

| Quantity | Retained maximum | Candidate upper bound | Bound checked |
| --- | ---: | ---: | ---: |
| Minor bump words | 127,939,731 | 135,517,827 | <268,435,456 |
| Current major allocated words | 945,213 | 8,523,309 | <268,435,456 GC trigger |
| All major allocation including prior 2,911 words | 948,124 | 8,526,220 | <16,777,216 initial heap |
| Remembered references | 68,961 | 18,989,625 | <33,554,432 |
| Ephemeron entries | 146,291 | unchanged | <33,554,432 |
| Custom-table entries | 84 | unchanged | <33,554,432 |

The captured `stat_major_words=2911` accounts for the startup allocation
preceding the current `caml_allocated_words` counter; it is added for the
arena calculation, not silently omitted. There have been zero major
collections and one heap chunk throughout. In the retained runtime,
`caml_init_major_heap` makes one free block here (the arena is below
`Max_wosize`); idle normal allocation splits that block. Returning to idle
after sweeping increments `stat_major_collections`, so the captured zero
count and idle phase exclude a prior sweep. The pre-boundary startup minor
collection only promotes into that arena; its 2,911 words are charged above.
The retained normal-service/runtime relation excludes external native heap
mutation. Even `Obj.truncate` leaves its remainder as a colored heap block,
not a new freelist hole. Thus the unallocated remnant remains contiguous
before a first major collection, and the checked total guarantees room for
every additional block. This is a derivation from the retained startup and
allocator history, not a free-space test for an arbitrary fragmented heap.
The native allocation total fits the initial major arena, and
every added array is below N'+1 words. No major growth/resource charge is
needed. Retained custom-resource fractions stay below one and dependent
memory remains zero. All new lengths, tag counters and native integer
arithmetic are far below representation bounds.

Suppose the candidate first collects or requests a collection before its cut.
Until then, the source projection gives the same semantic/cache requests;
address-independent hashes and preserved equality retain the same weak-cache
decisions. The changed lexer/regex/FileTags subtrace is bounded as above.
All bump, major, table and resource quantities stay strictly below their
triggers, contradicting a first event. This establishes no-GC and cache
preservation together; it does not assume weak-cache equivalence after GC.

No changed operation registers a Why identifier. The semantic registration
sequence is therefore identical, and the native five-word/no-abandoned-
registration argument rules out a first identifier wrap using
`5*I <= candidate_minor_upper < 2^28 < 5*2^62`.

| Domain | Retained PID | Preserved initial I | Cut |
| --- | ---: | ---: | --- |
| Put_Line | 17310 | 136,844 | End of registration |
| Put | 17514 | 121,505 | End of registration |
| First_Or_Default | 17631 | 77,806 | End of registration |
| Is_Message | 17704 | 59,035 | End of registration |
| Input_Is_Valid | 17869 | 60,496 | First inline entry |

The type-symbol and initial tuple-entry counts remain at most I, and their
two-family union at most 2I. These are initial counts, not maximum arities or
later registration bounds. The source transfer keeps the raw task/theory to
driver association needed by later preparation; it does not just preserve a
numeric count. Input_Is_Valid reaches command selection once but neither
task printing nor `actualcommand` before this cut; its ordinary command bytes
are unchanged. No prior expensive checker was replayed.

This closes the selected source-level zero-limit/timing configuration and its
serial prefix transfer under the named source/runtime premises. It leaves
pre-entry output bounds, whole q/O, later capacity obligations, attempt-record
and enclosing report binding, implementation refinement and any parallel
transfer separate. One global two-save-entering-callback/three-save/e<=2
budget remains per process throughout; it is never renewed per attempt.
