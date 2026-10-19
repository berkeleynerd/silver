#!/usr/bin/env python3
"""Inventory aid with process/site owners; source projection remains the proof."""
import argparse,json,re,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent

def clean(s):return re.sub(r"'\"'|--[^\n]*|\"(?:[^\"\n]|\"\")*\"",lambda m:''.join('\n' if c=='\n' else ' ' for c in m[0]),s)
def owner(f):
    if f.startswith('errid-'):return 'partial packet: unconditional registry objects'
    if f.startswith('libgnat/'):
        return 'generic template: allocate only in concrete caller instance; table/hash/list owners below; fixed successful projection for fixed-only callers'
    if f=='atree.adb':return 'inherited node tables; explicit optional field sets; local statistics tables not entered with selected options'
    if f=='back_end.adb':return 'completion: Ada Args array, local copy, each allocated argument String'
    if f.startswith('ali.'):return 'Main invocation signature owner or initialized zero-growth Main ALI tables; ALI reader bodies not called'
    if f=='butil.adb':return 'binder utility body, no selected Main frontend caller; no package allocator at this site'
    if f.startswith('errout'):return 'partial diagnostic initial objects and empty-message/text-rendering projection'
    if f=='fname-uf.adb':return 'inherited SFN tables; completion SFN map wrappers and default pattern Strings'
    if f=='generate_minimal_reproducer.adb':return 'unselected error/reproducer path; successful selected route enters no allocator'
    if f=='lib-xref.adb':return 'inherited Xrefs/hash/sort backing; selected -gnatx excludes new cross-reference rows'
    if f=='lib.ads':return 'inherited Main_ALI_writer.Unit_Names and Units; completion other lib tables'
    if f=='lib.adb':return 'completion exact ten saved compilation switches and individual String copies'
    if f=='opt.ads':return 'partial unconditional option initialization; omitted option writers separately excluded'
    if f.startswith('osint'):return 'completion argument/path wrappers and file hash; inherited source buffers/search-directory tables; absent path files/platform helpers excluded'
    if f=='par-prag.adb':return 'completion selected naming pattern Strings; warning-match allocator excluded by naming-only configuration'
    if f=='par_sco.adb' or f.startswith('scos.'):return 'completion initialized SCO tables; selected no-SCO excludes local entries/allocators'
    if f=='sem.adb':return 'partial fixed Suppress_Stack_Entry wrappers; inherited common scope-save and scope tables'
    if f=='sem_case.adb':return 'fixed semantic projection only; completion choice Link/array counts and local fixed generic traversal'
    if f=='sem_ch6.adb':return 'Style_Check=False excludes style-order String; fixed runtime semantic projection remains'
    if f=='sem_elim.adb':return 'completion initialized Elim table; no Eliminate configuration/Main writer, static hash retained'
    if f=='sem_prag.adb':return 'partial warning/configured-mode caller partition; completion fixed pragma tables'
    if f=='set_targ.adb':return 'fixed selected target/mode read projection; fixed FPT table retained; no target-file override'
    if f=='sinput-l.adb':return 'inherited physical buffers/line tables and nine already-owned virtual Dope_Rec objects'
    if f=='switch-c.adb':return 'completion selected Config/Mapping path objects and singleton pointer array; other optional switch routes excluded'
    if f=='vast.adb':return 'completion initialized Node_Stack; optional representation/tree visualization not selected'
    if f=='fmap.adb':return 'inherited configuration map hash wrappers/buckets'
    if f=='sem_type.adb':return 'inherited core All_Interp and Interp_Map'
    if f=='uintp.adb':return 'inherited numeric tables/UI_Ints/cache/local vector owner'
    if f=='sem_elab.adb':return 'inherited invocation: each map/set instance, lists and initial backing; completion legacy zero-growth tables'
    if f=='sem_util.adb':return 'partial NCT maps/wrappers; completion fixed semantic traversal/local intervals; inherited element-list counts'
    if f=='exp_util.adb':return 'partial Type_Map; fixed-only generic inputs; selected Main leaf-copy projection'
    if f=='sem_ch12.adb':return 'partial fixed eight generic instances, three tables and static renaming headers'
    if f.startswith('prep'):return 'completion Pp/Preproc tables; Dynamic_Tables instances initially empty; no preprocessing selection'
    if f=='repinfo.adb' or f=='repinfo-input.adb':return 'inherited Rep_Table numeric callbacks; completion optional JSON/dynamic tables; no representation listing/input'
    if f=='sinfo-utils.adb':return 'Lists actual site Lowest_Common_Ancestor is goto-label analysis; no Main goto; fixed projection for any fixed caller'
    if f=='inline.adb':return 'completion initialized inline tables; fixed runtime instance pending work; selected no frontend inline excludes Pending_Inlined local'
    if f=='par.adb':return 'inherited parser Scope/Suspicious_Labels actual instances'
    if f=='aspects.adb':return 'fixed aspect-name initialization and fixed runtime aspects; no Main aspect creates map entries'
    if f in ['exp_attr.adb','exp_dist.adb','gnat_cuda.adb','scil_ll.adb','sem_dim.adb','sem_ch7.adb','sem_disp.adb','treepr.adb']:
        return 'fixed package initialization retained; variable writers require respectively omitted attribute/distribution/CUDA/SCIL/dimension/package-body/dispatch/tree-print inputs'
    if f in ['rident.ads','scn.ads','scng.ads','style.ads']:
        return 'fixed generic data or inherited scanner; selected style/configuration transfer'
    if f in ['sem_ch3.adb','sem_ch4.adb','sem_ch5.adb','sem_ch13.adb']:
        return 'fixed generic case/variant choice caller; Main caller excluded by complete selected construct closure'
    # Ordinary Table.Table declarations are reconciled separately by exact120 symbol.
    return 'exact table owner in fixed120 reconciliation, or fixed-only local instance under selected source projection'

