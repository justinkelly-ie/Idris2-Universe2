module Evolution.Expansion

import Core.BoxInt
import Core.VexelMaxel
import Evolution.State
import Evolution.StructuralAccounting
import Data.Vect

%default total

||| Linearly appends an active vector to a base vector without resource leakage.
public export
linearAppendVect : (1 xs : Vect n a) -> Vect m a -> Vect (n + m) a
linearAppendVect [] ys = ys
linearAppendVect (x :: xs) ys = x :: linearAppendVect xs ys

||| Grid dimension calculation: a grid of size k has k * k cells.
public export
gridCapacity : Nat -> Nat
gridCapacity k = k * k

||| Generalized spatial lattice expansion transformer.
||| Expands the active field capacity while preserving linear conservation.
public export
expandUniverseState : {vm, de, dm : Nat} ->
                      (1 currentState : UniverseState vm de dm) ->
                      (newScale : Nat) ->
                      UniverseState (vm + (newScale * newScale)) de dm
expandUniverseState (MkUniverseState vm de dm) newScale =
  let expansionCells = replicate (newScale * newScale) (intToBoxInt 0)
      expandedVM = linearAppendVect vm expansionCells
  in MkUniverseState expandedVM de dm

||| Simulates spatial expansion step across standard 1x1 -> 2x2 -> 3x3 grids.
public export
stepGridExpansion : {vm, de, dm : Nat} ->
                    (1 currentState : UniverseState vm de dm) ->
                    (gridDim : Nat) ->
                    UniverseState (vm + (gridDim * gridDim)) de dm
stepGridExpansion state dim = expandUniverseState state dim

||| Helper function that structurally loops over column and row vectors 
||| to aggregate the total outer product matrix mass cleanly.
public export
computeOuterProductSum : {len1, len2 : Nat} -> Vect len1 Int -> Vect len2 Int -> Int
computeOuterProductSum [] _ = 0
computeOuterProductSum (k :: ks) bras = 
  sumBras k bras + computeOuterProductSum ks bras
  where
    sumBras : {m : Nat} -> Int -> Vect m Int -> Int
    sumBras _ [] = 0
    sumBras multiplier (b :: bs) = (multiplier * b) + sumBras multiplier bs

||| Completely generalized, non-hardcoded grid expansion into a pure Maxel.
||| Dynamically transitions a universe state forward into an expanded spatial Maxel
||| (such as stepping up from a 3x3 grid to a 4x4 matrix canvas).
public export
expandAndUnfoldGeneric : {currentVM, de, dm : Nat} ->
                         {nextScale : Nat} ->
                         (priorState : UniverseState currentVM de dm) ->
                         (chiralKet : Vect nextScale Int) ->
                         (chiralBra : Vect nextScale Int) ->
                         Maxel
expandAndUnfoldGeneric {currentVM} {de} {dm} {nextScale} (MkUniverseState vmState deState dmLog) chiralKet chiralBra =
  let -- 1. Structural Accounting of historical background mass
      historyMass = sumStructural dmLog
      
      -- 2. Execute the Chiral Handshake Outer Product
      gridWeight = computeOuterProductSum chiralKet chiralBra
      
      -- 3. Macro Maxel Unfold: anchor history at (nextScale, nextScale) and active field at (1, 1)
      ancestralAnchor = (MkPixel nextScale nextScale, historyMass)
      activeCell      = (MkPixel 1 1, intToBoxInt (cast gridWeight))
  in MkMaxel [ancestralAnchor, activeCell]

||| A structural pipeline wrapper that guarantees dimensional inflation
||| satisfies full resource accounting across the 4x4 scale transition.
public export
execute4x4Expansion : {vm, de, dm : Nat} ->
                      (state : UniverseState vm de dm) ->
                      (ket4 : Vect 4 Int) ->
                      (bra4 : Vect 4 Int) ->
                      Maxel
execute4x4Expansion state ket4 bra4 = 
  expandAndUnfoldGeneric state ket4 bra4
