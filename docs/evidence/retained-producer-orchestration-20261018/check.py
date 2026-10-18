#!/usr/bin/env python3
"""Reconcile the fixed producer runs and selected parent source/ALI dimensions."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32 = 2**31 - 1


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=REPO/'samples/null.adb')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE/'identity.json').read_bytes())
    archives = {}
    for name, expected in manifest['archives'].items():
        assert identity((HERE/name).read_bytes()) == expected['archive']
        with tarfile.open(HERE/name) as tar:
            assert all(m.isfile() for m in tar.getmembers())
            data = {m.name:tar.extractfile(m).read() for m in tar}
        assert {n:identity(b) for n,b in data.items()} == expected['members']
        archives[name] = data
    for name, expected in manifest['dependencies'].items():
        assert identity((REPO/name).read_bytes()) == expected
    datarep = json.loads((REPO/'docs/evidence/retained-producer-datarep-null-20261018/result.json').read_bytes())
    datarep_ali = datarep['components']['ALI']['serialized_file_byte_bound']
    assert datarep_ali == 2177456
    raw = archives['observations.tar.gz']
    get = lambda name: json.loads(raw[name])
    observations = []
    for label, run in manifest['runs'].items():
        inv = get(label+'/invocation.json')
        result = get(label+'/result.json')
        assert result['returncode'] == 0 and result['retained_inputs_unchanged']
        assert raw[label+'/stderr'] == b''
        assert inv['argv'][-2:] == ['-cargs','-Wno-free-nonheap-object']
        assert set(inv['environment']) == {'PATH','LC_ALL','TMPDIR'}
        work = Path(inv['cwd']).name
        for name, expected in result['generated'].items():
            assert identity(raw[label+'/'+work+'/'+name]) == expected
        spark = get(label+'/'+work+'/obj/gnatprove/main~1.spark')
        assert spark['flow'] == spark['proof'] == []
        assert raw[label+'/'+work+'/obj/gnatprove/data_representation/main.adb.json'] == b'[\n]\n'
        assert raw[label+'/'+work+'/main.adb'] == (REPO/'samples/null.adb').read_bytes()
        for name in result['generated']:
            if name.endswith(('.stdout','.stderr')):
                assert result['generated'][name]['bytes'] == 0
        events = [json.loads(line) for line in raw[label+'/managed/events.jsonl'].splitlines()]
        assert events[-1]['event'] == 'finished' and events[-1]['outcome'] == 'success'
        observations.append(dict(run=run, native_seconds=result['duration_seconds'],
                                 source_bytes=69, Main_VCs=0))
    # An overall invocation success does not repair a failed observer.
    assert b'Exception in thread' in raw['observer_socket_failure/managed/native.log']
    assert get('observer_socket_failure/observer.json')['files'] == []
    final = get('complete_configs/observer.json')
    captured = {r['archive_name']:raw['complete_configs/retained-temporaries/'+r['archive_name']]
                for r in final['files']}
    for row in final['files']:
        assert identity(captured[row['archive_name']]) == {k:row[k] for k in ('bytes','sha256')}
    configs = sorted((n,b) for n,b in captured.items() if b'configuration project' in b.lower())
    assert sorted(len(b) for n,b in configs) == [6741,6951,7015]
    naming = [b for b in captured.values() if b.lstrip().startswith(b'pragma Source_File_Name_Project')]
    assert len(naming) == 3 and len(set(naming)) == 1 and len(naming[0]) == 327
    for _, data in configs:
        assert b'with "' not in data.lower() and b'extends "' not in data.lower()
    model = runpy.run_path(str(REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017/compose-null-capacity.py'))
    source = args.source.read_bytes()
    counts = model['null_source_counts'](source)
    shape = model['physical_source_shape'](source)
    capacity = 500
    while capacity < shape['physical_line_entries_bound']:
        capacity *= 2
    # Project and each phase configuration live in a separate GPR process.
    # Their aligned sum is 12288; do not sum three process-local configurations.
    fixed = 4096 + max(4096*((len(b)+4096)//4096) for _,b in configs)
    assert fixed == 12288
    conditions = dict(source_length_and_EOF=len(source)+1 <= I32,
        shared_source_position=fixed+shape['aligned_source_extent']-1 <= I32-4096,
        line_table_bit_product=32*capacity <= I32,
        expanded_physical_column=shape['max_expanded_final_column'] <= 32766,
        producer_ALI_buffer=29622804+1 <= I32,
        datarep_ALI_buffer=datarep_ali+1 <= I32)
    result = dict(scope='selected null parent source/ALI interfaces and fixed executed context',
        observations=observations, retained_config_bytes=sorted(len(b) for n,b in configs),
        retained_naming_config_bytes=327, observer_misses=final['misses'],
        fixed_GPR_aligned_extent_per_process=fixed,
        source_bytes=len(source), source_sha256=hashlib.sha256(source).hexdigest(),
        source_shape=shape, source_word_tokens=counts['word_tokens'],
        GPR_physical_sources_per_process=3, GPR2_Main_source_parses=0,
        selected_GPR_ALI_rows=dict(ALIs=1,Units=1,Withs=1,Sdep=2,Args=0),
        datarep_ALI_file_bytes_upper=datarep_ali, producer_ALI_file_bytes_upper=29622804,
        conditions=conditions, all_selected_checks_pass=all(conditions.values()),
        fixed_context_source_projection_required=True,
        whole_toolchain_capacity_established=False, production_admission_changed=False)
    if args.output:
        args.output.write_text(json.dumps(result,indent=2)+'\n')
    else:
        assert result == json.loads((HERE/'result.json').read_bytes())
        print(json.dumps(result,indent=2))


if __name__ == '__main__':
    main()
