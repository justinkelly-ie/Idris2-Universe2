module Core.VexelMaxel

import Core.BoxInt
import Core.Multiset
import Data.List
import Data.Vect
import Language.Reflection

%default total

------------------------------------------------------------------------
-- 1. WILDBERGER'S SINGLETONS, PIXELS & VOXELS
------------------------------------------------------------------------

||| A Singleton is a 1-list from Nat [n], representing a 1D basis coordinate.
public export
record Singleton where
  constructor MkSingleton
  index : Nat

public export
Eq Singleton where
  (MkSingleton i1) == (MkSingleton i2) = i1 == i2

public export
Show Singleton where
  show (MkSingleton i) = "[" ++ show i ++ "]"

||| A Pixel is a 2-list from Nat [i, j], representing a 2D coordinate cell or Grothendieck pair (pos, neg).
public export
record Pixel where
  constructor MkPixel
  row : Nat
  col : Nat

public export
Eq Pixel where
  (MkPixel r1 c1) == (MkPixel r2 c2) = r1 == r2 && c1 == c2

public export
Show Pixel where
  show (MkPixel r c) = "[" ++ show r ++ ", " ++ show c ++ "]"

||| A Voxel is a 3-list from Nat [x, y, z], representing a 3D coordinate cell or Triplet Codon / Baryon state.
public export
record Voxel where
  constructor MkVoxel
  axisX : Nat
  axisY : Nat
  axisZ : Nat

public export
Eq Voxel where
  (MkVoxel x1 y1 z1) == (MkVoxel x2 y2 z2) = x1 == x2 && y1 == y2 && z1 == z2

public export
Show Voxel where
  show (MkVoxel x y z) = "[" ++ show x ++ ", " ++ show y ++ ", " ++ show z ++ "]"

------------------------------------------------------------------------
-- 2. GROTHENDIECK BOXINT <-> PIXEL ISOMORPHISM
------------------------------------------------------------------------

||| Encodes a Grothendieck signed pair (pos, neg) as a 2D coordinate Pixel [pos, neg].
public export
boxIntToPixelPair : Nat -> Nat -> Pixel
boxIntToPixelPair p n = MkPixel p n

||| Evaluates the signed BoxInt integer value of a Grothendieck coordinate Pixel [pos, neg]: (pos - neg).
public export
pixelToSignedBoxInt : Pixel -> BoxInt
pixelToSignedBoxInt (MkPixel p n) = intToBoxInt (cast p - cast n)

------------------------------------------------------------------------
-- 3. VEXELS & MAXELS AS PURE MULTISETS
------------------------------------------------------------------------

||| A Vexel is a multiset of Singletons (Wildberger Vector).
||| Stored as a list of weighted basis Singletons: sum c_k * [k].
public export
record Vexel where
  constructor MkVexel
  terms : List (Singleton, BoxInt)

public export
Eq Vexel where
  (MkVexel t1) == (MkVexel t2) = t1 == t2

public export
Show Vexel where
  show (MkVexel ts) = "Vexel(" ++ show ts ++ ")"

||| A Maxel is a multiset of Pixels (Wildberger Matrix).
||| Stored as a list of weighted coordinate Pixels: sum a_ij * [i, j].
public export
record Maxel where
  constructor MkMaxel
  pixels : List (Pixel, BoxInt)

public export
Eq Maxel where
  (MkMaxel p1) == (MkMaxel p2) = p1 == p2

public export
Show Maxel where
  show (MkMaxel ps) = "Maxel(" ++ show ps ++ ")"

||| Extracts the weight of a specific coordinate Pixel in a Maxel.
public export
lookupPixel : Pixel -> Maxel -> BoxInt
lookupPixel _ (MkMaxel []) = intToBoxInt 0
lookupPixel target (MkMaxel ((p, w) :: rest)) =
  if p == target then w else lookupPixel target (MkMaxel rest)

------------------------------------------------------------------------
-- 4. ALGEBRAIC MULTIPLICATION: SINGLETONS WITH PIXELS
--    [k] * [l, m] = [m] if k == l else blank
------------------------------------------------------------------------

||| Multiplies a Singleton on the left by a Pixel (Row extraction filter).
public export
mulSingletonPixel : Singleton -> Pixel -> Maybe Singleton
mulSingletonPixel (MkSingleton k) (MkPixel l m) =
  if k == l then Just (MkSingleton m) else Nothing

