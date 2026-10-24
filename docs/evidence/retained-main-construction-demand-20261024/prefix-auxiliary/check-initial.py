"""One focused changed-source/derived-demand/representation audit."""
import inspect
import json
import platform
import sys
import tarfile
import time
from collections import Counter

sys.dont_write_bytecode = True
import auxiliary as a
from prepare import HERE, ROOT, digest

start = time.monotonic()
groups = Counter()


def check(ok, label):
    if not ok:
        raise AssertionError(label)
    groups[label] += 1


inputs = json.loads((HERE / 'inputs.json').read_text())
for pin in inputs['providers'] + inputs['immutable_earlier_packets']:
    data = (ROOT / pin['path']).read_bytes()
    check(len(data) == pin['bytes'] and digest(data) == pin['sha256'], 'immutable provider/earlier packet')
pin = inputs['research_prefix']
research = (ROOT / pin['path']).read_bytes()
check(digest(research[:pin['bytes']]) == pin['sha256'], 'research prefix preserved')
check(b'## Source-derived prefix auxiliary owners' in research[pin['bytes']:], 'new argument appended')

source = {}
archives = {}
try:
    for row in json.loads((HERE / 'source-witnesses.json').read_text()):
        if row['archive'] not in archives:
            archives[row['archive']] = tarfile.open(ROOT / row['archive'])
        data = archives[row['archive']].extractfile(row['path']).read()
        check(len(data) == row['bytes'] and digest(data) == row['sha256'], 'full source identity')
        source[row['path']] = data.decode()
        lines = data.splitlines(True)
        for span in row['spans']:
            chunk = b''.join(lines[span['first']-1:span['last']])
            check(digest(chunk) == span['sha256'] and chunk.decode() == span['text'], 'exact source excerpt')
finally:
    for archive in archives.values():
        archive.close()
caps = json.loads((HERE / 'source-caps.json').read_text())
all_kinds = [k for f in caps['families'] for k in f['kinds']]
check(len(all_kinds) == len(set(all_kinds)) == 63 and set(all_kinds) == set(a.SCHEMA), 'all 63 serialized kinds have one source charge family')
check(caps['local_ticket_allowance'] == a.LOCAL_TICKETS == 128, 'callable uses audited local ticket allowance')
for row in caps['families']:
    for key, value in row.items():
        if key.endswith('_cap') or key.endswith('_pair'):
            check(type(value) is int and 0 <= value <= 64 <= a.LOCAL_TICKETS, 'family caps within allowance')

main = source['src/gnat/gnat_main.ml']
check(main.index('Gnat_checks.init_cont') < main.index('Sys.set_signal Sys.sigint'), 'save handler installed only after prefix')
converter = source['plugins/gnat_json/gnat_ast_to_ptree.ml']
check(converter.count('mk_expr_of_term r.expr') == 2, 'both variant expression conversions retained')
check('List.map (mk_binder r.labels)' in converter and
      'curr_attrs @ List.filter_map mk_label labels' in converter, 'quantifier cross-product source attachment')
check('Option.value ~default:(mk_ident [] "???") id' in converter and
      'ld_loc = get_pos (); ld_def = None' in converter, 'eager and discarded declaration work retained')
check('let code_after = mk_expr_of_prog r.code_after' in converter and
      'let code_before = mk_expr_of_prog r.code_before' in converter, 'loop body conversion sites bound')
check('Loc.user_position r.filename r.line 0 r.line 0' in converter and
      'Loc.user_position "<dummy>" line 0 line 0' in source['plugins/gnat_json/ptree_constructors.ml'], 'location columns stay zero')
loc = source['src/util/loc.ml']
check(loc.index('Hstr.add file_tags file n') < loc.index('Hint.add tag_to_file n file') < loc.index('incr tag_counter'), 'forward cell precedes FileTags increment')
check('let tag_counter = ref 0' in loc and 'let file_tags = Hstr.create 7' in loc, 'FileTags private source initialization')
check('let get_file_tag file' in loc and 'FileTags.get_file_tag f' in loc, 'single filename lookup service')
set_source = source['ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/set.ml']
check('type t = Empty | Node of {l:t; v:elt; r:t; h:int}' in set_source and
      'if hl > hr + 2 then' in set_source and 'let rec mem x = function' in set_source,
      'include set fixed node and height arithmetic bound')

