module Core.Polynumber

import Core.BoxInt
import Core.VexelMaxel
import Data.List
import Data.Nat
import Language.Reflection

%default total

------------------------------------------------------------------------
-- 1. DISCRETE POLYNOMIAL MULTISET CONTAINERS (WILDBERGER POLYS)
------------------------------------------------------------------------

||| A discrete Monomial Term in Wildberger's Box Arithmetic.
||| Represents c * x^k where:
||| - coeff: The multiset tally of empty boxes (c).
||| - degree: The nesting depth of the box (k).
public export
record PolynumberTerm where
  constructor MkPolynumberTerm
  coeff  : BoxInt
  degree : Nat

public export
Eq PolynumberTerm where
  (MkPolynumberTerm c1 d1) == (MkPolynumberTerm c2 d2) = c1 == c2 && d1 == d2

public export
Show PolynumberTerm where
  show (MkPolynumberTerm c d) = 
    show c ++ (if d == 0 then "" else " * x^" ++ show d)

||| Alias for backward compatibility.
public export
BoxTerm : Type
BoxTerm = PolynumberTerm

public export
MkBoxTerm : BoxInt -> Nat -> BoxTerm
MkBoxTerm = MkPolynumberTerm

||| A Polynumber is a multiset of nested monomial terms.
||| Stored as a coefficient list from degree 0 upwards: c0 + c1*x + c2*x^2 + ...
public export
record Polynumber where
  constructor MkPolynumber
  coeffs : List BoxInt -- coeffs[k] is coefficient of x^k

public export
Eq Polynumber where
  (MkPolynumber c1) == (MkPolynumber c2) = c1 == c2

public export
Show Polynumber where
  show (MkPolynumber cs) = 
    "Polynumber(" ++ show (map unwrapBox cs) ++ ")"

||| Backward compatibility type alias.
public export
BoxPolynomial : Type
BoxPolynomial = Polynumber

public export
MkBoxPolynomial : List BoxInt -> BoxPolynomial
MkBoxPolynomial = MkPolynumber

||| Structurally recursive list trimmer eliminating trailing zeros without reverse/dropWhile.
public export
trimList : List BoxInt -> List BoxInt
trimList [] = []
trimList (x :: xs) = 
  let rest = trimList xs
  in case rest of
       [] => if unwrapBox x == 0 then [] else [x]
       _  => x :: rest

||| Strips trailing zero coefficients to normalize the polynumber container.
public export
trimPolynumber : Polynumber -> Polynumber
trimPolynumber (MkPolynumber cs) = MkPolynumber (trimList cs)

public export
trimPoly : BoxPolynomial -> BoxPolynomial
trimPoly = trimPolynumber

public export
safeLast : a -> List a -> a
safeLast def [] = def
safeLast def [x] = x
safeLast def (x :: xs) = safeLast def xs

||| Evaluates leading coefficient and leading degree.
public export
leadingTerm : Polynumber -> (BoxInt, Nat)
leadingTerm (MkPolynumber cs) = 
  let trimmed = trimList cs
  in case trimmed of
       [] => (intToBoxInt 0, 0)
       xs => (safeLast (intToBoxInt 0) xs, minus (length xs) 1)

||| Degree of a polynumber (nesting depth of the highest non-zero box term).
public export
polynumberDegree : Polynumber -> Nat
polynumberDegree p = snd (leadingTerm p)

public export
polyDegree : BoxPolynomial -> Nat
polyDegree = polynumberDegree

||| Zero polynumber: empty box container.
public export
zeroPolynumber : Polynumber
zeroPolynumber = MkPolynumber []

public export
zeroPoly : BoxPolynomial
zeroPoly = zeroPolynumber

||| Creates a constant monomial polynumber: c * x^0.
public export
constantPolynumber : BoxInt -> Polynumber
constantPolynumber c = trimPolynumber (MkPolynumber [c])

public export
constantPoly : BoxInt -> BoxPolynomial
constantPoly = constantPolynumber

||| Creates a single monomial term polynumber: c * x^deg.
public export
monomialPolynumber : BoxInt -> Nat -> Polynumber
monomialPolynumber c deg = 
  trimPolynumber (MkPolynumber (replicate deg (intToBoxInt 0) ++ [c]))

public export
monomialPoly : BoxInt -> Nat -> BoxPolynomial
monomialPoly = monomialPolynumber

