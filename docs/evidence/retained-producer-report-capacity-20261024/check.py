#!/usr/bin/env python3
"""Offline source/algebra checks for the producer report research packet.

This does not run a native producer or any predecessor checker. It verifies
retained source bytes and bounded mathematical witnesses, not source soundness
by testing. The open attachments remain explicit in the generated result.
"""
import ast
import hashlib
import json
from pathlib import Path
import re
import sys
import tarfile
import time

sys.dont_write_bytecode = True
import capacity as c

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
START = time.monotonic()


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_text())


def ada_code(source):
    # Keep string tokens; remove comments without consuming '--' in strings.
    return re.sub(r'"(?:""|[^"\n])*"|--[^\n]*',
                  lambda m: '' if m[0].startswith('--') else m[0], source)


sources = {}
providers = read_json(HERE/'source-manifest.json')
for provider in providers:
    data = (ROOT/provider['path']).read_bytes()
    assert sha(data) == provider['sha256'], provider['path']
    with tarfile.open(ROOT/provider['path']) as archive:
        for item in provider['files']:
            content = archive.extractfile(item['member']).read()
            assert len(content) == item['bytes']
            assert sha(content) == item['sha256'], item['member']
            sources[item['member']] = content.decode()

additional = read_json(HERE/'additional-source-manifest.json')
assert sha((HERE/'additional-sources.tar.gz').read_bytes()) == additional['archive_sha256']
with tarfile.open(HERE/'additional-sources.tar.gz') as archive:
    for item in additional['files']:
        content = archive.extractfile(item['member']).read()
        assert len(content) == item['bytes']
        assert sha(content) == item['sha256'], item['member']
        sources[item['member']] = content.decode()

for item in read_json(HERE/'inputs.json'):
    assert sha((ROOT/item['path']).read_bytes()) == item['sha256'], item['path']
incoming_sources = read_json(ROOT/'docs/evidence/retained-producer-report-incoming-20261024/identity.json')['local_sources']
assert len(incoming_sources) == 6
for path, digest in incoming_sources.items():
    assert sha((ROOT/path).read_bytes()) == digest, path


def src(suffix):
    matches = [v for k, v in sources.items() if k.endswith(suffix)]
    assert len(matches) == 1, suffix
    return matches[0]


def ordered(text, needles):
    cursor = 0
    for needle in needles:
        cursor = text.index(needle, cursor) + len(needle)


driver = src('gnat2why-driver.adb')
conversion = src('gnat2why-error_messages.adb')
start = conversion.index('File    : constant JSON_Value := Read_File_Into_JSON')
ordered(conversion[start:], ['Results : constant JSON_Array',
        'if Has_Field (File, "error")', 'Handle_Error (Msg, Internal)',
        'Subp := Entity_Id', 'Handle_Timings', 'Parse_Gnattest_Values (Subp)',
        'Handle_Result (Get (Results, Index))', 'Ada.Text_IO.Put_Line'])
ordered(conversion[conversion.index('procedure Handle_Result (V : JSON_Value) is'):],
        ['Parse_Why3_Prove_Result (V)', 'VC_Info renames VC_Table',
         'Parse_Cntexamples_List (Rec.Cntexmps)', 'new Fuel_Type',
         'if Gnat2Why_Args.Check_Counterexamples'])
ordered(driver[driver.index('procedure Collect_One_Result is'):],
        ['Wait_Process', 'Parse_Why3_Results', 'Delete_File'])
ordered(driver[driver.index('procedure Create_JSON_File\n'):],
        ['"spark"', '"skip_flow_proof"', '"skip_proof"', '"progress"',
         '"stop_reason"', '"warn_error"', '"flow"', '"pragma_assume"',
         '"proof"', '"assumptions"', '"timings"', '"entities"',
         'Compact => False', 'Ada.Text_IO.Close'])

