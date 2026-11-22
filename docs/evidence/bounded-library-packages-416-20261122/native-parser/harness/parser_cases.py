from pathlib import Path
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
BASE=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/packages-416-native')
PRIMARY=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/named-array-parameters-410')
sys.path.insert(0,str(PRIMARY))
spec=importlib.util.spec_from_file_location('package_test_draft',PRIMARY/'tests/test_library_packages.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
out=BASE/'tmp/helper-syntax/out'
(out/'cases').mkdir(exist_ok=True)
tempfile.tempdir=str(out/'cases')
records=[]
class ParserOnlyComplete(Exception):
    pass
class Cases(m.LibraryPackageTests):
    def check(self,source,expected=0,*,specification=m.SPEC,body=m.BODY):
        self.write(source,specification,body)
        result=subprocess.run([str(out/'package_check'),str(self.specification),str(self.body),str(self.source)],capture_output=True,text=True)
        records.append({'test':self._testMethodName,'expected':expected,'actual':result.returncode,'stdout':result.stdout,'stderr':result.stderr})
        self.assertEqual(result.returncode,expected,result.stdout+result.stderr)
    def compile(self,source,*,specification=m.SPEC,body=m.BODY,**kwargs):
        self.check(source,specification=specification,body=body)
        if self._testMethodName == 'test_packages_compose_with_arguments_arrays_and_guarded_output':
            raise ParserOnlyComplete
        return self.directory
    def test_packages_compose_with_arguments_arrays_and_guarded_output(self):
        # Retain the authoritative source while excluding its executable claims.
        with self.assertRaises(ParserOnlyComplete):
            super().test_packages_compose_with_arguments_arrays_and_guarded_output()
    def test_extra_reserved_package_identifiers(self):
        for name in ['Main','Ada','Interfaces','System','Integer','Boolean','String','Character','Silver_IO','Silver_Arguments','Silver_Output_Libc','Silver_Runtime']:
            with self.subTest(package=name):
                n=name.encode()
                self.check(b'with '+n+b';procedure Main is pragma SPARK_Mode(On);begin null;end Main;',2,
                    specification=b'package '+n+b' is pragma SPARK_Mode(On);procedure Reset;end '+n+b';',
                    body=b'package body '+n+b' is pragma SPARK_Mode(On);procedure Reset is begin null;end Reset;end '+n+b';')
    def test_extra_qualified_constant_and_writable_local_have_distinct_names(self):
        spec=b'package P is pragma SPARK_Mode(On);N:constant Integer:=3;procedure Copy(X:in Integer;Y:out Integer);end P;'
        body=b'package body P is pragma SPARK_Mode(On);procedure Copy(X:in Integer;Y:out Integer)is begin Y:=X;end Copy;end P;'
        self.check(m.main(b'N:Integer:=0;',b'P.Copy(P.N,N);'),specification=spec,body=body)
    def test_extra_initializer_full_domains_and_formal_shadowing(self):
        spec=b'package P is pragma SPARK_Mode(On);subtype Small is Integer range 0..9;procedure Copy(Stored:in Small;X:out Small);end P;'
        body=b'package body P is pragma SPARK_Mode(On);Stored:Small:=0;procedure Copy(Stored:in Small;X:out Small)is Saved:Small:=Stored;begin X:=Saved;end Copy;end P;'
        self.check(m.main(),specification=spec,body=body)
        self.check(m.main(),2,specification=spec,body=body.replace(b'Saved:Small:=Stored;',b'Saved:Small:=(Stored+1);'))
    def test_extra_explicit_write_cannot_alias_implicit_read(self):
        spec=b'package P is pragma SPARK_Mode(On);subtype Small is Integer range 0..9;procedure Copy(X:out Small);procedure Call;end P;'
        body=b'package body P is pragma SPARK_Mode(On);Stored:Small:=0;procedure Copy(X:out Small)is begin X:=Stored;end Copy;procedure Call is begin Copy(Stored);end Call;end P;'
        self.check(m.main(),2,specification=spec,body=body)
        self.check(m.main(),specification=spec,body=body.replace(b'procedure Call is begin Copy(Stored);',b'procedure Call is Stored:Small:=0;begin Copy(Stored);'))
    def test_extra_read_only_calls_preserve_state_facts(self):
        spec=b'package P is pragma SPARK_Mode(On);subtype Small is Integer range 0..9;function Read return Small;procedure Step;end P;'
        body=b'package body P is pragma SPARK_Mode(On);Stored:Small:=0;function Read return Small is begin return Stored;end Read;procedure Step is Temp:Small:=0;begin Stored:=0;if Stored<9 then Temp:=Read;Stored:=(Stored+1);end if;end Step;end P;'
        self.check(m.main(),specification=spec,body=body)
    def test_extra_return_call_is_outside_existing_return_grammar(self):
        spec=b'package P is pragma SPARK_Mode(On);function First return Integer;function Second return Integer;end P;'
        body=b'package body P is pragma SPARK_Mode(On);function First return Integer is begin return 0;end First;function Second return Integer is begin return First;end Second;end P;'
        self.check(m.main(),2,specification=spec,body=body)
        self.check(m.main(),specification=spec,body=body.replace(b'function Second return Integer is begin return First;',b'function Second return Integer is X:Integer:=0;begin X:=First;return X;'))
    def test_extra_guarded_slice_starts_at_main_original_unit(self):
        decl=b'S:String:="abc";L:Integer range 1..3:=1;H:Integer range 1..3:=3;'
        self.check(m.main(decl,b'if L=1 then Silver_IO.Put_Line(S(L..H));end if;'),2,specification=m.SPEC+b'-- eof',body=m.BODY+b'-- eof')
        self.check(m.main(decl,b'if L=1 then Silver_IO.Put_Line(S(1..3));end if;'),specification=m.SPEC+b'-- eof',body=m.BODY+b'-- eof')
    def test_extra_selected_original_audit_fixtures(self):
        for name in ['package-selected-policy-probe','package-selected-local-policy-probe']:
            with self.subTest(fixture=name):
                src=BASE.parent/'packages-416-audit/tmp'/name/'src'
                self.check((src/'main.adb').read_bytes(),specification=(src/'audit_state.ads').read_bytes(),body=(src/'audit_state.adb').read_bytes())
    def test_extra_queue_definition_original_units(self):
        src=PRIMARY/'samples/rosetta_queue_definition'
        self.check((src/'main.adb').read_bytes(),specification=(src/'queue.ads').read_bytes(),body=(src/'queue.adb').read_bytes())

suite=unittest.TestSuite(Cases(name) for name in unittest.defaultTestLoader.getTestCaseNames(Cases)
                        if name!='test_missing_source_is_an_input_error_without_a_build_workspace')
result=unittest.TextTestRunner(verbosity=2).run(suite)
(out/'parser-cases.json').write_text(json.dumps({'scope':'native parser only, authoritative package fixtures plus focused regressions; compilation, audit and execution assertions are not claimed','records':records},indent=2)+'\n')
raise SystemExit(not result.wasSuccessful())
