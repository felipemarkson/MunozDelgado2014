include("sets.jl")
include("wind.jl")

#Custos de energia
Cᴱᵖₖ = Dict("C" => [47, 45], "W" => [0, 0])

Cˢˢᵦ = [57.7, 70, 85.3]

Cᵁ = 2000

#Custos de investimentos
Cᴵˡₖ = Dict("NRF" => [19140, 29870], "NAF" => [15020, 25030])

Cᴵᴺᵀₖ = [750e3, 950e3]

Cᴵᵖₖ = Dict("C" => [500e3, 490e3], "W" => [1850e3, 1840e3])

Cᴵˢˢₛ = Dict(21 => 100e3, 22 => 100e3, 23 => 140e3, 24 => 180e3)

#Custos de manutenção
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
    "ET" => [1000],
    "NT" => [2000, 3000],
)

# Dados do sistema

Dₛₜ = SystemData.peak_demand

D̃ₛₜᵦ = zeros(length(Ωᴺ), length(T), length(B))
for s in Ωᴺ
    for t in T
        for b in B
            if s in Ωᵖ["C"] || s in Ωᵖ["W"] && s in Ωᴸᴺₜ[t]
                D̃ₛₜᵦ[s, t, b] = 1
            else
                D̃ₛₜᵦ[s, t, b] = 0
            end
        end
    end
end

F̅ˡₖ = Dict(
    "EFF" => [3.94],
    "ERF" => [3.94],
    "NRF" => [6.28, 9],
    "NAF" => [3.94, 6.28],
)

G̅ᵖₖ = Dict("C" => [1, 2], "W" => [0.91, 2.05])

Ĝᵂₛₖₜᵦ = zeros(length(Ωᴺ), length(Kᵖ["W"]), length(T), length(B))
begin
    # Ref: https://wind-turbine.com/download/101655/enercon_produkt_en_06_2015.pdf
    wᵢ = [4.0, 3.0]
    Pᵢ = [0.02, 0.025]
    wᵣ = [15, 12]
    Pᵣ = G̅ᵖₖ["W"]

    for s = Ωᴺ
        for k in Kᵖ["W"]
            for t in T
                for b in B
                    zone = SystemData.node_zone[s]
                    speed = SystemData.wind_speed[zone, b]
                    Ĝᵂₛₖₜᵦ[s, k, t, b] =
                        power_out(wᵢ[k], wᵣ[k], Pᵢ[k], Pᵣ[k], speed)
                end
            end
        end
    end
end

G̅ᵗʳₖ = Dict("ET" => [7.5], "NT" => [12, 15])

Vbase = 20 #kV
V_ = 0.95*Vbase
V̅ = 1.05*Vbase
Vˢˢ = 1.05*Vbase

ℓₛᵣ = zeros(length(Ωᴺ), length(Ωᴺ))
for branch in SystemData.branch
    (s, r) = branch[1]
    ℓₛᵣ[s,r] = branch[2]
    ℓₛᵣ[r,s] = branch[2]
end

ndg = reduce( + , [length(Ωᵖ[p]) for p in P])

nT = length(T)

pf = 0.9

H = V̅ - V_  #Informação retirada de Munoz-Delgado et.al 2018

# Dados dos ativos
i = 7.1/100

IBₜ = [6e6, 6e6, 6e6]

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
    "NRF" => (i*(1+i)^ηˡ["NRF"])/((1+i)^ηˡ["NRF"] - 1),
    "NAF" => (i*(1+i)^ηˡ["NAF"])/((1+i)^ηˡ["NAF"] - 1)
)

RRᴺᵀ = (i*(1+i)^ηᴺᵀ)/((1+i)^ηᴺᵀ - 1)

RRᵖ =  Dict(
    "C" => (i*(1+i)^ηᵖ["C"])/((1+i)^ηᵖ["C"] - 1),
    "W" => (i*(1+i)^ηᵖ["W"])/((1+i)^ηᵖ["W"] - 1)
)

RRˢˢ = i

Zˡₖ = Dict(
    "EFF" => [0.732],
    "ERF" => [0.732],
    "NRF" => [0.557, 0.478],
    "NAF" => [0.732, 0.557]
)

Zᵗʳₖ = Dict(
    "ET" => [0.25],
    "NT" => [0.16, 0.13]
)

Δᵦ = [2000, 5760, 1000]

μᵦ = SystemData.load_factor

ℇ = 0.25


# Dados da linearização por partes

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
            push!(Mˡₖᵨ[l][k], (2*p - 1)*Zˡₖ[l][k]*F̅ˡₖ[l][k]/nᵨ)
            push!(Aˡₖᵨ[l][k], F̅ˡₖ[l][k]/nᵨ)
        end
    end
end

Mᵗʳₖᵨ = Dict(
    "ET" => [[]],
    "NT" => [[],[]],
)

Aᵗʳₖᵨ = Dict(
    "ET" => [[]],
    "NT" => [[],[]],
)


for tr in TR
    for k in Kᵗʳ[tr]
        for p in 1:nᵨ
            push!(Mᵗʳₖᵨ[tr][k], (2*p - 1)*Zᵗʳₖ[tr][k]*G̅ᵗʳₖ[tr][k]/nᵨ)
            push!(Aᵗʳₖᵨ[tr][k], G̅ᵗʳₖ[tr][k]/nᵨ)
        end
    end
end
