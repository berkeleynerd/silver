# Retained parallel logging startup and registration transfer

2026-10-20; R55 research for #119/#153. This supplies the changed-prefix
component left open by [R54](retained-fixed-goal-attribution.md), for the five
fixed R53 J12 domains. It does not implement #88–#94, amend the Oracle, adopt a
production launch profile, or establish the complete response/storage bound q.
The [packet](../evidence/retained-parallel-logging-prefix-20261020/) contains new
offline projections of retained bytes and static installed-code witnesses.
No R55 target process, solver, proof replay or predecessor checker was run.

## Scope and entry conditions

The reference invocation is each actual R53 capture: installed gnatwhy3,
`-j 12 --entity <fixed> --prover cvc5,z3,altergo --proof per_check --steps 0
--timeout 0 --counterexample off --why3-conf <fixed-overlay>/why3.conf --socket
<private>/server.sock <fixed-relative>.gnat-json`. The external server is the
retained single-client `-j12` server. Environment is exactly PATH `/usr/bin:/bin`,
LC_ALL `C`, private TMPDIR, and `OCAMLRUNPARAM=s=256M,h=16M,M=1000`.
The proposed changed invocation inserts **one** `--logging` immediately after
argv[0]; the packet records all five complete before/after argument vectors.
There is no replay, line/region filter, `GNATWHY3LOG`, populated session, extra
plugin, runtime randomization or GC override. Fresh input/session ownership and
the inherited fixed file/config/driver correspondence remain required.

For the numeric credit below, retain the R53 pathname lengths and equality
relationships, or an allocation-equivalent relocation. The logger target is a
fresh, private ordinary regular file at `unit_name ^ ".why3log"`, with successful
ordinary open/lseek service and adequate resources. No asynchronous handler,
profiling callback or native hook may alter the prefix. This is an explicit
control condition, compatible with the separately examined inherited SIGINT
mask profile; the captures did **not** measure that proposed mask. The added
open/leave-blocking-section points can otherwise run pending actions. A failed
open, resource failure or external termination does not reach the claimed cut;
its diagnostic/exit cost remains a separate aggregate obligation. The result
does not silently classify those paths as observation-only or prove totality.

## Startup delta and control order

The retained ten-file GNAT implementation scan finds just two logging reads:
`gnat_checks.ml:415` initializes the channel and `:1064` logs a scheduling
callback. Configuration stores `Arg.Set opt_logging` at `gnat_config.ml:214`
and exports it at `:744`. The two parallel reads are post-result retry at
`gnat_checks.ml:621` and scheduling at `:1055`; neither is on registration.

`gnat_main.ml:316–360` initializes settings/unique prefixes, skips the absent
GNATWHY3LOG branch, calls `init_cont`, installs the SIGINT save handler, registers
subprogram VCs, schedules, then enters the main loop. In `init_cont`
(`gnat_checks.ml:380–415`), empty-session construction, controller/driver loading
and `add_file` precede the external-server connection and `Logging.init`.
The logger init is exactly `outc := open_out (unit_name ^ ".why3log")`
(`:57–60`). It therefore occurs before both SIGINT handler installation and
registration/splitting. It constructs no formatter, JSON record, transformation,
Why3 identifier, hashcons node, session ID, environment ID or driver ID.

The precise added successful-path managed allocations on Linux x86_64 are:

| Addition | Managed words, including headers | Witness |
| --- | ---: | --- |
| One argv string of 9 bytes and one argv-array field | 4 | `sys.c:422–462`, `alloc.c:79–125`; array grows 20→21 fields |
| One ordinary exact-match Arg option | 27 | installed `parse_and_expand_argv_dynamic_aux_611+528` subtracts 216 bytes; `Arg.Set` only checks absent follow-argument and stores true |
| Concatenated log pathname of L bytes | `1 + ceil((L+1)/8)` | installed concatenation plus `alloc.c:79–97` |
| Output-channel custom wrapper | 3 | `io.c:505–526`, `custom.c:48–50` |

The installed `assoc3` exact-match branch does not take fallback splitting or
error construction; string comparison does not allocate managed blocks. The
per-option closure allocation is counted even though some closures are unused.
Installed `Logging.init`/`open_out_gen` use the static flags-list object; no new
list is charged. The retained 962 instruction-byte rows are checked against the
pinned installed ELF, not inferred solely from source-level closure syntax.

Native allocation requests add a 65,616-byte channel, one temporary pathname
copy of L+1 bytes in `sys_open`, and one persistent channel-name copy of L+1
bytes (`io.c:94–123,529–537`, `sys.c:197–227`). The temporary copy is freed before
the persistent copy. These are allocation-request sizes, without an allocator
metadata bound. The process launch also has one extra native argv pointer slot
and 10 argument payload bytes; aggregate startup accounting must cover its
platform stack/alignment costs. A new descriptor and channel-list member persist.
Its initial buffer occupancy is zero, and its ordinary fresh-file offset is
zero. It contributes no output bytes before registration. Final channel flush/
exit ownership and later logging allocations belong in the aggregate bound.

