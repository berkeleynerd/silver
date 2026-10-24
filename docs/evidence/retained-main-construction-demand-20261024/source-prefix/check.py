"""Focused source/identity and actual-populated-state transport checks only."""
import inspect
import json
import platform
import sys
import time
from collections import Counter

sys.dont_write_bytecode = True
from source import ARCHIVE, HERE, ROOT, digest, read_sources, reference_inventory, source_witnesses
from prefix import CONFIGURATION, OWNER_NAMES, PROVIDER, typing_entry

started = time.monotonic()
groups = Counter()


def check(ok, group):
    if not ok:
        raise AssertionError(group)
    groups[group] += 1


def pin(row):
    data = (ROOT / row['path']).read_bytes()
    check(len(data) == row['bytes'] and digest(data) == row['sha256'], 'provider/immutable identity')


inputs = json.loads((HERE / 'inputs.json').read_text())
pin(inputs['archive'])
for row in inputs['providers'] + inputs['immutable_earlier_packet']:
    pin(row)
prefix = inputs['research_prefix']
research = (ROOT / prefix['path']).read_bytes()
check(digest(research[:prefix['bytes']]) == prefix['sha256'], 'research prefix preserved')
check(b'## Populated source prefix to typing entry' in research[prefix['bytes']:], 'new argument appended')

sources = read_sources()
recorded = json.loads((HERE / 'source-witnesses.json').read_text())
current = source_witnesses(sources)
check(len(recorded) == len(current) == 18, 'all source files bound')
for expected, actual in zip(recorded, current):
    check(expected == actual, 'full source identity and exact excerpts')
inventory = reference_inventory(sources)
check(inventory == json.loads((HERE / 'reference-inventory.json').read_text()), 'complete reference/open inventory')
closure = json.loads((HERE / 'source-closure.json').read_text())
for file, row in inventory.items():
    for name, lines in row['qualified_references'].items():
        check(name.split('.')[0] in closure['reference_classes'] and bool(lines), 'reference family classified')
    for opened in row['opens']:
        check(opened['module'] in closure['open_classes'], 'open namespace classified')
check(set(inventory['plugins/gnat_json/gnat_ast.ml']['qualified_references']) ==
      {'List.assoc', 'List.length', 'List.map', 'List.mem_assoc'}, 'decoder external family closed')
for p in ('plugins/gnat_json/gnat_ast_to_ptree.ml', 'plugins/gnat_json/ptree_constructors.ml'):
    refs = inventory[p]['qualified_references']
    check({x for x in refs if x.startswith('Ident.')} <=
          {'Ident.create_attribute', 'Ident.op_infix', 'Ident.op_prefix'}, 'Ident uses only auxiliary attributes/notation')
    check({x for x in refs if x.startswith('Ity.')} <= {'Ity.MaskVisible'}, 'Ity is variant constant only')
    check(all(x.startswith('Ty.mk_') for x in refs if x.startswith('Ty.')), 'Ty resolves to local syntax constructor family')

