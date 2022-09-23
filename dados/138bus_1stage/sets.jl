include("SystemData.jl")

# Sets of indexes
B = Vector(1:length(SystemData.load_factor))

T = [10]

L = ["EFF", "ERF", "NRF", "NAF"]

P = ["C", "W"]
D = ["C"]
RW = ["W"]

TR = ["ET", "NT"]

# Sets of alternatives

Kˡ = Dict("EFF" => [1], "ERF" => [1], "NRF" => [1, 2], "NAF" => [1, 2])

Kᵖ = Dict("C" => [1, 2], "W" => [1, 2])

Kᵗʳ = Dict("ET" => [1], "NT" => [1, 2])

# Sets of branches
γˡ = Dict("EFF" => [], "ERF" => [], "NRF" => [], "NAF" => [])

for branch_type in L
    for branch in SystemData.branch
        if branch[3] == branch_type
            s = branch[1][1]
            r = branch[1][2]
            push!(γˡ[branch_type], (s, r))
        end
    end
end
γˡ["NRF"] = γˡ["ERF"]


# Sets of nodes
Ωˢˢ = [136, 137, 138]
Ωˢˢᴱ = [136, 137] # Fixing eq14
Ωˢˢᴺ = [138] # Fixing eq14

Ωₛ = Dict([i => Set() for i = 1:SystemData.n_bus])
Ωˡₛ = Dict(
    "EFF" => [[] for i = 1:SystemData.n_bus],
    "ERF" => [[] for i = 1:SystemData.n_bus],
    "NRF" => [[] for i = 1:SystemData.n_bus],
    "NAF" => [[] for i = 1:SystemData.n_bus],
)
for branch_type in L
    branches = γˡ[branch_type]
    for (s, r) in branches
        push!(Ωˡₛ[branch_type][s], r)
        push!(Ωˡₛ[branch_type][r], s)
        push!(Ωₛ[s], r)
        push!(Ωₛ[r], s)
    end
end

Ωᴸᴺₜ = Dict()
for t in T
    push!(
        Ωᴸᴺₜ,
        t => [
            indx for (indx, value) in enumerate(SystemData.peak_demand[:, t]) if value > 0
        ],
    )
end


Ωᴺ = Vector(1:SystemData.n_bus)

Ωᵖ = Dict(
    "C" => [10, 28, 38, 53, 64, 94, 108, 117, 126, 133],
    "W" => [31, 52, 78, 94, 103, 113, 114, 116, 120, 122],
)
