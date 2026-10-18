"""Compose the selected null-link representation contract without native runs."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import struct
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--prior-repo', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
prior = args.prior_repo.resolve()
sha = lambda raw: hashlib.sha256(raw).hexdigest()
inputs = json.loads((root/'inputs.json').read_bytes())
records = {}
for row in inputs:
    raw = (prior/row['path']).read_bytes()
    assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']
    records[row['key']] = json.loads(raw)
source_manifest = json.loads((root/'sources.json').read_bytes())
assert sha((root/'sources.tar.gz').read_bytes()) == source_manifest['archive_sha256']
with tarfile.open(root/'sources.tar.gz') as archive:
    assert sorted(archive.getnames()) == sorted(r['path'] for r in source_manifest['files'])
    for row in source_manifest['files']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and sha(raw) == row['sha256'], row['path']


def elf(raw):
    assert raw[:6] == b'\x7fELF\x02\x01'
    assert struct.unpack_from('<H', raw, 18)[0] == 62
    shoff = struct.unpack_from('<Q', raw, 40)[0]
    stride, count, names_index = struct.unpack_from('<HHH', raw, 58)
    assert stride == 64
    first = struct.unpack_from('<IIQQQQIIQQ', raw, shoff)
    count = count or first[5]
    names_index = first[6] if names_index == 65535 else names_index
    assert shoff + count*64 <= len(raw)
    headers = [struct.unpack_from('<IIQQQQIIQQ', raw, shoff+64*i) for i in range(count)]

    def payload(h):
        assert h[1] != 8 and h[4]+h[5] <= len(raw)
        return raw[h[4]:h[4]+h[5]]

    def string(b, pos):
        return b[pos:b.index(0, pos)].decode()

    names = payload(headers[names_index])
    section_names = [string(names, h[0]) for h in headers]
    symbols = []
    for h in headers:
        if h[1] not in (2, 11):
            continue
        assert h[9] == 24 and h[5] % 24 == 0
        strings = payload(headers[h[6]])
        for off in range(h[4], h[4]+h[5], 24):
            name, info, other, sec, value, size = struct.unpack_from('<IBBHQQ', raw, off)
            symbols.append(dict(name=string(strings, name), info=info, other=other,
                                section=sec, value=value, size=size))
    return headers, section_names, symbols


counts = Counter()
max_archive_sections = 0
for f in records['inventory']['files']:
    if f['role'] == 'generated-input':
        continue
    raw = Path(f['path']).read_bytes()
    assert len(raw) == f['bytes'] and sha(raw) == f['sha256']
    counts['fixed_files'] += 1
    if f['kind'] == 'script':
        assert raw.startswith(b'/*')
        counts['scripts_with_slash_star_prefix'] += 1
        continue
    for m in f.get('members', [f]):
        if f['kind'] == 'archive':
            start = m['header_offset']+60
            data = raw[start:start+m['bytes']]
            assert len(data) == m['bytes'] and sha(data) == m['sha256']
            counts['archive_members'] += 1
        else:
            data = raw
        headers, _, symbols = elf(data)
        if f['kind'] == 'archive':
            max_archive_sections = max(max_archive_sections, len(headers))
        counts['fixed_ELF_inputs'] += 1
        counts['COMMON_symbols'] += sum(s['section'] in (0xfff2, 0xff02) for s in symbols)
assert counts['COMMON_symbols'] == 0
assert counts['scripts_with_slash_star_prefix'] == 2
assert max_archive_sections == 55

# Read the selected ld's configured target-vector projection. No ld command
# executes. The source proof excludes transient section construction while
# rejecting the two scripts in precisely these target formats.
linker = records['linker']
ldraw = Path(linker['resolved_linker']).read_bytes()
assert sha(ldraw) == linker['selected_linker_sha256']
headers, _, symbols = elf(ldraw)
by_name = {s['name']: s for s in symbols}


def vbytes(address, count):
    for h in headers:
        if h[3] <= address and address+count <= h[3]+h[5]:
            if h[1] == 8:
                return bytes(count)
            start = h[4]+address-h[3]
            return ldraw[start:start+count]
    raise AssertionError(('unmapped installed address', address, count))


def vstring(address):
    result = bytearray()
    while True:
        b = vbytes(address+len(result), 1)
        if b == b'\0':
            return result.decode()
        result += b
        assert len(result) < 100


vector = by_name['_bfd_target_vector']
assert vector['size'] == 19*8
targets = []
for off in range(0, vector['size'], 8):
    pointer = struct.unpack('<Q', vbytes(vector['value']+off, 8))[0]
    if pointer:
        targets.append(vstring(struct.unpack('<Q', vbytes(pointer, 8))[0]))
    else:
        assert off == vector['size']-8
assert targets == ['elf64-x86-64', 'elf32-i386', 'elf32-iamcu', 'elf32-x86-64',
                   'pei-i386', 'pe-x86-64', 'pei-x86-64', 'elf64-little',
                   'elf64-big', 'elf32-little', 'elf32-big', 'srec',
                   'symbolsrec', 'verilog', 'tekhex', 'binary', 'ihex', 'plugin']
initial_ids = {}
for name, expected in [('_bfd_section_id', 16), ('bfd_id_counter', 0)]:
    s = by_name[name]
    assert s['size'] == 4
    value = int.from_bytes(vbytes(s['value'], 4), 'little')
    assert value == expected
    initial_ids[name] = value
target_record = dict(linker_sha256=sha(ldraw), targets=targets,
                     vector_entries_including_null=19, initial_ids=initial_ids)
assert target_record == json.loads((root/'target-projection.json').read_bytes())

join = records['join']
assert all(join['component_arithmetic_conditions'].values())
assert records['interface']['historical_successful_link_retained']
assert not records['interface']['fixed_input_Main_external_records']
assert records['relocations']['arithmetic_conditions_pass']
assert records['unwind']['final_signed32_fields_fit_under_operand_projection']
assert records['unwind']['EH_counts']['CFA_set_loc'] == 0
assert join['layout_shape_join']['effective_alignment_established']
assert join['layout_shape_join']['mapping_iterations_upper'] == 2
assert records['auxiliary']['covered_count_arithmetic_fits']
assert not records['hash_storage']['objalloc_has_cumulative_allocation_counter']
assert not records['cache']['additional_cumulative_memory_predicate_required_for_these_fields']
assert records['cache']['selected_max_cache_size'] == 'UINT64_MAX'
assert records['local_ifunc']['selected_local_entries_under_premise'] == 0
assert records['layout_shape']['mapping_convergence_established']
assert records['global_names']['selected_assignment_walk_non_dot_visits_upper'] == 16
assert records['optional']['new_build_id_payload_bytes'] == 0
assert records['optional']['CTF_output_payload_bytes'] == 0
assert records['optional']['SFrame_input_and_synthetic_payload_bytes'] == 0
R,Q,P,I,S,N = (join['counts'][k] for k in ['R','Q','P','I','S','N'])
probes = sum(len(q['ordered_probes']) for q in records['inventory']['library_resolution'])
assert probes == 65
F = counts['fixed_files']
bfd_id_events = 2*(P + 2*probes + 2*F + 1)
section_id_peak = 16 + 2*(Q+I+S)
start_stop_entries = 2*(I+S)
start_stop_capacity = 0
while start_stop_capacity < start_stop_entries:
    start_stop_capacity = 2*start_stop_capacity+10
assert start_stop_capacity <= 2*start_stop_entries+10
main = records['main_object']
reader = dict(Main_section_headers=main['section_headers_including_null'],
              Main_header_array=80*main['section_headers_including_null'],
              Main_header_pointer_array=8*main['section_headers_including_null'],
              Main_header_creation_flags=main['section_headers_including_null'],
              external_symbol_bytes=24*R, internal_symbol_bytes=32*R,
              local_section_indices=4*R, external_symbol_hash_pointers=8*R,
              original_relocation_bytes=24*join['counts']['Trel'])
bounds = dict(BFD_object_ID_events=bfd_id_events, BFD_section_ID_peak=section_id_peak,
              start_stop_entries=start_stop_entries,
              start_stop_capacity=start_stop_capacity,
              start_stop_pointer_bytes=8*start_stop_capacity,
              lang_statement_iterations=16, lang_sizing_iterations=9,
              section_address_check_array_bytes=16*S,
              empty_explicit_PHDR_pointer_array_bytes=10*8,
              output_statement_hash_keys=S+1,
              Main_ELF_reader=reader,
              input_mmap_span_formula='n+2*(G-1), n<=B',
              input_mmap_span_at_4096=join['payload_union_bytes']+8192)
assert bfd_id_events == 3288 and section_id_peak == 268632
assert join['payload_union_bytes']+8192 < 2**31
assert all(x < 2**31 for x in [bfd_id_events,section_id_peak,start_stop_entries,
                               start_stop_capacity,8*start_stop_capacity,16*S,S+1,*reader.values()])
result = dict(scope='Selected null-Main ld/BFD representation composition under retained descriptor and source premises',
              native_tool_executions=0, source_files_verified=len(source_manifest['files']),
              prior_inputs_verified=len(inputs), fixed_input_census=dict(counts),
              maximum_archive_member_section_headers=max_archive_sections,
              configured_target_projection=target_record, additional_bounds=bounds,
              payload_union_bytes=join['payload_union_bytes'],
              retained_address_endpoint=join['conditional_layout']['retained_endpoint'],
              file_position_endpoint=join['conditional_layout']['file_endpoint'],
              common_signed_relocation_bound=records['relocations']['bounds']['conservative_common_signed32'],
              capacity_composition_requires_manual_source_argument=True,
              source_transfer_conditions=[
                  'selected no-LTO ELF64 x86-64 PIE options and fixed lookup outcomes',
                  'retained source describes selected installed linker behavior',
                  'source-derived null Main object and stable external interface',
                  'accepted indexed binder shape and historical interface bridge',
                  'prior counts, payload, symbols, relocation, EH and layout transfers',
                  'selected LP64 and existing host-page/path/resource premises',
                  'manual supplemental reader, ID, LD array and iteration argument'],
              independent_ID_review_accepted=True,
              selected_null_link_representation_closed=True,
              broader_grammar_or_tool_pipeline_closed=False,
              physical_resource_guarantee=False)
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(BFD_object_ID_events=bfd_id_events, BFD_section_ID_peak=section_id_peak,
                     start_stop_capacity=start_stop_capacity,
                     selected_null_link_representation_closed=True)))
