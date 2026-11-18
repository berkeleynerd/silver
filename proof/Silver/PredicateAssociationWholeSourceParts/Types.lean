module

public import Silver.PredicateAssociationSource
public import Silver.ReviewedOutputShape
import all Init.Data.Repr

@[expose] public section

open Silver.SourceBridge
open Silver.Predicate.AssociationNative

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.PredicateAssociationWholeSourceCandidate.Parts

theorem formalSet : typeDeclaration "formal_set" Output.SourceShape.outputImplementation =
    some ["array", "(", "functions", ".", "formal_index", ")", "of", "boolean"] := by
  decide +kernel

theorem noFormals : Source.declaration "no_formals" Output.SourceShape.outputImplementation =
    some ["constant", "formal_set", ":=", "(", "others", "=>", "false", ")"] := by
  decide +kernel

theorem association : Silver.Lexical.SourceBridge.recordDeclaration "actual_association" Output.SourceShape.outputImplementation =
    some ["record", "formal", ":", "functions", ".", "formal_count", ";", "payload_first", ":", "literal_position", ";", "named", ":", "boolean", ";", "end", "record"] := by
  decide +kernel

theorem invalidAssociation : Source.declaration "invalid_association" Output.SourceShape.outputImplementation =
    some ["constant", "actual_association", ":=", "(", "0", ",", "0", ",", "false", ")"] := by
  decide +kernel

end Silver.PredicateAssociationWholeSourceCandidate.Parts
