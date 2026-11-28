module

public import Silver.ApplicationPackageBasicSyntax
public import Silver.ApplicationPackageArrayChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

def firstArm (calls : Statement.Calls) (source : Statement.Input) : Statement.Arms :=
  ⟨Statement.atPosition source.input
      (calls.takeToken source.text source.input.scan.position (.word "if")),
    source.input.scan.facts, false⟩

def loopChild (calls : Statement.Calls) (source : Statement.Input)
    (iteration : Statement.Iteration) : Statement.Input :=
  atContext source (Statement.innerContext source iteration)
    (Statement.innerInput source iteration (Statement.widened calls source iteration))

/-! Exact source syntax for the original recursive reader. These relations
retain every original call, guard selection and branch, and contain no semantic
check, safety, effect coverage, obligation discharge or valid-program field.
The one-statement reader lowers ELSIF into a nonempty list of nested choices;
the tail concatenates those source-preserving lists in original scan order. -/
mutual
  inductive StatementCodeAt (readers : Readers) (names : CallNames) :
      Statement.Input → ApplicationScan → List Predicate.Statement → Prop
    | basic {source result item}
        (present : source.input.scan.position ≠ 0)
        (noIf : readers.statement.takeToken source.text source.input.scan.position (.word "if") = 0)
        (noFor : readers.statement.takeToken source.text source.input.scan.position (.word "for") = 0)
        (returned : readers.statement.applicationBasic source.text source.context source.input source.info
          source.catalog source.procedures = result)
        (accepted : result.scan.position ≠ 0)
        (original : BasicCodeAt readers.basic names source result item) :
        StatementCodeAt readers names source result [item]
    | conditional {source state result codes alternative}
        (present : source.input.scan.position ≠ 0)
        (keyword : readers.statement.takeToken source.text source.input.scan.position (.word "if") ≠ 0)
        (arms : ArmsCodeAt readers names source (firstArm readers.statement source) state codes)
        (otherwise : ElseCodeAt readers names source state alternative)
        (closing : Statement.ClosingReading readers.statement source state result) :
        StatementCodeAt readers names source result (Statement.lowerArms codes alternative)
    | counted {source iteration result lower upper body}
        (present : source.input.scan.position ≠ 0)
        (noIf : readers.statement.takeToken source.text source.input.scan.position (.word "if") = 0)
        (keyword : readers.statement.takeToken source.text source.input.scan.position (.word "for") ≠ 0)
        (header : Statement.IterationReading readers.statement source
          (readers.statement.takeToken source.text source.input.scan.position (.word "for")) iteration result)
        (kind : loopIsArray source.text source.input.scan = false)
        (bounds : LoopBoundsAt source.text source.context source.input.scan lower upper)
        (inside : TailCodeAt readers names (loopChild readers.statement source iteration)
          .endOnly true false (Statement.loopResult readers.statement source iteration) body) :
        StatementCodeAt readers names source result
          [.forLoop (source.context.scalarNames.length + 1)
            (loopHeader source.text source.context source.input.scan).reverse lower upper body]
    | array {source iteration result body}
        (present : source.input.scan.position ≠ 0)
        (noIf : readers.statement.takeToken source.text source.input.scan.position (.word "if") = 0)
        (keyword : readers.statement.takeToken source.text source.input.scan.position (.word "for") ≠ 0)
        (header : Statement.IterationReading readers.statement source
          (readers.statement.takeToken source.text source.input.scan.position (.word "for")) iteration result)
        (kind : loopIsArray source.text source.input.scan = true)
        (inside : TailCodeAt readers names (loopChild readers.statement source iteration)
          .endOnly true false (Statement.loopResult readers.statement source iteration) body) :
        StatementCodeAt readers names source result
          [.arrayLoop (source.context.scalarNames.length + 1)
            (loopHeader source.text source.context source.input.scan).reverse
            (ArrayBindings.binding source.context.arrayNames
              (loopArrayTarget source.text source.context source.input.scan)).viewDescriptor body]

  inductive ArmsCodeAt (readers : Readers) (names : CallNames) :
      Statement.Input → Statement.Arms → Statement.Arms → List Statement.ArmCode → Prop
    | last {source before read after condition body}
        (parsed : Statement.readArm readers.statement source before = some read)
        (guard : ConditionAt source.text source.context before.value.scan.position before.value.scan.facts
          condition (Statement.conditionFor readers.statement source before))
        (inside : TailCodeAt readers names
          (atInput source (Statement.thenInput readers.statement source before
            (Statement.conditionFor readers.statement source before))) .arm true false read.branch body)
        (finished : Statement.finishArm readers.statement source read = .finished after) :
        ArmsCodeAt readers names source before after [(condition, body)]
    | next {source before read after final condition body rest}
        (parsed : Statement.readArm readers.statement source before = some read)
        (guard : ConditionAt source.text source.context before.value.scan.position before.value.scan.facts
          condition (Statement.conditionFor readers.statement source before))
        (inside : TailCodeAt readers names
          (atInput source (Statement.thenInput readers.statement source before
            (Statement.conditionFor readers.statement source before))) .arm true false read.branch body)
        (continued : Statement.finishArm readers.statement source read = .continued after)
        (following : ArmsCodeAt readers names source after final rest) :
        ArmsCodeAt readers names source before final ((condition, body) :: rest)

  inductive ElseCodeAt (readers : Readers) (names : CallNames) :
      Statement.Input → Statement.Arms → List Predicate.Statement → Prop
    | absent {source state}
        (missing : Statement.elsePosition readers.statement source state = 0) :
        ElseCodeAt readers names source state []
    | present {source state body}
        (keyword : Statement.elsePosition readers.statement source state ≠ 0)
        (inside : TailCodeAt readers names
          (atInput source (Statement.atPosition state.value (Statement.elsePosition readers.statement source state)))
          .endOnly true false (Statement.elseResult readers.statement source state) body) :
        ElseCodeAt readers names source state body

  inductive TailCodeAt (readers : Readers) (names : CallNames) :
      Statement.Input → BodyStop → Bool → Bool → ApplicationScan → List Predicate.Statement → Prop
    | done {source stop required seen}
        (present : source.input.scan.position ≠ 0)
        (stopped : readers.tail.atBodyStop source.text source.input.scan.position stop = true)
        (nonempty : required = true → seen = true) :
        TailCodeAt readers names source stop required seen source.input []
    | next {source stop required seen first result head rest}
        (present : source.input.scan.position ≠ 0)
        (proceed : readers.tail.atBodyStop source.text source.input.scan.position stop = false)
        (returned : readers.statementResult source = first)
        (statement : StatementCodeAt readers names source first head)
        (advanced : source.input.scan.position < first.scan.position)
        (following : TailCodeAt readers names (atInput source first) stop required true result rest) :
        TailCodeAt readers names source stop required seen result (head ++ rest)
