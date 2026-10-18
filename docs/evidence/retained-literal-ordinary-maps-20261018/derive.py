#!/usr/bin/env python3
"""Selected ordinary source-map preallocation; offline, conditional interface."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
MAX_LINES = 2**24
MAX_FILES = 1589
PACKED_LIMIT = 0x50000000 << 31


def derive(file_count_upper, logical_lines_upper):
    if type(file_count_upper) is not int or not 0 <= file_count_upper <= MAX_FILES:
        raise ValueError('selected permanent source-file upper bound required')
    if type(logical_lines_upper) is not int or logical_lines_upper < 1:
        raise ValueError('positive logical-line bound required')
    guards = dict(one_map_per_file=logical_lines_upper <= MAX_LINES,
                  location_space=1 + 256*file_count_upper*logical_lines_upper < PACKED_LIMIT)
    result = dict(file_count_upper=file_count_upper, logical_lines_upper=logical_lines_upper,
        guards=guards, source_map_size_bytes=32, allocation_rows=None,
        additional_GGC_events_upper=None, additional_finalizers_upper=0,
        complete_ordinary_map_lifetime_closed=False, total_GGC_events=None,
        complete_native_capacity=False, aggregate_RAM_gate=False,
        production_admission_changed=False, native_tool_executions=0)
    if not all(guards.values()):
        return result
    capacity = 0
    rows = []
    for used in range(file_count_upper):
        if used == capacity:
            requested_maps = 2*max(capacity or 128, used+1)
            raw = 32*requested_maps
            rounded = 1 << (raw-1).bit_length()
            capacity = rounded//32
            rows.append(dict(used_before=used,requested_maps=requested_maps,
                raw_before_rounding=raw,reallocator_caller_bytes=capacity*32,
                rounded_GGC_bytes=rounded,allocated_map_slots=capacity))
    result.update(allocation_rows=rows, allocated_map_slots_upper=capacity,
        additional_GGC_events_upper=len(rows),
        each_caller_bytes_upper=max((r['reallocator_caller_bytes'] for r in rows),default=0),
        individual_size_t_products_fit=all(r['rounded_GGC_bytes'] <= 2**63-1 for r in rows),
        map_count_and_index_uint64_fit=capacity < 2**64,
        highest_location_upper=1+256*file_count_upper*logical_lines_upper,
        gigi_source_map_preallocation_closed_under_premises=True,
        later_ordinary_map_mutators_excluded_here=False)
    return result


def check_inputs(gcc, ada):
    roots=dict(gcc=Path(gcc),ada=Path(ada))
    sources={}
    rows=json.loads((HERE/'inputs.json').read_text())['files']
    for row in rows:
        raw=(roots[row['root']]/row['path']).read_bytes()
        if len(raw)!=row['bytes'] or hashlib.sha256(raw).hexdigest()!=row['sha256']:
            raise ValueError('source identity: '+row['path'])
        sources[row['path']]=raw.decode()
    anchors={
        'gcc-interface/misc.cc':['line_table->default_range_bits = 0;'],
        'gcc-interface/trans.cc':['for (i = 0; i < number_file; i++)',
            'linemap_line_start (line_table, file_info_ptr[i].Num_Source_Lines, 252);',
            'linemap_position_for_column (line_table, 252 - 1);'],
        'libcpp/include/line-map.h':['typedef uint64_t location_t;',
            'Size is 28 (32) bytes for 32-bit (64-bit) arch.'],
        'libcpp/line-map.cc':['num_maps_allocated = 128;', 'num_maps_allocated *= 2;',
            'size_of_a_map = sizeof (line_map_ordinary);',
            'set->m_round_alloc_size (num_maps_allocated * size_of_a_map);',
            'set->m_reallocator (buffer, num_maps * size_of_a_map);'],
        'gcc/ggc-page.cc':['object_size_table[order] = (size_t) 1 << order;'],
        'gcc/toplev.cc':['line_table->m_round_alloc_size = ggc_round_alloc_size;'],
        'back_end.adb':['Nat (Physical_To_Logical (Last_Source_Line (J), J));']}
    for path,values in anchors.items():
        for value in values:
            if value not in sources[path]:
                raise ValueError('source anchor: '+path+': '+value)
    return len(rows)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',default='/tmp/silver-backend-compose-20261018/full-source')
    parser.add_argument('--ada-root',default='/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada')
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args=parser.parse_args()
    identities=check_inputs(args.gcc_root,args.ada_root)
    result=derive(MAX_FILES,MAX_LINES)
    result['complete_source_identities_checked']=identities
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(additional_GGC_events_upper=result['additional_GGC_events_upper'],
        each_caller_bytes_upper=result['each_caller_bytes_upper'],native_tool_executions=0)))


if __name__=='__main__':
    main()
