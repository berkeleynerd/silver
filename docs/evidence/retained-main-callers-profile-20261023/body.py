"""Working body-constructor/projection continuation, before full #178 audit."""
from dataclasses import dataclass
from collections import Counter
import callers
base = callers.base


@dataclass(frozen=True)
class Expr:
    op: str
    ty: str
    args: tuple = ()
    key: str = ''
    terms: tuple = ()
    # Unit Cfun/while/handler structural metadata, not a scalar child cover.
    detail: tuple = ()


def sequence(b, *items):
    items = tuple(n for n in items if n.op != 'unit')
    if not items:
        return b.node('unit','unit')
    out = items[-1]
    for n in reversed(items[:-1]):
        out = b.node('sequence',out.ty,n,out,domain='prog')
    return out


def fresh(b, ty):
    return b.node('identifier',ty,key=f'tmp:{b.serial+1}')


def let(b, name, definition, context):
    return b.node('binding',context.ty,definition,context,key=name.key,domain='prog')


def assume(b, predicate):
    return b.node('assume','unit',predicate,domain='prog')


def assign(b, ref, value):
    if not ref.ty.endswith('__ref'):
        raise ValueError('whole-object assignment needs a flat reference')
    return b.node('assignment','unit',ref,value,key=ref.ty[:-5]+'__content',domain='prog')


def read_ref(b, ref):
    if not ref.ty.endswith('__ref'):
        raise ValueError('expected flat reference')
    ty = ref.ty[:-5]
    return b.node('deref',ty,ref,key=ty+'__content')


def read_object(b, reference, *, shape=None, first=None, last=None):
    value = read_ref(b,reference)
    if shape is not None and not shape.static:
        if first is None or last is None:
            raise ValueError('split object requires full bound trees')
        return b.call('String.of_array','string',value,first,last)
    return value


def initialize(b, initializer, target, *, mutable, split=False,
               bound_first=None, bound_last=None):
    """Assignment_Of_Obj_Decl:1622-1668,1756-1819; supplied converted initializer."""
    if split:
        if not mutable or initializer.ty != 'string' or target.ty != 'map__ref':
            raise ValueError('ordinary mutable UCArray initializer premise')
        if bound_first is None or bound_last is None:
            raise ValueError('complete converted binder bounds required')
        tmp = fresh(b,'string')
        init_map = b.call('String.to_array','map',tmp,domain='prog')
        first = b.call('String.first','int',tmp)
        last = b.call('String.last','int',tmp)
        context = sequence(b,assign(b,target,init_map),
                           assume(b,b.call('=','bool',bound_first,first,domain='pred')),
                           assume(b,b.call('=','bool',bound_last,last,domain='pred')))
        return let(b,tmp,initializer,context)
    if mutable:
        return assign(b,target,initializer)
    tmp = fresh(b,initializer.ty)
    # Actual source order is temporary = object (gnat2why-expr:1795-1817).
    eq = b.call('=','bool',tmp,target,domain='pred')
    return let(b,tmp,initializer,assume(b,eq))


def invariant(b, value, *, policy, predicate='', initialized=True, only_var=False,
              top_predicate=True, all_global=True, scalar_bounds=None):
    """Ordinary dynamic-invariant branches; source shape chooses the policy."""
    if policy == 'true':
        return b.node('constant','prop',key='true',domain='pred')
    if policy == 'named':
        if not predicate:
            raise ValueError('selected type predicate required')
        flags = [callers.constant(b,'True' if v else 'False','bool')
                 for v in (initialized,only_var,top_predicate,all_global)]
        return b.call(predicate,'bool',value,*flags,domain='pred')
    if policy == 'well-formed':
        if not predicate:
            raise ValueError('selected array well-formed predicate required')
        return b.call(predicate,'bool',value,domain='pred')
    if policy == 'scalar':
        if not predicate or scalar_bounds is None:
            raise ValueError('selected dynamic property and complete static bound trees required')
        # Ordinary scalar ranges are nonempty; no initialized-or-empty guard.
        return b.call(predicate,'bool',*scalar_bounds,value,domain='pred')
    raise ValueError('uncovered invariant policy')


