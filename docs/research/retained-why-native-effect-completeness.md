# Native effects: source/link closure for the first fold and serial saves

2026-10-19 UTC, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119), base `7cb95968b0`.
**The native component supplies zero unaccounted identifier registrations** for
the retained first-fold/serial-SIGINT interval, under the explicitly instantiated
source/runtime/loader behavior relation below. The source entry certificate,
linked native families, initialization and standard-owner effects now compose;
no new runtime observation is needed to establish the selected source owners.
This is a source/interface argument awaiting independent review, not a binary
refinement theorem or an unconditional whole-pipeline capacity claim.

The useful new results include the closure of the allocation/collection and
I/O/raise/pending component cycles; the native Memprof-context dispatch that
survives disabled sampling; standard Thread owner effects; a callback-free
bounded Zarith comparator; and the native initialization/lifetime source join.
The filled entry rows include the companion reporting family's nonzero OCaml
tuple-type charge. They do not adopt a no-callback/no-throw premise or conflate
that charge with the zero **additional native** charge `N_native`.

## Inputs and scope

The [evidence packet](../evidence/retained-why-native-effect-completeness-20261019/README.md)
retains source excerpts, input identities, the component/coverage requirements
and a narrow source checker. The inherited run is
`20261019T000304-fcb988ec2c03`, PID 97103; executable SHA-256 is
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
The existing seven-image binding is reused. A new bounded data-only ELF
projection checks native source-file labels, dependencies, init/fini entries and
CRT weak providers in those same bytes. No installed instruction, process, old
graph certificate or raw memory-read stream was regenerated or rescanned.

Source components are OCaml 4.14.2 at
`8eb41f72ded84df884c3671734c947f612091f84`, Why3 at
`9390baf120ef260547dfa14f08e11c890b203d9c`, and Zarith 1.14 at
`667d742948914aa1f80d5ad5abb98bc412335e51`. New conclusions about these bodies are
**source conclusions**. Transfer to the selected executable uses the explicitly
scoped [external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary),
not a claim to have recovered historical build inputs or proved compiler
refinement. In particular there is no new installed-body witness for the
Memprof context-iterator edge below.

The [accepted correction](retained-why-interval-native-effects.md), source
`f9e8f43523` / review `8623c5123d`, is the starting point. Private Shape/printer/
fold ownership, the one-worker/no-added-worker condition, empty OCaml finalizer
registration history, never-started Memprof, selected custom destructors, fixed
loading/reflection restrictions and the successful blocked-SIGINT protocol are
reused at their accepted scopes. SIGINT saves are serial and at most two under
that protocol. The later ordinary ending save interrupted while using Shape
remains separate. This packet does not re-prove the companion numeric reporting allowance or
continuation argument, and supplies no full-grammar capacity or production change.

## The source component boundary

Let `P` contain the first fold's private cache/work list, retained term/session
projection, Shape buffer, and active shape printer/formatter/alpha locals.
Logical GC movement is not an application mutation of `P`. A primitive's
contract records its owned writes, changes to callback configuration, calls
back into OCaml, and exceptional/terminal outcomes. Ordinary allocator, libc,
numeric and collector policy implementation stays inside the existing trusted
boundary. An application-configurable dispatch remains explicit.

The following table is a source contract decomposition for the named entry
families. Its selected-client coverage comes from the filled source roots and the explicit
source/link-family relation below; this table alone is not that proof.

