# NCL.jl Tutorial

This tutorial shows how to solve a simple constrained nonlinear problem with
NCL.jl, and how to tune the main algorithm options.

## 1. Load Packages

```julia
using ADNLPModels
using NCL
using NLPModelsIpopt
```

`NLPModelsIpopt` activates the IPOPT extension used by NCL as an inner solver.

## 2. Define a Nonlinear Problem

We solve

$$
\begin{aligned}
\min_x &\; (x_1 - 1)^2 + (x_2 - 2)^2 \\
\\text{s.t.} &\; x_1 x_2 \le 1,
\end{aligned}
$$

with no explicit variable bounds.

```julia
f(x) = (x[1] - 1)^2 + (x[2] - 2)^2
c(x) = [x[1] * x[2] - 1]

nlp = ADNLPModel(
	f,
	[0.8, 1.2],      # initial point
	c,
	[-Inf],          # lower constraint bound
	[0.0],           # upper constraint bound
)
```

## 3. Solve with NCL

```julia
stats = NCLSolve(
	nlp;
	solver = :ipopt,
	opt_tol = 1.0e-6,
	feas_tol = 1.0e-6,
	max_iter_NCL = 30,
	verbose = true,
)
```

Inspect the solution:

```julia
stats.status
stats.solution
stats.objective
stats.primal_feas
stats.dual_feas
```

Residual variables from the final outer iteration are available in
`stats.solver_specific[:residuals]`.

## 4. Building the NCL Model Explicitly

If you need more control over the transformed problem, create `NCLModel`
directly:

```julia
ncl = NCLModel(
	nlp;
	resid = 0.0,          # initial residual value
	resid_linear = true,  # include residuals on linear constraints
	ρ = 1.0,              # initial penalty parameter
)

stats = NCLSolve(ncl; solver = :ipopt, verbose = false)
```

This is useful when experimenting with multiplier warm starts and penalty
updates.

## 5. Notes

- At least one supported inner solver extension must be loaded before calling
	`NCLSolve`.
- Use `solver = :ipopt` or `solver = :knitro` depending on the available backend.
- The returned stats object is reported on the original NLP variables, not on the
	augmented `(x, r)` vector.
