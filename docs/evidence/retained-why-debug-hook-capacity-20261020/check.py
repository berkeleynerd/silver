#!/usr/bin/env python3
"""Check retained inputs, selected native witnesses and hook arithmetic only.

This does not run gnatwhy3 or predecessor checkers, or prove the source theorem.
"""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
DISASM = Path('/tmp/silver-why-callback-closure-disassembly-20261018.txt')
ELF = Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
inputs = {}


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    path = Path(path)
    raw = path.read_bytes()
    name = str(path.relative_to(REPO)) if path.is_relative_to(REPO) else str(path)
    inputs[name] = identity(raw)
    return raw


def js(path):
    return json.loads(read(path))


def write(name, data):
    (HERE / name).write_text(json.dumps(data, indent=2, sort_keys=True) + '\n')


# Exact successful interfaces are imported; their checkers are not replayed.
PINS = {
    'retained-why-debug-formatter-control-20261020': (3383, 'f94f56f8f0f1cbd21002c89c569da7d938cc1f9fcb1bda7b149ce4205483ba4e'),
    'retained-why-exit-timing-growth-20261020': (21141, '8bce55d6799a8f2a9d1e17b2e2e532182b690ceb8f63c398388db6b1efae1d24'),
    'retained-why-exit-timing-format-20261020': (3369, 'e478798b548b127aac0d1184c0d7a5c88fb37087e34504bf2ca9b04b000c9c07'),
    'retained-why-save-format-allocation-20261020': (48814, 'bc61f76dbb1621eb18bd6714b5600b30a4dcd7dd04b08a0437126019ca2fe158'),
    'retained-why-save-formatter-core-20261020': (8508, '9709d2d703d01bb3d6e2a21fbe87ff3993c6f9c435f3c6ab72a577073f7479a0'),
    'retained-why-save-format-accumulator-20261020': (29716, '25a1ab4bbe4892c4bd9ce6e0c9f82b6379d3b200c81c5d1122fa87af70323ecd'),
    'retained-why-save-binder-formatter-stack-20261020': (3380, 'cca726643bb9a8a45aa8f02058e7e362bb365f31193347d0b0e83a93606d3ff8'),
    'retained-why-save-scalar-format-20261020': (1293, '8527fb0e2483cf36ebfb2fa63b065af21b2c2b0a55fedd1d64f3cb69811cd30a'),
}
providers = {}
for name, (length, digest) in PINS.items():
    raw = read(EVIDENCE / name / 'result.json')
    assert identity(raw) == dict(bytes=length, sha256=digest), name
    providers[name] = json.loads(raw)
for stem in ['retained-why-debug-formatter-control', 'retained-why-exit-timing-growth',
             'retained-why-exit-timing-format', 'retained-why-save-format-allocation',
             'retained-why-save-formatter-core', 'retained-why-save-format-accumulator',
             'retained-why-save-binder-formatter-stack', 'retained-why-save-scalar-format',
             'retained-why-save-exit-charge']:
    read(REPO / 'docs/research' / (stem + '.md'))
first = providers['retained-why-debug-formatter-control-20261020']
growth = providers['retained-why-exit-timing-growth-20261020']
extension = providers['retained-why-exit-timing-format-20261020']
assert first['constructor_state_preserved_until_first_stats_entry_under_selected_continuation']
assert first['newline_wrapper_depth'] == 1
assert first['initial_escape_buffer'] == dict(backing_equals_initial=True, capacity=42, position=0)
assert [c['uniform_counter_upper'] for c in growth['cases']] == [195, 162, 99, 12, 6]
assert all(c['debug_timing_callback_entries_whole_suffix_upper'] == 26 for c in growth['cases'])
assert all(c['total_distinct_key_bytes_upper'] == 1051 for c in growth['cases'])
assert extension['static_main_accumulator_nodes'] == 9
assert extension['static_annotation_nodes'] == 0
assert extension['normal_OCaml_conversion_requested_bytes_upper'] == 464

# These are projections of exact retained archives, not newly fetched source.
selections = [
    ('retained-why-session-helper-source-20261019/sources.tar.gz', 'why3/', {
        'src/util/debug.ml': [(75,96), (151,188)],
    }),
    ('retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz',
     'ocaml-8eb41f72ded84df884c3671734c947f612091f84/', {
        'stdlib/format.ml': [(218,288), (291,340), (427,505), (512,618),
                             (626,655), (665,682), (894,908), (934,1014), (1249,1311), (1354,1400)],
        'stdlib/buffer.ml': [(17,43), (69,95), (156,170)],
        'stdlib/hashtbl.ml': [(37,53), (154,170)],
        'stdlib/stdlib.ml': [(546,568)],
        'stdlib/camlinternalFormat.ml': [(1378,1460), (1515,1605), (1968,1978)],
    }),
]
witnesses = []
source = {}
for archive, prefix, paths in selections:
    path = EVIDENCE / archive
    read(path)
    with tarfile.open(path) as tar:
        for name, spans in paths.items():
            raw = tar.extractfile(prefix + name).read()
            source[name] = raw.decode()
            lines = raw.decode().splitlines(keepends=True)
            for lo, hi in spans:
                assert 1 <= lo <= hi <= len(lines), (name, lo, hi, len(lines))
                text = ''.join(lines[lo-1:hi])
                witnesses.append(dict(archive=str(path.relative_to(REPO)), member=prefix+name,
                    member_identity=identity(raw), first_line=lo, last_line=hi,
                    text=text, excerpt_identity=identity(text.encode())))
