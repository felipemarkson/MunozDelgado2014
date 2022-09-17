using Dates
fobj = round(JuMP.value.(cᵀᴾⱽ)/ 1e6, digits=3)
invest = round.(JuMP.value.(cᴵₜ) / 1e6, digits=3)
manu = round.(JuMP.value.(cᴹₜ) / 1e6, digits=3)
prod = round.(JuMP.value.(cᴱₜ) / 1e6, digits=3)
loss = round.(JuMP.value.(cᴿₜ) / 1e6, digits=3)
unserv = round.(JuMP.value.(cᵁₜ) / 1e6, digits=3)


function add_line!(msg, txt)
    push!(msg, txt)
end
function lista2str(lista)
    txt = "["
    for value in lista
        txt = txt * "$value "
    end
    txt = txt * "]"
    return txt
end

function write_msg(msg, name, title)
    open("results/$name/$title.txt", "w") do io
        for txt in msg
            write(io, txt * "\n")
        end
    end
end


invst_msg = ["SYSTEM : $name"]

add_line!(invst_msg, "$(now())")
add_line!(invst_msg, "Fobj(x10⁶): $fobj")
add_line!(invst_msg, "Investiment Costs(x10⁶): ")
add_line!(invst_msg, lista2str(invest))
add_line!(invst_msg, "Maintenance Costs(x10⁶): ")
add_line!(invst_msg, lista2str(manu))
add_line!(invst_msg, "Energy (Production) Costs(x10⁶): ")
add_line!(invst_msg, lista2str(prod))
add_line!(invst_msg, "Losses Costs(x10⁶): ")
add_line!(invst_msg, lista2str(loss))
add_line!(invst_msg, "Unserverd Costs(x10⁶): ")
add_line!(invst_msg, lista2str(unserv))


add_line!(invst_msg, "Investiments: ")
for t in T
    add_line!(invst_msg, "   Stage: $t")
    add_line!(invst_msg, "       NEW SUBSTATIONS:")
    for s in Ωˢˢ
        if JuMP.value(xˢˢₛₜ[s, t]) > 0.1
            add_line!(invst_msg, "           Node: $s")
        end
    end


    add_line!(invst_msg, "       NEW TRANSFORMERS:")
    for s in Ωˢˢ
        for k in Kᵗʳ["NT"]
            if JuMP.value(xᴺᵀₛₖₜ[s, k, t]) > 0.1
                add_line!(invst_msg, "           Node: $s  Alternative: $k")
            end
        end
    end

    add_line!(invst_msg, "       NEW GENERATOR:")
    for p in P
        for s in Ωᵖ[p]
            for k in Kᵖ[p]
                if JuMP.value(xᵖₛₖₜ[p, s, k, t]) > 0.1
                    add_line!(invst_msg, "           Node: $s  Type: $p  Alternative: $k")
                end
            end
        end
    end

    add_line!(invst_msg, "       LINES:")
    for l in ["NRF", "NAF"]
        for s in Ωᴺ
            for r in Ωˡₛ[l][s]
                for k in Kˡ[l]
                    if JuMP.value(xˡₛᵣₖₜ[l, s, r, k, t]) > 0.1
                        if l == "NAF"
                            add_line!(invst_msg, "           NEW LINE -> Branch: $((s, r)) Alternative: $k")
                        elseif l == "NRF"
                            add_line!(invst_msg, "           REPLECEMENT LINE -> Branch: $((s, r)) Alternative: $k")
                        end
                    end
                end
            end
        end
    end
end

write_msg(invst_msg, name, "investiment")

