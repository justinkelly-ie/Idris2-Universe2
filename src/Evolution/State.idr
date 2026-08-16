module Evolution.State

import Core.BoxInt
import Core.VexelMaxel
import Data.Vect

%default total

||| The completely un-hardcoded cosmic partition state.
||| Dimensions are tracked relationally through dependent parameters.
||| All data slots store exact BoxInt discrete particle/quadrance tokens.
public export
record UniverseState (vmSize : Nat) (deSize : Nat) (dmSize : Nat) where
  constructor MkUniverseState
  visibleMatter : Vect vmSize BoxInt -- Active spatial field lattice
  darkEnergy    : Vect deSize BoxInt -- Background ROM capacity
  darkMatter    : Vect dmSize BoxInt -- Historical error/residue ledger

||| Extracts the Dark Matter log as a read-only reference.
public export
dmLog : UniverseState vm de dm -> Vect dm BoxInt
dmLog (MkUniverseState _ _ dmData) = dmData

||| Calculates total active state energy across all memory pools.
public export
totalStateCapacity : {vm, de, dm : Nat} -> UniverseState vm de dm -> Nat
totalStateCapacity {vm} {de} {dm} _ = vm + de + dm

------------------------------------------------------------------------
-- UNIFIED COSMIC DIRECT-SUM MULTISET
------------------------------------------------------------------------

||| The Unified Cosmic Multiset:
||| Encodes Visible Matter as a 3D Boxel (27 cells), Dark Energy as a 2D Maxel (128 cells),
||| and Dark Matter as an inductive 1D Vexel of historical singletons.
public export
record CosmicMultiset where
  constructor MkCosmicMultiset
  visible    : Boxel
  darkEnergy : Maxel
  darkMatter : Vexel

||| Calculates total active state energy across the cosmic multiset.
public export
totalCosmicMultisetBudget : CosmicMultiset -> Nat
totalCosmicMultisetBudget (MkCosmicMultiset (MkBoxel v) (MkMaxel de) (MkVexel dm)) =
  length v + length de + length dm

||| Embeds a dependent UniverseState into the Unified Cosmic Multiset.
public export
stateToCosmicMultiset : {vm, de, dm : Nat} -> UniverseState vm de dm -> CosmicMultiset
stateToCosmicMultiset (MkUniverseState vmVect deVect dmVect) =
  let vmBoxel = MkBoxel (zipWith (\idx, val => (MkVoxel idx 1 1, val)) [1..vm] (toList vmVect))
      deMaxel = MkMaxel (zipWith (\idx, val => (MkPixel idx 1, val)) [1..de] (toList deVect))
      dmVexel = MkVexel (zipWith (\idx, val => (MkSingleton idx, val)) [1..dm] (toList dmVect))
  in MkCosmicMultiset (canonicalizeBoxel vmBoxel) (canonicalizeMaxel deMaxel) (canonicalizeVexel dmVexel)

||| Audits that Epoch 37 CosmicMultiset has total budget 210 = 27 + 128 + 55.
public export
auditCosmicMultisetBudgetProof : Bool
auditCosmicMultisetBudgetProof =
  let mockState = MkUniverseState {vmSize=27} {deSize=128} {dmSize=55}
                    (replicate 27 (intToBoxInt 1))
                    (replicate 128 (intToBoxInt 1))
                    (replicate 55 (intToBoxInt 1))
      cMultiset = stateToCosmicMultiset mockState
  in totalCosmicMultisetBudget cMultiset == 210
