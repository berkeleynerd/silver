#!/usr/bin/env python3
"""Source-derived literal output-link representation predicate, conditional on
the accompanying source argument and selected descriptor. No native execution.
"""
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import runpy
import struct
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
U32, I32, I64 = 2**32-1, 2**31-1, 2**63-1


def require(value, message):
    if not value:
        raise ValueError(message)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read_functions(raw, names, namespace):
    """Reuse pure ELF readers from pinned, otherwise CLI-only predecessor code.

    Execute only the named function definitions, never its CLI or native/file
    inventory loop. This extraction is checked against the pinned complete file.
    """
    nodes = [n for n in ast.parse(raw).body
             if isinstance(n, ast.FunctionDef) and n.name in names]
    require({n.name for n in nodes} == set(names), 'predecessor reader definitions')
    exec(compile(ast.Module(body=nodes, type_ignores=[]), '<pinned readers>', 'exec'),
         namespace)
    return namespace


class Context:
    def __init__(self):
        self.records, self.raw = {}, {}
        rows = json.loads((HERE/'inputs.json').read_bytes())
        for row in rows:
            raw = (REPO/row['path']).read_bytes()
            require(identity(raw) == {k:row[k] for k in ('bytes','sha256')}, row['path'])
            self.raw[row['key']] = raw
            if row['path'].endswith('.json'):
                self.records[row['key']] = json.loads(raw)
        self.input_count = len(rows)
        manifest = json.loads((HERE/'sources.json').read_bytes())
        require(identity((HERE/'sources.tar.gz').read_bytes())['sha256'] ==
                manifest['archive_sha256'], 'source archive')
        self.sources = {}
        with tarfile.open(HERE/'sources.tar.gz') as archive:
            require(sorted(archive.getnames()) == sorted(r['path'] for r in manifest['files']),
                    'source inventory')
            for row in manifest['files']:
                raw = archive.extractfile(row['path']).read()
                require(identity(raw) == {k:row[k] for k in ('bytes','sha256')}, row['path'])
                self.sources[row['path']] = raw.decode()
                predecessor = (self.records['source_cache_manifest']['files']
                               + self.records['source_input_manifest'])
                prior = next(r for r in predecessor if r['path']==row['path'])
                require(all(row[k]==prior[k] for k in ('bytes','sha256')),
                        row['path']+': predecessor source correspondence')
        # These landmarks detect stale evidence; the document supplies the
        # semantic argument. They do not prove it by matching source strings.
        for name, anchors in {
            'lto-plugin/lto-plugin.c': [
                'if (!startswith (name, ".gnu.lto_.symtab"))',
                'if (startswith (name, ".gnu.offload_lto_.opts"))',
                'if (obj.found == 0 && !obj.offload)',
                'if (num_claimed_files + num_offload_files == 0)'],
            'ld/plugin.c': ['if (claimed)', 'ibfd->plugin_format = bfd_plugin_no;',
                            'bfd_close_all_done (abfd);'],
            'ld/ldlang.c': ['if (link_info.lto_plugin_active)',
                           'if (added.head != NULL)'],
            'bfd/elflink.c': ['if (info->lto_plugin_active',
                             'h->root.non_ir_ref_regular = 1;'],
        }.items():
            for anchor in anchors:
                require(anchor in self.sources[name], name+': '+anchor)
        self.asm = runpy.run_path(str(HERE.parent/'retained-literal-assembler-20261018/storage.py'))
        self.asm_context = self.asm['Context']()
        self.delta = self.records['delta']
        require(self.records['null']['selected_null_link_representation_closed'], 'null prerequisite')
        require(not self.delta['historical_output_link_witness_used_explicit_no_plugin'],
                'historical witness must remain distinguished')
        self.fixed_projection = self.inspect_generated()

    def inspect_generated(self):
        packet = HERE.parent/'retained-linker-output-delta-20261018'
        manifest = self.records['delta_manifest']['artifacts']
        require(identity((packet/'artifacts.tar.gz').read_bytes()) ==
                {k:manifest[k] for k in ('bytes','sha256')}, 'fixed output artifacts')
        wanted = ['indexed/obj/silver_io.o', 'indexed/obj/silver_output_libc.o',
                  'indexed/obj/b__main~1.o', 'objects/literal-proposed/main.o']
        objects = {}
        with tarfile.open(packet/'artifacts.tar.gz') as archive:
            for name in wanted:
                row = next(r for r in manifest['members'] if r['path'] == name)
                raw = archive.extractfile(name).read()
                require(identity(raw) == {k:row[k] for k in ('bytes','sha256')}, name)
                objects[name] = raw
        parse = read_functions(self.raw['delta_checker'], ['elf'],
                               dict(struct=struct, sha=lambda b: identity(b)['sha256']))['elf']
        ns = read_functions(self.raw['unwind_checker'],
                            ['leb','width','scan_cfa','inspect_eh'],
                            dict(struct=struct, eh_summary=Counter(), eh_rows=[]))
        summaries, externals = {}, {}
        fixed_names = set()
        K = 2019040
        for name, raw in objects.items():
            parsed = parse(raw)
            syms, secs = parsed['symbols'], parsed['sections']
            require(not any(s['name'].startswith(('.gnu.lto_', '.gnu.offload_lto_'))
                            for s in secs), name+': no plugin claiming section')
            ext = [s for s in syms if s['binding'] != 0]
            externals[name] = ext
            if name.endswith('main.o'):
                require([(s['name'],s['binding'],s['type'],s['visibility'],s['value'])
                         for s in ext] == [('_ada_main',1,2,0,0),
                                           ('silver_io__put',1,0,0,0)],
                        'literal witness external projection')
                continue
            for s in syms:
                require(s['section'] not in (0xfff2,0xff02,0xffff), 'ordinary symbols')
                if s['section'] in (0,0xfff1):
                    require(s['value'] == 0, 'zero undefined/ABS value')
                else:
                    require(s['value'] <= secs[s['section']]['bytes'], 'defined symbol offset')
            for s in ext:
                if s['section']:
                    fixed_names.add(s['name'])
            for r in parsed['relocations']:
                require(r['type'] in (1,2,4), 'extra fixed relocation domain')
                require(abs(r['addend']) <= K, 'fixed addend bound')
                target = next(s for s in secs if s['name'] == r['section'])
                require(r['offset']+(8 if r['type']==1 else 4) <= target['bytes'],
                        'complete relocation field')
            shoff = struct.unpack_from('<Q', raw, 40)[0]
            hs = [struct.unpack_from('<IIQQQQIIQQ', raw, shoff+64*i)
                  for i in range(len(secs))]
            tables = {i:[struct.unpack_from('<IBBHQQ',raw,p)
                         for p in range(h[4],h[4]+h[5],24)]
                      for i,h in enumerate(hs) if h[1] in (2,11)}
            ns['inspect_eh'](raw,name,hs,tables,[s['name'] for s in secs],name)
            summaries[name] = dict(symbols=len(syms), sections=len(secs),
                relocations=len(parsed['relocations']),
                property_bytes=sum(s['bytes'] for s in secs if s['name']=='.note.gnu.property'),
                merge_bytes=sum(s['bytes'] for s in secs if s['flags']&0x10))
        require('_ada_main' not in fixed_names, 'no competing Main definition')
        binder_main = [s for s in externals['indexed/obj/b__main~1.o'] if s['name']=='_ada_main']
        require(len(binder_main)==1 and all(binder_main[0][k]==0
                for k in ('section','value','bytes','type','visibility')), 'binder Main reference')
        eh = ns['eh_summary']
        require(eh['CFA_set_loc']==0 and eh['zero_ranges']==0, 'ordinary nonempty fixed FDEs')
        require({k:v for k,v in eh.items() if k.startswith('CIE_')} ==
                {'CIE_R_encoding_0x1b':2}, 'fixed generated CIE address encodings')
        require(eh['indexed/obj/b__main~1.o_FDEs']==6 and
                eh['indexed/obj/silver_io.o_FDEs']==2, 'additional FDE counts')
        return dict(objects=summaries, EH=dict(eh), FDE_ranges=ns['eh_rows'],
                    Main_external_witness=externals['objects/literal-proposed/main.o'])


