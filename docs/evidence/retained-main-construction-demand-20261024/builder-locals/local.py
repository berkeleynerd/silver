"""Local representation safety, extending the accepted request partition.

No new cumulative byte coefficient, aggregate RAM/stack gate or admission
input. The finite input-shape witness includes stored list spines, while
accepted construction/owner requests retain their original meaning.
"""
from collections import Counter
import importlib.util
import json
from pathlib import Path
import sys

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('accepted_builders',HERE.parent/'contract-builders/builders.py')
b=importlib.util.module_from_spec(sp);sys.modules[sp.name]=b;sp.loader.exec_module(b)
k=b.k


class Demand(b.Demand):
    def __post_init__(self):
        super().__post_init__()
        self.input_shape=Counter()
        self.entries=Counter()
        self.type_arities=Counter()
        self.domain_supported=True

    def type_shape(self,ty):
        if ty is None:return
        if not isinstance(ty,b.Ty):raise ValueError('source type record required')
        self.input_shape['type_occurrences']+=1
        self.input_shape['type_argument_list_cells']+=len(ty.args)
        self.type_arities[len(ty.args)]+=1
        for arg in ty.args:self.type_shape(arg)

    def term_shape(self,t):
        self.input_shape['term_occurrences']+=1
        self.type_shape(t.ty)
        if isinstance(t,b.b.Case):
            self.term_shape(t.subject)
            self.input_shape['case_branch_list_cells']+=len(t.branches)
            for p,bb in t.branches:self.pattern_shape(p);self.binding_shape(bb)
            return
        self.input_shape['term_child_slots']+=len(t.args)
        for child in t.args:self.term_shape(child)
        if t.binding is not None:self.binding_shape(t.binding)

    def pattern_shape(self,p):
        self.input_shape['pattern_occurrences']+=1;self.type_shape(p.ty)
        self.input_shape['pattern_child_slots']+=len(p.children)
        for q in p.children:self.pattern_shape(q)

    def binding_shape(self,bb):
        self.input_shape['binder_variable_list_cells']+=len(bb.variables)
        for v in bb.variables:self.type_shape(v.ty)
        self.input_shape['trigger_group_list_cells']+=len(bb.triggers)
        for group in bb.triggers:
            self.input_shape['trigger_term_list_cells']+=len(group)
            for t in group:self.term_shape(t)
        self.input_shape['saved_bindings']+=len(bb.saved)
        for v,t in bb.saved.items():self.type_shape(v.ty);self.term_shape(t)
        self.input_shape['cached_free_bindings']+=len(bb.free)
        self.term_shape(bb.body)

    def contract_shape(self,args,pre,post,e,result):
        self.input_shape['formal_list_cells']+=len(args)
        self.input_shape['specification_list_cells']+=len(pre)+len(post)
        for v in args:self.type_shape(v.var.ty)
        self.type_shape(result)
        for t in pre+post:self.term_shape(t)
        self.input_shape['effect_bindings']+=len(e.reads)+len(e.writes)+len(e.taints)+len(e.covers)+len(e.resets)
        for v in e.reads:self.type_shape(v.var.ty)
        for r,fields in e.writes.items():
            self.type_shape(r.ty)
            self.input_shape['written_field_bindings']+=len(fields)
            for f in fields:self.type_shape(f.ty)

    def local_export(self):
        native=json.loads((HERE/'native-census.json').read_text())
        original=super().export()
        maximum=max(self.type_arities,default=0)
        header_ok=native['maximum_heap_reservation_bytes']//8-1<=2**54-1
        length_ok=maximum<=k.MAX_INT
        source_domain=self.domain_supported and maximum<=2
        return {
          'accepted_request_vector':original,
          'entries':dict(self.entries),
          'input_structure_witness':dict(sorted(self.input_shape.items())),
          'input_structure_is_mathematical_not_native_trace':True,
          'maximum_observed_type_argument_arity':maximum,
          'type_argument_arity_histogram':dict(sorted(self.type_arities.items())),
          'native_local_request_ceiling_bytes':native['maximum_heap_reservation_bytes'],
          'native_local_payload_words_upper':native['maximum_heap_reservation_bytes']//8-1,
          'native_local_header_representable':header_ok,
          'type_list_length_guard':length_ok,
          'current_Main_source_type_arity_bound':2,
          'observed_diagram_within_source_arity_bound':maximum<=2,
          'accepted_partition_domain_supported':self.domain_supported,
          'new_local_counter_increments':0,
          'new_local_size_scaled_blocks':0,
          'new_local_representation_safety_closed':header_ok and length_ok and source_domain,
          'finite_local_traversal_under_source_input_premise':source_domain,
          'complete_native_bytes':False,
          'cumulative_local_bytes_computed':False,
          'cumulative_local_bytes_required_for_representation_safety':False,
          'legacy_new_helper_byte_gap_disposition':'fixed request sizes and finite traversal discharge local representation safety; no aggregate physical byte total is required',
          'shared_hashcons_backing_and_lookup_services_closed':False,
          'remaining_representation_obligations':[
              'shared hashcons owner endpoints, per-request backing sizes and callback arithmetic',
              'Wvs and strong memo backing/lookup service contracts',
              'remaining source-derived candidate and caller multiplicities',
              'residual builder site families and later kode/SPWP/continuation construction'],
          'aggregate_physical_memory_or_stack_gate':False,
        }


def create_cty(args,pre,post,e,result,registry,d,**kwargs):
    d.entries['create_cty']+=1
    d.contract_shape(args,pre,post,e,result)
    try:return b.create_cty(args,pre,post,e,result,registry,d,**kwargs)
    except ValueError:
        d.domain_supported=False
        raise


def c_app(c,actuals,result,d,**kwargs):
    d.entries['c_app']+=1
    d.contract_shape(c.args,c.pre,c.post,c.effect,c.result)
    d.input_shape['actual_argument_list_cells']+=len(actuals)
    for v in actuals:d.type_shape(v.var.ty)
    d.type_shape(result)
    try:return b.c_app(c,actuals,result,d,**kwargs)
    except ValueError:
        d.domain_supported=False
        raise
