module

public import Silver.ReviewedOutputShape

@[expose] public section

/-! Aliases of the reviewed complete native source shapes. Their equality with
current authoritative tokens is established by the final source bridge. -/
namespace Silver.Predicate.SourceShape

def specTokens : List String := Output.SourceShape.outputSpecification
def bodyTokens : List String := Output.SourceShape.outputImplementation

end Silver.Predicate.SourceShape
