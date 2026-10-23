"""Independent frozen R72 audit: no author code, target or disassembler execution."""
from pathlib import Path
import hashlib
import json
import re
import struct
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = 'docs/evidence/retained-re-native-correspondence-20261023/'
CHECKS = 0


def check(ok, label):
    global CHECKS
    CHECKS += 1
    if not ok:
        raise AssertionError(label)


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_bytes())


class Image:
    """Local ELF64 parser, independent of the author's elf_reader module."""
    def __init__(self, raw):
        self.raw = raw
        check(raw[:6] == b'\x7fELF\x02\x01', 'ELF64 little-endian')
        header = struct.unpack_from('<HHIQQQIHHHHHH', raw, 16)
        check(header[1] == 62, 'x86_64 architecture')
        start, width, count = header[5], header[10], header[11]
        check(width == 64 and start + width*count <= len(raw), 'complete ELF section table')
        self.sections = [struct.unpack_from('<IIQQQQIIQQ', raw, start+i*width) for i in range(count)]
        self.symbols = {}
        for section in self.sections:
            if section[1] != 2:
                continue
            names = self.sections[section[6]]
            table = raw[names[4]:names[4]+names[5]]
            check(section[9] == 24 and section[5] % 24 == 0, 'ELF symbol entry extent')
            for offset in range(section[4], section[4]+section[5], 24):
                name_at, info, other, index, address, size = struct.unpack_from('<IBBHQQ', raw, offset)
                end = table.index(b'\0', name_at)
                name = table[name_at:end].decode()
                if name:
                    record = {'address':address, 'bytes':size, 'section_index':index, 'info':info}
                    self.symbols.setdefault(name, []).append(record)

    def at(self, address, size):
        candidates = [s for s in self.sections if s[1] != 8 and s[3] <= address and address+size <= s[3]+s[5]]
        check(size > 0 and len(candidates) == 1, 'unique complete file-backed ELF interval')
        section = candidates[0]
        offset = section[4]+address-section[3]
        check(offset+size <= len(self.raw), 'ELF file interval in bounds')
        return self.raw[offset:offset+size]


