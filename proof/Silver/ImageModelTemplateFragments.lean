module

public import Silver.ImageModelTemplateSchema
public import Silver.ImageModelClone

@[expose] public section
set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.ImageModel.Templates

/-- The actual declaration chunks serialize the checked typed clone, including
the comma that appends it to the existing declaration array. -/
theorem declarations_serialized : bytes .declarations = Clone.declarationsFragment := by
  rw [Clone.declarationsFragment_bytes]
  decide +kernel

/-- The actual include chunks serialize the checked Standard__integer use. -/
theorem includes_serialized : bytes .includes = Clone.includesFragment := by
  rw [Clone.includesFragment_bytes]
  decide +kernel

theorem declarations_lookup (position : Nat) (positive : 1 ≤ position)
    (bounded : position ≤ length .declarations) :
    byteAt .declarations position = Clone.declarationsFragment[position - 1]?.getD 0 := by
  rw [byteAt_eq .declarations position positive bounded, declarations_serialized]

theorem includes_lookup (position : Nat) (positive : 1 ≤ position)
    (bounded : position ≤ length .includes) :
    byteAt .includes position = Clone.includesFragment[position - 1]?.getD 0 := by
  rw [byteAt_eq .includes position positive bounded, includes_serialized]

end Silver.ImageModel.Templates
