"""Ordinary Main source-indexed construction fold, not a Silver parser.

Inputs retain frontend type identity, static/folding/capture decisions and
source entity identity. These are semantic indices of the source derivation,
not arbitrary typed trees or numeric size certificates. All native children
are built here through the closed admitted constructor grammar.
"""
from dataclasses import dataclass,field,replace
import body, callers, terms
base = callers.base


@dataclass(frozen=True)
class Bound:
    kind: str
    value: str
    ty: str = 'int'


@dataclass(frozen=True)
class Shape:
    identity: str
    static: bool
    first: Bound
    last: Bound
    length: int | None = None


STANDARD_STRING = Shape('Standard.String',False,Bound('symbol','Standard.Positive.first'),
                        Bound('symbol','Standard.Positive.last'))


@dataclass(frozen=True)
class Object:
    identity: str
    ty: str
    mutable: bool
    shape: Shape | None = None
    policy: str = 'named'
    predicate: str = ''
    bounds: tuple = ()
    range_symbol: str | None = None


@dataclass(frozen=True)
class Value:
    kind: str
    args: tuple = ()
    key: str = ''
    shape: Shape | None = None
    expected: Shape | None = None
    check: bool = False
    sliding: bool = False
    equal_lengths: bool = False
    range_symbol: str | None = None
    warn: bool = False
    guarded: bool = False


@dataclass(frozen=True)
class Declaration:
    object: Object
    value: Value
    # A separate term initializer belongs to the entity context, not Main's
    # executable body. Its guard/cost is never silently imported as Eexec.
    term_replay: bool = False


@dataclass(frozen=True)
class Statement:
    kind: str
    values: tuple = ()
    bodies: tuple = ()
    key: str = ''
    warn: tuple = ()
    captures: tuple = ()
    capture_slots: tuple = ()
    reverse: bool = False
    # Actual whole-root statuses from the producer's ordered write map.
    roots: tuple = ()
    check_lengths: bool = False
    target_shape: Shape | None = None
    sliding: bool = False


def written_roots(statement):
    """Ordinary source write-set induction; generated branch observation is
    a typed effect, not an Ada frame root. Read-only actuals are not inserted.
    """
    if statement.kind=='assign': return {statement.key}
    if statement.kind=='call' and statement.key in {'put','put_line'}:
        return {'Silver_io__written_bytes.written_bytes','Silver_io__written_count.written_count',
                'Silver_io__flushed.flushed','Silver_io__succeeded.succeeded'}
    roots=set()
    for arm in statement.bodies:
        for child in arm: roots.update(written_roots(child))
    return roots


