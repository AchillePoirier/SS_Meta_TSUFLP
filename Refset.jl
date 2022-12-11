include("Misc.jl")

function refSet_init(I,J,K,C,B,S,pop,beta,objective)

    pop_remain = Vector{Tuple{Tuple{Vector{Vector{Int}},Vector{Vector{Int}},Vector{Int}},Float64}}(undef,0)

    for p in pop
        ((X,Y,Z),) = deepcopy(p)
        if objective == 1
            push!(pop_remain,((X,Y,Z),objective_value_1(I,J,K,C,B,S,X,Y,Z)))
        elseif objective == 2
            push!(pop_remain,((X,Y,Z),objective_value_2(I,J,K,C,B,S,X,Y,Z)))
        end
    end

    refSet = Vector{Tuple{Tuple{Vector{Vector{Int}},Vector{Vector{Int}},Vector{Int}},Float64}}(undef,0)

    half_beta = ceil(Int,beta/2)

    #recherche des beta/2 meilleurs solutions
    for i = 1:half_beta
        inf = 99999999999999999
        to_add = ()
        for p = 1:length(pop_remain)
            ((),obj_value) = pop_remain[p]
            if obj_value < inf
                to_add = p
                inf = obj_value
            end
        end

        push!(refSet,pop_remain[to_add])
        deleteat!(pop_remain,to_add)
    end

    #println("pop remain : ",pop_remain)
    #println("refset : ",refSet)

    for i = half_beta+1:beta
        #indice de la solution a ajouter
        to_add = 0
        dist_to_refset_max = 0

        #calcul de la distance pour chaque solution
        for p = 1:length(pop_remain)
            
            ((X_pop,Y_pop,Z_pop),) = pop_remain[p]

            Y_pop_opened = zeros(Int,J)
            for j = 1:J
                Y_pop_opened[j] = sum(Y_pop[j])
            end


            dist_to_refset = 0

            for sol_refset in refSet

                dist = 0
                
                ((X_refset,Y_refset,Z_refset),) = sol_refset

                Y_refset_opened = zeros(Int,J)
                for j = 1:J
                    Y_refset_opened[j] = sum(Y_refset[j])
                end

                for j = 1:J
                    if Y_pop_opened[j] != Y_refset_opened[j]
                        dist += 1
                    end
                end
                
                for k = 1:K 
                    if Z_pop[k] != Z_refset[k]
                        dist += 1
                    end
                end

                if dist > dist_to_refset
                    dist_to_refset = dist
                end
                #println("distance au refSet pour ",p," : ",dist)
            end

            #println("donc ",dist_to_refset)

            if dist_to_refset > dist_to_refset_max
                dist_to_refset_max = dist_to_refset
                to_add = p
            end

        end
        #println("sol la plus distante : ",to_add)

        push!(refSet,pop_remain[to_add])
        deleteat!(pop_remain,to_add)
    end

    # println("pop remain : ",pop_remain)
    # println("refset : ",refSet)
    return refSet

end

# #Exemple

# I = 5
# J = 4
# K = 3

# B = [
#     [14,13,18],
#     [15,12,14],
#     [10,16,15],
#     [12,14,18]
# ]

# S = [26,33,30]

# C = [
#     [5,4,7,3],
#     [9,7,6,4],
#     [2,5,3,7],
#     [5,4,8,6],
#     [7,2,3,4]
# ]

# Z1 = [0,1,1]
# Y1 = [
#     [0,0,0],
#     [0,0,1],
#     [0,1,0],
#     [0,0,0]
# ]
# X1 = affectation_terminaux_obj1(5,4,C,Y1)

# Z2 = [0,0,1]
# Y2 = [
#     [0,0,0],
#     [0,0,1],
#     [0,0,1],
#     [0,0,1]
# ]
# X2 = affectation_terminaux_obj1(5,4,C,Y2)

# Z3 = [1,0,1]
# Y3 = [
#     [1,0,0],
#     [1,0,0],
#     [0,0,1],
#     [0,0,0]
# ]
# X3 = affectation_terminaux_obj1(5,4,C,Y3)

# Z4 = [0,1,1]
# Y4 = [
#     [0,0,1],
#     [0,1,0],
#     [0,0,0],
#     [0,1,0]
# ]
# X4 = affectation_terminaux_obj1(5,4,C,Y4)

# Z5 = [1,0,0]
# Y5 = [
#     [1,0,0],
#     [1,0,0],
#     [0,0,0],
#     [1,0,0]
# ]
# X5 = affectation_terminaux_obj1(5,4,C,Y5)

# Z6 = [1,0,0]
# Y6 = [
#     [1,0,0],
#     [0,0,0],
#     [0,0,0],
#     [1,0,0]
# ]
# X6 = affectation_terminaux_obj1(5,4,C,Y6)

# pop1 = [
#     ((X1,Y1,Z1),objective_value_1(I,J,K,C,B,S,X1,Y1,Z1)),
#     ((X2,Y2,Z2),objective_value_1(I,J,K,C,B,S,X2,Y2,Z2)),
#     ((X3,Y3,Z3),objective_value_1(I,J,K,C,B,S,X3,Y3,Z3)),
#     ((X4,Y4,Z4),objective_value_1(I,J,K,C,B,S,X4,Y4,Z4)),
#     ((X5,Y5,Z5),objective_value_1(I,J,K,C,B,S,X5,Y5,Z5)),
#     ((X6,Y6,Z6),objective_value_1(I,J,K,C,B,S,X6,Y6,Z6))
#     ]

# pop2 = [
#     ((X1,Y1,Z1),objective_value_2(I,J,K,C,B,S,X1,Y1,Z1)),
#     ((X2,Y2,Z2),objective_value_2(I,J,K,C,B,S,X2,Y2,Z2)),
#     ((X3,Y3,Z3),objective_value_2(I,J,K,C,B,S,X3,Y3,Z3)),
#     ((X4,Y4,Z4),objective_value_2(I,J,K,C,B,S,X4,Y4,Z4)),
#     ((X5,Y5,Z5),objective_value_2(I,J,K,C,B,S,X5,Y5,Z5)),
#     ((X6,Y6,Z6),objective_value_2(I,J,K,C,B,S,X6,Y6,Z6))
#     ]


# pop = [
#     (X1,Y1,Z1),
#     (X2,Y2,Z2),
#     (X3,Y3,Z3),
#     (X4,Y4,Z4),
#     (X5,Y5,Z5),
#     (X6,Y6,Z6)
#     ]
# refSet_init(I,J,K,C,B,S,pop,4,1)