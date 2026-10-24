"""New source partition inventory, reusing immutable accepted graph bytes."""
import importlib.util
import json
from pathlib import Path
import re
import sys
import tarfile

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
sp=importlib.util.spec_from_file_location('accepted_clone_inventory',HERE.parent/'clone-callers/inventory.py')
old=importlib.util.module_from_spec(sp);sp.loader.exec_module(old)


def collect():
    prior=json.loads((old.OLD/'result.json').read_text())
    accepted=json.loads((HERE.parent/'clone-callers/inventory.json').read_text())
    seen=set();todo=list(old.MAIN_ORIGINS)
    while todo:
        m=todo.pop()
        if m in seen:continue
        seen.add(m)
        todo.extend(s['target'] for s in prior['modules'][m]['statements'] if s['kind']=='clone')
    expected={'_gnatprove_standard.Array__1','_gnatprove_standard.Array__Index',
      'ada__model.Constr_Array','ada__model.Discrete_Base','ada__model.Dynamic_Discrete',
      'ada__model.Index_Type','ada__model.Rep_Proj_Base','ada__model.Rep_Proj_Int',
      'ada__model.Static_Discrete','ada__model.Static_Discrete_Base','ada__model.Unconstr_Array'}
    assert seen==expected
    rows={}
    with tarfile.open(old.OLD/'sources.tar.gz') as t:
        for m in sorted(seen):
            fk,mn=m.rsplit('.',1);path=prior['files'][fk]['path']
            src=t.extractfile(path).read().decode();clean=old.lexer.mask_comments(src)
            starts=list(re.finditer(r'^(?:module|theory)\s+([A-Za-z_][A-Za-z0-9_\']*)',clean,re.M))
            i=next(i for i,s in enumerate(starts) if s[1]==mn)
            start=starts[i].start();end=starts[i+1].start() if i+1<len(starts) else len(src)
            ts=old.lexer.tokens(src[start:end])
            excluded=[(v,src[:start+pos].count('\n')+1) for v,pos in ts
                if v in {'old','at','raises','exception','ghost'} or v.startswith("'")]
            assert not excluded,(m,excluded)
            definitions=[]
            for j,(v,pos) in enumerate(ts):
                if v=='let':
                    assert ts[j+1][0]=='function',(m,j)
                    definitions.append({'name':ts[j+2][0],
                        'line':src[:start+pos].count('\n')+1})
            rows[m]={'path':path,'first':src[:start].count('\n')+1,
                     'last':src[:end].count('\n'),
                     'explicit_executable_definitions':definitions,
                     'typevar_old_exception_ghost_tokens':0}
    found={(m,d['name'],d['line']) for m,r in rows.items() for d in r['explicit_executable_definitions']}
    assert found=={('ada__model.Index_Type','first',1251),('ada__model.Index_Type','last',1253),
       ('ada__model.Unconstr_Array','to_array',1629),('ada__model.Unconstr_Array','of_array',1631)}
    residual=sorted(set(accepted['all_origins'])-seen)
    assert len(residual)==58
    return {
       'main_origins':sorted(old.MAIN_ORIGINS),'main_clone_ancestor_inventory':rows,
       'other_fixed_clone_origins_remaining':residual,
       'covered_create_cty_sites':[
          'Dexpr.cty_of_spec:1324 (current Main vals/Cany)',
          'Expr.c_fun:831 (Main/internal/nullary wrappers)',
          'Expr.create_constructor:210 (current snapshot/reference records)',
          'Expr.rs_of_ls:220 and c_pur:853 (closed current Main contract entries only)',
          'Pmodule.clone_cty:959 (eleven Main-origin closure and its generated lemmas)'],
       'covered_snapshot_c_app_families':[
          'Input_Is_Valid','First_Or_Default','Reject','Put','Put_Line',
          'monomorphic snapshot arithmetic/Int relations/overflow and range checks',
          'Integer.length, array concat/equality, String conversion/accessors, Image/to_string',
          'Boolean True/False','Unit (additional cty_tuple [] replacement)',
          'Index_Type.first/last, Unconstr_Array.to_array/of_array body calls'],
       'remaining_native_site_branches':[
          {'site':'Ity.cty_apply:1436-1489','rows':['reference parameter/result instantiation including current reference projection/constructor calls','type-variable signatures including polymorphic equality candidates','partial application fresh formals','oldie rebuilding','ghost promotion where not excluded by current source gate','eff_inst and type-changing t_ty_subst rows']},
          {'site':'Ity.create_cty:1359-1431','rows':['fixed-origin polymorphic/nested types','nonempty oldies','nonempty xposts and their singleton open_post','MaskTuple inputs','nonempty spoils/raises outside closed Main frontier']},
          {'site':'Expr.c_app:843 / Ity.cty_tuple:1491-1501','rows':['nonzero tuples and discarded previously built cty_apply output']},
          {'site':'Pmodule.clone_cty:902-958','rows':['preceding clone_ity/clone_reg, formals and oldies, effect reconstruction; accepted term roots remain composed separately']},
          {'site':'Expr.create_rsymbol/c_cty_enrich/c_pur and Dexpr frontend','rows':['surrounding symbol/post/proxy/overload construction and incomplete multiplicities']},
          {'site':'native runtime consumer','rows':['new Ity helper local closures/frames','shared Hsty/Hsity backing, hash and collision callbacks','Wvs/strong memo lookup local services']}],
       'wellfounded_builtin':'accepted review600455e678: closed pure declarations, no program contract-builder entry',
       'predecessor_main_runs':0,
    }
