include("GRASP.jl")
include("PathRelinking.jl")
include("TabuSearch.jl")
include("refSet.jl")

function scatterSearch(I,J,K,C,B,S,alpha,beta,tenure,tolerance,P)


    #------------------------------GRASP-----------------------------------------
    pop_obj1,pop_obj2 = population_generation(I,J,K,C,B,S,P,alpha)

    plot_grasp_axe1 = []
    plot_grasp_axe2 = []

    println("GRASP--------------------------------------------------")
    for p in append!(pop_obj1,pop_obj2)
        X,Y,Z = p
        push!(plot_grasp_axe1,objective_value_1(I,J,K,C,B,S,X,Y,Z))
        push!(plot_grasp_axe2,objective_value_2(I,J,K,C,B,S,X,Y,Z))
        # println("X = ",X)
        # println("Y = ",Y)
        # println("Z = ",Z)
    end

    #------------------------------tabu-----------------------------------------

    improved_pop = []

    for p in pop_obj1
        X,Y,Z = p
        push!(improved_pop,tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,1))
    end

    for p in pop_obj2
        X,Y,Z = p
        push!(improved_pop,tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,2))
    end



    println("tabu--------------------------------------------------")
    plot_tabu_axe1 = []
    plot_tabu_axe2 = []
    for p in improved_pop
        ((X,Y,Z),) = p

        push!(plot_tabu_axe1,objective_value_1(I,J,K,C,B,S,X,Y,Z))
        push!(plot_tabu_axe2,objective_value_2(I,J,K,C,B,S,X,Y,Z))
        # println("X = ",X)
        # println("Y = ",Y)
        # println("Z = ",Z)
    end

    improve_tabu = Vector{Tuple{Float64,Float64}}(undef,P)

    for p = 1:P
        improve_tabu[p] = (plot_grasp_axe1[p]-plot_tabu_axe1[p],plot_grasp_axe2[p]-plot_tabu_axe2[p])
    end
    # println(improve_tabu)
    # println("GRASP : \n",plot_grasp_axe1,"\n",plot_grasp_axe2)

    # println("tabu : \n",plot_tabu_axe1,"\n",plot_tabu_axe2)

    plot_equal_axe1 = []
    plot_equal_axe2 = []

    for p = 1:P
        if plot_grasp_axe1[p] == plot_tabu_axe1[p] && plot_grasp_axe2[p] == plot_tabu_axe2[p]
            push!(plot_equal_axe1,plot_grasp_axe1[p])
            push!(plot_equal_axe2,plot_grasp_axe2[p])
        end
    end


    plot_axe1 = [plot_grasp_axe1,plot_tabu_axe1,plot_equal_axe1]
    plot_axe2 = [plot_grasp_axe2,plot_tabu_axe2,plot_equal_axe2]

    #scatter(plot_axe1,plot_axe2,label=["GRASP" "tabu" "GRASP=tabu"])

    println("refSet--------------------------------------------------")


    refSet_obj1 = refSet_init(I,J,K,C,B,S,improved_pop,beta,1)
    refSet_obj2 = refSet_init(I,J,K,C,B,S,improved_pop,beta,2)

    println("Path Relinking--------------------------------------------------")

    solutions_non_dom = []

    for r1 = 1:beta
        for r2 = 1:beta
            ((X1,Y1,Z1),) = refSet_obj1[r1]
            ((X2,Y2,Z2),) = refSet_obj2[r2]
            append!(solutions_non_dom,pathRelinking(I,J,K,C,B,S,X1,Y1,Z1,X2,Y2,Z2))
        end
    end

    plot_path_axe1 = []
    plot_path_axe2 = []

    for s in solutions_non_dom
        ((),(obj1,obj2)) = s
        push!(plot_path_axe1,obj1)
        push!(plot_path_axe2,obj2)
    end

    new_pop = []
    skl_archive = skiplist_init()

    for s in solutions_non_dom 
        ((X,Y,Z),) = s
        ((improved_X1,improved_Y1,improved_Z1),sol1_value1) = tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,1)
        ((improved_X2,improved_Y2,improved_Z2),sol2_value2) = tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,2)

        sol1_value2 = objective_value_2(I,J,K,C,B,S,improved_X1,improved_Y1,improved_Z1)
        sol2_value1 = objective_value_1(I,J,K,C,B,S,improved_X2,improved_Y2,improved_Z2)

        push!(new_pop,((improved_X1,improved_Y1,improved_Z1),(sol1_value1,sol1_value2)))
        push!(new_pop,((improved_X2,improved_Y2,improved_Z2),(sol2_value1,sol2_value2)))

        skl_archive, = skiplist_insertion(skl_archive,improved_X1,improved_Y1,improved_Z1,sol1_value1,sol1_value2)
        skl_archive, = skiplist_insertion(skl_archive,improved_X2,improved_Y2,improved_Z2,sol2_value1,sol2_value2)
    end

    refSet_update(new_pop,refSet_obj1,refSet_obj2)
    

end


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

alpha = 0
beta = 6
tenure = 10
tolerance = 3
P = 10


scatterSearch(I,J,K,C,B,S,alpha,beta,tenure,tolerance,P)