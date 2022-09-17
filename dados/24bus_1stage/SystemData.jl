module SystemData
    n_bus = 24
    n_branches = 33

    load_factor = [0.7, 0.83, 1]

    branch = [
        #    (s,r) length  type
        ((1, 5), 2.22, "NAF"),
        ((1, 9), 1.2, "NAF"),
        ((1, 14), 1.2, "NAF"),
        ((1, 21), 2.2, "ERF"),
        ((2, 3), 2.0, "NAF"),
        ((2, 12), 1.1, "NAF"),
        ((2, 21), 1.7, "EFF"),
        ((3, 10), 1.1, "NAF"),
        ((3, 16), 1.2, "NAF"),
        ((3, 23), 1.2, "NAF"),
        ((4, 7), 2.6, "NAF"),
        ((4, 9), 1.2, "NAF"),
        ((4, 15), 1.6, "NAF"),
        ((4, 16), 1.3, "NAF"),
        ((5, 6), 2.4, "NAF"),
        ((5, 24), 0.7, "NAF"),
        ((6, 13), 1.2, "NAF"),
        ((6, 17), 2.2, "NAF"),
        ((6, 22), 2.7, "EFF"),
        ((7, 8), 2.0, "NAF"),
        ((7, 11), 1.1, "NAF"),
        ((7, 19), 1.2, "NAF"),
        ((7, 23), 0.9, "NAF"),
        ((8, 22), 1.9, "ERF"),
        ((10, 16), 1.6, "NAF"),
        ((10, 23), 1.3, "NAF"),
        ((11, 23), 1.6, "NAF"),
        ((14, 18), 1.0, "NAF"),
        ((15, 17), 1.2, "NAF"),
        ((15, 19), 0.8, "NAF"),
        ((17, 22), 1.5, "NAF"),
        ((18, 24), 1.5, "NAF"),
        ((20, 24), 0.9, "NAF"),
    ]

    peak_demand = [
    #Stage 1    2    3
        5.42
        1.21
        3.98
        2.43
        0.47
        1.81
        4.36
        0.94
        1.77
        2.40
        2.80
        1.29
        1.87
        3.16
        1.62
        1.22
        2.40
        2.10
        1.81
        3.79
        0.00 #add eq14 problem
        0.00 #add eq14 problem
        0.00 #add eq14 problem
        0.00 #add eq14 problem
    ]

    node_zone = [2, 3, 3, 1, 1, 2, 3, 3, 1, 2, 3, 3, 3, 2, 2, 2, 3, 1, 3, 1, 3, 3, 3, 1]

    wind_speed = [
        #Load Level
        #1   2    3
        8.53 9.12 10.04 #Zone A
        6.13 7.26 7.11 #Zone B
        4.13 5.10 5.56 #Zone C
    ]
end  # moduleSystemData

#
# module AssetsData
#
#     Ωᵗʳ = Dict(
#     "ET" => [21, 22]
#     "NT" => [24, 23]
#     )
#
#     Ωᵖ = Dict(
#     "C" => [2 ,3 ,7, 13, 15, 16, 17, 20],
#     "W" => [1, 4, 5, 9 ,15, 17, 18, 19]
#     )
# end
#

#
# n_bus = 24
# n_brach = 33
# pf = 0.9
#
# i = 0.071
#
# load_level_perc = [0.7, 0.83, 1]
#
# load_hours_peryear = [2000, 5760, 1000]
#
# cost_non_server = 2000
#
# cost_generation_per_loadlevel = [57.7, 70, 85.3]
