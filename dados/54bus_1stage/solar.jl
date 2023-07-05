function solar_power_out(k, irradiation)
    efficence = 0
    if k == 1
        # Ref: https://www.enf.com.cn/Product/pdf/Crystalline/54c1e666df543.pdf
        # efficence = Irradiance in STC / Pmax in STC
        efficence = 0.14 
    elseif k == 2 
        # Ref: https://cdn.enfsolar.com/Product/pdf/Crystalline/54c1e3b14602c.pdf
        # efficence = Irradiance in STC / Pmax in STC
        efficence = 0.33 
    else
        throw("PV alternative $k is not implemented")
    end
    return irradiation*efficence
end