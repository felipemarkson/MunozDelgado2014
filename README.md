# Joint Expansion Planning of Distributed Generation and Distribution Networks

Implementation using JuMP of Distribution Expansion Planning Model proposed by Muñoz-Delgado et al. (2014).

Tested with HiGHS v1.2.2

Reference:
>Muñoz-Delgado, G., Contreras, J., & Arroyo, J. M. (2014). Joint expansion planning of distributed generation and distribution networks. IEEE Transactions on Power Systems, 30(5), 2579-2590.
DOI: 10.1109/TPWRS.2014.2364960

## Changes

This implementation does not use an identical model proposed by the reference paper.
See [CHANGES.md](CHANGES.md) for more details.


## Quick start

```julia
using JuMP
using HiGHS # This package can be replaced by any other MILP with JuMP interface
import MunozDelgado2014
MD14 = MunozDelgado2014

optimizer =  HiGHS.Optimizer

path = "path/to/data/folder" # See the folder "dados"
model = MD14.build_model(path, optimizer; is_direct=true)
optimize!(model)

MD14.save_results(model, "path/to/results/folder")
```