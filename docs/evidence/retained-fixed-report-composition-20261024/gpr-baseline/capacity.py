"""Source/configuration bounds for the selected GPR project-processing prefix.

The lexer is an evidence reader, not an Ada/GPR execution or a general parser.
Unsupported syntax raises; ordinary source admission is unaffected.
"""
from dataclasses import dataclass
import re
I32=2**31-1
I64=2**63-1

@dataclass(frozen=True)
class Token:
    kind: str
    value: str
    offset: int


def tokens(data):
    text=data.decode('ascii') if isinstance(data,bytes) else data
    out=[];i=0
    while i<len(text):
        if text[i].isspace():i+=1;continue
        if text.startswith('--',i):
            j=text.find('\n',i);i=len(text) if j<0 else j+1;continue
        start=i
        if text[i]=='"':
            i+=1;value=''
            while True:
                if i>=len(text):raise ValueError('unterminated GPR string')
                if text[i]=='"':
                    if i+1<len(text) and text[i+1]=='"':value+='"';i+=2;continue
                    i+=1;break
                value+=text[i];i+=1
            out.append(Token('string',value,start));continue
        m=re.match(r'[A-Za-z][A-Za-z0-9_]*|[0-9]+|:=|=>|[();,&\']',text[i:])
        if not m:raise ValueError(('unrecognized source byte',i,text[i:i+20]))
        word=m.group();i+=len(word)
        kind='word' if word[0].isalpha() else 'integer' if word[0].isdigit() else word
        out.append(Token(kind,word.lower() if kind=='word' else word,start))
    return out


class Shape:
    def __init__(self,data):
        self.t=tokens(data);self.i=0;self.declarations=[];self.packages=[]
        self.expressions=0;self.terms=0;self.references=0;self.list_items=0
        self.max_references_per_rhs=0;self.case_count=0
        if self.peek('configuration'):self.take()
        self.expect('project');self.take_kind('word');self.expect('is')
        self.block('project')
        if self.i!=len(self.t):raise ValueError('trailing GPR tokens')
    def peek(self,value):return self.i<len(self.t) and self.t[self.i].value==value
    def take(self):
        t=self.t[self.i];self.i+=1;return t
    def expect(self,value):
        t=self.take()
        if t.value!=value:raise ValueError(('expected',value,'got',t))
    def take_kind(self,kind):
        t=self.take()
        if t.kind!=kind:raise ValueError(('expected kind',kind,'got',t))
        return t
    def block(self,package):
        while not self.peek('end'):
            if self.peek('package'):
                self.take();name=self.take_kind('word').value;self.packages.append(name)
                self.expect('is');self.block(name)
            elif self.peek('case'):
                # The retained GCC_Prefix case has two empty alternatives.
                self.take();self.take_kind('word');self.expect('is')
                self.expect('when');self.take_kind('string');self.expect('=>')
                self.expect('null');self.expect(';');self.expect('when')
                self.expect('others');self.expect('=>');self.expect('end')
                self.expect('case');self.expect(';');self.case_count+=1
            else:
                attribute=self.peek('for')
                if attribute:self.take()
                name=self.take_kind('word').value;index=None
                if self.peek('('):
                    self.take();index=self.take_kind('string').value.lower();self.expect(')')
                self.expect('use' if attribute else ':=')
                before=self.references;self.expression()
                refs=self.references-before
                if refs>1:raise ValueError('selected linear-reference expression required')
                self.max_references_per_rhs=max(self.max_references_per_rhs,refs)
                self.expect(';')
                self.declarations.append((package,name,index,attribute))
        self.expect('end');self.take_kind('word');self.expect(';')
    def expression(self):
        self.expressions+=1;self.term()
        while self.peek('&'):self.take();self.term()
    def term(self):
        self.terms+=1
        if self.peek('('):
            self.take()
            if not self.peek(')'):
                self.expression();self.list_items+=1
                while self.peek(','):self.take();self.expression();self.list_items+=1
            self.expect(')')
        elif self.i<len(self.t) and self.t[self.i].kind=='string':
            self.take()
            if self.peek('at'):self.take();self.take_kind('integer')
        else:
            self.take_kind('word');self.references+=1
            if self.peek("'"):
                self.take();self.take_kind('word')
                if self.peek('('):
                    self.take();self.take_kind('string');self.expect(')')
    def summary(self):
        strings=[t.value for t in self.t if t.kind=='string']
        return dict(tokens=len(self.t),string_tokens=len(strings),
                    literal_payload=sum(map(len,strings)),max_literal=max(map(len,strings),default=0),
                    declarations=len(self.declarations),packages=len(self.packages),
                    expressions=self.expressions,terms=self.terms,references=self.references,
                    list_items=self.list_items,max_references_per_rhs=self.max_references_per_rhs,
                    empty_case_constructs=self.case_count,
                    imports=0,extends=0,aggregates=0,builtin_expressions=0)