def native_audit():
    native = read(PACKET+'native.json')
    raw = Path(native['target']).read_bytes()
    check(identity(raw) == native['target_identity'], 'exact installed target identity')
    check(identity(Path(native['disassembler']).read_bytes()) == native['disassembler_identity'], 'retained decoder identity, no execution')
    check(native['target_executions'] == 0, 'author did not execute target')
    elf = Image(raw)
    instruction_rows = 0
    rendered = {}
    for name, record in native['functions'].items():
        aliases = elf.symbols[name]
        symbol = aliases[0]
        check(all(item == symbol for item in aliases), 'unambiguous selected named symbol '+name)
        check(all(record[k] == symbol[k] for k in symbol), 'exact native symbol '+name)
        check(symbol['info'] & 15 == 2, 'named function type '+name)
        code = elf.at(symbol['address'], symbol['bytes'])
        check(code.hex() == record['hex'] and identity(code) == record['identity'], 'complete native bytes '+name)
        check(record['disassembly'] == name+'.txt', 'unique complete symbol filename '+name)
        listing = (ROOT/PACKET/record['disassembly']).read_bytes()
        check(identity(listing) == record['disassembly_identity'], 'retained disassembly identity '+name)
        cursor = symbol['address']
        for line in listing.decode().splitlines():
            match = re.match(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2}(?:\s+|$))+)', line)
            if not match:
                continue
            address, values = int(match[1],16), bytes.fromhex(match[2])
            check(address == cursor, 'contiguous retained instruction bytes '+name)
            check(values == elf.at(address,len(values)), 'retained instruction bytes map to ELF '+name)
            cursor += len(values)
            instruction_rows += 1
        check(cursor == symbol['address']+symbol['bytes'], 'complete disassembly coverage '+name)
        rendered[name] = listing.decode()
    for name, record in native['data'].items():
        code = elf.at(record['address'], record['bytes'])
        check(code.hex() == record['hex'] and identity(code) == record['identity'], 'native data interval '+name)
        if 'words' in record:
            check(len(code)%8 == 0 and list(struct.unpack('<'+'Q'*(len(code)//8),code)) == record['words'], 'native data words '+name)
        if 'targets' in record:
            targets = [record['address']+x for x in struct.unpack('<'+'i'*(len(code)//4),code)]
            check(targets == record['targets'], 'signed relative dispatch table '+name)
    check(native['data']['epsilon_expr']['words'] == [0xb00,1,1], 'epsilon header, id0 and immediate definition')
    for key, symbol in {
        'rename_dispatch':'camlRe__Automata__rename_1196',
        'delta_expr_dispatch':'camlRe__Automata__delta_expr_2010',
        'handle_case_dispatch':'camlRe__Ast__handle_case_1186',
        'translate_block_dispatch':'camlRe__Compile__translate_1981',
        'translate_immediate_dispatch':'camlRe__Compile__translate_1981',
    }.items():
        body = native['functions'][symbol]
        for target in native['data'][key]['targets']:
            check(body['address'] <= target < body['address']+body['bytes'], 'selected dispatch stays in complete body '+key)
            check(re.search(r'^\s*'+format(target,'x')+r':', rendered[symbol], re.M) is not None, 'dispatch target retained row '+key)
    check(native['data']['char_initializer_closure']['words'][1] == native['functions']['camlRe__Ast__fun_2317']['address'], 'eager character initializer closure target')
    check(native['data']['mark_max_fold_closure']['words'][3] == native['functions']['camlRe__Mark_infos__fun_486']['address'], 'mark maximum fold closure target')
    witnesses = read(PACKET+'witnesses.json')
    for witness in witnesses:
        code = bytes.fromhex(witness['hex'])
        body = native['functions'][witness['symbol']]
        check(body['address'] <= witness['address'] and witness['address']+len(code) <= body['address']+body['bytes'], 'full witness inside named body')
        check(elf.at(witness['address'],len(code)) == code, 'instruction witness exact installed bytes')
        check(any(format(witness['address'],'x')+':' in line and witness['assembly'] in line for line in rendered[witness['symbol']].splitlines()), 'instruction witness retained decoding')
    # These manually reviewed cut landmarks must remain bound to the exact bytes.
    landmarks = {
        'camlRe__Hash_set__add_530':['9144f1:', '914500:', '914507:', '914510:'],
        'camlRe__Hash_set__resize_582':['9145ba:', '914636:', '<camlRe__Hash_set__add_530>'],
        'camlRe__Automata__delta_2076':['9199b4:', '9199cb:', '9199e0:'],
        'camlRe__Compile__resize_1199':['920882:', '9208ac:', '9208bf:'],
        'camlRe__Compile__find_state_1246':['920b0e:', '920b15:', '920ba5:'],
        'camlRe__Compile__loop_1358':['920daa:', '920db1:', '920dba:'],
        'camlRe__Str__search_forward_689':['927883:', '92788b:', '927917:'],
        'camlRe__Core__exec_594':['924c1f:', '$0x3,%esi'],
    }
    for name, markers in landmarks.items():
        for marker in markers:
            check(marker in rendered[name], 'reviewed native landmark '+name+' '+marker)
    no_local_trap = [
        'camlRe__Hash_set__add_530', 'camlRe__Hash_set__add_590', 'camlRe__Hash_set__resize_582',
        'camlRe__Automata__loop_1628', 'camlRe__Automata__delta_2076',
        'camlRe__Compile__resize_1199', 'camlRe__Compile__set_1203',
        'camlRe__Compile__loop_1358', 'camlRe__Compile__make_match_str_1508',
        'camlRe__Compile__match_str_no_bounds_1793', 'camlRe__Core__exec_594']
    for name in no_local_trap:
        check('push   0x10(%r14)' not in rendered[name], 'no native local trap on reviewed abandonment route '+name)
    return {'instruction_witnesses':len(witnesses), 'retained_functions':len(native['functions']), 'retained_data_intervals':len(native['data']),
            'instruction_byte_rows':instruction_rows, 'native_target':native['target'], 'native_target_identity':identity(raw),
            'disassembler_identity':native['disassembler_identity']}


def scalar_audit():
    maximum = (1 << 62)-1
    string_maximum = (1 << 57)-9
    array_maximum = (1 << 54)-1
    n = 64*(401+8)**2
    m = n+1
    count = m*(m+1)
    capacity = 4*count
    payload = 8*capacity
    check(n == 10705984 and m == 10705985, 'reference compile IDs plus native epsilon')
    check(count < maximum and 2*capacity < maximum, 'historical count and probe-sum arithmetic fit')
    check(payload <= string_maximum and 2*payload+1 < (1 << 63), 'packed Bytes and tagged allocation operand fit')
    check(payload//8+1 <= array_maximum, 'packed Bytes block word extent fits header')
    check(16*capacity-7 < (1 << 63), 'native tagged-index scaled address calculation fits')
    for index in range(403):
        tagged = 2*index+1
        encoded = -8-tagged
        check(encoded == 2*(-index-5)+1 and encoded <= -9, 'break state tagged encoding')
        check(-8-encoded == tagged and -(1 << 63) <= encoded < (1 << 63), 'break state decoding and signed range')
    authored = read(PACKET+'result.json')['bounds']
    for key, expected in {'compiler_ids':n,'hash_set_key_count':m,'historical_size':count,
                          'hash_set_slots':capacity,'hash_set_bytes':payload,'max_string_length':string_maximum}.items():
        check(authored[key] == expected, 'independent bound agrees with author '+key)
    for additions, key in ((402,'union_table_buckets'),(86,'individual_table_buckets')):
        buckets = 1
        while buckets < 97:
            buckets *= 2
        for size in range(1,additions+1):
            if size > 2*buckets:
                buckets *= 2
        check(buckets == authored[key], 'attempted-add ceiling gives table bound '+key)
    bits = 1
    while bits <= 401:
        bits *= 2
    check(bits == authored['working_bits'] == 512 and (bits+7)//8 == authored['working_bytes'] == 64, 'index/bit backing bound')
    for hint in range(513):
        length = hint+1
        while length <= 401:
            length *= 2
        check(length <= authored['positions_words'] == 2048, 'fresh/stale-hint growth envelope')
    check(authored['transition_words'] == 256+1 and authored['mark_words'] == 2*4, 'color and group mark extents')
    configurations = prefixes = count_lag_witnesses = 0
    # Scalar abstraction of every reinsert publication prefix. Hash placement
    # cannot affect these counts; probe coverage is checked independently below.
    for keys in range(1,65):
        ceiling = 4*keys*(keys+1)
        initial = [0]
        c = 1
        while c <= ceiling:
            initial.append(c)
            c *= 2
        for starting in initial:
            configurations += 1
            capacity_now, historical, occupied = starting, 0, 0
            for unused in range(keys):
                if capacity_now == 0 or (historical > 0 and capacity_now//historical < 2):
                    old = capacity_now
                    capacity_now = max(1,2*old)
                    check(capacity_now <= ceiling, 'coarse capacity closed across clear epochs')
                    for reinserted in range(occupied+1):
                        prefixes += 1
                        check(reinserted < capacity_now, 'every reinsertion has an empty slot')
                        check(historical+reinserted <= keys*(keys+1), 'reinsertion prefix historical bound')
                        # An escape here is followed by clear, never continued
                        # with partial occupancy/count as an intact epoch.
                    historical += occupied
                else:
                    check(occupied == 0 or occupied <= historical <= capacity_now//2, 'stable no-growth occupancy/load')
                check(occupied < capacity_now, 'ordinary insertion has empty slot')
                occupied += 1  # published packed key; count increment still pending
                prefixes += 1
                if occupied > historical:
                    count_lag_witnesses += 1
                check(historical <= keys*(keys+1), 'count before pending-action escape')
                historical += 1
                check(occupied <= historical <= keys*(keys+1), 'stable historical count after increment')
    check(count_lag_witnesses > 0, 'reject count>=occupancy at all exception prefixes')
    probe_cases = 0
    for capacity_now in (1,2,4,8,16,32,64):
        for start in range(capacity_now):
            positions = [(start+k if start+k < capacity_now else start+k-capacity_now) for k in range(capacity_now)]
            check(set(positions) == set(range(capacity_now)), 'one-subtraction linear probe covers table')
            for slot in positions:
                offset = ((2*slot+1)*8-7)//2
                check(offset == 8*slot and offset+8 <= 8*capacity_now, 'native packed access arithmetic')
                probe_cases += 1
    return {'compile_ID_upper':n, 'packed_key_domain':m, 'Hash_set_historical_count_upper':count,
            'Hash_set_capacity_upper':capacity, 'Hash_set_payload_bytes_upper':payload,
            'scalar_epoch_configurations':configurations, 'reinsertion_and_key_prefixes':prefixes,
            'count_lag_prefix_witnesses':count_lag_witnesses, 'linear_probe_slot_cases':probe_cases,
            'finite_models_are_universal_proof':False}


def main():
    started = time.monotonic()
    inputs = json.loads((HERE/'inputs.json').read_bytes())
    exact, providers = {}, {}
    for path, expected in inputs['exact_inputs'].items():
        raw = (ROOT/path).read_bytes()
        frozen = subprocess.check_output(['git','show',inputs['author_freezes']['installed_Re']+':'+path],cwd=ROOT)
        check(raw == frozen and identity(raw) == expected, 'exact frozen author file '+path)
        exact[path] = expected
    for path, expected in inputs['providers'].items():
        check(identity((ROOT/path).read_bytes()) == expected, 'accepted provider identity '+path)
        providers[path] = expected
    accepted = read('docs/evidence/retained-filetags-canonical-parser-review-20261023/audit-result.json')
    accepted_files = dict(accepted['providers'], **accepted['exact_inputs'])
    for item in read(PACKET+'inputs.json')['inputs']:
        check(providers[item['path']] == item['identity'], 'complete author-provider manifest attachment')
        if item['path'].endswith('/elf_reader.py'):
            continue  # New extraction helper identity is checked, never imported.
        check(accepted_files[item['path']] == item['identity'], 'reuse exact already accepted R71 source/evidence')
    result = {'status':'pass','author_freezes':inputs['author_freezes'],'exact_inputs':exact,'providers':providers,
              'audit_code_identity':identity(Path(__file__).read_bytes())}
    result.update(native_audit())
    result.update(scalar_audit())
    result.update({'checks':CHECKS,'elapsed_seconds':time.monotonic()-started,'author_or_predecessor_checker_runs':0,
                   'target_executions':0,'disassembler_runs':0,'compiler_runs':0,'solver_runs':0,'proof_runs':0,'capture_runs':0})
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ('exact_inputs','providers')},indent=2,sort_keys=True))


if __name__ == '__main__':
    main()
