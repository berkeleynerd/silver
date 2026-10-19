# Retained interval native effects: an expanded callback obligation

2026-10-19 UTC, Linux x86_64, research
[#119](https://github.com/berkeleynerd/silver/issues/119). **The four collection
timing cells were not an exhaustive native-callback boundary.** The first-fold
and serial-SIGINT-save argument also has to account for `caml_major_gc_hook`
and `caml_scan_roots_hook`, including the predecessor saved by systhreads.
The retained source and selected installed bodies establish these additional
dispatch routes. Their interval-start configuration and preservation are not
established. This packet freezes that concrete obstruction; it does not close
the complete reachable native client/effect set.

This corrects the narrower residual description in
[save preservation](retained-why-save-preservation.md), while retaining its
typed/API and classified OCaml-client results. In particular, the opening
“isolates ... to four” assertion, the claim that those four are the exact
remaining alias interfaces, and the four-only condition on the buffer argument
are too narrow. The buffer arithmetic remains available **conditional on the
complete relevant native noninterference argument**. No actual nonnull unknown
hook, interfering callback or tool failure has been observed.

This coverage omission is distinct from
[#143](https://github.com/berkeleynerd/silver/issues/143). That finding rejects
an inference about setters for the four specified cells: exact operands and
finite anchors do not exclude a shared-base-plus-offset store. Even a sound
null-preservation proof for those four would leave the additional dispatch
routes below. The [repaired native-hook packet](retained-why-native-collection-hooks.md)
and its frozen historical reports remain unchanged.

## Scope and evidence relation

Base: `fa85a5ea0d`, after the native-hook repair and its independent acceptance.
The [new evidence packet](../evidence/retained-why-interval-native-effects-20261019/README.md)
uses the same run `20261019T000304-fcb988ec2c03`, PID **97103**, executable
SHA-256 `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`
and seven-image binding. OCaml source is revision
`8eb41f72ded84df884c3671734c947f612091f84` (4.14.2), from the already retained
complete source archive. The new projection covers eight source files and
eleven named installed function bodies, **9,040 bytes including trailing
alignment padding**, matched to that executable. It extracts existing
disassembly; no disassembler or target is run.

The source/installed witnesses establish the named loads, stores, calls and
guards. They do not prove a universal compiled-source refinement or enumerate
all callers, setters or effective addresses. The existing
[source-reviewed external behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary)
and [runtime/library boundary](../trusted-boundary.md#trusted-computing-base)
remain applicable. Faithful collector semantics preserve logical OCaml values;
ordinary allocation, libc and numeric-library behavior remain external
contracts. A faithful implementation of a configurable callback dispatch still
requires the selected callback configuration to be identified. Those contracts
do not imply that an application-extensible hook has no client.

The interval remains the first fold/inlining and its serial signal saves under
the accepted one-OCaml-worker, no-added-worker, finalizer-registration,
disabled-Memprof, fixed-loaded-code and successful blocked-SIGINT premises.
Those accepted results are reused. A later ordinary save interrupted while
using Shape is outside this interval. Complete `R`, exceptional identifier
charge, exceptional continuation closure and exit/output closure remain open.
No Oracle, tool, production, admission or source-pin change is made.

## Additional collection edges

Addresses in this section are ELF-relative. These are actual guarded native
alternatives; the packet does not claim that this capture observed a callback
invocation or completed a collection phase.

| Route | Pinned source witness | Installed witness |
| --- | --- | --- |
| Major collection enters marking or cleaning, then starts sweeping | `major_gc.c:820–843,851–882,1106–1125` | `caml_major_collection_slice` calls `mark_slice` at `0x9c5c20` and `clean_slice` at `0x9c5cd0`; they reach `init_sweep_phase` at `0x9c4e91` and `0x9c5361` |
| Sweep initialization dispatches the major hook | `major_gc.c:132,420–431` | Loads `caml_major_gc_hook`, cell `0xfaaf60`, at `0x9c4375`; nonnull tail call at `0x9c4385` |
| Minor collection scans local roots and dispatches a root hook | `minor_gc.c:356–373`; `roots_nat.c:330–346` | `caml_empty_minor_heap` calls `caml_oldify_local_roots` at `0x9c6bc6`; outer-hook load at `0x9c2bae`, guarded tail call at `0x9c2bc5`, with `caml_oldify_one` as action |
| Major root scanning dispatches the same outer hook | `major_gc.c:395–408`; `roots_nat.c:355–359,405–452` | Major collection calls `caml_darken_all_roots_start` at `0x9c5d8a`; it supplies `caml_darken` to `caml_do_roots`; outer-hook load at `0x9c2fcf`, guarded tail call at `0x9c2fe6` |
| Thread scanner dispatches its saved predecessor | `st_stubs.c:140–162` | `caml_thread_scan_roots` loads cell `0xfaaa48` at `0x9b83c3`; guarded tail call at `0x9b83d8` |

The major hook is **not** a timing-hook alias. It is a separate eight-byte
symbol. Its guard is not the nonempty-finalizer-queue guard that excluded the
two finalization timing callbacks in the previous argument. A path reaching
sweep initialization can dispatch it even with no registered OCaml finalizer.
The existing interval argument does not exclude all such collection paths.

The outer root-scan hook is cell `0xfaac98`. The source initializes it to null
in `roots_nat.c:36`, but Thread initialization intentionally changes it:

```c
prev_scan_roots_hook = caml_scan_roots_hook;
caml_scan_roots_hook = caml_thread_scan_roots;
```

These are `st_stubs.c:459–460`. The installed initializer materializes the
outer cell at `0x9b8e72`, reads it at `0x9b8e80`, installs the Thread scanner at
`0x9b8e83`, and stores the saved old value at `0x9b8e94`. The different store
order in the installed body preserves the stated save-and-install dependency.
This is a concrete owner transition, not proof of the old value's provenance.

`caml_thread_scan_roots` first scans each thread's descriptor and last exception,
and other threads' stacks where applicable. Its action parameter is supplied
by the collector on the routes above. After that loop, it calls the saved
predecessor whenever nonnull. **The one-worker condition does not bypass this
predecessor call.** Identifying the outer hook with Thread's scanner, or the
scan action with a faithful collector action, leaves that predecessor's
configuration and effects to establish.

## Initialization, observation and preservation are separate

Let `t0` be entry to the retained first-fold interval. A useful candidate
configuration would make the four timing cells and `caml_major_gc_hook` null,
set `caml_scan_roots_hook` to the Thread scanner, and make its saved predecessor
null. These are **candidate initial conditions**, not facts established by this
packet and not a newly adopted no-callback premise. Identified harmless
nonnull owners would also be sufficient if their effects were proved.

| Obligation | Established here | Missing join |
| --- | --- | --- |
| Initial state at `t0` | Source null definitions and the actual Thread save/install sequence | The initialization clients before `t0`, including the old outer hook when Thread saved it, or suitable observations plus justified configuration history |
| Preservation during the interval | The named dispatches read the hooks; the identified Thread initializer writes the outer/predecessor pair | A complete relevant interval client/effect relation excluding unclassified legitimate setters or classifying their changes; exact-address absence is insufficient |
| Effects when dispatched | The collector action is identified on the displayed scan routes; Thread's scanner has an explicit predecessor edge | Identity and effect summary of every configured application callback reached through these routes |

The narrow read-coverage check examines both existing raw streams, with exact
retained member hashes: **835,579** records in `memory-reads.jsonl` and
**49,728** in `session-memory-reads.jsonl`. No recorded read overlaps any of the
seven eight-byte cells comprising the original four, the major hook, the
outer root hook and its saved predecessor. Thus these streams supply none of
their values. An address being in the process map or in ELF BSS is not an
observation of its value after initialization. The initial four-cell check is
retained separately; the new check expands the targets and confirms that the
same input streams have the same identities.

No new capture was taken. Observing four zeros would not establish preservation
or address the new scanner chain. Even observing all seven candidate values
would not identify all other interval application-callback interfaces or prove
that later legitimate clients cannot change the observed values. Seven is the
size of this targeted read projection, **not an exhaustive native-boundary
count**.

## Apply existing contracts at ordinary native interfaces

The selected bodies also contain ordinary runtime indirection. For example,
`init_sweep_phase` calls `caml_fl_p_init_merge` at `0x9c4342`, corresponding to
`caml/freelist.h:42–43`; the reviewed free-list policy assigns its internal
next-fit, first-fit or best-fit implementation (`freelist.c:1780–1840`). This
belongs to the existing faithful collector/allocation contract. Its indirect
machine instruction is not by itself evidence of a new application callback
or a reason to re-prove allocator internals.

The Thread initializer also installs blocking-section and channel-mutex
implementations (`st_stubs.c:461–469`), and saves a stack-usage predecessor
(`470–471`). Signal masking and channel operations already use the accepted
POSIX/runtime interfaces. A complete interval summary must either use an
applicable accepted owner/effect result or justify a reached configuration
where application callback behavior matters. The mere presence of an exported
symbol or saved stack-usage predecessor does not prove that route is reached
here. This packet does not certify such a complete summary or promote every
internal runtime pointer into a separate open theorem. Likewise the accepted
custom-destructor result remains about destructor effects; it is not a blanket
classification of every custom-operation slot on every numeric or exceptional
path.

There is one new bounded numeric-interface result. The accepted
[saved-root atom certificate](retained-why-session-save-outcomes.md) supplies
immediate integer values **0, 1, 32, 126 and 4,096** to `Common.const_v2`.
`BigInt.to_string` delegates to `Big_int_Z.string_of_big_int`, which delegates
to `Z.to_string = format "%d"`. The packet retains official Zarith 1.14 source
at `667d742948914aa1f80d5ad5abb98bc412335e51`; the installed image has a
`zarith.1.14` build-path string, and the selected `ml_z_format` body supplies
concrete corroboration of the following reached behavior. The version string
alone is not historical source identity or universal source correspondence.

In `caml_z.c:381–393,989–1086`, immediate zero selects zero limbs, other
retained atoms select one limb, and `"%d"` selects width zero with no prefix
or sign. The native buffer formula is `5 + 64 * size_v + 2 * width`: **5 or
69 bytes**, with an additional **8-byte** limb copy for nonzero values. The
installed shift by six at `0x9ae80b`, size calculation and `malloc` at
`0x9ae81e`, and nonzero branch at `0x9ae83b` agree. These particular sizes and
at most four decimal digits are representable on the selected target under
the existing faithful numeric and successful-allocation contracts. This is an
interface bound for those retained atoms, not a proof of GMP or malloc.

Nonzero immediate atoms still call `mpn_get_str` (`caml_z.c:1045`, installed
call to `__gmpn_get_str@plt` at `0x9aeab5`), then `caml_copy_string` returns an
OCaml string. Smallness does not remove the external-library call. The ordinary
numeric/allocator contract applies; reaching GMP alone does not create a new
requirement to verify its internals. If a claimed interval route instead
depends on configurable application allocation callbacks, identify that reached
configuration explicitly. No such extra route or setter is demonstrated here.
The five-value domain is **not extended to all inlining operands or arbitrary
exceptional printers**. The accepted installed `Compress_none` selection is
also reused; there is no selected compression-library boundary to add.

## Constructive successor

The immediate next proof input is a bounded interval summary at the existing
external-runtime abstraction: name the reached application callback interfaces,
their possible configured owners and write effects, and the finite argument
domains required by those contracts. It must include the major hook and the
root-scanner predecessor, preserve the original four-hook obligation, reuse
accepted signal/finalizer/Memprof/destructor results at their actual scopes, and
justify why its interface list is complete for the interval. It need not recover
every historical build input or verify libc, GMP or the collector implementation.

For the two new routes specifically, trace initialization of `caml_major_gc_hook`
and the root-scanner chain to the selected cut, then close legitimate writes
through the interval or classify their resulting owners. A complete reviewed
source/client behavior relation can supply this; another exact-name scan or
fixed list of machine bases cannot. If that interval closure leaves essential
initial values unobserved, coordinate a capture of that **derived** state
projection. The present packet does not supply the closure that would justify
a four-cell or seven-cell capture as sufficient.

Validation is limited to the new deterministic source/byte/read projections,
Zarith retrieval identities, local links and authored whitespace. No old
checker, graph replay, new capture, native target, build, prover, Lean or corpus
run was used. Independent review and integration are owned by the lead. `R`
and exceptional identifier charge remain **null**.