class Fold:
    def __init__(self):
        self.b = base.Builder(); self.signatures = body.catalogue()
        self.apis = terms.api_profiles()
        self.signatures.update({k:v['signature'] for k,v in self.apis.items()})
        self.objects = {}; self.external = set(); self.context = []; self.shapes={}
        self.events = []; self.loop_count = 0
        self.branch = None
        output_shape=Shape('Silver_IO.Written_Bytes:type',True,Bound('constant','1'),
                           Bound('symbol','Silver_IO.Max_Length'))
        self.global_objects={
            'Silver_io__written_bytes.written_bytes':Object('Silver_io__written_bytes.written_bytes',
                'string',True,output_shape,predicate='Silver_IO.Buffer:dynamic_invariant'),
            'Silver_io__written_count.written_count':Object('Silver_io__written_count.written_count',
                'int',True,predicate='Silver_IO.Count:dynamic_invariant'),
            'Silver_io__flushed.flushed':Object('Silver_io__flushed.flushed','bool',True,policy='true'),
            'Silver_io__succeeded.succeeded':Object('Silver_io__succeeded.succeeded','bool',True,policy='true')}

    def bound(self, d):
        if d.kind == 'constant':
            return callers.constant(self.b,d.value)
        if d.kind not in {'symbol','to_rep'}:
            raise ValueError('uncovered source bound '+d.kind)
        ty = 'abstract' if d.kind=='to_rep' else d.ty
        self.signatures.setdefault(d.value,callers.signature(d.value,(),ty,
                                    'ordinary declared immutable bound; converter:1044-1059'))
        n = self.b.identifier(d.value,ty,symbol=True)
        return self.b.call('Rep_Proj_Base.to_rep','int',n) if d.kind=='to_rep' else n

    def shape(self, s):
        if s is None:
            raise ValueError('String source shape required')
        if not s.static and s.identity!='Standard.String':
            raise ValueError('nonstatic constrained String is outside the ordinary premise')
        if s.identity in self.shapes:
            prior,native=self.shapes[s.identity]
            if prior!=s: raise ValueError('incoherent source type identity')
            return native
        native=base.ArrayShape(s.identity,s.static,self.bound(s.first),self.bound(s.last))
        self.shapes[s.identity]=(s,native)
        return native

    def register(self, obj):
        if obj.identity in self.objects or obj.identity.startswith('tmp:'):
            raise ValueError('source entity identity must be unique')
        if obj.ty not in {'int','string','bool'}:
            raise ValueError('uncovered source object type')
        self.objects[obj.identity] = obj
        ty = self.shape(obj.shape).ty if obj.ty=='string' else obj.ty
        if obj.mutable:
            # Ordinary mutable UCArray uses only a map reference; bounds are
            # immutable nullary program symbols in the source entity context.
            self.external.add(obj.identity)
            return self.b.identifier(obj.identity,('map' if obj.ty=='string' else ty)+'__ref')
        self.signatures[obj.identity] = callers.signature(obj.identity,(),ty,
                    'ordinary immutable object declaration; converter:1044-1059')
        return self.b.identifier(obj.identity,ty,symbol=True)

    def ref(self,obj):
        if not obj.mutable:
            raise ValueError('mutable source reference required')
        ty = 'map' if obj.ty=='string' else obj.ty
        return self.b.identifier(obj.identity,ty+'__ref')

    def read(self,obj):
        if not obj.mutable:
            ty = self.shape(obj.shape).ty if obj.ty=='string' else obj.ty
            return self.b.identifier(obj.identity,ty,symbol=True)
        ref = self.ref(obj)
        if obj.ty=='string' and not obj.shape.static:
            if len(obj.bounds)!=2:
                raise ValueError('split String requires its two actual binder-bound descriptors')
            return body.read_object(self.b,ref,shape=self.shape(obj.shape),
                                    first=self.bound(obj.bounds[0]),last=self.bound(obj.bounds[1]))
        return body.read_ref(self.b,ref)

    def invariant(self,obj,value,only_var=False):
        predicate = obj.predicate or obj.identity+':dynamic_invariant'
        policy = obj.policy
        args = ({'named':(value.ty,'bool','bool','bool','bool'),
                 'well-formed':(value.ty,), 'scalar':('int','int',value.ty),
                 'true':()})[policy]
        if policy!='true':
            self.signatures[predicate] = base.Signature(predicate,args,'prop','logic-only',(),None,
                                      'Compute_Dynamic_Invariant ordinary source branch')
        kw = dict(policy=policy,predicate=predicate,only_var=only_var)
        if policy=='scalar':
            if len(obj.bounds)!=2: raise ValueError('full scalar bounds required')
            kw['scalar_bounds'] = tuple(self.bound(x) for x in obj.bounds)
        return body.invariant(self.b,value,**kw),kw

    def range_signature(self,key):
        if key not in self.signatures:
            n,r = base.var('a0'),base.var('result')
            p = base.app(key+':in_range',n)
            self.signatures[key] = base.Signature(key,('int',),'int','RKnone',(p,),
                base.connective('and',base.app('=',r,n),p),'Static_Discrete.range_check clone')

    def value(self,v,domain='prog'):
        b=self.b; k=v.kind; shape=v.shape
        self.events.append(('value',k,v.key,domain))
        if domain not in {'prog','term','pred'}: raise ValueError('source mode')
        if k=='integer':
            n=callers.constant(b,v.key)
        elif k=='boolean':
            if v.key not in {'True','False'}: raise ValueError('Boolean literal')
            n=callers.constant(b,v.key,'bool')
        elif k=='name':
            obj=self.objects[v.key]; n=self.read(obj); shape=obj.shape
        elif k=='literal':
            if shape is None or not shape.static: raise ValueError('ordinary literal static shape')
            self.signatures[v.key]=callers.signature(v.key,('unit',),'map',
                         'gnat2why-expr:30225-30315; unit argument Pterm declaration')
            n=b.call(v.key,'map',b.node('unit','unit'),domain=domain)
        elif k in {'+','-','*','neg','pos'}:
            children=tuple(self.value(a,domain)[0] for a in v.args)
            if v.range_symbol: self.range_signature(v.range_symbol)
            n=callers.scalar_operation(b,k,children,overflow_symbol=v.range_symbol,domain=domain)
        elif k=='image':
            if len(v.args)!=1: raise ValueError('Image arity')
            n=callers.integer_image(b,self.value(v.args[0],domain)[0],v.key,domain=domain)
            shape=STANDARD_STRING
        elif k=='concat':
            if len(v.args)!=2: raise ValueError('binary frontend concat required')
            left,ls=self.value(v.args[0],domain); right,rs=self.value(v.args[1],domain)
            n,actual=callers.concat(b,left,right,self.shape(ls),self.shape(rs),
                positive_last=self.bound(STANDARD_STRING.last),
                static_left_empty=ls.static and ls.length==0,domain=domain)
            shape=rs if actual is not None else STANDARD_STRING
        elif k=='length':
            obj=self.objects[v.key]
            if obj.ty!='string': raise ValueError('Length requires String object')
            split=obj.mutable and not obj.shape.static
            n=callers.object_length(b,self.read(obj),self.shape(obj.shape),
                binder_kind='split' if split else 'regular',
                binder_value=None if obj.mutable else self.read(obj),
                first_rep=self.bound(obj.bounds[0]) if split else None,
                last_rep=self.bound(obj.bounds[1]) if split else None,
                static_length=obj.shape.length,domain=domain)
            shape=None
        elif k in {'scalar_compare','string_compare'}:
            left,ls=self.value(v.args[0],domain); right,rs=self.value(v.args[1],domain)
            if k=='string_compare':
                if v.key not in {'=','/='}: raise ValueError('String ordering is not admitted')
                n=callers.compare(b,v.key,left,right,self.shape(ls),self.shape(rs),domain=domain)
            else:
                suffix={'=':'eq','/=':'ne','<':'lt','<=':'le','>':'gt','>=':'ge'}[v.key]
                symbol='Integer.bool_'+suffix if domain=='term' else ('=' if v.key in {'=','/='} else 'Int.'+v.key)
                n=b.call(symbol,'bool',left,right,domain=domain)
                if domain!='term' and v.key=='/=': n=b.node('not','bool',n,domain=domain)
            shape=None
        elif k in {'and','or','not'}:
            xs=[self.value(a,domain)[0] for a in v.args]
            if len(xs)!=(1 if k=='not' else 2): raise ValueError('Boolean arity')
            if domain=='prog':
                if k!='not': xs[1]=body.warning(b,xs[1],v.warn)
                n=b.node(k,'bool',*xs,domain=domain)
            elif domain=='pred': n=b.node(k,'bool',*xs,domain=domain)
            else:
                symbol='Boolean.'+{'and':'andb','or':'orb','not':'notb'}[k]
                self.signatures.setdefault(symbol,callers.signature(symbol,('bool',)*len(xs),'bool','bool.mlw'))
                n=b.call(symbol,'bool',*xs,domain=domain)
            shape=None
        elif k=='query':
            symbol='API.'+v.key
            if v.key not in {'first_or_default','input_is_valid'}: raise ValueError('query selection')
            args=tuple(self.value(a,domain)[0] for a in v.args) if v.args else (b.node('unit','unit'),)
            s=self.signatures[symbol]
            if domain=='prog': n=b.call(symbol,s.result_type,*args,domain=domain)
            else:
                logic='Logic.'+v.key
                self.signatures[logic]=base.Signature(logic,s.arg_types,s.result_type,
                    'logic-only',(),None,'selected query logic declaration')
                if not v.guarded:
                    n=b.call(logic,s.result_type,*args,domain=domain)
                else:
                    guard=logic+':guard'
                    self.signatures[guard]=base.Signature(guard,(s.result_type,)+s.arg_types,
                        'prop','logic-only',(),None,'New_Function_Call:5017-5178')
                    tmps=tuple(b.temporary(a) for a in args)
                    result=body.fresh(b,s.result_type)
                    eq=b.call('=','bool',result,b.call(logic,s.result_type,*tmps),domain='pred')
                    post=b.call(guard,'bool',result,*tmps,domain='pred')
                    n=b.node('epsilon',s.result_type,b.node('and','bool',eq,post,domain='pred'),
                             key=result.key,domain='term')
                    for tmp in tmps: n=b.binding(tmp,n,'term')
            shape=STANDARD_STRING if v.key=='first_or_default' else None
        else:
            raise ValueError('uncovered admitted value '+k)
        if v.expected is not None:
            if shape is None: raise ValueError('String expected type on scalar')
            n=base.array_conversion(b,n,self.shape(shape),self.shape(v.expected),
                sliding=v.sliding,need_check=v.check,domain='prog' if domain=='prog' else 'term',
                static_lengths_equal=v.equal_lengths)
            shape=v.expected
        elif v.range_symbol and k not in {'+','-','*','neg','pos'}:
            self.range_signature(v.range_symbol)
            n=callers.scalar_expected(b,n,range_symbol=v.range_symbol,domain=domain)
        return n,shape

    def declaration(self,d):
        if d.object.identity in self.objects: raise ValueError('declaration reused')
        n,shape=self.value(d.value)
        if d.term_replay:
            context_node,_=self.value(d.value,'term')
            self.context.append(dict(entity=d.object.identity,source=d.value,
                                     term=terms.record(body.term(context_node,self.signatures))))
        target=self.register(d.object)
        obj=d.object; split=obj.mutable and obj.ty=='string' and not obj.shape.static
        if obj.ty=='string' and shape!=obj.shape:
            raise ValueError('initializer must carry the selected expected-type conversion')
        init=body.initialize(self.b,n,target,mutable=obj.mutable,split=split,
            bound_first=self.bound(obj.bounds[0]) if split else None,
            bound_last=self.bound(obj.bounds[1]) if split else None)
        inv,_=self.invariant(obj,self.read(obj))
        if not body.syntactic_true(inv): init=body.sequence(self.b,init,body.assume(self.b,inv))
        return self.b.node('label','unit',init,domain='prog')

    def statement(self,s):
        # Source-location attributes keep a unit/null list entry from the
        # converter's bare-unit sequence filter. The attribute itself has no
        # additional typed expression constructor.
        n=self._statement(s)
        return self.b.node('label',n.ty,n,domain='prog')

    def _statement(self,s):
        b=self.b
        if s.kind in {'null','ignored'}: return b.node('unit','unit')
        if s.kind=='call':
            if s.key not in {'put','put_line','reject'}: raise ValueError('procedure selection')
            args=tuple(self.value(v)[0] for v in s.values) if s.values else (b.node('unit','unit'),)
            api=self.apis['API.'+s.key]; self.external.update(api['reads']|api['writes'])
            return b.call('API.'+s.key,'unit',*args,domain='prog')
        if s.kind=='assign':
            obj=self.objects[s.key]; rhs,shape=self.value(s.values[0])
            if not obj.mutable: raise ValueError('assignment to immutable object')
            if obj.ty!='string': return body.assign(b,self.ref(obj),rhs)
            target_shape=s.target_shape or obj.shape
            return body.string_assignment(b,rhs,self.shape(shape),self.ref(obj),self.shape(target_shape),
                target_read=self.read(obj),binder_shape=self.shape(obj.shape),
                check_target_lengths=s.check_lengths,final_sliding=s.sliding)
        if s.kind=='if':
            if len(s.bodies)!=len(s.values)+1: raise ValueError('if arm layout')
            if self.branch is None:
                self.branch=b.identifier('spark__branch','bool__ref'); self.external.add('spark__branch')
            conditions=[self.value(v)[0] for v in s.values]
            arms=[self.statements(xs) for xs in s.bodies]
            flags=s.warn or (False,)*len(arms)
            return body.source_if(b,conditions,arms[:-1],arms[-1],self.branch,warn=flags)
        if s.kind=='loop':
            if len(s.values)!=2 or len(s.bodies)!=1 or len(s.captures)>2:
                raise ValueError('ordinary range loop layout')
            self.loop_count+=1
            slots=s.capture_slots or tuple(range(len(s.captures)))
            if len(slots)!=len(s.captures) or len(set(slots))!=len(slots) or any(i not in {0,1} for i in slots):
                raise ValueError('capture-to-endpoint source map')
            endpoints=list(s.values);prefix=[]
            for slot,d in zip(slots,s.captures):
                if d.object.ty!='int' or d.object.mutable or d.value!=s.values[slot]:
                    raise ValueError('capture must relocate its complete scalar endpoint')
                prefix.append(self.declaration(d));endpoints[slot]=Value('name',key=d.object.identity)
            # The supplied frontend capture map replaces the corresponding
            # bound by its generated constant name; it never repeats its init.
            lp=self.value(endpoints[0])[0]; hp=self.value(endpoints[1])[0]
            lt=self.value(endpoints[0],'term')[0]; ht=self.value(endpoints[1],'term')[0]
            idx=Object(s.key,'int',True,policy='true'); ref=self.register(idx)
            child=self.statements(s.bodies[0]); roots=[]
            source_writes=written_roots(s)
            actual_roots=s.roots or tuple((name,'entire') for name in sorted(source_writes))
            if (len({name for name,status in actual_roots})!=len(actual_roots) or
                {name for name,status in actual_roots}!=source_writes or
                any(status!='entire' for name,status in actual_roots)):
                raise ValueError('ordinary loop frame is exactly its source whole-write roots')
            for name,status in actual_roots:
                obj=self.objects.get(name,self.global_objects.get(name))
                if obj is None: raise ValueError('frame root outside source objects and four concrete globals')
                current=self.read(obj); _,policy=self.invariant(obj,current,True)
                roots.append(dict(status=status,current=current,entry_read=self.read(obj),invariant=policy))
            flags=s.warn or (False,False)
            out=body.range_loop(b,lp,hp,lt,ht,ref,child,roots,loop_identity=s.key,
                               reverse=s.reverse,warn_entry=flags[0],warn_after=flags[1])
            return body.sequence(b,*prefix,out)
        raise ValueError('uncovered admitted statement '+s.kind)

    def statements(self,xs):
        return body.sequence(self.b,*(self.statement(s) for s in xs))

    def main(self,declarations,statements):
        ds=body.sequence(self.b,*(self.declaration(d) for d in declarations))
        ss=self.statements(statements)
        invariants=[]
        for key,ty in [('Silver_io__written_bytes.written_bytes','map'),
                       ('Silver_io__written_count.written_count','int')]:
            if key in self.external:
                ref=self.b.identifier(key,ty+'__ref')
                predicate=key+':dynamic_invariant'
                self.signatures[predicate]=base.Signature(predicate,(ty,'bool','bool','bool','bool'),
                    'prop','logic-only',(),None,'Main input invariants:2362-2461')
                invariants.append(body.invariant(self.b,body.read_ref(self.b,ref),policy='named',predicate=predicate))
        native=body.main_wrapper(self.b,ds,ss,invariants)
        return native,body.project(native,self.signatures)