def invariant_suffix(b, initialization, object_read, **policy):
    inv = invariant(b,object_read,**policy)
    if inv.op == 'constant' and inv.ty == 'prop' and inv.key == 'true':
        return initialization
    return sequence(b,initialization,assume(b,inv))


def string_assignment(b, rhs, rhs_shape, target_ref, target_shape, *,
                      target_read, binder_shape, check_target_lengths,
                      final_sliding=False):
    """Whole identifier target: Transform_Assignment + New_Assignment.

    rhs has already undergone Transform_Prog's expected-type conversion. Each
    additional conversion remains explicit; the second same-type conversion
    is still invoked (its body is identity under the ordinary type premise).
    """
    b.require_owned(rhs,target_ref,target_read)
    tmp = b.temporary(rhs,need=check_target_lengths)
    t = rhs
    if check_target_lengths:
        old = b.temporary(target_read)
        pred = base.length_equality(b,base.array_attr(b,rhs_shape,tmp,'first'),
                                    base.array_attr(b,rhs_shape,tmp,'last'),
                                    base.array_attr(b,target_shape,old,'first'),
                                    base.array_attr(b,target_shape,old,'last'))
        t = sequence(b,b.node('assert','unit',pred,domain='prog'),tmp)
        t = b.binding(old,t)
    # EW_Pterm forbids new checks; projection still follows the caller E mode.
    t = base.array_conversion(b,t,rhs_shape,binder_shape,sliding=final_sliding,domain='term')
    t = b.binding(tmp,t)
    moved = b.temporary(t,need=False)
    # New_Assignment invokes a second conversion to the same target entity.
    moved = base.array_conversion(b,moved,binder_shape,binder_shape,domain='term')
    value = moved if binder_shape.static else b.call('String.to_array','map',moved,domain='prog')
    result = assign(b,target_ref,value)
    return b.binding(moved,result)


def observe(b,condition,branch_ref):
    """New_Counterexample_Assign:4728-4758; condition occurs once."""
    return sequence(b,assign(b,branch_ref,condition),read_ref(b,branch_ref))


def ignore(b,stmt):
    return b.node('ignore','unit',stmt,domain='prog')


def warning(b,stmt,enabled):
    if not enabled:
        return stmt
    false = b.node('constant','prop',key='false',domain='pred')
    check = b.node('check','unit',false,domain='prog')
    # Comments/location labels have no additional typed body/term skeleton.
    return sequence(b,comment(b,'dead branch/code'),ignore(b,check),stmt)


def source_if(b,conditions,bodies,otherwise,branch_ref,*,warn):
    if len(conditions) != len(bodies) or len(warn) != len(bodies)+1:
        raise ValueError('one condition/body per if/elsif and one else flag')
    out = warning(b,otherwise,warn[-1])
    for condition,arm,flag in reversed(tuple(zip(conditions,bodies,warn))):
        out = b.node('if','unit',observe(b,condition,branch_ref),warning(b,arm,flag),out,domain='prog')
    return out


def pure_no_vcs(n):
    if n.op in {'identifier','constant','unit','assume'}:
        # Resolved nullary symbols are syntactic Eident; the converter's test
        # deliberately classifies them by Ptree syntax at this stage.
        return True
    if n.op in {'label','binding','sequence','if','and','or','not'}:
        return all(pure_no_vcs(a) for a in n.args)
    if n.op == 'raise':
        # The converter's syntactic test is not a no-raise assertion.
        return all(pure_no_vcs(a) for a in n.args)
    return False


