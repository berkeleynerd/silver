#!/usr/bin/env python3
"""Focused read-only extraction from retained sources, disassembly and ELF."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import sys
import tarfile
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sp = importlib.util.spec_from_file_location('shared_elf_reader', HERE.parent/'builder-locals/freeze.py')
elf = importlib.util.module_from_spec(sp)
sp.loader.exec_module(elf)
INSN, elf_symbols = elf.INSN, elf.elf_symbols

ROOTS = {
    'Why3__Hashcons': 'hashcons_412 combine_434 combine_list_449 fun_591'.split(),
    'Why3__Ty': 'equal_2026 hash_2273 tag_2290 ty_equal_2001 ty_hash_2005'.split(),
    'Why3__Ity': 'equal_3511 hash_3762 tag_3788 pure_3786 ity_equal_3475 ity_hash_3481 restore_pv_14857'.split(),
    'Why3__Weakhtbl': 'tag_hash_287 hash_296 equal_299'.split(),
    'Why3__Wstdlib': 'equal_271 hash_275 equal_1826 tag_2176'.split(),
    'Why3__Term': ['tag_475'],
    'Why3__Ident': ['tag_2120'],
    'Why3__Exthtbl': ['fun_917'],
    'Stdlib__List': 'fold_left_521 for_all_581 for_all2_591'.split(),
    'Stdlib__Hashtbl': 'key_index_1028 find_rec_1053 find_1059 mem_1114 mem_in_bucket_1118 hash_1177'.split(),
    'Stdlib__Ephemeron': 'find_730 find_rec_721 key_index_668 equal_1252 get_key_1150 get_data_1170 hash_1334'.split(),
    'Stdlib__Weak': 'create_269 length_379 raise_if_invalid_offset_382 set_389 get_396 get_copy_400 check_404 blit_408 get_index_531 create_584 iter_bucket_687 fun_1086 count_bucket_691 loop_741 resize_745 add_weak_751 setter_756 add_aux_746 loop_770 find_or_781 loop_791 merge_795 fun_1147'.split(),
}
SPANS = {
    'src/core/ty.ml': [(16,33),(50,122),(278,289)],
    'src/mlw/ity.ml': [(19,76),(110,171),(182,185),(745,798)],
    'src/core/term.ml': [(17,39),(1037,1057)],
    'src/core/ident.ml': [(158,173)],
    'src/mlw/expr.ml': [(837,844),(938,951)],
    'src/util/hashcons.ml': [(14,62)],
    'src/util/weakhtbl.ml': [(50,85)],
    'src/util/wstdlib.ml': [(13,22),(45,100)],
    'src/util/exthtbl.ml': [(38,58)],
}
OCAML_SPANS = {
    'stdlib/weak.ml': [(18,66),(98,128),(159,294)],
    'stdlib/ephemeron.ml': [(92,137),(157,158),(241,268),(483,560)],
    'stdlib/hashtbl.ml': [(344,355),(381,399),(448,454),(477,484)],
    'stdlib/list.ml': [(117,123),(160,190)],
}


def sha(raw): return hashlib.sha256(raw).hexdigest()
def write(name, value): (HERE/name).write_text(json.dumps(value, indent=2)+'\n')


def main():
    prior = json.loads((HERE.parent/'builder-locals/native-witnesses.json').read_text())
    binary = Path(prior['executable']['path']).read_bytes()
    assert sha(binary) == prior['executable']['identity']['sha256']
    dis = Path(prior['existing_disassembly']['path']).read_bytes()
    assert sha(dis) == prior['existing_disassembly']['sha256']
    bodies = {n:b for b,n in re.findall(r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)',dis.decode(),re.S)}
    symbols = elf_symbols(binary)
    selected = {'caml'+unit+'__'+n for unit,ns in ROOTS.items() for n in ns}
    missing = selected-set(bodies)
    if missing: raise ValueError(sorted(missing))
    address_names = {v[0]:n for n,v in symbols.items() if n in bodies}
    closures = {}
    # The only additional constant callback closure in this selected set is
    # Ity.pure. Fixed adapters already have accepted predecessor evidence.
    for n in sorted(selected):
        for ref in re.findall(r'<([^>+]+)(?:\+[^>]+)?>',bodies[n]):
            if not re.fullmatch(r'camlWhy3__\w+__\d+',ref) or ref not in symbols: continue
            addr,_,pos = symbols[ref]
            header = struct.unpack_from('<Q',binary,pos-8)[0]
            if header & 255 != 247: continue
            size = 8*(header>>10)
            assert 16 <= size <= 512
            targets = [address_names.get(struct.unpack_from('<Q',binary,pos+i)[0]) for i in range(0,size,8)]
            targets = sorted({x for x in targets if x})
            closures[ref] = {'address':addr,'header':header,'size':size,'targets':targets}
    chosen = {n:bodies[n] for n in sorted(selected)}
    write('native-bodies.json',chosen)
    write('native-witnesses.json',{
        'executable':prior['executable'],'existing_disassembly':prior['existing_disassembly'],
        'selected_bodies':sorted(selected),'constant_closures':closures,
        'external_code_references':sorted({r for body in chosen.values() for r in re.findall(r'<([^>+]+)(?:\+[^>]+)?>',body) if r in bodies and r not in chosen}),
        'source_callback_mapping':'source-joins.json',
        'new_disassembler_or_target_execution':False,
        'machine_checked_source_native_refinement':False,
    })
    sources=[]
    for archive,spans in [(elf.WHY,SPANS),(elf.OCAML,OCAML_SPANS)]:
        item={'path':archive,'sha256':sha((ROOT/archive).read_bytes()),'files':[]}
        with tarfile.open(ROOT/archive) as t:
            for name,ranges in spans.items():
                matches=[n for n in t.getnames() if n==name or n.endswith('/'+name)]
                assert len(matches)==1,(name,matches)
                raw=t.extractfile(matches[0]).read();lines=raw.decode().splitlines()
                ss=[]
                for first,last in ranges:
                    code='\n'.join(lines[first-1:last])+'\n'
                    ss.append({'first':first,'last':last,'sha256':sha(code.encode()),'source':code})
                item['files'].append({'path':matches[0],'sha256':sha(raw),'spans':ss})
        sources.append(item)
    write('source-witnesses.json',sources)
    print(json.dumps({'selected_bodies':len(selected),'constant_closures':len(closures)}))


if __name__ == '__main__': main()
