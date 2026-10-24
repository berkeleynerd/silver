"""Source-derived flat Main contract-builder request fold.

Inputs are the accepted source fold's actual stored records, never a new
admission certificate. New local helpers expose visits/record/list candidates;
only the accepted term and Extmap kernels contribute byte estimates here.
"""
from collections import Counter
from dataclasses import dataclass, field, replace
import importlib.util
from pathlib import Path
import sys

sys.dont_write_bytecode = True
PATH = Path(__file__).resolve().parent.parent/'bridge.py'
sp = importlib.util.spec_from_file_location('accepted_contract_bridge', PATH)
b = importlib.util.module_from_spec(sp)
sys.modules[sp.name] = b
sp.loader.exec_module(b)
k = b.k
Ty = b.Ty
UNIT = Ty('tuple0')


@dataclass(frozen=True)
class Field:
    tag: int
    ty: Ty
    ghost: bool = False


@dataclass(frozen=True)
class Region:
    tag: int
    ty: Ty
    fields: tuple = ()
    private: bool = False


@dataclass(frozen=True)
class PV:
    var: k.Var
    region: Region | None = None
    ghost: bool = False


@dataclass(frozen=True)
class Effect:
    reads: frozenset = frozenset()
    writes: dict = field(default_factory=dict)
    taints: frozenset = frozenset()
    covers: frozenset = frozenset()
    resets: frozenset = frozenset()
    ghost: bool = False
    oneway: str = 'Total'
    # This partition has empty raises/spoils. No absent fields are inferred
    # from a result formula; source correspondence establishes these rows.


@dataclass(frozen=True)
class Contract:
    args: tuple
    pre: tuple
    post: tuple
    effect: Effect
    result: Ty
    result_region: Region | None = None
    freeze: frozenset = frozenset()
    mask: str = 'visible'


class SourceFailure(Exception):
    pass


@dataclass
class Demand:
    ident_entry: int = 0
    hsty_entry: int = 0
    hsity_entry: int = 0
    kernel: object = None
    calls: Counter = field(default_factory=Counter)
    records: Counter = field(default_factory=Counter)
    owner_requests: Counter = field(default_factory=Counter)
    memo_reads: Counter = field(default_factory=Counter)
    map_events: list = field(default_factory=list)

    def __post_init__(self):
        self.kernel = k.Ledger(self.ident_entry)

    def visit(self, name, count=1):
        self.calls[name] += count

    def map(self, name, n, m=0):
        self.map_events.append((name,n,m))
        self.kernel.map(name,n,m)

    def copy_effect(self, e, **changes):
        self.records['effect'] += 1
        return replace(e,**changes)

    def fail(self, message):
        self.records['exception_candidate'] += 1
        raise SourceFailure(message)

    def fresh_result(self):
        self.kernel.ident_increments += 1
        self.records.update(preid=1,ident=1,vsymbol=1)
        return k.Var(self.ident_entry+self.kernel.ident_increments,UNIT)

    def export(self):
        kres=self.kernel.result()
        requests=dict(self.owner_requests)
        requests['Ident']=self.kernel.ident_increments
        return {
            'calls':dict(sorted(self.calls.items())),
            'source_record_list_candidates':dict(sorted(self.records.items())),
            'owner_requests_upper':requests,
            'owner_endpoints_upper':{
                'Ident':self.ident_entry+requests['Ident'],
                'Hsty':self.hsty_entry+requests.get('Hsty',0),
                'Hsity':self.hsity_entry+requests.get('Hsity',0)},
            'memo_reads':dict(sorted(self.memo_reads.items())),
            'map_events':self.map_events,
            'term_map_bytes_upper':kres['direct_bytes_upper'],
            'term_kernel':kres,
            'new_helper_native_bytes_complete':False,
            'shared_hashcons_backing_bytes_complete':False,
            'complete_main_builder_classification':False,
        }