The output-ref store adds at most one remembered-reference entry. If its
overwritten stdout pointer invokes `caml_darken` during mark, stdout is a custom
block (`Custom_tag=255 >= No_scan_tag=251`), so it cannot push a mark-stack entry
or allocate there (`memory.c:633–656`, `major_gc.c:278–305`). This may change a
color/ephemeron-purity flag; equality of internal mark work is **not** claimed.
The channel adds one custom-table entry, zero ephemeron-table entries and no
dependent-memory charge. Its resource accounting is mem=65,616,
mem_minor=8,192, major remainder=57,424, with the exact integer denominators
`(2^28 * 8 // 100) * 100` and `(2^24 * 8 // 150) * 1000`.

## GC correction and prefix credits

The earlier [prefix GC note](retained-producer-prefix-gc.md) labels recorded
phase 0 “idle.” That label is wrong: retained `runtime/caml/major_gc.h:55–58`
defines mark=0, clean=1, sweep=2, idle=3. In all five R53 captures the initialized
runtime is phase3; the first-Why3 boundary and registration are phase0, **mark**.
The old finite counter comparisons remain what their bytes say; their phase
interpretation is corrected here. No equality of future mark budgets follows
from equal phase numbers.

Re's inherited startup initializer forces one minor collection before Why3
counters/caches. Its position is not inferred from phase equality. Every R53
startup guard sequence is exactly minor_collection→gc_dispatch→empty_minor_heap
→major_collection_slice, with backtraces through `caml_make_vect`,
`Re.Dense_map.make` and `Re.Cset` initialization. The total pre-collection minor
allocations are 3,289/3,305/3,293/3,308/3,293 words in the table's domain order;
with the added argv words, the maximum is 3,312, far below 2^28. Until a
hypothetical earlier automatic collection, the startup source/request sequence
is unchanged except for those four words. They add no custom resource or direct
major allocation before promotion. The first-trigger argument excludes an
earlier automatic collection. At the same explicit `array.c:239–243` call the
initializer is still young, so the forced collection remains at the same source
point, with the same other live roots. This bounds extra promotion by four
words; it does not assume a shifted collection has the same surviving set.
The added argv words are rooted and promoted there. Source
`minor_gc.c:462–502,565–578` clears request flags and restores the young trigger;
`major_gc.c:1084–1093` starts a cycle from idle when the arena is empty, sets
`p=0`, and exits without executing `mark_slice`. `start_cycle:400–417` establishes
the mark-root subphase and ephemeron iteration state. The new argv string/field
can alter the root set; no exact old/new mark-stack or work-budget equality is
needed. The protected prefix has no subsequent slice/clean/sweep/weak clearing.

For a conservative envelope, charge the four argv words both to current-minor
allocation and to major allocation, although the forced startup collection
promotes them. Let delta_minor=`4 + 27 + path_words + 3`, delta_major=4.
The actual J12 endpoint counters plus these deltas are:

| Domain | L | delta_minor | minor words upper | major allocation words upper | ref entries upper | ephe entries | custom entries upper |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 27 | 39 | 127,939,532 | 945,217 | 68,962 | 146,291 | 85 |
| Put | 22 | 38 | 116,661,244 | 889,806 | 68,641 | 145,931 | 85 |
| First_Or_Default | 42 | 41 | 87,937,762 | 763,838 | 63,050 | 138,639 | 85 |
| Is_Message | 36 | 40 | 77,776,344 | 623,206 | 59,717 | 133,992 | 85 |
| Input_Is_Valid | 40 | 41 | 78,761,834 | 630,052 | 60,032 | 135,215 | 85 |

Minor/major resource fractions become at most 0.0003128056484342883 and
0.005262463343108506. Both allocation guards are 2^28 words; remembered-table
thresholds are 33,554,432 entries. All inequalities remain strict. The checker
recalculates the fractions and compares each table with its captured threshold.

The transfer uses a first-trigger contradiction, not just small endpoint
totals. Before a hypothetical first additional protected collection/request,
the inherited fixed-context source relation preserves the ordinary constructor
and cache trace modulo address renaming. The only new successful-prefix
requests are those enumerated above. Their monotone cumulative envelopes stay
below every allocation, custom-resource and remembered-table trigger. No
explicit collection, dependent-memory request or setting override is selected.
Thus there is no first triggering route in this controlled prefix. Weak entries
are not cleared, regardless of the changed coloring of nonlogical argv/channel
objects. GC metadata itself is not asserted identical. This reasoning uses the
inherited source exclusions and newly bounded delta, together with the retained
R53 protected-entry guards, rather than treating observed no-GC as universal.

