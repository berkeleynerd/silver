# Returning failures before fixed-library registration

2026-10-23 UTC; #119 / #153. Author source interface, pending independent
review. This is a new source attachment
to the fixed-five-domain continuation composition. It does not amend that
accepted provider or treat successful startup as an assumption excluding
ordinary returning open/connect/read failures. The exact fixed valid JSON,
configuration, library and plugin bytes, source/native correspondence, one
OCaml worker, selected Why-only SIGINT mask and ordinary runtime/resource
boundary are retained. Arbitrary Main remains separate.

## Source routes that matter

The normal prefix and the failing prefix are alternatives. An abort which
returns from its JSON writer calls exit; one whose output fails unwinds its
caller. The accepted standard-prefix observer proves that ordinary abort
failure cannot become the Not_found consumed by registration's iter_leafs.
Thus abandoned abort output is not added to a later successful-cut suffix in
the same run. The new failing alternative still needs its own capacities.

| Phase | Actual returning-failure path |
| --- | --- |
| Configuration | Rc.from_file wraps an open failure as CannotOpen(f,s); a read or close failure escapes, with a failed close replacing the earlier error. Gnat_config handles CannotOpen and ConfigFailure by constructing an abort string. |
| Driver discovery | find_driver_file tries the given name, optional extra-config relative name, optional extra-dir relative name and installed-driver name. Failure of all probes constructs one abort string and terminates that mapping; it does not visit the remaining provers. |
| Plugins | The two fixed Plugin.load calls can fail their file probe or native open/read/mapping operation. Stable valid plugin/ABI inputs exclude malformed-file and binding-mismatch explanations, not service failure. Native loader text needs the explicit scalar transport below. |
| Controller/session creation | mkdir, driver opens/parsing and file I/O failures propagate to main. Fresh session state excludes old-session restore/reload. The initial driver integer-conversion diagnostic can attempt one stderr message before unwinding controller construction. |
| Native input and imported libraries | Controller.add_file catches one error from Session.read_file, creates at most the detached file section and raises Errors_list with a singleton list. init_cont may format that one error and attempt its own abort. A subsequent relativize/file-section failure replaces the earlier exception. |
| Typing error diagnostic | gnat_ast_to_ptree.read_channel handles a typing exception by attempting .sexp and .mlw output of the complete generated Ptree. The Located arm formats a marker first and replaces that outer location with Located_by_marker. This route is reachable for an ordinary imported-library service error even when the input tree is valid. |
| External connection | Prove_client.client_connect catches Unix_error into a fixed connection message, or builds the generic message through Printexc.to_string. A failed cwd restoration replaces the original connect exception; it does not recurse or retry connection. |
| Logging initialization | Its private open can fail before registration. It propagates to main; it supplies no standard output or new process. |
| Registration | Missing trace/label paths can attempt abort. Gnat_loc's Failure handler can be followed by parse_check_string's outer Failure handler; these are distinct attempts. |
| Main and uncaught processing | Main has one handler outside its own try; Out_of_memory skips it. One configured uncaught handler can run next. Its failure invokes the runtime's fixed fallback, which does not call the configured handler again. |

This census must remain distinct from the post-registration terminal theorem.
In particular its two-abort count and depth-two exception argument are not
silently assigned to the new prefix.

## Abort count and backtraces

The maximum source nesting of explicit caller aborts is two: Gnat_loc.parse_loc
inside Gnat_expl.parse_check_string. Neither handler catches its own body.
Other selected branches have at most one explicit caller abort: config,
driver discovery, init_cont's singleton add-file error, a missing trace or a
single other label handler. No normal report is attempted before registration.

After these caller levels, main can attempt one abort and the configured
uncaught handler one more. Therefore **at most four abort-JSON attempts** is
a conservative common count. Configuration failure before main needs at most
two; an init_cont/add-file error at most three; direct connect failure at most
two. Initial private-message construction failure can only skip an attempt.
The two standard Format exit flushes remain process-global once-gated events.
Repeated abort entry does not reset their gates or renew the e<=2 allowance.

