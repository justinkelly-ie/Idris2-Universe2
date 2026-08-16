module Evolution.StructuralAccounting

import Core.BoxInt
import Core.VexelMaxel
import Evolution.State
import Math.DiscreteLandauerPrinciple
import Data.Vect

%default total

||| Structural summation of BoxInt vectors.
||| Accumulates memory units purely through inductive box container algebra (+),
||| with zero reliance on backend primitive integer casts.
public export
sumStructural : {n : Nat} -> Vect n BoxInt -> BoxInt
sumStructural []        = intToBoxInt 0
sumStructural (x :: xs) = x + sumStructural xs

||| Pure structural summation of standard integer vectors directly into BoxInt algebra.
public export
sumStructuralInt : {n : Nat} -> Vect n Int -> BoxInt
sumStructuralInt []        = intToBoxInt 0
sumStructuralInt (x :: xs) = (intToBoxInt (cast x)) + sumStructuralInt xs

||| Pure structural counting of a vector's length directly into a BoxInt container:
||| Each element adds exactly one physical unit box (intToBoxInt 1).
public export
countStructural : {n : Nat} -> {0 a : Type} -> Vect n a -> BoxInt
countStructural []        = intToBoxInt 0
countStructural (x :: xs) = (intToBoxInt 1) + countStructural xs

||| Evaluates associative grouping across a 3-way vector split during scale transitions:
||| (A + B) + C == A + (B + C)
public export
verifyAssociativeTransition : (a : BoxInt) -> (b : BoxInt) -> (c : BoxInt) -> Bool
verifyAssociativeTransition a b c =
  ((a + b) + c) == (a + (b + c))

------------------------------------------------------------------------
-- CONSTRUCTIVIST LANDAUER'S PRINCIPLE (QTT TOKEN RELOCATION)
------------------------------------------------------------------------

||| Erases an active Visible Matter Singleton token from a quantum state Vexel
||| and relocates its informational weight into the Dark Matter history ledger (dm -> S dm).
||| Provably conserves total cosmic tokens: active tokens + dm == remaining tokens + (S dm).
public export
landauerTokenErasure : {vm, de, dm : Nat} ->
                       (target : Singleton) ->
                       (active : Vexel) ->
                       (UniverseState (S vm) de dm) ->
                       (Vexel, UniverseState vm de (S dm))
landauerTokenErasure target (MkVexel terms) (MkUniverseState (_ :: vmRest) deVect dmVect) =
  let erasedWeight = lookupSingleton target (MkVexel terms)
      tokenToRelocate = if unwrapBox erasedWeight == 0 then intToBoxInt 1 else erasedWeight
      remainingTerms = filter (\(s, _) => s /= target) terms
      remainingVexel = MkVexel remainingTerms
      newState = MkUniverseState vmRest deVect (tokenToRelocate :: dmVect)
  in (remainingVexel, newState)

||| Audits Constructivist Landauer's Principle:
||| Erasing token [1] from active Vexel (mass 10) in UniverseState 27 128 55
||| yields remaining Vexel (mass 7) in UniverseState 26 128 56 with preserved capacity 210.
public export
auditLandauerTokenConservationProof : Bool
auditLandauerTokenConservationProof =
  let activeVexel = MkVexel [(MkSingleton 1, intToBoxInt 3), (MkSingleton 2, intToBoxInt 7)]
      initialState = MkUniverseState {vmSize=27} {deSize=128} {dmSize=55}
                       (replicate 27 (intToBoxInt 1))
                       (replicate 128 (intToBoxInt 1))
                       (replicate 55 (intToBoxInt 1))
      (remVexel, finalState) = landauerTokenErasure (MkSingleton 1) activeVexel initialState
      remMass = totalVexelMass remVexel
      capInitial = totalStateCapacity initialState
      capFinal = totalStateCapacity finalState
  in capInitial == 210 &&
     capFinal == 210 &&
     remMass == intToBoxInt 7


