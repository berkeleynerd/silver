# Boolean producer review in progress

Native subthread for [#291](https://github.com/berkeleynerd/silver/issues/291),
2026-10-30. Selected worker: GPT-6 Astra / Extra High, as requested by the lead.
Runtime model confirmation and token/cost measurements are unavailable. The
[input inventory](producer-inputs.json) records the retained upstream source
identities. This is a source account under the existing producer assumptions,
not binary-source attestation or complete native/Lean assurance.

## Routes reviewed

- `gnat2why-expr.adb:24501–24626` translates scalar Boolean negation and eager
  logical operands. Boolean arrays and modular operations take other branches
  and are not admitted. Ordinary `and` and `or` create Boolean calls; `not`
  creates Boolean negation. Their operands retain their own existing checks.
- `gnat2why-expr.adb:21817–21837,21942–21966` translates predefined Boolean
  equality/inequality using the scalar/Boolean comparison routes, without a
  new root safety check. The primary operands are translated from the same
  incoming execution state. Existing checked subexpressions remain required.
- `gnat2why-expr.adb:24635–24712` retains the existing short-circuit translation.
  Boolean storage does not change the source or inherited evaluation semantics.
- `why-gen-expr.adb:2425–2439` returns a same-base Standard.Boolean conversion
  unchanged even if a range-check flag is present. This capability introduces
  no Boolean subtype, conversion syntax or predicate constraint.
- `flow-analysis.adb:1989–2055` selects existing unused-assignment,
  mutable-initializer and ineffective-statement advisories. Boolean declarations
  and writes enter those existing source-vertex categories. They introduce no
  new library call, array write, type entity or indexed-loop initialization note.

A Boolean declaration needs at least thirteen bytes (`A:Boolean:=B;`), so its
metadata capacity is `floor(4096/13)`. The existing combined declaration/root
allowances already include the shorter seven-byte named Integer subtype object
and five-byte assignment forms. The named-subtype retained Main envelope is
31,822,336 bytes within its 33,554,432-byte allocation. Reusing that numerical
envelope for Boolean values requires the expression-shape restriction agreed
below and the complete semantic/source assurance checkpoint.
No report-policy or allocation change has been made.

## Xor representation question

`why-gen-expr.adb:5391–5424` builds `(Left or Right) and not (Left and Right)`
from the supplied operand AST IDs. The caller in
`gnat2why-expr.adb:24589–24626` transforms each operand once; it does not create
an operand temporary at that call. The JSON writer template at
`why-atree-to_json.adb-tmpl:113–115` recursively serializes the referenced node.
The retained frontend `exp_ch4.adb:10731–10751` adjusts scalar Boolean operand
and result types without introducing an xor-specific operand temporary.

This distinguishes intermediate representation size from retained report size.
`gnat_checks.ml:175–224` groups goals by check identity; `gnat_report.ml:33,59–85`
emits one record per check and aggregates prover statistics. Existing report
projection removes immediate `check_tree` values after validating their JSON,
so raw proof-tree bytes are not the retained Main allocation. Copied operand
ASTs do not by themselves imply distinct registered checks.

Seven bounded dynamic probes all completed with every required check proved.
Their ordinary SPARK procedure parameters isolate the producer route and are
not a claim that formal parameters are admitted in Silver. The full Integer
input domain is retained and the executable `N < Integer'Last` guard protects
`N+1`. Each run reserved one worker, used the existing level 2 / timeout 30 /
CVC5,Z3,Alt-Ergo settings and disabled loop unrolling. The original root native
context was separate from the two-worker compiler-unit proof. The lead explicitly
authorized this temporary total of three native workers.

| Probe | Exported `gnat-json` bytes | Why3 goals including root | Solver successes for one overflow check |
| --- | ---: | ---: | ---: |
| Arithmetic under 1 xor | 23,318 | 5 | 4 |
| Arithmetic under 4 xor | 68,328 | 33 | 32 |
| Arithmetic under 8 xor | 850,324 | 513 | 512 |
| Names-only conditional, 1 xor | 24,997 | 3 | 2 |
| Names-only conditional, 8 xor | 457,243 | 3 | 2 |
| Arithmetic under 8 Boolean equalities | 24,713 | 3 | 2 |
| Arithmetic under 8 Boolean inequalities | 24,713 | 3 | 2 |

[Observations](producer/observations.json) retain exact managed run IDs, durations,
commands, source/project inputs, original artifact hashes and compressed reports,
exported formulas, native logs and Why3 sessions. The one-xor procedure does not
use its second formal parameter B and emits that ordinary unused-formal warning;
no Silver diagnostic acceptance rule was broadened for this probe.

The source and experiments agree: nested xor causes exponential intermediate
formula expansion and may duplicate primitive proof tasks for one registered
check. Names-only operands still expand the formula. Boolean equality and
inequality take `Transform_Comparison` and `Transform_Compare_Op`, which create
one comparison (or predicate equivalence) node with each operand once; the
bounded equality/inequality observations show no xor-like expansion.

The lead agreed the structural restriction on 2026-10-30: neither operand of an xor may contain
another xor, including the implicit left operand in a homogeneous xor chain.
`A xor B`, `(N=0) xor (M=0)` and independent `(A xor B) and (C xor D)` remain
available. `A xor B xor C` and `A xor (B xor C)` are excluded. Authors can express
multi-input parity through ordinary initialized Boolean temporaries in their
actual Ada source. This removes repeated xor multiplication without setting an
arbitrary observed runtime threshold or changing the existing source/operator/
leaf budgets. The native parser now checks both exact operand spans with a lexical scanner
that ignores strings, doubled quote escapes, comments and identifier substrings.
A ghost functional scanner and exact native postcondition connect its behavior to
the source model. Complete parser/model/specification integration and the final
assurance checkpoint remain pending; the earlier checkpoint 828dd16e6e alone
does not contain this restriction.