| Entry family | Application dispatch to expose | Other effects at this abstraction |
| --- | --- | --- |
| Allocation, ephemeron/pending polls, urgent/minor/major collection | Four collection timing hooks; major-GC hook; root scanner and its predecessor chain; Memprof context iterator; custom destructors; the accepted signal/finalizer/tracker routes | Allocate/maintain owned runtime storage; preserve logical live values; clear weak entries. Internal free-list policy and collector scan actions are not independent application clients. |
| Channel/file operations and flushing | Four channel-mutex hooks; enter/leave-blocking hooks; signal-mask hook; pending-action routes | Change the named channel, its mutex/TLS, buffers and OS resources; return or raise the specified I/O outcome. They do not acquire a typed Shape alias. |
| Native exception raising | Channel `unlock_exn`, pending actions, and, when no OCaml exception frame remains, the named uncaught-exception callback | Transfer the exception to an existing trap, or the uncaught-exception route. Raising is not an independent callback-registration operation. |
| Structural compare/hash and scalar/string/array primitives | Custom compare/compare-ext/hash where the actual value representation selects them; allocation/raise routes where applicable | Read or update their argument/result storage according to the primitive contract. A destructor result does not certify the other custom-operation slots. |
| Marshal/unmarshal, **if a covered caller reaches them** | Custom serialize/deserialize; registered custom type selection | Owned serialization buffers and returned values; their applicability and dimensions require a caller/domain row. XML session serialization is not itself `Marshal`. |
| Explicit exit or uncaught-exception processing | Existing OCaml exit/printer roots; optional runtime-shutdown named callbacks; any selected native lifetime registrations | Once-only OCaml gates and terminal `flush_all` retain their existing semantics. libc termination is an external contract; callbacks executed before it still need their effect summary. |
| Runtime fatal error, **if a covered outcome reaches it** | `caml_fatal_error_hook` | The source aborts after the hook returns. This does not prove that an unidentified hook returns or is harmless. No fatal outcome is asserted to occur. |

This boundary can be checked compositionally. For the collector component,
`minor_gc.c`, `major_gc.c`, `roots_nat.c`, `memprof.c`, `finalise.c`,
`freelist.c` and `compact.c` expose the callback-bearing operations in the
first row. Free-list selection remains the internal policy contract already
accepted. Root actions supplied by minor/major collection or compaction are
collector operations, not a new unconstrained OCaml closure. Custom destruction
uses the accepted selected destructor contracts. The empty finalizer history
excludes both OCaml finalizer calls and the two finalization timing hooks;
never-started Memprof excludes tracker callbacks, **but not its native context
iterator**. A fatal-error exit is accounted for by the separate row rather than
being silently identified with a successful collector operation.

For I/O, `io.c:73–80` unlocks a channel around pending processing, then relocks
it. Blocking sections in `signals.c:146–181` call their selected native owners;
the ordinary entry variant also processes pending signals. `fail_nat.c:63–78`
calls `Unlock_exn`, processes pending actions with the exception rooted, and
uses the uncaught route when the exception pointer is null. Thus allocation or
I/O inside an owner returns to the *same component contracts*. It does not
require recursively inventing new callback interfaces. This is an effect/frame
argument; it supplies no bound on the number of internal loop iterations,
allocations, failed I/O attempts or exceptional continuations.

## The Memprof distinction and standard owner effects

`memprof.c:635–640` implements `entry_arrays_iter(f,data)` by calling `f` on the
global entries and then calling `caml_memprof_th_ctx_iter_hook`. There is no
`lambda`, `started` or nonempty-array guard around this second call.
`caml_memprof_oldify_young_roots` reaches it at `658–660`,
`caml_memprof_do_roots` at `709–712`, and minor/clean updates also use it.
`roots_nat.c:344,446` supplies the corresponding collector routes. Therefore
empty tracker arrays do not eliminate this native interface.

Its source default, `th_ctx_iter_default` (`memprof.c:1095–1100`), invokes the
supplied action on the current context. Thread initialization installs
`memprof_ctx_iter` (`st_stubs.c:166–173,472`), which invokes that supplied action
once per thread context. These owners select **contexts**, not tracker closures.
With the accepted empty arrays, the collector actions' entry loops have no
user-data entries. Neither owner calls an OCaml closure, installs another
owner, or obtains Shape. This closes the effect of these two identified source
owners. The source/link initialization argument below selects the Thread owner
under the stated behavior relation; this is not a live cell observation.

The same Thread initializer provides a compact configuration transition:

