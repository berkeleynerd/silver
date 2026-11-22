# Bounded library packages assessment — 2026-11-22

This assessment selects **Include a file** (cached revision 412843) and
**Queue/Definition** (412985) as newly enabled tasks for [#416](https://github.com/berkeleynerd/silver/issues/416).
The [capability record](../docs/bounded-library-packages.md) defines the package
fragment and tracks implementation and assurance. Delivery remains pending;
these task assessments do not claim that the new language is already supported.

## Include a file

The cached task asks: “Demonstrate the language's ability to include source code
from other files.” Its Ada example uses a `with` clause and qualified package
calls. It does not require the imported code itself to perform output, a
parameterless procedure, preprocessing, or textual source substitution.

The three-file [sample](../samples/rosetta_include_a_file/main.adb) imports
`Included`. Its [specification](../samples/rosetta_include_a_file/included.ads)
exports the subtype `Digit` (0 through 9) and `Twice`. Its separate
[body](../samples/rosetta_include_a_file/included.adb) returns `(Value + Value)`.
Main calls `Included.Twice (4)` and prints the returned value. The result is 8;
the exact expected output is ` 8` followed by LF, including Integer Image's
leading space. For every declared input, the sum lies in 0 through 18 and fits
the declared Integer result. This arithmetic observation explains the example;
complete compiler and language assurance remain separate requirements.

This driver needs the precise `bounded-library-packages` fragment and the
existing `integer-image` operation. Its package subtype and function belong to
the new fragment; the Main-local `scalar-functions` identifier would not
describe their scope. There is no author-written contract or proof annotation.
The compiler must retain the original three files through proof and compilation,
audit the package as well as Main, and execute the result against the manifest.

The existing 2026-10-15 assessment selected Claude Sonnet 5.5 at medium effort.
Its original `assessed`, `revision`, `tier`, `model` and `effort` fields are to
remain unchanged. The previous approach put output in a parameterless package
procedure; the selected calculation keeps output in Main while satisfying the
same file-inclusion requirement. The original record has no later `review`
object to replace.

## Queue/Definition

The cached task requires FIFO `push`, `pop` and `empty` operations, and a handled
attempt to pop an empty queue. It does not require unbounded storage, a container
library, an array representation or multiple queue instances. The previous
2026-10-15 assessment selected a bounded circular-array/record design; its
original Sonnet 5.5 medium attribution remains part of the task's provenance.
The new sample changes the implementation representation, not the FIFO behavior.

The [two-cell queue](../samples/rosetta_queue_definition/main.adb) has a public
[scalar interface](../samples/rosetta_queue_definition/queue.ads) and private
[storage](../samples/rosetta_queue_definition/queue.adb): two initialized
`Element` cells (0 through 99) and a count (0 through 2). Push appends when there
is room. Pop returns the oldest cell and shifts the second cell when needed.
A full push reports `Added = False` and leaves the queue unchanged; an empty pop
reports `Present = False`, initializes the output to zero and leaves the queue
empty. The Boolean `Empty` function observes the count. No package arrays or
private types are assumed.

An independent list interpretation of the driver is:
`[] → [11] → [11,22] → [11,22] → [22] → [22,33] → [33] → [] → []`.
The third push is visibly full, successful pops return 11, 22 and 33 in insertion
order, and the final pop is visibly empty. The manifest additionally checks the
initial and final `Empty` queries. Its seven output lines are `initially empty`,
`queue full`, ` 11`, ` 22`, ` 33`, `queue empty`, and `finally empty`, each with LF.
This is a bounded FIFO implementation, rather than a fixed transcript: both
operations accept the complete declared input/state domains. The package syntax
and all sample results still await integrated compiler validation.

The native implementation author checked that this design fits the selected
scalar-package rules; that check is an implementing-team scope review, not
independent proof evidence. This task adds a second newly runnable mapping when
the delivery checks pass.

## Package-state driver and other candidates

The separate [counter sample](../samples/package_counter/main.adb) exercises
private initialized state, zero-formal operations and repeated calls. Its reset
sets the counter to zero; twelve guarded increments saturate at nine; the getter
returns nine. The expected output is ` 9` followed by LF. This is a language
composition example, not an additional Rosetta task mapping.

The following cached tasks were checked against their actual requirements:

| Task | Disposition for this increment |
| --- | --- |
| Modulinos (405829) | Its central requirement is executing a main function only when the module is run directly. The selected package-plus-separate-Main example does not demonstrate that dual interface; leave its mapping pending. |
| Executable library (414191) | Requires the same library to run directly, a second client executable, and the specified hailstone interface/results. This increment does not supply those interfaces or the full required algorithm. |
| Singleton (413229) | Requires a class with one instance and operations on its non-static members. A private scalar package counter alone does not establish that interface. |
| Return multiple values; Primality by trial division | Already have faithful supported callable mappings. Repackaging them would illustrate packages but would not gain a new task. Preserve their current mappings and review provenance. |

Broad `packages` includes private types and remains unsupported. The expected
gain is two newly runnable mappings, subject to successful delivery validation.

## Delivery checkpoint

Still required: final sample admission, proof/report audit, compilation and
execution; complete feature assurance and review; the precise construct in the
catalogue and Rosetta supported list; updated current-language description and
task review metadata; deterministic rendering and stage reconciliation. Replace
this pending account with actual evidence at delivery.

The integration lead reread the cached task texts and Include a file's Ada
example, compared the selected sources and independently derived their output.
The repository's selected lead tier is GPT-6 Astra Extra High; live runtime
model/effort and token/cost measurements are not independently exposed. This is
an implementing-team task assessment, not an external review or a proof result.
