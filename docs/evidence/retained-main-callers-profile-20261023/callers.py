"""Source-caller continuation; imports immutable construction freeze 767007.

This remains a working implementation until the complete caller/body join and
its source correspondence have been checked. No compiler or prover is run.
"""
from pathlib import Path
import importlib.util
import sys

_BASE = Path(__file__).resolve().parents[1] / 'retained-main-construction-profile-20261023/algebra.py'
_spec = importlib.util.spec_from_file_location('silver_main_construction_767007', _BASE)
base = importlib.util.module_from_spec(_spec)
sys.modules[_spec.name] = base
_spec.loader.exec_module(base)


def signature(symbol, arg_types, result_type, source, *, route='RKfunc'):
    xs = tuple(base.var(f'a{i}', t) for i, t in enumerate(arg_types))
    r = base.var('result', 'bool' if result_type == 'prop' else result_type)
    f = base.app(symbol, *xs, ty=result_type)
    post = (base.connective('iff', base.app('=', r, base.BTRUE), f)
            if result_type == 'prop' else base.app('=', r, f))
    return base.Signature(symbol, tuple(arg_types), result_type, route, (), post, source)


def catalogue():
    c = base.catalogue()
    def add(name, args, result, source, route='RKfunc'):
        c[name] = signature(name, args, result, source, route=route)
    add('Integer.length', ('int','int'), 'int', '_gnatprove_standard.mlw:236-237', 'RKnone explicit equality')
    for op in ('eq','ne','lt','le','gt','ge'):
        add('Integer.bool_' + op, ('int','int'), 'bool', '_gnatprove_standard.mlw:223-234', 'RKnone explicit equality')
    add('=', ('any','any'), 'prop', 'int.mlw:16 / Cpur equality; both result=True iff x=y', 'selected equality program route')
    add('Array.bool_eq', ('map','int','int','map','int','int'), 'bool',
        'why-gen-arrays.adb:2131-2192; converter:1067-1090', 'RKnone explicit logical equality')
    add('Array.compare', ('map','int','int','map','int','int'), 'int', 'ada__model.mlw:1326')
    add('Boolean.notb', ('bool',), 'bool', 'bool.mlw: Bool.notb')
    add('Integer.image', ('int',), 'image', 'ada__model.mlw:46')
    add('String.to_string', ('image','int'), 'string', 'why-gen-arrays.adb:1657-1667; Pterm no explicit spec')
    n, r = base.var('a0'), base.var('result')
    pre = base.app('Standard.Positive.in_range', n)
    c['Standard.Positive.range_check'] = base.Signature(
        'Standard.Positive.range_check', ('int',), 'int', 'RKnone', (pre,),
        base.connective('and', base.app('=',r,n),pre), 'ada__model.mlw:86-89; Positive clone')
    return c


def constant(b, value, ty='int'):
    return b.node('constant', ty, key=str(value))


def pack(b, value, shape, domain):
    return (base.array_map(b,shape,value,domain),
            base.array_attr(b,shape,value,'first'),base.array_attr(b,shape,value,'last'))


def length_from_bounds(b, first, last, domain):
    return b.call('Integer.length','int',first,last,domain=domain)


def concat(b, left, right, left_shape, right_shape, *, positive_last,
           static_left_empty=False, domain='prog'):
    """gnat2why-expr:21976-22351, two ordinary String operands.

    Return (native expression, static result shape or None for Standard.String).
    Static-empty-left returns the right representation; caller expected-type
    conversion remains responsible for reconciling it with the context.
    """
    b.require_owned(left,right,positive_last)
    if left.ty != left_shape.ty or right.ty != right_shape.ty:
        raise ValueError('source representation mismatch')
    if static_left_empty and not left_shape.static:
        raise ValueError('only a static shape establishes this early branch')
    l = b.temporary(left)
    r = b.temporary(right)
    first = base.array_attr(b,left_shape,l,'first')
    if static_left_empty:
        # Right_First is eagerly constructed by the native source, but unused.
        base.array_attr(b,right_shape,r,'first')
        t = r
        result_shape = right_shape
    else:
        args = pack(b,l,left_shape,domain) + pack(b,r,right_shape,domain)
        rf = base.array_attr(b,right_shape,r,'first')
        rl = base.array_attr(b,right_shape,r,'last')
        no_slide_last = b.call('Int.+','int',positive_last,
                              length_from_bounds(b,rf,rl,domain),domain=domain)
        # Native New_Concat_Call tags this with the result Ada array type;
        # the declared logical symbol nevertheless returns its map type.
        m = b.call('Array.concat','string',*args,no_slide_last,domain=domain)
        left_len = length_from_bounds(b,base.array_attr(b,left_shape,l,'first'),
                                     base.array_attr(b,left_shape,l,'last'),domain)
        right_len = length_from_bounds(b,base.array_attr(b,right_shape,r,'first'),
                                      base.array_attr(b,right_shape,r,'last'),domain)
        lengths = b.call('Int.+','int',left_len,right_len,domain=domain)
        last = b.call('Int.-','int',b.call('Int.+','int',first,lengths,domain=domain),
                      constant(b,1),domain=domain)
        if domain == 'prog':
            last = b.call('Standard.Positive.range_check','int',last,domain=domain)
        # The subsequent representation conversion is identity for Integer.
        t = b.call('String.of_array','string',m,first,last,domain=domain)
        result_shape = None
    if not left_shape.static:
        rf = base.array_attr(b,right_shape,r,'first')
        rl = base.array_attr(b,right_shape,r,'last')
        right_map = base.array_map(b,right_shape,r,domain)
        right_value = b.call('String.of_array','string',right_map,rf,rl,domain=domain)
        left_length = b.call('String.length','int',l)
        condition = b.call('=','bool',left_length,constant(b,0),domain='pred')
        t = b.node('if','string',condition,right_value,t,domain=domain)
    # Source consumes the left first, so right is the outer binding.
    t = b.binding(l,t,domain)
    t = b.binding(r,t,domain)
    return t,result_shape