| Configuration | Source transition / owner effect |
| --- | --- |
| Root scanner | Save the previous scanner, then install Thread's scanner. The saved predecessor remains an independent obligation even with one worker. |
| Enter/leave blocking | Install Thread save/release and acquire/restore bodies (`st_stubs.c:235–262`). They manipulate runtime descriptors/master-lock state. With the accepted one-worker condition they do not schedule another OCaml application. |
| Channel free/lock/unlock/unlock-exn | Install `caml_io_mutex_*` (`265–301`). Effects are mutex creation/destruction, channel mutex fields and TLS. The lock slow path calls the covered blocking/pending interface; it is not an unclassified Why scheduler. |
| Signal mask | POSIX `st_initialize` sets the owner to `pthread_sigmask` (`st_posix.h:37–41`), the already used POSIX mask interface. |
| Memprof context iteration | Install the context enumerator above, with no saved predecessor. |
| Stack usage | Save the previous stack-usage hook and install Thread's counter; its predecessor is called even when there is no other thread. This interface needs a row only if stack statistics are reached. |
| Fork/termination | Install Thread reinitialization and thread termination owners. Their names alone do not make fork or Thread.exit reachable in this interval. |

`caml_thread_initialize` checks `curr_thread != NULL` before doing this work
(`st_stubs.c:431–476`). Reapplying that initializer in an initialized state
does not extend a predecessor chain. That guard is useful preservation evidence;
it is not a proof that no other legitimate native client changes an exported
cell. The source definitions/defaults plus this transition need the initialization
relation below. A source default alone would not establish a live cut value.

Stack usage illustrates why the interface is reachability-based. The native
root implementation dispatches it at `roots_nat.c:520–529`; the runtime clients
are the statistics paths in `gc_ctrl.c:256,317`. It is not a hidden call made by
every allocation. The accepted Gc capability restriction and Debug's primitive
timing-map printer do not supply a Gc-stat call on the displayed save/exit path.
Likewise fixed loading excludes a new native-plugin initialization route, and
the displayed save calls do not fork. An eventual newly covered helper using
one of those APIs must carry the corresponding row; it cannot inherit an
unreachability claim merely from this table.

## Two finite numeric domains, and limits of the custom result

The accepted [comparand transfer](retained-why-inline-comparand-capacity.md)
already covers all constants supplied by this fold's strict/shallow comparison
and candidate hashing: immediate integers in
`[-2147483648, 2147483647]`. Candidate construction preserves those constants;
rejected declaration payloads containing custom numbers do not enter that
comparison. This result was reused without replay.

`BigInt.compare` delegates through `Big_int_Z.compare_big_int = Z.compare` to
`ml_z_compare`. At Zarith `caml_z.c:1259–1271`, equal operands return zero and
two unequal immediate operands return one or minus one. The source fast path
performs no limb access, allocation, GMP call, callback or hook assignment.
The optional performance counter changes only its own counter. The source
disables invariant checking; even its debug helper returns immediately for
immediates. This supplies a frame contract for those actual comparator operands,
not all numeric work of every exceptional printer. The accepted hashing domain
contains ordinary blocks/immediates, so it selects no custom hash callback.

For saved shape constants, reuse the accepted five-value domain
`{0,1,32,126,4096}` and `format "%d"`: 5/69-byte native buffers, an 8-byte
nonzero limb copy, and at most four digits. Nonzero formatting still calls GMP;
its ordinary numeric/allocation contract applies. The two domains must not be
conflated or extended to unknown exceptional pretty-printer inputs.

`custom.h:30–40` gives six callable operation slots. The accepted ten selected
operation records and destructor result do not, by themselves, establish that
every future compare/hash/serialize/deserialize sees one of those records with
its original slot values. The new source inspection identifies the standard
record fields, including Zarith's compare/hash/serialization bodies, but leaves
that application/domain join explicit in the requirements. No arbitrary custom
payload, unclassified numeric size or whole Marshal traversal is certified.

## Exit configuration is a predicate, not another arbitrary callback count

