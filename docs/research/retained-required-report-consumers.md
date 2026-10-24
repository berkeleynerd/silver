# Required report consumers and native representations

2026-10-24 UTC, #119 / #194 authorized research, selected Linux x86_64.
This attaches the accepted [per-unit producer interface](retained-producer-report-capacity.md)
to GNATprove's collector and Silver's complete report audits. The
[packet](../evidence/retained-required-report-consumers-20261024/README.md)
contains callable mathematical functions and exact-source offline checks.
It does not change production, admission, Oracle requirements or tool/source
pins. #119 still needs its remaining whole-pipeline joins and #88–#94 remain
implementation work. The global e<=2, two callbacks and three saves are
imported unchanged; no consumer starts a renewed allowance.

The current source families and fixed dependencies provide the input domains;
observed report bytes, elapsed times and successful proof runs do not. Adequate
physical memory, stack and disk remain premises. False sufficient guards mean
an unestablished representation argument, not demonstrated overflow and not
permission to reject additional language programs. Loose generic incoming-flow
bounds must be specialized from fixed sources when a fixed-library fit is
needed. The packet's orientation inputs do not establish those fits.

## Phase order and the complete required set

GNATprove executes data representation, ALI and GNAT2Why steps before
`Generate_SPARK_Report` (`gnatprove.adb:1314–1328`). Its recoverable-failure
handler also calls the reporter with `Errors=>True`, then fails. The ordinary
path constructs `gnatprove.alfad`, runs `spark_report`, and propagates reporter
failure or unproved-check status under `--checks-as-errors=on`
(`:681–845`). Earlier server/phase cleanup is established by
[the producer-tail source analysis](retained-producer-tail.md).

This is phase separation, **not an optional-reporter exemption**. Silver tests
`Prove` success before reading reports (`src/silver.adb:347–352`). Ordinary
summary output and unconditional SARIF generation remain on the command's
success path. Generic reporter exceptions do not reliably distinguish a
completed collection from an incomplete one. A future exemption requires both
an explicit phase/status interface and diagnosis that establishes all required
proof work and report publication completed before the optional failure.
Nothing here supplies or assumes that implementation.

The private generated project has one object directory and no imported
project. GPR2 Tree.Iterate uses Default_Iterator, which excludes runtime and
configuration views (`gpr2-project-tree.ads:336–340`, `gpr2-project.ads:125–127`
at the already selected96e428 revision). Its explicit Source_Files list is Main alone for null, or Main plus
six Silver source files for output (`src/silver.adb:103–120`). The owned
spec/body pairs collapse to their unit's report; fixed interfaces have their
own reports. The successful output path requires **all five**:

| Report | Consumer policy |
| --- | --- |
| `main~1.spark` | Complete application policy for the admitted Main family |
| `silver_io.spark` | IO body, including Put and Put_Line postcondition coverage |
| `silver_arguments.spark` | Arguments body and owned postcondition coverage |
| `silver_output_libc.spark` | Complete imported output-interface policy |
| `silver_runtime.spark` | Complete runtime-interface policy |

`Silver_Libraries.Check_Proof_Evidence:42–86` iterates all four Report_Kind
values regardless of Main's selected operation. It returns failure on any
read, overflow or policy failure. Source correspondence is independently
checked before proof, after proof and after build. Those checks neither replace
report completeness nor establish report capacity. Null requires its single
Main report and its narrower raw-text policy.

Both ordinary and SARIF collection enumerate `*.spark` in each unique object
directory. The current generated project and fresh private directory restrict
that matching domain to the above units; imported runtime sources analyzed by
a frontend do not become independent project compilation jobs. This requires
the existing fresh-directory, stable-artifact and tool source/native behavior
premises. Extra matching files are not silently ignored by the capacity
function: an extended directory must extend its unit list and bindings.
GNAT `Wildcard_Iterator` receives a pattern with no directory suffix; it does
not descend into subdirectories on this call. Its Natural Index increments
once per matching entry, resets for each iterator, and needs U<=I. Its
2048-byte directory-entry buffer separately requires the selected filesystem's
entry-name bound (Linux NAME_MAX<=255 suffices); no counter counts all other
entries. Path normalization/OS limits remain explicit configuration domains.

## Configuration and parsing lifetimes