def compare(b, op, left, right, left_shape, right_shape, *, domain='prog'):
    """gnat2why-expr:18547-18735 helper, initialized String operands.

    Ordinary source String /= is expanded to not (=) before this helper;
    source.Fold normalizes it. The direct /= row remains a generic helper row.
    """
    if op not in {'=','/=','<','<=','>','>='}:
        raise ValueError('uncovered comparison')
    # Insert_Initialization_Check eagerly asks for temps, then returns each
    # original initialized expression. These discarded pending entries are
    # allocation state, not emitted body binders (why-gen-init:502-554).
    equality = op in {'=','/='}
    b.temporary(left)
    if equality:
        b.temporary(right)
        l,r = b.temporary(left),b.temporary(right)
    else:
        l = b.temporary(left)
        b.temporary(right)
        r = b.temporary(right)
    subdomain = 'term' if domain == 'pred' else domain
    args = pack(b,l,left_shape,subdomain)+pack(b,r,right_shape,subdomain)
    t = b.call('Array.bool_eq' if equality else 'Array.compare',
               'bool' if equality else 'int',*args,domain=subdomain)
    t = b.binding(l,t,domain)
    t = b.binding(r,t,domain)
    if equality:
        if domain == 'pred':
            eq = b.call('=','bool',t,constant(b,'True','bool'),domain=domain)
            t = b.node('not','bool',eq,domain=domain) if op == '/=' else eq
        elif op == '/=':
            t = b.call('Boolean.notb','bool',t,domain=domain)
    else:
        symbol = ('Integer.bool_' + {'<':'lt','<=':'le','>':'gt','>=':'ge'}[op]
                  if domain == 'term' else 'Int.' + op)
        t = b.call(symbol,'bool',t,constant(b,0),domain=domain)
    return t


def integer_image(b, value, maximum_image_size, *, domain='prog'):
    """gnat2why-expr:20256-20300; outer expected-type conversion is separate."""
    image = b.call('Integer.image','image',value,domain=domain)
    return b.call('String.to_string','string',image,constant(b,maximum_image_size),domain=domain)


def array_length(b,value,shape,*,static_length=None):
    """Get_Array_Attr Length; caller expected-type conversion is separate."""
    if shape.static:
        if static_length is None:
            raise ValueError('static source shape must supply its derived length')
        return constant(b,static_length)
    return b.call('String.length','int',value)


def object_length(b, prefix_read, shape, *, binder_kind, binder_value=None,
                  first_rep=None, last_rep=None, static_length=None, domain='prog'):
    """Name'Length, including eager prefix/temp and binder fast path.

    Source19903-20101 and arrays2894-2928. Integer-representation bound trees
    include any required conversion from the binder's stored abstract bounds.
    """
    tmp = b.temporary(prefix_read)
    if binder_kind == 'split':
        if shape.static or first_rep is None or last_rep is None:
            raise ValueError('split unconstrained binder and complete bound trees required')
        t = length_from_bounds(b,first_rep,last_rep,'term')
    elif binder_kind == 'regular':
        if shape.static:
            if static_length is None:
                raise ValueError('derived static length required')
            t = constant(b,static_length)
        else:
            if binder_value is None:
                raise ValueError('regular binder identifier required')
            t = b.call('String.length','int',binder_value)
    else:
        raise ValueError('ordinary source name binder required')
    return b.binding(tmp,t,domain) if domain == 'prog' else t


def scalar_operation(b,op,children,*,overflow_symbol=None,domain='prog'):
    if op not in {'+','-','*','neg','pos'}:
        raise ValueError('uncovered ordinary Integer operator')
    if op in {'neg','pos'} and len(children)!=1 or op in {'+','-','*'} and len(children)!=2:
        raise ValueError('operator arity')
    t = children[0] if op == 'pos' else b.call('Int.'+op,'int',*children,domain=domain)
    if domain == 'prog' and overflow_symbol is not None:
        t = b.call(overflow_symbol,'int',t,domain=domain)
    return t


def scalar_expected(b,value,*,range_symbol=None,domain='prog'):
    # Split Integer/base-Integer conversions only retag; optional selected
    # nonempty static target range-check is the sole retained call.
    return (b.call(range_symbol,'int',value,domain=domain)
            if domain == 'prog' and range_symbol is not None else value)
