#!/usr/bin/env python3
"""Source-sensitive literal GAS/ELF interface; no native execution or full verdict."""
import hashlib
import json
from pathlib import Path
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


class Context:
    def __init__(self):
        rows = json.loads((HERE/'inputs.json').read_bytes())
        for row in rows:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')}, row['path'])
        self.input_count = len(rows)
        packet = HERE.parent/'retained-assembler-capacity-20261018'
        manifest = json.loads((packet/'source-manifest.json').read_bytes())
        require(manifest['commit'] == '5e56594815854de5eca35c7c04b11705d0f19c02',
                'Binutils source identity')
        sources = {}
        with tarfile.open(packet/'sources.tar.gz') as archive:
            require(sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files']),
                    'source archive inventory')
            for row in manifest['files']:
                raw = archive.extractfile(row['path']).read()
                require(identity(raw) == {k:row[k] for k in ('bytes','sha256')}, row['path'])
                sources[row['path']] = raw.decode()
        self.source_count = len(sources)
        # Identity/landmark checks support the separately reviewed source argument.
        # They are not a machine proof of GAS reachability.
        for name, anchors in {
            'gas/config/tc-i386.c': [
                'OPERAND_TYPE_IMM32_32S_DISP32, false },',
                'if (gotrel[j].need_GOT_symbol && GOT_symbol == NULL)',
                'tmpbuf = XNEWVEC (char, first + second + 2);',
                'p = frag_more (i.opcode_length + size);',
                'else if (i.base_reg->reg_num == RegIP)',
                'fixP = fix_new_exp (frag_now, p - frag_now->fr_literal,'],
            'gas/write.c': ['int region;', 'fragP->region = region;', 'region += 1;'],
            'gas/input-scrub.c': ['static unsigned int physical_input_line;',
                                 'physical_input_line = 0;', '++physical_input_line;'],
            'gas/read.c': ['unsigned long num_octets = 0;', 'decode_base64_and_append (b, i);'],
            'opcodes/i386-opc.tbl': ['lea, 0x8d,', 'call, 0xe8, x64,'],
        }.items():
            for anchor in anchors:
                require(anchor in sources[name], name+': '+anchor)
        native = HERE.parent/'unbounded-programs/retained-native-expansion-20261017'
        self.recognize = runpy.run_path(str(native/'derive-literal-output.py'))['source_counts']


def interface(c, n, w, maximum_literal_length):
    """Mathematical internal transfer, supplied only by evaluate's source scan."""
    require(all(type(v) is int and v >= 0 for v in (c,n,w,maximum_literal_length)) and c >= 1,
            'natural counts and at least one output call')
    require(maximum_literal_length <= w <= c*maximum_literal_length,
            'consistent literal lengths')
    chain, text = 7*c+7*n+45, 31*c+4*n+22
    lines = 114+chain+w+8*c
    reservation = 433+max(0,text-26)+w+10*c
    frags = 2*reservation+2*c+62
    gas_symbols = chain+2*c+93
    symbols, relocations = gas_symbols+9, 3*c+281
    symbol_strings = 1+26*(symbols-1)
    section_strings = 1+32*23
    payload = text+w+22*c+394
    file_parts = dict(header=64, ordinary_payload=payload, symbols=24*symbols,
                      relocations=24*relocations, symbol_strings=symbol_strings,
                      section_strings=section_strings, alignment_padding=26*7,
                      section_headers=24*64)
    object_bytes = sum(file_parts.values())
    checks = dict(
        literal_length=maximum_literal_length <= I32,
        backend_chain=chain+1 <= I32,
        text_and_CFI=text <= I32,
        physical_lines=lines+1 <= U32,
        fragment_counter=frags <= U32,
        region=max(10,2*c+1) <= 65535,
        symbol_indices=symbols <= I32,
        fixup_and_relocation_counts=relocations <= U32,
        symbol_string_offsets=symbol_strings <= U32,
        section_string_offsets=section_strings <= U32,
        object_offsets=object_bytes <= I64,
        symbol_record_requests=40*symbols <= I64,
        relocation_record_requests=24*relocations <= I64,
        string_sort_pointer_requests=8*symbols <= I64,
    )
    return dict(
        counts=dict(calls=c,nulls=n,decoded_bytes=w,maximum_literal_length=maximum_literal_length),
        final_chain=chain, text_bytes_upper=text,
        assembly=dict(lines_upper=lines,bytes_upper=7410+65*chain+13*w+512*c,
                      longest_line_excluding_LF_upper=512,scrub_buffer_bytes_upper=65539),
        GAS=dict(ordinary_sections_upper=10,initial_chains_upper=14,
                 final_alignment_events_upper=12,rodata_bytes_upper=w+22*c,
                 reservation_bytes_upper=reservation,fragment_allocations_upper=frags,
                 each_fragment_chunk_bytes_upper=4064,maximum_region_upper=max(10,2*c+1),
                 symbol_allocations_upper=gas_symbols,output_symbols_upper=gas_symbols-2,
                 BFD_symbol_allocations_upper=gas_symbols+15,fixups_upper=3*c+279,
                 relocations_upper=relocations,GOT_symbol_required=False,
                 symbol_name_bytes_including_NUL_upper=26),
        ELF=dict(section_headers_upper=24,symbols_including_null_upper=symbols,
                 symbol_string_names_upper=symbols-1,section_string_names_upper=23,
                 symbol_string_positive_references_upper=symbols-1,
                 section_string_positive_references_upper=46,
                 file_parts=file_parts,object_bytes_upper=object_bytes),
        local_checks=checks,local_interface_fits=all(checks.values()),
        open_joins=['GAS_subsidiary_lifetimes_and_hash_growth','BFD_arena_and_string_table_growth',
                    'production_invocation','fixed_objects_and_binder','final_link_reach'],
        whole_literal_pipeline_capacity_established=False,native_tool_executions=0)


def evaluate(raw, context):
    require(all(32 <= b <= 126 or b in (9,10,13) for b in raw),
            'current ASCII source alphabet')
    counts = context.recognize(raw)
    result = interface(counts['output_calls'],counts['null_statements'],
                       counts['decoded_literal_bytes'],counts['maximum_literal_length'])
    result['source_identity'] = identity(raw)
    return result
