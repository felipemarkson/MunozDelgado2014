module testSys
import MunozDelgado2014
MD14 = MunozDelgado2014

using Test
using HiGHS
using JuMP

function test_primal(path; run=false)

    model = MD14.build_model(path, HiGHS.Optimizer)
    # JuMP.set_optimizer(model, ; add_bridges=false)
    set_optimizer_attribute(model, "mip_rel_gap", 1e-1)
    if run
        set_silent(model)
        optimize!(model)
        @test primal_status(model) == MOI.FEASIBLE_POINT
    end
    @test true
    return model
end

function test_primal_direct(path; run=false)

    model = MD14.build_model(path, HiGHS.Optimizer, is_direct=true)
    # JuMP.set_optimizer(model, ; add_bridges=false)
    set_optimizer_attribute(model, "mip_rel_gap", 1e-1)
    if run
        set_silent(model)
        optimize!(model)
        @test primal_status(model) == MOI.FEASIBLE_POINT
    end
    @test true
    return model
end

function test_investiment(model)
    values = JuMP.value.(model[:cᴵₜ])
    @info values
    for investment_cost in values
        @test investment_cost > 100.0
    end
end

function test_save_results(model, name)
    MD14.save_results(model, name)
end

function runtest()
    systems = Dict(
        "24bus_1" => "../dados/24bus_1stage",
        "24bus" => "../dados/24bus",
        # "138bus_1" => "../dados/138bus_1stage",
        # "138bus_4" => "../dados/138bus_4stages",
        # "138bus" => "../dados/138bus"
    )
    # systems = Dict(["24bus" => "../dados/24bus","24bus_1" => "../dados/24bus_1stage", "138bus" => "../dados/138bus", "138bus_4" => "../dados/138bus_4stages", "138bus_1" => "../dados/138bus_1stage"])
    to_solve = ["138bus_1", "24bus_1", "24bus"]
    for sys in keys(systems)
        @testset "$sys" begin
            run = sys in to_solve
            model = test_primal(systems[sys]; run=run)
            model2 = test_primal_direct(systems[sys]; run=run)
            if run
                test_save_results(model, sys)
                test_save_results(model2, sys)
                test_investiment(model)
            end
        end
    end

end
end


import .testSys

testSys.runtest()