def node(kind, **fields):
    # Pure source-shape diagrams, not native observations or producer captures.
    return [kind, 1, 1] + [fields.get(f['name'].lower(), None) for f in a.SCHEMA[kind]]


def raw(value):
    return json.dumps(value, ensure_ascii=True, separators=(',', ':')).encode()


name = node('W_NAME', symb='f', namespace='', module=None, infix=False)
ident = node('W_IDENTIFIER', name=name, typ=None, labels=[])
literal = node('W_LITERAL', value=0)
binder = node('W_BINDER', name=ident, arg_type=node('W_TYPE', type_kind=0, name=name, is_mutable=False, relaxed_init=False))
quant = node('W_UNIVERSAL_QUANTIF', binders=[binder, binder], labels=['a', 'b', 'c'], triggers=None, pred=literal)
variant = node('W_VARIANT', cmp_op=ident, labels=[], expr=quant)
nested_variant = node('W_VARIANT', cmp_op=ident, labels=[], expr=variant)
diagrams = {
    'empty_root': {'theory_declarations': []},
    'repeated_serialized_children': {'theory_declarations': [literal, literal]},
    'binder_label_product': {'theory_declarations': [quant]},
    'variant_replay': {'theory_declarations': [variant]},
    'nested_replay_outside_linear_shortcut': {'theory_declarations': [nested_variant]},
    'beyond_three_labels_actual_fold': {'theory_declarations': [node('W_EXISTENTIAL_QUANTIF', binders=[binder] * 4, labels=['x'] * 7, pred=literal)]},
    'split_identifier_and_escaped_bytes': {'theory_declarations': [node('W_IDENTIFIER', name=node('W_NAME', symb='f a b c\\"', namespace='', module=None, infix=False), typ=None, labels=[])]},
}
folds = {name: a.serialized_fold(raw(v)) for name, v in diagrams.items()}
for name, fold in folds.items():
    check(all(fold['plain_component_byte_guards'].values()), 'three plain metrics bounded by serialized bytes')
    check(fold['combined_auxiliary_event_upper'] == 128 * fold['potential'], 'source-derived combined event envelope')
    if fold['ordinary_linear_envelope_applies']:
        check(fold['potential'] <= fold['linear_potential_upper'], 'linear inequality for eligible actual fold')
check(folds['repeated_serialized_children']['kind_occurrences']['W_LITERAL'] == 2, 'equal children/IDs not memoized')
check(folds['binder_label_product']['weighted']['binder_label_pairs'] == 6, 'all binder-label pairs counted')
check(folds['variant_replay']['weighted']['binder_label_pairs'] == 12, 'replayed subtree includes its cross-product')
check(folds['variant_replay']['maximum_variant_expr_replay_depth'] == 1, 'single full-subtree replay')
check(folds['nested_replay_outside_linear_shortcut']['maximum_variant_expr_replay_depth'] == 2 and
      folds['nested_replay_outside_linear_shortcut']['weighted']['binder_label_pairs'] == 24 and
      not folds['nested_replay_outside_linear_shortcut']['ordinary_linear_envelope_applies'], 'nested replay charged without claiming linear shortcut')
check(folds['beyond_three_labels_actual_fold']['weighted']['binder_label_pairs'] == 28 and
      not folds['beyond_three_labels_actual_fold']['ordinary_linear_envelope_applies'], 'large label product charged from data')
duplicate_keys = a.serialized_fold(b'{"x":[1,2],"x":[3,4]}')
check(duplicate_keys['plain']['values'] == 9 and duplicate_keys['plain']['list_cells'] == 6, 'object pairs are not overwritten by host JSON decoder')

