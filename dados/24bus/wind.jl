function power_out(wᵢ, wᵣ, Pᵢ, Pᵣ, speed)

    coef = (Pᵣ - Pᵢ)/(wᵣ - wᵢ)

    if speed < wᵢ
        return 0
    elseif wᵢ <= speed <= wᵣ
        return speed * coef
    else
        return Pᵣ
    end

end
