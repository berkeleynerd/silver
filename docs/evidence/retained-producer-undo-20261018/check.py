#!/usr/bin/env python3
"""Check source identities and scoped-map call inventory; no native execution."""
import argparse,collections,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'retained-producer-capacity-20261017'))
from auxiliary_domains import check,clean
from string_lengths import body_events


def inventory(source_root):
    rows=[];generic=[]
    for p in sorted((source_root/'src/why').glob('*.adb')):
        source=p.read_text();code=clean(source);events=body_events(code)
        assert not re.search(r'\b(?:use|renames)\s+Ada_Ent_To_Why\b',code,re.I)
        for m in re.finditer(r'\b(?:Ada_Ent_To_Why\.(?:Push_Scope|Insert)|Insert_Item|Insert_Tmp_Item_For_Entity|Push_Binders_To_Symbol_Table)\s*\(',code):
            if re.search(r'\bprocedure\s*$',code[max(0,m.start()-15):m.start()]):continue
            events.append((m.start(),'site',m.group().split('(')[0].strip()))
        for m in re.finditer(r'\bis\s+new\s+Generate_Expr_With_Actions\s*\(',code,re.I):
            generic.append({'file':str(p.relative_to(source_root)),'line':source.count('\n',0,m.start())+1})
        stack=[]
        for pos,kind,value in sorted(events):
            if kind=='start':stack.append(value)
            elif kind=='end':
                if stack and stack[-1].lower()==value.lower():stack.pop()
            else:
                rows.append({'file':str(p.relative_to(source_root)),'line':source.count('\n',0,pos)+1,'call':value,'enclosing_entity':'.'.join(stack)})
        assert not stack,(p,stack)
    counts=dict(collections.Counter(x['call'] for x in rows))
    assert counts=={'Ada_Ent_To_Why.Push_Scope':48,'Ada_Ent_To_Why.Insert':15,'Insert_Item':4,'Insert_Tmp_Item_For_Entity':26,'Push_Binders_To_Symbol_Table':13},counts
    assert len(generic)==4,generic
    sinfo=clean((source_root/'src/why/why-sinfo.ads').read_text())
    assert re.search(r'type EW_ODomain is\s*\(EW_Expr, EW_Term, EW_Pterm, EW_Pred, EW_Prog\)',sinfo)
    assert re.search(r'subtype EW_Domain is\s*EW_ODomain\s+range EW_Term\s*\.\.\s*EW_Prog;',sinfo)
    flow=clean((source_root/'src/flow/flow_types.ads').read_text())
    variants=re.search(r'type Flow_Id_Variant is\s*\((.*?)\);',flow,re.S).group(1).split(',')
    facets=re.search(r'type Variable_Facet_T is\s*\((.*?)\);',flow,re.S).group(1).split(',')
    assert len(variants)==7 and len(facets)==5
    assert 1+len(variants)*len(facets)==36
    util=(source_root/'src/why/gnat2why-util.adb').read_text()
    assert len(re.findall(r'M\.Undo_Stack\.Append\b',clean(util)))==7
    assert 4*(counts['Ada_Ent_To_Why.Push_Scope']+len(generic)-1)==204
    assert counts['Push_Binders_To_Symbol_Table']+2==15
    return rows,generic,counts


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source-root',type=Path,required=True)
    p.add_argument('--source-archive',type=Path,required=True)
    p.add_argument('--write',action='store_true',help='Write the initial reviewed inventory; normal use verifies it.')
    args=p.parse_args()
    verified=check(args.source_root,args.source_archive)
    rows,generic,counts=inventory(args.source_root)
    result={'archive_sha256':verified['archive_sha256'],'verified_complete_ada_files':verified['verified_complete_ada_files'],'counts':counts,'generic_instances':generic,'scope_instances':51,'domains':4,'boundary_coefficient':204,'binder_batches':15,'flow_variants':7,'variable_facets':5,'raw_plus_variable_entity_factor':36,'undo_peak_bound':'204*(A_total+1) + 2*B_N + 30*(36*E_total+7*U_Common+1)','call_sites':rows,'limitation':'Checks source identity, complete lexical call inventory and arithmetic. Reachability, strict source descent/domain progress and finite outstanding binder batches are manually argued for the current frontier in retained-producer-undo.md. Not a general GNATprove-program theorem.','native_tool_executions':0}
    path=ROOT/'inventory.json'
    if args.write:path.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    else:assert json.loads(path.read_text())==result
    print(json.dumps({k:result[k] for k in ('verified_complete_ada_files','counts','scope_instances','boundary_coefficient','binder_batches','undo_peak_bound','native_tool_executions')}))
