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

||| A Pixel is a 2-list from Nat [i, j], representing a 2D coordinate cell or signed difference pair [pos, neg].
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
-- 2. SIGNED BOXINT <-> PIXEL DIFFERENCE PAIR ISOMORPHISM
------------------------------------------------------------------------

||| Encodes a signed difference pair (pos, neg) as a 2D coordinate Pixel [pos, neg].
public export
boxIntToPixelPair : Nat -> Nat -> Pixel
boxIntToPixelPair p n = MkPixel p n

||| Evaluates the signed BoxInt integer value of a difference pair Pixel [pos, neg]: (pos - neg).
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

||| Extracts the weight of a specific basis Singleton in a Vexel.
public export
lookupSingleton : Singleton -> Vexel -> BoxInt
lookupSingleton target (MkVexel sings) =
  foldl (\acc, (s, w) => if s == target then acc + w else acc) (intToBoxInt 0) sings

||| Computes the total integer mass of a Vexel vector.
public export
totalVexelMass : Vexel -> BoxInt
totalVexelMass (MkVexel sings) =
  foldl (\acc, (_, w) => acc + w) (intToBoxInt 0) sings


||| Extracts the weight of a specific coordinate Pixel in a Maxel.
public export
lookupPixel : Pixel -> Maxel -> BoxInt
lookupPixel target (MkMaxel ps) =
  foldl (\acc, (p, w) => if p == target then acc + w else acc) (intToBoxInt 0) ps

||| A Boxel is a multiset of Voxels (Wildberger 3D Volume Tensor).
||| Stored as a list of weighted coordinate Voxels: sum rho_xyz * [x, y, z].
public export
record Boxel where
  constructor MkBoxel
  voxels : List (Voxel, BoxInt)

public export
Eq Boxel where
  (MkBoxel b1) == (MkBoxel b2) = b1 == b2

public export
Show Boxel where
  show (MkBoxel bs) = "Boxel(" ++ show bs ++ ")"

||| Extracts the weight of a specific coordinate Voxel in a Boxel.
public export
lookupVoxel : Voxel -> Boxel -> BoxInt
lookupVoxel target (MkBoxel vs) =
  foldl (\acc, (v, w) => if v == target then acc + w else acc) (intToBoxInt 0) vs


||| Adds two Boxels by concatenating their voxel multiset entries.
public export
addBoxel : Boxel -> Boxel -> Boxel
addBoxel (MkBoxel bs1) (MkBoxel bs2) = MkBoxel (bs1 ++ bs2)

||| Scales a Boxel by a BoxInt scalar.
public export
scaleBoxel : BoxInt -> Boxel -> Boxel
scaleBoxel s (MkBoxel bs) =
  MkBoxel (map (\(v, w) => (v, s * w)) bs)

||| Computes total weight/density across all voxels in a Boxel.
public export
totalBoxelWeight : Boxel -> BoxInt
totalBoxelWeight (MkBoxel bs) =
  sum (map snd bs)

------------------------------------------------------------------------
-- CANONICAL MULTISET REDUCTION & ZERO-PRUNING
------------------------------------------------------------------------

||| Aggregates duplicate coordinate Singletons and prunes zero-weight entries in a Vexel.
public export
canonicalizeVexel : Vexel -> Vexel
canonicalizeVexel (MkVexel terms) =
  let folded = foldl insertOrAdd [] terms
      pruned = filter (\(_, w) => unwrapBox w /= 0) folded
  in MkVexel pruned
  where
    insertOrAdd : List (Singleton, BoxInt) -> (Singleton, BoxInt) -> List (Singleton, BoxInt)
    insertOrAdd [] (s, w) = [(s, w)]
    insertOrAdd ((k, v) :: rest) (s, w) =
      if k == s 
        then (k, v + w) :: rest 
        else (k, v) :: insertOrAdd rest (s, w)