||| Multiplies a Pixel on the left by a Singleton (Column extraction filter).
public export
mulPixelSingleton : Pixel -> Singleton -> Maybe Singleton
mulPixelSingleton (MkPixel l m) (MkSingleton k) =
  if m == k then Just (MkSingleton l) else Nothing

------------------------------------------------------------------------
-- 5. ROW & COLUMN VEXEL EXTRACTIONS FROM MAXELS
------------------------------------------------------------------------

||| Extracts the i-th Row of a Maxel as a 1D Vexel: R_i(M) = [i] * M
public export
extractRowVexel : Nat -> Maxel -> Vexel
extractRowVexel i (MkMaxel ps) =
  let singI = MkSingleton i
      extracted = mapMaybe (\(pix, w) => 
                    case mulSingletonPixel singI pix of
                      Just sOut => Just (sOut, w)
                      Nothing   => Nothing) ps
  in MkVexel extracted

||| Extracts the j-th Column of a Maxel as a 1D Vexel: C_j(M) = M * [j]
public export
extractColVexel : Nat -> Maxel -> Vexel
extractColVexel j (MkMaxel ps) =
  let singJ = MkSingleton j
      extracted = mapMaybe (\(pix, w) => 
                    case mulPixelSingleton pix singJ of
                      Just sOut => Just (sOut, w)
                      Nothing   => Nothing) ps
  in MkVexel extracted

------------------------------------------------------------------------
-- 6. CHIRAL OUTER PRODUCT: VEXEL x VEXEL -> MAXEL
------------------------------------------------------------------------

||| Multiplies a column Vexel (ket) by a row Vexel (bra) to generate a Maxel:
||| (sum c_i [i]) x (sum b_j [j]) => sum (c_i * b_j) [i, j]
public export
outerProductVexel : Vexel -> Vexel -> Maxel
outerProductVexel (MkVexel kets) (MkVexel bras) =
  let generated = [ (MkPixel (index k) (index b), kw * bw) 
                  | (k, kw) <- kets, (b, bw) <- bras ]
  in MkMaxel generated

||| Computes total weight/mass across all pixels in a Maxel.
public export
totalMaxelWeight : Maxel -> BoxInt
totalMaxelWeight (MkMaxel ps) =
  sum (map snd ps)

------------------------------------------------------------------------
-- 7. PHYSICAL, CHEMICAL & BIOLOGICAL PERMUTATIONS
------------------------------------------------------------------------

||| 🌌 Physics: A Quark Vexel represents the 3 color charges (Red=[1], Green=[2], Blue=[3]) of a Baryon singlet.
public export
nucleonQuarkVexel : Vexel
nucleonQuarkVexel =
  MkVexel [ (MkSingleton 1, intToBoxInt 1)
          , (MkSingleton 2, intToBoxInt 1)
          , (MkSingleton 3, intToBoxInt 1)
          ]

||| 🧪 Chemistry: A Molecular Bond Maxel represents covalent bond connectivity between atoms i and j.
public export
waterMoleculeBonds : Maxel
waterMoleculeBonds =
  MkMaxel [ (MkPixel 1 2, intToBoxInt 1) -- O-H1 bond
          , (MkPixel 1 3, intToBoxInt 1) -- O-H2 bond
          ]

||| 🧬 Biology: A Codon Voxel represents a 3-nucleotide genetic triplet (e.g., [A=0, U=1, G=2] => AUG Methionine/Start).
public export
startCodonAUG : Voxel
startCodonAUG = MkVoxel 0 1 2

------------------------------------------------------------------------
-- 8. COMPILE-TIME REFLECTION & INVARIANT AUDITORS
------------------------------------------------------------------------

||| Pure evaluator verifying that row extraction on an outer-product Maxel is proportional to the bra Vexel.
public export
auditRowExtractionProof : Bool
auditRowExtractionProof =
  let v1 = MkVexel [(MkSingleton 1, intToBoxInt 2), (MkSingleton 2, intToBoxInt 3)]
      v2 = MkVexel [(MkSingleton 1, intToBoxInt 1), (MkSingleton 2, intToBoxInt 4)]
      m = outerProductVexel v1 v2
      row1 = extractRowVexel 1 m
  in row1 == MkVexel [(MkSingleton 1, intToBoxInt 2), (MkSingleton 2, intToBoxInt 8)]
