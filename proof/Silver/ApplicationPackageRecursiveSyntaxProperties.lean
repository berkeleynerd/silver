module

public import Silver.ApplicationPackageRecursiveSyntax
public import Silver.ApplicationPackageConditionalSource

@[expose] public section

namespace Silver.ApplicationPackageBodies.SourceSyntax
open ApplicationPackages Compose Predicate Recursive

theorem TailCodeAt.original {readers names source stop required seen result code}
    (read : TailCodeAt readers names source stop required seen result code) :
    TailTree readers source stop required seen result := by
  apply TailCodeAt.rec
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

theorem StatementCodeAt.nonempty {readers names source result code}
    (read : StatementCodeAt readers names source result code) : code ≠ [] := by
  cases read with
  | basic => intro impossible; cases impossible
  | conditional _ _ arms _ _ =>
    cases arms <;> simp only [Statement.lowerArms] <;> (intro impossible; cases impossible)
  | counted => intro impossible; cases impossible
  | array => intro impossible; cases impossible

theorem TailCodeAt.nonempty {readers names source stop result code}
    (read : TailCodeAt readers names source stop true false result code) : code ≠ [] := by
  cases read with
  | done _ _ impossible => exact Bool.noConfusion (impossible rfl)
  | next _ _ _ statement _ _ =>
    intro empty
    exact statement.nonempty (List.append_eq_nil_iff.mp empty).1

abbrev childReading (readers : Readers) (names : CallNames) (source : Statement.Input) : Statement.ChildReading :=
  fun input stop code result => TailCodeAt readers names (atInput source input) stop true false result code

/-- Compose independently extracted condition/child source readings with the
original ordered arm history. The conclusion stores no semantic checker. -/
theorem ArmsCodeAt.of_reading {readers : Readers} {names source before entries after codes}
    (reading : Statement.ArmsReading readers.statement source before entries after)
    (sourceCode : Statement.ArmCodesAt readers.statement source (childReading readers names source) entries codes) :
    ArmsCodeAt readers names source before after codes := by
  induction reading generalizing codes with
  | last parsed finished =>
    cases sourceCode with
    | cons condition child rest =>
      cases rest
      exact .last parsed condition child finished
  | next parsed continued _ ih =>
    cases sourceCode with
    | cons condition child rest => exact .next parsed condition child continued (ih rest)

theorem ElseCodeAt.of_reading {readers : Readers} {names source state code}
    (reading : Statement.ElseCodeAt readers.statement source (childReading readers names source) state code) :
    ElseCodeAt readers names source state code := by
  cases reading with
  | absent missing => exact .absent missing
  | present keyword child => exact .present keyword child

end Silver.ApplicationPackageBodies.SourceSyntax