The disabled-backtrace proof begins at runtime startup: the actual
OCAMLRUNPARAM has no b option and no selected argument, initializer, pending
client or failure handler enables recording. This part does not depend on
reaching registration. The uncaught handler's raw backtrace and its fallback
raw backtrace are therefore empty. Reuse the accepted 0/59-byte conversion
and per-invocation representation interfaces, including their failure cases.
There are at most two direct fallback Printexc conversions and two direct
raw-backtrace print attempts; no failure restarts this fallback.

## Direct scalar/configuration transports

Let P bound the actual selected filesystem arguments, inherited client cwd,
loader object spellings, location filenames and complete selected qualified
library spellings. It is a maximum over concrete source/configuration operands,
not an adopted pathname cap. Let U bound the raw GP_ label payloads transported
from the fixed native JSON. The packet binds the retained operands and leaves the actual client cwd
and complete joined P explicit. Arithmetic examples are not measurements of
those missing operands.

| Construction | Conservative byte function |
| --- | --- |
| Runtime Sys_error | P+51, from path plus ': ' plus C-locale strerror<=49 |
| Config CannotOpen abort argument | 2P+128, including the duplicated filename and fixed text |
| Missing-driver abort argument | 2P+256 |
| One malformed-label abort argument | U+256; the location handler's scalar Failure text is separately fixed |
| ConnectionError from Unix_error | 2P+1024, including strerror, fixed function name, arg and socket_name |
| Generic ConnectionError | 4P+2048, after the scalar Printexc rendering and fixed outer text |
| Native loader service Failure | P+512 under the fixed valid-image and C-locale source case below |

The connection message is not raw solver output. ConfigFailure is produced
around RC_load.config_from_rc, after Rc.from_file has returned. With the fixed
valid parsed config and complete mutation/runtime relation, ordinary file
service failure cannot masquerade as an RC missing-field/type failure. A
returning scalar/native failure inside conversion still reaches the catch-all:
its private render becomes ConfigFailure, then Gnat_config sends that string
directly to abort. This separate one-level render/copy construction fits the
common bounds below. A wider configuration family would require its actual RC
scalar-value envelope.

## Native loader message case

Retained glibc2.43 dlfcn/dlerror.c constructs objname, an optional ': ', the
selected fixed errstring, and optionally ': ' plus strerror. Failed asprintf
returns the original shorter errstring. The reached open/stat/read/map/protect/
close/allocation-error arms in dl-load, dl-map-segments, dl-reloc, dl-open and
dl-tls use fixed C-locale strings. The fixed valid plugin/linked-image relation
excludes corrupted ELF, unresolved bindings, version mismatch and arbitrary
plugin initializer code. It still permits permission, open, read and mapping
service errors. Bound objname by P and the selected literal by 256; including
two separators and strerror<=49 is below P+512.

The packet retains selected source spans and the complete selected-file Debian
patch projection. `any/unsubmitted-ldso-machine-mismatch.diff` adds a
wrong-machine skip, outside the valid x86_64 image relation. The multilib patch
is ARM-conditional. No selected service-message branch is altered, and the
release-update patch has no selected-file diff. Fatal loader diagnostics that
terminate without returning are not an OCaml exception result; their existing
native service owner remains separate. This is a source-message argument
within the trusted libc/native correspondence, not an allocator/kernel audit.

Native Dynlink makes the loader message a Failure and wraps it once in
Cannot_open_dynamic_library. A fixed plugin initializer may similarly fail
with a scalar exception and use Library's_module_initializers_failed. Those
initializers register fixed extensions/printers; they do not load another
plugin. Plugin's Why branch calls Dynlink.error_message. The registered
Dynlink Printexc callback instead quotes its inner rendering with `%S`.

This branch has at most **three** inner scalar Printexc attempts: one from
each of the two possible Why passes and one from the Dynlink callback. The
last quotes its result with at most four bytes per input byte; default
Printexc treatment of the error's variant payload does not recurse. The outer
returned output is bounded by two unquoted child results plus one fourfold
quoted result and own constants, hence `7*C` below. For all private work,
charge three child packages, both Why concatenations/formatter copies, the
quoted construction, enclosing Dynlink construction, possible adapter
Buffer.contents and outer anomaly copies. `32*C` conservatively covers these
copies and the package's own constants/layout. This is below the common
`341*C` private allowance. At most four packages/1,280 direct events are
needed, below the common 9,936. We do not apply the ordinary two-child
recurrence directly to Dynlink.

