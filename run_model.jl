import JuMP
# import CPLEX
import Gurobi
opt = JuMP.optimizer_with_attributes(Gurobi.Optimizer,
)
name = "138bus_4stages"
include("model.jl")

# JuMP.write_to_file(model, "model.mps")
# JuMP.set_silent(model)
JuMP.optimize!(model)
if JuMP.termination_status(model) != JuMP.MOI.OPTIMAL
    error("Not Optimal")
end

include("save_results.jl")