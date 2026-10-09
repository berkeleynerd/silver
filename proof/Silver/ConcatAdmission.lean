import Silver.NamedAdmission

namespace Silver.Concat

open Named

abbrev Token := Named.Token
abbrev Parsed := Named.Parsed

def requiredTokens : List Named.Token :=
  [.base .withKeyword, .base .ioName, .base .semicolon,
   .base .procedureKeyword, .base .mainName, .base .isKeyword,
   .base .pragmaKeyword, .base .sparkModeName, .base .leftParenthesis,
   .base .onName, .base .rightParenthesis, .base .semicolon,
   .declarationName, .colon, .constantKeyword, .stringName, .assignment,
   .base .stringLiteral, .base .semicolon, .base .beginKeyword,
   .base .ioName, .base .dot, .base .putLineName, .base .leftParenthesis,
   .base .stringLiteral, .ampersand, .referenceName, .ampersand,
   .base .stringLiteral, .base .rightParenthesis, .base .semicolon,
   .base .endKeyword, .base .mainName, .base .semicolon]

def Member (source : Source) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ byte ∈ source, allowedCharacter byte = true) ∧
    ∃ events, Parsed source requiredTokens 1 {} events

def accepts (source : Source) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && Named.suffixMatches source requiredTokens 1 {}

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, Member, Named.parsed_iff, and_assoc]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

end Silver.Concat