## Ordinary wrappers and fixed identifier operands

Use the accepted wrapper-creation proof at its source scope, with a different
phase partition from the post-cut theorem:

* During initial typing, coalescing Loc helpers and one noncoalescing clone
  handler give at most two Located wrappers. A library lookup occurs before
  the clone trap, so recursive library reads do not accumulate clone wrappers.
  One BadI_rs_type may catch a scalar/native failure in `e_exec(c_app ...)`.
  That protected expression does not reenter cloning or source parsing.
* A selected Finally wraps its cleanup failure, replacing any body exception.
  The cleanup updates timing scalars or flushes/closes a private file; it does
  not parse a source file, clone a declaration or enter another protect.
  An outer cleanup failure replaces the old one. It cannot supply a chain
  of Finally wrappers or hide a Located from an outer location guard.
* Consequently initial typing has depth at most four: two Located, one
  BadI_rs_type and one Finally. The GNAT typing handler replaces its outer
  Located with Located_by_marker, keeping the same inner exception. It does
  not add a fifth wrapper. Its body is outside its own match trap.
* Registration's selected transformation path instead has at most three
  TransFailure layers and one Finally. It does not run initial source parsing
  or place the typing exception inside those transformations: typing must
  return a controller before registration begins. These are alternative
  phases, not a sum of seven layers. Singleton Errors_list is unwrapped by
  init_cont's list printer rather than recursively dispatched as a wrapper.
* ConfigFailure's private render/copy, initial built-in Pmodule error-to-Message
  constructions, and connection-message construction are separate startup
  phases. They do not surround typing or registration. Their fixed outer text
  and copies fit the common depth-four majorants. The three Pmodule initial
  values are sequential module initializations, not mutually nested handlers.
* A failed printer retains the original registry argument, as in the accepted
  dispatch proof. A failed main/custom/abort reporter supplies a new scalar
  error; it does not enclose the JSON or the original exception. It cannot
  deepen these value/construction chains.

This retains ordinary scalar/service failures and incomplete output prefixes.
It uses the fixed valid JSON/config/library/plugin, represented-operation and
source/native relation for successful computation between those failures.
An ordinary open/read/connect failure does not manufacture a malformed input,
logical type mismatch or an arbitrary foreign exception. No successful-service
premise removes the failure routes. The existing classified returning
Thread/SIGVTALRM/native clients remain admitted; Why-only SIGINT masking
removes the pre-cut save/exit reentry, not those clients.

BadI_rs_type prints the **original cloned routine's** `rs_name`, at
`pmodule.ml:1376–1391`, before construction of the `'refn` name at 1394.
The selected case refines an abstract routine. Its head comes from an original
source/Ptree binder (or a bounded tuple name); id_clone preserves that spelling.
The new native Ptree input packet at `09d9a2382f` bounds every direct string
payload by 202 bytes, hence every original Ptree id_str. The packet's independent
lexical projection checks all 21 exact initial library files: conservative
word-identifier candidates, including comments and strings, have maximum 82.
The numeric-token boundary prevents the `x...` part of a long hexadecimal
literal being misclassified as a word identifier. Symbolic routine heads have
fixed operator spellings. Tuple names need at most 25 bytes. Thus **N_id<=467**
is a conservative original-head envelope, without borrowing post-cut SMT
printer names or measuring only the names that survived registration.

The accepted BadI printer source uses `Pretty.print_id`, then
`Ident.print_decoded`; it does not enter an identifier uniqueness table. Its
own offered text is at most `N_id+52`, and the optional notation-suffix private
helper has at most `N_id+8`; 32 own events cover both. This join still requires
the raw Ptree capture's separate immutable-input/source/native/configuration
transport. The capture's discovered third native module-tuple field does not
change its raw maximum-string fact; this packet does not pretend that the
source pair declaration proves that native layout.

## Rendered bytes versus all private work

Let

```
S = max(467, U+256, 4P+2048, N_id)
K = 723 + 12*S
C = 8*K + 65536.
```

