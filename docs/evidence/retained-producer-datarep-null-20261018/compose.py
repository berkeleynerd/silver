#!/usr/bin/env python3
"""Compose the null data-representation compiler component; offline only."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--descriptor', type=Path, default=HERE/'fixture.json')
    p.add_argument('--ada-root', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args()
    records = {}
    for row in json.loads((HERE/'inputs.json').read_bytes()):
        raw = (REPO/row['path']).read_bytes()
        assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
        if row['path'].endswith('.json'):
            records[Path(row['path']).name if 'native-gcc-prefix' in row['path']
                    else row['path']] = json.loads(raw)
    prefix = records['docs/evidence/retained-producer-parent-20261018/prefix-result.json']
    native = records['native-gcc-prefix-witness.json']
    assert prefix['event_records_replayed'] == 47707
    assert prefix['hardware_write_watchpoints'] == 4
    assert not prefix['counter_wrap_or_reset'] and not prefix['collection_or_new_thread_observed']
    # Event/identity allowances transfer; measured aggregate bytes do not
    # become a source admission gate. Variable metadata is charged separately.
    for name in ('ggc_bytes', 'decl_uid', 'type_uid', 'debug_decl_uid'):
        for key in ('events', 'positive_events', 'negative_events'):
            assert prefix['counters'][name][key] == native['counters'][name][key]
    for name in ('decl_uid', 'type_uid', 'debug_decl_uid'):
        assert prefix['counters'][name] == native['counters'][name]
    assert prefix['gnat1_sha256'] != native['gnat1_sha256']
    report = records['docs/evidence/retained-producer-null-global-20261018/result.json']
    assert report['data_representation_file_bytes'] == 4
    assert report['data_representation_entries'] == 0
    native_dir = REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
    namespace = runpy.run_path(str(native_dir/'compose-null-capacity.py'))
    result = namespace['compose'](a.descriptor, namespace['load_model'](a.ada_root),
                                  producer_datarep=True)
    assert result['inputs']['gnat1']['sha256'] == prefix['gnat1_sha256']
    result['fixed_prefix_bridge'] = dict(managed_run_id=prefix['managed_run_id'],
        event_records_replayed=47707, fixed_GGC_requests=39257,
        fresh_declaration_identities=5832, fresh_type_identities=2277,
        measured_bytes_are_not_an_admission_gate=True)
    result['source_transfer'] = dict(
        fixed_Standard_and_System_read_projection=True,
        identical_null_expansion_and_postprefix_backend_shape=True,
        representation_level_two_gigi_constructor_delta=0,
        compiler_child_argc_source_bound=23, selected_argc_envelope=24,
        additional_repinfo_Name_Find_requests=2,
        source_and_configuration_premises_required=True,
        no_assembler_binder_or_linker_selected=True,
        complete_parent_and_producer_composition_established=False)
    a.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(component_checks=result['component_checks'],
                         compiler_sha256=result['inputs']['gnat1']['sha256'],
                         whole_toolchain_capacity_established=False)))


if __name__ == '__main__':
    main()
