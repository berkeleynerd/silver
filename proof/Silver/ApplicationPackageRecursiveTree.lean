module

public import Silver.ApplicationPackageRecursiveReading

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

def atInput (source : Statement.Input) (value : ApplicationScan) : Statement.Input :=
  {source with input := value}

def atContext (source : Statement.Input) (context : ParseContext) (value : ApplicationScan) : Statement.Input :=
  {source with context, input := value}

/-! The mutually recursive tree contains only original reader equations,
source selections and calls. Every arm, optional ELSE, loop body and sequential
statement is retained, including statically unreachable branches. Semantic
syntax and all checker results are constructed from this tree afterwards. -/
mutual
  inductive StatementTree (readers : Readers) : Statement.Input → ApplicationScan → Prop
    | basic {source : Statement.Input} : source.input.scan.position ≠ 0 →
        readers.statement.takeToken source.text source.input.scan.position (.word "if") = 0 →
        readers.statement.takeToken source.text source.input.scan.position (.word "for") = 0 →
        (readers.statement.applicationBasic source.text source.context source.input source.info
          source.catalog source.procedures).scan.position ≠ 0 →
        StatementTree readers source
          (readers.statement.applicationBasic source.text source.context source.input source.info source.catalog source.procedures)
    | conditional {source : Statement.Input} {state result} : source.input.scan.position ≠ 0 →
        readers.statement.takeToken source.text source.input.scan.position (.word "if") ≠ 0 →
        ArmsTree readers source
          ⟨Statement.atPosition source.input
            (readers.statement.takeToken source.text source.input.scan.position (.word "if")), source.input.scan.facts, false⟩ state →
        ElseTree readers source state →
        Statement.ClosingReading readers.statement source state result →
        StatementTree readers source result
    | iteration {source : Statement.Input} {iteration result} : source.input.scan.position ≠ 0 →
        readers.statement.takeToken source.text source.input.scan.position (.word "if") = 0 →
        readers.statement.takeToken source.text source.input.scan.position (.word "for") ≠ 0 →
        Statement.IterationReading readers.statement source
          (readers.statement.takeToken source.text source.input.scan.position (.word "for")) iteration result →
        TailTree readers
          (atContext source (Statement.innerContext source iteration)
            (Statement.innerInput source iteration (Statement.widened readers.statement source iteration)))
          .endOnly true false (Statement.loopResult readers.statement source iteration) →
        StatementTree readers source result

  inductive ArmsTree (readers : Readers) : Statement.Input → Statement.Arms → Statement.Arms → Prop
    | last {source before read after} : Statement.readArm readers.statement source before = some read →
        TailTree readers
          (atInput source (Statement.thenInput readers.statement source before
            (Statement.conditionFor readers.statement source before))) .arm true false read.branch →
        Statement.finishArm readers.statement source read = .finished after →
        ArmsTree readers source before after
    | next {source before read after final} : Statement.readArm readers.statement source before = some read →
        TailTree readers
          (atInput source (Statement.thenInput readers.statement source before
            (Statement.conditionFor readers.statement source before))) .arm true false read.branch →
        Statement.finishArm readers.statement source read = .continued after →
        ArmsTree readers source after final → ArmsTree readers source before final

  inductive ElseTree (readers : Readers) : Statement.Input → Statement.Arms → Prop
    | absent {source state} : Statement.elsePosition readers.statement source state = 0 → ElseTree readers source state
    | present {source state} : Statement.elsePosition readers.statement source state ≠ 0 →
        TailTree readers (atInput source (Statement.atPosition state.value (Statement.elsePosition readers.statement source state)))
          .endOnly true false (Statement.elseResult readers.statement source state) →
        ElseTree readers source state

  inductive TailTree (readers : Readers) : Statement.Input → BodyStop → Bool → Bool → ApplicationScan → Prop
    | done {source : Statement.Input} {stop required seen} : source.input.scan.position ≠ 0 →
        readers.tail.atBodyStop source.text source.input.scan.position stop = true →
        (required = true → seen = true) → TailTree readers source stop required seen source.input
    | next {source : Statement.Input} {stop required seen first result} : source.input.scan.position ≠ 0 →
        readers.tail.atBodyStop source.text source.input.scan.position stop = false →
        readers.statementResult source = first → StatementTree readers source first →
        source.input.scan.position < first.scan.position →
        TailTree readers (atInput source first) stop required true result →
        TailTree readers source stop required seen result
end

theorem ArmsTree.reading {readers : Readers} {source : Statement.Input} {before after : Statement.Arms}
    (tree : ArmsTree readers source before after) :
    ∃ entries, Statement.ArmsReading readers.statement source before entries after := by
  refine ArmsTree.rec
    (motive_1 := fun _ _ _ => True)
    (motive_3 := fun _ _ _ => True)
    (motive_4 := fun _ _ _ _ _ _ => True)
    ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ tree
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; exact ⟨_, .last ‹_› ‹_›⟩
  · intros; rename_i ih
    obtain ⟨entries, reading⟩ := ih
    exact ⟨_, .next ‹_› ‹_› reading⟩
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; trivial

theorem StatementTree.reading {readers : Readers} {source : Statement.Input} {result : ApplicationScan}
    (tree : StatementTree readers source result) : Statement.Reading readers.statement source result := by
  cases tree with
  | basic present noIf noFor _ => exact .basic present noIf noFor
  | conditional present keyword arms _ closing =>
    obtain ⟨entries, reading⟩ := arms.reading
    exact .conditional present keyword reading closing
  | iteration present noIf keyword loop _ => exact .iteration present noIf keyword loop

theorem TailTree.reading {readers : Readers} {source : Statement.Input} {stop : BodyStop}
    {required seen : Bool} {result : ApplicationScan}
    (tree : TailTree readers source stop required seen result) :
    ∃ items, Tail.Reading readers.tail (tailContext source stop required) ⟨source.input, seen⟩ items result := by
  refine TailTree.rec
    (motive_1 := fun _ _ _ => True)
    (motive_2 := fun _ _ _ _ => True)
    (motive_3 := fun _ _ _ => True)
    ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ tree
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; trivial
  · intros; exact ⟨[], .done _ ‹_› ‹_› ‹_›⟩
  · intros; rename_i ih
    obtain ⟨items, reading⟩ := ih
    exact ⟨_ :: items, .cons _ _ ‹_› ‹_› ‹_› ‹_› reading⟩

end Silver.ApplicationPackageBodies.Recursive