`caml_sys_exit` reaches `caml_do_exit`; `sys.c:157–158` calls `caml_shutdown`
only when `caml_cleanup_on_exit` is nonzero. Shutdown calls the registered names
`Pervasives.do_at_exit` and `Thread.at_shutdown` before heap cleanup
(`startup_aux.c:167–197`). Thus it would be incorrect to stop the native
interface analysis at the OCaml call of `sys_exit`.

The retained plan's exact environment supplies
`OCAMLRUNPARAM=s=256M,h=16M,M=1000`. The source initializes cleanup to zero and
only option `c` changes it in this parser (`startup_aux.c:86,101–116`). The
source/link prefix below supplies the other native-client coverage, so this
selected input leaves cleanup zero and preserves it. This is a source-prefix
conclusion, not a live flag observation. It needs neither successful saves nor
suppression of otherwise admitted signals.

Zarith's source initializer registers its custom record; it does not set an
OCaml GC hook or GMP allocator. Its optional C `atexit` registration is the
fixed performance-counter printer (`caml_z.c:3509–3538`), which prints scalar
counters and does not enter OCaml. This is a classified source lifetime client,
the source/link lifetime-family proof below supplies the coverage join.
Uncaught-exception processing separately resolves
`Printexc.handle_uncaught_exception`, with a default route using
`Pervasives.do_at_exit` (`printexc.c:107–162`). Its OCaml printing/exit effects
are charged in the companion reporting component; they cannot be assigned zero
by the native table.

## Filled source entry certificate

The machine-readable [interface summary](../evidence/retained-why-native-effect-completeness-20261019/interface-summary.json)
records these rows, their argument domains, owned writes and successor contracts.
`A` is allocation/collection/pending actions; `V` is scalar, string, byte, array,
weak/ephemeron and bounded compare/hash behavior; `F` is the already reviewed
formatter family plus channel/file operations; `X` is native raising/backtraces;
`S` is signal setting/dispatch; `N` is the two numeric domains above; `T` is
native exit/lifetime behavior. Generated allocation/poll/raise calls are included
in every applicable row; a source file's lack of `external` declarations is
not the argument.

