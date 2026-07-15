"""
    NCL

Implementation of [Algorithm NCL](https://dx.doi.org/10.1007/978-3-319-90026-1_8) (New Constrained Lagrangian)
for solving constrained nonlinear optimization problems of the form

    minimize   f(x)
    over       x
    subject to lvar ≤ x ≤ uvar
               lcon ≤ c(x) ≤ ucon

Algorithm NCL reformulates the problem by appending residual variables `r` to the decision variables and solving a sequence
of unconstrained (or bound-constrained) subproblems. The augmented objective is

    minimize   f(x) + y'r + (ρ/2) ‖r‖²
    over       x, r
    subject to lvar ≤ x ≤ uvar
               lcon ≤ c(x) + r ≤ ucon

where `y` is a vector of Lagrange multiplier estimates and `ρ > 0` is a penalty parameter.

## Main Interface

- [`NCLModel`](@ref): create an NCL subproblem model from any `AbstractNLPModel`.
- [`NCLSolve`](@ref): solve a constrained problem using Algorithm NCL.

## Subproblem Solvers

NCL delegates each subproblem to an interior-point solver via the [`AbstractNCLSubSolver`](@ref) interface.
Currently supported solvers (loaded via package extensions):

- [`IpoptNCLSubSolver`](@ref) — requires `NLPModelsIpopt.jl`
- [`KnitroNCLSubSolver`](@ref) — requires `KNITRO.jl` and `NLPModelsKnitro.jl`
- [`MadNLPNCLSubSolver`](@ref) — requires `MadNLP.jl`
"""
module NCL

using LinearAlgebra
using Printf

using NLPModels
using SolverCore

export IpoptNCLSubSolver
export KnitroNCLSubSolver
export MadNLPNCLSubSolver

include("NCLModel.jl")
include("NCLSolve.jl")

@doc (@doc AbstractNCLSubSolver) IpoptNCLSubSolver
"""
    IpoptNCLSubSolver(ncl_model::NCLModel; kwargs...)

Create an IPOPT-based subproblem solver for the NCL algorithm.

Requires `NLPModelsIpopt.jl` to be loaded. Only supports `Float64` models.

# Keyword arguments

- `dfeas_abs_tol::Float64 = 0.1`: absolute tolerance on dual feasibility;
- `pfeas_abs_tol::Float64 = 0.1`: absolute tolerance on primal feasibility;
- `compl_abs_tol::Float64 = 0.1`: absolute tolerance on complementarity.
"""
function IpoptNCLSubSolver(args...; kwargs...)
  error(
    "Ipopt support is not loaded. Install and load NLPModelsIpopt.jl in your environment to use IpoptNCLSubSolver.",
  )
end

@doc (@doc AbstractNCLSubSolver) KnitroNCLSubSolver
"""
    KnitroNCLSubSolver(ncl_model::NCLModel; kwargs...)

Create a KNITRO-based subproblem solver for the NCL algorithm.

Requires `KNITRO.jl` and `NLPModelsKnitro.jl` to be loaded. Only supports `Float64` models.
"""
function KnitroNCLSubSolver(args...; kwargs...)
  error(
    "Knitro support is not loaded. Install and load KNITRO.jl and NLPModelsKnitro.jl to use KnitroNCLSubSolver.",
  )
end

@doc (@doc AbstractNCLSubSolver) MadNLPNCLSubSolver
"""
    MadNLPNCLSubSolver(ncl_model::NCLModel; kwargs...)

Create a MadNLP-based subproblem solver for the NCL algorithm.

Requires `MadNLP.jl` to be loaded.
"""
function MadNLPNCLSubSolver(args...; kwargs...)
  error(
    "MadNLP support is not loaded. Install and load MadNLP.jl in your environment to use MadNLPNCLSubSolver.",
  )
end

end