def ty_walk(ty,d,name):
    """Canonical, normalized, closed pure snapshot types only."""
    if not isinstance(ty,Ty) or ty.variable:
        raise ValueError('closed source type required')
    d.visit(name)
    for arg in ty.args:
        ty_walk(arg,d,name)


def project(ty,d):
    # ty_of_ity visits argument types, not record field types. A flat region
    # has a nullary logical type, exactly as its native projection does.
    ty_walk(ty,d,'ty_of_ity')
    def count(t):
        d.owner_requests['Hsty'] += 1
        d.records['type_argument_cons'] += len(t.args)
        for a in t.args: count(a)
    count(ty)
    return ty


def freeze_pv(v, frozen,d):
    d.visit('freeze_pv')
    if v.region is None:
        ty_walk(v.var.ty,d,'ity_match')
        return frozen
    assert not v.region.ty.args
    d.visit('ity_match'); d.visit('reg_match')
    d.records['reg_match_seen_ref'] += 1
    d.records['ity_subst'] += 1
    d.map('freeze_reg_change',len(frozen),int(v.region not in frozen))
    return frozen | {v.region}


def term_types(t,d):
    """term.ml t_gen_fold: stored body, triggers AND every saved image."""
    if isinstance(t,b.Case):
        d.visit('t_gen_fold')
        if t.ty is not None:ty_walk(t.ty,d,'ty_v_fold')
        term_types(t.subject,d)
        def pattern(p):
            d.visit('pat_gen_fold');ty_walk(p.ty,d,'ty_v_fold')
            for q in p.children:pattern(q)
        for p,bb in t.branches:
            d.map('bnd_saved_fold',len(bb.saved))
            for image in bb.saved.values():term_types(image,d)
            pattern(p);term_types(bb.body,d)
        return
    k.require_term(t)
    d.visit('t_gen_fold')
    if t.ty is not None: ty_walk(t.ty,d,'ty_v_fold')
    if t.binding is not None:
        bb=t.binding
        if t.op in {'forall','exists'}:
            for v in bb.variables:ty_walk(v.ty,d,'ty_v_fold')
        d.map('bnd_saved_fold',len(bb.saved))
        for image in bb.saved.values():term_types(image,d)
        for group in bb.triggers:
            for x in group:term_types(x,d)
        term_types(bb.body,d)
    for child in t.args:term_types(child,d)


def free_pvs(t,registry,d,initial=frozenset()):
    d.visit('t_freepvs')
    if b.profile(t)['case']:
        # Same native cached-support recurrence, extended to context cases.
        # Its local helper bytes are outside the case-free byte kernel.
        def variables(x):
            d.visit('case_context_t_vars')
            if isinstance(x,b.Case):
                acc=variables(x.subject)
                for _,bb in x.branches:acc=k.union_counts(acc,bb.free,d.kernel)
                return acc
            if x.op=='var':
                d.map('case_context_var_singleton',1)
                return {x.variable:1}
            if x.binding is not None:
                if x.op=='let':return k.union_counts(variables(x.args[0]),x.binding.free,d.kernel)
                return x.binding.free.copy()
            if not x.args:return {}
            if x.op=='app':acc={};children=x.args
            else:acc=variables(x.args[0]);children=x.args[1:]
            for child in children:acc=k.union_counts(acc,variables(child),d.kernel)
            return acc
        fvs=variables(t)
    else:
        fvs=k.t_vars(t,d.kernel)
    d.map('pvs_of_vss_fold',len(fvs))
    result=set(initial)
    for v in sorted(fvs,key=lambda x:x.tag):
        d.memo_reads['Ity.vs_to_pv.restore'] += 1
        pv=registry[v]
        d.map('free_pv_add',len(result),int(pv not in result))
        result.add(pv)
    return frozenset(result)


def check_taints(taints,reads,d):
    d.visit('check_taints')
    if not taints:return
    d.map('taint_read_iter',len(reads))
    for v in sorted(reads,key=lambda x:x.var.tag):
        if not v.ghost:
            d.visit('ity_vis_fold')
            if v.region is not None:
                d.visit('reg_vis_fold')
                d.map('taint_member',len(taints))
                if v.region in taints:d.fail('BadGhostWrite')


