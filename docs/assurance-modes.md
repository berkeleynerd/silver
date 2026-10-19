# Assurance modes

**Design record, drafted 2026-10-19; adopted in principle by the owner, Oracle
amendment pending approval.** The owner
[decided](session-memory.md#2026-10-19--strict-and-loose-assurance-modes-adopted-in-principle)
that Silver should have two assurance modes, and asked for the Oracle amendment
and this record. The amendment is in the same pull request and takes effect only
when the owner merges it. Nothing here changes the current language, admission,
installed tools or pins; build is paused until
[#119](https://github.com/berkeleynerd/silver/issues/119) completes.

## Definitions

- A **strict** program is valid Silver that satisfies the derived capacity rules.
  Its guarantee holds by construction: the universal Lean assurance argument,
  together with the documented trusted premises, establishes that every required
  obligation is discharged automatically. No per-program prover run is required.
  A prover run may still be made as non-gating confirmation.
- A **loose** program is valid Silver outside the strict rules but within the hard
  limits of both modes. It compiles only when its own GNATprove run succeeds. Its
  guarantee for the compiled program is GNATprove's verdict on the same source,
  plus the semantic guarantees Silver's rules give every member. In the owner's
  words, Silver "will do no worse than SPARK/GNATprove itself".
- Membership and mode are both decided by explicit, decidable rules. A prover run
  decides whether a loose program compiles, never whether it is Silver or which
  mode it is in.

Today's language is strict mode at the uniform 4,096-byte bound. #119's capacity
rule, when justified, becomes the strict predicate; loose mode is everything
between that rule and the hard limits.

## What a user sees

| Command | Strict program | Loose program |
| --- | --- | --- |
| `silver check` | admitted; reports `strict` | admitted; reports `loose` |
| `silver compile` | admits and builds (status 0), then confirms without gating, as the [scope](unbounded-programs.md#compilation-and-confirmation) designs | admits, runs the proof, then builds only on success (status 0) |
| proof resource exhaustion or interruption | confirmation reported not confirmed; build stands | not built; status 4 |
| definite non-proof with resources remaining | a defect: status 3, bug-report bundle | not built; status 3, recorded and investigated as a potential defect |
| `silver run` | admits, builds and runs | admits, proves, builds and runs |

The statuses are the scope's: 0 built or confirmed, 2 nonmembership or usage
error, 3 defect, 4 attributable resource exhaustion. Loose mode adds no status;
it changes which outcomes block the build.

## The separating principle

Loose mode may raise any number whose overflow the tools **detect**: a tool
error, a crash, a prover that gives up, an operating-system error, or memory
or time exhaustion. In each case the compiler observes a failure and reports it
under #88's outcome classification, and the user is no worse off than running
GNATprove directly.

Both modes must keep any number whose overflow is **silent**: an unchecked
32-bit index inside GNAT or the GNATprove producer that would wrap and could
produce wrong output with nothing to report. Those are the hard limits. Where
their exact per-program value is still being derived by #119, loose mode needs
a crude but sound stand-in, not the full rule.

## Numbers loose mode may raise

These are Silver's own choices today, documented as resource-derived. Each has a
detected failure mode in loose mode.

| Number | Strict today | Loose | Ceiling and failure in loose mode |
| --- | --- | --- | --- |
| Source bytes | 4,096 | host-limited, below the hard ceilings | gnat1 memory or time; prover memory (dense 8 KB already exceeded 14 GiB in the [scaling research](evidence/unbounded-programs/scoping-research.json)); status 4 |
| Operators per program, leaves per expression | 63, 64 | no cap | prover cost only |
| Binding slots | 341 | sized from the input | memory |
| Numeric literal exponent | 4,096 | 799,999 | GNAT rejects 800,000; each literal costs one Uint of about 332 KB at the maximum |
| String value and per-call output length | 4,096 | host-limited, below the character ceiling | compile or link memory; `ld` reports relocation overflow |
| Argument length | 4,096 | `Integer'Last` | `execve` `E2BIG` (131,071 bytes per argument on the researched Linux host); status 4 |
| Report storage | 16 MiB | 64-bit indexed or streamed | a possible ~2 GiB GNATprove writer limit; inconclusive |
| Prover caps | 100,000 steps, 1,000 MiB, `--level=2` | `--steps=0 --memlimit=0`, no `--level`, `-j` ≥ 3 | prover out of memory or interrupted; status 4. A finite `--steps` must never exceed 5,368,146 (Z3 wraps) |
| Image occurrence counter | not reached | up to 2³¹−1, about 40–80 MB of source | reported as inconclusive, naming the limit |

The recognizer's quadratic stack and copying are not numbers but must be
replaced before any of these rise, or they become the first failure.

## Hard limits in both modes

| Limit | Value | Why it is hard | Status |
| --- | --- | --- | --- |
| Physical line width | 32,765 columns, tabs expanded to 8 | GNAT error at 32,766 | known |
| Identifier length | 4,096 characters | GNAT bug box at 4,097 | known |
| Numeric literal exponent | 799,999 | GNAT error at 800,000 | known |
| `Integer` range; String length | `Integer'Last` | inherited Ada meaning | known |
| Source-position space | below 2³¹ per compilation, all units, 4 KiB-aligned | 2³¹−2²⁴ accepted; 2³¹−1 crashes gnat1; 2³¹ does not terminate | the per-program value depends on the units loaded; #119 |
| GNAT internal identifiers | nodes 1,999,999,999; names, lists, element lists, strings and ureals 100,000,000 | `table.adb` does not check overflow: silent | per-byte accounting pending; #119 |
| Static string characters | total distinct characters below 2³¹ | the character table uses signed 32-bit indices; two distinct 2³⁰-character values already need 2³¹ entries ([research](research/unbounded-feasibility-result.md)); the String descriptor count is not enforced either ([research](research/frontend-representation-result.md)) | per-program accounting pending; #119 |
| GNATprove literal producer | Why node identities 0..2³⁰−1, several per literal character | detection on overflow unresolved; treated as hard | #119 producer side |
| Link reach | code and static data below 2³¹ signed | `ld` reports relocation overflow, so detected; listed here because the limit is representation, not resources | known |

For the three pending rows, loose mode needs a crude, sound per-byte envelope
for the current grammar: no generics, no user subprograms, concatenation
expansion bounded by output length. This is a bounded derivation, far smaller
than #119's source-sensitive rule, and it is the one piece of capacity work loose
mode cannot skip.

## The Lean division

One development, one parameter. The strict rule enters as a decidable predicate;
no second proof tree is needed.

| Lean component (`proof/Silver/Current.lean`) | Strict | Loose |
| --- | --- | --- |
| Membership (`Member`) and its correspondence with the recognizer | required | required: same rules, larger domain, so [#90](https://github.com/berkeleynerd/silver/issues/90)'s exact length schema is needed above 16,383 bytes, where today's uniform ⟨L,L⟩ schema stops being valid |
| Semantics and safety by construction (`admitted_assurance`) | required | required; its bounds are parameterized by #90 instead of `maxSourceLength` |
| Discharge completeness (`ToolContract.boundedProofCompletes`, `automatic_pipeline`) | required, quantified over strict programs | not claimed |
| The strict predicate, decidable, with native correspondence | required | required, so the reported mode is correct |
| Resource-indexed outcome contract | optional confirmation | required: the outcome is proved, inconclusive or unknown; proved implies the guarantee (the existing producer premise); the driver's classification never maps a failure to success |
| Axiom audit | one audit; only `propext`, `Classical.choice` and `Quot.sound` | same |

The scoping research already probed the resource-indexed contract: it composes
with `Current.ToolContract` and is inhabited. The research also measured that
about 95 percent of the affected declarations lift to a symbolic bound unchanged.

## The Oracle amendment

The amendment edits six lines of [oracle.md](../oracle.md):

- "can never be rejected" becomes "can never be rejected as non-Silver", and the
  two modes are defined, with the loose compile condition and the "no worse than
  GNATprove" standard;
- membership's rule gains "A program's assurance mode is determined the same way";
- "Rejection or proof failure of a valid Silver program is an implementation
  defect" is restricted to rejection of any valid program and proof failure of a
  strict program; a loose program's resource or inconclusive outcome is not a
  defect, and a definite non-proof is recorded and investigated;
- the explicit-limits rule requires the strict rules and the hard limits to be
  documented separately, and makes any undetected overflow a hard limit;
- Lean's approved scope keeps completeness of automatic discharge for strict
  programs;
- the correspondence rule includes the strict predicate.

Unchanged: same-source, no hidden annotations, no author-written proof,
decidable membership, explicit documented limits, the verified-SPARK
implementation requirement, and Lean's other approvals.

## Work needed

Loose mode, when work resumes:

1. [#88](https://github.com/berkeleynerd/silver/issues/88): resource-outcome
   classification, the uncapped prover configuration, and mode-aware gating.
2. [#89](https://github.com/berkeleynerd/silver/issues/89): storage that scales
   with the input and the recognizer's complexity.
3. [#90](https://github.com/berkeleynerd/silver/issues/90): the exact length
   schema, parameterized models, and the strict predicate's correspondence.
4. The crude sound envelope for the pending hard limits, as a bounded package
   under [#91](https://github.com/berkeleynerd/silver/issues/91).
5. Mode reporting in `silver check`, the catalogue, `language.md`, samples and
   tests; and the merged Oracle amendment.

Strict mode: #119's rule. Until it exists, strict is the uniform 4,096-byte
bound, which the current Lean development already covers.

The milestone order in the [roadmap](../roadmap.md#unbounded-programs) records
that loose mode precedes expansion and that #119 defines strict.

## Trusted premises by mode

| Premise | Strict | Loose |
| --- | --- | --- |
| Solver completion over the admitted domain | required, restricted to strict programs; tested by optional confirmation | not required |
| GNATprove soundness: a proved program meets its obligations | already a trusted dependency | the guarantee rests on it |
| Producer premises: faithful static evaluation, complete obligation and report generation, Image translation | required | required |
| Frontend acceptance of every source passing the explicit rules | required | required |
| Resource outcomes reported distinctly, never as success | required | required |
| Hard-limit stand-ins for the pending rows | #119's rule | the crude envelope |

## Validation

- Boundary tests at the strict rule and one past it, and at each known hard limit.
- Loose outcome tests: resource exhaustion under `ulimit`, interruption, and a
  fixture whose proof fails under a small prover limit; each must leave no
  executable and return 4 or 3 as specified.
- Mode reporting tests for `check`, `compile`, `run` and the catalogue export.
- One Lean axiom audit covering the parameterized models and the strict predicate.
- No incompleteness outcome on a strict program anywhere in the corpus; one that
  cannot be fixed is a full stop, as the scope records.

## Open questions for the owner

1. Status 3 for a loose program's definite non-proof: it blocks the build and is
   investigated, but it is not a Silver defect by definition. Keep 3, or reserve a
   distinct status?
2. Should a loose compile retain the bug-report bundle on every non-success, as
   confirmation does, where resources permit?
3. Names: "strict" and "loose" are the owner's working terms.
4. Should `silver check` print, for a loose program, which strict rule it exceeds?

## Evidence

[Scope](unbounded-programs.md); [scoping research](evidence/unbounded-programs/scoping-research.json);
[unbounded feasibility result](research/unbounded-feasibility-result.md);
[frontend representation result](research/frontend-representation-result.md);
[capacity contract](research/retained-tool-capacity.md);
the [independent review of the #145 checkpoint](reviews/review-a3af180047.md) and its
[disposition](review-a3af180047-disposition.md), whose accepted-region finding
shows the first binding guards for the literal family are the linker and
assembler near 30,000 output calls, not GNAT's tables.
