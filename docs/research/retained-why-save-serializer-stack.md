# Retained save serializer and identifier stack closure

2026-10-20 UTC, #119 / #153 Round 38; selected five Linux x86_64 cases.

This packet supplies a complete selected `Session_itp.save_session` caller,
serializer, Shape traversal and private identifier-printer stack component **to
three explicit imported components and trusted runtime services**. Its largest
per-save bound is **106,788,096 bytes**. Every counted body has checked native
bytes and a stated active-instance multiplicity. This replaces the corresponding
incomplete projections; it must not be added on top of the old Round 36/37
serializer/shape/map/name projections.

The [packet](../evidence/retained-why-save-serializer-stack-20261020/README.md)
retains 220 native bodies, 35,960 checked instruction bytes, 61 application
sites, 87 indirect sites and the exact source-selected callback environments.
No executable, capture, disassembler, source fetch, solver or predecessor checker
was run. Source/native behavior correspondence remains the existing premise;
a complete symbol/callback inventory and byte comparison do not prove compiler
refinement or recover historical build identity. Complete save and process stack
remain null pending the parent's composition with other callback owners.

## Root and ownership boundary

The owned entry is `Session_itp.save_session_4339`. Ordinary `Gnat_checks` entry
tail-transfers to it without another live reservation. This packet follows its
preliminary uniformization, forest folds, dictionary construction, filename and
backup operations, and `save_4319`, including the plain-channel XML/shape writers.
The retained `compress_none.ml` and native direct calls select `Stdlib` channels.
The version-six source branch and the accepted no-Tcase term invariant exclude
only legacy `t_shape_task`, `ident_v4` and the pattern branch closure. The full
native caller bodies, including their excluded instructions, remain checked.

Three separately owned interfaces close the remaining source callees:

| Import | Exact scope and source packet |
| --- | --- |
| T | `Task.used_theories_2572`, `used_symbols_2581`, `local_decls_2592`; [helper closure](retained-why-save-stack-helper-closure.md) |
| G | `goal_expl_task_1184` and the public opening entries `caml_tuplify3` / `caml_tuplify4`; [binder/formatter closure](retained-why-save-binder-formatter-stack.md) |
| F | Selected Format/CamlinternalFormat entries, `const_shape_2323`, `sn_decode_2005`, including their callbacks and scalar/output wrappers; the same frozen binder/formatter packet |

The binder/formatter freeze is `562b9a1d8d18da46e9017c9d49c097d1d9bf64f5`.
Its 3,380-byte result has SHA-256
`cca726643bb9a8a45aa8f02058e7e362bb365f31193347d0b0e83a93606d3ff8`.
`import-interfaces.json` checks every outgoing imported symbol against the
frozen provider bodies, and checks that all of F's 24 printer callbacks plus
`Shape.check` are owned here. It binds both provider call inventories as inputs.
G already includes the collect/concat component X. F already includes constant
conversion and name decoding. Neither is added a second time.

Repeated goal computations are sequential within a save. G can be charged once
for a goal-explanation/opening context; F can be charged once for the selected
simultaneous Format invocations, including outer XML → printer → inner format
and the distinct shape/name paths. The provider's F bound is 23,008 bytes.
A symbol such as `List.iter`, `Buffer.resize` or `caml_apply2` appearing in both
packets denotes different invocation contexts. Its presence in an import never
silently covers another occurrence in this packet.

## Actual direct and indirect paths

`call-closures.json` records every direct transfer in each owned body, all
indirect instructions, selected application contexts, code/closure-factory
references, and static closure words read from the retained ELF. For example,
`save_goal` supplies the integer sort comparator through the static closure
at `0xe06a18` (`caml_curry2`, arity two, `fun_10193`), and its transformation
sort uses the closure at `0xe069f8` (`fun_10204`). The three frequency-fold
callbacks and the prover-ID map callback have corresponding checked static
closures. These are actual callback identities, not names inferred from a
generic `Hashtbl` or `List` entry.

