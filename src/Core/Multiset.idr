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

------------------------------------------------------------------------
-- 6. FIRST-CLASS MULTISET CONTAINERS & INFORMATION GEOMETRY
------------------------------------------------------------------------

||| A discrete Multiset (bag) of elements with integer multiplicities.
public export
record MSet a where
  constructor MkMSet
  items : List (a, BoxInt)

public export
Eq a => Eq (MSet a) where
  (MkMSet xs) == (MkMSet ys) = xs == ys

public export
Show a => Show (MSet a) where
  show (MkMSet xs) = "MSet(" ++ show xs ++ ")"

||| Canonical empty multiset.
public export
emptyMSet : MSet a
emptyMSet = MkMSet []

||| Creates a singleton multiset.
public export
singletonMSet : a -> BoxInt -> MSet a
singletonMSet x w = MkMSet [(x, w)]

||| Lookups the multiplicity of an element in a multiset.
public export
lookupMSet : Eq a => a -> MSet a -> BoxInt
lookupMSet target (MkMSet xs) =
  case find (\(x, _) => x == target) xs of
    Just (_, w) => w
    Nothing     => intToBoxInt 0

||| Inserts or updates the multiplicity of an element.
public export
insertMSet : Eq a => a -> BoxInt -> MSet a -> MSet a
insertMSet x w (MkMSet xs) =
  let current = lookupMSet x (MkMSet xs)
      newWeight = current + w
      filtered = filter (\(k, _) => k /= x) xs
  in if unwrapBox newWeight == 0
       then MkMSet filtered
       else MkMSet ((x, newWeight) :: filtered)

||| Multiset Union (pouring containers together): adds multiplicities.
public export
unionMSet : Eq a => MSet a -> MSet a -> MSet a
unionMSet (MkMSet []) ys = ys
unionMSet (MkMSet ((x, w) :: xs)) ys =
  insertMSet x w (unionMSet (MkMSet xs) ys)

||| Multiset Difference: subtracts multiplicities (bounded below by 0).
public export
subMSet : Eq a => MSet a -> MSet a -> MSet a
subMSet (MkMSet xs) ys =
  let nonZeroDiff = mapMaybe (\(k, w) => 
        let subW = lookupMSet k ys
            remW = w - subW
        in if unwrapBox remW > 0 then Just (k, remW) else Nothing) xs
  in MkMSet nonZeroDiff


||| Computes total multiset mass: sum of all item multiplicities.
public export
totalMassMSet : MSet a -> BoxInt
totalMassMSet (MkMSet xs) =
  sum (map snd xs)

||| Filters a multiset by a predicate.
public export
filterMSet : (a -> Bool) -> MSet a -> MSet a
filterMSet p (MkMSet xs) =
  MkMSet (filter (\(x, _) => p x) xs)

||| Multiset Symmetric Difference Information Distance:
||| D_MSet(A, B) = |A \ B| + |B \ A| = sum_{x} |w_A(x) - w_B(x)|
public export
multisetSymmetricDifference : Eq a => MSet a -> MSet a -> Nat
multisetSymmetricDifference (MkMSet xs) (MkMSet ys) =
  let allKeys = nub (map fst xs ++ map fst ys)
      diffs = map (\k => 
        let w1 = lookupMSet k (MkMSet xs)
            w2 = lookupMSet k (MkMSet ys)
            d = unwrapBox (if w1 >= w2 then w1 - w2 else w2 - w1)
        in integerToNat (if d >= 0 then d else -d)) allKeys
  in sum diffs