| Root and source join | Native contracts and domain | Effect/frame result |
| --- | --- | --- |
| First `Trans.fold` and `Inlining.fold` (`trans.ml:75–103`; `inlining.ml:23–103`) through the accepted term/type/declaration/task constructors | `A,V,X,N`: physical/tag tests, persistent maps, arrays and weak/ephemeron operations; bounded constant comparator/hash domain | Direct Why constructors retain their existing charge. Native operations update supplied/new containers and runtime storage; no additional native Why entry is supplied. The `Weakhtbl` functor's hash/equality are tag reads; `Hashcons` selects `Weak.Make`, not an arbitrary native comparator. |
| `save_session_and_exit` (`gnat_main.ml:298–309`) | `S,A,X`, then the save and exit rows | The only direct callback configuration write is the established ignore-setting protocol. It neither writes a native hook selector nor starts a worker. Failure can unwind; it is not treated as successful exit. |
| `save_session.uniformize_shape` (`session_itp.ml:2212–2235`) and Gshape/Shape (`termcode.ml:338–627`) | `A,V,F,N,X`: copied strings, local buffers, maps/tables; SV6's five integer atoms select `BigInt.to_string`, not arbitrary Number printing | Retains accepted binder charge, private buffer/formatter ownership and serial-save protocol. Ordinary native effects do not add a Shape alias or invoke a new Why root. |
| Session serialization (`session_itp.ml:1933–2210`) | `A,V,F,X`: strings, integer/float/bool formatting, integer/string/primitive prover-key comparisons/hashes, `Compress_none` channel output | The Format `%a` closures are the displayed save helpers. Prover IDs are local/session scalar IDs, not `Ident.id_register`. `save_ident` uses `Theory.restore_path` and existing identifier strings. No Marshal entry is selected. |
| Backup and path helpers (`session_itp.ml:2236–2245`; `sysutil.ml:11–16,131–136`) | `F,A,X`: `Sys.file_exists`, remove, rename, `Filename.concat`; the serialized path is already a string list | Effects are files, channel state, copied strings and ordinary errors. `Sysutil.decompose_path` is identity; adjacent directory traversal/temporary-file/fork helpers are not called. |
| Debug's accepted exit-statistics and timing-finalizer clients (`debug.ml:158–190`) | `A,V,F,X` and `unix_gettimeofday`: empty registered statistics family, primitive timing map | Changes primitive timing/formatting state. The clock primitive calls `gettimeofday` and boxes a float. The printer does not call `Gc.stat` or the native stack-usage hook. |
| Standard/Why formatter owners and `flush_all` | `A,V,F,X`; existing formatter/Location/Color owner-family result, finite channel list | Output closures retain the accepted destinations and family. Channel hooks and pending actions are explicit below. No typed Shape alias is gained by flushing a global formatter. |
| GNAT error JSON (`gnat_util.ml:4–9`; `json_base.ml:13–78`) | `A,V,F,X,T`: fixed record with string error, boolean internal flag, empty results list; sorting string keys and escaping characters | This is Why3.Json_base. It introduces neither Yojson nor Marshal. Formatting errors remain ordinary outcomes. |
| Exception dispatch and uncaught handler (`exn_printer.ml`; `gnat_util.ml:11–22`; `printexc.ml:327–367`) | `A,V,F,X,T` for `E_report`, defined below; Unix error strings and native backtrace decoding | The callable OCaml printer/converter/exit families are reused from their accepted prefix packets. Their OCaml identifier charge belongs to the reporting proof. Native leaves do not register Why identifiers. |
| Optional hash-table random seeding (`hashtbl.ml:47–76`; `ephemeron.ml:127–139`) | `A,V,X`; `Random.State.make_self_init` uses `caml_sys_random_seed`, whose Linux helper reads ordinary entropy/time/process data | No need to infer a live `randomized` flag from the absence of `R` in OCAMLRUNPARAM. Both branches have a frame contract. It may update the standard PRNG, not Why identifiers or native callback configuration. |
| Explicit `sys_exit`, uncaught termination, and fatal outcomes | `T,X,F` and the native selector/lifetime inputs below | The source separates OCaml exit hooks, optional shutdown, fatal-error hook, and libc termination clients. Merely reaching `exit` or a later `abort` is not used to erase a pretermination callback. |

This is a source-level component proof, under the already scoped external
behavior relation. It is not a new exhaustive instruction or symbol census.
The tables join the actual source operations to trusted ordinary API behavior;
the callback-bearing interiors of `A,F,X,S,T` are exposed separately. For
example `weak.c:128–139,326–342` explicitly processes pending actions after
creating/reading ephemerons. Those calls return to `A`, even when no GC occurs.
Array/string copies write their argument/result buffers; comparison, hashing,
float formatting and native backtrace decoding do not convert a read of data
into execution of a Why closure. The accepted source representation domains
supply that distinction.

`E_report` is supplied by companion source commit
`6dd2732dd083ba6e29c7e2bd026d5668a0283b5e`; its frozen
[effect ledger](../evidence/retained-why-native-effect-completeness-20261019/companion-effect-ledger.json)
and [report topology](../evidence/retained-why-native-effect-completeness-20261019/companion-report-sites.json)
are retained here as exact inputs. The admitted origins are primitive failures,
payload-free save failures, and receiving translations to `Ty.BadTypeArity`,
`Ty.TypeMismatch` and `Term.BadArity`, with the stated `Loc`/`Trans` and timing
wrappers. The matching logical printer is LegacyPrinter's type/symbol family;
rejected registry branches do not execute arbitrary term, Number real/range,
parser, Marshal or dynamic-loader work. The six report sites add ordinary
string/Format/Unix/backtrace leaves already covered in the table.

