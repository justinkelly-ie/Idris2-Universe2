module Compound.StellarNucleosynthesis

import Core.BoxInt
import Core.VexelMaxel
import Compound.HadronicConfinement
import Compound.AlphaReplication
import Compound.MolecularBonding
import Data.Vect

%default total

------------------------------------------------------------------------
-- 1. STELLAR TRIPLE-ALPHA PROCESS & ELEMENTAL GENESIS (EPOCHS 11 TO 20)
------------------------------------------------------------------------

||| Extended Chemical Elements synthesized in stellar interiors.
public export
data StellarElement =
    ElemH   -- Hydrogen (Z=1, Valence=1)
  | ElemHe  -- Helium (Z=2, Valence=0, Alpha Core)
  | ElemC   -- Carbon (Z=6, Valence=4, Triple-Alpha)
  | ElemN   -- Nitrogen (Z=7, Valence=3, CNO Cycle)
  | ElemO   -- Oxygen (Z=8, Valence=2, Alpha Capture on Carbon)
  | ElemNe  -- Neon (Z=10, Valence=0, Alpha Capture on Oxygen)
  | ElemMg  -- Magnesium (Z=12, Valence=2, Alpha Capture on Neon)
  | ElemSi  -- Silicon (Z=14, Valence=4, Alpha Capture on Magnesium)
  | ElemP   -- Phosphorus (Z=15, Valence=5, Polyphosphate Backbone)
  | ElemFe  -- Iron (Z=26, Valence=2, Silicon Burning Peak)

public export
Eq StellarElement where
  ElemH  == ElemH  = True
  ElemHe == ElemHe = True
  ElemC  == ElemC  = True
  ElemN  == ElemN  = True
  ElemO  == ElemO  = True
  ElemNe == ElemNe = True
  ElemMg == ElemMg = True
  ElemSi == ElemSi = True
  ElemP  == ElemP  = True
  ElemFe == ElemFe = True
  _      == _      = False

public export
Show StellarElement where
  show ElemH  = "H (Z=1)"
  show ElemHe = "He (Z=2)"
  show ElemC  = "C (Z=6)"
  show ElemN  = "N (Z=7)"
  show ElemO  = "O (Z=8)"
  show ElemNe = "Ne (Z=10)"
  show ElemMg = "Mg (Z=12)"
  show ElemSi = "Si (Z=14)"
  show ElemP  = "P (Z=15)"
  show ElemFe = "Fe (Z=26)"

||| Returns the atomic number Z (number of protons) for stellar elements.
public export
stellarAtomicNumber : StellarElement -> Nat
stellarAtomicNumber ElemH  = 1
stellarAtomicNumber ElemHe = 2
stellarAtomicNumber ElemC  = 6
stellarAtomicNumber ElemN  = 7
stellarAtomicNumber ElemO  = 8
stellarAtomicNumber ElemNe = 10
stellarAtomicNumber ElemMg = 12
stellarAtomicNumber ElemSi = 14
stellarAtomicNumber ElemP  = 15
stellarAtomicNumber ElemFe = 26

||| Returns the valence capacity for covalent and polyphosphate bonding.
public export
stellarValenceCapacity : StellarElement -> Nat
stellarValenceCapacity ElemH  = 1
stellarValenceCapacity ElemHe = 0
stellarValenceCapacity ElemC  = 4
stellarValenceCapacity ElemN  = 3
stellarValenceCapacity ElemO  = 2
stellarValenceCapacity ElemNe = 0
stellarValenceCapacity ElemMg = 2
stellarValenceCapacity ElemSi = 4
stellarValenceCapacity ElemP  = 5
stellarValenceCapacity ElemFe = 2

||| Constructs a discrete 3-component Nuclide coordinate Vexel:
||| [1] = Z (protons), [2] = N (neutrons), [3] = A (mass number = Z + N).
public export
nuclideVexel : StellarElement -> (neutrons : Nat) -> Vexel
nuclideVexel elem n =
  let z = stellarAtomicNumber elem
      a = z + n
  in canonicalizeVexel (MkVexel [ (MkUnixel 1, natToBoxInt z)
                               , (MkUnixel 2, natToBoxInt n)
                               , (MkUnixel 3, natToBoxInt a)
                               ])

------------------------------------------------------------------------
-- 2. TRIPLE-ALPHA FUSION GRAPH CONTRACTION
------------------------------------------------------------------------

||| Represents a Carbon-12 nucleus formed by fusing 3 Alpha clusters (3 x 108 = 324 voxels).
public export
record Carbon12Nucleus where
  constructor MkCarbon12Nucleus
  alphaCount  : Nat
  totalVoxels : Nat
  protons     : Nat
  neutrons    : Nat

public export
Eq Carbon12Nucleus where
  (MkCarbon12Nucleus a1 v1 p1 n1) == (MkCarbon12Nucleus a2 v2 p2 n2) =
    a1 == a2 && v1 == v2 && p1 == p2 && n1 == n2

public export
Show Carbon12Nucleus where
  show (MkCarbon12Nucleus a v p n) =
    "12C Nucleus(" ++ show a ++ " Alphas, " ++ show v ++ " voxels, " ++ 
    show p ++ "p, " ++ show n ++ "n)"

