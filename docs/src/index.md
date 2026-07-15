```@meta
CurrentModule = NCL
```

# NCL.jl

An implementation of [Algorithm NCL](https://dx.doi.org/10.1007/978-3-319-90026-1_8) (New Constrained Lagrangian) in Julia for solving constrained nonlinear optimization problems.

## Problem formulation

NCL solves problems of the form

```math
\begin{aligned}
\min_{x} \quad & f(x) \\
\text{s.t.} \quad & \ell_x \leq x \leq u_x \\
& \ell_c \leq c(x) \leq u_c
\end{aligned}
```

where ``f`` is the objective function and ``c(x)`` represents nonlinear (and optionally linear) constraints.

## How it works

Algorithm NCL reformulates the problem by appending slack (residual) variables ``r`` to the decision variables:

```math
\begin{aligned}
\min_{x,r} \quad & f(x) + y^T r + \frac{\rho}{2} \|r\|^2 \\
\text{s.t.} \quad & \ell_x \leq x \leq u_x \\
& \ell_c \leq c(x) + r \leq u_c
\end{aligned}
```

This transformation makes the constraints always satisfiable (by choosing ``r`` appropriately), and the problem can be solved as a sequence of bound-constrained subproblems using interior-point methods. The algorithm iterates between:

1. **Solving the subproblem** using an interior-point solver (IPOPT, KNITRO, or MadNLP);
2. **Updating Lagrange multipliers** ``y \leftarrow y + \rho\,r`` when the residual is sufficiently small;
3. **Increasing the penalty** ``\rho`` when the residual is not decreasing.

Convergence is declared when both the primal residual ``\|r\|_\infty`` and the dual feasibility residual are below specified tolerances.

## Installation

```julia
using Pkg
Pkg.add("NCL")
```

## Quick start

```julia
using NCL
using NLPModelsIpopt  # for IpoptNCLSubSolver
using ADNLPModels

# Define: minimize x₁ + x₂
#   s.t.  x₁² + x₂ ≥ 1
#         x₁·x₂ ≤ 0.5
#         0 ≤ xᵢ ≤ 1
f(x) = x[1] + x[2]
x0 = [0.5, 0.5]
lvar = [0.0, 0.0]
uvar = [1.0, 1.0]
c(x) = [x[1]^2 + x[2], x[1] * x[2]]
lcon = [1.0, -Inf]
ucon = [Inf, 0.5]

nlp = ADNLPModel(f, x0, lvar, uvar, c, lcon, ucon)

stats = NCLSolve(nlp)
stats.status    # :first_order
stats.solution  # optimal x
```

## Subproblem solvers

NCL uses Julia's package extension system to support multiple interior-point solvers. Load the appropriate package to enable a solver:

| Solver | Package(s) to load | Sub-solver type |
|--------|--------------------|-----------------|
| [IPOPT](https://coin-or.github.io/Ipopt) | `NLPModelsIpopt` | [`IpoptNCLSubSolver`](@ref) |
| [Artelys KNITRO](https://www.artelys.com/knitro) | `KNITRO` + `NLPModelsKnitro` | [`KnitroNCLSubSolver`](@ref) |
| [MadNLP](https://github.com/MadNLP/MadNLP.jl) | `MadNLP` | [`MadNLPNCLSubSolver`](@ref) |

## Data files

The `data/` directory contains several tax policy optimization models in [AMPL](http://www.ampl.com) format (`.mod` and `.nl` files). These can be loaded with [AmplNLReader.jl](https://github.com/JuliaSmoothOptimizers/AmplNLReader.jl).

## References

- Ma, D., Judd, K., Orban, D., & Saunders, M. (2018). [Stabilized optimization via an NCL algorithm](https://dx.doi.org/10.1007/978-3-319-90026-1_8).
- Ma, D., Orban, D., & Saunders, M.A. (2021). [A Julia Implementation of Algorithm NCL for Constrained Optimization](https://doi.org/10.1007/978-3-030-72040-7_8).
- Ma, D., Orban, D. & Saunders, M.A. (2025). [Solving Algorithm NCL's Subproblems: The Need for Interior Methods](https://doi.org/10.1007/s10013-025-00760-z).
