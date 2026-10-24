#!/usr/bin/env python3
"""New four-table source obligation and explicit Names boundary; no baseline replay."""
import hashlib
import inspect
import json
from pathlib import Path
import re
import tarfile
import time
import capacity

start = time.monotonic()
here = Path(__file__).resolve().parent
repo = here.parents[3]
sha = lambda data: hashlib.sha256(data).hexdigest()
manifest = json.loads((here / 'source-manifest.json').read_text())
archive = 'docs/evidence/retained-producer-gpr-descriptor-20261018/gprbuild-v26.0.0.tar.gz'
assert sha((repo / archive).read_bytes()) == manifest['providers'][archive]
with tarfile.open(repo / archive) as source_archive:
    sources = {}
    for name, pin in manifest['source_members'].items():
        if name.rsplit('/', 1)[-1] in ('gpr-part.adb', 'gpr-dect.adb', 'gpr-tree.adb'):
            data = source_archive.extractfile(name).read()
            assert len(data) == pin['bytes'] and sha(data) == pin['sha256']
            sources[name.rsplit('/', 1)[-1]] = data.decode()
assert len(sources) == 3
part, dect, tree = (sources[n] for n in ('gpr-part.adb', 'gpr-dect.adb', 'gpr-tree.adb'))
for name, source in [('Withs', part), ('Project_Stack', part),
                     ('Extended_Projects', part), ('Next_End_Nodes', tree)]:
    instance = re.search(r'package ' + name + r' is new GNAT.Table\s*\((.*?)\);', source, re.S).group(1)
    for field, value in [('Table_Low_Bound', 1), ('Table_Initial', 10), ('Table_Increment', 100)]:
        assert re.search(field + r'\s*=>\s*' + str(value) + r'\b', instance)
assert len(re.findall(r'Withs.Increment_Last;', part)) == 1
assert len(re.findall(r'Project_Stack.Append\s*\(', part)) == 1
assert len(re.findall(r'Extended_Projects.Append\s*\(', part)) == 1
assert len(re.findall(r'Set_Next_End_Node\s*\(', part)) == 1
assert len(re.findall(r'Set_Next_End_Node\s*\(', dect)) == 2
assert 'Project_Stack.Init;' in part
assert 'Next_End_Nodes.Increment_Last;' in tree
baseline = json.loads((here / 'result.json').read_text())
auxiliary = {}
for phase, row in baseline['phases'].items():
    extra = capacity.auxiliary_parser_tables(row['project'], row['configuration'])
    assert extra['all_four_backings_closed'] and extra['Next_End_Nodes_gross_pushes'] == 10
    assert not extra['complete_parser_or_process_allocation_closed']
    assert {name: table['bytes'] for name, table in extra['tables'].items()} == {
        'Withs': 1680, 'Project_Stack': 1344, 'Extended_Projects': 672, 'Next_End_Nodes': 336}
    auxiliary[phase] = extra
signature = inspect.signature(capacity.attach_names)
assert all(p.default is inspect.Parameter.empty for p in signature.parameters.values())
for count in range(4):
    try:
        capacity.attach_names(*([0] * count))
    except TypeError:
        pass
    else:
        raise AssertionError('missing explicit Names operand was accepted')
for operands in [(0, 0, 0, 0), (2467, 100, 8192, 1000)]:
    result = capacity.attach_names(*operands)
    assert not result['additional_provider_attached']
    assert result['lifetime_requests'] == operands[0] + operands[1] + operands[3]
assert 'gross_shared_table_bounds only' in capacity.project_prefix.__doc__
assert 'attached separately' in capacity.project_prefix.__doc__
receipt = {
    'scope': 'Four auxiliary parser backings, explicit Names arguments and enumerated-table scope; no baseline replay',
    'capacity_sha256': hashlib.sha256((here / 'capacity.py').read_bytes()).hexdigest(),
    'retained_baseline_result_sha256': sha((here / 'result.json').read_bytes()),
    'selected_complete_sources_checked': len(sources),
    'auxiliary_parser_tables': auxiliary,
    'all_four_Name_operands_required': True,
    'arithmetic_never_attaches_missing_provider': True,
    'enumerated_table_scope_explicit': True,
    'passed': True,
    'elapsed_seconds': round(time.monotonic() - start, 6),
}
(here / 'boundary-result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps(receipt))
