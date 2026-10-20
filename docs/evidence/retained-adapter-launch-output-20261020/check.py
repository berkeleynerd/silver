#!/usr/bin/env python3
"""Read the selected ELF and source; retain/check finite launch diagnostics."""
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
LIBC = Path('/usr/lib/x86_64-linux-gnu/libc.so.6')
ARCHIVE = ROOT / 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def check():
    blob = LIBC.read_bytes()
    assert identity(blob) == dict(bytes=2190608, sha256='85e64f97e348786a8fb4d9f3d52fec289e2fb86bba20f0731dfe61990525e0f7')
    assert identity(ARCHIVE.read_bytes()) == dict(bytes=1372815, sha256='2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749')
    assert blob[:6] == b'\x7fELF\x02\x01'
    phoff = struct.unpack_from('<Q', blob, 32)[0]
    phsize, phnum = struct.unpack_from('<HH', blob, 54)
    loads = []
    for i in range(phnum):
        kind, flags, offset, address, _, filesz, memsz, align = struct.unpack_from('<IIQQQQQQ', blob, phoff+i*phsize)
        if kind == 1:
            loads.append(dict(offset=offset, address=address, filesz=filesz, memsz=memsz, flags=flags))

    def read(address, size):
        matches = [p for p in loads if p['address'] <= address and address+size <= p['address']+p['filesz']]
        assert len(matches) == 1, (address, size)
        p = matches[0]; start = p['offset']+address-p['address']
        return blob[start:start+size]

    def string(address):
        data = bytearray()
        for i in range(1024):
            b = read(address+i, 1)
            if b == b'\0':
                return bytes(data)
            data += b
        raise AssertionError('Unterminated retained error string')

    shoff = struct.unpack_from('<Q', blob, 40)[0]
    shsize, shnum = struct.unpack_from('<HH', blob, 58)
    relocations = {}
    packed_relative = set()
    for i in range(shnum):
        fields = struct.unpack_from('<IIQQQQIIQQ', blob, shoff+i*shsize)
        if fields[1] == 19:  # SHT_RELR, ELF64 packed relative relocations.
            assert fields[9] == 8
            where = None
            for offset in range(fields[4], fields[4]+fields[5], 8):
                entry = struct.unpack_from('<Q', blob, offset)[0]
                if entry & 1:
                    assert where is not None
                    packed_relative.update(where+8*(bit-1) for bit in range(1,64) if entry & (1<<bit))
                    where += 63*8
                else:
                    packed_relative.add(entry)
                    where = entry+8
            continue
        if fields[1] != 4:
            continue
        assert fields[9] == 24
        for offset in range(fields[4], fields[4]+fields[5], 24):
            address, info, addend = struct.unpack_from('<QQq', blob, offset)
            relocations[address] = dict(type=info & 0xffffffff, symbol=info >> 32, addend=addend)

    helper = read(0x89ad0, 34)
    assert helper.hex() == 'f30f1efa31c085ff78174863ff483b3d7ca61500730b488d05f3601800488b04f8c3'
    # Decode both RIP-relative targets instead of trusting objdump comments.
    count_address = 0x89ae4 + struct.unpack_from('<i', helper, 16)[0]
    table_address = 0x89aed + struct.unpack_from('<i', helper, 25)[0]
    assert (count_address, table_address) == (0x1e4160, 0x20fbe0)
    count = struct.unpack('<Q', read(count_address, 8))[0]
    assert count == 134
    errors = []
    for n in range(count):
        address = table_address+8*n
        target = struct.unpack('<Q', read(address, 8))[0]
        if target == 0:
            assert address not in relocations and address not in packed_relative
            errors.append(dict(errno=n, target=0, text=None, bytes=0))
        else:
            assert ((address in packed_relative and address not in relocations) or
                    relocations.get(address) == dict(type=8, symbol=0, addend=target))
            value = string(target)
            errors.append(dict(errno=n, target=target, relocation='RELR' if address in packed_relative else 'RELA', text=value.decode('ascii'), bytes=len(value)))
    unknown = string(0x1dcbab)
    unknown_format = string(0x1dcbba)
    fallback = string(0x1dcbbf)
    assert unknown == b'Unknown error ' and unknown_format == b'%s%d'
    assert fallback == b'Unknown error'
    unknown_max = len(unknown) + len(str(-(2**31)))
    error_max = max(max(row['bytes'] for row in errors), unknown_max, len(fallback))

    witnesses = []
    with tarfile.open(ARCHIVE) as archive:
        for name, ranges in {
            'server-unix.c':[(74,86),(163,194),(313,399),(503,534),(638,650)],
            'logging.c':[(17,42)], 'options.c':[(17,87)],
            'proc.c':[(1,130)]}.items():
            member = 'why3/src/server/'+name
            raw = archive.extractfile(member).read(); lines = raw.decode().splitlines(keepends=True)
            for lo, hi in ranges:
                hi = min(hi,len(lines))
                witnesses.append(dict(member=member, identity=identity(raw), first=lo,last=hi,text=''.join(lines[lo-1:hi])))
        server = archive.extractfile('why3/src/server/server-unix.c').read().decode()
        child = server[server.index('pid_t create_process('):server.index('void write_to_client(')]
        assert child.count('fprintf(') == 2 and child.count('perror(') == 1
        assert child.count('execvp(') == 1
        assert child.index('creation of process group failed') < child.index('dup2(outfile, 1)')
        assert child.index('Cannot open the input file') < child.index('dup2(outfile, 1)')
        assert child.index('dup2(outfile, 2)') < child.index('execvp(') < child.index("exec of '%s' failed")
        assert child.count('exit(1);') == 3
        assert '"%s: creation of process group failed (%s)\\n"' in child
        assert '"%s: exec of \'%s\' failed (%s)\\n"' in child
        assert 'perror("Cannot open the input file")' in child
        logging = archive.extractfile('why3/src/server/logging.c').read().decode()
        assert 'if (logging)' in logging and 'exit(1);' in logging

    group = b'%s: creation of process group failed (%s)\n'
    failed_exec = b"%s: exec of '%s' failed (%s)\n"
    group_fixed = len(group.replace(b'%s',b''))
    exec_fixed = len(failed_exec.replace(b'%s',b''))
    # Compare the formulas with independently substituted finite strings.
    for length in [0,1,76,255,4096,16384]:
        command = b'x'*length
        for row in errors:
            if row['text'] is None:
                continue
            error = row['text'].encode()
            assert len(group % (command,error)) == length+len(error)+group_fixed
            assert len(failed_exec % (command,command,error)) == 2*length+len(error)+exec_fixed
            assert len(failed_exec % (command,command,error)) <= 2*length+error_max+exec_fixed
    return dict(libc_path=str(LIBC),libc_identity=identity(blob),load_segments=loads,
        errno_lookup=dict(address=0x89ad0,bytes_hex=helper.hex(),count_address=count_address,table_address=table_address,count=count),
        native_bodies=[dict(name=name,address=addr,bytes_hex=read(addr,size).hex()) for name,addr,size in [('strerror',0xbb990,20),('strerror_l',0xbb9b0,303)]],
        errno_strings=errors, unknown_error_max=unknown_max, error_string_max=error_max,
        group_diagnostic_fixed_bytes=group_fixed, exec_diagnostic_fixed_bytes=exec_fixed,
        stdin_perror_fixed_bytes=len(b'Cannot open the input file: \n'),
        source_archive_identity=identity(ARCHIVE.read_bytes()),source_witnesses=witnesses,
        scope='Direct stock server child diagnostics under exact ELF, C-locale and normal service premises; not adapter/loader startup or complete q',
        complete_adapter_startup_bound=False, complete_q=None,
        production_adopted=False,native_target_runs=0,solver_or_proof_runs=0,predecessor_replays=0)


if __name__ == '__main__':
    start=time.monotonic(); result=check(); output=HERE/'result.json'
    if output.exists():
        assert json.loads(output.read_text()) == result
    else:
        output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(passed=True,error_string_max=result['error_string_max'],
        group_fixed=result['group_diagnostic_fixed_bytes'],exec_fixed=result['exec_diagnostic_fixed_bytes'],
        seconds=time.monotonic()-start)))
