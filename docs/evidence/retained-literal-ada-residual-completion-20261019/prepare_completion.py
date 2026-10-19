#!/usr/bin/env python3
"""Read-only source extraction for the additive Ada completion packet."""
from pathlib import Path
import argparse, hashlib, json, re
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
def clean(s):
    return re.sub(r"'\"'|--[^\n]*|\"(?:[^\"\n]|\"\")*\"",lambda m:''.join('\n' if c=='\n' else ' ' for c in m[0]),s)
def identity(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def main():
    p=argparse.ArgumentParser();p.add_argument('--ada-root',required=True);a=p.parse_args();ada=Path(a.ada_root)
    used=set();excerpts=[]
    def source(f):used.add(f);return (ada/f).read_bytes().decode()
    def excerpt(f,start,end,label):
        s=source(f);excerpts.append(dict(path=f,first_LF_line=start,last_LF_line=end,label=label,text='\n'.join(s.split('\n')[start-1:end])))
    def enum(f,name):
        s=clean(source(f));m=re.search(r'\btype\s+'+name+r'\s+is\s*\((.*?)\)\s*;',s,re.S|re.I)
        assert m,(f,name);return [v.strip() for v in m[1].split(',')]
    restrictions=enum('libgnat/s-rident.ads','Restriction_Id')
    warnings=enum('warnsw.ads','Opt_Warnings_Enum')
    il_types=enum('gen_il-types.ads','Opt_Type_Enum');il_fields=enum('gen_il-fields.ads','Opt_Field_Enum')
    # Use the entire enum even for subtype arrays: a conservative static bound.
    nested={'Restrictions_Info':5*len(restrictions)*16,'Config_Switches_Type':26*16,
            'Suppress_Record':(30+2)*16,'Warnings_State':len(warnings)*16,
            'Symbol_Table.Instance':4*16,'Name_Array':7*16,'Symbol_Array':7*16,
            'Xref_Key':7*16,'Source_Location':2*16,'Time_Stamp_Type':16,
            'Version_String':16}
    primitive={'Node_Id','Entity_Id','Name_Id','Int','Unit_Name_Type','String_Id','Character','Unit_Number_Type','Source_File_Index','String_Ptr'}
    defs={};rows=[]
    census=json.loads((HERE/'fixed-table-census.json').read_text())
    for row in census['rows']:
        if row['owner']:continue
        sym=row['symbol'];name=sym.split('__')[-2];unit=sym.split('__')[0]
        hits=[]
        for f in sorted(ada.glob(unit+'*.ad*')):
            s=f.read_bytes().decode()
            for m in re.finditer(r'package\s+'+name+r'\s+is\s+new\s+(?:Table\.)?Table\b',clean(s),re.I):
                end=s.find(';',m.end())+1
                hits.append((f.name,m.start(),end,s))
        assert len(hits)==1,(sym,hits)
        f,start,end,s=hits[0];first=s.count('\n',0,start)+1;last=s.count('\n',0,end)+1
        excerpt(f,first,last,'instance '+sym);decl=s[start:end];fields={}
        for k,v in re.findall(r'(Table_\w+)\s*=>\s*([^,\n]+)',clean(decl)):fields[k]=v.strip()
        comp=fields['Table_Component_Type'];comp_bytes=None;layout=None
        if comp in primitive:comp_bytes=1 if comp=='Character' else 16 if comp=='String_Ptr' else 4;layout=dict(kind='scalar_or_pointer',bytes_upper=comp_bytes)
        else:
            candidates=[f]+[v.name for v in sorted(ada.glob(unit+'*.ad*')) if v.name!=f]
            if comp=='Pending_Body_Info':candidates=['inline.ads']
            if comp=='Xref_Entry':candidates=['lib-xref.adb']
            if comp=='SCO_Table_Entry':candidates=['scos.ads']
            found=[]
            for sf in candidates:
                ss=source(sf);cc=clean(ss)
                m=re.search(r'\btype\s+'+comp+r'\s*(\([^;]*?\))?\s+is\s+record\b',cc,re.S|re.I)
                if not m:continue
                e=cc.index('end record;',m.end())+11;body=cc[m.end():e-11]
                members=[]
                for mm in re.finditer(r'\b([A-Za-z]\w*(?:\s*,\s*[A-Za-z]\w*)*)\s*:\s*(?![=])([^;]+);',body):
                    names=mm[1].split(',');ty=mm[2].split(':=')[0].strip();n=len(names)
                    if ty.startswith('String (1 .. Ver_Len_Max)'):b=256+16
                    else:b=nested.get(ty,16)
                    members.append(dict(names=[v.strip() for v in names],type=ty,bytes_upper_each=b))
                comp_bytes=sum(len(v['names'])*v['bytes_upper_each'] for v in members)
                if m[1]:comp_bytes+=16 # discriminant plus all variant arms conservatively
                layout=dict(kind='record_all_variant_arms_padded',members=members,discriminant_bytes_upper=16 if m[1] else 0,bytes_upper=comp_bytes)
                excerpt(sf,ss.count('\n',0,m.start())+1,ss.count('\n',0,e)+1,'component '+comp)
                found.append(sf);break
            assert found,(sym,comp)
        def number(v):
            if v.isdecimal():return int(v)
            assert v.startswith('Alloc.'),v
            s=source('alloc.ads');m=re.search(r'\b'+v.split('.')[1]+r'\s*:\s*constant\s*:=\s*([\d_]+)',s,re.I);assert m,v
            return int(m[1].replace('_',''))
        low=fields['Table_Low_Bound']
        if low.isdecimal():low=int(low)
        elif low=='First_Name_Id':low=-399999997
        elif low.startswith('First_'):low=1
        elif low.endswith("'First"):low=0
        else:raise ValueError(low)
        d=row['retained_positive_lifetime_growth'];basis='fixed successful root projection; zero Main writer delta'
        if sym=='lib__compilation_switches__last_val':d=10;basis='current Main_ALI_interface.stored_native_switches exact ten payloads, total110 characters; supersedes historical five/six'
        if sym=='osint__file_name_chars__last_valX':d=1580*513;basis='at most1580 successful physical Source opens, each complete spelling <=512 plus LF; repeat System already included'
        if sym=='lib__load_stack__last_val':d=42;basis='at most41 admitted unit records plus one already-loaded temporary request; repeated calls pop before returning'
        rows.append(dict(symbol=sym,retained_positive_lifetime_growth=row['retained_positive_lifetime_growth'],owner='selected_Main_process.'+sym.rsplit('__',1)[0],demand_upper=d,demand_basis=basis,initial=number(fields['Table_Initial']),increment_percent=number(fields['Table_Increment']),low=low,component_bytes_upper=comp_bytes,layout=layout,declaration=dict(path=f,first_LF_line=first,last_LF_line=last),initial_backing_retained=True))
    # Source support for nested fields and changed demand paths.
    spans=[('alloc.ads',30,165),('libgnat/s-rident.ads',88,239),('libgnat/s-rident.ads',328,375),('warnsw.ads',38,112),('opt.ads',2082,2109),('types.ads',698,726),('types.ads',775,788),('types.ads',336,350),('namet.ads',186,202),('gnatvsn.ads',75,87),('libgnat/g-dyntab.ads',144,182),('libgnat/g-dyntab.ads',278,294),('sem_dim.adb',99,131),('lib-xref.adb',68,113),('scos.ads',357,382),('lib.adb',1173,1190),('back_end.adb',226,281),('switch-c.adb',145,168),('osint.adb',2685,2705),('sinput-l.adb',345,398),('sinput-l.adb',418,427),('lib-load.adb',672,730),('atree.ads',590,607),('atree.adb',275,352),('gen_il-gen.adb',2145,2196),('sem.adb',873,908),('sem_ch5.adb',4523,4595),('atree.adb',2627,2659),('sinfo-utils.adb',379,430),('sem_ch5.adb',1905,1930),('libgnat/g-dyntab.ads',144,155),('libgnat/g-table.adb',150,164),('back_end.adb',194,219),('back_end.adb',303,317),('switch-c.adb',497,545),('switch-c.adb',710,729),('switch-c.adb',1686,1698),('osint.ads',280,297),('osint.ads',387,396),('osint.ads',708,751),('osint.adb',256,278),('osint.adb',560,587),('osint.adb',1490,1519),('osint.adb',1550,1676),('osint.adb',2114,2148),('osint.adb',2830,2887),('osint.adb',3204,3249),('fname-uf.adb',59,78),('fname-uf.adb',437,457),('par-prag.adb',660,677),('par-prag.adb',860,873),('set_targ.ads',90,106),('set_targ.adb',264,279),('set_targ.adb',344,379),('sem_util.adb',31133,31212),('sem_util.adb',31242,31324),('sem_util.ads',3620,3634),('sem_res.adb',10283,10320),('sem_case.adb',3183,3225),('sem_case.adb',3377,3386),('sem_case.adb',3535,3576),('sem_case.adb',3637,3680),('sem_case.adb',3725,3830),('libgnat/g-hesorg.adb',50,148),('sem_util.adb',25056,25237),('sem_util.adb',25243,25357),('sem_util.adb',25362,25495),('sem_util.adb',24579,24646),('gen_il-gen.adb',1737,1802),('gen_il-gen.adb',1833,1901),('gen_il-gen.adb',2188,2249),('gen_il-gen.adb',2608,2633),('gen_il-gen.adb',2919,2934),('gen_il-gen.adb',3036,3059)]
    for f,a,b in spans:excerpt(f,a,b,'layout or caller support')
    repo_paths=['docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json','docs/evidence/retained-literal-ali-20261018/compose.py','docs/evidence/retained-literal-ali-20261018/review.md','docs/evidence/retained-native-fixed-capture-20261018/README.md','docs/evidence/retained-native-fixed-capture-20261018/summary.json','docs/evidence/retained-native-fixed-capture-20261018/inputs.json','docs/research/retained-native-expansion.md','docs/research/retained-main-semantics.md','docs/research/retained-literal-frontend-storage.md','docs/research/retained-literal-native-frontend.md','docs/research/retained-binder-capacity.md']
    manifest=dict(repository_files=[dict(path=f,identity=identity((REPO/f).read_bytes())) for f in repo_paths],frozen_partial_commit='d23e7395e3d8df4019f90c798348334f86c4d376',files=[dict(path=f,identity=identity((ada/f).read_bytes())) for f in sorted(used)],excerpts=excerpts,literal_LF_positions=True,read_only_extraction=True)
    (HERE/'completion-inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')
    out=dict(rows=rows,new_named_table_count=len(rows),nested_layout_bytes_upper=nested,restriction_enum_count=len(restrictions),warning_enum_count=len(warnings),IL_type_enum_count=len(il_types),IL_field_enum_count=len(il_fields),optional_field_check_each_array_bytes_upper=len(il_types)*len(il_fields)*16+16,retained_partial_rows=53,exact_reconciled_census_rows=120)
    (HERE/'completion-tables.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(dict(rows=len(rows),files=len(used),excerpts=len(excerpts),restriction_enum_count=len(restrictions),warning_enum_count=len(warnings))))
if __name__=='__main__':main()