pf_msg = ["SYSTEM POWERFLOW : $name"]
add_line!(pf_msg, "$(now())")
for t in T
    add_line!(pf_msg, "   Stage: $t")
    add_line!(pf_msg, "       TRANSFORMERS:")
    for tr in TR
        for s in Ωˢˢ
            for k in Kᵗʳ[tr]
                data = [JuMP.value(gᵗʳₛₖₜᵦ[tr, s, k, t, b]) for b in B]
                usetr = JuMP.value(yᵗʳₛₖₜ[tr, s, k, t]) > 0
                has_flow = any(value -> value > 0.01, data)
                if !(!usetr && has_flow)
                    if usetr
                        add_line!(pf_msg, "           Type: $tr Node: $s Alternative: $k")
                        value_gtr = round(JuMP.value(gᵗʳₛₖₜᵦ[tr, s, k, t, 3]), digits=2)
                        add_line!(pf_msg, "               Injection: $value_gtr Type: $tr Node: $s Alternative: $k")
                    end
                else
                    println(crayon"red", "ERROR!!!!!!    Type:", tr, " Node:", s, " Alternative: ", k)
                end
            end
        end
    end

    add_line!(pf_msg, "       GENERATORS:")
    for p in P
        for s in Ωᵖ[p]
            for k in Kᵖ[p]
                data = [JuMP.value(gᵖₛₖₜᵦ[p, s, k, t, b]) for b in B]
                usegd = JuMP.value(yᵖₛₖₜ[p, s, k, t]) > 0.1
                has_flow = any(value -> value > 0.01, data)
                if !(!usegd && has_flow)
                    if usegd
                        add_line!(pf_msg, "           Type: $p Node: $s  Alternative: $k")
                        value_gp = round(JuMP.value(gᵖₛₖₜᵦ[p, s, k, t, 3]), digits=2)
                        add_line!(pf_msg, "               Injection: $value_gp Type: $p Node: $s Alternative: $k")
                    end
                else
                    println(crayon"red", "ERROR!!!!!!    Type:", p, " Node:", s, " Alternative: ", k)
                end
            end
        end
    end

    add_line!(pf_msg, "       LINES:")
    for l in L
        for s in Ωᴺ
            for r in Ωˡₛ[l][s]
                for k in Kˡ[l]
                    use_line = JuMP.value(yˡₛᵣₖₜ[l, s, r, k, t]) > 0.1
                    data1 = [JuMP.value(fˡₛᵣₖₜᵦ[l, s, r, k, t, b]) for b in B]
                    data2 = [JuMP.value(fˡₛᵣₖₜᵦ[l, r, s, k, t, b]) for b in B]
                    has_flow_sr = any(value -> value > 0.01, data1)
                    has_flow_rs = any(value -> value > 0.01, data1)
                    has_flow = has_flow_sr || has_flow_rs

                    if !(!use_line && has_flow)
                        if use_line
                            add_line!(pf_msg, "           Type $l Branch: $((s, r)) Alternative: $k")
                            if has_flow_sr
                                value_fl = round(JuMP.value(fˡₛᵣₖₜᵦ[l, s, r, k, t, 3]), digits=2)
                                add_line!(pf_msg, "             Flow $((s, r)): $value_fl")
                            else
                                value_fl = round(JuMP.value(fˡₛᵣₖₜᵦ[l, r, s, k, t, 3]), digits=2)
                                add_line!(pf_msg, "             Flow $((s, r)): $value_fl")
                            end
                        end
                    else
                        println(crayon"red", "ERROR!!!!!!Type ", l, "Branch: ", (s, r), " Alternative: ", k)
                        if has_flow_sr
                            println(crayon"red", round(JuMP.value(fˡₛᵣₖₜᵦ[l, s, r, k, t, 1]), digits=2), round(JuMP.value(fˡₛᵣₖₜᵦ[l, s, r, k, t, 2]), digits=2), round(JuMP.value(fˡₛᵣₖₜᵦ[l, s, r, k, t, 3]), digits=2))
                        else
                            println(crayon"red", round(JuMP.value(fˡₛᵣₖₜᵦ[l, r, s, k, t, 1]), digits=2), round(JuMP.value(fˡₛᵣₖₜᵦ[l, r, s, k, t, 2]), digits=2), round(JuMP.value(fˡₛᵣₖₜᵦ[l, r, s, k, t, 3]), digits=2))
                        end
                    end
                end
            end
        end
    end
end
write_msg(pf_msg, name, "powerflow")