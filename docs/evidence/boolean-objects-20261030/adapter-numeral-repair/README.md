# Predicate adapter numeral rendering repair

Issue: [#291](https://github.com/berkeleynerd/silver/issues/291). Base input:
`d2db22c443df3434f1b82644886d0c71ccb886e1`. The only implementation change is
the proof body of `context_of_candidate` in
`proof/Silver/PredicateAdapterSourceCandidate.lean`; [inputs.json](inputs.json)
identifies the exact checked file and inspected source/model files.

The failed complete run `20261030T132736-e452c95bd00d` reported an undecided
equality, not a false equality. Its [retained diagnostic](original-failure.txt)
ends at `(Nat.repr 0).1.1.toList`: `decide +kernel` cannot unfold that imported
representation function. The two new `.number 0` mask defaults render through
`toString`, exposing this proof elaboration problem.

The repair rewrites zero rendering with the core proved lemmas
`Nat.toString_eq_repr`, `Nat.repr_of_lt`, `Nat.digitChar_eq_zero`, and
`String.singleton_eq_ofList`, then retains the exact existing `decide +kernel`
check. The theorem statement, token literal, expression tree, semantic models,
Ada source, declared domains and source pins are unchanged.

Source comparison found no semantic mismatch:

- Ada `Context_Of`, `Adapter.contextOf`, `contextExpr` and the candidate agree
  on all thirteen fields, including `Elaborating => False`, both zero mask
  positions, the declaration count, Boolean names and literal hiding.
- The Ada Boolean initializer starts with `Context_Of` and then replaces
  `Scalar_Names`, sets `Elaborating` to true, and sets both mask positions.
  `Compose.BooleanDeclarationNative.elaborationContext` performs those same
  four updates; `initializerContext` converts that context to the native model.
- `PredicateAdapterEnvironment.context_projection` still justifies the body
  scalar-environment transformation; this proof needs no change.

The [diagnostic lexical comparison](context-token-comparison.json) confirms all
108 candidate tokens equal the actual Ada aggregate tokens. It uses the existing
untrusted certificate lexer and does not replace complete Lean source
correspondence through `PredicateSourceCandidate`.

Native Linux x86-64 run `20261030T184802-f5496b2d5331` passed the focused target
`Silver.PredicateAdapterSourceCandidate` and a fresh axiom audit of its import
closure. It used pinned Lean 4.34.1, one Lake worker, one Lean thread and an
8192 MiB per-process threshold. The target built in 12 seconds; the complete
focused build phase took 22.530 seconds and the audit 13.887 seconds. The runner
reported 52.232 seconds overall and audited 18,430 declarations against only
`propext`, `Classical.choice` and `Quot.sound`. See
[evidence](lean-focused-evidence.json), [log](lean-focused.log), and
[managed events](events.jsonl.gz). Matching dependency artifacts were copied
from the terminal integration workspace; this was a cached focused check.

The proof-body edit requires no runtime/sample fixture refresh: source behavior,
test inputs, generators and tool settings are unchanged. Integration still
requires the successful complete Lean/source-correspondence checkpoint and
fresh whole-project module/axiom audit on final inputs. The prior complete run
remains failed. This focused result makes no claim about other pending repairs
or native verification.

Work round: selected GPT-6 Astra / Extra High; runtime model/effort confirmation
and token/cost measurements unavailable. Intended result: diagnose the adapter
failure and retain exact source/token semantics. Achieved result: a proof-only
normalization with successful focused build and audit on the first repair run.
Native execution timings above are measured; total agent elapsed time was not
measured separately. No independent review is claimed by this diagnostic record.