## Constructor trace, goal IDs and serial-table interface

The new input-role audit joins each old R28 serial capture with its actual R53
J12 capture. Each pair has exactly 81 successful, read-only file opens in the
same order. Whole private-root substitution preserves the **full** path suffix,
both requested and resolved paths, and each byte count/SHA256; basename matching
is not used. All seven mapped-file identities agree. The normalized argv differs
only by `-j 12`; the normalized controlled environments agree. The no-GC guards
and unchanged protected GC statistics are checked independently on both sides.
Path lengths differ between the old serial and J12 contexts: this join claims
no equality of their allocation totals.

The source relation is stronger than raw-result equality. The fixed modules,
config content, driver resolution/load order, relative JSON name/content,
plugins and fresh-session branch give the same pre-registration control and
Why3 constructor sequence. Private directory strings affect file access,
storage/diagnostics and native allocations; they do not become new logical
symbols or branch selectors in this prefix. `gnat_config.ml:675–740`,
`controller_itp.ml:263–285` and `sysutil.ml:209–230` preserve the relative input/
session roles. The external socket connection completes before registration
but cannot schedule a prover until the later main order. The only changed
parallel reads are after the cut. Hashing uses fixed strings/scalar tags and
sharing, not numeric placement; the inherited fixed-context argument for
`Weakhtbl`, Hcpt, nonrandomized Hashtbl/Ephemeron and selected plugins applies.
No weak clearing intervenes in either retained interval. Induct on this
constructor trace, preserving sharing and tag generation under address
renaming. This includes intermediate declarations that are absent from the
final raw tasks: `split_goal_wp_conj` invokes `Gnat_rewrite.elim_to_of_array`
(`gnat_split_conj.ml:315–324`), whose `Dprop` branch rebuilds every proposition
under its same prsymbol (`gnat_rewrite.ml:130–137`). Raw graph equality alone
would not establish this intermediate-table fact.

Consequently the four R28 registration tables can be transported to the R53
registration cut under the constructor relation, then across the logging delta.
For Input_Is_Valid, the old capture ends at `inline_trivial_entry` after the
first CE. Only its **prefix through registration** is transferred here. Its old
mutable table is not equated to the new registration table. Any use of that
later finite table as an overapproximation needs the separate no-removal/subset
lemma owned by the post-registration cache component.

For the new logging invocation itself, no added path advances any of the four
session generators (`session_itp.ml:275–294`). The native 17-field record
projection independently checks all tables against the exact ranges
0..nextID−1. The five `(nextNode,nextPA,nextTrans,nextFile)` tuples are:
Put_Line `(65,14,1,1)`, Put `(54,12,1,1)`, First `(33,10,1,1)`, Is_Message
`(4,1,1,1)`, Input `(5,3,1,1)`. Proof attempts include synthetic trivial children,
including children that do not become registered roots.

Every forest has parent goal0, transformation0 `split_goal_wp_conj`, and
children1..nextNode−1, without detached/child transforms. The transformation
name was a retained static pointer without its string bytes: the packet joins
its recorded load bias to the pinned installed ELF string, explicitly not a
new target-memory read. The R54 restricted alpha-opening projection checks
6,747 binder records and reproduces the actual goal labels/triviality and all
118 registered root mappings across 161 raw goals. Its variable-only opening
lemma is reused, without native alpha replay or a rerun of the accepted R53
whole-raw correspondence. Exact session counter traces, unchanged registration
attributes and integer goal ordering preserve the R54
`(domain,goalID) → (checkID,kind,descending-root-index)` map in the proposed
logging profile. Pointer addresses and proposition names are not substitute IDs.

The later changed callback is still precisely the parallel scheduler closure:
it looks up the proof-attempt prover and calls `Logging.log g prover pas` before
the remaining-count/result branch. Logging creates formatter/JSON objects and
does I/O there; errors/reentrancy and those later allocations require the
separate callback/capacity argument. The R54 one-unacknowledged-F completion
delivery gate, producer-closed drain and final seal remain conditional protocol
requirements. This prefix component adds no time/step identity tag, tool patch,
solver serialization, extra per-process save budget or whole-q claim.

## Evidence and handoff

The checker pins twelve input archives, the predecessor context/graph projector,
47 source slices, the ten-file control-use inventory, the static installed-byte
witnesses and both frozen new projections. It executes only these new finite
checks. Exact final timing/platform and author settings are recorded in the
packet's round record and check result. Source/control transfer and the
first-trigger argument require independent review; successful projections do
not turn them into a mechanically verified universal theorem.