| Source operation | Complete selected route outside the imports |
| --- | --- |
| Statistics and prover IDs | session attempt iteration → `fun_9928` → PHprover/frequency tables; frequency folds → `fun_9947/9949/9951`; missing ID → occurs-table iteration/scan; Mprover/Mint add/fold/iter and their actual comparison callbacks |
| XML forest | file/theory/goal/transformation serializers; table getters and status defaults/caches; attempt/transform pair construction, stable sort and comparator callbacks; sequential attempt and child traversal |
| Shape output | shape/checksum getters, `string_of_shape`, Pp list/separator callbacks, global dictionary `Mint.iter` → output-string wrapper; plain channel output/close |
| XML printers | `save_ident`, optional/attribute/scalar wrappers, prover alternative, file paths, transformation arguments; `Pp.html_string` → `html_char` → imported string/character printing |
| Shape input | `t_bound_shape_task`, `do_d` and trap, term traversal and trigger/alpha callbacks; imported public openings; `Mid.find/add` and scalar identifier comparisons |
| Identifier names | `ident_v5` → `decoded` → imported decoder or `id_unique_inner`; identity sanitizers → `find_unique` → candidate loops/specname → private Hstr/Hid methods, string/integer helpers and imported decoder |
| Restored path | `save_ident` → `Ephemeron.find/find_rec` → K1 equality → checked get-key wrapper and Weakhtbl identifier equality; get-data wrapper; `String.concat` loops |
| File callers | Linux `Filename.concat` → `is_dir_sep_473`, fixed string concatenation; backup existence/remove/rename; open/output/flush/close wrappers |
| Optional table seeding | `Hashtbl.create` → Lazy forcing → fixed Hashtbl PRNG thunk → Random state initialization, integer/digest/string wrappers; cached exception and recursive-force rejection thunks are included |

Hashtbl's selected functorial hash adapter dispatches only to integer, string,
prover or identifier-tag hashing. Its equality callbacks have the matching key
types. Extmap callbacks select integer/string/prover/identifier comparison.
Path lookup instead uses `Weakhtbl.hash_296/equal_299` and `Ident.tag_2120`.
The two tag/comparison systems are not conflated. Table resize's first indirect
application creates the key-index partial closure; bucket redistribution
applies that closure through the checked curry adapter. `interfaces.py` retains
these source contexts and the exact native application sites they govern.

Four computed jumps are internal constructor/character switches, not closure
calls. Their table bytes and all destinations are checked against the same body.
The three opening calls in `t_shape` instead resolve to the public tuple adapters
in G. Other indirect calls either inherit a finite source application context
or have an explicit selected target set. The private printers' sanitizer is the
identity function. No arbitrary closure of the right arity is admitted.

The native C-call bridge targets are separately listed for each owned body.
They are the selected allocation, copying, channel, filesystem, ephemeron,
random-seed and digest primitives. GC, primitive interiors, libc/kernel work,
raising and pending dispatch remain in the established service/callback boundary.
Missing OCaml caller bodies are not reclassified as runtime demand.

## Active-instance bounds

Every own-byte bound includes the incoming eight-byte return slot, the exact
native prologue reservation and an upper allowance for native trap pushes.
The checker conservatively sums all syntactic trap pushes, including mutually
exclusive/sequential handlers. Tail-transferred bodies are also summed even
where the return slot is reused. These deliberate overcharges cannot remove
a live frame. No uniform guessed frame size is assigned to unexamined code.

Let Z = Ffiles + Htheories + Ggoals + Ttransformations. Use the accepted native
forest counts to bound active ancestry. Let D be the preserved term-constructor
depth, P the full proposition-term occurrence sum per task, A the alpha-renaming
count per task, K the all-save dictionary-binding bound, V the accepted prover
key-domain bound, and Ls the attempt/transform sort-cell bound. P and A bound
the private alpha/name map by P+A; the dictionary and prover maps are separate
contexts. This packet does not use the explanation attribute cardinality as A.

| Native family | Own bytes | Active instances charged |
| --- | ---: | ---: |
| Preliminary file/theory/goal/transformation folds and their recursive callback wrappers | each checked separately | corresponding whole-forest Ffiles/Htheories/Ggoals/Ttransformations count |
| XML file/theory/goal/transformation bodies | 96 / 80 / 112 / 112 | corresponding forest count |
| `t_shape` | 64 | D+1 |
| Shape recursive/trigger callback wrappers | each checked separately | D+1 each |
| `List.iter` | 32 | 2D+Z+4 |
| `List.fold_left` | 32 | Z+1 |
| `List.sort` and `rev_sort` recursive bodies | 48 each | Ls+1 each |
| `Extmap.add` | 80 | K+P+A+V+3 |
| `Extmap.iter` / `fold` | 32 each | K+V+2 / V+1 |
| Hashtbl iteration/fold and their bucket callbacks | 80 / 80 / 32 / 32 | two each |
| All other non-application bodies | individual checked size | one each |

Forest recursion follows strict descendants of the accepted fixed forest.
Term recursion follows the preserved no-Tcase skeleton, so D bounds active
ancestry even though opening produces fresh terms. An application list iterator
can remain suspended while traversing a child, and quantifier triggers add two
iterator levels; `2D` covers those contexts. The forest and two sequential
attempt/path contexts plus declaration/init allowances give the stated remaining
List terms. No argument-list length is mistaken for recursive term depth.

Each sort recursion uses a strictly smaller nonempty partition. Thus Ls+1 is
safe without needing a logarithmic-depth theorem; merge/reversal loops do not
accumulate frames. An Extmap add/iter/fold follows a strict subtree. The sums of
separate key bounds cover the selected maps without claiming they share a key
domain. Prover fold can be suspended while its callback inserts into Mint;
those two families are both charged. Table folds/iterations can have an outer
session/prover table suspended over one inner table callback; there is no third
nested table traversal in these source paths.