text = {p: data.decode() for p, data in sources.items()}
converter = text['plugins/gnat_json/gnat_ast_to_ptree.ml']
ctors = text['plugins/gnat_json/ptree_constructors.ml']
session = text['src/session/session_itp.ml']
env = text['src/core/env.ml']
anchors = [
    ('fresh session add_file after C', text['src/gnat/gnat_checks.ml'],
     'let c = Controller_itp.create_controller Gnat_config.config Gnat_config.env session in\n  if is_new_session || not (has_file session) then begin\n    try\n      Controller_itp.add_file c Gnat_config.filename'),
    ('parser evaluated before store', env, 'let fp env path fn ch = store lang env path (fp env path fn ch) in'),
    ('one reader invocation', env, 'try fp env path file ch; close_in ch; ff'),
    ('parent language forwards parser unchanged', env, 'regf = (fun inf fp -> register_format parent inf fp)'),
    ('parser exact registration', converter, 'Pmodule.mlw_language gnat_json_format [gnat_json_file_ext] read_channel'),
    ('constructor namespace shadows Why3', converter, 'open Why3\nopen Ptree\nopen Gnat_ast\nopen Ptree_constructors'),
    ('E instantiation', converter, 'mk_of_expr (module E) node'),
    ('T instantiation', converter, 'mk_of_expr (module T) node'),
    ('variant direct T instantiation', converter, 'process_call (module T) v r.cmp_op [new_var_term;old]'),
    ('attribute owner distinct', text['src/core/ident.ml'], 'let create_attribute s = Hsattr.hashcons'),
    ('file tag separate counter', text['src/util/loc.ml'], 'let tag_counter = ref 0'),
    ('location source initializer', ctors, 'let loc_counter = ref 0'),
    ('location eager initialization', ctors, 'let result_ident = mk_ident [] "result"'),
    ('call-ID source initializer', converter, 'let next_call_id =\n  let counter = ref 0 in\n  fun () -> incr counter; !counter'),
    ('eager default is charged', converter, 'Option.value ~default:(mk_ident [] "???") id'),
    ('unused declaration still constructed', converter, 'ld_loc = get_pos (); ld_def = None'),
    ('connection array arithmetic residual', converter, 'let mid = (from + to_ + 1) / 2'),
    ('all source location columns zero', converter, 'Loc.user_position r.filename r.line 0 r.line 0'),
    ('synthetic location columns zero', ctors, 'Loc.user_position "<dummy>" line 0 line 0'),
]
for name, haystack, needle in anchors:
    check(needle in haystack, 'source semantic anchor: ' + name)
reader = converter[converter.index('let read_channel env path filename c ='):]
offsets = [reader.index(s) for s in ['Yojson.Safe.from_channel c', 'From_json.file_from_json json',
           'let mlw_file = mlw_file gnat_file.theory_declarations', 'let print_mlw_file ?mark () =',
           'match Typing.type_mlw_file env path filename mlw_file with', 'print_mlw_file ();']]
check(offsets == sorted(offsets), 'entry sequence and deferred printer')
read_session = session[session.index('let read_file env ?format fn ='):]
check(read_session.index('Env.read_file') < read_session.index('| theories, format ->') <
      read_session.index('Ident.id_register'), 'session registration follows parser return')
check(not closure['source_argument_machine_proved'] and not closure['full_parser_representation_closed']
      and not closure['full_builder_entry_attachment_closed'], 'human theorem and scope explicit')

