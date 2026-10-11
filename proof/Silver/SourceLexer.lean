import Silver.Cursor

/-!
Read the authoritative SPARK files into literal terms and recover their Ada
tokens. This is a proof-only reader for the expression-function fragment; it
does not participate in Silver source admission or compilation. Quoted strings
and character literals are kept intact, so comments and punctuation inside
them cannot be mistaken for source structure.

The reader is composed at physical LF boundaries; Ada string and character
literals cannot contain a physical line terminator. Every line is lexed and
certified independently, then a generic theorem composes the certificates.
The artifact generator computes candidate tokens, but the kernel checks each candidate
against the lexer and checks reconstruction of the entire original source.
No native evaluation theorem or trusted token-generation axiom is used.

`include_str` produces a literal checked by the kernel. The handwritten Lake
configuration attaches each external Ada file as a binary dependency of its
authoritative binding module; the runner rehashes inputs before using caches.
External includes must never be checked through an object for different bytes.
-/

set_option maxRecDepth 100000
set_option maxHeartbeats 10000000

namespace Silver.Source

abbrev Tokens := List String

/-- Compiler-source alphabet, including comments and quoted literals. Unsupported
Ada format effectors and alternate Unicode encodings cannot hide declarations. -/
def compilerCharacter (c : Char) : Bool :=
  c == '\t' || c == '\n' || c == '\r' || decide (32 ≤ c.toNat ∧ c.toNat ≤ 126)

def compilerSource (source : String) : Bool := source.toList.all compilerCharacter

def identifierChar (c : Char) : Bool :=
  c.isAlpha || c.isDigit || c == '_'

def readWord : List Char → List Char × List Char
  | [] => ([], [])
  | c :: cs =>
    if identifierChar c then
      let (word, rest) := readWord cs
      (c :: word, rest)
    else ([], c :: cs)

def readComment : List Char → List Char
  | [] => []
  | c :: cs => if c == '\n' || c == '\r' then c :: cs else readComment cs

def readString : List Char → Option (List Char × List Char)
  | [] => none
  | '"' :: '"' :: cs => do
    let (literal, rest) ← readString cs
    pure ('"' :: '"' :: literal, rest)
  | '"' :: cs => some (['"'], cs)
  | c :: cs =>
    if c == '\n' || c == '\r' then none
    else do
      let (literal, rest) ← readString cs
      pure (c :: literal, rest)

def lexer : Nat → List Char → Option Tokens
  | _, [] => some []
  | 0, _ :: _ => none
  | fuel + 1, chars@(c :: cs) =>
    if c == ' ' || c == '\t' || c == '\n' || c == '\r' then lexer fuel cs
    else if c == '%' then none
    else match chars with
    | '-' :: '-' :: tail => lexer fuel (readComment tail)
    | '"' :: tail => do
      let (literal, rest) ← readString tail
      let tokens ← lexer fuel rest
      pure (String.ofList ('"' :: literal) :: tokens)
    | '\'' :: value :: '\'' :: tail => do
      -- The fixed compiler fragment has no '(' character literal or qualified
      -- character expression. Reject their shared prefix rather than guessing
      -- whether an apostrophe belongs to a literal or a qualification.
      if value == '\n' || value == '\r' || value == '(' then none else pure ()
      let tokens ← lexer fuel tail
      pure (String.ofList ['\'', value, '\''] :: tokens)
    | _ =>
      if identifierChar c then
        let (word, rest) := readWord chars
        do
          let tokens ← lexer fuel rest
          pure (String.ofList (word.map Char.toLower) :: tokens)
      else match cs with
      | d :: rest =>
        if (c == ':' && d == '=') || (c == '=' && d == '>') ||
           (c == '<' && d == '=') || (c == '>' && d == '=') ||
           (c == '/' && d == '=') || (c == '.' && d == '.') then do
          let tokens ← lexer fuel rest
          pure (String.ofList [c, d] :: tokens)
        else do
          let tokens ← lexer fuel cs
          pure (String.singleton c :: tokens)
      | [] => some [String.singleton c]

def lexLine (source : String) : Option Tokens :=
  if compilerSource source then lexer (source.toList.length + 1) source.toList else none

theorem lexLine_supported {source : String} {tokens : Tokens}
    (checked : lexLine source = some tokens) : compilerSource source = true := by
  unfold lexLine at checked
  split at checked
  · assumption
  · contradiction

/-- Regression: Ada treats these bytes as line endings, so they must never be
silently consumed inside a compiler-source comment by the restricted reader. -/
theorem hidden_declaration_rejected :
    lexLine "-- hidden\u000bfunction \"=\" (L, R : Character) return Boolean is (True);" = none ∧
    lexLine "-- hidden\u000cfunction \"=\" (L, R : Character) return Boolean is (True);" = none ∧
    lexLine "-- hidden\u0085function Hidden return Boolean is (True);" = none ∧
    lexLine "-- hidden\u2028function Hidden return Boolean is (True);" = none := by decide +kernel

/-- Alternate string delimiters and the ambiguous qualified-character prefix
are outside this compiler fragment, even though their bytes are ASCII. -/
theorem unsupported_literal_syntax_rejected :
    lexLine "S : String := %--%; function Hidden return Boolean is (True);" = none ∧
    lexLine "C : Character := Character'('\"'); function Hidden return Boolean is (True);" = none := by decide +kernel

def lexLines : List String → Option Tokens
  | [] => some []
  | line :: lines => do
      let head ← lexLine line
      let tail ← lexLines lines
      pure (head ++ tail)

