module test24bus
import MunozDelgado2014
MD14 = MunozDelgado2014

using Test
using HiGHS
using JuMP

function test_primal()
    path = "../dados/24bus_1stage"
    model = MD14.build_model(path)
    JuMP.set_optimizer(model, HiGHS.Optimizer)
    set_optimizer_attribute(model, "mip_rel_gap", 1e-1)
    set_silent(model)
    optimize!(model)
    @test primal_status(model) == MOI.FEASIBLE_POINT
    return model
end

function test_save_results(model)
    MD14.save_results(model, "24bus")
end

function runtest()
    model = test_primal()
    test_save_results(model)

end    
end


import .test24bus

test24bus.runtest()