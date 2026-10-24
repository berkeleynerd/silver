"""Independent offline identity, source-control and mathematical audit.

This does not execute author/predecessor checkers, extractors or native tools.
The new mathematical API is compared with an independently recursive fold.
Fixtures are fold controls, not producer captures or language admission tests.
"""
import hashlib
import importlib.util
import inspect
import json
import platform
import subprocess
import sys
import tarfile
import time
from collections import Counter
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = 'ae53fcef513b322bdc67f91aee998d1a8c356a22'
PACKET = ROOT / 'docs/evidence/retained-main-construction-demand-20261024/prefix-auxiliary'
START = time.monotonic()
counts = Counter()


def check(ok, group):
    if not ok:
        raise AssertionError(group)
    counts[group] += 1


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read_json(path):
    return json.loads(path.read_text())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


manifest = read_json(PACKET / 'inputs.json')
changed = git('diff', '--name-only', manifest['base_commit'], AUTHOR).decode().splitlines()
research_path = 'docs/research/retained-main-construction-demand.md'
check(all(p.startswith(str(PACKET.relative_to(ROOT)) + '/') or p == research_path for p in changed),
      'author changes confined to owned packet and research append')
review_inputs = []
for path in sorted(PACKET.iterdir()) + [ROOT / research_path]:
    if path.is_file():
        data = path.read_bytes()
        check(data == git('show', AUTHOR + ':' + str(path.relative_to(ROOT))), 'exact author input')
        review_inputs.append({'path': str(path.relative_to(ROOT)), **identity(data)})