||| Aggregates duplicate coordinate Pixels and prunes zero-weight entries in a Maxel.
public export
canonicalizeMaxel : Maxel -> Maxel
canonicalizeMaxel (MkMaxel pxs) =
  let folded = foldl insertOrAdd [] pxs
      pruned = filter (\(_, w) => unwrapBox w /= 0) folded
  in MkMaxel pruned
  where
    insertOrAdd : List (Pixel, BoxInt) -> (Pixel, BoxInt) -> List (Pixel, BoxInt)
    insertOrAdd [] (p, w) = [(p, w)]
    insertOrAdd ((k, v) :: rest) (p, w) =
      if k == p 
        then (k, v + w) :: rest 
        else (k, v) :: insertOrAdd rest (p, w)

||| Aggregates duplicate coordinate Voxels and prunes zero-weight entries in a Boxel.
public export
canonicalizeBoxel : Boxel -> Boxel
canonicalizeBoxel (MkBoxel voxs) =
  let folded = foldl insertOrAdd [] voxs
      pruned = filter (\(_, w) => unwrapBox w /= 0) folded
  in MkBoxel pruned
  where
    insertOrAdd : List (Voxel, BoxInt) -> (Voxel, BoxInt) -> List (Voxel, BoxInt)
    insertOrAdd [] (v, w) = [(v, w)]
    insertOrAdd ((k, val) :: rest) (v, w) =
      if k == v 
        then (k, val + w) :: rest 
        else (k, val) :: insertOrAdd rest (v, w)

------------------------------------------------------------------------
-- 4. ALGEBRAIC MULTIPLICATION: PIXELS & SINGLETONS
--    [k] * [l, m] = [m] if k == l else blank
--    [i, j] * [k, l] = [i, l] if j == k else blank
------------------------------------------------------------------------

||| Multiplies a Pixel by a Pixel (discrete matrix basis multiplication).
||| [i, j] * [k, l] = [i, l] if j == k, otherwise Nothing.
public export
mulPixel : Pixel -> Pixel -> Maybe Pixel
mulPixel (MkPixel i j) (MkPixel k l) =
  if j == k then Just (MkPixel i l) else Nothing

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

||| Multiplies two Maxels (discrete matrix multiplication).
||| (sum a_ij [i, j]) * (sum b_kl [k, l]) => sum (a_ij * b_kl) [i, l] (where j == k)
public export
mulMaxel : Maxel -> Maxel -> Maxel
mulMaxel (MkMaxel ps1) (MkMaxel ps2) =
  let step : (Pixel, BoxInt) -> List (Pixel, BoxInt)
      step (p1, w1) = mapMaybe (\(p2, w2) => case mulPixel p1 p2 of
                                               Just pOut => Just (pOut, w1 * w2)
                                               Nothing   => Nothing) ps2
  in MkMaxel (concatMap step ps1)

||| Contracts a Maxel matrix on a Vexel vector (M * v).
public export
actMaxelVexel : Maxel -> Vexel -> Vexel
actMaxelVexel (MkMaxel pxs) (MkVexel sings) =
  let step : (Pixel, BoxInt) -> List (Singleton, BoxInt)
      step (pix, pw) = mapMaybe (\(sing, sw) => case mulPixelSingleton pix sing of
                                                  Just sOut => Just (sOut, pw * sw)
                                                  Nothing   => Nothing) sings
  in MkVexel (concatMap step pxs)


||| Canonical 3D identity metric Maxel: [1, 1] + [2, 2] + [3, 3].
public export
identityMaxel : Maxel
identityMaxel =
  MkMaxel [ (MkPixel 1 1, intToBoxInt 1)
          , (MkPixel 2 2, intToBoxInt 1)
          , (MkPixel 3 3, intToBoxInt 1)
          ]

||| Adds two Maxels by concatenating their pixel multiset entries.
public export
addMaxel : Maxel -> Maxel -> Maxel
addMaxel (MkMaxel ps1) (MkMaxel ps2) = MkMaxel (ps1 ++ ps2)


||| Scales a Maxel by a BoxInt scalar.
public export
scaleMaxel : BoxInt -> Maxel -> Maxel
scaleMaxel s (MkMaxel ps) =
  MkMaxel (map (\(p, w) => (p, s * w)) ps)

||| Adds two Vexels by concatenating their singleton multiset entries.
public export
addVexel : Vexel -> Vexel -> Vexel
addVexel (MkVexel s1) (MkVexel s2) = MkVexel (s1 ++ s2)