# Inspect the complete existing SPARK source frontier, not only selected files.
caller_rows = []
option_rows = []
continuation_rows = []
text_io_rows = []
ada_integer_setters = []
frontier = 0
with tarfile.open(ROOT/providers[0]['path']) as archive:
    for member in archive.getmembers():
        if not (member.isfile() and member.name.startswith('spark-source/src/')
                and member.name.endswith(('.adb', '.ads'))):
            continue
        frontier += 1
        text = archive.extractfile(member).read().decode()
        code = ada_code(text)
        for match in re.finditer(r'\bEntity_To_Subp_Assumption\s*\(', code):
            line = code.count('\n', 0, match.start()) + 1
            before = code[max(0, match.start()-30):match.start()]
            if re.search(r'function\s*$', before):
                continue
            caller_rows.append({'member': member.name, 'line': line})
        for match in re.finditer(r'\b(?:Output_Mode|Report_Mode)\b', code):
            option_rows.append({'member': member.name,
                                'line': code.count('\n', 0, match.start())+1,
                                'name': match[0]})
        for match in re.finditer(r'\b(?:Continuation_Stack|\w*Check_Info\.Continuation)\.Append\b', code):
            continuation_rows.append({'member': member.name,
                                      'line': code.count('\n', 0, match.start())+1,
                                      'spelling': match[0]})
        if '/gnatprove/' not in member.name and '/xgen/' not in member.name:
            qualified = re.finditer(r'\bAda\.Text_IO\.(?:Put_Line|Put|New_Line|Set_Output|Set_Line_Length|Set_Page_Length)\b', code)
            for match in qualified:
                text_io_rows.append({'member': member.name,
                                     'line': code.count('\n', 0, match.start())+1,
                                     'spelling': match[0]})
            if re.search(r'\buse\s+Ada\.Text_IO\s*;', code) or member.name.endswith('/outputs.adb'):
                for match in re.finditer(r'(?<![\w.])(?:Put_Line|Put|New_Line|Set_Output|Set_Line_Length|Set_Page_Length)\b', code):
                    text_io_rows.append({'member': member.name,
                                         'line': code.count('\n', 0, match.start())+1,
                                         'spelling': match[0]})
        for match in re.finditer(r'\b(?:Set_Intval|Make_Integer_Literal)\s*\(', code):
            ada_integer_setters.append({'member': member.name,
                                       'line': code.count('\n', 0, match.start())+1})
assert len(caller_rows) == 9, caller_rows
assert not ada_integer_setters, ada_integer_setters
assert sum(x['spelling'] == 'Continuation_Stack.Append' for x in continuation_rows) == 18
assert sum(x['spelling'] != 'Continuation_Stack.Append' and not x['member'].endswith('gnat2why-error_messages.adb') for x in continuation_rows) == 16
assert not [x for x in text_io_rows if re.search(r'Set_(?:Output|Line_Length|Page_Length)$', x['spelling'])]

assert frontier == 279, frontier

flow = src('flow_error_messages.adb')
assert flow.count('Add_Json_Msg (Proof_Msgs, Result, Msg_Id)') == 1
ordered(src('spark_util.adb')[src('spark_util.adb').index('function Entity_To_Subp_Assumption ('):],
        ['Mk_Subp', 'end Entity_To_Subp_Assumption'])
assert 'elsif CL_Switches.Output.all = "brief" then\n            Output := GPO_Brief;' in src('configuration.adb')
assert 'Report := GPR_All;' in src('configuration.adb')
assert 'if Gnat2Why_Args.Output_Mode in Gnat2Why_Opts.GPO_Pretty then' in src('back_end.adb')
assert 'if Error_Msg_Line_Length /= 0 and then Continuation then' in src('errout.adb')
assert 'Buffer (Next_Col) := ASCII.LF;' in src('output.adb')
ordered(src('output.adb')[src('output.adb').index('procedure Write_Char ('):], ["if Next_Col > Buffer'Length then", 'Flush_Buffer;', 'if C = ASCII.LF then', 'Write_Eol;'])

recipe = (ROOT/'docs/evidence/retained-tool-source-identity-20261018/spark2014.anod').read_text()
pairs = []
for node in ast.walk(ast.parse(recipe)):
    if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id == 'text_replace':
        try:
            value = ast.literal_eval(node.args[1])
        except (ValueError, TypeError, IndexError):
            continue
        if value and value[0][0] == 'if Is_FSF_Version then':
            pairs = value
assert len(pairs) == 1
old, new = pairs[0]
assert src('comperr.adb').count(old) == 1
patched = src('comperr.adb').replace(old, new)
assert patched == (HERE/'comperr-recipe-applied.adb').read_text()
assert sha(patched.encode()) == '9e91665d1cdf08e6d60e46ec55804ab07c00c7e9761ff0e72aa602ed4a584a4b'

literal_budgets = {}
for name, lo, hi in [('fix', 1620, 3816), ('details', 1025, 1462),
                     ('explanation', 1466, 1598), ('not_proved', 4122, 4430),
                     ('vc_message', 4717, 5007), ('regular', 3960, 4116)]:
    text = ada_code('\n'.join(flow.splitlines()[lo-1:hi]))
    literals = [x[1:-1].replace('""', '"') for x in
                re.findall(r'"(?:""|[^"\n])*"', text)]
    literal_budgets[name] = {'lines': [lo, hi], 'count': len(literals),
                             'decoded_sum': sum(map(len, literals)),
                             'maximum': max(map(len, literals), default=0)}
    if name in ('not_proved', 'vc_message'):
        def literal_sum(fragment):
            return sum(len(x[1:-1].replace('""', '"')) for x in
                       re.findall(r'"(?:""|[^"\n])*"', fragment))
        returns = [literal_sum(m[1]) for m in re.finditer(r'\breturn\b([\s\S]*?);', text)]
        locals_ = [literal_sum(m[1]) for m in re.finditer(r':\s*constant\s+String\s*:=([\s\S]*?);', text)]
        literal_budgets[name]['max_return_literal_sum'] = max(returns)
        literal_budgets[name]['all_local_string_literal_sum'] = sum(locals_)
