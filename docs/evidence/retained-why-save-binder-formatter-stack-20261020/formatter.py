"""Selected Format and internal name/constant interfaces, to explicit imports."""
import re
import struct

def closure(bodies, names, bytes_at, spec):
    imports=set(spec['imports'])
    assert imports<=set(bodies),imports-set(bodies)
    todo=spec['roots'][:]
    seen=set();front=set();rows={}
    services={'caml_blit_bytes','caml_blit_string','caml_c_call','caml_call_gc',
      'caml_create_bytes','caml_fill_bytes','caml_format_float','caml_format_int',
      'caml_int_of_string','caml_ml_array_bound_error','caml_ml_flush','caml_ml_output',
      'caml_modify','caml_raise_exn','caml_string_equal','caml_string_notequal','ml_z_format'}
    def created(v):
        entries=set();constants=[]
        for a,n in re.findall(r'# ([0-9a-f]+) <([^>+]+)>',v):
            if n in bodies:entries.add(n)
            elif re.fullmatch(r'caml\w+__\d+',n):
                words=struct.unpack('<3Q',bytes_at(int(a,16),24))
                targets=[names[x] for x in words if x in names]
                if targets:
                    entries.update(targets)
                    constants.append(dict(address=a,symbol=n,words=list(words),code_entries=targets))
        return entries,constants
    while todo:
        n=todo.pop()
        if n in imports|services:front.add(n);continue
        if n in seen:continue
        assert n.startswith(('camlStdlib__','camlCamlinternalFormat__','camlWhy3__Ident__','camlWhy3__Termcode__','camlZ__','caml_apply','caml_curry')),n
        seen.add(n);v=bodies[n]
        direct=set(x.split('+')[0] for x in re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>',v))
        factories,constants=created(v)
        selected=set(spec['select'].get(n,direct|factories))
        assert selected<=direct|factories,(n,selected-direct-factories)
        if n in spec['select']:assert n in spec['selection_reasons']
        sites=re.findall(r'^\s*([0-9a-f]+):.*\b(?:call|jmp)\s+\*([^\n]+)',v,re.M)
        switches=spec['local_switches'].get(n,[])
        excluded=spec['excluded_indirect_sites'].get(n,{})
        assert set(switches)|set(excluded)<=set(a for a,_ in sites)
        calls=[s for s in sites if s[0] not in set(switches)|set(excluded)]
        assert not calls or n in spec['extra'],(n,calls)
        callbacks=spec['extra'].get(n,[])
        # Direct C bridge operands and direct primitives are named services.
        ctargets=sorted(x for x in factories if x in services)
        if 'caml_c_call' in selected:assert ctargets,(n,'unnamed C bridge target')
        rows[n]=dict(direct=sorted(direct),created_closure_entries=sorted(factories),
          static_closures=constants,selected_direct_or_created=sorted(selected),
          excluded_direct_or_created=sorted((direct|factories)-selected),
          exclusion_reason=spec['selection_reasons'].get(n),indirect_sites=sites,
          local_constructor_switches=switches,source_excluded_indirect_sites=excluded,
          selected_indirect_targets=callbacks,concrete_service_operands=ctargets)
        todo+=list((selected|set(callbacks))-{n})
    assert imports<=front,imports-front
    # Exact static identity continuation used by asprintf and inlined callers.
    words=struct.unpack('<3Q',bytes_at(0xf8aa60,24))
    assert names[words[0]]=='camlStdlib__Format__id_267'
    entry=bodies['camlStdlib__Format__entry']
    assert '# f8aa60 <camlStdlib__Format__154>' in entry
    assert 'mov    %rax,0x4d0(%rbx)' in entry
    # Tail loops do not acquire a fresh own frame per queue item/string byte.
    loops={}
    for n in seen:
        if n=='camlStdlib__Format__output_acc_1688':continue
        assert not re.search(r'\bcall\s+[0-9a-f]+ <'+re.escape(n)+r'(?:\+[^>]*)?>',bodies[n]),n
        backs=[]
        for m in re.finditer(r'^\s*([0-9a-f]+):[^\n]*\bj\w*\s+([0-9a-f]+) <'+re.escape(n)+r'(?:\+[^>]*)?>',bodies[n],re.M):
            if int(m[2],16)<int(m[1],16):backs.append([m[1],m[2]])
        if backs:loops[n]=backs
    return dict(roots=spec['roots'],bodies=sorted(seen),imports=sorted(imports),
      services=sorted(front-imports),transfers=rows,tail_backedges=loops,
      identity_continuation=dict(address='0xf8aa60',words=list(words),target=names[words[0]],module_slot='0x4d0'),
      claim='Selected formatter, const_shape and sn_decode closure to explicit serializer callbacks and native services; excludes imported descendants.')
