module testSys
import MunozDelgado2014
MD14 = MunozDelgado2014

using Test
using HiGHS
using JuMP

function test_primal(path; run=false)

    model = MD14.build_model(path)
    JuMP.set_optimizer(model, HiGHS.Optimizer; add_bridges=false)
    set_optimizer_attribute(model, "mip_rel_gap", 1e-1)
    if run
        set_silent(model)
        optimize!(model)
        @test primal_status(model) == MOI.FEASIBLE_POINT
    end
    @test true
    return model
end

function test_save_results(model, name)
    MD14.save_results(model, name)
end

function runtest()
    systems = Dict(
        "24bus_1" => "../dados/24bus_1stage",
        "24bus" => "../dados/24bus",
        "138bus_1" => "../dados/138bus_1stage",
        "138bus_4" => "../dados/138bus_4stages",
        "138bus" => "../dados/138bus")
    # systems = Dict(["24bus" => "../dados/24bus","24bus_1" => "../dados/24bus_1stage", "138bus" => "../dados/138bus", "138bus_4" => "../dados/138bus_4stages", "138bus_1" => "../dados/138bus_1stage"])
    to_solve = ["138bus_1", "24bus_1"]
    for sys in keys(systems)
        @testset "$sys" begin
            run = sys in to_solve
            model = test_primal(systems[sys]; run=run)
            if run
                test_save_results(model, sys)
            end
        end
    end

end
end


import .testSys

testSys.runtest()