end

/-- Forgetting semantic syntax recovers exactly the already checked original
recursive tree. In particular, the decoder cannot delete an unvisited arm or
replace a native reader invocation with a separate parser. -/
theorem StatementCodeAt.original {readers names source result code}
    (read : StatementCodeAt readers names source result code) : StatementTree readers source result := by
  apply StatementCodeAt.rec
    (motive_1 := fun source result _ _ => StatementTree readers source result)
    (motive_2 := fun source before after _ _ => ArmsTree readers source before after)
    (motive_3 := fun source state _ _ => ElseTree readers source state)
    (motive_4 := fun source stop required seen result _ _ => TailTree readers source stop required seen result)
    ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ read
  · intro source result item present noIf noFor returned accepted original
    rw [← returned]
    exact .basic present noIf noFor (returned ▸ accepted)
  · intros; exact .conditional ‹_› ‹_› ‹_› ‹_› ‹_›
  · intros; exact .iteration ‹_› ‹_› ‹_› ‹_› ‹_›
  · intros; exact .iteration ‹_› ‹_› ‹_› ‹_› ‹_›
  · intros; exact .last ‹_› ‹_› ‹_›
  · intros; exact .next ‹_› ‹_› ‹_› ‹_›
  · intros; exact .absent ‹_›
  · intros; exact .present ‹_› ‹_›
  · intros; exact .done ‹_› ‹_› ‹_›
  · intros; exact .next ‹_› ‹_› ‹_› ‹_› ‹_› ‹_›

end Silver.ApplicationPackageBodies.SourceSyntax
