import JuMP
# import CPLEX
import Gurobi
import MunozDelgado2014
MD14 = MunozDelgado2014;


opt = JuMP.optimizer_with_attributes(Gurobi.Optimizer)


JuMP.set_optimizer(model, opt)
JuMP.write_to_file(model, "model.mps")
JuMP.write_to_file(model, "model.lp")
JuMP.set_optimizer_attribute(model, "mip_rel_gap", 1e-1)
# JuMP.set_optimizer_attribute(model, "MIPGapAbs", 1e2)
JuMP.optimize!(model)
if JuMP.termination_status(model) != JuMP.MOI.OPTIMAL
    error("Not Optimal")
end
save_results(model)
    


name = "24bus"
main(name)