def term(n, signatures, want='value'):
    if n.op == 'unit':
        if want != 'value': raise ValueError('unit is not a proposition')
        return base.atom('()','unit')
    if n.op == 'label':
        return term(n.args[0],signatures,want)
    if n.op == 'epsilon':
        if want != 'value': raise ValueError('epsilon result requires value context')
        return base.Term('epsilon',(term(n.args[0],signatures,'prop'),),n.key,n.ty)
    if n.op == 'not':
        t = base.connective('not',term(n.args[0],signatures,'prop'))
    elif n.op in {'and','or','implies'}:
        t = base.connective(n.op,*(term(x,signatures,'prop') for x in n.args))
    elif n.op == 'binding':
        definition = term(n.args[0],signatures)
        body = term(n.args[1],signatures,want)
        return base.Term('let',(definition,body),n.key,body.ty)
    elif n.op == 'if':
        condition = term(n.args[0],signatures,'prop')
        yes,no = term(n.args[1],signatures,want),term(n.args[2],signatures,want)
        t = base.connective('if',condition,yes,no,ty=yes.ty)
    elif n.op in {'call','deref'}:
        args = tuple(term(x,signatures) for x in n.args)
        s = base.validate_call(n.key,args,signatures)
        t = base.app(n.key,*args,ty=s.result_type)
    else:
        return base.term(n,signatures,want)
    if want == 'value' and t.ty == 'prop':
        return base.connective('if',t,base.BTRUE,base.BFALSE,ty='bool')
    if want == 'prop' and t.ty != 'prop':
        if t.ty != 'bool':
            raise ValueError('non-Boolean value in proposition context')
        return base.app('=',t,base.BTRUE)
    return t


def project(n, signatures):
    if n.op == 'label':
        return project(n.args[0],signatures)
    if n.op == 'constant' and n.ty in {'bool','unit'}:
        key = 'unit.()' if n.ty == 'unit' else 'bool.'+n.key
        return Expr('application',n.ty,key=key)
    if n.op in {'unit','comment'}:
        return Expr('application','unit',key='unit.()')
    if n.op == 'identifier':
        if n.symbol_identifier:
            base.validate_call(n.key,(),signatures)
            return Expr('application',n.ty,key=n.key)
        return Expr('variable',n.ty,key=n.key)
    if n.op == 'constant':
        return Expr('constant',n.ty,key=n.key)
    if n.op in {'call','deref'}:
        args = tuple(project(a,signatures) for a in n.args)
        s = base.validate_call(n.key,args,signatures)
        if s.route == 'logic-only':
            raise ValueError('missing program binding for '+n.key)
        return Expr('application','bool' if s.result_type=='prop' else s.result_type,args,n.key)
    if n.op == 'assignment':
        args=tuple(project(a,signatures) for a in n.args)
        if len(args)!=2 or not args[0].ty.endswith('__ref') or args[1].ty!=args[0].ty[:-5]:
            raise ValueError('typed whole-object assignment mismatch')
        return Expr('assignment','unit',args,n.key)
    if n.op in {'binding','sequence','if','and','or','not'}:
        return Expr(n.op,n.ty,tuple(project(a,signatures) for a in n.args),n.key)
    if n.op in {'assert','assume','check'}:
        return Expr(n.op,'unit',terms=(term(n.args[0],signatures,'prop'),))
    if n.op == 'any-unit':
        # Any_expr:731-758 is let _f = any() requires P ensures True in _f.
        key = f'tmp:any:{n.uid}'
        any_call = Expr('any','unit',terms=(term(n.args[0],signatures,'prop'),base.TRUE))
        return Expr('binding','unit',(any_call,Expr('variable','unit',key=key)),key=key)
    if n.op == 'raise':
        payload = tuple(project(a,signatures) for a in n.args)
        if not payload:
            payload = (Expr('application','unit',key='unit.()'),)
        return Expr('raise','unit',payload,n.key)
    if n.op == 'try':
        return Expr('try','unit',tuple(project(a,signatures) for a in n.args),n.key,
                    detail=('singleton-unit-handler',))
    if n.op == 'loop':
        before = project(n.args[0],signatures)
        after = project(n.args[1],signatures)
        unit = Expr('application','unit',key='unit.()')
        true = Expr('application','bool',key='bool.True')
        loop_body = Expr('sequence','unit',(after,Expr('sequence','unit',(before,unit))))
        loop = Expr('while','unit',(true,loop_body),detail=('empty-user-invariants','empty-variants'))
        return Expr('sequence','unit',(before,loop))
    if n.op == 'ignore':
        if pure_no_vcs(n.args[0]):
            return Expr('application','unit',key='unit.()')
        child = project(n.args[0],signatures)
        unit = Expr('application','unit',key='unit.()')
        inner = Expr('binding','unit',(child,unit),key=f'tmp:discard:{n.uid}:inner')
        function_body = Expr('binding','unit',(inner,unit),key=f'tmp:discard:{n.uid}:outer')
        return Expr('unit-cfun','unit',(function_body,),terms=(base.TRUE,))
    raise ValueError('uncovered body constructor '+n.op)