||| Addition of polynumbers: pours term containers together and adds matching degrees.
public export
addPolyList : List BoxInt -> List BoxInt -> List BoxInt
addPolyList [] ys = ys
addPolyList xs [] = xs
addPolyList (x :: xs) (y :: ys) = (x + y) :: addPolyList xs ys

public export
addPolynumber : Polynumber -> Polynumber -> Polynumber
addPolynumber (MkPolynumber p1) (MkPolynumber p2) = 
  trimPolynumber (MkPolynumber (addPolyList p1 p2))

public export
addPoly : BoxPolynomial -> BoxPolynomial -> BoxPolynomial
addPoly = addPolynumber

||| Subtraction of polynumbers: inverts the negative box container and pours terms.
public export
subPolyList : List BoxInt -> List BoxInt -> List BoxInt
subPolyList [] ys = map negate ys
subPolyList xs [] = xs
subPolyList (x :: xs) (y :: ys) = (x - y) :: subPolyList xs ys

public export
subPolynumber : Polynumber -> Polynumber -> Polynumber
subPolynumber (MkPolynumber p1) (MkPolynumber p2) = 
  trimPolynumber (MkPolynumber (subPolyList p1 p2))

public export
subPoly : BoxPolynomial -> BoxPolynomial -> BoxPolynomial
subPoly = subPolynumber

||| Scalar multiplication of a polynumber container.
public export
scalePolynumber : BoxInt -> Polynumber -> Polynumber
scalePolynumber s (MkPolynumber cs) = 
  trimPolynumber (MkPolynumber (map (* s) cs))

public export
scalePoly : BoxInt -> BoxPolynomial -> BoxPolynomial
scalePoly = scalePolynumber

||| Shifts a polynumber by multiplying by x^k (increasing nesting depth by k).
public export
shiftPolynumber : Nat -> Polynumber -> Polynumber
shiftPolynumber Z p = p
shiftPolynumber (S k) (MkPolynumber cs) = 
  trimPolynumber (MkPolynumber (intToBoxInt 0 :: cs))

public export
shiftPoly : Nat -> BoxPolynomial -> BoxPolynomial
shiftPoly = shiftPolynumber

||| Monomial multiplication: (c1 * x^d1) * P(x).
public export
mulMonomial : BoxInt -> Nat -> Polynumber -> Polynumber
mulMonomial c deg p = 
  shiftPolynumber deg (scalePolynumber c p)

||| Polynumber Multiplication: Cauchy product / Cartesian combination of nested terms.
public export
mulPolynumber : Polynumber -> Polynumber -> Polynumber
mulPolynumber (MkPolynumber []) _ = zeroPolynumber
mulPolynumber (MkPolynumber (c :: cs)) q = 
  addPolynumber (scalePolynumber c q) (shiftPolynumber 1 (mulPolynumber (MkPolynumber cs) q))

public export
mulPoly : BoxPolynomial -> BoxPolynomial -> BoxPolynomial
mulPoly = mulPolynumber