def table(demand,low,initial,growth,size,high=I32):
    assert all(isinstance(x,int) for x in (demand,low,initial,growth,size,high))
    assert demand>=0 and initial>0 and growth>=0 and size>0
    p=max(demand,initial)
    c=max(initial,demand+demand//1000,p*(100+growth)//100,p+10)
    guards=dict(initial=initial<=I32,growth=p*(100+growth)<=I64,
                length=c+1<=I32,low=low-1>=-2**31,backing=low+c<=I32,
                index=low+demand-1<=high,bytes=(c+1)*size<=I64)
    return dict(demand=demand,initial=initial,growth=growth,low=low,
                component_bytes=size,capacity=c,bytes=(c+1)*size,
                guards=guards,passed=all(guards.values()))


def project_prefix(project,configuration,syntax_sites,attribute_initializers,
                   package_initializers,predefined_names,kb_target_names):
    """Bound the enumerated parsed/shared-table coordinates through Phase_2.

    The closed flags cover gross_shared_table_bounds only. Four auxiliary
    parser tables are attached separately by auxiliary_parser_tables; whole
    GPR.Names/KB/OS/XML/GPR2 attachment remains unresolved. See README.md.
    Bounds retain obsolete list values and reset cell events.
    """
    p=Shape(project).summary();c=Shape(configuration).summary()
    t=p['tokens']+c['tokens']
    decl=p['declarations']+c['declarations']
    packages=p['packages']+c['packages']
    terms=p['terms']+c['terms']
    refs=p['references']+c['references']
    literal=p['string_tokens']+c['string_tokens']
    # One-reference RHSs form temporal chains. Charge every string literal,
    # even an index, plus a possible singleton default for every reference.
    L=literal+refs+1
    resets=2
    nodes=syntax_sites*(t+2)
    expression_cells=terms*L
    apply_cells=decl*L
    # Nmsc adds the one project source directory. The executable project has
    # no Interfaces/Library_Interface/--src-subdirs contribution.
    strings=resets+expression_cells+apply_cells+1
    # Every final nonempty configured list is supplied by a declaration;
    # default lists are nil. One language conversion; absent runtime pathfiles
    # add exactly two Name_List cells. Duplicate has no selected caller.
    name_lists=decl*L+2
    variables=attribute_initializers*(packages+2)+decl
    arrays=2*decl
    array_elements=2*decl
    package_cells=packages+c['packages']
    shared=dict(Project_Nodes=table(nodes,1,1000,100,352,99999999),
                String_Elements=table(strings,1,200,100,80),
                Name_Lists=table(name_lists,1,10,100,32),
                Variable_Elements=table(variables,1,200,100,256),
                Arrays=table(arrays,1,200,100,64),
                Array_Elements=table(array_elements,1,200,100,320),
                Packages=table(package_cells,1,100,100,128),
                Number_Lists=table(1,1,10,100,32),
                Reference_Prefix=table(1,1,10,100,32),
                Case_Choices=table(p['empty_case_constructs']+c['empty_case_constructs'],0,10,100,32,99999999),
                Case_Stack=table(1,1,10,100,16))
    # These are contributions to the process-wide names vector, not its total.
    # Name_Find deduplication is ignored, including rescanned lookahead tokens.
    parser_names=2*t+2*decl+terms
    known_names=predefined_names+kb_target_names+parser_names
    max_name_payload=max(p['literal_payload']+c['literal_payload'],188)
    return dict(project=p,configuration=c,list_value_bound=L,
                expression_cells=expression_cells,apply_copy_cells=apply_cells,
                gross_shared_table_bounds=shared,
                known_GPR_Name_requests=dict(predefined=predefined_names,
                    target_KB=kb_target_names,parser_expression=parser_names,total=known_names,
                    complete_process_baseline=False),
                reference_prefix_reset_events_upper=refs,
                syntax_name_payload_upper=max_name_payload,
                syntax_Name_Entry_object_upper=max_name_payload+48,
                multiplicities=dict(user_parse=1,configuration_parse=1,
                    user_evaluation=1,configuration_evaluation=1,Apply_Config=1,
                    naming_language_conversion=1,shared_resets=resets,
                    generated_naming_project_parses=0,runtime_project_parses=0,
                    user_AST_parses_in_Gprconfig=0),
                parser_shared_tables_closed=all(x['passed'] for x in shared.values()),
                complete_GPR_names_baseline_closed=False,
                complete_GPR_process_capacity_closed=False,
                complete_configuration_capacity_closed=False)


def auxiliary_parser_tables(project,configuration):
    """Four additional parser backings; summaries must be the pinned inputs.

    Count gross push events even though popping keeps the selected depth low.
    No imports, extensions or aggregates: two top-level parse calls only.
    """
    for summary in (project,configuration):
        assert all(summary[key]==0 for key in ('imports','extends','aggregates'))
    parses=2
    ends=parses+project['packages']+configuration['packages']
    ends+=project['empty_case_constructs']+configuration['empty_case_constructs']
    bounds=dict(Withs=table(0,1,10,100,80),
                Project_Stack=table(parses,1,10,100,64),
                Extended_Projects=table(0,1,10,100,32),
                Next_End_Nodes=table(ends,1,10,100,16))
    return dict(tables=bounds,Project_Stack_Init_calls=parses,
                Project_Stack_gross_pushes=parses,
                Project_Stack_peak_selected_depth=1,
                Next_End_Nodes_gross_pushes=ends,
                resets_or_pops_do_not_erase_gross_events=True,
                additional_RTS_pushes=0,
                all_four_backings_closed=all(b['passed'] for b in bounds.values()),
                complete_parser_or_process_allocation_closed=False)


def attach_names(known_requests,additional_requests,prior_capacity,later_requests):
    """Explicit unresolved process contributions; zero is NOT a default."""
    for n in (known_requests,additional_requests,prior_capacity,later_requests):
        assert isinstance(n,int) and n>=0
    prefix=known_requests+additional_requests
    total=prefix+later_requests
    cap=max(prior_capacity,2*max(total,1))
    return dict(prefix_requests=prefix,lifetime_requests=total,capacity=cap,
                pointer_array_bytes=16*cap+16,
                passed=total<=99999998 and cap<=99999998 and 16*cap+16<=I64,
                additional_provider_attached=False)
