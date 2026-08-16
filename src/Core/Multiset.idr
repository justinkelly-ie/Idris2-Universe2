module Core.Multiset

import Core.BoxInt
import Data.Vect
import Decidable.Equality
import Language.Reflection

%default total

||| Tracks runtime erasure (0) while ensuring type safety for multiset indices.
public export
data Multiplicity : Type where
  Count : (val : Nat) -> (qty : Nat) -> Multiplicity

public export
Eq Multiplicity where
  (Count v1 q1) == (Count v2 q2) = v1 == v2 && q1 == q2

public export
Show Multiplicity where
  show (Count v q) = "(" ++ show v ++ " : " ++ show q ++ ")"

------------------------------------------------------------------------
-- 1. BOX MULTISET SPECIFICATION (Containers of Containers)
------------------------------------------------------------------------

||| Core Type-Level Specification for inductive nested boxes.
||| - Leaf: An empty box [] (Base zero token).
||| - Node xs: A parent box containing a collection of child boxes [x1, x2, ...].
public export
data MSetSpec : Type where
  Leaf : MSetSpec
  Node : {n : Nat} -> Vect n MSetSpec -> MSetSpec

mutual
  public export
  eqMSetSpec : MSetSpec -> MSetSpec -> Bool
  eqMSetSpec Leaf Leaf = True
  eqMSetSpec (Node {n=n1} xs) (Node {n=n2} ys) =
    case decEq n1 n2 of
      Yes Refl => eqSpecVect xs ys
      No _     => False
  eqMSetSpec _ _ = False

  public export
  eqSpecVect : {n : Nat} -> Vect n MSetSpec -> Vect n MSetSpec -> Bool
  eqSpecVect [] [] = True
  eqSpecVect (x :: xs) (y :: ys) = eqMSetSpec x y && eqSpecVect xs ys

public export
Eq MSetSpec where
  (==) = eqMSetSpec

------------------------------------------------------------------------
-- 2. DERIVING NATURAL NUMBERS FROM MULTISETS OF EMPTY BOXES
--    [] = 0, [[]] = 1, [[] []] = 2, [[] [] []] = 3, ...
------------------------------------------------------------------------

||| Generates the exact MSetSpec for any natural number n.
||| 0 = Leaf ([])
||| 1 = Node [Leaf] ([[]])
||| 2 = Node [Leaf, Leaf] ([[] []])
||| 3 = Node [Leaf, Leaf, Leaf] ([[] [] []])
public export
fromNatSpec : (n : Nat) -> MSetSpec
fromNatSpec Z     = Leaf
fromNatSpec (S k) = Node (replicate (S k) Leaf)

||| The physical, linear QTT structural type representing a Multiset / Polynumber.
||| The '1' annotations ensure full data conservation across nested operations.
public export
data Polynumber : (0 spec : MSetSpec) -> Type where
  Zero : Polynumber Leaf
  Nest : (1 elements : Vect n (Polynumber childSpec)) -> 
         Polynumber (Node (replicate n childSpec))

||| Wildberger Natural numbers defined as multisets of empty boxes.
||| - WZero = Leaf ([]) = 0
||| - WNil  = Node []
||| - WSucc WZero WNil = Node [Leaf] ([[]]) = 1
||| - WSucc WZero (WSucc WZero WNil) = Node [Leaf, Leaf] ([[] []]) = 2
public export
data WildNat : (0 spec : MSetSpec) -> Type where
  WZero : WildNat Leaf
  WNil  : WildNat (Node [])
  WSucc : {0 xs : Vect n MSetSpec} -> 
          (1 zeroElement : WildNat Leaf) -> 
          (1 rest : WildNat (Node xs)) -> 
          WildNat (Node (Leaf :: xs))

||| Tallies the physical count of empty box tokens inside a WildNat.
public export
tallyWildNat : {0 spec : MSetSpec} -> WildNat spec -> Nat
tallyWildNat WZero = 0
tallyWildNat WNil  = 0
tallyWildNat (WSucc zeroElement rest) = 1 + tallyWildNat rest

||| Constructs a WildNat directly from a standard Nat count as nested empty boxes.
public export
toWildNat : (n : Nat) -> WildNat (fromNatSpec n)
toWildNat Z = WZero
toWildNat (S k) = toWildNatSucc k
  where
    toWildNatSucc : (m : Nat) -> WildNat (Node (replicate (S m) Leaf))
    toWildNatSucc Z = WSucc WZero WNil
    toWildNatSucc (S j) = WSucc WZero (toWildNatSucc j)

