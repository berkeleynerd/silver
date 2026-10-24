"""Bind selected installed report configuration fields without executing tools."""
import ctypes
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
START = time.perf_counter()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    return json.loads(path.read_text())


inputs = read(HERE / 'inputs.json')
for row in inputs['repository']:
    assert sha((ROOT / row['path']).read_bytes()) == row['sha256'], row['path']
spec = importlib.util.spec_from_file_location(
    'report_configuration_elf', ROOT / inputs['elf_reader'])
elf_reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(elf_reader)


class Elf(elf_reader.Elf):
    def at(self, address, size):
        # Debug sections can have address zero and large file extents. They are
        # not mapped at those virtual addresses: select SHF_ALLOC sections.
        sections = [s for s in self.sections if s[1] != 8 and s[2] & 2
                    and s[3] <= address and address+size <= s[3]+s[5]]
        assert len(sections) == 1, (hex(address), size)
        s = sections[0]
        off = s[4] + address - s[3]
        return self.data[off:off+size]

    def plt_import(self, address):
        op = self.at(address, 6)
        assert op[:2] == bytes.fromhex('ff25')
        slot = address + 6 + struct.unpack('<i', op[2:])[0]
        names = []
        for rel in self.sections:
            if rel[1] != 4:  # SHT_RELA
                continue
            symbols = self.sections[rel[6]]
            if symbols[1] != 11:  # SHT_DYNSYM
                continue
            strings = self.sections[symbols[6]]
            raw_names = self.data[strings[4]:strings[4]+strings[5]]
            for off in range(rel[4], rel[4]+rel[5], rel[9]):
                target, info, addend = struct.unpack_from('<QQq', self.data, off)
                if target != slot:
                    continue
                assert info & 0xffffffff == 7 and addend == 0
                sym_off = symbols[4] + (info >> 32)*symbols[9]
                name_off = struct.unpack_from('<I', self.data, sym_off)[0]
                names.append(raw_names[name_off:raw_names.index(0, name_off)].decode())
        assert len(names) == 1
        return names[0]


def masked(raw, intervals):
    value = bytearray(raw)
    for a, b in intervals:
        value[a:b] = bytes(b-a)
    return bytes(value)


version_template = bytes.fromhex(
    '4883ec08be04000000bf14000000e85d981d0048ba010000000a000000'
    '48b94653462031362e31488910ba2e30000066895010488d5008'
    '4889480848924883c408c3')
version_immediates = [(15,19), (21,29), (31,39), (43,47)]
native = []
for target in inputs['targets']:
    raw = Path(target['path']).read_bytes()
    assert len(raw) == target['bytes'] and sha(raw) == target['sha256']
    elf = Elf(raw)
    name = 'spark2014vsn__spark2014_version_string'
    fn = elf.function(name)
    assert len(fn) == 66
    assert masked(fn, version_immediates) == masked(version_template, version_immediates)
    destination = elf.symbols[name]['address'] + 19 + struct.unpack('<i', fn[15:19])[0]
    assert destination == elf.symbols['system__secondary_stack__ss_allocate']['address']
    low, high = struct.unpack('<ii', fn[21:29])
    assert (low, high) == (1, 10) and fn[45:47] == b'\0\0'
    value = fn[31:39] + fn[43:45]
    assert value.decode('ascii') == 'FSF 16.1.0'
    constant = elf.function('spark2014vsn__spark2014_static_version_string')
    assert constant[:10] == value and not any(constant[10:])
    max_path_raw = elf.function('__gnat_max_path_len')
    assert len(max_path_raw) == 4
    max_path = struct.unpack('<i', max_path_raw)[0]
    assert max_path == 4096
    row = dict(target=target, version_function_address=elf.symbols[name]['address'],
               version_function_hex=fn.hex(), version_bounds=[low,high],
               version_bytes=len(value), version_text=value.decode(),
               version_return_allocation_bytes=20, version_return_alignment=4,
               max_path_address=elf.symbols['__gnat_max_path_len']['address'],
               max_path_bytes_hex=max_path_raw.hex(), native_max_path=max_path)
    if target['role'] == 'reporter':
        page_name = 'gnatcoll__mmap__system__get_page_size'
        page = elf.function(page_name)
        expected = bytes.fromhex('4883ec08e82703deff85c0780789c04883c408c3e887faffff')
        assert masked(page, [(5,9),(21,25)]) == masked(expected, [(5,9),(21,25)])
        call = elf.symbols[page_name]['address'] + 9 + struct.unpack('<i', page[5:9])[0]
        assert elf.plt_import(call) == 'getpagesize'
        row.update(page_function_hex=page.hex(), page_import='getpagesize')
    native.append(row)

sources = {}
for archive in inputs['archives']:
    path = ROOT / archive['path']
    assert sha(path.read_bytes()) == archive['sha256'], str(path)
    with tarfile.open(path) as stream:
        for member, expected in archive['members'].items():
            raw = stream.extractfile(member).read()
            assert sha(raw) == expected, member
            sources[member] = raw.decode()
assert sources['gcc/ada/adaint.c'].count('int __gnat_max_path_len = GNAT_MAX_PATH_LEN;') == 1
assert 'pragma Import (C, Max_Path, "__gnat_max_path_len")' in sources['runtime/s-os_lib.adb']
assert 'pragma Import (C, Internal, "getpagesize")' in sources['gnatcoll/core/src/gnatcoll-mmap-system__unix.adb']
assert 'version      => To_Virtual_String (SPARK2014_Version_String)' in sources['spark-source/src/gnatprove/spark_report-generate_sarif_report.adb']
assert 'SPARK2014_Static_Version_String : constant String := "0.0w";' in sources['spark-source/spark2014vsn.ads']

# A configuration observation through the same declared C service, not a tool
# execution or a theorem about every host. The selected host/runtime relation
# and stable ordinary service behavior remain the accepted external premises.
service = ctypes.CDLL(None).getpagesize
service.restype = ctypes.c_int
service.argtypes = []
page_size = service()
assert 0 < page_size <= 65536
result = dict(status='pass', native=native, source_files=len(sources),
              observed_page_size=page_size, version_bytes=10, native_max_path=4096,
              selected_host=platform.platform(), page_service='getpagesize',
              source_version_literal_is_installed_value=False,
              complete_path_join=False, complete_fixed_report_composition=False,
              target_binary_executions=0, compiler_prover_runs=0,
              predecessor_checker_replays=0, libc_service_queries=1,
              elapsed_seconds=time.perf_counter()-START)
(HERE / 'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k != 'native'},indent=2))
