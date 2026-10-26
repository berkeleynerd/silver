"""Materialize scratch #237 inputs; this file never invokes native tools."""
from pathlib import Path
import json

BASE = Path(__file__).resolve().parent
PROJECT = '''project Probe is
   for Languages use ("Ada");
   for Source_Dirs use ("src"{extra_dirs});
   for Main use ("main.adb");
{source_files}   for Object_Dir use "obj";
   for Exec_Dir use "bin";
   package Naming is
      for Body ("Main") use "main.adb" at 1;
   end Naming;
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-gnata", "-gnato");
   end Compiler;
end Probe;
'''
CASES = []

def add(name, source, native, membership, questions, expected_sites):
    path = BASE / 'probes' / name
    (path / 'src').mkdir(parents=True, exist_ok=True)
    (path / 'src/main.adb').write_text(source)
    has_io = name == 'doors'
    (path / 'probe.gpr').write_text(PROJECT.format(
        extra_dirs=', "../../../../src"' if has_io else '',
        source_files=('   for Source_Files use ("main.adb", "silver_io.ads", "silver_io.adb", "silver_output_libc.ads");\n' if has_io else '')))
    CASES.append(dict(name=name, native_expectation=native,
                      selected_silver_rule=membership, questions=questions,
                      expected_source_sites=expected_sites,
                      source_bytes=len(source.encode()), status='prepared; not executed',
                      source_lines=[{'line':i,'text':line.strip()} for i,line in enumerate(source.splitlines(),1)
                                    if ':=' in line or 'Image' in line]))

# Each selected comparison has a constrained target that needs its reached flow.
matrices = [
 ('direct_true', [('X = 5','Exact'),('X /= 0','Positive'),('X < 9','Below'),('X <= 8','Below'),('X > 0','Positive'),('X >= 1','Positive')], True),
 ('reversed_true', [('5 = X','Exact'),('0 /= X','Positive'),('9 > X','Below'),('8 >= X','Below'),('0 < X','Positive'),('1 <= X','Positive')], True),
 ('direct_false', [('X = 0','Positive'),('X /= 5','Exact'),('X < 1','Positive'),('X <= 0','Positive'),('X > 8','Below'),('X >= 9','Below')], False),
 ('reversed_false', [('0 = X','Positive'),('5 /= X','Exact'),('1 > X','Positive'),('0 >= X','Positive'),('8 < X','Below'),('9 <= X','Below')], False),
]
guards = '''procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   Positive : Integer range 1 .. 9 := 1;
   Below : Integer range 0 .. 8 := 0;
   Exact : Integer range 5 .. 5 := 5;
begin
   for Seed in 0 .. 9 loop
      X := Seed;
'''
sites=[]
for label, items, true in matrices:
    for cond,target in items:
        if true:
            guards += f'      if {cond} then {target} := X; end if;\n'
        else:
            guards += f'      if {cond} then null; else {target} := X; end if;\n'
        sites.append(dict(label=f'{label}: {cond}', operation=f'{target} := X', expected='constrained assignment range check, if retained, proved'))
guards += '   end loop;\nend Main;\n'
add('guards',guards,'pass','admit after selected implementation',
    ['All six operators, each direct/reversed and true/false: 24 discriminating target assignments.'],sites)

flow='''procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 20 := 0;
   Small : Integer range 0 .. 9 := 0;
   Visits : Integer range 0 .. 100 := 0;
   Other : Integer range 0 .. 20 := 0;
   Text : String := "x";
begin
   for Step in 1 .. 100 loop
      if Visits < 100 then Visits := (Visits + 1); end if;
   end loop;
   for Seed in 0 .. 20 loop
      X := Seed;
      if X < 9 then
         X := 9;
         Small := (9 - X);
      end if;
      X := Seed;
      if X < 9 then
         Other := 20;
         Text := "y";
         Small := X;
      end if;
      X := Seed;
      if X < 9 then X := 1; else X := 2; end if;
      Small := X;
      X := Seed;
      if X <= 9 then
         for I in 1 .. X loop
            X := 20;
            Small := I;
         end loop;
      end if;
      for X in 0 .. 20 loop
         if X <= 9 then
            for X in 1 .. 2 loop Small := X; end loop;
            Small := X;
         end if;
      end loop;
      X := 1;
      for I in 2 .. X loop null; end loop;
      Small := X;
   end loop;
end Main;
'''
add('flow',flow,'pass','admit after selected implementation',[
 'Guarded non-unrolled counter; assignment replaces stale facts; unrelated scalar/String writes preserve X.',
 'Both branch outputs join to [1,2]; captured index survives bound-object write; shadowed index restores the outer index identity.',
 'Provably empty loop restores precise entry flow.'
],[dict(operation='Visits := (Visits + 1)',expected='overflow/range checks, if retained, proved'),
   dict(operation='Small := (9 - X)',expected='replacement makes RHS 0, retained checks proved'),
   dict(operation='Small := I',expected='captured index upper bound 9 despite X := 20'),
   dict(operation='Small := X (after shadowing)',expected='outer index X identity remains in 0 .. 9')])