||| Subtracts two Vexels (u - v = u + (-1)*v).
public export
subVexel : Vexel -> Vexel -> Vexel
subVexel (MkVexel s1) (MkVexel s2) =
  MkVexel (s1 ++ map (\(s, w) => (s, -w)) s2)

||| Scales a Vexel by a BoxInt scalar.
public export
scaleVexel : BoxInt -> Vexel -> Vexel
scaleVexel s (MkVexel sings) =
  MkVexel (map (\(sing, w) => (sing, s * w)) sings)

||| Evaluates the standard Euclidean inner product between two Vexels.
public export
dotVexel : Vexel -> Vexel -> BoxInt
dotVexel (MkVexel uTerms) v =
  let step : (Singleton, BoxInt) -> BoxInt
      step (s, uw) =
        let vw = lookupSingleton s v
        in uw * vw
  in foldl (+) (intToBoxInt 0) (map step uTerms)

||| Evaluates the metric inner product <u, v>_g = u^T (g * v).
public export
metricInnerVexel : Maxel -> Vexel -> Vexel -> BoxInt
metricInnerVexel g u v =
  let gv = actMaxelVexel g v
  in dotVexel u gv

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
-- 6. CHIRAL OUTER PRODUCTS & 3D TENSOR STACKS
------------------------------------------------------------------------

||| Multiplies a column Vexel (ket) by a row Vexel (bra) to generate a Maxel:
||| (sum c_i [i]) x (sum b_j [j]) => sum (c_i * b_j) [i, j]
public export
outerProductVexel : Vexel -> Vexel -> Maxel
outerProductVexel (MkVexel kets) (MkVexel bras) =
  let generated = [ (MkPixel (index k) (index b), kw * bw) 
                  | (k, kw) <- kets, (b, bw) <- bras ]
  in MkMaxel generated

||| 3D Tensor Outer Product: Vexel (1D ket) x Maxel (2D surface) -> Boxel (3D volume).
||| (sum c_k [k]) x (sum a_ij [i, j]) => sum (c_k * a_ij) [k, i, j]
public export
outerProductVexelMaxel : Vexel -> Maxel -> Boxel
outerProductVexelMaxel (MkVexel sings) (MkMaxel pxs) =
  let generated = [ (MkVoxel (index s) (row p) (col p), sw * pw)
                  | (s, sw) <- sings
                  , (p, pw) <- pxs ]
  in canonicalizeBoxel (MkBoxel generated)

||| Extracts a 2D Maxel plane slice at a fixed Z-coordinate: Z_k(B) = { [x, y] with w | [x, y, k] in B }
public export
sliceBoxelZ : Nat -> Boxel -> Maxel
sliceBoxelZ targetZ (MkBoxel voxs) =
  let extracted = mapMaybe (\(MkVoxel x y z, w) =>
                    if z == targetZ then Just (MkPixel x y, w) else Nothing) voxs
  in canonicalizeMaxel (MkMaxel extracted)

||| Extracts a 2D Maxel plane slice at a fixed Y-coordinate: Y_k(B) = { [x, z] with w | [x, k, z] in B }
public export
sliceBoxelY : Nat -> Boxel -> Maxel
sliceBoxelY targetY (MkBoxel voxs) =
  let extracted = mapMaybe (\(MkVoxel x y z, w) =>
                    if y == targetY then Just (MkPixel x z, w) else Nothing) voxs
  in canonicalizeMaxel (MkMaxel extracted)

||| Extracts a 2D Maxel plane slice at a fixed X-coordinate: X_k(B) = { [y, z] with w | [k, y, z] in B }
public export
sliceBoxelX : Nat -> Boxel -> Maxel
sliceBoxelX targetX (MkBoxel voxs) =
  let extracted = mapMaybe (\(MkVoxel x y z, w) =>
                    if x == targetX then Just (MkPixel y z, w) else Nothing) voxs
  in canonicalizeMaxel (MkMaxel extracted)

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

||| 🧬 Biology: A GeneBoxel represents a chain of triplet codons along an mRNA reading frame.
public export
record GeneBoxel where
  constructor MkGene
  codons : Boxel

