# Populated Why owner bounds before Main JSON input

2026-10-24 UTC; author unit of #202 under #119, pending independent review.
**The accepted fixed-prefix allocation evidence restricts to a populated,
Main-content-independent entry envelope at cut C:** after
`Controller_itp.create_controller` returns in `gnat_checks.ml:396`, before
`Controller_itp.add_file` at `:399`. For the current R78 prospective recipe,
the largest Ident entry bound is **27,104,344** and the largest complete
managed/static carrier bound is **146,200,712 words**. These are upper bounds
on the actual constructed state, not invented exact counter values or empty
tables. The [packet](../evidence/retained-main-entry-capacity-20261024/README.md)
supplies a finite configuration/launch-role function and exact reused inputs.

This closes the entry-envelope obligation left by the first
[stored-term kernel](retained-main-why-storage.md) for the matching launch
relation below. It does not count Main's subsequent typing/kode/SPWP calls,
establish its case-free attachment, or complete #202/#119. It changes neither
admission nor tools, pins, production #88–#94 or the Oracle. The physical
memory/stack/disk and native-service premises remain. One process-wide
`e <= 2`, two save-entering callbacks and three saves is retained.

## The exact input relation at C

Choose one of the five retained launch roles, with its actual argv,
configuration path, native relative input filename, cwd/private-root/path
relations, environment, plugins and library/driver identities. Use the
[R56 combined startup](retained-combined-parallel-startup.md), corrected by
[R78's resolver and configuration repair](retained-fixed-failure-composition.md#successful-prefix-allocation-and-semantic-transfer).
This means the repaired private root/common names, quiet command, two
time-directive removals, J12 server selection, logging and the exact 2,069-byte
base configuration; it does not mean the older resolver's incorrect
first-local-match behavior. All nine configured provers load before C,
including unselected later provers. The complete repaired closure has 28
distinct files and 57 driver-open occurrences.

Replace only the native input file's **contents** with the actual generated
Main JSON. Keep its filename and observed pre-C filesystem classification
(existing, nondirectory), the fresh-session branch, fixed nonaliasing config/
driver/library inputs, and their stable candidate membership. The Main input
does not alias any earlier-read input. The owner need not provide a demand
certificate, term graph or cache state. This is a source/configuration theorem
about the compiler-produced Main bytes. It even holds for arbitrary bytes in
that file before parsing; it makes no later assertion about invalid bytes.

The relation permits only the already-proved allocation-equivalent relocation,
preserving pathname dimensions/equalities. It does not cover an arbitrary
`main.gnat-json` spelling, cwd length or newly added config/plugin. A future
launcher must attach its chosen canonical native filename/layout to this
relation, as it already must for the accepted prefix. Relocating paths requires
its own allocation relation; a diagnostic pathname bound alone does not supply
one. The five role names select reference launch descriptors and numeric
envelopes, not five languages or author source formats.

The source dependency argument is:

1. `gnat_config.ml:267,346–401` parses fixed argv, reads the fixed configuration,
   selects provers, loads the two fixed plugins and creates the fixed Env
   loadpath. The native filename is accepted by suffix at `:552–563`.
   Unit-name/path operations at `:675–693,714–742` use its spelling,
   `Sys.file_exists` and `Sys.is_directory`, not its contents or length on disk.
   `--prepare-shared`, replay, proof-dir, debug/inference/profiling and
   `--limit-lines` are absent; in particular the alternate file reader at
   `:758–768` is not selected. Controlled environment/path/service outcomes
   retain their accepted roles.
2. Module initialization and `gnat_main.ml:316–332` register fixed callbacks,
   flags and unique prefixes, then enter `init_cont`. The optional
   `GNATWHY3LOG` branch is absent in the controlled environment. The outer
   `Debug.Stats.record_timing` frame can retain a clock value, but its finalizer
   has not run at C. No clock value controls a pre-C allocation length or
   shared-owner lookup. Address, clock and incidental native state need not be
   identical; the accepted constructor/allocation projection is the relation.
3. `gnat_checks.ml:380–396` chooses the same fresh session and completes
   controller creation. `load_drivers` (`controller_itp.ml:114–137`) loads
   every configured driver using only configuration/Env/fixed input state.
   Its repeated import/library reads are part of the retained prefix.
   No Main input content is among those reads. The session's four next-ID
   counters start at zero (`session_itp.ml:620–626`); this says nothing about
   the already populated global Ident/type/declaration owners.
4. Only after C does `add_file` call `Session_itp.read_file` and
   `Env.read_file`. The native JSON plugin then calls
   `Yojson.Safe.from_channel`, converts the Gnat/Ptree input and invokes
   Typing. The first-kernel packet pins that exact final route. Changing Main
   contents therefore cannot change the pre-C constructor/allocation trace
   under the same selected native/service/control projection.

All module initializers and driver calls have returned at C. There is no
suspended shared-owner insertion/resize beneath C; the outer timing frame is
not such a mutation. Later input errors, detached sessions, registration,
callbacks and saves do not execute backward across this cut.

## Why restricting the retained allocation is valid

The original [GC evidence](retained-producer-prefix-gc.md) establishes
`W = 86,632,681` protected lifetime managed words for its largest original
fixed process. Its interval begins at the first Why module,
`Exn_printer.entry`, before the Why counter/table initializers, and ends after
successful `add_file` at entry to `Gnat_checks.init`. It is not the final live
heap: the native `%r15` minor consumption and cumulative major allocation
count all requested objects, including garbage and discarded candidates.
The accepted no-protected-collection argument excludes resets/reclamation,
using complete collection/request guards and the relevant source projection.
Startup/static overcounts were separately recorded. Thus for that matching
original configuration, every nonnegative allocation prefix through C is at
most W, and every reachable managed/static carrier at C is bounded by its
original `88,828,616`-word overcount.

The restriction needs no new observation at C and no subtraction of final
live objects. If `a_1,...,a_n >= 0` are the charged allocations of a matching
completed reference trace and C occurs after `a_k`, then
`sum_(i<=k) a_i <= sum_(i<=n) a_i`. Main-content noninterference identifies
the actual pre-C projected prefix with that reference prefix. No behavior of
the changed Main after C is used. A first representation/collection-event
argument uses only this prefix: until that event, the projections agree;
the inherited prefix margins exclude the event before C. It does not assume
the changed Main's complete later trace matches a fixed-library process.

The old numerical W is **not** silently reused for the later current recipe.
R56 already supplies explicit quiet/timeless/logging allocation credits and
the J12 launch attachment. R78 repairs the resolver branch while preserving
those conservative credits, including both candidate strings, all candidate
tests and the extra FileTags name. Reuse these accepted full-reference bounds:

| Matching role | Minor history M | All-major history A | Managed history M+A | Carrier S=M+A+2,152,771 |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 135,521,724 | 8,526,217 | 144,047,941 | 146,200,712 |
| Put | 124,243,436 | 8,470,822 | 132,714,258 | 134,867,029 |
| First_Or_Default | 95,519,954 | 8,344,842 | 103,864,796 | 106,017,567 |
| Is_Message | 85,358,536 | 8,204,225 | 93,562,761 | 95,715,532 |
| Input_Is_Valid | 86,344,026 | 8,211,056 | 94,555,082 | 96,707,853 |

M is the current young-heap bump envelope, which also overcounts allocations
before the first Why module after the fixed startup collection. A is the
accepted **all-major history**, including startup promotions; it is not just
the current-major column. At C every live young block is covered by M and
every live major block by A. Earlier reclaimed young garbage is irrelevant to
the physical carrier. The loaded-image overcount of 2,152,771 words covers
all PT_LOAD memory of the unchanged executable/two plugins, including static
data and zero-filled regions. We do not transplant the older startup scalar
to a different argv layout or add startup promotions a second time.

R56's corrected mark-phase/contiguous-arena argument, not its superseded
historical idle-phase wording, supplies the no-extra-collection/expansion
relation. The largest M remains below `2^28`, A below the `2^24` initial
major arena, and the reference/ephemeron/custom/resource margins remain
strict. These are sufficient representation/runtime-control premises;
S is neither total resident memory nor a physical-RAM admission cap.

## Charged owners from initialization

The exact source/native allocation sites establish a **per-call injection**
into fresh minor allocations. A physical carrier bound alone would not bound
historical increments. All named counters below initialize after the first
Why module, before C. Registered module-static symbols/attributes are created
by those same runtime calls; there is no serialized nonzero initial counter.
Use `q_X = floor(M / w_X)` for each owner's minimum allocation `w_X`:

| Actual owner | Initialization/source site | Minimum words per counted call | Largest q_X / counter upper |
| --- | --- | ---: | ---: |
| Ident | `ident.ml:187–192`, counter0 | 5 | 27,104,344 |
| Ident.Hsattr | `ident.ml:29–39`, Hashcons counter0 | 3 | 45,173,908 |
| Ty.Hsty | `ty.ml:90–122`, Hashcons counter0 | 3 | 45,173,908 |
| Ity.Hsity | `ity.ml:125–160`, Hashcons counter0 | 4 | 33,880,431 |
| Decl.Hsdecl | `decl.ml:340–419`, Hashcons counter0 | 4 | 33,880,431 |
| Theory.Hstdecl | `theory.ml:214–274`, Hashcons counter0 | 3 | 45,173,908 |
| Task.Hstask | `task.ml:88–106`, Hashcons counter0 | 7 | 19,360,246 |
| Task.Stdecl.Hcpt | `task.ml:19`, `hcpt.ml:152–158`, counter1 | 4 | 33,880,431 requests; counter <=33,880,432 |

`Hashcons.Make:37–49` initializes each of its six active instances with
`next_tag=0` and `Weak.Make.create 5003`. Every external hashcons/unique call
executes the owner's native H.tag allocation before merge/increment. This
includes merge hits, repeated use of an existing candidate argument and
discarded tag copies. Candidate reuse cannot reuse the new tag-copy charge.
Ity's purity scan precedes its four-word tag copy; a scan that does not return
cannot reach a merge/increment. Hcpt's private hashcons has only fresh Leaf/
Branch callers; their native allocations cost four/six words before find.
Internal rehash is backing work, not another external owner request.

Distinct calls in one owner have distinct allocation charges. Different
owners' bounds may overlap: the vector is a componentwise bound and its q_X
values are not summed to infer total allocation. Discarded objects and failed
lookup candidates still consume bump space; no protected collection clears
weak keys or resets that history. Each counter increment is at most one per
charged request. A hypothetical first wrap would need more charged calls
than M allows, proving the counter is the unwrapped count plus its initializer.

**Ident's ordering requires a separate control argument.** Its native body
increments before subtracting five words, and a pending action can roll back
the speculative allocation. No-GC alone would not exclude an orphan increment.
Reuse the [initial-registration analysis](retained-why-initial-registration-bound.md)
and [source-prefix pending-client closure](retained-why-path-initial-state.md#exact-input-and-initialization-attachment),
at their actual successful controlled-prefix scope. No application finalizer,
alarm, Memprof/reflection callback or second OCaml worker can abandon this
allocation and resume into C. The one-worker SIGVTALRM yield returns. GNAT's
SIGINT save handler is installed only at `gnat_main.ml:335`, after `init_cont`
returns, and therefore after C. Physical/native fault or allocation failure
does not provide a successful resumed path into C under the inherited service
and non-unwinding-prefix premises. Thus every Ident increment reaching C has
completed its five-word charge. The retained debugger stop evidence supports
its original executions; the prospective transfer retains the stated source/
service/control relation rather than assuming a production debugger exists.

This does not create a fresh exceptional allowance. There are zero such orphan
increments in the selected C prefix. Any future extension admitting an
abandon-and-resume client must count its actual orphan increments and preserve
the same process-wide `e <= 2` budget; it cannot merely assert no collection
or reset e at C. Later weak clearing is likewise outside the pre-C no-clearing
proof and must be allowed/charged by the later owner transfer.

The complete retained implementation scan has one further Hashcons functor:
`Introduction.Hsdecl` (`introduction.ml:33–52`) has allocation-free
`tag _ d = d`. It is not covered by the positive tag-copy injection. It is
initialized with counter0/Weak5003 but has no hashcons call before C: driver
loading registers transforms, while the only selected pre-C Introduction call
adds unique-prefix strings. Its table therefore remains empty, with limit7,
oversize0 and rover0. Its future preparation lifetime needs its own argument.

## Backing state and other reached memos

Carry the **actual** source-produced objects at C, with the following numeric
envelopes. Do not replace their counter values or contents by these upper
bounds. A continuation can use `I_actual <= I_upper` and check
`I_upper + future_increments <= max_int` without observing or fabricating
`I_actual`.

- Each active Weak table has outer length, individual bucket length and
  **total allocated bucket slots** at most S. Nonempty current buckets and
  their cached-hash arrays are actual allocated blocks; distinct current
  buckets do not share nonempty backing. Empty shared buckets have zero slots.
  This uses physical storage from cumulative history, never occupied slots
  as a substitute for allocated slots. Live entries are at most q_X. Cached
  hash-array lengths match weak-bucket lengths. Completed operations give
  `0 <= oversize <= outer_length` and `0 <= rover < outer_length`.
  `limit=7`: Weak.create sets7 and resize copies that value from a fresh table;
  the only other assignment is max_int at the maximum array length, which
  cannot be reached with `S < 2^54-3`.
- Task.Stdecl.Hcpt starts with backing8192 and seed0. Its actual current
  backing remains a power of two at most S. Its size counts stored bucket
  cells, not merely distinct/live logical keys; size and cells are at most
  q_Hcpt. Only find/add reaches the private table, and each completed miss is
  paired with one counter increment and insertion. No cut is taken inside
  that mutation. Its current state is not assumed to be the creation state.
- All other reached **managed** memo/registry backings fit the same carrier:
  Env/library caches, strong hash tables, restore-path tables, tuple/type
  registries, driver/result-parser structures, transform closures/private
  tables, Re-managed state, and the fresh controller/session tables. The
  invariant is quantified over every reachable managed block at C, not only
  an enumerated list of familiar table names. Each individual array, string,
  physical list/map/bucket spine and its distinct backing cells is bounded
  by S (byte payload by8S). Aliases are counted once physically. The accepted
  complete-prefix representation theorem supplies their valid-state/scalar
  meaning; this new carrier does not infer arbitrary stored integers or
  unfolded term-occurrence sums from physical word count.

The last row covers geometry, not future lookup success, comparator cost,
semantic cache contents, false misses, or C/libc/GMP/runtime-owned foreign
backings. Those keep their existing contracts or later demand owners.
In particular, a large source-independent envelope for keys does not count
Main's repeated memo requests. The named global counters, current geometries
and initialized extra owner are useful concrete entry operands without a
claim that the entire future owner proof is complete.

All named counter endpoints, `3S+3` weak growth arithmetic, `2S+3` map/container
arithmetic and `16S+2` byte arithmetic fit `2^62-1`; S is below the ordinary
and weak-array limits. These checks concern explicit source families and
current backing dimensions, not all future native arithmetic.

## Configuration delta and remaining work

Unadopted #206 proposes three tiny `time` directives in the common private
driver. Its reported recipe changes that line from32 to33 bytes including LF,
creating nine rules across the actual driver-load occurrences. It adds lexer/
parser/string/list work and Re state before C; it cannot inherit an empty
timing-list premise. The coordinated delta work remains separate and supplies
no accepted numeric credit to this packet.

For a proved additive delta, use `M'=M+delta_minor`,
`A'=A+delta_major`, `S'=S+delta_minor+delta_major`, re-evaluate the per-owner
positive-allocation bounds, and reestablish every collection/arena/reference/
ephemeron/custom/resource, foreign-allocation and stack obligation. Constructor
equivalence or explicit additional owner requests must also be proved for that
recipe. No removed-work credit or final-live subtraction is allowed. The
executable export rejects other recipe names and sets the #206 extension
availability false. These formulas are an integration interface, not an
uninstantiated assumption used to claim the baseline bound.

Remaining #202 work is Main's actual input graph/call-multiplicity and typing/
cty/kode/SPWP construction ledger, all later owner transfers and native scalar
families, case-free attachment, preparation/printers/callbacks/saves, and the
useful arbitrary-Main failure-payload composition. The numeric entry provider
can now be reused at this exact cut/configuration relation; no fixed Main
terminal state, final heap observation or aggregate RAM cap has been imported.

Selected author GPT-6 Astra / Extra High; runtime confirmation, token use and
cost unavailable. No native/capture/prover/Lean or predecessor-checker replay
occurred. Root owns independent review, issue status, integration, publication
and durable memory. This author did not update CLI memory.
