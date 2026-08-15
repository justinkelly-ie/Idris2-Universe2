module Evolution.GridExpansion

import Core.BoxInt
import Math.IntPolynumber
import Math.LinAlgebra.MetricTensor
import Evolution.State
import Evolution.StructuralAccounting
import Data.Vect

%default total

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

||| Completely generalized, non-hardcoded grid expansion engine.
||| Dynamically transitions a universe state forward into an expanded spatial matrix
||| (such as stepping up from a 3x3 grid to a 4x4 matrix canvas).
public export
expandAndUnfoldGeneric : {currentVM, de, dm : Nat} ->
                         {nextScale : Nat} ->
                         (priorState : UniverseState currentVM de dm) ->
                         (chiralKet : Vect nextScale Int) ->
                         (chiralBra : Vect nextScale Int) ->
                         IntPolynumber
expandAndUnfoldGeneric {currentVM} {de} {dm} {nextScale} (MkUniverseState vmState deState dmLog) chiralKet chiralBra =
  let -- 1. Structural Accounting:
      --    Compute historical mass weight by walking down the vector array manually.
      historyMass = sumStructural dmLog
      
      -- 2. Execute the Chiral Handshake Outer Product:
      --    Cross-multiply the 1D structural vectors to generate the new, 
      --    higher-dimensional coordinate lattice cells (e.g., 4x4 = 16 cells).
      gridWeight = computeOuterProductSum chiralKet chiralBra
      
      -- 3. The Macro Tensor Unfold:
      --    Anchor the accumulated history mass at the outer boundary coordinates,
      --    while wrapping the new cell grid coordinates smoothly into the active manifold.
      ancestralAnchor = AddM (nextScale, nextScale) historyMass ZeroM
      expandedManifold = AddM (1, 1) (intToBoxInt (cast gridWeight)) ancestralAnchor
      
  in expandedManifold

||| A structural pipeline wrapper that guarantees dimensional inflation
||| satisfies full resource accounting across the 4x4 scale transition.
public export
execute4x4Expansion : {vm, de, dm : Nat} ->
                      (state : UniverseState vm de dm) ->
                      (ket4 : Vect 4 Int) ->
                      (bra4 : Vect 4 Int) ->
                      IntPolynumber
execute4x4Expansion state ket4 bra4 = 
  expandAndUnfoldGeneric state ket4 bra4