for row in manifest['providers'] + manifest['immutable_earlier_packets']:
    check(identity((ROOT / row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')},
          'frozen provider or prior packet identity')
pin = manifest['research_prefix']
research = (ROOT / research_path).read_bytes()
old_research = git('show', manifest['base_commit'] + ':' + research_path)
check(old_research == research[:pin['bytes']] and identity(old_research) == {k: pin[k] for k in ('bytes', 'sha256')},
      'exact research prefix retained')

sources = {}
archives = {}
try:
    for row in read_json(PACKET / 'source-witnesses.json'):
        archive = archives.setdefault(row['archive'], None)
        if archive is None:
            archive = archives[row['archive']] = tarfile.open(ROOT / row['archive'])
        data = archive.extractfile(row['path']).read()
        sources[row['path']] = data.decode()
        check(identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, 'complete archived source identity')
        lines = data.splitlines(keepends=True)
        for span in row['spans']:
            chunk = b''.join(lines[span['first'] - 1:span['last']])
            check(chunk.decode() == span['text'] and identity(chunk)['sha256'] == span['sha256'],
                  'exact archived source excerpt')
finally:
    for archive in archives.values():
        archive.close()

converter = sources['plugins/gnat_json/gnat_ast_to_ptree.ml']
main = sources['src/gnat/gnat_main.ml']
loc = sources['src/util/loc.ml']
ht = next(v for k, v in sources.items() if k.endswith('/stdlib/hashtbl.ml'))
check(main.index('let c = Debug.Stats.record_timing "gnatwhy3.init" Gnat_checks.init_cont') <
      main.index('Sys.set_signal Sys.sigint (Sys.Signal_handle (save_session_and_exit c))'),
      'actual save handler installation follows initialization')
check(converter.count('mk_expr_of_term r.expr') == 2 and
      converter.count('List.map (mk_binder r.labels)') == 2 and
      'curr_attrs @ List.filter_map mk_label labels' in converter,
      'two variant conversions and per-binder label conversion')
check('Option.value ~default:(mk_ident [] "???") id' in converter and
      'ld_loc = get_pos (); ld_def = None' in converter and
      converter.count('let code_after = mk_expr_of_prog r.code_after') == 1 and
      converter.count('let code_before = mk_expr_of_prog r.code_before') == 1,
      'eager candidates and once-converted loop bodies retained')
check('let tag_counter = ref 0' in loc and 'let file_tags = Hstr.create 7' in loc and
      'let tag_to_file = Hint.create 7' in loc and
      loc.index('Hstr.add file_tags file n') < loc.index('Hint.add tag_to_file n file') < loc.index('incr tag_counter'),
      'private forward allocation precedes completed FileTags increment')
check('let nsize = osize * 2' in ht and 'h.size > Array.length h.data lsl 1' in ht,
      'strong table source doubles at strict twice-capacity threshold')

schema = read_json(ROOT / 'docs/evidence/retained-producer-storage-20261018/serialization.json')['schema']
caps = read_json(PACKET / 'source-caps.json')
kinds = [kind for family in caps['families'] for kind in family['kinds']]
check(len(kinds) == len(set(kinds)) == 63 and set(kinds) == set(schema), 'all serialized kinds assigned exactly once')
check(caps['local_ticket_allowance'] == 128 and all(
    0 <= value <= 64 for family in caps['families'] for key, value in family.items()
    if key.endswith('_cap') or key.endswith('_pair')), 'charge coefficients leave ticket slack')
fixed = read_json(ROOT / 'docs/evidence/retained-producer-composition-20261018/result.json')
check(all(fixed['fixed_kind_occurrences'].get(k, 0) == 0 for k in ('W_VARIANT', 'W_VARIANTS', 'W_LOOP')),
      'accepted complete fixed provider has zero variants and loops')
caller = (ROOT / 'docs/research/retained-main-callers-profile.md').read_text()
storage = (ROOT / 'docs/research/retained-producer-storage.md').read_text()
check('Empty user\ninvariant/variant lists stay empty' in caller,
      'ordinary Main variant-free attachment is source induction')
check("Close's terminating newline is outside T_file" in storage,
      'body byte convention inherited from producer')

spec = importlib.util.spec_from_file_location('reviewed_auxiliary_math', PACKET / 'auxiliary.py')
aux = importlib.util.module_from_spec(spec)
spec.loader.exec_module(aux)


class ObjectPairs:
    def __init__(self, pairs):
        self.pairs = pairs


def reference_fold(data):
    """Recursive algebra, independent of author's explicit work-stack walk."""
    value = json.loads(data, object_pairs_hook=ObjectPairs)

    def fold(x, replay=True):
        total = Counter(values=1, list_cells=0, string_bytes=0, binder_label_pairs=0)
        if isinstance(x, str):
            total['string_bytes'] = len(x.encode('utf-8', errors='surrogatepass'))
        elif isinstance(x, ObjectPairs):
            total['list_cells'] = len(x.pairs)
            for key, val in x.pairs:
                total.update(fold(key, replay))
                total.update(fold(val, replay))
        elif isinstance(x, list):
            total['list_cells'] = len(x)
            for child in x:
                total.update(fold(child, replay))
            if replay and x and isinstance(x[0], str) and x[0] in schema and len(x) == 3 + len(schema[x[0]]):
                fields = {f['name'].lower(): x[i + 3] for i, f in enumerate(schema[x[0]])}
                if x[0] == 'W_VARIANT':
                    total.update(fold(fields['expr'], replay))
                if x[0] in ('W_UNIVERSAL_QUANTIF', 'W_EXISTENTIAL_QUANTIF'):
                    if isinstance(fields['binders'], list) and isinstance(fields['labels'], list):
                        total['binder_label_pairs'] += len(fields['binders']) * len(fields['labels'])
        return total

    plain = dict(fold(value, False))
    del plain['binder_label_pairs']
    return plain, dict(fold(value))


def node(kind, **fields):
    return [kind, 7, 1] + [fields.get(f['name'].lower()) for f in schema[kind]]


def encoded(value):
    return json.dumps(value, ensure_ascii=True, separators=(',', ':')).encode()


leaf = node('W_LITERAL', value=0)
binder = node('W_BINDER')
quant = node('W_EXISTENTIAL_QUANTIF', binders=[binder] * 5, labels=['x', 'y', 'z'], pred=leaf)
variant = node('W_VARIANT', expr=quant, labels=[])
nested = node('W_VARIANT', expr=variant, labels=[])
cases = {
    'duplicate_objects': b'{"x":[1,2],"x":[3,4]}',
    'escaped_unicode': b'{"s":"\\ud83d\\ude00\\u0000\\u00e9\\\\\\\""}',
    'literal_utf8': '{"s":"é😀"}'.encode(),
    'space_split': encoded(node('W_NAME', symb=' f  g   h ', namespace='A', module=None)),
    'same_ids': encoded([leaf, leaf, leaf]),
    'binder_product': encoded(quant),
    'one_replay': encoded(variant),
    'nested_replay': encoded(nested),
    'large_labels': encoded(node('W_UNIVERSAL_QUANTIF', binders=[binder] * 7, labels=['x'] * 17, pred=leaf)),
    'all_kind_shapes': encoded([node(k) for k in sorted(schema)]),
    'unknown_shape': encoded(['W_NOT_A_KIND', 7, 1, quant]),
    'body_with_LF': encoded(variant) + b'\n',
    'two_LFs': encoded(variant) + b'\n\n',
}
fold_results = {}
for name, data in cases.items():
    expected_plain, expected_weighted = reference_fold(data)
    result = aux.serialized_fold(data)
    check(result['plain'] == expected_plain and result['weighted'] == expected_weighted,
          'independent recursive occurrence fold')
    check(result['potential'] == sum(expected_weighted.values()) and
          result['combined_auxiliary_event_upper'] == 128 * sum(expected_weighted.values()),
          'combined events use full weighted potential')
    check(all(v <= len(data) - int(data.endswith(b'\n')) for v in expected_plain.values()),
          'plain byte charging including Unicode and duplicate keys')
    if result['ordinary_linear_envelope_applies']:
        check(result['potential'] <= 12 * result['producer_json_body_bytes'], 'conditional linear fold control')
    fold_results[name] = result
check(fold_results['nested_replay']['weighted']['binder_label_pairs'] == 60 and
      fold_results['one_replay']['weighted']['binder_label_pairs'] == 30 and
      not fold_results['nested_replay']['ordinary_linear_envelope_applies'], 'cross-products replay multiplicatively')
check(fold_results['same_ids']['kind_occurrences']['W_LITERAL'] == 3 and
      not fold_results['large_labels']['ordinary_linear_envelope_applies'] and
      not fold_results['unknown_shape']['ordinary_linear_envelope_applies'], 'no deduplication or overbroad shortcut')
check(fold_results['body_with_LF']['potential'] == fold_results['one_replay']['potential'] and
      fold_results['body_with_LF']['producer_json_body_bytes'] == len(cases['one_replay']) and
      fold_results['two_LFs']['producer_json_body_bytes'] == len(cases['one_replay']) + 1,
      'only one final LF removed from body count')
check(list(inspect.signature(aux.from_serialized_json).parameters) == ['role', 'data', 'configuration'] and
      list(inspect.signature(aux.producer_envelope).parameters) == ['role', 'configuration'],
      'public demand interface has no numeric certificate parameter')

B = 2**31 - 2
Q = 128 * 12 * B
I, A, S, L = 2**62 - 1, 2**54 - 1, 2**57 - 9, 2**47 - 1
check(Q == 3298534880256, 'maximum conditional demand arithmetic')
provider = read_json(ROOT / 'docs/evidence/retained-main-entry-capacity-20261024/result.json')
exports = read_json(PACKET / 'exports.json')['producer_maximum']
for role, c in provider['entry_envelopes'].items():
    out = aux.producer_envelope(role)
    check(out == exports[role], 'frozen exports equal callable mathematics')
    h = c['owners']['Ident.Hsattr']
    b = h['backing']
    n = b['allocated_bucket_slots_upper'] + Q
    wa = max(b['outer_length_upper'], (3 * b['outer_length_upper']) // 2 + 3, 3 * n + 3)
    wb = max(b['bucket_length_upper'], (3 * n) // 2 + 3)
    nc = c['minor_history_words_upper'] // 4
    nf = nc + Q
    strong = max(16, nf)
    string = max(8 * c['managed_static_carrier_words_upper'], 64 * B + 128)
    check(out['Hsattr']['actual_populated_backing_at_C'] == b and
          out['Hsattr']['weak_transfer']['individual_outer_array_length_upper'] == wa and
          out['Hsattr']['weak_transfer']['individual_bucket_length_upper'] == wb and
          out['Hsattr']['counter_upper_at_T'] == h['counter_value_upper'] + Q,
          'Hsattr arithmetic retains all populated C geometry')
    check(out['FileTags']['counter_and_each_size_upper_at_C'] == nc and
          out['FileTags']['counter_and_each_size_upper_at_T'] == nf and
          out['FileTags']['each_backing_or_tail_extent_upper'] == strong and
          out['FileTags']['each_backing_or_tail_bytes_upper'] == 8 * (strong + 1),
          'FileTags native injection and strong geometry arithmetic')
    independent_guards = [h['counter_value_upper'] + Q <= I, 3 * max(wa, wb) + 6 <= I,
        wa <= A, wb + 2 <= A - 2, nf <= I, 2 * strong <= I, strong <= A,
        1 + Q <= L, Q <= I, string <= S, 2 * string + 16 <= I,
        8 * (max(wa, wb + 2, strong) + 1) <= 2**64 - 1,
        B <= A, 2 * B + 1 <= I, 8 * (B + 1) <= 2**64 - 1]
    check(all(independent_guards) and all(out['guards'].values()) and
          len(out['guards']) == len(independent_guards), 'independently recomputed representation guards')
    check(out['producer_json_body_bytes_upper'] == B and
          out['native_input_file_bytes_upper_including_Close_LF'] == B + 1 and
          out['synthetic_location_counter_upper_at_T'] == Q + 1 and
          out['call_id_counter_upper_at_T'] == Q and out['old_or_new_string_length_upper'] == string,
          'body file location call-ID and individual-string operands')
    check(out['process_budget'] == {'escaping_save_exceptions': 2, 'save_entering_callbacks': 2, 'saves': 3} and
          out['new_callback_or_save_allowance'] == out['save_origin_callbacks_before_T'] == 0 and
          not out['full_parser_converter_representation_closed'] and not out['T_to_builder_transport_closed'] and
          not out['aggregate_RAM_stack_or_cumulative_local_bytes'] and len(out['genuine_remaining_operands']) == 3,
          'unchanged control budget and residual consumer boundaries')

# Threshold controls support the induction: unchanged b remains bounded;
# when n=2b+1 causes growth, new b=2b<n. They are not a universal proof alone.
for power in range(4, 44):
    old = 2**power
    insertion_size = 2 * old + 1
    check(2 * old <= max(16, insertion_size) and old <= max(16, insertion_size - 1),
          'strong growth threshold arithmetic controls')

result = {
    'status': 'passed', 'author_commit': AUTHOR, 'assertions': sum(counts.values()),
    'groups': dict(counts), 'elapsed_seconds': time.monotonic() - START,
    'host': platform.platform(), 'source_files': len(sources), 'schema_kinds': len(schema),
    'fold_controls': fold_results, 'review_inputs': review_inputs,
    'author_changed_files': changed, 'audit_identity': identity(Path(__file__).read_bytes()),
    'source_amortization_machine_proved': False,
    'native_target_capture_compiler_prover_Lean_disassembler_service_runs': 0,
    'author_or_predecessor_checker_extractor_runs': 0,
    'full_parser_converter_representation_closed': False, 'T_to_builder_transport_closed': False,
}
(HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k: v for k, v in result.items() if k not in ('fold_controls', 'review_inputs', 'author_changed_files')}, indent=2))