The 467 literal interface is imported at its selected fixed-code scope; fixed
plugin exception names/messages follow their retained source constructors.
K covers default/Unix scalar representations, path/qualified-library printers
and the own prefixes of the wrappers above. The selected library paths have
at most two components; their list-print events fit the same 32-event own
allowance. Compiler source positions retain the ordinary 20-byte integer and
fixed-file-name interface. Primitive conversions do not copy rejected input
unless separately shown above. Disabled automatic Sexplib default printers do
not create another callback route for a service exception.

Reuse the dirty-private-formatter/Buffer invariant, 55-candidate registry and
320-direct-event package allowance from the terminal provider. Freshness does
not imply a clean successful drain: caught printer failures may leave boxes
and partial mutations, so the interrupted-core bound applies. Each package
has at most two strict-child dispatches. The own nonrecursive construction,
text and layout fits C. Crucially, use different inductions for different
quantities:

```
R[-1] = A[-1] = 0
R[d] = 2*R[d-1] + C    # bytes returned/offered at this root destination
A[d] = 4*A[d-1] + C    # aggregate private construction, offers and copies
R[4] = 31*C
A[4] = 341*C
E_private = 320*(2^5-1)+16 = 9936.
```

A child's rendered bytes enter the parent's output at most once per child
attempt. An unquoted copy is not four new bytes at that destination. The
separate aggregate A pays the child work and its possible enclosing copy.
At the common owner, layout is additive over the actual descendant events;
charging 70 times each package's events and entry allowance is conservative
under the imported interrupted-core inequality. The large fixed C also pays
the own prefixes and helper endings. The identifier decoder is a separate
small owner covered by its n+8 interface; ordinary annotation-helper owners
retain the R67 representation proof. Neither is shared standard output.

A depth-four aggregate fits each private owner conservatively by applying the
core guards to `B_private=A[4]+P+1024`, `E_private=9936`. This also pays the
outer main/custom/add-file text. The resulting returned abort payload is at
most `x=R[4]+P+1024`, and **X=4*x** is the sum of four abort payloads. These
are per-owner representation arguments, not a cumulative RAM/stack limit.

## Marker-specific export

The Located typing handler removes its outer location before formatting
`" ERROR %a: @?"`. The marker's **inner** depth is at most three. Its scalar
origins are the typing/library phase: connection errors, config payloads,
Dynlink and GP_ label-abort messages cannot enter that suspended typing
handler. Therefore use the smaller typing scalar base

```
S_marker = max(467, P+51, N_id)
C_marker = 8*(723+12*S_marker)+65536
M_marker = 15*C_marker+1024
A_marker = 85*C_marker+1024
E_marker = 320*15+16 = 4816.
```

M_marker is a returned **string-byte** bound. A_marker and E_marker separately
bound its private construction/dirty-core owner; the serializer must not
multiply A_marker as if all those private copies appeared in the marker.
The 1024 allowance covers the fixed prefix/suffix, explicit flush and helper
finishing. For P<=416 and N_id<=467, M_marker=**1,743,304 bytes**. This is an
arithmetic range, not an imposed path cap or a new input restriction.

## Separate Ptree diagnostic interface

The lead coordinates the separate fixed-Ptree serializer attachment. Its inputs are the
complete immutable Ptree generated from each exact native JSON, including
expanded/shared fields, strings, attributes, numbers and locations. Declaration
counts alone are not a complete tree measure.

The helper attempts, in order, Ptree.sexp_of_mlw_file, Sexplib.Sexp.to_string,
open/output/close of remove_suffix('.gnat-json',filename)+'.sexp', then one
Mlw_printer.pp_mlw_file ~attr:true through a private formatter and a matching
'.mlw' open/close. A failure stops that sequence; the handler cannot reenter
itself. The Located alternative additionally provides one preformatted marker
message. The expected serializer export is a function of that message's byte
bound, with source/native representation guards for both private serializers,
their file outputs and synthetic-location counters. It is not supplied by the
bounded Why result JSON or by the successful-prefix allocation transfer alone.

## Shared standard roots and channels

