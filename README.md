# Joint Expansion Planning of Distributed Generation and Distribution Networks

Implementation using JuMP of Distribution Expansion Planning Model proposed by Muñoz-Delgado et al. (2014).

Tested with CPLEX 22.1.0 and Gurobi 9.5.2

Reference:
>Muñoz-Delgado, G., Contreras, J., & Arroyo, J. M. (2014). Joint expansion planning of distributed generation and distribution networks. IEEE Transactions on Power Systems, 30(5), 2579-2590.
DOI: 10.1109/TPWRS.2014.2364960

## Changes

This implementation does not use an identical model proposed by the reference paper.
See [CHANGES.md](CHANGES.md) for more details.


## How to run

1. Install the dependencies (CPLEX or Gurobi, JuMP, CPLEX.jl or Gurobi.jl)

2. Run:
``` model
julia model.jl
```