assert literal_budgets['fix']['decoded_sum'] == 1326
assert literal_budgets['explanation']['decoded_sum'] == 705
assert literal_budgets['not_proved']['decoded_sum'] == 2847
assert literal_budgets['vc_message']['decoded_sum'] == 2194
assert literal_budgets['not_proved']['max_return_literal_sum'] == 110
assert literal_budgets['not_proved']['all_local_string_literal_sum'] == 109
assert literal_budgets['vc_message']['max_return_literal_sum'] == 101
assert literal_budgets['vc_message']['all_local_string_literal_sum'] == 25


def write(value, indent=0):
    # Direct layout witness for the checked GNATCOLL Write recurrence.
    if isinstance(value, (list, dict)):
        object_kind = isinstance(value, dict)
        items = list(value.items()) if object_kind else list(enumerate(value))
        body = []
        for key, child in items:
            prefix = json.dumps(key, ensure_ascii=True)+': ' if object_kind else ''
            body.append('  '*(indent+1)+prefix+write(child, indent+1))
        return ('{' if object_kind else '[')+'\n'+',\n'.join(body)+('\n' if items else '')+'  '*indent+('}' if object_kind else ']')
    return json.dumps(value, ensure_ascii=True, separators=(',', ':'))


def shape(value):
    if isinstance(value, dict):
        return c.object_fields([(k, shape(v)) for k, v in value.items()])
    if isinstance(value, list):
        return c.container([(1, 0, 0, shape(v)) for v in value], object_kind=False)
    if isinstance(value, str):
        return c.literal(value)
    return c.atom(len(json.dumps(value)))


examples = [[], {}, [0], {'a': []}, [[], {'a': 'x', 'b': [1, 2]}]]
for value in examples:
    bound = shape(value)
    for indent in (0, 1, 7):
        assert len(write(value, indent)) == bound.pretty+indent*bound.slope
    assert len(json.dumps(value, separators=(',', ':'))) == bound.compact
assert c.array(0, c.string(999)).pretty == 3
assert c.array(0, c.string(999)).string_max == 0

row_parameters = dict(path_bytes=128, text_bytes=2048, rule_bytes=64,
                      stats_count=3, stats_key_bytes=7)
p1 = c.canonical_proof(records=1, goals=3, attempts=5, answer_bytes=736,
                       row_parameters=row_parameters)
p2 = c.canonical_proof(records=100, goals=3, attempts=5, answer_bytes=736,
                       row_parameters=row_parameters)
p0 = c.canonical_proof(records=1, goals=0, attempts=0, answer_bytes=736,
                       row_parameters=row_parameters)
p00 = c.canonical_proof(records=100, goals=0, attempts=0, answer_bytes=736,
                        row_parameters=row_parameters)
assert p2['full'].pretty-p00['full'].pretty == p1['full'].pretty-p0['full'].pretty
assert p1['projected'] == p0['projected']
assert p1['full'].depth >= 6
assert c.unknown_tree(100).pretty > 3*c.unknown_tree(50).pretty

meta = c.metadata(entities=8, location_depth=2, name_bytes=32, path_bytes=128,
                  spark_entities=8, skip_flow=0, skip_proof=0, pragma_assume=0,
                  claims=40, edges_per_claim=40, claim_edges=20,
                  timing_entities=9, timing_names=30, timing_fields=30,
                  timing_key_bytes=32, progress_bytes=14, stop_bytes=20)