All remaining non-application bodies are scalar wrappers, tail loops, or
nonrecursive helpers whose invocation finishes before the next sibling/phase.
In particular, a parent serializer prints its attributes before recursing into
children: printer callbacks are not retained once per ancestor. This is why the
one-instance claim for those callbacks is stronger than merely inspecting a
symbol's lack of direct self-calls.

For application adapters, define M as the sum of **all** non-adapter active
multiplicities above. An owned source activation can be suspended at one
application edge at a time. Between that source caller and its selected actual
callee, the native route has an apply entry and a curry application entry at
most; curry constructors return, and extra supplied arguments are applied in
sequence. A selected curry application tail-enters the actual body, not a new
unbounded chain of curry closures. The checked source contexts exclude arbitrary
higher-order returns; typed-format returns enter F. Charge **2(M+1) instances
of each of the 13 retained apply/curry bodies**. The extra one permits the entry
boundary. Their individual own sizes sum to 480 bytes. This is intentionally
loose: most of M counts map ancestors whose comparator call has already returned.
It is nevertheless a bound on every actual application frame from these source
contexts, with a finite reviewed target set, not a maximum-size proxy for U.

The largest case therefore charges 100,791,360 bytes for adapters and 5,996,736
for the remaining owned bodies. Tightening this overcharge is optional future
work; it is not evidence that a run actually uses 106 MB of stack.

## Printer, table and path control under interruption

The [private-printer control packet](retained-why-save-printer-control.md), frozen
at `631cfc8acbb397f91d1ac67d2a005194055fe756`, supplies the exact survival argument.
The first `find_unique` replacement is an update-only operation. Failed inserting
replacements leave their printer owner; the private ShapeTooLong identity cannot
originate inside the active mutation. A reused table has at most P bindings and
valid bucket topology; the first or final abandoned resize is a finite prefix
from a valid table. Native `find`, `mem`, replacement and redistribution scan
buckets with backedges, so their P bounds establish finite traversal without
adding a P-deep stack term. The largest selected capacity is 4,096 cells.

The previously established session/prover/status-table prefix contracts and
publication bounds remain inputs here. Similarly, restored-path scans import
the accepted finite-chain/getter behavior. Their bucket scans, `String.concat`
length/copy traversals, filename/string operations, name candidate advance/
retreat and Pp printable-list traversal use native loops. Suffix index, path
length and bucket length are not multiplied into stack depth. Random seeding
also uses fixed-state/array loops; no live randomized flag is assumed false.
A reentrant force reaches the checked Undefined thunk; a failed initialization
can cache a raising thunk. Neither recursively grows a PRNG-initialization stack
within the same save. Nested signal saves remain separate globally bounded saves.

Catch scopes and every corresponding native trap allowance remain present.
An exception can abandon a subtree or retry an accepted caller suffix; it does
not resume a discarded native frame. The selected argument is conditional on
the existing source/runtime behavior and control premises. It does not establish
runtime progress, allocation success or physical resource sufficiency.

## Numerical component and parent join

| Case | Z | D | P | K | Ls | M | Owned S bytes per active save |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 113 | 197 | 5,979 | 47,841 | 209 | 104,990 | 106,788,096 |
| Put | 102 | 197 | 5,531 | 39,745 | 174 | 88,117 | 89,634,104 |
| First_Or_Default | 76 | 89 | 3,352 | 7,657 | 109 | 20,577 | 20,971,856 |
| Is_Message | 18 | 37 | 1,276 | 665 | 13 | 3,343 | 3,420,040 |
| Input_Is_Valid | 28 | 39 | 1,435 | 951 | 10 | 4,151 | 4,243,344 |

S names the owned stack component; Ls is the sort-cell input (named `S` only
inside the arithmetic input environment).
For parent composition, replace old save-entry projections with `S + T + G + F`,
each component once per active save. Use the existing **global** r≤3 and e≤2;
neither a printer retry, Format callback nor nested save resets them. The direct
bridge allowance is separately r×4,104 and the dispatch-to-save shell e×816.
Handler setter/exit/reporting/other callback owners remain parent-owned.

This packet deliberately leaves complete-save fields null until that composition
is checked. Trusted-service demand R and preexisting suspended stack A_pre remain
separate unknowns, as do physical headroom, successful services and faithful
artifacts. It makes no whole-save-capacity, #153-completion or whole-pipeline
claim. Oracle, pins, production and all prior frozen evidence are unchanged.

Selected author: GPT-6 Astra / Extra High. Runtime model/effort confirmation and
individual token/cost telemetry were unavailable. The round record reports the
actual focused-check work and pending independent review without inventing them.
