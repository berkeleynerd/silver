module

public import Silver.SequenceNativeProjection
public import Silver.SequenceFullEquations
public import Silver.SequenceNativeUnique

@[expose] public section

/-! Project the full admission scanner into the scalar native interface.
This supplies a second interpretation whose equations can be compared using
uniqueness, without repeating the recursive scanner's induction. -/

namespace Silver.Sequence.Native
open Compose

set_option backward.dsimp.instances true

def projectedCalls : Calls where
  token := modelToken
  basic := modelBasic
  atStop := modelStop
  statement := fun text context scan => compact context (statementAt text (expand context scan))
  conditional := fun text context scan => compact context (conditionalAt text (expand context scan))
  alternative := fun text context scan => compact context (alternativeAt text (expand context scan))
  tail := fun text context scan stop => compact context (bodyTail text (expand context scan) stop.model)
  read := fun text context scan stop => compact context (Silver.Sequence.readBody text (expand context scan) stop.model)

theorem compact_strict_ranges (text : Source) (context : Context) (scan : Scan) (result : ScanResult)
    (valid : Silver.Sequence.ValidScan text result)
    (advances : result.state.position ≠ 0 → scan.position < result.state.position) :
    ValidScan text context (compact context result) ∧
      ((compact context result).position = 0 ∨ scan.position < (compact context result).position) := by
  refine ⟨compact_valid text context result valid, ?_⟩
  unfold compact
  split
  · exact Or.inl rfl
  · rename_i success
    exact Or.inr (advances (fun zero => success (Or.inl zero)))

theorem compact_monotone_ranges (text : Source) (context : Context) (scan : Scan) (result : ScanResult)
    (valid : Silver.Sequence.ValidScan text result)
    (advances : result.state.position ≠ 0 → scan.position ≤ result.state.position) :
    ValidScan text context (compact context result) ∧
      ((compact context result).position = 0 ∨ scan.position ≤ (compact context result).position) := by
  refine ⟨compact_valid text context result valid, ?_⟩
  unfold compact
  split
  · exact Or.inl rfl
  · rename_i success
    exact Or.inr (advances (fun zero => success (Or.inl zero)))

theorem projected_ranges : Ranges projectedCalls where
  token := by
    intro text valid context scan token contextValid scanValid _
    exact model_token_ranges text valid context scan token contextValid scanValid
  basic := by
    intro text valid context scan contextValid scanValid
    exact model_basic_ranges text valid context scan contextValid scanValid
  statement := by
    intro text valid context scan contextValid scanValid
    apply compact_strict_ranges
    · exact model_statementAt_valid text valid _ (expand_valid text context scan contextValid scanValid)
    · exact fun accepted => statement_progress accepted
  conditional := by
    intro text valid context scan contextValid scanValid
    apply compact_strict_ranges
    · exact model_conditionalAt_valid text valid _ (expand_valid text context scan contextValid scanValid)
    · exact fun accepted => conditional_progress accepted
  alternative := by
    intro text valid context scan contextValid scanValid
    apply compact_monotone_ranges
    · exact model_alternativeAt_valid text valid _ (expand_valid text context scan contextValid scanValid)
    · exact fun accepted => alternative_progress text valid _
        (expand_valid text context scan contextValid scanValid) accepted
  tail := by
    intro text valid context scan stop contextValid scanValid
    apply compact_monotone_ranges
    · exact model_bodyTail_valid text valid _ stop.model (expand_valid text context scan contextValid scanValid)
    · exact fun accepted => bodyTail_progress text valid _ stop.model
        (expand_valid text context scan contextValid scanValid) accepted
  read := by
    intro text valid context scan stop contextValid scanValid
    apply compact_strict_ranges
    · exact model_readBody_valid text valid _ stop.model (expand_valid text context scan contextValid scanValid)
    · exact fun accepted => readBody_progress text valid _ stop.model
        (expand_valid text context scan contextValid scanValid) accepted

end Silver.Sequence.Native