def main():
    p=argparse.ArgumentParser();p.add_argument('--ada-root',required=True);a=p.parse_args();root=Path(a.ada_root)
    inputs=json.loads((HERE/'source-census-files.json').read_text());files=[];allocs=[];generics=[]
    for f in inputs['files']:
        raw=(root/f).read_bytes();s=raw.decode();c=clean(s)
        files.append(dict(path=f,bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()))
        for m in re.finditer(r'\bnew\s+([\w.]+)',c,re.I):
            if re.search(r'\bis\s*$',c[:m.start()],re.I):continue
            allocs.append(dict(path=f,LF=s.count('\n',0,m.start())+1,target=m[1],owner=owner(f)))
        for m in re.finditer(r'package\s+(\w+)\s+is\s+new\s+([\w.]+)',c,re.I):
            generics.append(dict(path=f,LF=s.count('\n',0,m.start())+1,instance=m[1],generic=m[2],owner=owner(f),initialization_rule='Table.Table.Init executes at actual instance elaboration; Simple_HTable has static headers; Dynamic_Tables starts at shared empty table; dynamic hash/list allocate at actual Create site; local package elaboration needs caller entry'))
    output=dict(scope=inputs['scope'],source_files=files,allocator_sites=allocs,generic_instantiation_sites=generics,
        allocator_site_count=len(allocs),generic_instantiation_site_count=len(generics),generated_missing=inputs['generated_missing'],
        generic_templates_are_not_independent_runtime_allocations=True,lexical_inventory_is_not_an_exhaustive_callgraph=True,
        completion_basis='closed actual Main constructor/caller projection plus fixed successful selected-root read projection and explicit changed argv/path/name storage')
    (HERE/'closure-owner-audit.json').write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(dict(files=len(files),allocator_sites=len(allocs),generic_instantiations=len(generics))))
if __name__=='__main__':main()
