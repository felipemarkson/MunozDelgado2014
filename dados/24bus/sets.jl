include("SystemData.jl")

# Conjuntos de indices e tipos
B = Vector(1:length(SystemData.load_factor))

T = Vector(1:size(SystemData.peak_demand)[2])

L = ["EFF", "ERF", "NRF", "NAF"]

P = ["C", "W"]

TR = ["ET", "NT"]

# Conjuntos de Alternativas

Kˡ = Dict("EFF" => [1], "ERF" => [1], "NRF" => [1, 2], "NAF" => [1, 2])

Kᵖ = Dict("C" => [1, 2], "W" => [1, 2])

Kᵗʳ = Dict("ET" => [1], "NT" => [1, 2])

# Conjuntos de ramos
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


# Conjuntos de barras
Ωˢˢ = [21, 22, 24, 23]
Ωˢˢᴱ = [21, 22] # Adicionado
Ωˢˢᴺ = [23, 24] # Adicionado

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
    end
end

Ωᴸᴺₜ = Dict(
    1 => [
        indx
        for
        (indx, value) in enumerate(SystemData.peak_demand[:, 1]) if value > 0
    ],
    2 => [
        indx
        for
        (indx, value) in enumerate(SystemData.peak_demand[:, 2]) if value > 0
    ],
    3 => [
        indx
        for
        (indx, value) in enumerate(SystemData.peak_demand[:, 3]) if value > 0
    ],
)

Ωᴺ = Vector(1:SystemData.n_bus)

Ωᵖ = Dict(
    "C" => [2, 3, 7, 13, 15, 16, 17, 20],
    "W" => [1, 4, 5, 9, 15, 17, 18, 19],
)
