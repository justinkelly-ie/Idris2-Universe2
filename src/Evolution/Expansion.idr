module Evolution.Expansion

import Core.BoxInt
import Evolution.State
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
expandAndUnfoldGeneric : {vm, de, dm : Nat} ->
                         (1 currentState : UniverseState vm de dm) ->
                         (newScale : Nat) ->
                         UniverseState (vm + (newScale * newScale)) de dm
expandAndUnfoldGeneric (MkUniverseState vm de dm) newScale =
  let expansionCells = replicate (newScale * newScale) (intToBoxInt 0)
      expandedVM = linearAppendVect vm expansionCells
  in MkUniverseState expandedVM de dm

||| Simulates spatial expansion step across standard 1x1 -> 2x2 -> 3x3 grids.
public export
stepGridExpansion : {vm, de, dm : Nat} ->
                    (1 currentState : UniverseState vm de dm) ->
                    (gridDim : Nat) ->
                    UniverseState (vm + (gridDim * gridDim)) de dm
stepGridExpansion state dim = expandAndUnfoldGeneric state dim
