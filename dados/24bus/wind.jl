function power_out(wᵢ, wᵣ, Pᵢ, Pᵣ, speed)

    coef = (Pᵣ - Pᵢ) / (wᵣ - wᵢ)

    if speed < wᵢ
        return 0
    elseif wᵢ <= speed <= wᵣ
        return speed * coef
    else
        return Pᵣ
    end

end

function power_out_v2(k, speed)
    # Ref: https://wind-turbine.com/download/101655/enercon_produkt_en_06_2015.pdf
    if k == 1
        WG = [
            3 4.0
            4 20.0
            5 50.0
            6 96.0
            7 156.0
            8 238.0
            9 340.0
            10 466.0
            11 600.0
            12 710.0
            13 790.0
            14 850.0
            15 880.0
            16 905.0
            17 910.0
        ]

    elseif k == 2
        WG = [
            2 3.0
            3 25.0
            4 82.0
            5 174.0
            6 321.0
            7 532.0
            8 815.0
            9 1180.0
            10 1580.0
            11 1810.0
            12 1980.0
            13 2050.0
        ]
    end

    if (k == 1) && (speed < 3)
        Pr = 0
    elseif (k == 1) && (speed >= 17)
        Pr = 0.91
    elseif (k == 2) && (speed < 2)
        Pr = 0
    elseif (k == 2) && (speed >= 13)
        Pr = 2.05
    else
        speed_aux1 = floor(speed)
        speed_aux2 = speed_aux1 + 1
        loc_aux1 = findfirst(x -> x == speed_aux1, WG[:, 1])
        loc_aux2 = findfirst(x -> x == speed_aux2, WG[:, 1])



        Pr_aux1 = (speed * WG[loc_aux1, 2]) / speed_aux1
        Pr_aux2 = (speed * WG[loc_aux2, 2]) / speed_aux2

        Pr = ((Pr_aux1 + Pr_aux2) / 2) / 1000
    end

    return Pr
end