`configuration` reconstructs the actual parent argv from current Silver
literals plus the accepted installation forwarding `-cargs
-Wno-free-nonheap-object`. The latter is the
[orchestration provider](retained-producer-orchestration.md)'s correction; the
old 15-element/181+P command is not reused. Before prospective brief output,
null has17 elements and joined command213+P; output has17 and216+P. Adding
`--output=brief` gives18 and228+P or231+P respectively. `--report=all` remains.
P here bounds the project-file argument; object-directory length is a separate
argument. If effective launcher options change, this configuration binding
must change with them.

The shared P passed to parser normalization, reporter strings and Silver paths
is checked against named demands in `compose`: the project argument, initial
and saved cwd, object directory, every unit's source/sloc path bound, and the
object directory plus slash and each fixed config/report/summary/SARIF filename.
`configuration.adb:249–259` returns Root_Project.Object_Directory as Artifact_Dir
for this project; its existing subdir configuration already includes gnatprove.
The function takes initial_cwd_bytes explicitly and requires P to dominate all
these terms. Independent smaller P/project/object/unit inputs do not silently
establish the join. Actual cwd/path source evidence remains the parent's
configuration duty; this interface supplies its explicit obligations (#205).

The compact six-field configuration contains one obj_dirs entry, argv,
empty proof_switches, mode GPM_ALL, has_errors and colors. False is the longer
Boolean. There are no assumptions/output_header/quiet/limit fields and no
Prove.Switches attribute in the generated project. `configuration` returns
its exact structural bound with sixfold JSON string escaping of each variable
path and a final LF from Text_IO.Close. GNATCOLL Escape_String escapes all non-ASCII
code points, so serialized config and .spark text are ASCII and retain their
one-byte-per-Character file bounds. This differs from the decoded ordinary
reporter text discussed below (#203). Build_Switches_String retains the
literal space join as an Unbounded_String; it is not a shell parser. The
configuration JSON stays live throughout `spark_report`. Its producer writer,
parser, joined string and parent summary-print delta are separate outputs of
the interface, not absorbed into one raw-size scalar.

Each ordinary file is mmap/read and parsed through the same `Call.Read_File_Into_JSON`
route as #186. Each SARIF file is read and parsed again. Per-file Dict and
local JSON arrays finalize before the next file. The ordinary database stores
native records, symbols and strings; SARIF stores typed records and VSS
strings. Neither retains the parsed JSON graph. Thus parser maxima compose
by maximum, while database/symbol/result counts compose by sum. The two passes
share one reporter process and symbol pool, not a fresh pool per file.

`parsed_report` maps accepted full Shape dimensions to the existing
[GNATCOLL parser guard](retained-response-parser-capacity.md): bytes are
full.pretty+1, array/object maxima are the actual occurrence envelope, encoded
string token<=6D+2, encoded key<=6K+2, numeric token<=317, and depth is full.depth.
The same function with compact=True prices the configuration. Missing/truncated source-writer reports retain failure; the same bounds
cover a committed prefix of the fixed writer stream under existing artifact
ownership. A corrupted arbitrary file is outside that source relation and
would require the generic byte-based parser interface. This retains
file/scanner spares, mmap page rounding, parser-state vector, key/path builders,
XString growth and unsigned32 reference counters. It does not parse only the
projected bytes: GNATprove consumes the complete check trees twice.

After parser return, each graph is a tree of source occurrences. Active JSON
holders are bounded by64: configuration/root and array wrappers; map callback
key/value; entity/sloc conversion; current row; message/arguments; and nested
physicalLocation/region conversion, including controlled return temporaries.
These calls are sequential, have no recursive JSON traversal after parsing,
and do not put JSON values into retained native structures. Each array copy
can introduce at most one new holder per occurrence. Max(parser's3q+32,64)
bounds a particular JSON reference counter;64 also overcharges active XString
key/value wrappers. This is a holder census, not64 times the whole document.
Returned native strings have separate storage.

Invalid_JSON_Stream conversion remains a failure. Crucially, the two local
file handlers catch **others**, print filename+fixed text and “try cleaning
proofs,” and continue (`spark_report.adb:742–763`, SARIF`:129–145`). They do
not set Error_Code. Earlier database/results updates can survive a later
exception in the same file. Success status and SARIF executionSuccessful=True
therefore cannot certify coverage. Silver's complete report audits are the
independent required check. Failure-message line length is bounded by path+64,
with two ordinary lines per failed file per pass. Ordinary pragma Debug can
add one Exception_Message line; the retained runtime occurrence buffer caps
that message at200 bytes, so214 bytes suffice with its prefix. The callable
charges five lines per unit across both passes, including this optional debug
line. The no-check branch can additionally emit three stderr lines after all
ordinary parses fail: its warning, reason and possible-fix strings are charged
explicitly, giving5U+3 explicit newlines and a separate fixed-character term
(#204). The success branch emits one bounded stdout line. These are this
reporter's standard-stream deltas; the parent's shared output-file/channel
position is not reset. No failure becomes a proof.

## Reporter symbols, database and summary arithmetic

Let U be matching units; E_i be each producer's entity-table domain; h_i>=1
its maximum location-record chain; F_i,R_i,W_i its flow, proof and warning
row envelopes; G_i its accepted total reported goal-node occurrences.
The exported `selected_unit` obtains F/W/full/projected from the accepted
source interface and retains R/G/E/h. R/G/A are source-bound current
occurrences, not observed counts and not the superseded A<=4G assumption.

Parse_Entity_Table clears Subp_Map/Subp_Vector each file, then uses producer
Positive keys to grow/replace the vector and insert the hash map. Consecutive
producer keys<=E_i and stable name/location identity matter; a generic JSON
byte bound would not prevent an enormous sparse key or forged reference.
Each entity calls Mk_Subp once (one name Find), and each location record calls
Mk_Base_Sloc once (one filename Find). Ordinary Mk_Unit adds one Find per
file; SARIF has no Mk_Unit. Therefore the whole-process lifetime bound is

```
Find <= U + 2*sum E_i*(h_i+1)
unique symbols <= U + sum E_i*(h_i+1)
unique hash-consed subprograms <= sum E_i.
```

Pool/hash-cons state survives both per-file clears. From_JSON references use
vector lookup and introduce no extra Find. Each location list has<=h_i nodes;
the vector's peak is max E_i (using sum E_i in the callable is conservative).
The accepted third-pool hash endpoint, Natural lifetime counter, Positive
vector growth, list counts and copied-string guards apply. There is no
assumption import or transitive search: the config's absent assumptions flag
makes Handle_Assume_Items and Compute_Assumptions unreachable. Serialized
claim/assumption metadata is still parsed and Silver still audits it.

Database Unit_Map has<=U; all per-unit subprogram maps, Subp_Unit_Map and
ordered-output copies have<=sum E_i entries. A suppression list adds at most
one node per flow/proof row; selected pragma_assume/skip domains are empty.
Retaining a conservative suppression allowance avoids confusing the
source-specific zero case with the generic reader branch. Each row increments
at most one category counter and one per-subprogram counter. Put_Provers_Cell
uses at most five prover keys, including Trivial and Checker. Native
Most_Difficult_Proved_Checks is pruned after insertion: transient<=11,
retained<=10. No parsed JSON reference escapes to it.

For the accepted fresh goal forest, extract_stat_goal visits each descendant
of one recorded result at most once, chooses one successful proof per goal,
or adds one Checker count for an empty proved transformation. Each selected
leaf adds one count, not one per saved attempt. A conservative total

```
C = sum (F_i+R_i)
S = sum R_i*(G_i+1)
```

bounds the summary's check counts and cumulative prover-statistic counts;
the extra1 covers native PC_Trivial. Repeating G_i across rows is an intentional
loose upper bound, not a duplicate contribution to the producer's JSON schema.
`gnat_checks.ml:774–870`, `gnat_report.ml:135–156` and
`spark_report.adb:632–726,1197–1218` supply this transfer. The #193 statistics
shape now uses the accepted S_keys<=5R provider, correcting its earlier3.

Compute_Total_Summary_Line sums ten categories. Integer_Percent evaluates
**100*Part as Integer before conversion to Float**. Thus100*max(C,S)<=I is a
sufficient guard, not merely C,S<=I. Zero counts bypass percent formatting;
a nonempty statistics map on a successful selected row has positive total.
After percentages overwrite Count, Print_Max_Steps merges at most ten category
maps, each Count<=100; its only reported result is max steps. It does not
reintroduce the original S bound into this later percentage sum.

Numeric metadata requires the accepted producer/solver domains: represented
nonnegative steps/counts and finite nonnegative times. Print_Most_Difficult
additionally does Integer(Max_Time), so finite Float alone is insufficient.
`duration_ceiling<=I-128` plus0<=Max_Time<=duration_ceiling gives a conservative
safe conversion margin at the single-precision upper endpoint. This is an
explicit source/configuration clock obligation, not a time sampled from a
successful run, and no timeout is silently added to the command.

Print_Table allocates a fixed12-by6 table with cell predicate length<=1000.
Integer'Image of Natural can be11 bytes including its leading blank; the
source's assume<=10 comment is not used. Five names<=7, percentage images<=4,
separators and check-count image give the callable's82-byte prover cell;
six padded columns fit510 bytes. Text output emits sections/units/entities
incrementally, not one whole-file String. `collector` bounds a source line
by names, h locations, paths, up to four suppression strings and fixed text;
it separately bounds descriptor characters, explicit line count and encoded
file bytes. In the selected installed Text_IO, ordinary zero line/page lengths
prevent automatic line breaks; Col advances once per Character and only explicit
New_Line advances Line. Embedded LF in Put is not counted as New_Line. The
retained s-wchcnv transfer emits at most two bytes per Character across selected
encodings. Thus for H explicit lines and L maximum line characters, character
bound H*(L+1) yields encoded bytes<=2H*(L+1), with Line<=H+1 and Col<=L+1 checked
separately. Native String/backing demands use characters; the newly created
ordinary file's signed64 offset uses encoded bytes. The stderr owner receives
the same encoding factor plus its explicit no-check charge. These are repairs
to the interface/derivation, not demonstrated native overflows (#203–#204).
The fixed table dimensions remain fixed as source counts grow.

Native database records use at most fourteen scalar/handle fields plus
container linkage;4096 bytes overcharges each selected-ABI node/handle record,
with payload strings and backing arrays counted separately. A contiguous
bucket/vector request is<=64+4096*I under the accepted container cardinality
and growth guards, within unsigned64. Ordered/list structures allocate nodes
individually. This is not an aggregate-memory quota. Unbounded_String active
copies are sequential database mutation/output locals; no retained copy chain
grows with repeated printing. The conservative64-holder local census applies
per backing; symbol payloads use owned immutable strings instead of a finite
reference counter.

## Populated SARIF and VSS

SARIF generation is unconditional (`spark_report.adb:1576–1582`) and appends
one result per flow/proof/warn_error row across **all** units. Let
N=sum(F_i+R_i+W_i). Each result has one message,<=1 message argument,<=1
suppression, one primary location,<=1 related location, and<=1 logical
location under its primary location. No check_tree is copied into SARIF.
The fixed167 rule descriptors, one invocation and one run remain as in the
[accepted null SARIF provider](retained-producer-sarif-capacity.md).

The newly reached result/location/logicalLocation/suppression record layouts
are expanded from the complete same sarif-types.ads, with the provider's
selected-ABI leaf128, record16, discriminant16 and array-header32 envelopes.
The new element envelopes are result13,536, location13,088, logicalLocation1,152
and suppression13,952 bytes; vectors own separate arrays,
including old/new growth arrays and deep copies. For each generated vector,
capacity starts2 and grows floor(3*length/2); the callable checks **3*length**
before division as well as final length and individual byte request. A length
that fits Natural can still fail the growth-multiply guard. Root.runs.Append
copies My_Run, whose results assignment already copied My_Results; these
copies have exact populated length and do not renew append histories.

Message.arguments reaches VSS.String_Vectors, not a generated SARIF vector.
Accepted producer rows have at most one argument. Its one Append calls
Mutate(null,1,0); Aligned_Length uses header<=64, element<=128 and alignment<=64.
Conservatively bulk<=64 and request<=8256. This price includes unused alignment
slots. Later immutable copies increment the vector's unsigned32 counter;
there is no second Append/mutation of that message argument backing.

Let D=max(258, joined command, version,20, paths, every decoded report string).
To_Virtual_String validates UTF-8, initializes once, copies bytes and appends
NUL. It does not repeatedly append each source byte. D<=2^30-1 covers character
count; D+129<=I covers the selected heap-header/alignment intermediates and
request. Invalid UTF-8 is a conversion failure independent of byte length.
The source/installation path and configuration domains must provide UTF-8;
this note does not relax the file/audit failure behavior.

For a particular heap string or argument backing, every result field starts
fresh; separate messages do not share newly constructed backing. Count up to
32 caller constructor/aggregate/return boundaries, at most8 controlled
adjustment/copy stages along a path, and two temporary copies per boundary.
The eight-stage allowance covers controlled vectors (runs/results/locations/
logicalLocations or the rules/invocations path), the message-argument vector
and leaf adjustment. It is not a count of literal JSON field/record edges:
ordinary optional record wrappers forward adjustment of their controlled
components and do not independently multiply leaf holders. The
conservative512 (=32*8*2) initial-holder allowance, plus16 for each result/rule growth
copy step, bounds references even without credit for prior finalization.
Append growth happens before My_Run/Root copies; later output retains constant
references. `512+16*(g(N)+g(167))<2^32-1` applies separately to VSS text and
argument-vector counters; it does not borrow the null-only56 bound.

The typed output's populated depth is bounded independently of N. The push
writer has no document buffer or growing stack. Escaping visits immutable
strings one character at a time; each file Put encodes<=4 UTF-8 bytes and,
even charging an optional BOM, its short vector capacity<=8 and individual
request<=64. Actual BOM processing is disabled. The populated typed schema also yields a total SARIF byte bound and an
explicit signed64 file-offset guard; this price can use D for every string
without treating the resulting sum as a contiguous allocation. Total bytes
require disk capacity, but do not occupy a stored whole-document counter or a
String. Output paths separately require their UTF-8 C terminator.

File_Output stores write errors; Content_Handlers convenience methods test
Success and raise Assertion_Error, so creation/write failures can terminate
the reporter. Generated Outputs uses those methods. No assertion that SARIF
completion is certified by executionSuccessful=True is made. Close/finalize,
OS file offsets and ordinary correct I/O remain within the existing external
behavior/resource premises; mandatory Silver proof coverage comes from the
complete .spark reads and policies.

## Silver streaming, audit and scalable #89 duties

The output reader reads fgetc one byte at a time. Its native state is the
fixed projection State, file/status/item, Last and the caller's retained-byte
buffer. Raw_Bytes, Projected_Bytes, Report_Length/Report_State histories and
projection-audit sequences are Ghost=>Static; they do not allocate native
whole-file copies under the selected build. It emits at most two bytes per
input, tests `Next.Length > Buffer'Length - Last` before adding/copying, checks
EOF/ferror, projection completeness and fclose. Last resets per file; there
is no native counter of raw file bytes.

Projection **preserves whitespace outside removed check_tree values**. The
accepted actual bound is projected.pretty+1, including final LF; compact is
not this reader's byte bound. Raw full.depth still bounds projection nesting,
even for a large subtree whose bytes are discarded. This permits raw files
larger than the retained buffer without assuming their depth is small.

The present sufficient guards are projected bytes<=16,777,216 for Main,
<=262,144 per runtime report, raw projection depth<=64 and projected scanner
depth<=64. They are current implementation guards, not proposed language caps.
Library audit uses offset/span scans and a finite Boolean entity set. It
checks the entire document/end-of-input; progress, stop reason, skipped work,
Assume/warnings, exact entity coverage, each flow/proof row, dependencies and
owned postconditions remain mandatory. It does not allocate one native record
per JSON row. Reference lookup copies its digit span and adds one leading
blank; it does **not** Integer'Value the unbounded digit token. Largest such
copy<=retained bytes+1, with cursor spare<=bytes+2. At actual one-based call
sites the generic rebasing-copy branch is bypassed. The finite application
policy alternatives do not accumulate prior report state.

Null uses raw Read_File into the existing Main buffer; Complete_Null_Proof
rejects>262,144 and allocates Compact plus its trimmed Text copy. `silver_reader`
prices two whole-report local copies for this distinct policy. Its narrow
whitespace/substrings behavior is not generalized to arbitrary JSON.

#89 must implement/refine source-derived scalable retained capacity, raw and
projected nesting, cursor/token spares and audit copies for every admitted
source while preserving these complete policies. Options include segmented
storage or equivalent streaming state, but choosing one is future authorized
implementation, not a new correctness premise here. Current false guards do
not justify shrinking language admission or ignoring libraries. The required
refinement also preserves EOF/close checks, source correspondence, one-based
policy semantics, projection equality and failure behavior. This interface
specifies the mathematical demands and present limitations; it does not claim
the existing fixed buffers already admit arbitrary-sized reports.