This integration does not assume its combined counter conclusion. Type printing
can call `Ty.is_ts_tuple -> ts_tuple`; a memo miss can create identifiers, charged
in that companion argument. Native leaves of the `NoDef` symbol constructors
are the same allocation, scalar and table contracts; no numeric range check or
new native callback configuration is added. Independent review
`3956aa7fb78c5ada4c9ceda2ba26ce76766b389e`
[accepted that companion](../evidence/retained-why-native-effect-completeness-20261019/companion-review.txt)
without material findings. Its whole-interval reporting allowance `D = 25,920`
is an OCaml source allowance, distinct from this packet's `N_native = 0`.

The source rows establish a useful conditional frame theorem. Assume the accepted
OCaml ownership/registration/protocol results, the established representation
domains, `E_report`, and the source/link behavior relation and initial-state
derivation below. Every
ordinary native step and selected standard owner either preserves the protected
logical state, performs the named owned write, invokes an already listed OCaml
root, or raises/terminates through a listed successor. It adds **zero
unaccounted `Ident.id_register` calls**. This is the interface needed by the
reporting charge; it does not assert that the listed OCaml roots themselves
have zero charge. Repeated visits to a component preserve the same frame
invariant, so this statement does not assume a bound on the number of polls,
collections or I/O retries.

## The selected native source/link relation