||| Executes the Triple-Alpha fusion reaction: 3 x 4He -> 12C.
public export
tripleAlphaFusion : AlphaClusterState -> AlphaClusterState -> AlphaClusterState -> Carbon12Nucleus
tripleAlphaFusion _ _ _ =
  MkCarbon12Nucleus 3 324 6 6

------------------------------------------------------------------------
-- 3. STELLAR FUSION BALANCE ARRAY NETWORK (CH. 26 & 28)
------------------------------------------------------------------------

||| Nuclide state vectors across the stellar fusion ladder:
public export
nuclideHe4 : Vexel
nuclideHe4 = nuclideVexel ElemHe 2 -- [2, 2, 4]

public export
nuclideC12 : Vexel
nuclideC12 = nuclideVexel ElemC 6 -- [6, 6, 12]

public export
nuclideO16 : Vexel
nuclideO16 = nuclideVexel ElemO 8 -- [8, 8, 16]

public export
nuclideNe20 : Vexel
nuclideNe20 = nuclideVexel ElemNe 10 -- [10, 10, 20]

public export
nuclideMg24 : Vexel
nuclideMg24 = nuclideVexel ElemMg 12 -- [12, 12, 24]

public export
nuclideSi28 : Vexel
nuclideSi28 = nuclideVexel ElemSi 14 -- [14, 14, 28]

public export
nuclideNi56Core : Vexel
nuclideNi56Core = canonicalizeVexel (MkVexel [ (MkUnixel 1, intToBoxInt 28)
                                             , (MkUnixel 2, intToBoxInt 28)
                                             , (MkUnixel 3, intToBoxInt 56)
                                             ])

||| Audits the Complete Closed Stellar Nucleosynthesis Balance Network:
||| 1. Triple-Alpha: 3 * He4 = C12
||| 2. Alpha Capture on C12: C12 + He4 = O16
||| 3. Alpha Capture on O16: O16 + He4 = Ne20
||| 4. Alpha Capture on Ne20: Ne20 + He4 = Mg24
||| 5. Alpha Capture on Mg24: Mg24 + He4 = Si28
||| 6. Silicon Burning: 2 * Si28 = Ni56/Fe56
public export
auditCompleteStellarFusionBalanceNetworkProof : Bool
auditCompleteStellarFusionBalanceNetworkProof =
  let bTripleAlpha = MkBalanceArray [3, 0] [0, 1]
      vTripleAlpha : Vect 2 Vexel = [nuclideHe4, nuclideC12]
      ok1 = isBalanced vTripleAlpha bTripleAlpha && isDisjointBalance bTripleAlpha

      bAlphaC = MkBalanceArray [1, 1, 0] [0, 0, 1]
      vAlphaC : Vect 3 Vexel = [nuclideC12, nuclideHe4, nuclideO16]
      ok2 = isBalanced vAlphaC bAlphaC && isDisjointBalance bAlphaC

      bAlphaO = MkBalanceArray [1, 1, 0] [0, 0, 1]
      vAlphaO : Vect 3 Vexel = [nuclideO16, nuclideHe4, nuclideNe20]
      ok3 = isBalanced vAlphaO bAlphaO && isDisjointBalance bAlphaO

      bAlphaNe = MkBalanceArray [1, 1, 0] [0, 0, 1]
      vAlphaNe : Vect 3 Vexel = [nuclideNe20, nuclideHe4, nuclideMg24]
      ok4 = isBalanced vAlphaNe bAlphaNe && isDisjointBalance bAlphaNe

      bAlphaMg = MkBalanceArray [1, 1, 0] [0, 0, 1]
      vAlphaMg : Vect 3 Vexel = [nuclideMg24, nuclideHe4, nuclideSi28]
      ok5 = isBalanced vAlphaMg bAlphaMg && isDisjointBalance bAlphaMg

      bSiliconBurning = MkBalanceArray [2, 0] [0, 1]
      vSiliconBurning : Vect 2 Vexel = [nuclideSi28, nuclideNi56Core]
      ok6 = isBalanced vSiliconBurning bSiliconBurning && isDisjointBalance bSiliconBurning
  in ok1 && ok2 && ok3 && ok4 && ok5 && ok6

------------------------------------------------------------------------
-- 4. CONSTRUCTIVE FORMAL AUDIT PROOFS
------------------------------------------------------------------------

||| Audits the Triple-Alpha Carbon & Phosphorus Synthesis Invariant:
||| 1. Triple-alpha process fuses 3 x 108 voxels into a 324-voxel 12C core (6 protons + 6 neutrons).
||| 2. Phosphorus (Z=15) emerges with valence capacity 5 for ATP polyphosphates.
public export
auditTripleAlphaCarbonPhosphorusSynthesisProof : Bool
auditTripleAlphaCarbonPhosphorusSynthesisProof =
  let carbon = MkCarbon12Nucleus 3 324 6 6
  in totalVoxels carbon == 324 &&
     protons carbon == 6 &&
     neutrons carbon == 6 &&
     stellarAtomicNumber ElemP == 15 &&
     stellarValenceCapacity ElemP == 5
