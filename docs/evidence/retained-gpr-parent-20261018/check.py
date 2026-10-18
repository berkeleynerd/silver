#!/usr/bin/env python3
"""Replay retained GPR evidence and source/ALI capacity terms, without tools.

This is a research component, not language admission or a whole-pipeline gate.
--main re-evaluates source-dependent arithmetic on another exact null source.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
I32, I64 = 2**31 - 1, 2**63 - 1
NULL = 'procedure main is pragma spark_mode ( on ) ; begin null ; end main ;'.split()
TOKEN = re.compile(rb'[ \t\r\n\v\f]+|--[^\r\n\v\f]*|[A-Za-z][A-Za-z_0-9]*|[();]')


def require(ok, message):
    if not ok:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def inputs():
    manifest = json.loads((HERE / 'manifest.json').read_bytes())
    files = {}
    for name, record in manifest['archives'].items():
        raw = (HERE / name).read_bytes()
        require(identity(raw) == record['archive'], 'changed archive: ' + name)
        with tarfile.open(HERE / name, 'r:gz') as tar:
            require(set(tar.getnames()) == set(record['members']), 'changed archive inventory')
            for member, meta in record['members'].items():
                data = tar.extractfile(member).read()
                require(identity(data) == {k: meta[k] for k in ('bytes', 'sha256')}, member)
                files[member] = data
    return files


def null_tokens(raw):
    require(raw and all(32 <= b <= 126 or b in (9, 10, 11, 12, 13) for b in raw),
            'outside selected ASCII null family')
    tokens, at = [], 0
    while at < len(raw):
        m = TOKEN.match(raw, at)
        require(m is not None, 'unsupported token')
        word = m[0]
        if not word.isspace() and not word.startswith(b'--'):
            tokens.append(word.decode('ascii').lower())
        at = m.end()
    require(tokens == NULL, 'not the selected null token sequence')


def line_capacity(lines):
    capacity = 500
    while capacity < lines:
        capacity *= 2
    return capacity


def shape(raw):
    # FF and VT end comments/logical lines but NOT GPR physical lines. Count
    # their byte columns; only CRLF, CR and LF reset the physical column.
    lines = re.split(rb'\r\n|[\r\n]', raw)
    largest = 1
    for line in lines:
        column = 1
        for byte in line:
            column = 8 * ((column - 1) // 8 + 1) + 1 if byte == 9 else column + 1
        largest = max(largest, column)
    return dict(bytes=len(raw), aligned_extent=4096 * ((len(raw) + 4096) // 4096),
                physical_line_entries_bound=len(lines), max_expanded_final_column=largest,
                line_capacity=line_capacity(len(lines)))


def arithmetic(sizes, lines, columns, ali_bytes=378):
    q = [4096 * ((n + 4096) // 4096) for n in sizes]
    caps = [line_capacity(n) for n in lines]
    # Order-independent sufficient bound, including one block increment past
    # the last represented range and every alignment addition.
    extent = sum(q)
    conditions = dict(source_lengths_and_EOF=all(0 <= n and n + 1 <= I32 for n in sizes),
        source_cursor_and_block_increment=extent - 1 <= I32 - 4096,
        source_buffer_individual_requests=all(n + 17 <= I64 for n in sizes),
        line_table_doubling_and_bits=all(32 * c <= I32 for c in caps),
        physical_columns=all(c <= 32766 for c in columns),
        ALI_reader_index_and_EOF=0 <= ali_bytes and ali_bytes + 1 <= I32)
    return dict(aligned_source_extent=extent, line_capacities=caps,
                ALI_buffer_bytes=ali_bytes + 1, conditions=conditions,
                all_selected_arithmetic_pass=all(conditions.values()))


def replay(main_path=None):
    files = inputs()
    results = {}
    for label in ('ordinary', 'retained-config'):
        result = json.loads(files[f'{label}/result.json'])
        require(result['returncode'] == 0 and result['retained_inputs_unchanged'], label)
        for name, meta in result['generated'].items():
            require(identity(files[f'{label}/work/{name}']) == meta, name)
        require(not files[f'{label}/stderr'], 'unexpected native diagnostic')
        inv = json.loads(files[f'{label}/invocation.json'])
        require(set(inv['environment']) == {'PATH', 'LC_ALL', 'TMPDIR'}, 'environment drift')
        require(inv['environment']['LC_ALL'] == 'C', 'locale drift')
        require(inv['argv'][-6:] == ['-cargs:Ada', '-gnatx', '-Wno-free-nonheap-object',
                                    '-largs', '-fno-lto', '-fno-use-linker-plugin'], 'options drift')
        events = [json.loads(line) for line in files[f'{label}/managed/events.jsonl'].splitlines()]
        require(any(x.get('event') == 'finished' and x.get('outcome') == 'success' for x in events),
                'managed success missing')
        binder = files[f'{label}/work/obj/b__main~1.o']
        require(identity(binder) == dict(bytes=13432,
            sha256='368b82296a24b933d1154f07b54bdad7af2f291302d4db23196f9d89128e2883'),
            'binder object differs')
        ali = files[f'{label}/work/obj/main~1.ali']
        records = [line for line in ali.split(b'\n') if line]
        counts = {letter: sum(x.startswith(letter.encode() + b' ') for x in records)
                  for letter in ('U', 'W', 'D', 'A')}
        require(counts == dict(U=1, W=0, D=2, A=9), 'ALI record population')
        require(len(ali) <= 378 and not any(x.startswith(b'X ') for x in records), 'ALI domain')
        results[label] = dict(duration_seconds=result['duration_seconds'],
                             ALI_bytes=len(ali), ALI_records=counts)
    require(files['ordinary/work/bin/main'] == files['retained-config/work/bin/main'],
            'retaining configuration changed executable')
    config = files['retained-config/work/selected.cgpr']
    # Inventory is justified in the source argument; reject accidental imports
    # in the retained fixture rather than infer it from only the file length.
    config_code = re.sub(rb'--[^\r\n]*', b'', config)
    require(not re.search(rb'\b(?:with|extends)\b', config_code, re.I), 'configuration imports')
    main = main_path.read_bytes() if main_path else files['retained-config/work/main.adb']
    null_tokens(main)
    physical = {'Main': main, 'project': files['retained-config/work/program.gpr'],
                'configuration': config}
    shapes = {name: dict(**identity(raw), **{k: v for k, v in shape(raw).items() if k != 'bytes'})
              for name, raw in physical.items()}
    calc = arithmetic([len(raw) for raw in physical.values()],
                      [r['physical_line_entries_bound'] for r in shapes.values()],
                      [r['max_expanded_final_column'] for r in shapes.values()])
    return dict(scope='selected native GPR source/ALI component with fixed-context projection',
                witnesses=results, physical_sources=shapes, source_files=3,
                Main_ALI_parser_population=dict(ALIs=1, Units=1, Withs=0, Sdep=2, Args=0),
                **calc, whole_pipeline_capacity_established=False)


def boundary_checks():
    # Arithmetic checks are intentionally independent of huge materializations.
    require(line_capacity(500) == 500 and line_capacity(501) == 1000, 'growth boundary')
    require(shape(b'A\r\nB\rC\nD')['physical_line_entries_bound'] == 4, 'CR/LF accounting')
    require(shape(b'\tA')['max_expanded_final_column'] == 10, 'tab accounting')
    require(shape(b'A\vB\fC')['max_expanded_final_column'] == 6, 'FF/VT physical column')
    require(not arithmetic([I32], [1], [1])['all_selected_arithmetic_pass'], 'EOF rejection')
    require(not arithmetic([1], [2**27], [1])['all_selected_arithmetic_pass'], 'growth rejection')
    require(not arithmetic([1], [1], [32767])['all_selected_arithmetic_pass'], 'column rejection')
    require(arithmetic([69, 411, 6816], [6, 15, 151], [30, 100, 512])[
            'all_selected_arithmetic_pass'], 'ordinary joined terms')


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--main', type=Path)
    p.add_argument('--output', type=Path)
    a = p.parse_args()
    boundary_checks()
    result = replay(a.main)
    text = json.dumps(result, indent=2, sort_keys=True) + '\n'
    if a.output:
        a.output.write_text(text)
    print(text, end='')
