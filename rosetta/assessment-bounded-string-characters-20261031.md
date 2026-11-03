# Bounded String and Character driver assessment

Prepared for [#296](https://github.com/berkeleynerd/silver/issues/296). This is
an implementation assessment; complete feature validation and independent review
remain pending in the [capability record](../docs/bounded-string-characters.md).
The selected integration setting was GPT-6 Astra / Extra High. Live model and
effort were not independently exposed; whole-agent elapsed time and token/cost
measurements are unavailable. Native execution timings have their separate scope
in the capability record.

The inputs are the checked-in task text for Reverse a string (revision 415531),
Palindrome detection (415537), and Selectively replace multiple instances of a
character within a string (413011), together with the three named sample files
and their manifest entries. The earlier broad assessments remain historical
provenance; the updated approaches describe these actual bounded programs.

| Task and source | Task correspondence and expected result |
| --- | --- |
| [Reverse a string](r/reverse-a-string/task.wiki), [driver](../samples/rosetta_reverse_a_string.adb) | Swaps mirrored bytes in `silver`, using a Character temporary and retaining an original snapshot. Python byte reversal independently gives `revlis`; the output is `silver -> revlis` followed by LF. The example `asdf` in the task is illustrative. |
| [Palindrome detection](p/palindrome-detection/task.wiki), [driver](../samples/rosetta_palindrome_detection.adb) | The task permits a program. The driver compares mirrored bytes and accumulates a Boolean result for `racecar` and `silver`; independent comparison with reversed bytes yields true and false. Output is `racecar: palindrome` and `silver: not a palindrome`, each followed by LF. |
| [Selective replacement](s/selectively-replace-multiple-instances-of-a-character-within-a-string/task.wiki), [driver](../samples/rosetta_selective_character_replacement.adb) | Counts occurrences in the original `abracadabra` bytes as it scans. The six task replacements give `AErBcadCbFD`, followed by LF; the third `a`, second `b` and first `r` remain unchanged. |

The first two tasks' Unicode extensions are optional and excluded. All three
programs compute from their embedded input bytes. They use the narrow
`bounded-string-characters` identifier, together with previously delivered loops,
Boolean objects or bounded Integer refinement as needed. This does not promote
broad `characters`, `string-indexing`, arrays, procedures or functions. The
new identifier remains outside `supported` until complete feature delivery.

The native worker's retained eight-case stress run already exercises the exact
three driver sources, their execution output, proof reports and source identity.
That evidence is neither an independent task review nor universal assurance.
Final manifest-driven coverage, complete source correspondence and independent
delivery review remain required. The separate `string_character_bounds.adb`
sample exercises slices, noncanonical bounds, null slices and assignment sliding;
it claims no additional Rosetta task.