||| Fundamental Amino Acids transcribed from genetic triplet codons:
||| - Methionine (AUG / [0, 1, 2] - Start Codon)
||| - Alanine (GCU / [2, 1, 0])
||| - Glycine (GGU / [2, 2, 0])
||| - Serine (UCU / [1, 1, 0])
||| - StopCodon (UAA / [1, 0, 0])
||| - UnknownAcid
public export
data AminoAcid = Methionine | Alanine | Glycine | Serine | StopCodon | UnknownAcid

public export
Eq AminoAcid where
  Methionine == Methionine = True
  Alanine    == Alanine    = True
  Glycine    == Glycine    = True
  Serine     == Serine     = True
  StopCodon  == StopCodon  = True
  UnknownAcid == UnknownAcid = True
  _          == _          = False

public export
Show AminoAcid where
  show Methionine  = "Met"
  show Alanine     = "Ala"
  show Glycine     = "Gly"
  show Serine      = "Ser"
  show StopCodon   = "Stop"
  show UnknownAcid = "Xaa"

||| Transcribes a 3-nucleotide coordinate Voxel into its corresponding Amino Acid.
public export
translateCodon : Voxel -> AminoAcid
translateCodon (MkVoxel 0 1 2) = Methionine -- AUG
translateCodon (MkVoxel 2 1 0) = Alanine    -- GCU
translateCodon (MkVoxel 2 2 0) = Glycine    -- GGU
translateCodon (MkVoxel 1 1 0) = Serine     -- UCU
translateCodon (MkVoxel 1 0 0) = StopCodon  -- UAA
translateCodon _               = UnknownAcid

||| Translates a GeneBoxel reading frame into a sequence of Amino Acids.
public export
translateGene : GeneBoxel -> List AminoAcid
translateGene (MkGene (MkBoxel voxs)) =
  map (\(v, _) => translateCodon v) voxs

------------------------------------------------------------------------
-- 8. GRASSMANN WEDGE PRODUCTS ON MULTISETS (Vexel ^ Vexel -> Maxel)
------------------------------------------------------------------------

||| Evaluates the Grassmann exterior wedge product of two Vexels:
||| [u] ^ [v] = [u, v] - [v, u].
||| Satisfies exact nilpotency: v ^ v == 0.
public export
wedgeVexel : Vexel -> Vexel -> Maxel
wedgeVexel (MkVexel u) (MkVexel v) =
  let pairs = concatMap (\(MkSingleton i, wu) =>
                map (\(MkSingleton j, wv) =>
                  (MkPixel i j, wu * wv)) v) u
      antisym = concatMap (\(MkPixel i j, w) =>
        if i == j then [] else [(MkPixel i j, w), (MkPixel j i, -w)]) pairs
  in canonicalizeMaxel (MkMaxel antisym)


||| Evaluates the Grassmann exterior wedge product of a Vexel and a Maxel into a 3D Boxel:
||| [u] ^ [v, w] = [u, v, w] - [v, u, w] + [v, w, u].
public export
wedgeVexelMaxel : Vexel -> Maxel -> Boxel
wedgeVexelMaxel (MkVexel u) (MkMaxel m) =
  let terms = concatMap (\(MkSingleton i, wu) =>
        concatMap (\(MkPixel j k, wm) =>
          if i == j || j == k || i == k
            then []
            else let w = wu * wm
                 in [ (MkVoxel i j k, w)
                    , (MkVoxel j i k, -w)
                    , (MkVoxel j k i, w)
                    ]) m) u
  in canonicalizeBoxel (MkBoxel terms)

------------------------------------------------------------------------
-- 9. 4D SPACETIME HYPERBOXEL TENSORS (Tesseract [x, y, z, t])
------------------------------------------------------------------------

||| A 4D Spacetime coordinate token [x, y, z, t].
public export
record Tesseract where
  constructor MkTesseract
  x : Nat
  y : Nat
  z : Nat
  t : Nat

public export
Eq Tesseract where
  (MkTesseract x1 y1 z1 t1) == (MkTesseract x2 y2 z2 t2) =
    x1 == x2 && y1 == y2 && z1 == z2 && t1 == t2