assert '<stats>@[%s: %f, %d@]@.' in source['src/util/debug.ml']
assert 'if len < 2 then Buffer.contents buf' in source['stdlib/format.ml']
assert 'if str = "" then (0, Pp_box)' in source['stdlib/camlinternalFormat.ml']
assert 'f key data; do_bucket next' in source['stdlib/hashtbl.ml']
assert 'while old_pos + more > !new_len do new_len := 2 * !new_len done' in source['stdlib/buffer.ml']
write('source-witnesses.json', witnesses)

raw = read(DISASM)
assert identity(raw) == dict(bytes=69046582, sha256='f79d14fcdc2715a2997035a5c416308653a69eabe427bbac8f8a2d0b2dc2c7a5')
bodies = {m[1]: m[0] for m in re.finditer(r'^\w+ <([^>]+)>:\n.*?(?=^\w+ <|\Z)', raw.decode(), re.M | re.S)}
elf = read(ELF)
assert identity(elf) == dict(bytes=24561432, sha256='7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368')
hdr = struct.unpack_from('<16sHHIQQQIHHHHHH', elf)
segments = [struct.unpack_from('<IIQQQQQQ', elf, hdr[5]+i*hdr[9]) for i in range(hdr[10])]


def at(address, size):
    s = next(s for s in segments if s[0] == 1 and s[3] <= address and address+size <= s[3]+s[5])
    return elf[s[2]+address-s[3]:s[2]+address-s[3]+size]


F = EVIDENCE / 'retained-why-save-binder-formatter-stack-20261020'
f_bodies = js(F / 'native-bodies.json')
f_frames = js(F / 'native-frames.json')
f_closure = js(F / 'formatter-call-closures.json')
js(F / 'formatter-spec.json')
js(EVIDENCE / 'retained-why-exit-timing-format-20261020/extension-spec.json')
js(EVIDENCE / 'retained-why-save-format-allocation-20261020/native-allocation-sites.json')
owned = {
    'camlWhy3__Debug__fun_3069': 16,
    'camlWhy3__Debug__print_1651': 16,
    'camlWhy3__Debug__fun_3056': 48,
    'camlStdlib__Hashtbl__iter_730': 80,
    'camlStdlib__Hashtbl__do_bucket_734': 32,
    'camlStdlib__Hashtbl__ongoing_traversal_278': 8,
    'camlStdlib__List__iter_507': 32,
    'camlWhy3__Debug__fun_2950': 16,
    'caml_apply2': 16,
    'caml_apply4': 32,
}
# The unused registered-stat callback is retained to identify the allocated
# closure. Its body never runs because the registered list is empty.
retained = list(owned) + ['camlWhy3__Debug__fun_3047']
frames = {}
checked = 0
for name in retained:
    body = bodies[name]
    for line in body.splitlines()[1:]:
        m = re.match(r'\s*([0-9a-f]+):\t((?:[0-9a-f]{2} ?)+)\s*(.*)', line)
        if not m:
            assert not line.strip(), line
            continue
        binary = bytes.fromhex(m[2])
        assert at(int(m[1],16), len(binary)) == binary
        checked += len(binary)
    if name in f_bodies:
        assert body == f_bodies[name]
    if name in owned:
        subs = re.findall(r'\bsub\s+\$0x([0-9a-f]+),%rsp', body)
        pushes = re.findall(r'\bpush\s+[^\n]+', body)
        assert len(subs) <= 1
        own = 8 + sum(int(x,16) for x in subs) + 8*len(pushes)
        assert own == owned[name], (name, own)
        frames[name] = dict(own_high_water_upper=own, trap_bytes=16 if name.endswith('iter_730') else 0,
                           simultaneous_instances_upper=1, body_identity=identity(body.encode()))
write('native-bodies.json', {n: bodies[n] for n in retained})
write('native-frames.json', frames)

