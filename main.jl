include("GRASP.jl")
include("PathRelinking.jl")
include("TabuSearch.jl")
include("refSet.jl")


using Plots

function main()
    println("---------------------------------------------------")
    I = 5   
    J = 4
    K = 3
    C = [
    [3, 10, 3, 9],
    [11, 2, 17, 3],
    [17, 12, 2, 1],
    [14, 3, 13, 8],
    [7, 11, 12, 15]
    ]
    B = [
    [77, 97, 48],
    [39, 39, 77],
    [92, 76, 97],
    [65, 42, 94]
    ]
    S = [456, 490, 504]
    
    


    #scatter(plot_path_axe1,plot_path_axe2)



    
end

main()