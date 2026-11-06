# Boolean-array driver reconciliation

**Prepared on 2026-11-06; native execution and complete assurance pending.**
The owner-authorized [#297](https://github.com/berkeleynerd/silver/issues/297)
adds the narrow fixed-size Boolean-array fragment described in
[language.md](../language.md#fixed-size-boolean-arrays). The
[capability record](../docs/boolean-arrays.md) tracks validation separately.
No broad `arrays` or `booleans` support is claimed.

Inputs are the cached Sieve of Eratosthenes task revision 415491 and Elementary
cellular automaton revision 414941, sample commit `4c45aa0cbb`, and the prepared
language/catalogue rules. The sample subthread selected GPT-6.1 Sol / Extra
High; the lead integrated and compared the sources against the cached tasks.
The lead runtime setting, whole-round elapsed time and token/cost measurements
are unavailable. This source reconciliation is not independent critical review.

## Sieve of Eratosthenes

The [driver](../samples/rosetta_sieve_of_eratosthenes.adb) initializes flags for
2 through 100, visits each base through 10 and crosses out its multiples from
its square when the base's flag is still set. The final scan prints all retained
primes. No wheel or precomputed prime list is used. The temporary Multiple and
its guard express the product's bound in the admitted local interval analysis:
for every executed iteration, K <= Limit / Base implies K * Base <= Limit, so
the guard omits no required crossing. Expected output is independently computed
by trial division, rather than the driver's marking algorithm.

## Elementary cellular automaton

The [driver](../samples/rosetta_elementary_cellular_automaton.adb) decodes the
rule's eight bits by division/remainder, reads the left/current/right cells from
one state array, writes a separate next-state array, then copies components.
Modulo implements wrapping at both edges. The neighborhood number is
4 * left + 2 * current + right, so its bit selects exactly the task's specified
rule output. Each update reads one unchanged generation.

The demonstration uses width 21, one initially active central cell, 16 displayed
generations and rules 90, 30 and 122. Static declarations configure width, initial
state and rule values within Silver's source/storage bounds; the transition
algorithm handles any Boolean initial contents and any rule in 0..255. It does
not promise runtime-sized arrays or unbounded configurations. Direct output of
`#`/`.` avoids a String buffer, and existing Integer-array iteration supplies
the three demonstrations without a user subroutine. Expected rows use an
independent Python neighborhood/bit-shift calculation.

## Retained assessment provenance and delivery work

Both previous assessments were made on 2026-10-15 by
`claude-sonnet-5-5`, selected effort `medium`, rubric 2, standard tier, on the
same cached revisions. They proposed broad arrays/Booleans; the cellular
assessment also proposed a procedure and String indexing. Those are historical
proposals, not descriptions of these bounded executable drivers. Their original
assessment date, model and effort remain in the coverage records when current
review metadata is added.

Before delivery: complete native sample executions and universal/actual-source
assurance, review the task mapping, add only `fixed-boolean-arrays` to supported
constructs, update the current assessor description and both task summaries,
render the progression and reconcile the affected stage issue fields. Broad
arrays #12 remains open. The separate sample-expansion package #300 is unchanged.
