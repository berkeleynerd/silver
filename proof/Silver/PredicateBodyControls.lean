module

public import Silver.PredicateBodyProperties

@[expose] public section
namespace Silver.Predicate
open Compose Bindings PathFacts Compose.Expressions

/-- Native target and capacity fields remain in their declared domains. -/
def Controls (context : ParseContext) (scan : BodyScan) : Prop :=
  scan.target ≤ context.names.length ∧ scan.capacity ≤ maxSourceLength

theorem bodyToken_controls (text : Source) (context : ParseContext) (scan : BodyScan) (token : ShellToken)
    (valid : Controls context scan) : Controls context (bodyToken text scan token) := valid

theorem bodyTokens_controls (text : Source) (context : ParseContext) (scan : BodyScan) (tokens : List ShellToken)
    (valid : Controls context scan) : Controls context (bodyTokens text scan tokens) := by
  induction tokens generalizing scan with
  | nil => exact valid
  | cons token tokens ih => exact ih _ (bodyToken_controls text context scan token valid)

theorem basicRaw_controls (text : Source) (context : ParseContext) (scan : BodyScan)
    (valid : Controls context scan) : Controls context (basicRaw text context scan) := by
  unfold basicRaw
  cases basicKind text context scan with
  | null => exact valid
  | output =>
      dsimp only
      split
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
      · exact valid
  | reject => exact valid
  | assignment =>
      have targetBound : (targetAt text (parserState context scan) false).target ≤ context.names.length := by
        unfold targetAt
        dsimp only
        split
        · exact Nat.zero_le _
        · exact model_lookup_valid text context.names _ _
      dsimp only
      split
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
      · exact ⟨targetBound, valid.2⟩

theorem basicBody_controls (text : Source) (context : ParseContext) (scan : BodyScan)
    (valid : Controls context scan) : Controls context (basicBody text context scan) := by
  unfold basicBody
  split
  · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  · dsimp only
    split
    · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    · exact basicRaw_controls text context scan valid

theorem branchStart_controls (text : Source) (context : ParseContext) (scan : BodyScan) (keyword : String)
    (valid : Controls context scan) : Controls context (branchStart text context scan keyword).1 := valid

mutual
  theorem statementBody_controls (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : Controls context scan) :
      Controls context (statementBody text context scan) := by
    rw [statementBody]
    split
    · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    · split
      · exact conditionalBody_controls text context scan sv
      · exact basicBody_controls text context scan sv
  termination_by (bodyRemaining text scan, 2)

  theorem conditionalBody_controls (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : Controls context scan) :
      Controls context (conditionalBody text context scan) := by
    rw [conditionalBody]
    try dsimp only
    split
    · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    · split
      · split
        · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
        · split
          · try dsimp only
            split
            · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
            · exact bodyTokens_controls text context _ _ (alternativeBody_controls text context _
                (readBody_controls text context _ .arm (branchStart_controls text context scan _ sv)))
          · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  termination_by (bodyRemaining text scan, 1)

  theorem alternativeBody_controls (text : Source) (context : ParseContext) (scan : BodyScan)
      (sv : Controls context scan) :
      Controls context (alternativeBody text context scan) := by
    rw [alternativeBody]
    split
    · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    · split
      · try dsimp only
        split
        · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
        · split
          · split
            · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
            · split
              · exact alternativeBody_controls text context _
                  (readBody_controls text context _ .arm (branchStart_controls text context scan _ sv))
              · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
          · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
      · split
        · try dsimp only
          split
          · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
          · split
            · exact readBody_controls text context _ .endOnly (bodyToken_controls text context scan _ sv)
            · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
        · split
          · exact sv
          · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  termination_by (bodyRemaining text scan, 1)

  theorem bodyTail_controls (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (sv : Controls context scan) :
      Controls context (bodyTail text context scan stop) := by
    rw [bodyTail]
    split
    · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    · split
      · exact sv
      · try dsimp only
        split
        · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
        · split
          · exact bodyTail_controls text context _ stop (statementBody_controls text context scan sv)
          · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  termination_by (bodyRemaining text scan, 3)

  theorem readBody_controls (text : Source) (context : ParseContext) (scan : BodyScan) (stop : BodyStop)
      (sv : Controls context scan) :
      Controls context (readBody text context scan stop) := by
    rw [readBody]
    try dsimp only
    split
    · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    · split
      · exact bodyTail_controls text context _ stop (statementBody_controls text context scan sv)
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  termination_by (bodyRemaining text scan, 3)
end

end Silver.Predicate