edges='''procedure Main is
   pragma SPARK_Mode (On);
   Min : constant Integer := -2147483648;
   Max : constant Integer := 2147483647;
   Value : Integer := 0;
   D : Integer range 0 .. 9 := 0;
   Q : Integer range 0 .. 9 := 0;
begin
   for X in -2147483648 .. 2147483647 loop
      if X > Min then Value := (X - 1); end if;
      if Min < X then Value := (X - 1); end if;
      if X <= Min then null; else Value := (X - 1); end if;
      if X < Max then Value := (X + 1); end if;
      if Max > X then Value := (X + 1); end if;
      if X >= Max then null; else Value := (X + 1); end if;
      if X > Min then Value := (-X); end if;
      if X < Min then Value := X; end if;
      if X > Max then Value := X; end if;
   end loop;
   for Seed in 0 .. 9 loop
      D := Seed;
      if D > 0 and then (9 / D) > 0 then Q := (9 / D); end if;
      if D = 0 or else (9 / D) > 0 then null; end if;
      if not (D = 0) and then (9 / D) > 0 then null; end if;
      if D > 0 and then Integer'Image ((9 / D)) /= "" then null; end if;
   end loop;
end Main;
'''
add('edges',edges,'pass','admit after selected implementation',[
 'Strict minimum/maximum arithmetic in direct/reversed/false outcomes; safe minimum-negation guard.',
 'Impossible endpoint arms retain incoming flow without inventing static overflow.',
 'Reached flow enters and-then/or-else/not RHS arithmetic and Image. Proof only: full-Integer loop must not be executed.'
],[dict(operation='X - 1 (3 sites), X + 1 (3 sites), -X (1 site)',expected='7 dynamic arithmetic sites; emitted overflow/range checks proved'),
   dict(operation='9 / D (5 sites)',expected='5 guard-dependent division sites; emitted nonzero-divisor checks proved; raw rule may be VC_RAISE'),
   dict(operation="Integer'Image ((9 / D))",expected='Image report/advisory inventory retained; no unproved safety check')])

conservative='''procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   D : Integer range -1 .. 1 := 0;
   Q : Integer range -9 .. 9 := 0;
   Source : Integer range 0 .. 9 := 0;
   Snapshot : constant Integer := Source;
begin
   for Seed in -1 .. 1 loop
      D := Seed;
      if D /= 0 then Q := (9 / D); end if;
   end loop;
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 2 then
         for I in 2 .. X loop X := I; end loop;
      end if;
      if X = 10 then X := X; end if;
   end loop;
   for I in 0 .. 9 loop
      if I > Snapshot then Q := (9 / I); end if;
   end loop;
end Main;
'''
add('conservative',conservative,'pass expected; native result must be observed','reject whole source under selected Silver rules',[
 'Crossing-zero /= removes interior zero semantically, but one-interval hull retains it: intentional Silver rejection, not expected native failure.',
 'X < 2 makes index interval for 2 .. X empty; index-dependent assignment remains excluded even if native proves vacuously.',
 'Contradictory mutable X = 10 arm retains nonempty incoming flow; self-copy remains admissible in isolation.',
 'Snapshot of mutable Source is nonstatic despite exact value; cannot supply selected refinement threshold.'
],[dict(operation='9 / D',expected='native may prove using disjunction; Silver convex-hull rule rejects'),
   dict(operation='X := I in newly empty loop',expected='native may prove; Silver nonempty-RHS rule rejects'),
   dict(operation='9 / I under I > Snapshot',expected='native may prove using immutable Snapshot=0; Silver static-threshold rule rejects')])

