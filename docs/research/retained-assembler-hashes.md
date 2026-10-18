# Retained assembler hash-table capacity

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies the hash-request input H of the
[shared GAS backing transfer](retained-assembler-backing.md) for the selected
null Main stream. It uses Binutils commit
`5e56594815854de5eca35c7c04b11705d0f19c02` and the existing installed-source,
configuration and LP64 premises. The
[evidence bundle](../evidence/retained-assembler-capacity-20261018/README.md)
now includes the complete generated `opcodes/i386-tbl.h` and `gas/macro.c`.
No generator, compiler, assembler, linker or prover was executed.

## Selected table inventory

GAS starts the symbol, pseudo-op, macro, opcode and register tables once.
The symbol table uses direct `xcalloc`/`free`; the other four use
`notes_calloc` with no individual free callback. The ordinary CFI route
has no multiple/linkonce frame-section hash; no group name, macro definition
or macro expansion adds another table
(`gas/as.c:1366–1378`, `gas/symbols.c:3132–3137`,
`gas/hash.h:112–117`, `gas/macro.c:59–65`,
`gas/config/tc-i386.c:3643–3667`).

| Table | Initial requested slots | Insert calls/live entries, at most | Pointer slots, at most | Bytes per pointer array, at most |
| --- | ---: | ---: | ---: | ---: |
| Opcode | 16 | 2613 | 8191 | 65528 |
| Register | 16 | 352 | 1021 | 8168 |
| Pseudo-op | 16 | 263 | 1021 | 8168 |
| Macro | 16 | 0 | 31 | 248 |
| Symbol, direct heap | 1024 | 90 | 2039 | 16312 |

The generated opcode-set array contains 2614 offsets, the final one being
the end sentinel. The initializer inserts once for each preceding offset.
The generated register array has 352 rows; the runtime loop skips some FP
spellings, so charging every row is conservative. The offsets are unsigned
short values with maximum 4550; all array indexes and loop counts fit their
declared types (`opcodes/i386-tbl.h:47951–48282,50514–51926`,
`gas/config/tc-i386.c:3652–3658,3664–3704`). These are pinned source counts,
not counts sampled from an installed assembler.

For pseudo-ops, count every syntactically declared row, including both sides
of conditional compilation: 165 portable, 33 x86, 36 ELF and 29 CFI rows.
Their sum 263 bounds calls to `str_hash_insert`; duplicates only reduce
live entries. The two CFI table definitions are mutually exclusive; the
selected supported-CFI definition has 29 rows, and the fallback also has 29.
The selected x86 ELF hook adds the ELF table only; ECOFF and synthesized-CFI
paths are excluded by the selected configuration
(`gas/read.c:335–520,556–615`, `gas/config/tc-i386.c:1310–1361`,
`gas/config/obj-elf.c:73–187,194–200`,
`gas/dw2gencfi.c:699–731,2723–2755`).

The macro hash stays empty. The selected stream has no macro definitions,
iterations or purges. The prior symbol transfer bounds all created GAS
symbol objects by 90, including the two non-output predefinitions, so the
symbol hash cannot have more than 90 distinct
entries; conversions and replacement insertions do not add a second live
key. Its initial 2039-slot backing already exceeds the growth threshold
needed for this count.

## Hash requests and arithmetic

`htab_create_alloc` requests one control object and a prime-sized pointer
array. The source's `struct htab` fits 112 bytes on LP64; 128 is a conservative
ceiling. Each string insertion creates one 16-byte key/value tuple through
the table allocator. Even duplicate pseudo-op insertions create a tuple;
the bound counts calls, not just distinct keys. Static opcode/register/
pseudo-op key strings are retained by pointer and are not duplicated
(`include/hashtab.h:96–141`, `gas/hash.h:24–28,52–58,96–117`,
`libiberty/hashtab.c:282–286,339–374`).

With no key deletions, occupied count is at most the number N of insertion
calls. Insertion checks the 75% threshold before looking for a slot;
reallocation either retains the current prime or selects the least listed
prime at least twice the live count. Therefore every capacity is at most
the least listed prime at least `max(initial_request,2N)`. This also covers
a growth caused by a duplicate lookup at the threshold. For N=2613 the
argument is 5226, whose selected upper prime is 8191. The smaller table
bounds follow the same rule (`libiberty/hashtab.c:134–193,517–575,633–695`).

The maximum probe index plus its secondary step is at most
`2*8191-3=16379`. The size/load-factor multiplications and occupied counts
fit their declared types. The hash/search/collision counters use intentional
unsigned modular arithmetic; those diagnostic counters do not allocate
storage or select equality. Pointer arrays and controls are completed
`notes_calloc` objects, so their sizes do not enlarge the existing-prefix
bound at the next growth request. Old pointer arrays may remain in `notes`
after a resize; the individual-request argument does not assume they are
freed or impose an aggregate memory gate.

Thus **H=65528 bytes** suffices for all selected shared-hash requests and
also exceeds the symbol table's separate direct-heap request. The common
notes transfer becomes

```text
Q = max(65528, 8*(A+1), P)
notes_chunk <= max(4064,Q+241).
```

For the descriptor example `as --64 -o main.o TEMP.s`, A=5 and P=7;
the individual notes chunk bound is **65769 bytes**. The production phase
join still supplies its actual argument count and output-path spelling.
The required `max(4064,Q+241) <= PTRDIFF_MAX` condition and allocation/
pointer-placement premises remain. This is a source-derived representation
bound, not a memory benchmark or language admission cap.

This closes H for the selected stream. Fixed option parsing and other
non-hash startup requests, expression/parser subsidiary storage, BFD
initialization/backing and the final phase joins remain separate obligations.
