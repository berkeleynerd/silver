# One concrete Why3 inlining entry

2026-10-18, Linux x86_64, bounded research for
[#119](https://github.com/berkeleynerd/silver/issues/119), based on `d5a63e4ca0`.

The first actual **Input_Is_Valid / cvc5** `inline_trivial` entry now has a
retained declaration/term graph and decoded, ordered input dimensions for the
[conditional inlining transfer](retained-why-preparation-bound.md). This
instantiates that transfer's input interface for **one observed pair**, under
the unchanged relevant-source/runtime premise. It does not establish capacity
for that pair, the other pairs, or the whole pipeline.

The [offline packet](../evidence/retained-why-preparation-entry-20261018/README.md)
retains the successful capture, exact native input, driver closure, source
files, decoder, full 512-batch input, and corruption/omission checks. Nothing
in the toolchain, production configuration, Oracle, admission rules or proof
pins changed. Replay uses ordinary Python and launches no native target.

## Actual endpoint and joins

The retained input is `silver_arguments__input_is_valid.gnat-json`, 121,828
bytes, SHA-256
`d146b75d28832260c49de3d8eb5f816c8481595127dc56dfaf3512cbdb6a4b2d`.
The fresh launch retains `--entity 1 --prover cvc5,z3,altergo --proof per_check
--steps 0 --timeout 0 --counterexample off` and
`OCAMLRUNPARAM=s=256M,h=16M,M=1000`. Only scratch/socket/configuration paths
were relocated into `/tmp/silver-why-entry-capture-20261018`. The private driver
bytes and imports are retained and joined to their original identities; the
configuration's absolute private paths are relocated explicitly.

The root coordinated managed run `20261018T201352-407bbd8ad0f5`, reserving one
worker with this scratch directory as the only writable workspace. It took
7.153969065 seconds overall; the debugger interval was 4.873981385 seconds.
The earlier run `20261018T201256-979e7151f456` failed preflight because the
integration worktree had no native installation. Correcting the launcher to
use the root checkout reused the existing installation; no target executed in
that setup-only failure. The successful observation is reused without rerun.

The debugger stops at the first instruction of
`camlWhy3__Driver__apply_3383`, static address `0x5d7aa0`, when its second
argument's name is `inline_trivial`. Disassembly establishes `rax = task` and
`rbx = (transform, name)`. The preceding `Driver.prepare_task` observation
uses `rax = driver`, `rbx = input task`. Its directive list matches the
accepted cvc5 envelope, and the observed prefix is exactly
`counterexamples_dependent_intros`, then `inline_trivial`.
The original preparation task's complete declaration-address sequence matches
initial graft child **2** in this same process; its chain has 434 nodes.
The selected driver therefore receives an actual initial split child, not a
reconstructed textual approximation.

At the stop, `Driver.update_task` and the CE-off unused-symbol removal have
returned, and inlining has not started (`driver.ml:372–389`). Printing,
`call_on_buffer` and request-submission guards have zero hits. The debugger
makes no inferior calls or data writes and fabricates no returns or solver
responses. The installed separate `why3server` remained idle; no prover was
launched. The retained collection/request/settings, arithmetic, actual-file-
read and process/thread guards also have no failures. The debugger kills the
stopped client after capture; server exit 1 is the already documented normal
single-client teardown, not a solver result.

The diagnostic limits were 120 seconds for the debugger, 6 GiB address space
per process, and a graph-abort limit of 128 MiB payload / one million blocks.
They control this research process; none is an inferred Silver capacity bound.

## Measured ordered dimensions

There are **512 task nodes** at the inlining entry:

| Kind | Count |
| --- | ---: |
| Type / data / parameter | 17 / 16 / 68 |
| Logic / proposition / inductive | 81 / 62 / 0 |
| Use / clone / meta | 34 / 42 / 192 |

The 244 logical declaration payloads supply **143 mapped roots**. The decoder
opens logic definition axioms before selecting their bodies and records their
formal arities. All roots in a declaration retain that declaration's batch;
metadata/use/clone nodes remain in their original positions. The full input
is `batches.json`, using the reviewed `inline_context` schema.

| Opened occurrence dimension | Sum over mapped roots | Coordinate maximum |
| --- | ---: | ---: |
| Term nodes `n` | 1,613 | 91 |
| Bound-variable slots `b` | 168 | 8 |
| Pattern nodes `p` | 12 | 2 |
| Applications `a` | 594 | 36 |
| Mass `n+b+p` | 1,793 | 99 |

The maximum logic arity is 6. The goal has `(n,b,p,a) = (68,5,0,36)`, mass 73.
Coordinate maxima can come from different roots. These are counts for the
captured task; they are not bounds for every registered task or driver.

The raw graph has 14,477 distinct stored blocks and 401,208 header/payload
bytes. Its JSON is 1,490,344 bytes, SHA-256
`d7f49ce0181875434292f228c3d599c8c8157b3d1f0ac6793f0d12c2558184be`.
Its 1,933 reachable stored term records include the full logic axioms and
all saved substitution values. There are 157 binder-info records and eight
substitution entries across three nonempty maps; the largest has six entries.
These stored counts are kept separate from occurrence counts. The partial
type inventory covers term/application-symbol types, not complete validator
work or type-allocation capacity.

## Opening and validation

The decoder follows the exact constructor layouts in the retained `term.ml`,
`decl.ml`, `ty.ml` and `extmap.ml`. Block headers, sizes and graph edges are
checked before decoding. All captured opaque blocks are strings; no closure,
lazy block or custom payload needed interpretation in this graph.

For semantic opening it uses the binding-frame interpretation in
`term.ml:258–283`: a bound key shadows substitutions, and a substitution value
is interpreted in the remaining outer frames. Fresh variable identities can
be represented by bound markers because the measured dimensions are invariant
under alpha-renaming. Quantifier triggers are traversed. Each repeated edge
contributes its occurrences again even when a stored subtree is shared;
memoization reuses a dimension result, not a once-only visit count.

The checker independently reconstructs free-variable occurrence counts for
all **157 binder payloads** and compares them to their stored `bv_vars` maps,
including their delayed substitutions and triggers. It checks variable-map
key order and uniqueness, pattern variable sets (including `Por` agreement),
and logic arities against symbol signatures. This directly checks important
well-formedness premises on the captured objects. It does not prove every
constructor/type invariant, the decoder's correspondence to native semantics,
or all operations performed while opening saved substitutions.

The separate stored walk follows **all** substitution values, including any
that do not appear in the opened result. Logic-axiom dimensions and termination
list lengths are also retained separately for later validator accounting.
No opened-tree count is reused as a bound on hidden stored work.

## What the concrete input reveals about the old recurrence

The old transfer conservatively admits every singleton logic definition and
treats every application as an environment hit. Applying its actual callable
through the first excess yields:

```text
task node index:              60 (zero based)
logical declaration index:    37 (zero based)
input (n,b,p,a,m):            (7,0,0,2,7)
preceding environment mass:   1310666765893632
output mass upper bound:     12024931598526509256156767059968
OCaml nonnegative int limit:  4611686018427387903
```

This is a **demonstrated loss of precision in the upper bound**, not an
observed overflow, growth measurement, capacity obstruction, or reason to
change tools. The remaining enormous recurrence is deliberately not evaluated.
The complete measured batch input is retained for a more precise transfer.
The next useful refinement tracks eligible definitions and actual symbol hits,
then bounds substitution by body nonformal mass plus the sum of formal-variable
occurrences times transformed-argument masses. That refinement is not delivered
by this packet.

## Remaining closure

The other fixed inputs and driver entry interfaces remain uninstantiated.
A specific possible source-projection route is to retain each fixed process's
whole initial task graph, establish the actual driver `Ruse`/metadata behavior,
and derive the CE-removal and monomorphisation prefixes. Driver source
`driver.ml:231–246` identifies `Ruse` as the only addition to `drv_thuse`;
`libencoding.ml:267–276` supplies goal type substitution and added type
constants. These observations suggest a smaller exhaustive composition, but
that composition is still research.

In particular, CE-off removal is not generally a shrinking operation:
`term.ml:1850–1895` can duplicate both polarities of `Tiff` and formula `Tif`.
Its `Tlet` route calls the simplifying mapper, and
`t_let_simp_keep_var` can retain the binding expression after substituting it
into the body (`:1688–1701`). A future recurrence must account for those paths,
triggers, binder opening and hidden substitution work. No unproved constant
expansion factor is used here.

A complete Why3 closure still needs the precise inlining transfer, stored
substitution/type/declaration-validator work, every later selected driver
transform, printing, meaningful counters and shared cache backing over the
process lifetime, plus response/session serialization joins. Cache/schedule
independence and alpha-equivalence for a projected all-pair domain must be
established separately. One successful capture cannot supply those universal
claims or a source/configuration membership predicate.