def read_pre(reads,e,d):
    d.visit('eff_read_pre')
    d.map('read_subset',len(reads),len(e.reads))
    if reads <= e.reads:return e
    check_taints(e.taints,reads,d)
    d.map('read_union',len(e.reads),len(reads))
    return d.copy_effect(e,reads=e.reads | reads)


def read_post(e,reads,d):
    d.visit('eff_read_post');d.visit('check_writes');d.visit('check_covers')
    if e.writes:
        d.map('write_check_read_iter',len(reads))
        for v in reads:
            # A pure snapshot or flat reference has no frozen nested region.
            ty_walk(v.var.ty,d,'ity_frz_fold_upper')
    if e.resets:
        d.map('cover_check_read_iter',len(reads))
        for v in sorted(reads,key=lambda x:x.var.tag):
            d.visit('ity_exp_fold')
            r=v.region
            if r is None:continue
            d.map('stale_cover_mem',len(e.covers))
            if r not in e.covers:
                d.map('stale_reset_mem',len(e.resets))
                if r in e.resets:
                    # Diagnostic inner iteration keeps its already-done work.
                    d.map('stale_diagnostic_iter',len(e.resets))
                    for q in sorted(e.resets,key=lambda x:x.tag):
                        d.map('stale_diagnostic_singleton',1)
                        d.map('stale_diagnostic_cover_mem',len(e.covers))
                        d.map('stale_diagnostic_mem',1)
                        if r==q:d.fail('StaleVariable')
    return read_pre(reads,e,d)


def reset_taints(e,d):
    d.visit('reset_taints');d.visit('visible_writes')
    d.map('visible_write_subdomain',len(e.writes))
    visible=set()
    for r,fs in e.writes.items():
        if not r.private:d.map('visible_field_exists',len(fs))
        if r.private or any(not f.ghost for f in fs):visible.add(r)
    visible=frozenset(visible)
    if e.ghost or not visible:
        check_taints(visible,e.reads,d)
        taints=visible
    else:
        taints=visible
        d.map('remove_visible_read_fold',len(e.reads))
        for v in e.reads:
            if not v.ghost:
                d.visit('ity_vis_fold')
                if v.region is not None:
                    d.visit('reg_vis_fold')
                    d.map('visible_region_remove',len(taints))
                    taints=taints-{v.region}
    return d.copy_effect(e,taints=taints)


