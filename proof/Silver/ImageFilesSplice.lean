module

public import Silver.ImageFileSplice

@[expose] public section
namespace Silver.ImageModel.FilesSplice

inductive Fragment | declarations | includes deriving DecidableEq
inductive Sequence | original | refined deriving DecidableEq

structure Inputs where
  original : List Nat
  refined : List Nat
  declarations : List Nat
  includes : List Nat
  count : Nat
  declarationsOffset : Nat
  includesOffset : Nat
  iterator : Nat := 0

def Fragment.bytes (input : Inputs) : Fragment → List Nat
  | .declarations => input.declarations
  | .includes => input.includes

def Fragment.offset (input : Inputs) : Fragment → Nat
  | .declarations => input.declarationsOffset
  | .includes => input.includesOffset

def Fragment.name : Fragment → String
  | .declarations => "declarations"
  | .includes => "includes"

def Fragment.render (fragment : Fragment) : List String := ["model", ".", fragment.name ++ "_insertion"]
def Fragment.renderOffset (fragment : Fragment) : List String := ["plan", ".", fragment.name ++ "_offset"]
def Fragment.renderLength (fragment : Fragment) : List String :=
  ["model", ".", "insertion_length", "("] ++ fragment.render ++ [")"]

def Sequence.bytes (input : Inputs) : Sequence → List Nat
  | .original => input.original
  | .refined => input.refined

def Sequence.name : Sequence → String
  | .original => "original"
  | .refined => "refined"

inductive Number
  | count | iterator | zero | offset (fragment : Fragment)
  | length (sequence : Sequence) | fragmentLength (fragment : Fragment)
  | big (value : Number) | countBig (value : Number)
  | add (left right : Number)
  | inserted (position : Number) (fragment : Fragment)
  deriving DecidableEq

def Number.eval (input : Inputs) : Number → Nat
  | .count => input.count
  | .iterator => input.iterator
  | .zero => 0
  | .offset fragment => fragment.offset input
  | .length sequence => (sequence.bytes input).length
  | .fragmentLength fragment => (fragment.bytes input).length
  | .big value | .countBig value => value.eval input
  | .add left right => left.eval input + right.eval input
  | .inserted position fragment => if position.eval input > fragment.offset input then (fragment.bytes input).length else 0

