```@meta
CurrentModule = NCL
```

# NCL

NCL.jl implements Algorithm NCL for nonlinear constrained optimization.

## What NCL Does

NCL transforms a constrained nonlinear problem into a sequence of subproblems by
adding residual variables and a penalty term. Each subproblem is solved with an
inner NLP solver (currently IPOPT or KNITRO through optional extensions).

Given

$$
\begin{aligned}
\min_x &\; f(x) \\
\\text{s.t.} &\; \ell_x \le x \le u_x, \\
&\; \ell_c \le c(x) \le u_c,
\end{aligned}
$$

NCL builds subproblems with residuals $r$ of the form

$$
\begin{aligned}
\min_{x,r} &\; f(x) + y^\top r + \frac{\rho}{2}\|r\|^2 \\
\\text{s.t.} &\; \ell_x \le x \le u_x, \\
&\; \ell_c \le c(x) + r \le u_c.
\end{aligned}
$$

## Installation

```julia
using Pkg
Pkg.add("NCL")
```

Install at least one inner solver backend:

```julia
# IPOPT backend
Pkg.add("NLPModelsIpopt")

# KNITRO backend
Pkg.add(["KNITRO", "NLPModelsKnitro"])
```

## Documentation Pages

- [Tutorial](tutorial.md): end-to-end example and solver options.
- [Reference](95-reference.md): autodocs for exported API.
