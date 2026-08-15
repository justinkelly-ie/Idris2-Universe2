module Compound.AlphaReplication

import Core.BoxInt
import Geometry.LatticeTopology
import Compound.HadronicConfinement
import Evolution.State
import Evolution.Init
import Data.Vect
import Data.Fin

%default total

||| A Composite Alpha Particle Core (4 Bonded Nucleons: 2 Protons + 2 Neutrons).
||| Spans 4 distinct 27-cell maxel sub-lattices (108 active sub-cells).
public export
record AlphaClusterState where
  constructor MkAlphaCluster
  proton1 : HadronState
  proton2 : HadronState
  neutron1 : HadronState
  neutron2 : HadronState

||| Flattens an AlphaClusterState into a contiguous 108-cell Visible Matter vector.
public export
flattenAlphaCluster : AlphaClusterState -> Vect 108 BoxInt
flattenAlphaCluster (MkAlphaCluster (MkHadronState p1) 
                                   (MkHadronState p2) 
                                   (MkHadronState n1) 
                                   (MkHadronState n2)) =
  p1 ++ p2 ++ n1 ++ n2

||| Initializes a Ground-State Alpha Cluster at Epoch 4.
public export
seedAlphaClusterEpoch4 : AlphaClusterState
seedAlphaClusterEpoch4 =
  let h = seedHadronEpoch3
  in MkAlphaCluster h h h h

||| Computes total bound valence flux of the Alpha Cluster (4 x 27 = 108).
public export
totalAlphaFlux : AlphaClusterState -> BoxInt
totalAlphaFlux alpha =
  let flat = flattenAlphaCluster alpha
  in foldl (+) (intToBoxInt 0) flat

||| Validates Nuclear Stability & S-Wave Symmetry:
||| The Alpha particle is stable if all 4 constituent nucleons are color-neutral singlets.
public export
isAlphaStable : AlphaClusterState -> Bool
isAlphaStable (MkAlphaCluster p1 p2 n1 n2) =
  isColorNeutral p1 && isColorNeutral p2 && isColorNeutral n1 && isColorNeutral n2

||| Step-Up to Epoch 4 Cosmic State: UniverseState 108 128 6.
public export
alphaCosmicStateEpoch4 : UniverseState 108 128 6
alphaCosmicStateEpoch4 = 
  let vm = flattenAlphaCluster seedAlphaClusterEpoch4
      de = replicate 128 (intToBoxInt 0)
      dm = replicate 6 (intToBoxInt 0)
  in MkUniverseState vm de dm