def lex (source : String) : Option Tokens :=
  lexLines ((source.split '\n').toList.map (·.copy))

structure LineCertificate where
  text : String
  tokens : Tokens
  correct : lexLine text = some tokens
  noNewline : '\n' ∉ text.toList

theorem certified_lines_lex (lines : List LineCertificate) :
    lexLines (lines.map (·.text)) = some (lines.flatMap (·.tokens)) := by
  induction lines with
  | nil => rfl
  | cons line lines ih => simp [lexLines, line.correct, ih]

theorem certified_lines_no_newline (lines : List LineCertificate) :
    ∀ text ∈ lines.map (·.text), '\n' ∉ text.toList := by
  intro text h
  obtain ⟨line, _, rfl⟩ := List.mem_map.mp h
  exact line.noNewline

theorem compilerSource_append (left right : String) :
    compilerSource (left ++ right) = (compilerSource left && compilerSource right) := by
  simp [compilerSource, String.toList_append]

/-- Compose the checked alphabet without reducing the entire file's UTF-8
representation in one kernel evaluation. Each leaf has already been checked. -/
theorem certified_source_supported (lines : List LineCertificate) :
    compilerSource (String.intercalate "\n" (lines.map (·.text))) = true := by
  induction lines with
  | nil => rfl
  | cons line lines ih =>
    cases lines with
    | nil => simpa using lexLine_supported line.correct
    | cons next rest =>
      simp only [List.map_cons] at ih
      simp only [List.map_cons, String.intercalate_cons_cons, compilerSource_append]
      rw [lexLine_supported line.correct, ih]
      rfl

theorem reconstructed_source_lex (lines : List LineCertificate) (hne : lines ≠ []) :
    lex (String.intercalate "\n" (lines.map (·.text))) =
      some (lines.flatMap (·.tokens)) := by
  unfold lex
  rw [show "\n" = String.singleton '\n' by decide +kernel]
  rw [String.toList_split_intercalate (certified_lines_no_newline lines)]
  have hm : lines.map (·.text) ≠ [] := by simpa using hne
  rw [ite_eq_right hm]
  exact certified_lines_lex lines

/-- A nonempty block of certified physical lines and its exact source text. -/
structure ReconstructionCertificate where
  lines : List LineCertificate
  text : String
  nonempty : lines ≠ []
  correct : String.intercalate "\n" (lines.map (·.text)) = text

/-- Character-list equality avoids reducing repeated byte-array copies when
checking large literal string joins in the kernel. -/
theorem string_join_ofList (left right : List Char) :
    String.ofList left ++ "\n" ++ String.ofList right =
      String.ofList (left ++ ['\n'] ++ right) := by
  simp only [String.ofList_append]

def ReconstructionCertificate.single (line : LineCertificate) : ReconstructionCertificate where
  lines := [line]
  text := line.text
  nonempty := by intro h; cases h
  correct := String.intercalate_singleton

/-- Compose blocks using only a checked equality between their literal texts.
Balanced compositions avoid reducing a quadratic chain of growing strings. -/
def ReconstructionCertificate.join (left right : ReconstructionCertificate)
    (text : String) (joined : left.text ++ "\n" ++ right.text = text) :
    ReconstructionCertificate where
  lines := left.lines ++ right.lines
  text := text
  nonempty := by
    intro h
    exact left.nonempty (List.append_eq_nil_iff.mp h).1
  correct := by
    rw [List.map_append, String.intercalate_append_of_ne_nil
      (by simpa using left.nonempty) (by simpa using right.nonempty),
      left.correct, right.correct, joined]

/-- Consume one balanced parenthesized expression, excluding its outer parentheses. -/
def balanced : Nat → Tokens → Option (Tokens × Tokens)
  | _, [] => none
  | depth, token :: tokens =>
    if token == ")" && depth == 1 then some ([], tokens)
    else do
      let next := if token == "(" then depth + 1 else if token == ")" then depth - 1 else depth
      let (inside, rest) ← balanced next tokens
      pure (token :: inside, rest)

def expressionBodies (name : String) : Tokens → List Tokens
  | [] => []
  | "function" :: actual :: tokens =>
    let later := expressionBodies name (actual :: tokens)
    if actual == name then
      match tokens.dropWhile (· != "return") with
      | "return" :: _resultType :: "is" :: "(" :: expr =>
        match balanced 1 expr with
        | some (body, ";" :: _) => body :: later
        | _ => later
      | _ => later
    else later
  | _ :: tokens => expressionBodies name tokens

def expressionBody (name : String) (tokens : Tokens) : Option Tokens :=
  match expressionBodies name tokens with
  | [body] => some body
  | _ => none

/-- Read a declaration through its outer semicolon, respecting parameter groups. -/
def declarationEnd : Nat → Tokens → Option Tokens
  | _, [] => none
  | depth, token :: tokens =>
    if token == ";" && depth == 0 then some []
    else do
      let next := if token == "(" then depth + 1 else if token == ")" then depth - 1 else depth
      let rest ← declarationEnd next tokens
      pure (token :: rest)

def declarations (name : String) : Tokens → List Tokens
  | [] => []
  | actual :: ":" :: tokens =>
    let later := declarations name (":" :: tokens)
    if actual == name then
      match declarationEnd 0 tokens with
      | some value => value :: later
      | none => later
    else later
  | _ :: tokens => declarations name tokens

def declaration (name : String) (tokens : Tokens) : Option Tokens :=
  match declarations name tokens with
  | [value] => some value
  | _ => none

end Silver.Source
