import JuMP
using Crayons

# opt = CPLEX.Optimizer

# function println_lista(lista)
#     print("[")
#     for value in lista
#         print(value, " ")
#     end
#     println("]")
# end
function build_model(path2main)


    include(path2main*"/main.jl")
    model = JuMP.Model()




    # Variables
    # JuMP.@variable(model, 0 ≤ cᴱₜ[T])
    # JuMP.@variable(model, 0 ≤ cᴹₜ[T])
    # JuMP.@variable(model, 0 ≤ cᴿₜ[T])
    # JuMP.@variable(model, 0 ≤ cᵁₜ[T])
    # JuMP.@variable(model, 0 ≤ cᴵₜ[T])
    # JuMP.@variable(model, 0 ≤ cᵀᴾⱽ)
    # JuMP.@variable(model, 0 ≤ dᵁₛₜᵦ[Ωᴺ, T, B])
    # JuMP.@variable(model, 0 ≤ fˡₛᵣₖₜᵦ[l=L, s=Ωᴺ, Ωˡₛ[l][s], Kˡ[l], T, B])
    JuMP.@variable(model, 0 ≤ f̃ₛᵣₜ[s=Ωᴺ, Ωₛ[s], T] ≤ ndg * D̃)
    JuMP.@variable(model, gᵖₛₖₜᵦ[p=P, Ωᵖ[p], Kᵖ[p], T, B] ≥ 0 )
    # JuMP.@variable(model, 0 ≤ gᵗʳₛₖₜᵦ[tr=TR, Ωᴺ, Kᵗʳ[tr], T, B])
    JuMP.@variable(model, 0 ≤ g̃ˢˢₛₜ[Ωˢˢ, T] ≤ ndg * D̃)
    JuMP.@variable(model, V_ ≤ vₛₜᵦ[Ωᴺ, T, B] ≤ V̅, start = Vbase)
    JuMP.@variable(model, xˡₛᵣₖₜ[l=["NRF", "NAF"], s=Ωᴺ, Ωˡₛ[l][s], Kˡ[l], T]; binary=true)
    JuMP.@variable(model, xᴺᵀₛₖₜ[Ωˢˢ, Kᵗʳ["NT"], T]; binary=true)
    JuMP.@variable(model, xᵖₛₖₜ[p=P, Ωᵖ[p], Kᵖ[p], T]; binary=true)
    JuMP.@variable(model, xˢˢₛₜ[Ωˢˢ, T]; binary=true)
    JuMP.@variable(model, yˡₛᵣₖₜ[l=L, s=Ωᴺ, Ωˡₛ[l][s], Kˡ[l], T]; binary=true)
    JuMP.@variable(model, yᵖₛₖₜ[p=P, Ωᵖ[p], Kᵖ[p], T]; binary=true)
    JuMP.@variable(model, yᵗʳₛₖₜ[tr=TR, Ωˢˢ, Kᵗʳ[tr], T]; binary=true)
    JuMP.@variable(model, δˡₛᵣₖₜᵦᵨ[l=L, s=Ωᴺ, Ωˡₛ[l][s], Kˡ[l], T, B, ρ=1:nᵨ]  ≥ 0)
    JuMP.@variable(model, δᵗʳₛₖₜᵦᵨ[tr=TR, Ωˢˢ, Kᵗʳ[tr], T, B, ρ=1:nᵨ]  ≥ 0)

    JuMP.@expression(model, g_p_warp[p=P, s=Ωᴺ, k=Kᵖ[p], t=T, b=B],
        if s ∈ Ωᵖ[p]
            gᵖₛₖₜᵦ[p, s, k, t, b]
        else
            0.0
        end
    )

    ## eq2
    JuMP.@expression(model, cᴵₜ[t=T],
        sum(RRˡ[l] * sum(sum(
            Cᴵˡₖ[l][k] * ℓₛᵣ[s, r] * xˡₛᵣₖₜ[l, s, r, k, t]
            for (s, r) in γˡ[l])
                         for k in Kˡ[l])
            for l in ["NRF", "NAF"])
        + RRˢˢ * sum(
            Cᴵˢˢₛ[s] * xˢˢₛₜ[s, t]
            for s in Ωˢˢ)
        + RRᴺᵀ * sum(sum(
            Cᴵᴺᵀₖ[k] * xᴺᵀₛₖₜ[s, k, t]
            for s in Ωˢˢ)
                     for k in Kᵗʳ["NT"])
        + sum(RRᵖ[p] * sum(sum(
            Cᴵᵖₖ[p][k] * pf * G̅ᵖₖ[p][k] * xᵖₛₖₜ[p, s, k, t]
            for s in Ωᵖ[p])
                           for k in Kᵖ[p])
              for p in P)
    )

    ## eq3
    JuMP.@expression(model, cᴹₜ[t=T],
        sum(sum(sum(
            Cᴹˡₖ[l][k] * (yˡₛᵣₖₜ[l, s, r, k, t] + yˡₛᵣₖₜ[l, r, s, k, t])
            for (s, r) in γˡ[l])
                for k in Kˡ[l])
            for l in L)
        + sum(sum(sum(
            Cᴹᵗʳₖ[tr][k] * yᵗʳₛₖₜ[tr, s, k, t]
            for s in Ωˢˢ)
                  for k in Kᵗʳ[tr])
              for tr in TR)
        + sum(sum(sum(
            Cᴹᵖₖ[p][k] * yᵖₛₖₜ[p, s, k, t]
            for s in Ωᵖ[p])
                  for k in Kᵖ[p])
              for p in P)
    )

    ## eq 5
    JuMP.@expression(model, gᵗʳₛₖₜᵦ[tr=TR, s=Ωᴺ, k=Kᵗʳ[tr], t=T, b=B],
        if s ∈ Ωˢˢ
            sum(δᵗʳₛₖₜᵦᵨ[tr, s, k, t, b, ρ]
                for ρ = 1:nᵨ)
        else
            0.0
        end
        # gᵗʳₛₖₜᵦ[tr,s,k,t,b] == sum(
        #     δᵗʳₛₖₜᵦᵨ[tr,s,k,t,b,ρ]
        # for ρ in 1:nᵨ)
    )
    # JuMP.@constraint(model, constr_aux_g_tr[tr=TR, s=Ωᴺ, k=Kᵗʳ[tr], t=T, b=B], 0 ≤ gᵗʳₛₖₜᵦ[tr, s, k, t, b])
    JuMP.@expression(model, fˡₛᵣₖₜᵦ[l=L, r=Ωᴺ, s=Ωˡₛ[l][r], k=Kˡ[l], t=T, b=B],
        sum(
            δˡₛᵣₖₜᵦᵨ[l, s, r, k, t, b, ρ]
            for ρ in 1:nᵨ)
    )
    # JuMP.@constraint(model, eq5_aux1[l=L, r=Ωᴺ, s=Ωˡₛ[l][r], k=Kˡ[l], t=T, b=B], 0 ≤ fˡₛᵣₖₜᵦ[l, s, r, k, t, b])
    JuMP.@constraint(model, eq5_aux2[tr=TR, s=Ωˢˢ, k=Kᵗʳ[tr], t=T, b=B, ρ=1:nᵨ],
        δᵗʳₛₖₜᵦᵨ[tr, s, k, t, b, ρ] ≤ Aᵗʳₖᵨ[tr][k][ρ]
    )
    JuMP.@constraint(model, eq5_aux4[l=L, r=Ωᴺ, s=Ωˡₛ[l][r], k=Kˡ[l], t=T, b=B, ρ=1:nᵨ],
        δˡₛᵣₖₜᵦᵨ[l, s, r, k, t, b, ρ] ≤ Aˡₖᵨ[l][k][ρ]
    )


    ## eq4
    JuMP.@expression(model, cᴱₜ[t=T],
        sum(Δᵦ[b] * pf * (
                sum(sum(sum(
                    Cˢˢᵦ[b] * gᵗʳₛₖₜᵦ[tr, s, k, t, b]
                    for s in Ωˢˢ)
                        for k in Kᵗʳ[tr])
                    for tr in TR)
                +
                sum(sum(sum(
                    Cᴱᵖₖ[p][k] * gᵖₛₖₜᵦ[p, s, k, t, b]
                    for s in Ωᵖ[p])
                        for k in Kᵖ[p])
                    for p in P)
            )
            for b in B)
    )

    ## eq5
    JuMP.@expression(model, cᴿₜ[t=T],
        sum(Δᵦ[b] * Cˢˢᵦ[b] * pf * (
                sum(sum(sum(sum(
                    Mᵗʳₖᵨ[tr][k][ρ] * δᵗʳₛₖₜᵦᵨ[tr, s, k, t, b, ρ]
                    for ρ = 1:nᵨ)
                            for s in Ωˢˢ)
                        for k in Kᵗʳ[tr])
                    for tr in TR)
                +
                sum(sum(sum(sum(
                    Mˡₖᵨ[l][k][ρ] * ℓₛᵣ[s, r] * (δˡₛᵣₖₜᵦᵨ[l, s, r, k, t, b, ρ] + δˡₛᵣₖₜᵦᵨ[l, r, s, k, t, b, ρ])
                    for ρ = 1:nᵨ)
                            for (s, r) in γˡ[l])
                        for k in Kˡ[l])
                    for l in L)
            )
            for b in B)
    )

    JuMP.@expression(model, dᵁₛₜᵦ[s=Ωᴺ, t=T, b=B], 0.0) # Removing dᵁₛₜᵦ improves the solver performance.
    ## eq6
    JuMP.@expression(model, cᵁₜ[t=T],
        sum(sum(
            Δᵦ[b] * Cᵁ * pf * dᵁₛₜᵦ[s, t, b]
            for s in Ωᴸᴺₜ[t])
            for b in B)
    )

    #Costs
    JuMP.@expression(model, cᵀᴾⱽ,
        sum(cᴵₜ[t] * ((1 + i)^-t) / i for t in T)
        + sum((cᴹₜ[t] + cᴱₜ[t] + cᴿₜ[t] + cᵁₜ[t]) * (1 + i)^-t for t in T)
        + (cᴹₜ[T[end]] + cᴱₜ[T[end]] + cᴿₜ[T[end]] + cᵁₜ[T[end]]) * ((1 + i)^(-T[end])) / i
    )

    # Operational Constraints
    # JuMP.@constraint(model, eq7[s=Ωᴺ, t=T, b=B],
    #     V_ ≤ vₛₜᵦ[s, t, b] ≤ V̅
    # )

    # This fixes the voltage of the substation nodes.
    for s = Ωˢˢ, t = T, b = B
        JuMP.fix(vₛₜᵦ[s, t, b], Vˢˢ; force=true)
    end
    # JuMP.@constraint(model, eq7_aux[s=Ωˢˢ,t=T,b=B],
    #     vₛₜᵦ[s,t,b] == Vˢˢ
    # )

    JuMP.@constraint(model, eq8[l=L, r=Ωᴺ, s=Ωˡₛ[l][r], k=Kˡ[l], t=T, b=B],
        fˡₛᵣₖₜᵦ[l, s, r, k, t, b] ≤ yˡₛᵣₖₜ[l, s, r, k, t] * F̅ˡₖ[l][k]
    )

    JuMP.@constraint(model, eq9[tr=TR, s=Ωˢˢ, k=Kᵗʳ[tr], t=T, b=B],
        gᵗʳₛₖₜᵦ[tr, s, k, t, b] ≤ yᵗʳₛₖₜ[tr, s, k, t] * G̅ᵗʳₖ[tr][k]
    )

    JuMP.@constraint(model, eq10[t=T, s=Ωᴺ, b=B],
        dᵁₛₜᵦ[s, t, b] ≤ μᵦ[b] * Dₛₜ[s, t]
    )

    JuMP.@constraint(model, eq11[s=Ωᵖ["C"], k=Kᵖ["C"], t=T, b=B],
        gᵖₛₖₜᵦ["C", s, k, t, b] ≤ yᵖₛₖₜ["C", s, k, t] * G̅ᵖₖ["C"][k]
    )

    JuMP.@constraint(model, eq12[s=Ωᵖ["W"], k=Kᵖ["W"], t=T, b=B],
        gᵖₛₖₜᵦ["W", s, k, t, b] ≤ yᵖₛₖₜ["W", s, k, t] * minimum([G̅ᵖₖ["W"][k], Ĝᵂₛₖₜᵦ[s][k][t][b]])
    )

    JuMP.@constraint(model, eq13[t=T, b=B],
        sum(sum(sum(
            gᵖₛₖₜᵦ[p, s, k, t, b]
            for s in Ωᵖ[p])
                for k in Kᵖ[p])
            for p in P)
        ≤
        ℇ * sum(
            μᵦ[b] * Dₛₜ[s, t]
            for s in Ωᴸᴺₜ[t])
    )

    JuMP.@constraint(model, eq14[s=Ωᴺ, t=T, b=B], # Eq14 needs the follow fixes
        sum(sum(sum(
            fˡₛᵣₖₜᵦ[l, s, r, k, t, b] - fˡₛᵣₖₜᵦ[l, r, s, k, t, b]
            for r in Ωˡₛ[l][s])
                for k in Kˡ[l])
            for l in L)
        ==
        sum(sum(
            gᵗʳₛₖₜᵦ[tr, s, k, t, b]
            for k in Kᵗʳ[tr])
            for tr in TR)
        +
        sum(sum(
            g_p_warp[p, s, k, t, b]
            for k in Kᵖ[p])
            for p in P)
        -
        μᵦ[b] * Dₛₜ[s, t] + dᵁₛₜᵦ[s, t, b]
    )
    # JuMP.@constraint(model, eq14_aux1[ p = P, s = [s for s in Ωᴺ if s ∉ Ωᵖ[p]], k  =  Kᵖ[p],  t = T], #It allows DG only on candidates nodes
    #         yᵖₛₖₜ[p,s,k,t] == 0
    # )
    # JuMP.@constraint(model, eq14_aux2[ tr = TR, s = [s for s in Ωᴺ if s ∉ Ωˢˢ], k  =  Kᵗʳ[tr],  t = T], #It allows transf. only on candidates nodes
    #         yᵗʳₛₖₜ[tr,s,k,t] == 0
    # )
    # JuMP.@constraint(model, eq14_axu3[s=Ωˢˢᴺ, k=Kᵗʳ["ET"], t=T, b=B], 
    #     == 0
    # )

    # It avoids "ET" transf. on new substations
    for s = Ωˢˢᴺ, k = Kᵗʳ["ET"], t = T, b = B
        JuMP.fix(yᵗʳₛₖₜ["ET", s, k, t], 0, force=true)
    end

    JuMP.@constraint(model, eq14_axu4[s=Ωˢˢᴱ, t=T], # It allows one type of transf. on existing substation nodes
        sum(sum(yᵗʳₛₖₜ[tr, s, k, t] for k in Kᵗʳ[tr]) for tr in TR) ≤ 1
    )

    #Eq 15 and 16
    JuMP.@constraint(model, eq16_1[l=L, r=Ωᴺ, s=Ωˡₛ[l][r], k=Kˡ[l], t=T, b=B],
        -Zˡₖ[l][k] * ℓₛᵣ[s, r] * fˡₛᵣₖₜᵦ[l, s, r, k, t, b] / Vbase + (vₛₜᵦ[s, t, b] - vₛₜᵦ[r, t, b]) ≤ H * (1 - yˡₛᵣₖₜ[l, s, r, k, t])
    )
    JuMP.@constraint(model, eq16_2[l=L, r=Ωᴺ, s=Ωˡₛ[l][r], k=Kˡ[l], t=T, b=B],
        Zˡₖ[l][k] * ℓₛᵣ[s, r] * fˡₛᵣₖₜᵦ[l, s, r, k, t, b] / Vbase - (vₛₜᵦ[s, t, b] - vₛₜᵦ[r, t, b]) ≤ H * (1 - yˡₛᵣₖₜ[l, s, r, k, t])
    )

    #Investiment constraints
    JuMP.@constraint(model, eq17[l=["NRF", "NAF"], (s, r)=[branch for branch in γˡ[l]]],
        sum(sum(
            xˡₛᵣₖₜ[l, s, r, k, t]
            for k in Kˡ[l])
            for t in T) ≤ 1
    )

    JuMP.@constraint(model, eq18[s=Ωˢˢ],
        sum(xˢˢₛₜ[s, t] for t in T) ≤ 1
    )

    JuMP.@constraint(model, eq19[s=Ωˢˢ],
        sum(sum(
            xᴺᵀₛₖₜ[s, k, t]
            for k in Kᵗʳ["NT"])
            for t in T) ≤ 1
    )

    JuMP.@constraint(model, eq20[p=P, s=Ωᵖ[p]],
        sum(sum(
            xᵖₛₖₜ[p, s, k, t]
            for k in Kᵖ[p])
            for t in T) ≤ 1
    )

    JuMP.@constraint(model, eq21[s=Ωˢˢ, k=Kᵗʳ["NT"], t=T],
        xᴺᵀₛₖₜ[s, k, t] ≤ sum(xˢˢₛₜ[s, τ] for τ in T if τ ≥ t)
    )

    #Eq. updated #Ref: DOI: 10.1109/TSG.2016.2560339
    JuMP.@constraint(model, eq22[l=["EFF"], (s, r)=[branch for branch in γˡ[l]], k=Kˡ[l], t=T],
        yˡₛᵣₖₜ[l, s, r, k, t] + yˡₛᵣₖₜ[l, r, s, k, t] == 1
    )

    #Eq. updated #Ref: DOI: 10.1109/TSG.2016.2560339
    JuMP.@constraint(model, eq23[l=["NRF", "NAF"], (s, r)=[branch for branch in γˡ[l]], k=Kˡ[l], t=T],
        yˡₛᵣₖₜ[l, s, r, k, t] + yˡₛᵣₖₜ[l, r, s, k, t] == sum(xˡₛᵣₖₜ[l, s, r, k, τ] for τ  in T if τ ≥ t)
    )

    #Eq. updated #Ref: DOI: 10.1109/TSG.2016.2560339
    JuMP.@constraint(model, eq24[l=["ERF"], (s, r)=[branch for branch in γˡ[l]], k=Kˡ[l], t=T],
        yˡₛᵣₖₜ[l, s, r, k, t] + yˡₛᵣₖₜ[l, r, s, k, t] == 1 - sum(sum(xˡₛᵣₖₜ["NRF", s, r, κ, τ] for κ in Kˡ["NRF"]) for τ  in T if τ ≥ t)
    )

    JuMP.@constraint(model, eq25[s=Ωˢˢ, k=Kᵗʳ["NT"], t=T],
        yᵗʳₛₖₜ["NT", s, k, t] ≤ sum(xᴺᵀₛₖₜ[s, k, τ] for τ  in T if τ ≥ t)
    )

    JuMP.@constraint(model, eq26[p=P, s=Ωᵖ[p], k=Kᵖ[p], t=T],
        yᵖₛₖₜ[p, s, k, t] ≤ sum(xᵖₛₖₜ[p, s, k, τ] for τ  in T if τ ≥ t)
    )

    JuMP.@constraint(model, eq27[t=T],
        sum(sum(sum(
            Cᴵˡₖ[l][k] * ℓₛᵣ[s, r] * xˡₛᵣₖₜ[l, s, r, k, t]
            for (s, r) in γˡ[l])
                for k in Kˡ[l])
            for l in ["NRF", "NAF"])
        + sum(
            Cᴵˢˢₛ[s] * xˢˢₛₜ[s, t]
            for s in Ωˢˢ)
        + sum(sum(
            Cᴵᴺᵀₖ[k] * xᴺᵀₛₖₜ[s, k, t]
            for s in Ωˢˢ)
              for k in Kᵗʳ["NT"])
        + sum(sum(sum(
            Cᴵᵖₖ[p][k] * pf * G̅ᵖₖ[p][k] * xᵖₛₖₜ[p, s, k, t]
            for s in Ωᵖ[p])
                  for k in Kᵖ[p])
              for p in P)
        ≤
        IBₜ[t])


    #Radiality constraints
    JuMP.@constraint(model, eq28[t=T, r=Ωᴸᴺₜ[t]],
        sum(sum(sum(
            yˡₛᵣₖₜ[l, s, r, k, t]
            for k in Kˡ[l])
                for s in Ωˡₛ[l][r])
            for l in L) == 1
    )

    JuMP.@constraint(model, eq29[t=T, r=[r for r in Ωᴺ if r ∉ Ωᴸᴺₜ[t]]],
        sum(sum(sum(
            yˡₛᵣₖₜ[l, s, r, k, t]
            for k in Kˡ[l])
                for s in Ωˡₛ[l][r])
            for l in L) ≤ 1
    )

    # Radiality new

    ## Its allows ficticius injections only on substations node
    JuMP.@expression(model, g_radi_ss_wrap[s=Ωᴺ, t=T],
        if s ∈ Ωˢˢ
            g̃ˢˢₛₜ[s, t]
        else
            0.0
        end
    )

    ## Definition of demand
    JuMP.@expression(model, d̃ₛₜ[s=Ωᴺ, t=T],
        if (s in Ωᵖ["C"]) & (s in Ωᵖ["W"])
            # D̃ₛₜ[s, t]
            +D̃ * sum(
                yᵖₛₖₜ["C", s, k, t]
                for k ∈ Kᵖ["C"])
            +D̃ * sum(
                yᵖₛₖₜ["W", s, k, t]
                for k ∈ Kᵖ["W"])

        elseif s in Ωᵖ["C"]
            # D̃ₛₜ[s, t]
            +D̃ * sum(
                yᵖₛₖₜ["C", s, k, t]
                for k ∈ Kᵖ["C"])

        elseif s in Ωᵖ["W"]
            # D̃ₛₜ[s, t]
            +D̃ * sum(
                yᵖₛₖₜ["W", s, k, t]
                for k ∈ Kᵖ["W"])

        else
            0.0
            # D̃ₛₜ[s, t]
        end
    )

    JuMP.@constraint(model, eq_new1[s=Ωᴺ, t=T],
        sum(
            f̃ₛᵣₜ[s, r, t] - f̃ₛᵣₜ[r, s, t]
            for r in Ωₛ[s])
        ==
        g_radi_ss_wrap[s, t] - d̃ₛₜ[s, t]
    )

    JuMP.@constraint(model, eq_new2[r=Ωᴺ, s=Ωₛ[r], t=T],
        f̃ₛᵣₜ[s, r, t] ≤ D̃ * ndg *
                          sum(
                              sum(
                                  sum(
                                      yˡₛᵣₖₜ[l, s2, r, k, t]
                                      for k = Kˡ[l])
                                  for s2 ∈ Ωˡₛ[l][r] if s2 == s)
                              for l = L)
    )

    JuMP.@constraint(model, eq_new3[s=Ωˢˢ, t=T],
        g̃ˢˢₛₜ[s, t] ≤ D̃ * ndg *
                        sum(
                            sum(
                                yᵗʳₛₖₜ[tr, s, k, t]
                                for k ∈ Kᵗʳ[tr])
                            for tr ∈ TR)
    )

    #Objective Function
    JuMP.@objective(model, Min, cᵀᴾⱽ)
    return model
end