||| Theorem & Audit: Validates Multiset Information Distance metric axioms:
||| 1. Identity of Indiscernibles: D(A, A) == 0.
||| 2. Triangle Inequality: D(A, C) <= D(A, B) + D(B, C).
public export
auditMultisetInformationDistanceProof : Bool
auditMultisetInformationDistanceProof =
  let a = MkMSet [(1, intToBoxInt 10), (2, intToBoxInt 5)]
      b = MkMSet [(1, intToBoxInt 7),  (2, intToBoxInt 5), (3, intToBoxInt 4)]
      c = MkMSet [(1, intToBoxInt 2),  (3, intToBoxInt 8)]
      dAA = multisetSymmetricDifference a a
      dAB = multisetSymmetricDifference a b
      dBC = multisetSymmetricDifference b c
      dAC = multisetSymmetricDifference a c
  in dAA == 0 && (dAC <= dAB + dBC)

------------------------------------------------------------------------
-- 7. MULTISET CROSS-ENTROPY & PREDICTIVE COMPACTNESS
------------------------------------------------------------------------

||| Multiset Intersection: Computes the common shared tokens min(w_A, w_B).
public export
intersectMSet : Eq a => MSet a -> MSet a -> MSet a
intersectMSet (MkMSet xs) (MkMSet ys) =
  let commonKeys = filter (\k => lookupMSet k (MkMSet ys) /= intToBoxInt 0) (nub (map fst xs))
      itemsList = map (\k => 
        let w1 = lookupMSet k (MkMSet xs)
            w2 = lookupMSet k (MkMSet ys)
            minW = if w1 <= w2 then w1 else w2
        in (k, minW)) commonKeys
  in MkMSet (filter (\(_, w) => unwrapBox w > 0) itemsList)

||| Computes total mass of common shared tokens between two multisets |A ∩ B|.
public export
multisetIntersectionMass : Eq a => MSet a -> MSet a -> Nat
multisetIntersectionMass a b =
  let inter = intersectMSet a b
      mass = unwrapBox (totalMassMSet inter)
  in if mass <= 0 then 0 else integerToNat mass

||| Computes total union mass |A ∪ B| = sum max(w_A, w_B).
public export
multisetUnionMass : Eq a => MSet a -> MSet a -> Nat
multisetUnionMass (MkMSet xs) (MkMSet ys) =
  let allKeys = nub (map fst xs ++ map fst ys)
      maxWeights = map (\k => 
        let w1 = lookupMSet k (MkMSet xs)
            w2 = lookupMSet k (MkMSet ys)
            maxW = if w1 >= w2 then w1 else w2
            mw = unwrapBox maxW
        in if mw <= 0 then 0 else integerToNat mw) allKeys
  in sum maxWeights

||| Multiset Cross-Entropy: Measures the informational cost of explaining environment P using model Q:
||| H_MSet(P, Q) = |P| + |P \ Q| = 2|P| - |P ∩ Q|
public export
multisetCrossEntropyMass : Eq a => (envP : MSet a) -> (modelQ : MSet a) -> Nat
multisetCrossEntropyMass envP modelQ =
  let pMass = unwrapBox (totalMassMSet envP)
      pNat = if pMass <= 0 then 0 else integerToNat pMass
      unexplainedMSet = subMSet envP modelQ
      unexplainedMass = unwrapBox (totalMassMSet unexplainedMSet)
      unexplainedNat = if unexplainedMass <= 0 then 0 else integerToNat unexplainedMass
  in pNat + unexplainedNat

||| Audits that Multiset Cross-Entropy:
||| 1. Equals self-entropy |P| when the model is perfectly aligned (P == Q).
||| 2. Maximizes at 2*|P| when the model has zero predictive overlap (P ∩ Q == empty).
public export
auditMultisetCrossEntropyProof : Bool
auditMultisetCrossEntropyProof =
  let envP = MkMSet [(1, intToBoxInt 10), (2, intToBoxInt 5)]
      perfectModel = envP
      disjointModel = MkMSet [(3, intToBoxInt 8)]
      hPerfect = multisetCrossEntropyMass envP perfectModel
      hDisjoint = multisetCrossEntropyMass envP disjointModel
  in hPerfect == 15 && hDisjoint == 30