def catalogue():
    c = callers.catalogue()
    for key,ty in [('bool.True','bool'),('bool.False','bool'),('unit.()','unit')]:
        c[key] = callers.signature(key,(),ty,'expr.ml:938-951; nullary Boolean/unit rsymbol')
    c['Boolean.andb'] = callers.signature('Boolean.andb',('bool','bool'),'bool','bool.mlw:8-12')
    return c


def expression_nodes(p):
    if p.op not in {'application','assignment','and','or','not','unit-cfun',
                    'variable','constant','binding','sequence','if','assert',
                    'check','assume','raise','try','while','any'}:
        raise ValueError('uncovered typed expression '+p.op)
    child = sum(expression_nodes(a) for a in p.args)
    if p.op == 'application':
        return 2+2*len(p.args)+child
    if p.op == 'assignment':
        return 3+child
    if p.op in {'and','or'}:
        return 2+child
    if p.op == 'not':
        return 3+child
    if p.op == 'unit-cfun':
        return 2+child
    return 1+child


def inventory(p):
    c = Counter({p.op:1})
    if p.op == 'application':
        c['call:'+p.key] += 1
        c['proxy_actual_slots'] += len(p.args)
    if p.op == 'assignment':
        c['assignment_proxy_slots'] += 2
    for t in p.terms:
        c['attached_terms'] += 1
    for child in p.args:
        c.update(inventory(child))
    return c


def comment(b, name):
    return b.node('comment','unit',key=name,domain='prog')


def true_pred(b):
    return b.node('constant','prop',key='true',domain='pred')


def syntactic_true(n):
    return n.op == 'constant' and n.key in {'true','True'}


def and_expression(b,left,right,domain):
    if syntactic_true(left):
        return right
    if syntactic_true(right):
        return left
    if domain == 'pred':
        return b.node('and','bool',left,right,domain=domain)
    return b.call('Boolean.andb','bool',left,right,domain=domain)


def range_expression(b,low,high,index,domain):
    a = b.call('Int.<=','bool',low,index,domain=domain)
    z = b.call('Int.<=','bool',index,high,domain=domain)
    return and_expression(b,a,z,domain)


def frame_condition(b, roots):
    """Ordinary whole-root write statuses from the source write-set traversal.

    Each root supplies its complete current read and loop-entry program read,
    actual status, and previously derived dynamic-invariant policy. No opaque
    state or nested loop index is admitted to this source frame root list.
    """
    predicate = true_pred(b)
    snapshots = []
    for root in roots:
        status = root['status']
        if status == 'discard':
            continue
        if status not in {'entire','not-written'}:
            raise ValueError('whole-object source frame required')
        current = root['current']
        snapshot = fresh(b,current.ty)
        # Name_For_Loop_Entry is eagerly called even when Entire_Object's
        # preservation equality returns True (Only_Vars defaults to True).
        snapshots.append((snapshot,root['entry_read']))
        if status == 'not-written':
            clause = b.call('=','bool',current,snapshot,domain='pred')
        else:
            policy = dict(root['invariant'])
            policy.setdefault('only_var',True)
            clause = invariant(b,current,**policy)
        predicate = and_expression(b,predicate,clause,'pred')
    return predicate,snapshots


