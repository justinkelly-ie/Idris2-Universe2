# 🌌 Idris2-Universe2

**A Constructive, Finitist Model of the Universe Bootstrapped via Elaborator Reflection and Quantitative Type Theory (QTT) in [Idris 2](https://github.com/idris-lang/Idris2).**

[![Idris2](https://img.shields.io/badge/Idris2-QTT_Reflection-blue.svg)](https://github.com/idris-lang/Idris2)
[![Finitism](https://img.shields.io/badge/Finitism-Wildberger_Boxes-purple.svg)]()
[![Cosmology](https://img.shields.io/badge/Epochs-Genesis_to_37-green.svg)]()

---

## 🏛️ Overview

`Idris2-Universe2` represents the next evolutionary leap of the [Finite-Science](https://github.com/justinkelly-ie/Finite-Science) cosmological framework. 

While continuous modeling and numerical simulations are foundational across computational physics, `Idris2-Universe2` explores a complementary, discrete-constructive paradigm centered around a **self-compiling, dynamically dimensioned, and scale-invariant multiset architecture**:

1. **The Universal Mapping**: Dependent Types model physical laws, QTT Multiplicity `1` enforces thermodynamic conservation, Type Erasure `0` drops cosmic scaffolding, and Elaborator Reflection (`%runElab`) acts as a second-order cybernetic feedback engine.
2. **Numbers as Physical Containers**: Natural numbers, multisets, and polynumbers are constructed purely as inductive tallies of empty boxes (`BoxSpec`, `Polynumber`, `WildNat`).
3. **Unixels, Pixels, Voxels, Vexels, Maxels & Boxels**: Replaces rigid coordinate tensors with Wildberger's multiset linear algebra hierarchy (`Unixel` $[n]$, `Pixel` $[i, j]$, `Voxel` $[x, y, z]$, `Vexel` 1D, `Maxel` 2D, `Boxel` 3D).
4. **The 27-State Ternary Spacetime Multiverse**: Instead of assuming a single pre-selected geometry, the framework constructs a 2D metric multiset using discrete values $\{-1, 0, 1\}$ across its 3 independent components. This generates an exhaustive $3^3 = 27$ state manifold, categorizing all possible spacetime geometries into Elliptic, Hyperbolic, Parabolic, and Substrate sectors.
5. **Dynamic `UniverseState`**: Tracks dimensions as dependent types derived dynamically from prior epoch states.
6. **Bootstrapping Epoch 1 to 37**: Simulates lattice expansion ($1\times 1 \to 2\times 2 \to 3\times 3$), 137-stage cycles, and contraction/folding where Dark Matter acts as the accumulated historical error ledger ($55 \to 56$ states).
7. **Nilpotent Kinematics & Lensing**: Directional velocity tokens ($\epsilon = \begin{pmatrix}0&1\\0&0\end{pmatrix}, \epsilon^2 = 0$) routed through symmetric $g_{\text{EM}}$ and asymmetric $g_{\text{Substrate}}$ Maxels with inductive drag from Dark Matter residues.
8. **Grassmann Exterior Calculus & Yang-Mills Gauge Theory**: Full 3D discrete coboundary operators ($d_0, d_1, d_2$), combinatorial Hodge duality ($\star$), exact Bianchi closure ($d_2(d_1 A) = 0$), and Dihedron non-Abelian color flux confinement.
9. **Edwin Brady Protocol Channels & Galois Adjunction ($f_* \dashv f^*$)**: State evolution modeled as a linear QTT protocol channel (`PhysicsChannel`) indexed by reflected `Polynumber` generating functions ($P(x) = \sum c_k x^k$), driven by the 137-stage natural clock tick ($N_{\text{cycle}} = 137$) and a pure algebraic Galois Connection ($f_* \dashv f^*$) between contraction ($f_*$) and expansion ($f^*$).

---

## 📁 Module Organization

| Module | Description |
|---|---|
| [`Core.BoxInt`](src/Core/BoxInt.idr) | Box arithmetic wrapper for exact signed integer scalars. |
| [`Core.Multiset`](src/Core/Multiset.idr) | Type-indexed inductive multisets and reflected Box Arithmetic. |
| [`Core.Polynumber`](src/Core/Polynumber.idr) | Nested polynumber multisets, Spread Polynumbers $S_n(s)$, Goh Factorization, and cyclotomic division. |
| [`Core.VexelMaxel`](src/Core/VexelMaxel.idr) | Unixels, Pixels, Voxels, Vexels (1D), Maxels (2D), and Boxels (3D volume tensors). |
| [`Math.Infinitesimal`](src/Math/Infinitesimal.idr) | Nilpotent dual number matrix ($\epsilon^2 = 0$) for exact discrete calculus. |
| [`Math.QuantumTransition`](src/Math/QuantumTransition.idr) | Discrete quantum state vectors, unitary S-matrices, Born probability conservation, and Wilson loop holonomies. |
| [`Math.WilsonPolyhedra`](src/Math/WilsonPolyhedra.idr) | 3D Wilson Polyhedra cubic holonomies, non-Abelian $\mathrm{SU}(3)$ color flux coupling, and discrete Bianchi closure. |
| [`Math.FourGeometries`](src/Math/FourGeometries.idr) | The 4 Fundamental Geometries: Elliptic (Confinement), Hyperbolic (Phase), Parabolic (Dissipation), and Substrate (Causality). |
| [`Math.LawAlgebra`](src/Math/LawAlgebra.idr) | Typed Law Algebra Monoid ($\wedge, \otimes$), multiset pushforward ($f_*$), inverse image pullback ($f^*$), and pure algebraic Galois Connection ($f_* \dashv f^*$). |
| [`Math.DiscreteActionPrinciple`](src/Math/DiscreteActionPrinciple.idr) | Law 1: The Discrete Principle of Least Action, Euler-Lagrange equations, and Substrate causal arrow asymmetry. |
| [`Math.DiscreteBoltzmannDistribution`](src/Math/DiscreteBoltzmannDistribution.idr) | Law 2: The Discrete Boltzmann Distribution, sector partition functions ($Z$), and ground-state collapse. |
| [`Math.RationalTrig`](src/Math/RationalTrig.idr) | Rational Trigonometry: Quadrance, Spread, Cross, and Archimedes' Function. |
| [`Math.FineStructure`](src/Math/FineStructure.idr) | Pure constructivist derivation of $\alpha^{-1} = 137$. |
| [`Math.LinAlgebra.MetricTensor`](src/Math/LinAlgebra/MetricTensor.idr) | Rational Maxel metrics with BoxInt entries and discriminant classification. |
| [`Math.LinAlgebra.TernaryClassifier`](src/Math/LinAlgebra/TernaryClassifier.idr) | Permutation of $\{-1, 0, 1\}$ into all 27 canonical spacetime Maxel metrics. |
| [`Math.LinAlgebra.BilinearProduct`](src/Math/LinAlgebra/BilinearProduct.idr) | Bilinear inner product ($ds^2$) over infinitesimal dual complex vectors and Maxels. |
| [`Geometry.LatticeTopology`](src/Geometry/LatticeTopology.idr) | 3D coordinate bijections, toroidal 6-face neighbors, and Laplacian flux conservation. |
| [`Geometry.GrassmannCalculus`](src/Geometry/GrassmannCalculus.idr) | Grassmann cochains ($C_0, C_1, C_2, C_3$), coboundaries, Hodge duality, and Yang-Mills. |
| [`Geometry.InformationGeometry`](src/Geometry/InformationGeometry.idr) | Hyperbolic geodesic Stern-Brocot bit duality, Clifford mutual information, and Yang-Mills plaquette cross-entropy. |
| [`Compound.HadronicConfinement`](src/Compound/HadronicConfinement.idr) | Triadic Chromogeometry, color charges, and color-neutral nucleon singlets. |
| [`Compound.PlasmaRecombination`](src/Compound/PlasmaRecombination.idr) | Phase 3 plasma recombination, proton-electron binding, and photon decoupling. |
| [`Compound.AlphaReplication`](src/Compound/AlphaReplication.idr) | 4-nucleon hierarchical tetrahedral clustering into a 108-voxel $^4\text{He}$ core. |
| [`Compound.StellarNucleosynthesis`](src/Compound/StellarNucleosynthesis.idr) | Phase 4 Triple-Alpha Carbon fusion ($3\alpha \to {}^{12}\text{C}$) and Phosphorus ($Z=15$) synthesis. |
| [`Compound.MolecularBonding`](src/Compound/MolecularBonding.idr) | Chemical graph representation, covalent bond Maxels, Water quadrea ($A=3$), and alkane homologous saturation. |
| [`Compound.HydrogenBonding`](src/Compound/HydrogenBonding.idr) | Phase 5 non-covalent Hydrogen bonding Maxels, liquid water percolation, and ice network. |
| [`Compound.WatsonCrickBasePairing`](src/Compound/WatsonCrickBasePairing.idr) | Phase 6 & 7 high-energy polyphosphate ATP coupling and Watson-Crick A-T (2 H-bonds) / G-C (3 H-bonds) pairing. |
| [`Compound.MacromolecularChirality`](src/Compound/MacromolecularChirality.idr) | Tier 6 Macromolecules, amino acid stereocenters, peptide condensation, and L-homochirality selection. |
| [`Evolution.State`](src/Evolution/State.idr) | Universe state $(vm, de, dm)$ dependent vectors, linear QTT vector splits/combines, and token relocation. |
| [`Evolution.Init`](src/Evolution/Init.idr) | Dynamic vacuum seed initializer (`seedEvolutionaryVacuum`) for Epoch 1. |
| [`Evolution.Expansion`](src/Evolution/Expansion.idr) | Generalized grid expansion into pure Maxels and outer product tensor inflation. |
| [`Evolution.Contraction`](src/Evolution/Contraction.idr) | Multi-epoch collapse and folding (`contractAndFoldGeneric`). |
| [`Evolution.Bootstrap`](src/Evolution/Bootstrap.idr) | Master bootstrap pipeline scaling from Epoch 1 through Epoch 37. |
| [`Evolution.ProtocolChannel`](src/Evolution/ProtocolChannel.idr) | Edwin Brady Linear Protocol Channels (`PhysicsChannel`) parameterized by Polynumber generating functions and 137-stage clock ticks. |
| [`Evolution.StructuralAccounting`](src/Evolution/StructuralAccounting.idr) | Structural summation loops for non-cast integer vectors. |
| [`Derivation.PureGeometricClassifier`](src/Derivation/PureGeometricClassifier.idr) | Relational inference of metric coordinates from internal memory density ratios. |
| [`Compound.LinearEpsilonRouting`](src/Compound/LinearEpsilonRouting.idr) | Kinematic velocity routing across symmetric $g_{\text{EM}}$ vs asymmetric $g_{\text{Substrate}}$ Maxels. |
| [`Compound.VelocityLensing`](src/Compound/VelocityLensing.idr) | Dark Matter inductive drag and gravitational deflection across scale jumps. |
| [`Compound.SymplecticIntegrator`](src/Compound/SymplecticIntegrator.idr) | Discrete symplectic Leapfrog integrator and phase space Hamiltonian flow. |
| [`Math.CliffordAlgebra`](src/Math/CliffordAlgebra.idr) | Multiset Geometric Clifford Algebra, Multivectors, and Spinor reflections. |
| [`Reflect.PermutationSolver`](src/Reflect/PermutationSolver.idr) | Constructive $S_n$ swap factorization, permutation Maxels, and Young Tableaux Hook-Length. |
| [`Reflect.InvariantAuditor`](src/Reflect/InvariantAuditor.idr) | Elaborator reflection macros verifying all cosmic invariants statically at compile-time. |

---

## 🛠️ Companion Wiki

Comprehensive literate documentation, proofs, and the executable verification matrix are available in [`Idris2-Universe2-Wiki`](../Idris2-Universe2-Wiki).

---

© Justin Kelly. All rights reserved.