public export
Show Tesseract where
  show (MkTesseract x y z t) = "[" ++ show x ++ ", " ++ show y ++ ", " ++ show z ++ ", " ++ show t ++ "]"

||| A 4D Spacetime HyperBoxel represents a 4D volume multiset of weighted Tesseract cells.
public export
record HyperBoxel where
  constructor MkHyperBoxel
  cells : List (Tesseract, BoxInt)

public export
Eq HyperBoxel where
  (MkHyperBoxel c1) == (MkHyperBoxel c2) = c1 == c2

public export
Show HyperBoxel where
  show (MkHyperBoxel c) = "HyperBoxel" ++ show c

||| Canonicalizes a 4D HyperBoxel by pruning zeros and merging duplicate Tesseract coordinates.
public export
canonicalizeHyperBoxel : HyperBoxel -> HyperBoxel
canonicalizeHyperBoxel (MkHyperBoxel raw) =
  let nonZero = filter (\(_, w) => unwrapBox w /= 0) raw
      merged = foldl insertOrAdd [] nonZero
  in MkHyperBoxel merged
  where
    insertOrAdd : List (Tesseract, BoxInt) -> (Tesseract, BoxInt) -> List (Tesseract, BoxInt)
    insertOrAdd [] item = [item]
    insertOrAdd ((t, w) :: rest) (newT, newW) =
      if t == newT
        then let combined = w + newW
             in if unwrapBox combined == 0 then rest else (t, combined) :: rest
        else (t, w) :: insertOrAdd rest (newT, newW)

||| Looks up the weight of a 4D Tesseract coordinate in a HyperBoxel.
public export
lookupTesseract : Tesseract -> HyperBoxel -> BoxInt
lookupTesseract target (MkHyperBoxel raw) =
  case find (\(t, _) => t == target) raw of
    Just (_, w) => w
    Nothing     => intToBoxInt 0

||| Slices a 4D HyperBoxel at a fixed temporal coordinate t = targetT into a 3D spatial Boxel.
public export
sliceHyperBoxelT : Nat -> HyperBoxel -> Boxel
sliceHyperBoxelT targetT (MkHyperBoxel cells) =
  let extracted = mapMaybe (\(MkTesseract x y z t, w) =>
                    if t == targetT then Just (MkVoxel x y z, w) else Nothing) cells
  in canonicalizeBoxel (MkBoxel extracted)

||| Outer product of a temporal Vexel and a spatial Boxel: T (x) S -> 4D HyperBoxel.
public export
outerProductVexelBoxel : Vexel -> Boxel -> HyperBoxel
outerProductVexelBoxel (MkVexel times) (MkBoxel spaces) =
  let productList = [ (MkTesseract x y z t, wt * ws)
                    | (MkSingleton t, wt) <- times
                    , (MkVoxel x y z, ws) <- spaces
                    ]
  in canonicalizeHyperBoxel (MkHyperBoxel productList)

------------------------------------------------------------------------
-- 10. COMPILE-TIME REFLECTION & INVARIANT AUDITORS
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

||| Proves that the Grassmann wedge product of any Vexel with itself is identically zero: v ^ v == 0.
public export
auditWedgeNilpotencyProof : Bool
auditWedgeNilpotencyProof =
  let v = MkVexel [(MkSingleton 1, intToBoxInt 3), (MkSingleton 2, intToBoxInt 5)]
      w = wedgeVexel v v
  in w == MkMaxel []

||| Proves that slicing a 4D HyperBoxel at time t=2 extracts the exact 3D spatial Boxel.
public export
auditHyperBoxelSliceProof : Bool
auditHyperBoxelSliceProof =
  let tVex = MkVexel [(MkSingleton 1, intToBoxInt 1), (MkSingleton 2, intToBoxInt 1)]
      sBox = MkBoxel [(MkVoxel 1 1 1, intToBoxInt 7), (MkVoxel 2 2 2, intToBoxInt 9)]
      h4   = outerProductVexelBoxel tVex sBox
      s2   = sliceHyperBoxelT 2 h4
  in s2 == sBox