packet = json.loads(PROVIDER.read_text())
roles = packet['entry_envelopes']
check(set(roles) == {'first_or_default', 'input_is_valid', 'is_message', 'put', 'put_line'}, 'exact five-role domain')
check(packet['configuration'] == CONFIGURATION, 'exact accepted R78 configuration')
check(list(inspect.signature(typing_entry).parameters) == ['role', 'configuration'], 'no arbitrary state or certificate API')
exports = {role: typing_entry(role) for role in roles}
for role, out in exports.items():
    incoming = roles[role]
    for owner, provider_name in OWNER_NAMES.items():
        initial = incoming['owners'][provider_name]
        row = out['owners'][owner]
        check(row['counter_upper_at_C'] == row['counter_upper_at_T'] == initial['counter_value_upper'], 'actual populated counter bound transported')
        check(row['actual_counter_equal_at_C_and_T'] and not row['exact_actual_counter_known'], 'bound is not invented exact value')
        check(row['new_constructor_requests'] == row['new_counter_increments'] == 0, 'zero new three-owner requests')
        if owner != 'Ident':
            b = initial['backing']
            check(not b['current_state_is_creation_state'], 'populated backing provider used')
            check(row['same_backing_geometry_upper_at_C_and_T'] == {
                'outer_length': b['outer_length_upper'], 'bucket_max': b['bucket_length_upper'],
                'allocated_slots': b['allocated_bucket_slots_upper']}, 'full actual backing envelope preserved')
            check(row['actual_outer_and_bucket_lengths_unchanged'] and row['weak_clearing_allowed'] and
                  not row['live_contents_or_occupancy_claimed_unchanged'], 'weak clearing distinguished from geometry')
    multiplicities = out['source_entry_multiplicities_on_path_reaching_T']
    check(len(multiplicities) == 16 and sum(multiplicities.values()) == 10, 'exact single pre-T source spine')
    check(all(multiplicities[x] == 0 for x in ['Typing.type_mlw_file_body', 'imported_library_parser_entries',
          'typed_contract_builder_entries', 'typing_proxy_or_overload_candidates',
          'Session_itp.post_read_identifier_registrations', 'Env.post_parser_store']), 'post-T work not prepaid')
    check(out['actual_populated_three_owner_transport_to_T_established'] and
          not out['state_bounds_usable_at_T']['can_skip_T_to_builder_transport'], 'actual T state does not certify builder entry')
    check(not any(out[k] for k in ['complete_parser_converter_representation_closed',
          'actual_selected_builder_entry_attachment_established', 'complete_Main_source_candidate_multiplicities',
          'complete_source_to_initial_vc_storage']), 'all surrounding closure flags remain false')
    aux = out['auxiliary_prefix_interfaces']
    check(aux['Ident.Hsattr']['counter_upper_at_C'] == incoming['owners']['Ident.Hsattr']['counter_value_upper'] and
          aux['Ident.Hsattr']['backing_at_C'] == incoming['owners']['Ident.Hsattr']['backing'], 'Hsattr retains populated initial state')
    check(aux['Ident.Hsattr']['new_external_hashcons_attempts_upper'] is None and
          not aux['Ident.Hsattr']['argument_and_string_representation_closed'], 'Hsattr source demand unresolved')
    check(aux['Loc.FileTags']['current_counter_upper_at_C'] is None and
          aux['Loc.FileTags']['new_get_file_tag_attempts_upper'] is None and
          aux['Loc.FileTags']['current_geometry_upper_at_C'] == incoming['managed_static_carrier_words_upper'], 'FileTags residual is not old fixed-domain instantiation')
    check(aux['Ptree_constructors.loc_counter']['counter_at_C'] == closure['auxiliary_initializers']['loc_counter_at_C'] == 1 and
          aux['Gnat_ast_to_ptree.next_call_id']['counter_at_C'] == closure['auxiliary_initializers']['next_call_id_at_C'] == 0,
          'source synthetic initializers attached')
    for name in ['Loc.FileTags', 'Ptree_constructors.loc_counter', 'Gnat_ast_to_ptree.next_call_id', 'parser_converter_storage_and_arithmetic']:
        check(not aux[name]['representation_closed'], 'auxiliary representation remains explicit')
    check(out['process_budget'] == incoming['process_budget'] == {
        'escaping_save_exceptions': 2, 'save_entering_callbacks': 2, 'saves': 3}, 'single global callback/save budget')
    check(out['new_callback_or_save_allowance'] == out['constructor_orphan_increment_allowance_added'] == 0 and
          not out['aggregate_physical_memory_or_stack_gate'] and
          out['C_carrier_is_not_an_exit_heap_or_new_JSON_storage_bound'], 'no new allowance or aggregate gate')
for bad in ['', 'main', None, True, 0, [], {}]:
    try:
        typing_entry(bad)
    except ValueError:
        check(True, 'unsupported role rejected')
    else:
        raise AssertionError(('accepted role', bad))
for bad in ['r90_206', '', None]:
    try:
        typing_entry('put_line', bad)
    except ValueError:
        check(True, 'unsupported configuration rejected')
    else:
        raise AssertionError(('accepted configuration', bad))
try:
    typing_entry('put_line', counter_upper=0)
except TypeError:
    check(True, 'arbitrary state argument rejected')
else:
    raise AssertionError('arbitrary numeric state accepted')

(HERE / 'exports.json').write_text(json.dumps(exports, indent=2) + '\n')
result = {
    'status': 'passed', 'assertions': sum(groups.values()), 'groups': dict(groups),
    'elapsed_seconds': time.monotonic() - started, 'host': platform.platform(),
    'source_files': len(current), 'reference_inventory_is_verified_call_graph': False,
    'actual_populated_three_owner_transport_to_T': True,
    'full_parser_representation_closed': False, 'actual_builder_entry_attachment_closed': False,
    'configuration': CONFIGURATION, 'role_exports': list(exports),
    'native_capture_target_disassembler_compiler_prover_Lean_runs': 0,
    'predecessor_checker_replays': 0,
}
(HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
