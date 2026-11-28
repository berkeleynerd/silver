# Original layout to state read effects

Focused Linux run `20261127T141112-bf7ff4165764` passed
`Silver.ApplicationPackageLayoutEffects` and a fresh 28,303-declaration axiom
audit, two workers/two threads and an 8,192 MiB per-process threshold under
the host's eight-CPU allocation. Ordinary Lake reuse; no independent replay.

The concrete layout now supplies each selected global's actual live row,
original declaration spans and kind. Complete Integer and Boolean condition
reads then belong to the native State_Reads mask, with all lookups and Boolean
scalar-shadow exclusions derived from syntax. The only inputs are actual
parser/metadata validity, table capacities and the parsed condition. This does
not yet finish original-bundle admission or the whole-language endpoint.
Earlier normalization drafts failed and remain retained as failed.
