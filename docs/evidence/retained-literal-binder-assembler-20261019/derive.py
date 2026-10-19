#!/usr/bin/env python3
"""Replay bounded output-binder GAS witnesses and checksum source arithmetic.

No native execution. This is a conditional source-family transfer, not a
standalone native pipeline verdict or a substitute for its source argument.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
MASK = rb'(?m)^mainB:\n[^\n]*\n'


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def numeric(checksum):
    require(type(checksum) is int and 0 <= checksum < 2**32, 'uint32 checksum')
    signed = checksum if checksum < 2**31 else checksum-2**32
    directive = '\t.zero\t4\n' if checksum == 0 else '\t.long\t%d\n' % signed
    return dict(checksum=checksum, signed_value=signed, directive=directive,
                decimal_digits=len(str(abs(signed))),
                operand_recursion_depth=1+int(signed < 0),
                O_constant=True, bignum=False, output_bytes=4,
                variable_symbol_insertions=0, variable_fixups=0)


def checksum_offset(raw):
    require(raw[:6] == b'\x7fELF\x02\x01', 'ELF64 little endian object')
    require(struct.unpack_from('<HH',raw,16) == (1,62), 'x86-64 relocatable')
    table = struct.unpack_from('<Q',raw,40)[0]
    entry_size, count = struct.unpack_from('<HH',raw,58)
    require(entry_size == 64 and count == 16, 'accepted section table')
    sections = [struct.unpack_from('<IIQQQQIIQQ',raw,table+64*i) for i in range(count)]
    offsets=[]
    for section in sections:
        if section[1] != 2:
            continue
        strings = sections[section[6]]
        names=raw[strings[4]:strings[4]+strings[5]]
        require(section[9] == 24 and section[5] % 24 == 0, 'symbol records')
        for off in range(section[4], section[4]+section[5],24):
            name, info, other, index, value, size=struct.unpack_from('<IBBHQQ',raw,off)
            if names[name:names.index(b'\0',name)] == b'mainB':
                require(size == 4 and info == 17 and other == 0 and index < count, 'public checksum scalar')
                target=sections[index]
                require(target[1] == 1 and value+size <= target[5], 'checksum data section span')
                offsets.append(target[4]+value)
    require(len(offsets) == 1, 'single checksum symbol')
    return offsets[0]


class Context:
    def __init__(self, gcc_root, gas_root):
        self.manifest = json.loads((HERE/'inputs.json').read_bytes())
        roots = dict(gcc=Path(gcc_root),gas=Path(gas_root),repository=REPO)
        for row in self.manifest['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')}, row['path'])
        require(identity((HERE/'capture.tar.gz').read_bytes()) == self.manifest['capture'], 'capture bytes')
        with tarfile.open(HERE/'capture.tar.gz') as archive:
            self.artifacts = {m.name:archive.extractfile(m).read() for m in archive.getmembers() if m.isfile()}
        self.run = json.loads(self.artifacts['result.json'])
        self.result = replay(self.artifacts, self.run)


def replay(artifacts, run):
    require([r['tag'] for r in run['cases']] == ['baseline','zero','signed_boundary','maximum'], 'four recorded cases')
    masked = []
    object_masks = []
    for row in run['cases']:
        prefix = 'cases/'+row['tag']+'/'
        for name in ['b__main~1.s','b__main~1.o','b__main~1.ali']:
            require(identity(artifacts[prefix+name]) == row[name], prefix+name)
        for role in ['body','spec']:
            name = 'b__main~1.'+('adb' if role == 'body' else 'ads')
            require(identity(artifacts[prefix+name]) == row['source_identities'][role], role)
        require(len(row['cwd']) == 113, 'source fullname projection')
        require(set(row['environment']) == {'PATH','LC_ALL','TMPDIR'} and row['environment']['LC_ALL'] == 'C', 'controlled environment')
        require([c['role'] for c in row['commands']] == ['compiler','assembler'], 'selected tool roles')
        require(row['commands'][0]['argv'] == [run['plan']['compiler'], '-S', '-x', 'ada', '-gnatA', '-gnatA',
            '-gnatWb', '-gnatiw', '-gnatws', '-Wno-free-nonheap-object', '-mtune=generic', '-march=x86-64',
            '-fsplit-wide-types', 'b__main~1.adb', '-o', 'b__main~1.s'], 'exact observation compiler argv')
        require(row['commands'][1]['argv'] == [run['plan']['assembler'], '--64', '-o', 'b__main~1.o', 'b__main~1.s'],
                'exact observation assembler argv')
        for command in row['commands']:
            require(command['exit'] == 0, 'retained successful tool exit')
            for output in ['stdout','stderr']:
                require(identity(artifacts[prefix+command['role']+'.'+output]) == command[output], output)
                require(command[output]['bytes'] == 0, 'no diagnostic output')
        assembly = artifacts[prefix+'b__main~1.s']
        require(len(re.findall(MASK,assembly)) == 1, 'one Main checksum data item')
        transfer = numeric(row['checksum'])
        require(b'mainB:\n'+transfer['directive'].encode() in assembly, 'source-derived directive')
        require(row['checksum_directive'] == transfer['directive'], 'retained directive equality')
        masked.append(re.sub(MASK,b'mainB:\n<CHECKSUM>\n',assembly))
        require(assembly.count(b'\n') == 1262 and max(map(len,assembly.split(b'\n'))) == 87, 'assembly extents')
        obj=artifacts[prefix+'b__main~1.o']
        offset=checksum_offset(obj)
        require(obj[offset:offset+4] == struct.pack('<I',row['checksum']), 'exact checksum bytes')
        object_masks.append(obj[:offset]+b'\0'*4+obj[offset+4:])
    require(all(x == masked[0] for x in masked), 'only the checksum directive varies')
    require(all(x == object_masks[0] for x in object_masks), 'only four checksum object bytes vary')
    require(run['cases'][0]['b__main~1.o']['sha256'] ==
            'b668f70341f147da7340df4ad5436206b052ec158a7108cd4bbc1b11fd9f3b4a', 'accepted output object reproduced')
    managed = [json.loads(line) for line in artifacts[
        'managed/20261019T145323-b23fa45c07bb/events.jsonl'].splitlines()]
    finished, = [r for r in managed if r['event'] == 'finished']
    require(finished['outcome'] == 'success', 'managed completion')
    # Decimal CONST_INT printing is at most a sign plus ten digits. The
    # longest form is the retained signed-boundary case; all other bytes
    # and all line breaks are fixed by the accepted compiler projection.
    longest = numeric(2**31)['directive']
    max_bytes = len(masked[0])-len(b'<CHECKSUM>\n')+len(longest)
    checks = dict(decimal_accumulation_unsigned64=2**31 < 2**64,
                  signed32_data_fits_four_bytes=2**31 <= 2**32,
                  decimal_length_below_GAS_small_threshold=10 < (64+11)//4,
                  complete_source_below_first_input_buffer=max_bytes < 32768,
                  longest_line_below_initial_scrub=87 < 65536,
                  line_counter_signed=1262+1 < 2**31,
                  zero_repeat_and_byte_count_signed=4 < 2**31,
                  checksum_does_not_change_symbol_or_fixup_counts=True)
    return dict(scope='Selected output-binder assembler checksum family under source projection',
                checksum_domain=[0,2**32-1], source_equivalence_classes=['zero','nonzero signed32 decimal'],
                assembly_bytes_upper=max_bytes, lines=1262, longest_line_bytes=87,
                maximum_checksum_directive_bytes=len(longest), decimal_digits_upper=10,
                numeric_operand_depth_upper=2, checksum_data_bytes=4,
                conditions=checks, conditional_binder_assembler_capacity=all(checks.values()),
                source_argument_required=True, same_source_invocation_join_required=True,
                fixed_success_transfers_zero_and_nonzero_requests=True,
                total_or_peak_RAM_inferred=False, complete_native_capacity=False,
                production_admission_changed=False, native_tool_executions=0,
                retained_native_executions=8, retained_tool_seconds=run['elapsed_seconds'],
                retained_managed_seconds=finished['duration_seconds'])


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,required=True)
    parser.add_argument('--gas-root',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    start=time.perf_counter()
    context=Context(args.gcc_root,args.gas_root)
    result=context.result
    result['offline_seconds']=time.perf_counter()-start
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__ == '__main__':
    main()