c_packet = json.loads(a.prefix.PROVIDER.read_text())
exports = {role: a.producer_envelope(role) for role in c_packet['entry_envelopes']}
for role, out in exports.items():
    c = c_packet['entry_envelopes'][role]
    check(out['combined_auxiliary_event_upper'] == 128 * 12 * ((1 << 31) - 2), 'largest existing producer byte envelope')
    check(out['auxiliary_owner_representation_guards_hold'] and all(out['guards'].values()), 'all owner/table/string guards pass')
    check(out['FileTags']['counter_and_each_size_upper_at_C'] == c['minor_history_words_upper'] // 4, 'actual populated C FileTags minor injection')
    check(out['Hsattr']['actual_populated_backing_at_C'] == c['owners']['Ident.Hsattr']['backing'], 'actual populated Hsattr backing retained')
    check(out['FileTags']['fresh_filenames_allowed'] and not out['FileTags']['old_R71_D0_membership_used'], 'fresh Main filename domain allowed')
    check(out['FileTags']['each_backing_or_tail_extent_upper'] <= out['FileTags']['counter_and_each_size_upper_at_T'], 'strong backing bounded by total completed insertions')
    check(out['save_origin_callbacks_before_T'] == out['new_callback_or_save_allowance'] == 0 and
          out['process_budget'] == {'escaping_save_exceptions': 2, 'save_entering_callbacks': 2, 'saves': 3}, 'one unchanged global process budget')
    check(not out['full_parser_converter_representation_closed'] and not out['T_to_builder_transport_closed'] and
          not out['aggregate_RAM_stack_or_cumulative_local_bytes'] and len(out['genuine_remaining_operands']) == 3, 'remaining consumer operands and scope explicit')
    fixed = out['fixed_Gnat_Ptree_requests_and_Connection']
    check(fixed['closed_under_inherited_fixed_constructor_correspondence'] and
          fixed['Connection_midpoint_numerator_upper'] == 2 * a.JSON_BYTE_LIMIT + 1 and
          fixed['Connection_array_bytes_upper'] == 8 * (a.JSON_BYTE_LIMIT + 1), 'fixed syntax requests and Connection operands attached')
    check(all(row['new_constructor_requests'] == 0 for row in out['inherited_three_owner_projection'].values()), 'accepted three-owner transport unchanged')
actual = a.from_serialized_json('put_line', raw(diagrams['variant_replay']))
check(actual['combined_auxiliary_event_upper'] == folds['variant_replay']['combined_auxiliary_event_upper'] and
      actual['auxiliary_owner_representation_guards_hold'], 'actual bytes directly feed owner guards')
check(list(inspect.signature(a.from_serialized_json).parameters) == ['role', 'data', 'configuration'] and
      list(inspect.signature(a.producer_envelope).parameters) == ['role', 'configuration'], 'public API accepts no arbitrary counter/demand vector')
for thunk in [lambda: a.from_serialized_json('put_line', 100),
              lambda: a.from_serialized_json('put_line', b''),
              lambda: a.producer_envelope('not-a-role'),
              lambda: a.producer_envelope('put_line', 'R90'),
              lambda: a.from_serialized_json('put_line', b'{}', requests=0)]:
    try:
        thunk()
    except (ValueError, TypeError):
        check(True, 'unsupported API inputs rejected')
    else:
        raise AssertionError('unsupported input accepted')
limits = json.loads((ROOT / 'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json').read_text())
check(limits['max_string_length'] == a.STRING_MAX and limits['max_wosize'] == a.ARRAY_MAX, 'accepted native string/array limits reused')

(HERE / 'exports.json').write_text(json.dumps({'producer_maximum': exports, 'source_diagrams': folds, 'actual_bytes_diagram': actual}, indent=2) + '\n')
result = {
    'status': 'passed', 'assertions': sum(groups.values()), 'groups': dict(groups),
    'elapsed_seconds': time.monotonic() - start, 'host': platform.platform(),
    'source_files': len(source), 'source_kinds': 63, 'source_case_argument_machine_proved': False,
    'largest_combined_auxiliary_request_upper': exports['put_line']['combined_auxiliary_event_upper'],
    'largest_Hsattr_counter_upper': exports['put_line']['Hsattr']['counter_upper_at_T'],
    'largest_FileTags_counter_upper': exports['put_line']['FileTags']['counter_and_each_size_upper_at_T'],
    'largest_synthetic_location_counter_upper': exports['put_line']['synthetic_location_counter_upper_at_T'],
    'auxiliary_owner_guards_under_attached_source_fold': True,
    'full_parser_converter_representation_closed': False, 'T_to_builder_transport_closed': False,
    'native_capture_target_disassembler_compiler_prover_Lean_service_runs': 0,
    'predecessor_checker_replays': 0,
}
(HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