unsafe='''procedure Main is
   pragma SPARK_Mode (On);
   X : Integer range 0 .. 9 := 0;
   Wide : Integer := 0;
   Negated : Integer := 0;
begin
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then
         X := 9;
         X := (X + 1);
      end if;
   end loop;
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then X := 0; else X := 9; end if;
      X := (X + 1);
   end loop;
   for Seed in 0 .. 9 loop
      X := Seed;
      if X < 9 then X := 0; end if;
      X := (X + 1);
   end loop;
   for Seed in 0 .. 8 loop
      X := Seed;
      if X < 9 then
         for Step in 1 .. 2 loop X := (X + 1); end loop;
      end if;
   end loop;
   for Seed in -2147483648 .. -2147483647 loop
      Wide := Seed;
      if Wide < 0 then Negated := (-Wide); end if;
   end loop;
   for Seed in 0 .. 20 loop
      Wide := Seed;
      for Wide in 1 .. 2 loop null; end loop;
      X := Wide;
   end loop;
end Main;
'''
add('unsafe',unsafe,'EXPECTED FAIL','reject',[
 'Expected-fail stale assignment, explicit branch join, omitted else, stale pre-loop guard, unguarded minimum negation, and hidden mutable/index identity confusion.',
 'Counterexamples respectively X=9 after replacement, Seed=9, Seed=9, Seed=8 on second iteration, Seed=Integer minimum, Seed=10 with hidden Wide.'
],[dict(operation='X := (X + 1) (4 sites)',expected='4 unsafe assignment range sites; unproved/failed range diagnostics expected'),
   dict(operation='Negated := (-Wide)',expected='1 unsafe overflow site at Integer minimum; unproved/failed overflow diagnostic expected'),
   dict(operation='X := Wide after same-spelled loop index',expected='1 unsafe assignment range site; hidden mutable Wide has not become the inner index')])

static='''procedure Main is
   pragma SPARK_Mode (On);
   Max : constant Integer := 2147483647;
   Min : constant Integer := -2147483648;
   Value : Integer := 0;
begin
   if Max < 0 then Value := (Max + 1); end if;
   if Min > 0 then Value := (-Min); end if;
end Main;
'''
add('static',static,'EXPECTED FAIL (frontend/static legality)','reject',[
 'Impossible static-constant arms do not waive static expression legality.',
 'Both sites are beyond Integer range; retain complete frontend errors/warnings even if no .spark exists.'
],[dict(operation='Max + 1',expected='static Integer overflow diagnostic / frontend rejection'),
   dict(operation='-Min',expected='static Integer overflow diagnostic / frontend rejection')])

doors='''with Silver_IO;
procedure Main is
   pragma SPARK_Mode (On);
   Visits : Integer range 0 .. 100 := 0;
begin
   for Door in 1 .. 100 loop
      Visits := 0;
      for Pass in 1 .. 100 loop
         if (Door mod Pass) = 0 and then Visits < 100 then
            Visits := (Visits + 1);
         end if;
      end loop;
      if (Visits mod 2) = 1 then
         Silver_IO.Put_Line (Integer'Image (Door) & " is open");
      else
         Silver_IO.Put_Line (Integer'Image (Door) & " is closed");
      end if;
   end loop;
end Main;
'''
add('doors',doors,'pass; exact 100-line execution match after proof/build','admit after selected implementation',[
 'Complete finite 100 doors task; output independently derived by pass-major toggles.',
 'Per-door visit counter is guarded on each iteration; at most 99 prior visits means no required toggle is suppressed.',
 'Use current Silver_IO source directly, selected source files only; no hidden annotated Main replacement.'
],[dict(operation='Door mod Pass, Visits + 1, Visits mod 2',expected='guard-specific range/overflow/nonzero-divisor checks proved when retained'),
   dict(operation="Integer'Image (Door) & suffix (2 sites)",expected='all emitted Image/concatenation checks proved and advisories inventoried'),
   dict(operation='Silver_IO',expected='complete selected-library obligations included by -U')])

# Independent task oracle: pass-major Boolean toggle, not visit counting/parity.
states=[False]*101
for p in range(1,101):
    for door in range(p,101,p):
        states[door]=not states[door]
(BASE/'doors.expected.txt').write_text(''.join(f' {i} is {"open" if states[i] else "closed"}\n' for i in range(1,101)))
(BASE/'manifest.json').write_text(json.dumps(dict(issue=237, status='prepared only; no native execution',
    cases=CASES, rationale='Seven serial GNATprove invocations. Twenty-four guard-target sites, sparse composition cases, two labelled expected-fail controls, one complete driver. No division-only rerun.'),indent=2)+'\n')
print(json.dumps({x['name']:x['source_bytes'] for x in CASES},indent=2))