def Number.render : Number → List String
  | .count => ["count"]
  | .iterator => ["i"]
  | .zero => ["0"]
  | .offset fragment => fragment.renderOffset
  | .length sequence => ["bytes", ".", "length", "(", sequence.name, ")"]
  | .fragmentLength fragment => fragment.renderLength
  | .big value => ["to_big_integer", "("] ++ value.render ++ [")"]
  | .countBig value => ["counts", ".", "to_big_integer", "("] ++ value.render ++ [")"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .inserted position fragment => ["(", "if"] ++ position.render ++ [">"] ++ fragment.renderOffset ++
      ["then", "to_big_integer", "("] ++ fragment.renderLength ++ [")", "else", "0", ")"]

inductive Byte
  | get (sequence : Sequence) (index : Number)
  | fragment (fragment : Fragment) (index : Number)
  deriving DecidableEq

def Byte.eval (input : Inputs) : Byte → Option Nat
  | .get sequence index => (sequence.bytes input)[index.eval input - 1]?
  | .fragment kind index => (kind.bytes input)[index.eval input - 1]?

def Byte.render : Byte → List String
  | .get sequence index => ["bytes", ".", "get", "(", sequence.name, ","] ++ index.render ++ [")"]
  | .fragment kind index => ["model", ".", "insertion_byte", "("] ++ kind.render ++ [","] ++ index.render ++ [")"]

inductive Predicate
  | numberEqual (left right : Number) | byteEqual (left right : Byte)
  | andThen (left right : Predicate) | group (value : Predicate)
  | ifCopied (fragment : Fragment) (value : Predicate)
  | allOriginal (value : Predicate) | allInserted (fragment : Fragment) (value : Predicate)
  deriving DecidableEq

def Predicate.eval (input : Inputs) : Predicate → Prop
  | .numberEqual left right => left.eval input = right.eval input
  | .byteEqual left right => left.eval input = right.eval input
  | .andThen left right => left.eval input ∧ right.eval input
  | .group value => value.eval input
  | .ifCopied fragment value => input.count > fragment.offset input → value.eval input
  | .allOriginal value => ∀ i, 1 ≤ i → i ≤ input.count → value.eval {input with iterator := i}
  | .allInserted fragment value => ∀ i, 1 ≤ i → i ≤ (fragment.bytes input).length → value.eval {input with iterator := i}

def Predicate.render : Predicate → List String
  | .numberEqual left right => left.render ++ ["="] ++ right.render
  | .byteEqual left right => left.render ++ ["="] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .ifCopied fragment value => ["if", "count", ">"] ++ fragment.renderOffset ++ ["then"] ++ value.render
  | .allOriginal value => ["for", "all", "i", "in", "model", ".", "byte_count", "range", "1", "..", "count", "=>"] ++ value.render
  | .allInserted fragment value => ["for", "all", "i", "in", "1", ".."] ++ fragment.renderLength ++ ["=>"] ++ value.render

def shifted (position : Number) : Number :=
  .add (.add (.countBig position) (.inserted position .declarations)) (.inserted position .includes)

/-- Typed interpretation of the native one-based, independently quantified
Spliced_Prefix expression. It does not use the abstract splice operation. -/
def expression : Predicate := .group <|
  .andThen (.numberEqual (.length .original) (.countBig .count)) <|
  .andThen (.numberEqual (.length .refined) (shifted .count)) <|
  .andThen (.group (.allOriginal (.byteEqual (.get .refined (shifted .iterator)) (.get .original (.countBig .iterator))))) <|
  .andThen (.group (.ifCopied .declarations (.group (.allInserted .declarations
    (.byteEqual (.get .refined (.add (.countBig (.offset .declarations)) (.big .iterator)))
      (.fragment .declarations .iterator))))))
  (.group (.ifCopied .includes (.group (.allInserted .includes
    (.byteEqual (.get .refined (.add (.add (.countBig (.offset .includes)) (.big (.fragmentLength .declarations))) (.big .iterator)))
      (.fragment .includes .iterator))))))

theorem observations (input : Inputs)
    (first : input.declarationsOffset < input.count) (second : input.includesOffset < input.count)
    (native : expression.eval input) :
    SpliceObservations input.original input.refined input.declarations input.includes
      input.declarationsOffset input.includesOffset := by
  simp only [expression, shifted, Predicate.eval, Number.eval, Byte.eval, Sequence.bytes,
    Fragment.bytes, Fragment.offset, first, second, ↓reduceIte, true_implies] at native
  rcases native with ⟨originalLength, outputLength, originalRead, declarations, includes⟩
  constructor
  · omega
  · intro i bound
    have h := originalRead (i+1) (by omega) (by omega)
    have a : (i+1 > input.declarationsOffset) = (input.declarationsOffset ≤ i) := propext (by omega)
    have b : (i+1 > input.includesOffset) = (input.includesOffset ≤ i) := propext (by omega)
    simp only [a, b] at h
    simpa only [show i+1+(if input.declarationsOffset ≤ i then input.declarations.length else 0)+(if input.includesOffset ≤ i then input.includes.length else 0)-1 =
      i+(if input.declarationsOffset ≤ i then input.declarations.length else 0)+(if input.includesOffset ≤ i then input.includes.length else 0) by omega,
      Nat.add_sub_cancel] using h
  · intro i bound
    simpa only [show input.declarationsOffset+(i+1)-1=input.declarationsOffset+i by omega,
      Nat.add_sub_cancel] using declarations (i+1) (by omega) (by omega)
  · intro i bound
    simpa only [show input.includesOffset+input.declarations.length+(i+1)-1=input.includesOffset+input.declarations.length+i by omega,
      Nat.add_sub_cancel] using includes (i+1) (by omega) (by omega)

theorem exact_splice (input : Inputs) (ordered : input.declarationsOffset < input.includesOffset)
    (bounded : input.includesOffset < input.count) (native : expression.eval input) :
    input.refined = splice input.original input.declarations input.includes input.declarationsOffset input.includesOffset := by
  have length : input.original.length = input.count := native.1
  exact observations_splice _ _ _ _ _ _ (by omega) (by omega)
    (observations input (by omega) bounded native)

end Silver.ImageModel.FilesSplice
