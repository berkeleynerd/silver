#!/usr/bin/env python3
"""Variable literal GAS/BFD storage joins; selected invocation remains a premise."""
import json
from pathlib import Path
import re
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
BASE = runpy.run_path(str(HERE/'compose.py'))
require, identity = BASE['require'], BASE['identity']
I64, U64 = 2**63-1, 2**64-1


class Context:
    def __init__(self):
        self.base = BASE['Context']()
        rows = json.loads((HERE/'storage-inputs.json').read_bytes())
        for row in rows:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')},row['path'])
        self.inputs = len(rows)
        packet=HERE.parent/'retained-assembler-capacity-20261018'
        with tarfile.open(packet/'sources.tar.gz') as archive:
            hashtab=archive.extractfile('libiberty/hashtab.c').read().decode()
            bfd_hash=archive.extractfile('bfd/hash.c').read().decode()
        table=hashtab.split('prime_tab[] =',1)[1].split('};',1)[0]
        self.gas_primes=[int(s,0) for s in re.findall(r'\{\s*(0x[0-9a-f]+|[0-9]+),',table)]
        self.bfd_primes=[int(s) for s in re.findall(r'UINT32_C \((\d+)\)',bfd_hash)]
        require(self.gas_primes[-2:] == [2**31-1,2**32-5], 'GAS prime table')
        require(self.bfd_primes[-2:] == [2**31-1,2**32-5], 'BFD prime table')
        extra=json.loads((packet/'inner-source-manifest.json').read_bytes())
        with tarfile.open(packet/'inner-sources.tar.gz') as archive:
            for row in extra['files']:
                raw=archive.extractfile(row['path']).read()
                require(identity(raw)=={k:row[k] for k in ('bytes','sha256')},row['path'])
        self.extra_sources=len(extra['files'])


def storage(base, context, path_bytes):
    require(type(path_bytes) is int and path_bytes>=1,'positive NUL-inclusive path bound')
    s=base['GAS']['symbol_allocations_upper']
    r=base['GAS']['relocations_upper']
    y=base['ELF']['symbols_including_null_upper']
    cap=next((p for p in context.gas_primes if p>=max(1024,2*s)),None)
    q=max(65528,8*r,8*(s-2),48,path_bytes)
    notes=max(4064,q+250)
    bfd_parts=dict(path=path_bytes,object_data=4096,output_data=192,
        section_data=14*320,symbols=128*(s+15),relocation_headers=10*80,
        relocation_names=10*32,header_pointers=24*8,null_header=80,
        section_symbol_map=14*8,reordered_symbol_pointers=8*(s+8),
        relocation_buffers=24*r,serialized_section_headers=24*64)
    bfd_total=sum(bfd_parts.values())
    bfd_largest=max(path_bytes,4096,8*(s+8),24*r,24*64)
    strings=[]
    for role,d,length,refs in [('symbols',y-1,26,y-1),('sections',23,32,46)]:
        # Starting default and strict 75%-threshold growth from bfd/hash.c.
        capacities=[4051]
        while d>3*capacities[-1]//4:
            following=next((p for p in context.bfd_primes if p>capacities[-1]),None)
            if following is None:
                break
            capacities.append(following)
        array=max(64,1<<d.bit_length())
        checks=dict(distinct_names=d<=805306341,
            unshared_name_bytes=1+d*length<=2**32,
            positive_references=refs<=2**32-1,
            growth_no_wrap=3*capacities[-1]<=2**32-1 and d<=3*capacities[-1]//4,
            array_slots=array<=2**30,
            individual_requests=max(8*capacities[-1],8*array,8*(d+1),96)+23<=I64)
        strings.append(dict(role=role,distinct_names_upper=d,
            bytes_per_name_including_NUL_upper=length,positive_reference_events_upper=refs,
            hash_capacities=capacities,each_hash_entry_bytes_upper=64,
            hash_name_copies=0,pointer_array_capacity_upper=array,
            sorting_array_bytes_upper=8*(d+1),checks=checks))
    checks=dict(local_interface=base['local_interface_fits'],
        symbol_hash_prime_and_probe=cap is not None and 2*cap-3<=2**32-1,
        symbol_hash_array=cap is not None and 8*cap<=I64,
        notes_growth=notes<=I64,
        frchains_single_chunk=32+14*(192+15)<=4064,
        BFD_individual_requests=bfd_largest+23<=I64,
        BFD_lifetime_counter=bfd_total<=U64,
        ELF_string_tables=all(all(t['checks'].values()) for t in strings))
    return dict(path_bytes=path_bytes,assembler_argv_count=5,
        symbol_hash_capacity_upper=cap,symbol_hash_array_bytes_upper=None if cap is None else 8*cap,
        notes_request_bytes_upper=q,notes_unfinished_prefix_upper=120,
        notes_chunk_bytes_upper=notes,parser_scratch_bytes_upper=67,
        frchain_objects_upper=14,frchains_initial_chunks=1,
        BFD_main_arena_parts=bfd_parts,BFD_main_arena_raw_lifetime_bytes_upper=bfd_total,
        BFD_largest_main_arena_request_upper=bfd_largest,
        BFD_section_hash_capacities=[13,31],ELF_string_tables=strings,
        local_checks=checks,selected_GAS_BFD_storage_fits=all(checks.values()),
        whole_literal_pipeline_capacity_established=False,aggregate_RAM_gate=False,
        open_joins=['production_invocation','fixed_objects_and_binder','final_link_reach'],
        native_tool_executions=0)


def evaluate(raw, context, path_bytes=512):
    base=BASE['evaluate'](raw,context.base)
    return dict(interface=base,storage=storage(base,context,path_bytes))