def create_cty(args,pre,post,e,result,registry,d,*,defensive=False,
               result_region=None,mask='visible'):
    """Flat, closed, no-oldie/no-xpost Main row, retaining all effect sets."""
    if mask not in {'visible','ghost'}:raise ValueError('tuple mask residual')
    d.visit('create_cty')
    d.records['exception_candidate'] += 1 # eagerly formed Invalid_argument
    d.visit('check_pre');d.visit('check_pre_item',len(pre));d.visit('check_post')
    project(result,d) # Even post=[] computes ty_of_ity.
    d.visit('check_post_item',len(post))
    d.map('xpost_check_iter',0)
    d.visit('mask_check');d.visit('mask_reduce')
    sarg=set()
    for v in args:
        d.map('arg_add_new',len(sarg),1)
        if v in sarg:d.fail('duplicate formal')
        sarg.add(v)
    sarg=frozenset(sarg)
    d.map('oldie_iter',0)
    preads=sarg
    for t in pre:
        preads=free_pvs(t,registry,d,preads)
    qreads=frozenset()
    for t in post:
        qreads=free_pvs(t,registry,d,qreads)
    e=read_post(e,qreads,d)
    d.map('oldie_inter',0,len(e.reads));d.visit('eff_bind_empty')
    d.map('oldie_fold',0);d.map('oldie_disjoint',len(preads),0)
    e=read_pre(preads,e,d)
    d.map('external_read_diff',len(e.reads),len(sarg))
    xreads=e.reads-sarg
    frozen=frozenset()
    d.map('freeze_read_fold',len(xreads))
    for v in sorted(xreads,key=lambda x:x.var.tag):frozen=freeze_pv(v,frozen,d)
    d.map('freeze_exception_fold',0)
    d.visit('check_tvs')
    ty_walk(result,d,'ity_v_fold')
    d.map('type_read_fold',len(e.reads))
    for v in e.reads:ty_walk(v.var.ty,d,'ity_v_fold')
    d.map('type_exception_fold',0)
    for t in pre+post:
        term_types(t,d);d.map('type_variable_subset',0,0)
    d.map('exception_filter_diff',0,0)
    e=d.copy_effect(e) # raises, still empty
    d.map('write_cover_inter',len(e.writes),len(e.covers))
    d.map('taint_cover_inter',len(e.taints),len(e.covers))
    e=d.copy_effect(e,writes={r:fs for r,fs in e.writes.items() if r in e.covers},taints=e.taints&e.covers)
    d.visit('read_regs');d.map('read_region_fold',len(e.reads))
    rknown=set()
    for v in e.reads:
        d.visit('ity_exp_fold')
        if v.region is not None:
            d.map('reachable_region_add',len(rknown),int(v.region not in rknown));rknown.add(v.region)
    rknown=frozenset(rknown)
    d.visit('result_ity_exp_fold')
    vknown=rknown
    if result_region is not None:
        d.map('result_region_add',len(vknown),int(result_region not in vknown));vknown |= {result_region}
    d.map('raised_region_fold',0)
    d.map('known_write_inter',len(e.writes),len(rknown))
    d.map('known_cover_inter',len(e.covers),len(rknown))
    d.map('known_reset_inter',len(e.resets),len(vknown))
    e=d.copy_effect(e,writes={r:fs for r,fs in e.writes.items() if r in rknown},covers=e.covers&rknown,resets=e.resets&vknown)
    e=reset_taints(e,d)
    d.visit('eff_escape');d.map('escape_singleton',1)
    result_key=('region',result_region.tag) if result_region else ('pure',result)
    escape={result_key:result};d.map('escape_exception_fold',0)
    d.map('escape_write_fold',len(e.writes))
    for r,fs in e.writes.items():
        d.visit('its_match_regs');d.visit('its_match_args');d.records['ity_subst']+=1
        d.map('escape_field_fold',len(fs))
        for f in fs:
            d.visit('ity_full_inst');ty_walk(f.ty,d,'ity_closed')
            key=('pure',f.ty)
            d.map('escape_type_add',len(escape),int(key not in escape));escape[key]=f.ty
    d.map('escape_type_fold',len(escape))
    for ty in escape.values():ty_walk(ty,d,'ity_rch_vars_upper')
    d.map('spoil_inter',0,0);e=d.copy_effect(e)
    if defensive:
        d.map('defensive_reset_diff',len(vknown),len(rknown))
        d.map('defensive_reset_union',len(e.resets),len(vknown-rknown))
        e=d.copy_effect(e,resets=e.resets | (vknown-rknown))
    e=d.copy_effect(e,reads=xreads)
    d.records['cty']+=1;d.visit('cty_unsafe');d.visit('mask_adjust')
    mask='ghost' if e.ghost else 'visible' if result==UNIT else mask
    return Contract(args,pre,post,e,result,result_region,frozen,mask)


