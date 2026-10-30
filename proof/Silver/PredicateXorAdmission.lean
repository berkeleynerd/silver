module

public import Silver.ComposeAtomAdmission

@[expose] public section

namespace Silver.Predicate

/-- Exact byte scanner for the native xor operand restriction. Quoted strings,
comments and identifier substrings do not count as operators. -/
def xorFreeModel (text : Source) (position after : Nat)
    (quoted comment wordStart : Bool) : Bool :=
  if position = 0 ∨ position > after then false
  else if position = after then true
  else if comment then
    xorFreeModel text (position + 1) after false (!lineEnd (Cursor.byteAt text position)) true
  else if quoted then
    if Cursor.byteAt text position = 34 then
      if position + 1 < after ∧ Cursor.byteAt text (position + 1) = 34 then
        xorFreeModel text (position + 2) after true false true
      else xorFreeModel text (position + 1) after false false true
    else xorFreeModel text (position + 1) after true false true
  else if Cursor.byteAt text position = 45 ∧ position + 1 < after ∧ Cursor.byteAt text (position + 1) = 45 then
    xorFreeModel text (position + 2) after false true true
  else if Cursor.byteAt text position = 34 then
    xorFreeModel text (position + 1) after true false true
  else if wordStart ∧ after - position ≥ 3 ∧
      lowercase (Cursor.byteAt text position) = 120 ∧
      lowercase (Cursor.byteAt text (position + 1)) = 111 ∧
      lowercase (Cursor.byteAt text (position + 2)) = 114 ∧
      (position + 3 = after ∨ !identifierCharacter (Cursor.byteAt text (position + 3))) then false
  else xorFreeModel text (position + 1) after false false (!identifierCharacter (Cursor.byteAt text position))
termination_by after - position
decreasing_by all_goals omega

def xorFree (text : Source) (first after : Nat) : Bool :=
  xorFreeModel text first after false false true

end Silver.Predicate
