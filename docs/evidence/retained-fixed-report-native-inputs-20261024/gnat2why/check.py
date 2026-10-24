"""Attach the producer's native configuration owners; execute no target/service."""
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
START = time.perf_counter()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


inputs = json.loads((HERE / 'inputs.json').read_text())
for row in inputs['repository']:
    assert sha((ROOT / row['path']).read_bytes()) == row['sha256'], row['path']
target = inputs['target']
raw = Path(target['path']).read_bytes()
assert len(raw) == target['bytes'] and sha(raw) == target['sha256']
spec = importlib.util.spec_from_file_location('producer_config_symbols', ROOT / inputs['elf_reader'])
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
elf = reader.Elf(raw)
header = struct.unpack_from('<16sHHIQQQIHHHHHH', raw)
segments = [struct.unpack_from('<IIQQQQQQ', raw, header[5]+i*header[9])
            for i in range(header[10])]


def mapped(address, size):
    candidates = [s for s in segments if s[0] == 1 and s[3] <= address
                  and address+size <= s[3]+s[5]]
    assert len(candidates) == 1
    segment = candidates[0]
    offset = segment[2]+address-segment[3]
    return raw[offset:offset+size]


def symbol(name):
    value = elf.symbols[name]
    assert value['bytes'] > 0
    return mapped(value['address'], value['bytes'])


def masked(value, spans):
    value = bytearray(value)
    for start, end in spans:
        value[start:end] = bytes(end-start)
    return bytes(value)


retained = json.loads((ROOT / inputs['retained_configuration']).read_text())
reporter = next(x for x in retained['native'] if x['target']['role'] == 'reporter')
version_name = 'spark2014vsn__spark2014_version_string'
version = symbol(version_name)
# Reuse the reviewed instruction shape, separately resolve this ELF's call.
assert len(version) == 66
assert masked(version, [(15,19)]) == masked(bytes.fromhex(reporter['version_function_hex']), [(15,19)])
allocator = elf.symbols[version_name]['address']+19+struct.unpack('<i', version[15:19])[0]
assert allocator == elf.symbols['system__secondary_stack__ss_allocate']['address']
assert struct.unpack('<ii', version[21:29]) == (1,10)
text = version[31:39]+version[43:45]
assert text == b'FSF 16.1.0'
assert symbol('spark2014vsn__spark2014_static_version_string') == text+bytes(6)
max_path = struct.unpack('<i', symbol('__gnat_max_path_len'))[0]
assert max_path == 4096

page_name = 'gnatcoll__mmap__system__get_page_size'
page = symbol(page_name)
assert len(page) == 25
assert masked(page, [(5,9),(21,25)]) == masked(bytes.fromhex(reporter['page_function_hex']), [(5,9),(21,25)])
plt = elf.symbols[page_name]['address']+9+struct.unpack('<i', page[5:9])[0]
jump = mapped(plt,6)
assert jump[:2] == bytes.fromhex('ff25')
slot = plt+6+struct.unpack('<i',jump[2:])[0]
imports = []
for section in elf.sections:
    if section[1] != 4:
        continue
    symbols = elf.sections[section[6]]
    if symbols[1] != 11:
        continue
    strings = elf.sections[symbols[6]]
    names = raw[strings[4]:strings[4]+strings[5]]
    for offset in range(section[4],section[4]+section[5],section[9]):
        address, info, addend = struct.unpack_from('<QQq',raw,offset)
        if address != slot:
            continue
        assert info & 0xffffffff == 7 and addend == 0
        name_offset = struct.unpack_from('<I',raw,symbols[4]+(info >> 32)*symbols[9])[0]
        imports.append(names[name_offset:names.index(0,name_offset)].decode())
assert imports == ['getpagesize']
page_size = retained['observed_page_size']
assert page_size == 4096

result = dict(status='pass', target=target, native_max_path=max_path,
    version_text=text.decode(), version_bytes=len(text), version_bounds=[1,10],
    version_function_hex=version.hex(), version_return_allocation_bytes=20,
    version_return_alignment=4, page_function_hex=page.hex(), page_import=imports[0],
    page_size_from_retained_host_observation=page_size,
    service_relation='same host/runtime and stable ordinary getpagesize service premise',
    producer_native_configuration_owners_bound=True, complete_path_join=False,
    complete_producer_capacity=False, complete_fixed_report_composition=False,
    target_binary_executions=0, libc_service_queries=0, predecessor_checker_replays=0,
    compiler_prover_Lean_runs=0, elapsed_seconds=time.perf_counter()-START)
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if not k.endswith('_hex')},indent=2))