The exact abort record has three keys, one message string, one Boolean and
an empty results list. Its five annotated record/binding/list boxes and fixed
keys/punctuation need fewer than 128 text bytes and128 direct core events per
attempt. The imported all-byte escape theorem contributes at most 6n text
bytes and 2n direct events for a payload of n bytes (the fixed allowance pays
its quotes). Four abort attempts therefore give `6X+512` bytes and `2X+512`
events. No normal result JSON is produced on this failing prefix.

The initial driver integer diagnostic occurs at most once. The accepted full
14-file driver syntax census has parsed numeric substrings of at most two
bytes; using its looser four-byte interface gives the existing 64-byte/8-event
fragment. Registration/driver failure cannot resume controller creation.
Add the two globally gated standard exit flushes once:

```
B = 6*X + 512 + 64
E = 2*X + 512 + 8 + 2
L = B+E; I = 3*E+2; T = 1000000010+L+1
L+79 <= 1000000010
(3*E+1)*T + L+79 <= 2^62-1
4*I+2 <= 2^62-1.
```

The standard constructor-state/writer partition is used from startup, before
any new writer in this census. We do not assume that the failed run reaches a
fresh registration cut. Keep the same constructor state and charge all failed
prefixes through the shared cores. At most 20 fixed annotation helpers belong
to the four abort record attempts; their per-owner operands retain R67's small
fixed-description proof.

Direct uncaught fallback contributes at most `2*R[4]+253` channel bytes,
including its two empty-raw-backtrace print attempts and fixed fallback lines.
It contributes no standard Format events. The pre-cut missing-parent result
callback is absent; do not add or renew the suffix warning backtrace budget.
Using the accepted selected pipe/channel offset construction, the common
prospective offer is

```
Y_channel = B + 70*(E+2) + 2*R[4] + 253 <= 2^63-1.
```

For arithmetic orientation at P=180, every retained U gives the same
S=2768, C=337048, R[4]=10,448,488, A[4]=114,933,368 and
X=41,798,768. All scalar private/core/channel guards pass. The exact values
and per-domain U are in result.json. This is not an actual cwd attachment.

## Configuration and composition boundary

P is the maximum of the actual client initial cwd byte length; source-selected
config/overlay, driver probe and plugin/object spellings; the 21 initial
library candidate families under the four retained Env directories and five
extensions; source input/log/session and diagnostic `.sexp`/`.mlw` names; and
the selected Loc filenames/complete qualified library spellings. The exact
constructor functions in the retained source define this finite maximum.
The successful path projection supplies initial filename maximum 180 and
native JSON maxima U; it does not pretend to have observed client cwd, which
its process record lacks. Library probes use the whole initial family here;
the later four-library 167-byte number is not silently substituted. Loader
objname is its selected object name/path from the unchanged valid-image and
loader argument relation, including fixed dependencies, not arbitrary foreign
text. A deployment evaluates these operands instead of adopting the example.

Define `PrecutScalar(P,U,N_id)` as the source/client/immutable-input premises
above, these operand attachments and all displayed private/core/channel
inequalities. This packet exports that conditional interface and M_marker to
the separate Ptree serializers. A full failed-prefix capacity join additionally
needs their complete `.sexp` and `.mlw` owners and file/channel counters; the
Ptree module extra-field and configuration transport are owned by that new
provider. Existing successful-prefix owner evidence is reused only at its
finite-prefix scope, and the failed-prefix and successful-continuation cases
are alternatives. The earlier fixed-five continuation freeze remains unchanged.

The [evidence packet](../evidence/retained-precut-failure-capacity-20261023/README.md)
checks retained input/source/patch identities, original library head bounds,
raw capture maximum and conditional arithmetic. Semantic closure, destination
copy reasoning and source/native transfer require independent review. No
complete pre-cut, whole-process, #153 or #119 result is claimed here. Oracle,
admission and tool identities remain unchanged. This lane ran no target,
compiler, solver, proof, capture, disassembly, source fetch or predecessor
checker. The lead's new raw Ptree capture is an imported input, not this lane's
run. Selected GPT-6 Astra / Extra High; runtime confirmation and isolated
cost/token telemetry unavailable. Parent owns exact-freeze review, integration,
publication, issue updates and shared memory.