def range_loop(b,low_prog,high_prog,low_term,high_term,index_ref,source_body,
               roots,*,loop_identity,reverse=False,warn_entry=False,warn_after=False):
    """Ordinary no-unrolling range row; source body is retained exactly once."""
    if index_ref.ty != 'int__ref':
        raise ValueError('ordinary signed Integer loop index required')
    low,high = fresh(b,'int'),fresh(b,'int')
    current = read_ref(b,index_ref)
    frame,snapshots = frame_condition(b,roots)
    index_inv = range_expression(b,low_term,high_term,read_ref(b,index_ref),'pred')
    # This native Prog-domain Andb is subsequently used as a logical Assume.
    implicit = and_expression(b,frame,index_inv,'prog')
    entry = range_expression(b,low,high,current,'prog')
    exit_value = low if reverse else high
    exit_condition = b.call('=','bool',current,exit_value,domain='prog')
    update = b.call('Int.-' if reverse else 'Int.+','int',current,
                    callers.constant(b,1),domain='prog')
    continue_name,exit_name = loop_identity+':continue',loop_identity+':exit'
    unit = b.node('unit','unit')
    continue_handler = b.node('try','unit',source_body,unit,key=continue_name,domain='prog')
    raise_exit = b.node('raise','unit',key=exit_name,domain='prog')
    exit_test = b.node('if','unit',exit_condition,raise_exit,unit,domain='prog')
    before = comment(b,'check loop invariant/variant')
    after = sequence(b,comment(b,'assume implicit invariant'),assume(b,implicit),
                     comment(b,'loop continuation'),continue_handler,
                     comment(b,'loop exit/update'),exit_test,assign(b,index_ref,update))
    loop = b.node('loop','unit',before,after,domain='prog')
    inner = sequence(b,comment(b,'while translating Ada loop'),loop)
    # The source mapping's iteration order determines the nesting. The caller
    # supplies this same root order; all snapshot reads occur before the loop.
    for snapshot,entry_read in snapshots:
        inner = let(b,snapshot,entry_read,inner)
    caught = b.node('try','unit',inner,unit,key=exit_name,domain='prog')
    caught = warning(b,caught,warn_entry)
    entered = b.node('if','unit',entry,caught,unit,domain='prog')
    whole = sequence(b,comment(b,'translation of Ada loop'),entered,warning(b,unit,warn_after))
    initial_value = high if reverse else low
    whole = sequence(b,assign(b,index_ref,initial_value),whole)
    # High binding first, then Low: low evaluates before high in the body.
    return let(b,low,low_prog,let(b,high,high_prog,whole))


def main_wrapper(b,declarations,statements,input_invariants):
    """Normalized Main wrapper, with retained constant/comment upper padding.

    input_invariants are only the source-selected Bytes/Count terms. Empty
    pre/post ignores become units, not Cfun. Constant comment/empty blocks are
    retained here even where the converter's sequence smart constructor drops
    them; they cannot introduce a new effect/exception or child occurrence.
    """
    if len(input_invariants) > 2:
        raise ValueError('ordinary Main has at most the two concrete input predicates')
    unit = b.node('unit','unit')
    core = sequence(b,declarations,statements,b.node('raise','unit',key='Main:return',domain='prog'))
    handled = b.node('try','unit',core,unit,key='Main:return',domain='prog')
    # The four native comments and two empty ignores are retained as unit
    # applications; all source declaration/statement children remain once.
    return sequence(b,comment(b,'input assumptions'),
                    *(assume(b,p) for p in input_invariants),
                    comment(b,'output assumptions'),comment(b,'precondition RTE'),
                    ignore(b,callers.constant(b,'True','bool')),
                    comment(b,'precondition assumption'),handled,
                    ignore(b,callers.constant(b,'True','bool')))


def scalar_range_check(b,low_term,high_term,base_first,base_last,*,
                       low_prog=None,high_prog=None,statically_safe=False):
    """Check_Scalar_Range:3707-3823, preserving the supplied endpoint trees.

    The optional evaluations are present exactly when Comes_From_Source and
    not Is_OK_Static_Expression; static safe/empty ranges return Void.
    """
    if statically_safe:
        return b.node('unit','unit')
    nonempty = b.call('Int.<=','bool',low_term,high_term,domain='pred')
    inside = b.node('and','bool',
                    b.call('Int.>=','bool',low_term,base_first,domain='pred'),
                    b.call('Int.<=','bool',high_term,base_last,domain='pred'),domain='pred')
    pre = b.node('implies','bool',nonempty,inside,domain='pred')
    out = b.node('any-unit','unit',pre,domain='prog')
    # The producer prepends low, then high, so high is evaluated first.
    if low_prog is not None:
        out = sequence(b,ignore(b,low_prog),out)
    if high_prog is not None:
        out = sequence(b,ignore(b,high_prog),out)
    return out