def link(base, context, host_page_bytes):
    require(type(host_page_bytes) is int and host_page_bytes>0 and
            host_page_bytes & (host_page_bytes-1)==0, 'positive power-of-two host page size')
    g = host_page_bytes
    main, gas = base['ELF'], base['GAS']
    c = base['counts']['calls']
    Y, Ttext = main['symbols_including_null_upper'], base['text_bytes_upper']
    # Section payload includes NOBITS, but neither ELF headers nor file padding.
    main_original = sum(v for k,v in main['file_parts'].items()
                        if k not in ('header','alignment_padding','section_headers'))
    off = context.delta['symbolic_link_offsets']
    R, Q, P = off['R']+Y, off['Q']+24, off['P']
    Qrel, Trel = off['Qrel']+10, off['Trel']+gas['relocations_upper']
    Vdef, assignments = 51, 16
    H = 3*R+2*Q+Vdef+21
    I = Q+Qrel+3*P+35
    S, N, T = I+93, I+98, 3*(I+93)+13
    J = 8*R+11*H+2*assignments+Vdef+2*I+2*S
    D, Z = H+1+J, R+P+S+3*H+2
    generated_names = Y-1+23+285
    generated_bytes = 26*(Y-1)+32*23+6020
    dynstr = 1569550+generated_bytes+169
    ordinary_strings, section_strings = 1+197*Z, 1+183*(3*S+4)
    k = H.bit_length()
    m = max(6, 5 if k<3 else k+(3 if H & (1<<(k-2)) else 2))
    bloom = 1<<(m-6)
    # Fixed/Main/PLT already in nonbinder; replace only old binder and add IO.
    EHentries, EHbytes, FDEs = 16326+7+3, 551828+224+96, 14952+6+2
    EH = 743204+224+11*7+10+96+11*3+10
    EHheader = 12+8*FDEs
    # Only external symbols reach global size assignment. Main's defined
    # external is its sole function; the two possible undefined imports are 0.
    copy = 4*(8850737+12701+Ttext)+63*H
    extras = context.fixed_projection['objects']
    merge_generated = 31+sum(o['merge_bytes'] for o in extras.values())
    property_generated = sum(o['property_bytes'] for o in extras.values())
    rec = context.records
    payloads = dict(original_sections=off['original_payload']+main_original,
        full_fixed_merge_output=rec['fixed']['fixed_merge_output_payload_upper'],
        full_generated_merge_output=merge_generated,
        full_EH_edited_output_including_PLT_templates=EH, EH_header=EHheader,
        full_property_rewrite=296+property_generated, copy_storage=copy,
        interpreter=28, dynsym=24*D, versym=2*D, SysV_hash=4*(2+32771+D),
        GNU_hash=4*(4+32771+H)+8*bloom, ordinary_symtab=24*Z,
        optional_symtab_indices=4*Z, ordinary_strtab=ordinary_strings,
        shstrtab=section_strings,
        GOT_PLT_and_dynamic_relocations_including_copy_relocations=208*H+104*R+24*Trel+104,
        dynamic_tags=rec['dynamic']['dynamic_table_bytes_upper'], dynstr=dynstr,
        version_definitions=rec['versions']['version_definition_bytes_if_W_zero'],
        version_requirements=rec['versions']['version_need_bytes_upper'])
    B = sum(payloads.values())
    A = 4096  # selected layout alignment, independent of the host mmap page G
    padding, Hfile = (I+S+5)*(A-1)+32768, 64+56*T
    V = Hfile+B+padding
    F = Hfile+(S+1)*(V+A)+4*(B+padding)+(3*N+5)*A+64*N
    conditions = dict(
        assembler_interface=base['local_interface_fits'],
        dynamic_section_index=S<0xff00,
        external_section_header_product=64*N<=U32,
        external_program_header_product=56*T<=U32,
        dynamic_symbol_count=1<=D<=U32,
        global_hash_domain=H<=805306341,
        GNU_hash_signed_shift=m<=30,
        ordinary_symbol_uint32_product=Z<=rec['symtab']['output_symbol_uint32_product_limit'],
        ordinary_string_bytes=ordinary_strings<=2**32,
        dynstr_bytes=dynstr<=2**32, dynstr_names=72100+generated_names<=805306341,
        dynstr_positive_references=J+Vdef+152<=U32,
        section_string_bytes=section_strings<=2**32,
        section_string_references=6*S+7<=U32,
        section_string_table_product=64*(3*S+5)<=U32,
        version_index=rec['global']['maximum_version_index_under_that_premise_upper']<=32767,
        PLT_jump_count=H<=536870911,
        property_writer_size=payloads['full_property_rewrite']<=U32,
        EH_edit_size=EH<=U32, EH_FDE_count=FDEs<=536870911,
        EH_function_range=Ttext<=I32,
        trial_address_arithmetic=2*V+A<=I64, file_offset_arithmetic=F+A<=I64,
        fixed_signed_relocation_reach=2*V+2019040+15<=I32,
        fixed_unsigned_relocation_reach=V+293932<=U32,
        Main_PC32_PLT32_reach=V+4<=I32,
        EH_signed_fields=V+2019040<=I32,
        PLT_relocation_index=H+R<=U32,
        PLT_range_fields=B<=U32)
    fixed = rec['fixed']['processed_fixed_totals']
    merge_entries = fixed['merge_entries']+merge_generated
    merge_bytes = fixed['merge_entry_bytes']+merge_generated
    merge_capacity, order_capacity, start_capacity = 8192, 64, 0
    while merge_entries>merge_capacity//3*2:
        merge_capacity *= 2
    while order_capacity<I:
        order_capacity *= 2
    start_entries = 2*(I+S)
    while start_capacity<start_entries:
        start_capacity=2*start_capacity+10
    cie_capacity = next(p for p in context.asm_context.gas_primes if p>=2*EHentries)
    hash_capacity = next((p for p in context.asm_context.bfd_primes if H<=3*p//4),None)
    requests = dict(link_order=16+16*order_capacity, mapper=8*S, segment_map=80+8*S,
        final_PHDRs=12*(64+8), header_pointers=8*N, internal_header=80,
        merge_bucket=8*merge_capacity, merge_entry=32+merge_bytes,
        merge_copy=2*merge_bytes, merge_offset_map=4*(merge_entries+2048),
        merge_entry_map=8*(merge_entries+2048), merge_fast_lookup=4*(merge_bytes//32+1),
        merge_sort=8*merge_entries, merge_padding=64,
        EH_entry_info=16+64*EHentries, EH_local_CIE=256*EHentries,
        EH_CIE=256, EH_hash_control=128, EH_hash_backing=8*cie_capacity,
        EH_set_loc=4*(EHbytes+1), EH_search=24*FDEs,
        final_content_scratch=max(4*g,B+7), external_relocations=max(4*g,24*Trel),
        internal_relocations=24*Trel, external_symbols=24*max(R,20),
        internal_symbols=32*max(R,20), symbol_indices_or_pointers=8*max(R,20),
        local_extended_indices=4*R, output_symbol_cache=40*max(R,20,2*Z),
        output_symbols=24*Z, output_extended_indices=4*Z,
        Main_header_array=80*24, Main_header_pointers=8*24, Main_creation_flags=24,
        input_mmap_span=B+2*g, start_stop_pointers=8*start_capacity,
        section_check_array=16*S, explicit_PHDR_pointer_array=80,
        global_hash_entry=512, global_hash_name=197,
        global_hash_backing=0 if hash_capacity is None else 8*hash_capacity,
        global_hash_snapshot=0 if hash_capacity is None else 8*hash_capacity+1040*H)
    # Every BFD string-table consumer has its own capacity and backing request.
    string_tables = {}
    for role, distinct in [('dynstr',72100+generated_names),('ordinary',Z),
                           ('sections',3*S+4)]:
        cap = next((p for p in context.asm_context.bfd_primes
                    if p>=4051 and distinct<=3*p//4),None)
        slots = max(64,1<<distinct.bit_length())
        conditions[role+'_string_growth'] = (cap is not None and 3*cap<=U32
                                              and slots<=2**30)
        requests[role+'_string_hash'] = 0 if cap is None else 8*cap
        requests[role+'_string_array'] = 8*slots
        requests[role+'_string_sort'] = 8*(distinct+1)
        string_tables[role] = dict(distinct_names=distinct,hash_capacity=cap,array_slots=slots)
    bfd_ids = 2*(P+2*65+2*15+1)
    section_ids = 16+2*(Q+I+S)
    conditions.update(
        BFD_object_ID=bfd_ids<=U32, BFD_section_ID=section_ids<=U32,
        merge_offset_and_capacity=merge_entries+2048<=U32 and merge_capacity<2**31,
        shared_counts=all(v<I32 for v in (I,S,N,R,Z,Trel,EHentries,EHbytes,FDEs,
                                         order_capacity,start_entries,start_capacity)),
        global_hash_capacity=hash_capacity is not None and hash_capacity<=1073741789,
        individual_requests=all(0<n and max(4064,n+23)<=I64 for n in requests.values()),
        host_page_arithmetic=4*g<=I64,
        Main_file_reader=main['object_bytes_upper']<=I64)
    return dict(counts=dict(R=R,Q=Q,P=P,Qrel=Qrel,Trel=Trel,H=H,I=I,S=S,N=N,T=T,J=J,D=D,Z=Z),
        Main_original_section_bytes=main_original,
        Main_external_size_sum_upper=Ttext, Main_instruction_relocations=dict(PC32=2*c,PLT32=c),
        generated_names=dict(occurrences=generated_names,NUL_bytes=generated_bytes),
        payload_components=payloads,payload_union_bytes=B,
        layout=dict(alignment=A,padding=padding,headers=Hfile,retained_endpoint=V,
                    trial_endpoint=2*V,file_endpoint=F),
        relocation_bounds=dict(common_signed32=2*V+2019040+15,Main_PC32_PLT32=V+4,
                               unsigned32=V+293932,EH_relative=V+2019040),
        EH=dict(entries=EHentries,original_bytes=EHbytes,FDEs=FDEs,edited_bytes=EH),
        administrative=dict(BFD_object_ID_events=bfd_ids,BFD_section_ID_highwater=section_ids,
            start_stop_capacity=start_capacity,statement_iterations=16,sizing_iterations=9,
            mapping_iterations=2,output_statement_hash_keys=S+1),
        host_page_bytes=g,individual_request_upper_bytes=requests,string_tables=string_tables,
        checks=conditions,failed_sufficient_checks=[k for k,v in conditions.items() if not v],
        selected_output_link_representation_fits=all(conditions.values()))


def evaluate(raw, context, path_bytes=512, host_page_bytes=4096):
    upstream = context.asm['evaluate'](raw,context.asm_context,path_bytes=path_bytes)
    result = link(upstream['interface'],context,host_page_bytes)
    storage_fits = upstream['storage']['selected_GAS_BFD_storage_fits']
    return dict(source_identity=identity(raw),counts=upstream['interface']['counts'],
        assembler_interface_fits=upstream['interface']['local_interface_fits'],
        assembler_storage_fits=storage_fits,link=result,
        selected_literal_assembler_and_linker_representation_fits=(storage_fits and
                  result['selected_output_link_representation_fits']),
        source_argument_required=True,independent_review_accepted=False,
        selected_no_LTO_no_plugin_descriptor=True,
        historical_output_witness_was_exact_descriptor=False,
        source_no_plugin_compatibility_transfer=True,
        conditions_of_claim=[
            'retained sources describe the selected installed tools relevant behavior',
            'selected ELF64 x86-64 LP64 no-LTO/no-plugin descriptor and fixed lookup outcomes',
            'accepted literal Main emission/object/storage and fixed library/binder projections',
            'retained null generic linker contracts with the substitutions documented here',
            'manual no-plugin, external-resolution, relocation and EH source arguments',
            'separate filesystem, path, host-page, allocation, stack and I/O resource premises'],
        production_admission_rule=False,
        whole_literal_pipeline_capacity_established=False,
        aggregate_RAM_gate=False,physical_resource_guarantee=False,
        open_joins=['production_invocation_and_materialization',
                    'other_producer_compiler_and_binder_phases','whole_pipeline_composition'],
        native_tool_executions=0)