The permitted [external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
is instantiated explicitly: for the reached initialization, runtime-interface
and lifetime behavior of these fixed images, the OCaml native runtime,
Unix/systhreads stubs, Zarith, generated OCaml startup, and ordinary CRT/loader
families implement the named source/interface contracts below. Ordinary
libc/libm/GMP allocation, numerical work, loader operation and system cleanup
remain imported contracts. This is not an added premise that all callbacks are
harmless or that all programs fit: the source clients and their effects are
enumerated and derived. It is also not a claim that metadata alone proves an
exhaustive historical native-source manifest.

The [ELF projection](../evidence/retained-why-native-effect-completeness-20261019/elf-lifecycle.json)
reconciles the pinned executable and both plugins. It establishes concrete
source/link selection evidence:

| Image | Dynamic dependencies | Initialization / finalization arrays |
| --- | --- | --- |
| `gnatwhy3` | `libgmp.so.10`, `libm.so.6`, `libc.so.6` | one `frame_dummy`; one `__do_global_dtors_aux` |
| `ada_terms.cmxs` | no `DT_NEEDED` | one `frame_dummy`; one `__do_global_dtors_aux` |
| `gnat_json.cmxs` | no `DT_NEEDED` | one `frame_dummy`; one `__do_global_dtors_aux` |

Each has ordinary `_init` and `_fini` entries and no preinit array. The
[153-row file-symbol join](../evidence/retained-why-native-effect-completeness-20261019/source-family.json)
maps every distinct executable `STT_FILE` label to the retained OCaml native
runtime/Unix/systhreads source, Zarith's `caml_z.c`, runtime `amd64.S`, or ordinary
`Scrt1.o`/`crtstuff.c`. The two plugin file-symbol sets contain only `crtstuff.c`;
their generated OCaml units and imports have the accepted fixed-plugin source
relation. The mapping retains both `runtime/signals.c` and Unix `signals.c`
for their shared basename. No otherwise unclassified native source family is
exhibited by this metadata.

**These labels and absent imports corroborate the explicitly stated source/link
relation; they do not independently prove native provenance or arbitrary alias
absence.** Unnamed/stripped contributions cannot be ruled out by `STT_FILE`
syntax alone. The trusted component relation above, not that invalid inference,
transfers the reviewed source families to the identified installation. A change
of binary, dependencies, native contribution or relevant invocation invalidates
the affected relation and requires rechecking it.

The source side is a finite family, not just selected hook bodies. The packet
retains hashes for each mapped source and an inspected interface-use projection
across 233 C/header/assembly members of `runtime/`, `otherlibs/unix/`,
`otherlibs/systhreads/`, plus Zarith. Runtime aliases/headers are included.
Generated `caml_program` merely calls each selected OCaml unit entry and updates
`caml_globals_inited` (`cmm_helpers.ml:2581–2607`); it does not invent a C
lifetime registrar. The already retained installed witness calls Thread entry
at `0x526734`. Native plugin loading resolves the fixed `caml_plugin_header`
and generated unit data/root/frame/code/entry names (`dynlink_nat.c:45–133`).
The accepted capability proof excludes the generic reflection/native-loader
accessor alternatives. Loader `caml_natdynlink_hook` starts null and has no
installer in this selected native source family. Thus plugin entry cannot hide
an earlier unclassified client through that hook.

The ordinary CRT contract exposes profiling/TM weak providers and registered
C destructors; it does not manufacture a Why callback. The
[weak-provider projection](../evidence/retained-why-native-effect-completeness-20261019/crt-weak-bindings.json)
reconciles all seven mapped image files to the retained hashes and checks
`__gmon_start__`, `_ITM_registerTMCloneTable` and
`_ITM_deregisterTMCloneTable`: every occurrence is undefined weak, and no mapped
image defines any of them. Under ordinary ELF lookup they supply no owner.
The retained loader/no-extra-loading result is essential: this is not a general
statement for a process with arbitrary preload or newly loaded instrumentation.

## Derived initial selectors and preservation

The selected standard Thread prefix derives the following 17 logical values.
They are source-prefix results under the relation above, **not newly observed
cell contents**. The [configuration record](../evidence/retained-why-native-effect-completeness-20261019/configuration.json)
gives each symbol/field, source witness and owner. Only the previous seven
objects have retained ELF-relative addresses in this packet; no further live
reads are needed by this source argument.

| Source objects | Derived values |
| --- | --- |
| `caml_major_slice_begin_hook`, `caml_major_slice_end_hook`, `caml_minor_gc_begin_hook`, `caml_minor_gc_end_hook` | null |
| `caml_major_gc_hook` | null |
| `caml_scan_roots_hook`; systhreads' `prev_scan_roots_hook` | `caml_thread_scan_roots`; null predecessor |
| `caml_memprof_th_ctx_iter_hook` | `memprof_ctx_iter` |
| `caml_enter_blocking_section_hook`, `caml_leave_blocking_section_hook` | `caml_thread_enter_blocking_section`, `caml_thread_leave_blocking_section` |
| `caml_channel_mutex_free`, `caml_channel_mutex_lock`, `caml_channel_mutex_unlock`, `caml_channel_mutex_unlock_exn` | corresponding four `caml_io_mutex_*` owners |
| `caml_sigmask_hook` | `pthread_sigmask` |
| `caml_fatal_error_hook` | null |
| `caml_cleanup_on_exit` | zero |

The derivation is compositional:

1. Source static initialization supplies null timing/major/root/fatal selectors,
   null channel hooks, default blocking and Memprof-context owners, and cleanup
   zero. Static zero definitions are used as source initialization, not as an
   inference from BSS file bytes at an arbitrary later cut.
2. The selected native family has no installer for timing/major/fatal hooks or
   an alternate root scanner. Thread entry calls `caml_thread_initialize`; the
   root predecessor saved there is therefore null. Its explicit assignments
   select the listed scanner, context, blocking and channel owners, and its
   POSIX initialization selects `pthread_sigmask`. An initialized repeat returns
   before extending a predecessor chain. Fork reinitialization only repairs
   runtime thread/mutex state; it does not replace these selectors.
3. Native startup parses the exact retained environment
   `OCAMLRUNPARAM=s=256M,h=16M,M=1000`. This variable is present, so the parser
   does not select fallback `CAMLRUNPARAM`; there is no `c` option. No other
   source client in the selected native family writes cleanup. Shutdown's
   additional named callbacks and heap-wide destruction are consequently not
   selected by `caml_do_exit` on this invocation.
4. The selector-use projection and enclosing source contracts identify all
   source writes/dispatches in these families. No selector's address is exported
   as a mutable OCaml value or passed as an ordinary libc/GMP output buffer.
   Typed application code has no isolated cell-writing capability; the generic
   dynamic symbol/native-reflection alternatives retain their accepted exclusion.
   Ordinary C buffer/pointer effects own their stated storage. This supplies the
   frame/escape argument, rather than an exact-address-absence claim.

Thus the prefix and interval preserve those configurations. Prior native work
can move GC roots or change ordinary runtime storage but cannot establish an
additional hook owner through the classified interfaces. The accepted selected
custom-destructor and empty finalizer/never-started-Memprof results remain
separate facts. Custom compare/hash slots are not selected by the covered value
domains; serializers/deserializers are not selected by the interval source
roots. The general six-slot warning still applies to other values/programs.

Finalization begin/end hooks are excluded by the accepted empty registration
history. Stack-usage, atfork and thread-termination selectors are excluded from
this interval by its complete scoped roots, not by omission from the table.
`Thread.exit` takes the startup jump leading to `caml_termination_hook`;
ordinary raise and `sys_exit` do not take that jump. Their prefix installers and
the null native-loader hook have nevertheless been classified above, so those
excluded interval paths do not conceal an unknown earlier configuration writer.

## Native lifetime coverage and disposition

Application-side native lifetime registration is also finite in the selected
source family. Its only source registrations are:

- `teardown_eventlog` (`eventlog.c:229–264`): flush/free the owned C event buffer
  and close its owned `FILE *`. Event posting/flush shares that owned-storage
  contract. Setup failures use the separately covered null fatal-hook route.
- Optional Zarith `ml_z_dump_count` (`caml_z.c:3509–3538`): print scalar native
  performance counters. It neither enters OCaml nor installs allocator/GC hooks.
- `winsock_cleanup` in the Windows-bytecode debugger branch: excluded by the
  selected Linux native target.

The exact application ELF imports contain no `atexit`, `on_exit`,
`at_quick_exit` or `__cxa_atexit` registration symbol. The source argument does
not need to infer compile-time options from that absence: either optional
source client above already has zero unaccounted Why charge and the required
frame effect. `__cxa_finalize` is present and retains its ordinary registered
cleanup semantics. The three application init/fini arrays select only the
classified CRT owners; generated OCaml module entry is separate, and no source
constructor/destructor client is omitted. Standard libc/libm/GMP/loader cleanup
remains within its named external contract, with no arbitrary application
callback smuggled into it. Combined with the fixed loader/reflection result,
this closes native lifetime selection at this source/interface boundary.

The 17-value projection is therefore useful as a description of the proved
configuration, **not a request for a larger hook capture**. The old seven reads
remain absent; the result comes from source-prefix coverage. No additional
physical input is needed for this native component under the stated behavior
relation. A future contradictory owner observation would invalidate that
relation/result. A new process's readings would still require its own forest,
counter and binder joins; they could not be spliced into PID 97103's proof.

The no-collection alternative remains unselected. The accepted controlled-GC
prefix ends at its recorded cut; `custom.c:46–74` and `minor_gc.c:461–535`
include non-nursery-full collection routes. The proof covers those collection
interfaces rather than relying on a large nursery to exclude them.

The [numeric composition](../evidence/retained-why-native-effect-completeness-20261019/composition.json)
joins `N_native = 0` to accepted companion `6dd2732dd0` at the same PID, cut and
interval:

```text
counter_end <= 60,496 + 1,145 + 2*966 + 25,920 + 0 = 89,493
89,493 < 2^62 - 1.
```

The whole interval has at most 28,997 registrations. Every prefix of this
interval has no more. Starting from the captured counter `60,496` and the
components' cut invariants, induction establishes no wrap during this interval
and preserves the typed/source invariants used by the components. It does not
establish no wrap or global freshness before the selected cut. The native
effect proof did not assume this endpoint to obtain zero charge or preservation.
This yields the scoped source/tool no-wrap result under the explicit behavior
relation; the new native argument and this composition still await independent
review and integration by the lead.

The composition leaves broader-capacity flags false: other resources, later
driver/scheduler invocations, full-transform and full-grammar/whole-pipeline
assurance remain unestablished. The ordinary ending save interrupted while
Shape is live also remains separate. No Oracle, tool/source pin, production
admission, runtime capture, build, prover, Lean or expensive validation was
changed or run.