direct = {n: sorted(set(x.split('+')[0] for x in re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>', bodies[n])) - {n}) for n in owned}
assert direct['camlWhy3__Debug__fun_3069'] == ['camlStdlib__Format__pp_print_flush_938', 'camlWhy3__Debug__print_1651']
assert direct['camlWhy3__Debug__fun_3056'] == ['camlStdlib__Format__fprintf_1781', 'caml_apply4', 'caml_call_gc']
assert direct['camlStdlib__Hashtbl__do_bucket_734'] == ['caml_apply2', 'caml_call_gc']
assert 'jmp    9819e4' in bodies['camlStdlib__Hashtbl__do_bucket_734']
assert 'call   9819e0' not in bodies['camlStdlib__Hashtbl__do_bucket_734']
assert bodies['camlWhy3__Debug__print_1651'].count('sub    $0x20,%r15') == 1
assert bodies['camlWhy3__Debug__print_1651'].count('sub    $0x28,%r15') == 1
assert bodies['camlStdlib__Hashtbl__iter_730'].count('sub    $0x20,%r15') == 1
assert 'sub    $' not in '\n'.join(l for l in bodies['camlWhy3__Debug__fun_3056'].splitlines() if '%r15' in l)
control = dict(
    root='camlWhy3__Debug__fun_3069', direct_targets=direct,
    callback_targets={
        'Hashtbl.do_bucket -> apply2': 'exact-arity-two camlWhy3__Debug__fun_3056, not its stored curry2 entry',
        'Debug.fun_3056 -> apply4': 'fprintf unary wrapper, then fixed string, float and integer argument closures',
        'Debug.fun_2950 call 0x559c8d': 'captured Format.fun_2407 default newline -> Buffer callback',
        'Debug.fun_2950 tail 0x559ca7': 'captured Format.fun_2447 ignore flush',
        'List.iter 0x94911e': 'unreachable on empty registered_stats; allocated fun_3047 never runs',
    },
    excluded={'Hashtbl.iter array-bound error': '64-slot backing and loop index 0..63; no resize',
              'old F serializer imports': 'No %a/%t/Acc_delay in timing template or empty annotation',
              'old F name/constant roots': 'No identifier, Shape or constant printer in this hook',
              'old F channel callbacks': 'Both main and annotation formatters use Buffer callbacks',
              'annotation parser scanners': 'Empty annotation returns static (0,Pp_box) immediately'},
    added_services=['caml_call_gc', 'caml_raise_exn'],
    imported_F_service_frontier_superset=f_closure['services'],
    caller_adapters_charged_outside_F=['caml_apply2', 'caml_apply4'],
    once_gate_wrapper_and_exit_dispatch='Outside this root, retained exit-owner charge',
)
write('native-control.json', control)

# Reuse exact owned-frame sums, not a maximum-frame-size times symbol count.
ordinary = [n for n in f_closure['bodies'] if not n.startswith(('caml_apply', 'caml_curry')) and n != 'camlStdlib__Format__output_acc_1688']
adapters = [n for n in f_closure['bodies'] if n.startswith(('caml_apply', 'caml_curry'))]
assert sum(f_frames[n]['own_high_water_upper'] for n in ordinary) == 2392
assert sum(f_frames[n]['own_high_water_upper'] for n in adapters) == 176
assert f_frames['camlStdlib__Format__output_acc_1688']['own_high_water_upper'] == 32

C = 26
B = 1051 + C*348
E_main = 9*C + 1
E_annotation = 1
I_main = 3*E_main + 1
I_annotations = C*(3*E_annotation + 1)
I_total = I_main + I_annotations
L = B + E_main
N = 4*(E_main + 1)
assert L+79 <= 1000000010 and N+2 <= 2**62-1
output = B + 70*(E_main + 1)
callback_calls = 4*(E_main + 1)
assert (B, E_main, I_main, I_annotations, I_total, L, N, output) == (10099,235,706,104,810,10334,944,26619)
S = lambda n: 8*(1+(n+8)//8)
capacities = []
capacity = 42
while capacity < output:
    capacity *= 2
    capacities.append(capacity)
assert capacity == 43008 and sum(S(c) for c in capacities) == 86088
assert capacity <= 2**57-9 and (capacity+8)//8 < 2**54
assert max(2*capacity, output, L+79, N+2) < 2**62-1
allocation = dict(
    dynamic_core_main_and_annotations=640*I_total,
    annotation_formatter_fixed=640*C,
    accumulator_argument_and_format_continuations=C*(128+192*9),
    float_conversion_blocks=C*464,
    integer_conversion_string_blocks=C*32,
    annotation_Buffer_records_and_backings=C*(40+S(16)),
    annotation_contents_string_allowance=C*S(0),
    hook_and_Hashtbl_closures=32+40+32,
    main_Buffer_new_backings=sum(S(c) for c in capacities),
)
requested = sum(allocation.values())
assert requested == 684672
initial = dict(formatter_fixed_upper=640, constructor_dynamic_upper=640,
               Buffer_record_and_initial_backing=40+S(42), captured_output_record_and_wrapper=48+32)
assert sum(initial.values()) == 1456
H, J, O = 3, 48, 11
formatter_stack = 2392*H + 176*J + 32*O
caller_stack = sum(owned.values())
assert (formatter_stack, caller_stack, formatter_stack+caller_stack) == (15976,296,16272)
write('transfer.json', dict(
    rows_upper=C, main=dict(B=B,E=E_main,I=I_main,L=L,N=N,
        sentinel_guard_left=L+79,sentinel_guard_right=1000000010,
        container_length_plus_sentinel_guard=N+2),
    annotation=dict(streams_upper=C,B=0,E=1,I_each=4,output_bytes=0,Buffer_capacity=16),
    I_total=I_total, output_bytes_upper=output, core_callback_calls_upper=callback_calls,
    Buffer_capacities_charged=capacities, Buffer_largest_capacity=capacity,
    maximum_new_block_bytes=S(capacity), main_Buffer_new_backing_requests_upper=len(capacities),
    allocation_requested_blocks=allocation, allocation_requested_total=requested,
    initial_owned_object_charges=initial, initial_owned_object_charge_total=sum(initial.values()),
    owned_base_plus_no_reclamation_envelope=requested+sum(initial.values()),
    stack=dict(H=H,J=J,O=O,F=formatter_stack,caller=caller_stack,total=formatter_stack+caller_stack),
    separate_normal_C_saved_format_requests=C*21,
))
write('result.json', dict(
    scope='One selected once-only Debug Stats timing hook, including abandoned source prefixes, to explicit service frontiers',
    cases=[c['case'] for c in growth['cases']],
    first_use_provider_freeze='7ead79763d239bbd81ed734b2aaa1ef01d8cc747',
    first_use_acceptance_report='ec08dd19e5ee5efc85885c4b1746672723908a22',
    source_owned_hook_capacity_closed_under_named_premises=True,
    semantic_theorem_proved_by_checker=False,
    assumptions=[
        'Existing selected typed-source/native/runtime/loader relation and valid representations',
        'Accepted first-use state and callback preservation; accepted timing growth and once-only gate',
        'Each numeric/allocation/copy service returns normally within its retained contract or escapes; failed-service internals retain R ownership',
        'Preserved effective numeric locale and retained GNU Float_f normal-return contract',
        'Faithful runtime callbacks do not corrupt or replay partial hook frames; global r<=3 and e<=2 never reset',
    ],
    rows_upper=C, raw_text_bytes_upper=B, main_core_operations_upper=E_main,
    empty_annotation_streams_upper=C, dynamic_queue_insertions_charge_upper=I_total,
    offered_Buffer_bytes_upper=output, main_Buffer_capacity_upper=capacity,
    main_core_callback_calls_upper=callback_calls,
    default_indentation_bytes_per_call_upper=68,
    source_owned_new_OCaml_requested_block_bytes_upper=requested,
    initial_owned_formatter_Buffer_charge_upper=sum(initial.values()),
    owned_initial_plus_new_objects_no_reclamation_envelope=requested+sum(initial.values()),
    largest_new_OCaml_block_bytes=S(capacity),
    owned_hook_stack_to_service_frontiers_bytes=formatter_stack+caller_stack,
    formatter_stack_bytes=formatter_stack, extra_caller_stack_bytes=caller_stack,
    Debug_newline_wrapper_included_bytes=16,
    once_gate_wrapper_and_exit_dispatch_included=False,
    conditional_normal_C_saved_format_requested_bytes_upper=C*21,
    float_C_wrapper_shell_in_R_bytes=512,
    C_bridge_GC_runtime_allocator_libc_and_signal_stack_included=False,
    ambient_A_pre_included=False,
    budgets_restarted=False,
    maximum_active_Stats_hooks=1,
    after_partial_failure_formatter_constructor_freshness=False,
    failed_service_resource_capacity_established=False,
    actual_continued_numeric_service_join_established=False,
    physical_GC_allocator_stack_sufficiency_established=False,
    complete_exit_capacity_established=False,
    complete_exit_stack_established=False,
    complete_save_capacity_established=False,
    native_bodies=len(retained), native_instruction_bytes_checked=checked,
    source_witnesses=len(witnesses),
    target_runs=0,new_captures=0,new_disassembly_runs=0,source_fetches=0,
    predecessor_checker_replays=0,solver_runs=0,
))
write('inputs.json', inputs)
write('manifest.json', {p.name: identity(p.read_bytes()) for p in sorted(HERE.iterdir())
                        if p.is_file() and p.name not in {'manifest.json','round.json'}})
print(json.dumps(dict(status='PASS',native_bodies=len(retained),
    native_instruction_bytes_checked=checked,source_witnesses=len(witnesses),
    new_requested_blocks_upper=requested,owned_hook_stack_upper=formatter_stack+caller_stack)))
