#!/usr/bin/env python3
"""Freeze new read-only source/native witnesses from retained inputs."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
WHY='docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz'
OCAML='docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
PRIOR='docs/evidence/retained-why-save-shape-builder-allocation-20261020/native-witnesses.json'
INSN=re.compile(r'^\s*([0-9a-f]+):\s*((?:[0-9a-f]{2}(?:\s+|$))+)')

# These are finite witness supersets. The source partition, not membership
# in this set, decides which branches run. Shared owner services are cut.
ROOTS={
 'Ity':'''ity_equal its_equal reg_equal pv_equal mk_ity ity_app_unsafe
 ty_of_ity dfold dfold2 its_arg_fold its_reg_fold its_fold
 ity_v_fold ity_freevars ity_closed ity_exp_fold its_exp_fold reg_exp_fold
 ity_exp_regs reg_rch_regs ity_rch_regs reg_unc_fold ity_unc_fold ity_r_stale
 ity_rch_vars fold_on_frz ity_frz_fold ity_r_frozen ity_vis_fold its_vis_fold
 fn_4298 fn_4396 fn_4519
 reg_vis_fold ity_full_inst add_or_keep ity_match reg_match ity_freeze
 its_match_args its_match_regs its_check_args its_match_smart ity_app_raw
 ity_app ity_tuple freeze_pv pvs_of_vss t_freepvs restore_pv
 mask_reduce mask_check mask_adjust check_writes check_covers check_taints
 visible_writes reset_taints eff_ghostify eff_read_pre eff_read_post eff_bind
 eff_read read_regs eff_escape add_xs_7207 add_write_7212 add_fd_7218
 cty_unsafe spec_t_fold fn_l check_tvs add_pv_7394 add_xs_7400 check_pre
 check_post create_cty create_cty_inner create_cty_defensive cty_apply
 vsb_add match_v apply_7502 cut_7522 subst_l cty_tuple result_id_inner
 create_post filter_6698'''.split(),
 'Term':'''create_vsymbol pat_gen_fold t_type tr_fold_5594 bnd_fold t_vars
 mk_term t_var t_app t_eps t_prop t_loc add_t_vars vars_union fn_2787
 ls_arg_inst mtch_6208 ls_app_inst fs_app ps_app
 t_equ is_fs_tuple t_tuple t_gen_fold branch_6696 t_ty_fold'''.split(),
 'Ty':'''ts_equal ty_equal ty_v_fold ty_freevars ty_app ty_match set_3275
 ty_tuple ty_equal_check'''.split(),
 'Expr':['c_app','is_rs_tuple','mk_cexp'],
 'Ident':['id_fresh','id_fresh_inner'],
 'Util':['const','all','any','all_fn','any_fn','ffalse'],
 'Opt':['fold'],
}
LISTS='length length_aux map iter fold_left fold_right fold_left2 fold_right2 for_all rev_append'.split()
SPANS={
 'src/mlw/ity.ml':[(125,185),(189,207),(220,331),(355,455),(488,500),
                  (520,539),(745,764),(790,823),(900,1021),(1237,1249),
                  (1264,1288),(1293,1501)],
 'src/core/ty.ml':[(90,116),(157,172),(203,217),(238,254),(256,277),(278,289),(294,302)],
 'src/core/term.ml':[(17,39),(200,254),(574,624),(628,644),(780,795),
                    (874,894),(950,963),(1020,1021),(1037,1057),(1177,1209)],
 'src/mlw/expr.ml':[(495,498),(837,844),(938,951)],
 'src/core/ident.ml':[(158,214)],
 'src/util/util.ml':[(16,18),(32,63)],
 'src/util/opt.ml':[(1,150)],
 'src/util/extmap.ml':[(18,42),(439,567)],
 'src/util/extset.ml':[(18,112)],
}


def digest(raw):return hashlib.sha256(raw).hexdigest()
def write(name,value):(HERE/name).write_text(json.dumps(value,indent=2)+'\n')


def elf_sections(raw):
    assert raw[:6]==b'\x7fELF\x02\x01'
    off=struct.unpack_from('<Q',raw,40)[0]
    size,count=struct.unpack_from('<HH',raw,58)
    return [struct.unpack_from('<IIQQQQIIQQ',raw,off+i*size) for i in range(count)]


def elf_symbols(raw):
    sections=elf_sections(raw);out={}
    for sec in sections:
        if sec[1]!=2:continue
        strings=sections[sec[6]];st=raw[strings[4]:strings[4]+strings[5]]
        for pos in range(sec[4],sec[4]+sec[5],sec[9]):
            name,info,other,index,addr,size=struct.unpack_from('<IBBHQQ',raw,pos)
            nm=st[name:st.find(b'\0',name)].decode()
            if nm and index and index<len(sections):
                s=sections[index];out[nm]=(addr,size,s[4]+addr-s[3])
    return out


def named_roots(bodies):
    selected=set()
    for unit,names in ROOTS.items():
        for name in names:
            pattern='camlWhy3__'+unit+'__'+name+(r'' if re.search(r'_\d+$',name) else r'_\d+')
            found={n for n in bodies if re.fullmatch(pattern,n)}
            assert found,(unit,name)
            selected|=found
    for name in LISTS:
        found={n for n in bodies if re.fullmatch('camlStdlib__List__'+name+r'_\d+',n)}
        assert len(found)==1,name
        selected|=found
    return selected


def main():
    prior=json.loads((ROOT/PRIOR).read_text())
    binary=Path(prior['executable']['path']).read_bytes()
    assert digest(binary)==prior['executable']['identity']['sha256']
    raw=Path(prior['existing_disassembly']['path']).read_bytes()
    assert digest(raw)==prior['existing_disassembly']['sha256']
    bodies={n:b for b,n in re.findall(r'(?m)^([0-9a-f]+ <([^>]+)>:\n.*?)(?=\n[0-9a-f]+ <|\Z)',raw.decode(),re.S)}
    symbols=elf_symbols(binary)
    address_names={addr:n for n,(addr,_,_) in symbols.items() if n in bodies}
    selected=named_roots(bodies);roots=set(selected);closures={}
    local_units={'Ity','Ty','Term','Expr','Ident','Util','Opt'}
    while True:
        extra=set()
        for n in selected:
            refs=set(re.findall(r'<([^>+]+)(?:\+[^>]+)?>',bodies[n]))
            for ref in refs:
                if re.fullmatch(r'camlWhy3__(?:'+('|'.join(local_units))+r')__fun_\d+',ref) and ref in bodies:
                    extra.add(ref)
                if not re.fullmatch(r'camlWhy3__(?:'+('|'.join(local_units))+r')__\d+',ref) or ref not in symbols:
                    continue
                addr,size,pos=symbols[ref]
                # Local ELF labels have zero st_size. The preceding OCaml
                # block header supplies the exact closure-object extent.
                header=struct.unpack_from('<Q',binary,pos-8)[0]
                if header & 255 != 247:continue
                words=header>>10
                assert 2<=words<=64,(ref,header)
                size=8*words
                targets=[]
                for off in range(0,size,8):
                    val=struct.unpack_from('<Q',binary,pos+off)[0]
                    target=address_names.get(val,'')
                    if target and re.match(r'camlWhy3__(?:'+('|'.join(local_units))+r')__',target):
                        targets.append(target);extra.add(target)
                if targets:closures[ref]={'address':addr,'size':size,'header':header,'targets':sorted(set(targets))}
        if extra<=selected:break
        selected|=extra
    adapters={n for n in bodies if re.fullmatch(r'caml_(?:apply|curry)(?:[2-9]|1[01])(?:_\d+)*(?:_app)?',n)}
    chosen={n:bodies[n] for n in sorted(selected|adapters)}
    write('native-bodies.json',chosen)
    write('native-witnesses.json',{
      'executable':prior['executable'],'existing_disassembly':prior['existing_disassembly'],
      'root_bodies':sorted(roots),'local_bodies':sorted(selected),
      'adapter_bodies':sorted(adapters),'constant_closure_targets':closures,
      'external_code_references':sorted({r for n in chosen for r in re.findall(
          r'<([^>+]+)(?:\+[^>]+)?>',chosen[n]) if r in bodies and r not in chosen}),
      'new_disassembler_or_target_execution':False,
      'source_native_refinement_machine_proved':False})
    sources=[]
    for archive,spans in [(WHY,SPANS),(OCAML,{'stdlib/list.ml':[(1,240)]})]:
        item={'path':archive,'sha256':digest((ROOT/archive).read_bytes()),'files':[]}
        with tarfile.open(ROOT/archive) as t:
            for name,ranges in spans.items():
                matches=[n for n in t.getnames() if n==name or n.endswith('/'+name)]
                assert len(matches)==1,(name,matches)
                data=t.extractfile(matches[0]).read();ls=data.decode().splitlines()
                ss=[]
                for first,last in ranges:
                    last=min(last,len(ls));code='\n'.join(ls[first-1:last])+'\n'
                    ss.append({'first':first,'last':last,'sha256':digest(code.encode()),'source':code})
                item['files'].append({'path':matches[0],'sha256':digest(data),'spans':ss})
        sources.append(item)
    write('source-witnesses.json',sources)
    print(json.dumps({'roots':len(roots),'local_bodies':len(selected),'adapter_bodies':len(adapters),'static_closures':len(closures)}))


if __name__=='__main__':main()
