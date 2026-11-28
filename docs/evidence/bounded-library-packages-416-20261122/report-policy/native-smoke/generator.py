from pathlib import Path
import json,re,copy
p=Path('tmp/package-policy-probe')
spec=(p/'src/audit_state.ads').read_text(); body=(p/'src/audit_state.adb').read_text(); main=(p/'src/main.adb').read_text()
report_path=p/'out/obj/explore/indexed/gnatprove'
pkg_report=json.loads((report_path/'audit_state~1.spark').read_text());main_report=json.loads((report_path/'main~1.spark').read_text())
def ada_string(s):
 return '\n      & '.join('"'+line.replace('"','""')+'"'+(' & Character\'Val (10)' if ended else '') for line,ended in [(x.removesuffix('\n'),x.endswith('\n')) for x in s.splitlines(keepends=True)])
def span(s,name,start=0,offset=0):
 m=re.search(r'\b'+re.escape(name)+r'\b',s[start:]);assert m,name;return offset+start+m.start()+1,offset+start+m.end()+1
q=Path('tmp/audit-compile/check.adb')
out=['with Silver_Library_Reports;','with Silver_Application_Report_Metadata;','with Silver_Package_Bindings;','with Silver_Application_Units;','with Silver_Procedure_Bindings;','with Ada.Text_IO;','procedure Check is','   package Reports renames Silver_Library_Reports;','   package Metadata renames Silver_Application_Report_Metadata;','   package Packages renames Silver_Package_Bindings;','   package Units renames Silver_Application_Units;','   package Procedures renames Silver_Procedure_Bindings;']
for name,s in [('Specification',spec),('Implementation',body),('Main_Source',main)]:out.append(f'   {name} : constant String :=\n      '+ada_string(s)+';')
out+=['   Sources : constant Units.Bundle := Units.Pack (Specification, Implementation, Main_Source);','   Source : constant String := Sources.Pool (1 .. Sources.Used);','   Info : Packages.Metadata := Packages.Empty_Metadata;']
fixtures=[('Package_Positive',pkg_report,True,True),('Main_Positive',main_report,False,True)]
x=copy.deepcopy(main_report);x['entities'][' 42']={'name':'Audit_State.Reset','sloc':[{'file':'audit_state.ads','line':7,'column':14}]};x['assumptions']=[{'claim':{'arg':1,'predicate':'CLAIM_EFFECTS'},'assumptions':[{'arg':42,'predicate':'CLAIM_EFFECTS'}]}];fixtures.append(('Main_Import',x,False,True))
x=copy.deepcopy(x);x['entities'][' 42']['name']='Audit_State.Unknown';fixtures.append(('Bad_Import',x,False,False))
x=copy.deepcopy(pkg_report);x['spark'].pop(' 3');fixtures.append(('Missing_Coverage',x,True,False))
x=copy.deepcopy(pkg_report);x['flow']=[r for r in x['flow'] if not (r['rule']=='SUBPROGRAM_TERMINATION' and pkg_report['entities'][' '+str(r['entity'])]['name'].lower()=='audit_state.read')];fixtures.append(('Missing_Termination',x,True,False))
x=copy.deepcopy(pkg_report);x['flow']=[r for r in x['flow'] if r['rule']!='UNINITIALIZED'];fixtures.append(('Missing_Output',x,True,False))
x=copy.deepcopy(pkg_report);next(r for r in x['flow'] if r['rule']=='UNINITIALIZED')['file']='audit_state.adb';fixtures.append(('Bad_Output_File',x,True,False))
x=copy.deepcopy(pkg_report);next(r for r in x['flow'] if r['rule']=='UNINITIALIZED')['message']['text']='initialization of "ANSWER" proved';fixtures.append(('Bad_Output_Case',x,True,False))
x=copy.deepcopy(main_report);next(r for r in x['flow'] if 'audit_state.stored' in r['message']['text'])['message']['text']='"audit_state.never" is set by "Reset" but not used after the call';fixtures.append(('Bad_State_Effect',x,False,False))
x=copy.deepcopy(pkg_report);x['assumptions'].append({'claim':{'arg':5,'predicate':'CLAIM_POST'},'assumptions':[]});fixtures.append(('Bad_Package_Post',x,True,False))
for label,r,_,_ in fixtures:out.append(f'   {label} : constant String :=\n      '+ada_string(json.dumps(r,indent=2))+';')
out+=['begin','   Info.Units := Sources.Units;']
first,after=span(spec,'Audit_State');out += [f'   Info.Name_First := {first};',f'   Info.Name_After := {after};','   Info.State_Count := 3;']
for i,name in enumerate(['Stored','Never','Flag'],1):
 a,b=span(body,name,offset=len(spec));out.append(f'   Info.States ({i}).Name := ({a}, {b});')
routines=[('Produce','Procedure_Routine',[('Answer','Output'),('Unread','Input')]),('Depend','Procedure_Routine',[('Value','Input_Output'),('Drop','Input')]),('Reset','Procedure_Routine',[]),('Replace','Procedure_Routine',[]),('Read','Function_Routine',[]),('Ignore','Function_Routine',[('Unused','Input')])]
out += [f'   Info.Routine_Count := {len(routines)};',f'   Info.Completed := {len(routines)};','   Info.Parameter_Count := 5;']
fi=1
for i,(name,kind,formals) in enumerate(routines,1):
 a,b=span(spec,name);out += [f'   Info.Routines ({i}).Kind := Packages.{kind};',f'   Info.Routines ({i}).Spec_Name := ({a}, {b});',f'   Info.Routines ({i}).Formal_First := {fi if formals else 0};',f'   Info.Routines ({i}).Count := {len(formals)};']
 for formal,mode in formals:
  aa,bb=span(spec,formal,start=b-1);out += [f'   Info.Parameters ({fi}).Spec_Name := ({aa}, {bb});',f'   Info.Parameters ({fi}).Mode := Procedures.{mode};'];fi+=1
out += ['   Info.Routines (3).May_Write (1) := True;','   Info.Routines (3).May_Write (3) := True;','   Info.Routines (4).May_Write (1) := True;', '   if not Metadata.Valid (Source, Metadata.For_Package (Info)) then raise Program_Error with "context"; end if;']
for label,_,ispkg,expected in fixtures:
 args=(f'{label}, Reports.Assigned_Output, Source, Metadata.Owned_Functions (Info), Metadata.Owned_Procedures (Info), Metadata.For_Package (Info)' if ispkg else f'{label}, Reports.Static_Output, Source, Context => Metadata.For_Main (Info)')
 out += [f'   if Reports.Complete_Application_Proof ({args}) /= {str(expected)} then',f'      raise Program_Error with "{label}";','   end if;']
out += ['   Ada.Text_IO.Put_Line ("11 native package report checks passed");','end Check;']
q.write_text('\n'.join(out)+'\n');print(q,len(fixtures))
