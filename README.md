# 🌌 Idris2-Universe2

**A Constructive, Finitist Model of the Universe Bootstrapped via Elaborator Reflection and Quantitative Type Theory (QTT) in [Idris 2](https://github.com/idris-lang/Idris2).**

[![Idris2](https://img.shields.io/badge/Idris2-QTT_Reflection-blue.svg)](https://github.com/idris-lang/Idris2)
[![Finitism](https://img.shields.io/badge/Finitism-Wildberger_Boxes-purple.svg)]()
[![Cosmology](https://img.shields.io/badge/Epochs-Genesis_to_37-green.svg)]()

---

## 🏛️ Overview

`Idris2-Universe2` represents the next evolutionary leap of the [Finite-Science](https://github.com/justinkelly-ie/Finite-Science) cosmological framework. 

Traditional computational physics relies on hardcoded dimensions, fixed background metric assertions, and continuous approximations. `Idris2-Universe2` replaces these assumptions with a **self-compiling, un-hardcoded, and scale-invariant architecture**:

1. **The Universal Mapping**: Dependent Types model physical laws, QTT Multiplicity `1` enforces thermodynamic conservation, Type Erasure `0` drops cosmic scaffolding, and Elaborator Reflection (`%runElab`) acts as a second-order cybernetic feedback engine.
2. **Numbers as Physical Containers**: Natural numbers, multisets, and polynumbers are constructed purely as inductive tallies of empty boxes (`MSetSpec`, `Polynumber`, `WildNat`).
3. **The 27-State Ternary Spacetime Multiverse**: Replaces arbitrary pre-declared geometries by permuting the fundamental 3-bit alphabet $\{-1, 0, 1\}$ (Identity, Presence, Parity) across a symmetric $2\times 2$ metric tensor.
4. **Dynamic `UniverseState`**: Eliminates magic numbers (`27`, `128`, `55`) by tracking dimensions as dependent parameters derived dynamically from prior epoch states.
5. **Bootstrapping Epoch 1 to 37**: Simulates lattice expansion ($1\times 1 \to 2\times 2 \to 3\times 3$), 137-stage cycles, and contraction/folding where Dark Matter acts as the accumulated historical error ledger ($55 \to 56$ states).
6. **Nilpotent Kinematics & Lensing**: Directional velocity tokens ($\epsilon = \begin{pmatrix}0&1\\0&0\end{pmatrix}, \epsilon^2 = 0$) routed through symmetric $g_{\text{EM}}$ and asymmetric $g_{\text{Substrate}}$ with inductive drag from Dark Matter residues.

---

## 📁 Module Organization

| Module | Description |
|---|---|
| [`Core.BoxInt`](src/Core/BoxInt.idr) | Box arithmetic wrapper for exact signed integer scalars. |
| [`Core.Multiset`](src/Core/Multiset.idr) | Type-indexed inductive multisets and reflected Box Arithmetic. |
| [`Core.QTT`](src/Core/QTT.idr) | Quantitative Type Theory resource conservation combinators. |
| [`Math.Infinitesimal`](src/Math/Infinitesimal.idr) | Nilpotent dual number matrix ($\epsilon^2 = 0$) for exact discrete calculus. |
| [`Math.LinAlgebra.MetricTensor`](src/Math/LinAlgebra/MetricTensor.idr) | 2x2 rational metric tensor with BoxInt entries and discriminant classification. |
| [`Math.LinAlgebra.TernaryClassifier`](src/Math/LinAlgebra/TernaryClassifier.idr) | Permutation of $\{-1, 0, 1\}$ into all 27 canonical spacetime metrics. |
| [`Math.LinAlgebra.BilinearProduct`](src/Math/LinAlgebra/BilinearProduct.idr) | Bilinear inner product ($ds^2$) over infinitesimal dual complex vectors. |
| [`Evolution.State`](src/Evolution/State.idr) | Un-hardcoded `UniverseState vmSize deSize dmSize` record. |
| [`Evolution.Init`](src/Evolution/Init.idr) | Dynamic vacuum seed initializer (`seedEvolutionaryVacuum`) for Epoch 1. |
| [`Evolution.Expansion`](src/Evolution/Expansion.idr) | Generalized grid expansion ($1\times 1 \to 2\times 2 \to 3\times 3 \to \dots$). |
| [`Evolution.Contraction`](src/Evolution/Contraction.idr) | Multi-epoch collapse and folding (`contractAndFoldGeneric`). |
| [`Evolution.Bootstrap`](src/Evolution/Bootstrap.idr) | Master bootstrap pipeline scaling from Epoch 1 through Epoch 37. |
| [`Derivation.PureGeometricClassifier`](src/Derivation/PureGeometricClassifier.idr) | Relational inference of metric coordinates from internal memory density ratios. |
| [`Compound.LinearEpsilonRouting`](src/Compound/LinearEpsilonRouting.idr) | Kinematic velocity routing across symmetric $g_{\text{EM}}$ vs asymmetric $g_{\text{Substrate}}$. |
| [`Compound.VelocityLensing`](src/Compound/VelocityLensing.idr) | Dark Matter inductive drag and gravitational deflection across scale jumps. |
| [`Reflect.PermutationSolver`](src/Reflect/PermutationSolver.idr) | Reflection macros for automated multiset swap-chain proof generation. |
| [`Reflect.InvariantAuditor`](src/Reflect/InvariantAuditor.idr) | Compile-time thermodynamic, closure, and causality auditors. |

---

## 🛠️ Companion Wiki

Comprehensive literate documentation, proofs, and the executable verification matrix are available in [`Idris2-Universe2-Wiki`](../Idris2-Universe2-Wiki).

---

© Justin Kelly. All rights reserved.
