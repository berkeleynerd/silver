# Exact Boolean loop control repair — 2026-11-22

The native condition reader now uses an unconditional loop and its existing
current-operator No_Chain return. The constant while condition and unreachable
trailing return were removed. The selected-operator agreement, cursor-progress
guard, loop invariant/variant and complete public contract are unchanged.

Complete canonical native run `20261122T180644-1f5eefc02619` passed all 22 checks
(5 flow, 17 proof) in 54.366 seconds, with no warning. Its exact source SHA256 is
`e181c06fc2ac104092b9166eb276338feeca254ad21446fdfc3903cd81a7dc02`; the source
snapshot and native reports are in the adjacent `native-package-contracts`
directory. The failed stable-loop warning record remains failed and retained.

The raw loop equation, complete typed command interpretation and source-token
candidate changed with the native source. `ConditionExec.initial_split` proves
the ordinary zero-iteration result when the initial token is No_Chain: the same
pure token read returns that result on the first native iteration. When Selected
is nonempty the former constant guard admitted every iteration, so its removal
does not change any iteration decision. No fuel cutoff, domain restriction,
warning suppression or extra invariant was introduced.

Focused Linux x86-64 Lean run `20261122T180811-891cde057b0a` passed the updated
candidate and a fresh audit of 21,313 declarations, with only `propext`,
`Classical.choice` and `Quot.sound`. Evidence elapsed time was 84.709 seconds;
two managed workers and two threads per process shared the eight-CPU allocation.
All four typed Boolean bodies and native headers/defaults are checked against
the proposal. Actual whole-source certification and the exact semantic
evaluator/reading connection remain required.
