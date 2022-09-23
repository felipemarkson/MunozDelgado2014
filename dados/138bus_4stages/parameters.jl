include("sets.jl")
include("wind.jl")

#Energy Costs
Cᴱᵖₖ = Dict("C" => [47, 45], "W" => [0, 0])

Cˢˢᵦ = [57.7, 70, 85.3]

Cᵁ = 20000 # This value was changed because 1% gap can present unserved energ

#Investment Costs
Cᴵˡₖ = Dict("NRF" => [29870, 39310], "NAF" => [25030, 34920])

Cᴵᴺᵀₖ = [500e3, 950e3]

Cᴵᵖₖ = Dict("C" => [500e3, 490e3], "W" => [1850e3, 1840e3])

Cᴵˢˢₛ = Dict(136 => 100e3, 137 => 100e3, 138 => 150e3)

#Maintenance Costs
Cᴹˡₖ = Dict(
    "EFF" => [450],
    "ERF" => [450],
    "NRF" => [450, 450],
    "NAF" => [450, 450],
)

Cᴹᵖₖ = Dict( #0.05*Cᴵᵖₖ*Gᵖₖ
    "C" => [22.5e3, 44.1e3],
    "W" => [75757.5, 169740],
)


Cᴹᵗʳₖ = Dict( #0.05*Cᴵᵖₖ*Gᵖₖ
    "ET" => [2000],
    "NT" => [1000, 3000],
)

# System's Data

Dₛₜ = SystemData.peak_demand

D̃ₛₜ = Dict([s => Dict([t => 0.0 for t in T]) for s in Ωᴺ])

D̃ = 0.1
Mᴰ = 1e6
for s in Ωᴺ
    for t in T
        if s in Ωᴸᴺₜ[t]
            D̃ₛₜ[s][t] = D̃
        else
            D̃ₛₜ[s][t] = 0
        end
    end
end

F̅ˡₖ = Dict(
    "EFF" => [6.28],
    "ERF" => [6.28],
    "NRF" => [9, 12],
    "NAF" => [6.28, 9],
)

G̅ᴰₚₖ = Dict("C" => [1, 2])
G̅ᴿᵂₚₖ = Dict("W" => [0.91, 2.05])

# Ĝᵂₛₖₜᵦ = zeros(length(Ωᴺ), length(Kᵖ["W"]), length(T), length(B))
Ĝᴿᵂₚₛₖₜᵦ =
    Dict([p =>
        Dict([s =>
            Dict([k =>
                Dict([t =>
                    Dict([b => 0.0
                          for b in B])
                      for t in T])
                  for k in Kᵖ["W"]])
              for s in Ωᴺ])
          for p in RW])
# begin
#     # Ref: https://wind-turbine.com/download/101655/enercon_produkt_en_06_2015.pdf
#     wᵢ = [4.0, 3.0]
#     Pᵢ = [0.02, 0.025]
#     wᵣ = [15, 12]
#     Pᵣ = G̅ᵖₖ["W"]
#
#     for s = Ωᴺ
#         for k in Kᵖ["W"]
#             for t in T
#                 for b in B
#                     zone = SystemData.node_zone[s]
#                     speed = SystemData.wind_speed[zone, b]
#                     Ĝᵂₛₖₜᵦ[s, k, t, b] =
#                         power_out(wᵢ[k], wᵣ[k], Pᵢ[k], Pᵣ[k], speed)
#                 end
#             end
#         end
#     end
# end

# Version 2
begin
    # Ref: https://wind-turbine.com/download/101655/enercon_produkt_en_06_2015.pdf
    for s = Ωᴺ
        for k in Kᵖ["W"]
            for t in T
                for b in B
                    zone = SystemData.node_zone[s]
                    speed = SystemData.wind_speed[zone, b]
                    Ĝᴿᵂₚₛₖₜᵦ["W"][s][k][t][b] = power_out_v2(k, speed)
                end
            end
        end
    end
end

G̅ᵗʳₖ = Dict("ET" => [12], "NT" => [7.5, 15])

Vbase = 13.8 #kV
V_ = 0.95 * Vbase
V̅ = 1.05 * Vbase
Vˢˢ = 1.05 * Vbase

ℓₛᵣ = zeros(length(Ωᴺ), length(Ωᴺ))
for branch in SystemData.branch
    (s, r) = branch[1]
    ℓₛᵣ[s, r] = branch[2]
    ℓₛᵣ[r, s] = branch[2]
end

ndg = reduce(+, [length(Ωᵖ[p]) for p in P])

nT = length(T)

pf = 0.9

H = V̅ - V_  #Ref: DOI: 10.1109/TPWRS.2017.2764331

# Assets Data
i = 7.1 / 100

IBₜ = Dict([t => 5e6 for t in T])

ηˡ = Dict(
    "NRF" => 25,
    "NAF" => 25
)

ηᴺᵀ = 15

ηᵖ = Dict(
    "C" => 20,
    "W" => 20
)

ηˢˢ = 100

RRˡ = Dict(
    "NRF" => (i * (1 + i)^ηˡ["NRF"]) / ((1 + i)^ηˡ["NRF"] - 1),
    "NAF" => (i * (1 + i)^ηˡ["NAF"]) / ((1 + i)^ηˡ["NAF"] - 1)
)

RRᴺᵀ = (i * (1 + i)^ηᴺᵀ) / ((1 + i)^ηᴺᵀ - 1)

RRᵖ = Dict(
    "C" => (i * (1 + i)^ηᵖ["C"]) / ((1 + i)^ηᵖ["C"] - 1),
    "W" => (i * (1 + i)^ηᵖ["W"]) / ((1 + i)^ηᵖ["W"] - 1)
)

RRˢˢ = i

Zˡₖ = Dict(
    "EFF" => [0.557],
    "ERF" => [0.557],
    "NRF" => [0.478, 0.423],
    "NAF" => [0.557, 0.478]
)

Zᵗʳₖ = Dict(
    "ET" => [0.16],
    "NT" => [0.25, 0.13]
)

Δᵦ = [2000, 5760, 1000]

μᵦ = SystemData.load_factor

ℇ = 0.25


# Piecewise linearization

nᵨ = 3

Mˡₖᵨ = Dict(
    "EFF" => [[]],
    "ERF" => [[]],
    "NRF" => [[], []],
    "NAF" => [[], []]
)

Aˡₖᵨ = Dict(
    "EFF" => [[]],
    "ERF" => [[]],
    "NRF" => [[], []],
    "NAF" => [[], []]
)

for l in L
    for k in Kˡ[l]
        for p in 1:nᵨ
            push!(Mˡₖᵨ[l][k], (2 * p - 1) * Zˡₖ[l][k] * F̅ˡₖ[l][k] / (nᵨ * (Vbase^2)))
            push!(Aˡₖᵨ[l][k], F̅ˡₖ[l][k] / nᵨ)
        end
    end
end

Mᵗʳₖᵨ = Dict(
    "ET" => [[]],
    "NT" => [[], []],
)

Aᵗʳₖᵨ = Dict(
    "ET" => [[]],
    "NT" => [[], []],
)


for tr in TR
    for k in Kᵗʳ[tr]
        for p in 1:nᵨ
            push!(Mᵗʳₖᵨ[tr][k], (2 * p - 1) * Zᵗʳₖ[tr][k] * G̅ᵗʳₖ[tr][k] / (nᵨ * (Vˢˢ^2)))
            push!(Aᵗʳₖᵨ[tr][k], G̅ᵗʳₖ[tr][k] / nᵨ)
        end
    end
end