||| Direct, constructive conversion from a WildNat multiset to a BoxInt scalar.
||| Zero casts, zero continuous approximations.
public export
wildNatToBoxInt : {0 spec : MSetSpec} -> WildNat spec -> BoxInt
wildNatToBoxInt w = natToBoxInt (tallyWildNat w)

------------------------------------------------------------------------
-- 3. BOX MULTISET COMBINATORS (Pouring & Combining Containers)
------------------------------------------------------------------------

||| Wildberger Addition Spec: Simple vector concatenation.
public export
appendSpec : Vect n Multiplicity -> Vect m Multiplicity -> Vect (n + m) Multiplicity
appendSpec [] ys = ys
appendSpec (x :: xs) ys = x :: appendSpec xs ys

||| Recursive Type-Level Specification Merger for MSetSpec.
public export
addMSetSpec : MSetSpec -> MSetSpec -> MSetSpec
addMSetSpec Leaf Leaf = Leaf
addMSetSpec Leaf (Node ys) = Node ys
addMSetSpec (Node xs) Leaf = Node xs
addMSetSpec (Node xs) (Node ys) = Node (xs ++ ys)

||| Type-Level Multiset Multiplication Spec (Cartesian combination of values).
public export
multSpec : Vect n Multiplicity -> Vect m Multiplicity -> Vect (n * m) Multiplicity
multSpec [] ys = []
multSpec (Count v1 q1 :: xs) ys = 
  appendSpec (map (\(Count v2 q2) => Count (v1 + v2) (q1 * q2)) ys) (multSpec xs ys)

||| Swaps two adjacent elements in the type specification.
public export
swapAdjacentSpec : Vect (2 + n) Multiplicity -> Vect (2 + n) Multiplicity
swapAdjacentSpec (a :: b :: rest) = b :: a :: rest

------------------------------------------------------------------------
-- 4. ELABORATOR REFLECTION MACROS
------------------------------------------------------------------------

||| Generates the WildNat AST for any Natural number n.
public export
genWildNat : Nat -> TTImp
genWildNat Z = IVar emptyFC (UN $ Basic "WZero")
genWildNat (S k) = genWildNatSucc k
  where
    genWildNatSucc : Nat -> TTImp
    genWildNatSucc Z = 
      let zeroVar = IVar emptyFC (UN $ Basic "WZero")
          nilVar  = IVar emptyFC (UN $ Basic "WNil")
          succVar = IVar emptyFC (UN $ Basic "WSucc")
      in IApp emptyFC (IApp emptyFC succVar zeroVar) nilVar
    genWildNatSucc (S j) =
      let zeroVar = IVar emptyFC (UN $ Basic "WZero")
          succVar = IVar emptyFC (UN $ Basic "WSucc")
      in IApp emptyFC (IApp emptyFC succVar zeroVar) (genWildNatSucc j)

||| Compile-time macro to generate the WildNat AST for any Natural number n.
export
%macro
makeWildNat : Nat -> Elab TTImp
makeWildNat n = pure (genWildNat n)

------------------------------------------------------------------------
-- 5. INTEGER PARTITIONS & YOUNG DIAGRAMS AS MULTISETS
------------------------------------------------------------------------

||| An Integer Partition lambda |- n represented canonically as a Multiset of part sizes:
||| lambda = { p1^m1, p2^m2, ..., pk^mk } where sum (pi * mi) = n.
public export
record IntegerPartition where
  constructor MkPartition
  parts : List Multiplicity

public export
Eq IntegerPartition where
  (MkPartition p1) == (MkPartition p2) = p1 == p2

public export
Show IntegerPartition where
  show (MkPartition p) = "Partition" ++ show p

||| Evaluates the total partition weight sum: sum (part_size * multiplicity).
public export
partitionSum : IntegerPartition -> Nat
partitionSum (MkPartition ps) =
  sum (map (\(Count size mult) => size * mult) ps)

||| Validates if a partition is a valid partition of a target natural number n.
public export
isPartitionOf : IntegerPartition -> Nat -> Bool
isPartitionOf part target =
  partitionSum part == target

||| Canonical 4th Primorial cosmic partition: { 128^1, 55^1, 27^1 } |- 210.
public export
cosmicPartition210 : IntegerPartition
cosmicPartition210 =
  MkPartition [ Count 128 1  -- Dark Energy ROM
              , Count 55 1   -- Dark Matter Residue
              , Count 27 1   -- Visible Spacetime Metric Basis
              ]

||| Proves that the cosmic partition multiset sums exactly to 210 = 2*3*5*7.
public export
auditCosmicPartition210Proof : Bool
auditCosmicPartition210Proof =
  isPartitionOf cosmicPartition210 210