||| Exact discrete polynumber evaluation at an integer scalar x = a (Horner's rule).
public export
evalPolyList : List BoxInt -> BoxInt -> BoxInt
evalPolyList [] _ = intToBoxInt 0
evalPolyList (c :: cs) a = c + (a * evalPolyList cs a)

public export
evalPolynumber : Polynumber -> BoxInt -> BoxInt
evalPolynumber (MkPolynumber cs) a = evalPolyList cs a

public export
evalPoly : BoxPolynomial -> BoxInt -> BoxInt
evalPoly = evalPolynumber

------------------------------------------------------------------------
-- 2. MULTISET ISOMORPHISMS: POLYS <-> VEXELS, MAXELS, BOXELS
------------------------------------------------------------------------

||| Converts a univariate Polynumber into a 1D Vexel: sum c_k x^k <=> sum c_k [k].
public export
polynumberToVexel : Polynumber -> Vexel
polynumberToVexel (MkPolynumber cs) =
  let pairs = zipWith (\idx, c => (MkSingleton idx, c)) [0..(length cs)] cs
  in canonicalizeVexel (MkVexel pairs)

||| Converts a 1D Vexel into a univariate Polynumber: sum c_k [k] <=> sum c_k x^k.
public export
vexelToPolynumber : Vexel -> Polynumber
vexelToPolynumber (MkVexel terms) =
  foldl (\acc, (sing, w) => addPolynumber acc (monomialPolynumber w (index sing)))
        zeroPolynumber
        terms

||| Converts a 2D Maxel into a bivariate polynumber: sum a_ij [i, j] <=> sum a_ij x^i y^j.
public export
maxelToBivariatePolynumber : Maxel -> List ((Nat, Nat), BoxInt)
maxelToBivariatePolynumber (MkMaxel ps) =
  map (\(MkPixel r c, w) => ((r, c), w)) ps

||| Converts a 3D Boxel into a trivariate polynumber: sum rho_ijk [i, j, k] <=> sum rho_ijk x^i y^j z^k.
public export
boxelToTrivariatePolynumber : Boxel -> List ((Nat, Nat, Nat), BoxInt)
boxelToTrivariatePolynumber (MkBoxel vs) =
  map (\(MkVoxel x y z, w) => ((x, y, z), w)) vs

------------------------------------------------------------------------
-- 3. WILDBERGER SPREAD POLYS: Sn(s) MULTIPLE-SPREAD RECURRENCE
------------------------------------------------------------------------

||| Generates the n-th Wildberger Spread Polynumber S_n(s) using exact integer coefficients:
||| S_0(s) = 0
||| S_1(s) = s
||| S_2(s) = 4s - 4s²
||| S_3(s) = 9s - 24s² + 16s³
||| S_4(s) = 16s - 112s² + 224s³ - 128s⁴
||| Recurrence: S_n(s) = 2(1 - 2s) * S_{n-1}(s) - S_{n-2}(s) + 2s (for n >= 2)
public export
spreadPolynumber : (n : Nat) -> Polynumber
spreadPolynumber Z = zeroPolynumber
spreadPolynumber (S Z) = monomialPolynumber (intToBoxInt 1) 1
spreadPolynumber (S (S Z)) =
  -- S_2(s) = 4s - 4s^2
  addPolynumber (monomialPolynumber (intToBoxInt 4) 1)
                (monomialPolynumber (intToBoxInt (-4)) 2)
spreadPolynumber (S (S (S Z))) =
  -- S_3(s) = 9s - 24s^2 + 16s^3
  addPolynumber (monomialPolynumber (intToBoxInt 9) 1)
                (addPolynumber (monomialPolynumber (intToBoxInt (-24)) 2)
                               (monomialPolynumber (intToBoxInt 16) 3))
spreadPolynumber (S (S (S (S Z)))) =
  -- S_4(s) = 16s - 112s^2 + 224s^3 - 128s^4
  addPolynumber (monomialPolynumber (intToBoxInt 16) 1)
                (addPolynumber (monomialPolynumber (intToBoxInt (-112)) 2)
                               (addPolynumber (monomialPolynumber (intToBoxInt 224) 3)
                                              (monomialPolynumber (intToBoxInt (-128)) 4)))
spreadPolynumber (S (S (S (S (S k))))) =
  -- For higher n, generate recursive step
  let sPrev1 = spreadPolynumber (S (S (S (S k))))
      sPrev2 = spreadPolynumber (S (S (S k)))
      factor = addPolynumber (constantPolynumber (intToBoxInt 2))
                             (monomialPolynumber (intToBoxInt (-4)) 1) -- 2(1 - 2s) = 2 - 4s
      term1  = mulPolynumber factor sPrev1
      term2  = sPrev2
      linearS = monomialPolynumber (intToBoxInt 2) 1 -- + 2s
  in addPolynumber (subPolynumber term1 term2) linearS

------------------------------------------------------------------------
-- 4. CYCLOTOMIC DIVISION & REMAINDER FOLDING ALGORITHM
------------------------------------------------------------------------

||| Discrete polynomial division fuel-bounded algorithm.
||| Computes (Quotient, Remainder) where Dividend = Quotient * Divisor + Remainder.
public export
divModPolyHelper : (fuel : Nat) -> Polynumber -> Polynumber -> Polynumber -> (Polynumber, Polynumber)
divModPolyHelper Z quotient remainder _ = (quotient, remainder)
divModPolyHelper (S fuel) quotient remainder divisor =
  let (remLeadCoeff, remLeadDeg) = leadingTerm remainder
      (divLeadCoeff, divLeadDeg) = leadingTerm divisor
  in if remLeadDeg < divLeadDeg || unwrapBox remLeadCoeff == 0 || unwrapBox divLeadCoeff == 0
       then (quotient, remainder)
       else
         let qCoeff = remLeadCoeff `div` divLeadCoeff
             qDeg   = minus remLeadDeg divLeadDeg
             stepTerm = monomialPolynumber qCoeff qDeg
             newQuotient = addPolynumber quotient stepTerm
             subtrahend  = mulPolynumber stepTerm divisor
             newRemainder = subPolynumber remainder subtrahend
         in divModPolyHelper fuel newQuotient newRemainder divisor

||| Exact discrete polynomial long division with remainder:
||| divModPolynumber P D = (Q, R) such that P = Q * D + R with deg(R) < deg(D).
public export
divModPolynumber : Polynumber -> Polynumber -> (Polynumber, Polynumber)
divModPolynumber dividend divisor = 
  let fuel = 1 + polynumberDegree dividend + polynumberDegree divisor
  in divModPolyHelper fuel zeroPolynumber (trimPolynumber dividend) (trimPolynumber divisor)

public export
divModPoly : BoxPolynomial -> BoxPolynomial -> (BoxPolynomial, BoxPolynomial)
divModPoly = divModPolynumber

------------------------------------------------------------------------
-- 5. GOH FACTORIZATION & LINEAR REDUCTION IN BOX ARITHMETIC
------------------------------------------------------------------------

||| Goh Linear Factor Step (Synthetic Box Division):
||| Divides P(x) by the linear box factor (x - r), producing quotient Q(x) and remainder P(r).
public export
gohPolynumberFactor : Polynumber -> BoxInt -> (Polynumber, BoxInt)
gohPolynumberFactor poly root = 
  let divisor = MkPolynumber [negate root, intToBoxInt 1] -- (x - r)
      (q, r) = divModPolynumber poly divisor
      remVal = evalPolynumber poly root
  in (q, remVal)

public export
gohLinearFactor : BoxPolynomial -> BoxInt -> (BoxPolynomial, BoxInt)
gohLinearFactor = gohPolynumberFactor

||| The 137th Cyclotomic Polynomial: Φ₁₃₇(x) = 1 + x + x² + ... + x¹³⁶ (137 unit stages).
public export
cyclotomic137Polynumber : Polynumber
cyclotomic137Polynumber = 
  MkPolynumber (replicate 137 (intToBoxInt 1))

public export
cyclotomic137 : BoxPolynomial
cyclotomic137 = cyclotomic137Polynumber

||| Folds an active epoch polynomial state by dividing by the cyclotomic period.
||| Returns (DarkEnergyQuotient, DarkMatterRemainder).
public export
foldEpochPolynumber : Polynumber -> Polynumber -> (Polynumber, Polynumber)
foldEpochPolynumber epochPoly divisorPoly = 
  divModPolynumber epochPoly divisorPoly

public export
foldEpochPolynomial : BoxPolynomial -> BoxPolynomial -> (BoxPolynomial, BoxPolynomial)
foldEpochPolynomial = foldEpochPolynumber

------------------------------------------------------------------------
-- 6. ELABORATOR REFLECTION MACROS FOR POLYS
------------------------------------------------------------------------

||| Generates the AST for a Polynumber literal from a list of integer coefficients.
public export
genPolyAST : List Integer -> TTImp
genPolyAST cs = 
  let mkBox = IVar emptyFC (UN $ Basic "intToBoxInt")
      boxInts = map (\c => IApp emptyFC mkBox (IPrimVal emptyFC (BI c))) cs
      boxList = foldr (\x, acc => IApp emptyFC (IApp emptyFC (IVar emptyFC (UN $ Basic "::")) x) acc)
                      (IVar emptyFC (UN $ Basic "Nil")) boxInts
      mkPoly = IVar emptyFC (UN $ Basic "MkPolynumber")
  in IApp emptyFC mkPoly boxList

||| Compile-time macro to generate a Polynumber AST directly from an integer list.
export
%macro
makePolynumber : List Integer -> Elab TTImp
makePolynumber cs = pure (genPolyAST cs)

export
%macro
makePolynomial : List Integer -> Elab TTImp
makePolynomial = makePolynumber
