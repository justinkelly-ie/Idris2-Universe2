module Evolution.Init

import Core.BoxInt
import Evolution.State
import Data.Vect
import Data.Nat

%default total

||| Relational scaling function for 3D spatial field lattice cells.
||| Grid dimension k produces k^3 active spatial slots (1 -> 1, 2 -> 8, 3 -> 27).
public export
computeVMSize : (gridDim : Nat) -> Nat
computeVMSize dim = dim * dim * dim

||| Relational scaling function for Dark Energy binary ROM buffer depth.
||| Binary depth b produces 2^b conserved archival capacity slots (e.g. 7 -> 128).
public export
computeDESize : (deDepth : Nat) -> Nat
computeDESize depth = power 2 depth

||| Relational scaling function for Dark Matter historical log length.
||| The ledger records exactly the number of elapsed evolutionary epochs.
public export
computeDMSize : (epoch : Nat) -> Nat
computeDMSize epoch = epoch

||| Dynamically initializes the cosmic vacuum state purely from spatial,
||| energy depth, and epoch parameters without magic constants or casts.
public export
seedCosmicVacuum : (gridDim : Nat) -> 
                    (deDepth : Nat) -> 
                    (epoch : Nat) -> 
                    UniverseState (computeVMSize gridDim) 
                                  (computeDESize deDepth) 
                                  (computeDMSize epoch)
seedCosmicVacuum gridDim deDepth epoch =
  let initVM = replicate (computeVMSize gridDim) (intToBoxInt 0)
      initDE = replicate (computeDESize deDepth) (natToBoxInt epoch)
      initDM = replicate (computeDMSize epoch) (natToBoxInt epoch)
  in MkUniverseState initVM initDE initDM

||| The Primordial Genesis Vacuum state at Epoch 1 (empty Dark Matter history log).
public export
genesisVacuumAtScale : (gridDim : Nat) -> (deDepth : Nat) -> UniverseState (computeVMSize gridDim) (computeDESize deDepth) 0
genesisVacuumAtScale gridDim deDepth = seedCosmicVacuum gridDim deDepth 0
