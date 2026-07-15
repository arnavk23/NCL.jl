# Tutorial

This tutorial walks through the basic usage of NCL.jl for solving constrained nonlinear optimization problems.

## Prerequisites

NCL.jl requires at least one interior-point subproblem solver. The most accessible option is IPOPT via `NLPModelsIpopt.jl`:

```julia
using Pkg
Pkg.add(["NCL", "NLPModelsIpopt", "ADNLPModels"])
```

## Example 1: Simple constrained problem

We solve the HS16 test problem from the Hock-Schittkowski collection:

minimize ``4x_1 - x_2^2`` subject to ``-x_1^2 + 2 \leq 0``, ``x_1^2 + x_2^2 - 10 \leq 0``, ``0 \leq x_1 \leq 3``, ``0 \leq x_2 \leq 2``.

```julia
using NCL
using NLPModelsIpopt
using OptimizationProblems

nlp = hs16()
stats = NCLSolve(nlp)
```

The solver prints a log at each outer iteration and returns a `GenericExecutionStats`:

```julia
stats.status    # :first_order
stats.solution  # optimal x ≈ [2.0, 1.0]
```

You can suppress the iteration log with `verbose = false`:

```julia
stats = NCLSolve(nlp; verbose = false)
```

## Example 2: Building a problem from scratch

You can define your own problem using `ADNLPModels.jl`:

```julia
using NCL
using NLPModelsIpopt
using ADNLPModels

# minimize x₁ + x₂
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
stats = NCLSolve(nlp; verbose = false)

stats.status    # :first_order
stats.solution  # optimal x
```

## Example 3: Using KNITRO or MadNLP

If you have KNITRO or MadNLP available, load the corresponding package and pass the sub-solver explicitly:

```julia
# With MadNLP
using MadNLP
sub = MadNLPNCLSubSolver(NCLModel(nlp))
stats = NCLSolve(nlp; subsolver = sub, verbose = false)

# With KNITRO
using KNITRO, NLPModelsKnitro
sub = KnitroNCLSubSolver(NCLModel(nlp))
stats = NCLSolve(nlp; subsolver = sub, verbose = false)
```

## Example 4: Working with AMPL models

NCL ships with several AMPL tax models in the `data/` directory. Load them with `AmplNLReader.jl`:

```julia
using NCL
using NLPModelsIpopt
using AmplNLReader

model = AmplModel(joinpath(path_to_ncl, "data", "tax1D.nl"))
stats = NCLSolve(model; verbose = false)
stats.status  # :first_order
```

## Example 5: Creating an NCLModel manually

If you want to inspect or customize the NCL transformation, you can create an `NCLModel` directly:

```julia
using NCL
using NLPModelsIpopt
using OptimizationProblems

nlp = hs16()
ncl = NCLModel(nlp)

# The NCL model has more variables than the original:
NLPModels.get_nvar(ncl)  # nx + nr
NLPModels.get_nvar(nlp)  # nx

# You can then solve the NCL model directly:
stats = NCLSolve(ncl; verbose = false)
```

### Residual modes

By default, residuals are appended to all constraints (`resid_linear = true`). To add residuals only to nonlinear constraints:

```julia
ncl = NCLModel(nlp; resid_linear = false)
```

This is useful when the problem has linear constraints that can be handled directly by the subproblem solver.

### Tuning parameters

You can control the initial penalty parameter and Lagrange multipliers:

```julia
ncl = NCLModel(nlp; ρ = 100.0, y = zeros(get_ncon(nlp)))
```

## Tuning the solver

The outer NCL loop has a few key parameters:

```julia
stats = NCLSolve(nlp;
  opt_tol = 1e-6,       # dual feasibility tolerance
  feas_tol = 1e-6,      # primal feasibility tolerance
  max_iter_NCL = 30,    # maximum outer iterations
  verbose = false,
)
```

## Inspecting results

The returned `GenericExecutionStats` contains:

```julia
stats.status          # :first_order, :infeasible, or :max_iter
stats.solution        # optimal x (original variables only)
stats.multipliers     # Lagrange multiplier estimates y
stats.objective       # objective value f(x)
stats.iter            # total inner iterations across all outer iterations
stats.elapsed_time    # total solve time
stats.solver_specific[:residuals]  # final residual vector r
```

When the problem has bound multipliers, they are accessible via:

```julia
stats.multipliers_L   # lower bound multipliers zL
stats.multipliers_U   # upper bound multipliers zU
```
