include("GRASP.jl")
include("PathRelinking.jl")
include("TabuSearch.jl")

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

    Z = [1,0,1]
    Y = [
    [0,0,0],
    [0,1,0],
    [0,1,0],
    [0,0,0]
    ]
    X = affectation_terminaux_obj1(5,4,C,Y)
    
    #parametres
    alpha = 0.7
    beta = 6
    tenure = 10
    tolerance = 3 #k
    p = 10

    #println(RCL_init_Si(K,S1,0.7))
    #println(RCL_init_Bi(3,J,B1,0.7))

    # P = 5

    # pop = population_generation(J,K,B,S,P,2,0.7)
    # for p = 1:P
    #     println(pop[p])
    # end

    tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,2)
    println("Solution finale : ")
    println("Z = ",Z)
    println("Y = ",Y)
    println("X = ",X)

    
end

main()