def apply_same(c,actuals,result,d):
    """Saturated ground-pure parameters/result, no promotion, no oldies.

    External effects/frozen region maps are retained and may be nonempty.
    Region parameters/results, type variables and exceptional posts are
    distinct caller partitions, not silently zero-cost cases.
    """
    d.visit('cty_apply')
    if c.result_region is not None or any(v.region is not None for v in c.args+actuals):
        raise ValueError('reference application belongs to residual partition')
    if len(c.args)!=len(actuals):raise ValueError('unsaturated application residual')
    vsb={}
    for u,v in zip(c.args,actuals):
        d.visit('apply_pair')
        if v.ghost and not u.ghost and not c.effect.ghost:
            raise ValueError('ghost-promotion source gate required')
        ty_walk(u.var.ty,d,'ity_match')
        if u.var.ty!=v.var.ty:d.fail('TypeMismatch')
        if u.var!=v.var:
            d.map('formal_actual_add',len(vsb),1);vsb[u.var]=v
    d.visit('apply_end');d.visit('cut_empty')
    d.records.update(apply_result_tuple=1,cut_result_tuple=1,oldie_result_pair=1)
    if vsb:d.map('oldie_rebuild_fold',0)
    d.map('actual_term_map',len(vsb))
    terms={u:k.var(v.var) for u,v in vsb.items()}
    d.records['actual_tvar']+=len(terms)
    if c.result!=result:
        ty_walk(c.result,d,'result_ity_match');d.fail('TypeMismatch')
    if not actuals:
        d.visit('cty_apply_return_original');return c
    d.visit('eff_ghostify_no_promotion')
    reads=set()
    for v in actuals:
        d.map('actual_read_add',len(reads),int(v not in reads));reads.add(v)
    e=read_pre(frozenset(reads),c.effect,d)
    d.map('type_substitution_map',0)
    bd=b.Demand(d.kernel)
    pre,post,xpost=b.cty_specs(c.pre,c.post,{}, {},terms,True,bd)
    assert not xpost and not bd.hsty_requests_upper
    d.calls.update(bd.calls)
    d.records['spec_list_cons']+=len(pre)+len(post)
    d.map('exceptional_spec_map',0)
    d.records['cty']+=1;d.visit('cty_unsafe');d.visit('mask_adjust')
    return Contract((),pre,post,e,result,None,c.freeze,c.mask)


def unit_tuple(d):
    """cty_tuple [] after the already-counted cty_apply, warm arity zero."""
    d.visit('cty_tuple_unit')
    d.memo_reads.update(ts_tuple=2,fs_tuple=1,its_tuple=1)
    d.owner_requests.update(Hsty=2,Hsity=1)
    v=d.fresh_result()
    value=k.node('app',ty=UNIT,symbol='Tuple0')
    eq=k.node('app',k.var(v),value,symbol='=')
    # Equality's polymorphic type matcher does two Mtv.change operations;
    # tuple's nullary result matcher visits its one already resolved type.
    d.visit('ty_match',3)
    d.map('unit_equality_type_change',0,1);d.map('unit_equality_type_change',1,0)
    post=k.close('eps',(v,),eq,d.kernel)
    d.records.update(tuple_tvar=1,tuple_application=1,equality_application=1,
                     equality_argument_cons=2,post_list_cons=1,mask_tuple=1,cty=1,
                     discarded_rho_preid=1,ity_match_smart_pair=1)
    d.visit('mask_reduce');d.visit('ity_tuple');d.visit('eff_read_empty')
    d.visit('cty_unsafe');d.visit('mask_adjust')
    return Contract((),(),(post,),Effect(),UNIT)


def c_app(c,actuals,result,d,*,unit=False,constructor_one=False):
    d.visit('c_app')
    out=apply_same(c,actuals,result,d)
    d.visit('is_rs_tuple')
    if unit or constructor_one:
        # is_fs_tuple probes the ID table for every RLls with ls_constr=1,
        # including an ordinary immutable-record constructor that is not a
        # tuple. This flag is source rsymbol metadata, not a numeric demand.
        d.memo_reads['fs_tuple_ids.mem']+=1
    if unit:
        if actuals or c.args or result!=UNIT:raise ValueError('only ordinary Unit tuple row')
        d.visit('prior_contract_discarded')
        out=unit_tuple(d)
    d.records.update(capp_node=1,cexp=1)
    return out