empty = c.array(0, c.atom(0))
full = c.report(meta, warnings=empty, flow=empty, proof=p1['full'])
projected = c.report(meta, warnings=empty, flow=empty, proof=p1['projected'])
assert full.pretty > projected.compact
assert c.representation(full, filename_bytes=128)['sufficient']
assert not c.representation(c.atom(c.I), filename_bytes=128)['sufficient']
assert not c.representation(c.atom(c.I*2//3), filename_bytes=128)['guards']['unbounded_alignment_intermediates']
assert c.failed_fix_calls(2, 3) == 51
assert c.claim_domain(3, 2)['edges'] == 14
assert c.producer_source_open_bound() == 1584
assert c.frontend_diagnostics(process='Silver_IO', fixed_name_bytes=64, path_bytes=128)['entries'] == 12
assert c.frontend_diagnostics(process='Main', main_loops=2, main_withs=3, fixed_name_bytes=64, path_bytes=128)['entries'] == 7
assert c.diagnostic_name_suffix(string_descriptors=3, maximum_string_length=5) == dict(names=4, characters=31)
assert c.terminal_warnings(count=2, decoded_sum=4, decoded_max=2, initial_line=1, initial_column=1)['offered_text_bytes'] == 10
assert c.report_phase_aliases(100)['unbounded_references'] == 117
assert not c.terminal_warnings(count=1, decoded_sum=2, decoded_max=2,
                               initial_line=c.I, initial_column=1)['guards']['line']
assert not c.compiler_abort(error_bytes=32767, path_bytes=20,
                             version_bytes=20, target_bytes=20)['guards']['output_explicit_eol']
assert c.compiler_abort(error_bytes=33227168, error_tail_bytes=0, path_bytes=128, version_bytes=40, target_bytes=40)['guards']['output_explicit_eol']
assert not c.brief_output(message_bytes=32767, path_bytes=1,
                           output_calls=1)['guards']['explicit_eol']
assert c.uint_image_storage(radix_digits=2, prefix_entries=0, prefix_digits=0, table_index_room=c.I)['local_vector_digits'] == 4
assert c.uint_image_storage(radix_digits=33, prefix_entries=0, prefix_digits=0,
                            table_index_room=c.I)['guards']['no_abbreviation']
assert not c.uint_image_storage(radix_digits=34, prefix_entries=0, prefix_digits=0,
                                table_index_room=c.I)['guards']['no_abbreviation']
expr = c.expression_image(decoded_name=32, string_characters=100,
                          attribute_name=9, source_span=1000, uint_image_bytes=550)
assert expr['bytes'] > 32766  # private Get_Fix bound is not a printed CP bound
assert expr['printed_cp_bytes'] == 15581
small = c.selected_report(frontend_nodes=1, entities=1, list_headers=1,
                          why_allocations=1, name_bytes=16, full_name_bytes=32,
                          magic_bytes=32, path_bytes=128, instantiation_edges=0,
                          records=1, goals=1, attempts=1, launches=1,
                          expression_bytes=expr['printed_cp_bytes'])
assert small['proof_message_bytes'] == 31439
assert c.brief_output(message_bytes=small['proof_message_bytes'], path_bytes=128, output_calls=5)['maximum_line'] == 31655
assert c.brief_output(message_bytes=small['proof_message_bytes'], path_bytes=128, output_calls=5)['guards']['explicit_eol']
assert c.uint_image_storage(radix_digits=18, prefix_entries=0, prefix_digits=0, table_index_room=c.I)['image_bytes'] == 550
assert small['incoming']['proof_records'] == 0
assert small['third_pool']['entity_requests'] == (9+7+26+small['incoming']['flow_records']+1)
assert small['third_pool']['find_calls'] == 2*small['third_pool']['entity_requests']
assert small['full'].pretty > small['projected'].compact

result = {
    'status': 'focused checks passed; source attachments remain open',
    'native_execution': False, 'predecessor_checker_replay': False,
    'provider_archives': len(providers)+1, 'complete_selected_files': len(sources),
    'spark_ada_frontier': frontier, 'assumption_callers': caller_rows,
    'option_uses': option_rows, 'continuation_append_sites': continuation_rows,
    'producer_text_io_sites': text_io_rows,
    'ada_integer_field_setters': ada_integer_setters,
    'incoming_local_sources_checked': incoming_sources,
    'literal_budgets': literal_budgets,
    'recipe_applied_comperr_sha256': sha(patched.encode()),
    'checks': ['provider and input identity', 'result declaration/side-effect order',
               'complete third-pool call frontier', 'prospective brief/all option path',
               'literal budget derivation', 'exact pretty/compact recurrence witnesses',
               'empty groups do not affect maxima', 'additive global R/G/A occurrences',
               'check-tree projection preserves other schema', 'arbitrary-depth quadratic envelope',
               'writer growth, terminal column and cumulative-line failures',
               'exact bugbox recipe application', 'Uint abbreviation guard boundary',
               'Uint carry plus Algorithm_D local normalization digit',
               'incoming source equations and whole-lifetime third-pool composition',
               'six local incoming source identities', 'full continuation append inventory',
               'printed CP and private Get_Fix bounds remain separate',
               'fixed GCC prefix transfer and native name suffix',
               'producer Text_IO caller inventory and no standard-state setters'],
    'illustration_not_program_bound': {
        'full_pretty': full.pretty, 'projected_compact': projected.compact,
        'full_shape': c.asdict(full), 'writer': c.representation(full, filename_bytes=128)},
    'open_attachments': ['full terminal failure-payload to native Output join',
                         'concrete path and clock/duration configuration joins',
                         'independent integrated freeze review'],
    'elapsed_seconds': round(time.monotonic()-START, 6),
}
(HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({k: result[k] for k in ['status', 'complete_selected_files',
                                        'spark_ada_frontier', 'elapsed_seconds']}))
