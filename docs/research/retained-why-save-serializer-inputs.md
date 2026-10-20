# Selected Why3 save: raw serializer string inputs

2026-10-20 UTC; authorized #119 / #153 Round 29 research;
base `466c44c54b6ec777829400108c2f53920827bcc0`.
Selected worker setting: GPT-6.1 Sol / Extra High; runtime confirmation and
token/cost measurements are unavailable. Independent review is pending.

The retained five fresh captures determine every selected XML string field at
the cut. Source/configuration mapping also determines the three automatic
prover records that may be added afterward. A conditional candidate for the
sum of raw string bytes per reached save is **4,275 / 3,571 / 2,317 / 419 / 384**
for Put_Line, Put, First_Or_Default, Is_Message and Input_Is_Valid respectively.
The exported whole-continuation `raw_string_bytes_sum` **remains null**: the
available source route has not bounded a restored-path binding installed later
for a currently unbound serialized identifier. It preserves session name
fields and the forest, which is a narrower fact.

The [packet](../evidence/retained-why-save-serializer-inputs-20261020/README.md)
contains an offline extractor, occurrence-level inventories, configuration
mapping, exact source excerpts, input identities and boundary checks. It
consumes accepted archives directly. It performs no native execution, new
capture, collector/observer replay, binder/alpha recomputation or source fetch.
The Oracle, installed tools/pins, admitted language and draft PR #121 are
unchanged. This result does not complete #119 or #153.

## Meaning and source coverage

U here is a bound on raw bytes presented by the serializer's variable string
arguments and source-selected result-status labels, summed with their actual
serialization multiplicity. It excludes fixed format text and fixed attribute
labels already covered by `1024*Q` in the accepted
[operational interface](retained-why-save-operational-bounds.md). It also excludes
HTML expansion, scalar `%g`/integer/boolean output, shape-file strings, formatter
queues/storage and native allocation. It cannot by itself establish a native
string limit or formatter capacity.

The packet's `source_witnesses` binds the archived members at Why3 revision
`9390baf120ef260547dfa14f08e11c890b203d9c`. The relevant consumers in
`src/session/session_itp.ml` are:

| Consumer | Raw input counted in U |
| --- | --- |
| `save_prover`, 2023–2035 | Prover name and version; alternative only when nonempty |
| `save_result`, 2056–2072 | One of eight fixed status labels, at most 17 bytes |
| `save_file_path`, 2079–2082 | Each path component; no joined-path separator is printed |
| `save_proof_attempt`, 2084–2097 | Optional script components and result label |
| `save_ident`, 2099–2107 | Joined nonempty restored qualified path, including dots, or fallback `id_string` |
| `save_goal`, 2109–2135 | Identifier and nonempty `proofn_expl`, once per forest visit |
| `save_trans`, 2137–2148 | Transformation name and each argument |
| `save_theory`, 2150–2161 | Identifier only when the theory's goal list is nonempty |
| `save_file`, 2163–2170 | Nonempty format and path components |

Diagnostic messages, prover output and model text in result records are not
serialized by `save_result`; their size is irrelevant to this U interface.
`None` status prints the fixed `<undone/>` literal. Charging 17 for every
`Axml` occurrence safely covers either branch. The selected route's
[attempt-growth argument](retained-why-save-attempt-growth.md) excludes future
manual proof scripts; every captured script is also explicitly `None`.

Source `Sysutil.file_path = string list` and `decompose_path p = p`
(`src/util/sysutil.ml:131–135`) justify using the captured path-component byte
sum. The captured zero explanation/argument extents are checked values of
complete sections; they are not defaults supplied for unknown fields.

## Actual selected prover records

All five retained invocations contain
`--prover cvc5,z3,altergo --proof per_check --counterexample off`.
The extractor binds each invocation and its case-local `why3.conf` to the
capture manifest and the plan's file identities. The extra `--why3-conf` file
contains only `[main]` and `magic = 14`; it contributes no prover or shortcut.

`gnat_config.ml:291–316` splits the selection and calls
`filter_one_prover config (mk_filter_prover prover_string)` for each entry.
The base configuration is explicitly `read_config (Some "why3.conf")` at
346–379; it does not use a home-directory configuration. The supplemental
configuration cannot redefine a built-in prover (283–289), and merging keeps
the first records and shortcuts. `Gnat_util.get_gnatprove_config` changes
driver paths, preserving the prover record (101–108).

`whyconf.ml:335–343` constructs the three immutable identity strings from
`name`, `version` and `alternative`; only absent configuration `alternative`
gets the source-defined default `""`. Lines 392–395 and 529–533 load the
shortcut map. Lines 820–840 resolve a shortcut into its full structural
prover filter and require one match. This establishes the following mapping
from configuration records, rather than from executable filenames:

| Shortcut | Serialized name | Version | Alternative | Raw bytes |
| --- | --- | --- | --- | ---: |
| `cvc5` | `CVC5` | `0.0.7-gnatprove` | empty | 19 |
| `z3` | `Z3` | `4.5.1-gnatprove` | empty | 17 |
| `altergo` | `altergo` | `1.30-gnatprove` | empty | 21 |
| Captured synthetic record | `Trivial` | `1.0` | `trivial` | 17 |

The first four captures contain only the synthetic record; Input_Is_Valid
already contains CVC5 as well. The structural union of captured records and
the three selected records has **four** keys and **74** bytes for every case.
This is tighter than multiplying the separate 4/4/4/4/5 cardinality bound by
a maximum record length. The extractor checks every captured attempt and
per-goal membership key against this domain. Under the imported growth route,
new or reassigned prover keys belong to the selected set.

`save` builds a local `Mprover` map, then a `Mint` map before printing prover
records (2178–2191). Each structural prover key can therefore contribute at
most once. ID collisions may omit records in the second map; they cannot
increase the charged 74 bytes. The numerical domain count is independent of
prover-ID uniqueness and private statistics-table binding multiplicity.

## Occurrence arithmetic

The extractor traverses file → nonempty theory → goal → transformation →
subtask edges and retains repeated visits. A recursion-path check rejects
cycles without globally deduplicating shared nodes. The selected forests have
one file, one serialized theory and one transformation each. They contain
46/46/41/12/21 captured theories in total; the empty theories are inspected by
the source but their names are not printed. The goal visits are
65/54/33/4/5. All five transformations are `split_goal_wp_conj` (18 bytes),
with empty argument lists and captured goal explanations.

| Case | File path + format | Identifier bytes including joined dots | Transformation | Prover domain | `17*Axml` | Candidate U per save |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Put_Line | 40 | 607 | 18 | 74 | 3,536 | 4,275 |
| Put | 35 | 503 | 18 | 74 | 2,941 | 3,571 |
| First_Or_Default | 55 | 334 | 18 | 74 | 1,836 | 2,317 |
| Is_Message | 49 | 74 | 18 | 74 | 204 | 419 |
| Input_Is_Valid | 53 | 86 | 18 | 74 | 153 | 384 |

The imported conditional `Axml` bounds are 208/173/108/12/9. They already use
one global remaining signal budget `e <= 2`; it is not restarted per pair or
per save. With at most three remaining save entries, the corresponding
conditional aggregate candidates are 12,825 / 10,713 / 6,951 / 1,257 / 1,152.
These count source input even when a later save truncates a file or an earlier
save aborts after a prefix. No native storage bound follows from the sum.

For every identifier, the result retains both fallback bytes and the captured
qualified components, including the inserted dot count. The candidate uses
their maximum, not merely the captured branch's selected length. In these
five inputs that maximum equals the captured branch sum shown in the table.

## Exact remaining restored-path premise

`save_ident` reads a mutable global weak table through `Theory.restore_path`
at each call. The session's immutable identifier record does not determine
the table contents. `theory.ml:472–492` makes `store_path` and `store_theory`
conditional insertions when `Wid.mem` is false. `store_path` can introduce
`List.rev (id.id_string :: path @ uc.uc_prefix)`; its joined length is not
bounded by `id_string` alone. The captured serializer identifiers missing a
binding number **64/53/32/3/4**, with exact ID tags listed per case in the
result. Their captured `qualified_path` is null, not an empty future path.

The precise additional premise needed for the numerical candidate is:

> At every reached `save_ident` call, the selected fallback or restored
> qualified-path string has length at most the per-identifier maximum of the
> captured fallback bytes and captured qualified joined-dot bytes. A currently
> absent binding either stays absent, selects an empty qualified path, or gains
> a qualified path within that maximum.

Keeping existing bindings live and unchanged is one sufficient part of such
a theorem; bounding all subsequent registrations for currently absent IDs is
another. The current source route establishes neither complete theorem. Driver
task preparation and theory construction have not been excluded as later path
registrants for those IDs. The extractor does not extrapolate table stability
from fresh pointer correspondence or the immutable forest guarantee.

Until that premise is discharged or replaced by a larger verified path bound,
`raw_string_bytes_sum`, `scalar_format_bytes_max`, formatter storage and native
allocation outputs remain null. The operational owner can consume the
candidate only with that explicit additional premise and the existing growth,
lookup/prefix, scalar-format, formatter and native representation obligations.

## Evidence boundary and checking

The extractor verifies every consumed archive member against the accepted
capture manifest, binds the fresh projection to the accepted repaired state
join, checks overlapping comparison/replay raw identities against one another
and the manifest, and binds configuration and plan identities directly. It
reuses the successful correspondence and byte-identical replay; it does not
claim to rerun them. This preserves the distinction required by Round 28
review finding M1 / #154 between immutable correspondence and fresh mutable
field evidence.

Four focused checks cover repeated serialization visits, qualified-path
joining, unknown-versus-absent fields, and rejection of an archive-member
identity mutation. The deterministic extraction and final checks are recorded
in the packet's `round.json`. The selected reviewer and combined review belong
to the lead's integration checkpoint.
