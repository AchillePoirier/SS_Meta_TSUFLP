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

function refSet_insertion(refSet,J,K,X_sol,Y_sol,Z_sol,obj_value,beta)
    Y_sol_opened = zeros(Int,J)
    for j = 1:J
        Y_sol_opened[j] = sum(Y_sol[j])
    end

    #indice des solution du refset qui sont moins bonne que la solution que l on souhaite inserer
    arg_worst_sol = Vector{Int}(undef,0)

    for r = 1:beta
        ((),obj_value_refset) = refSet[r]
        if obj_value_refset > obj_value
            push!(arg_worst_sol,r)
        end
    end

    if length(arg_worst_sol) == 0
        return false,refSet
    end

    distances = zeros(Int,beta)
    distance_nul = false

    for r = 1:beta

        dist = 0
        
        ((X_refset,Y_refset,Z_refset),) = refSet[r]

        Y_refset_opened = zeros(Int,J)
        for j = 1:J
            Y_refset_opened[j] = sum(Y_refset[j])
        end

        for j = 1:J
            if Y_sol_opened[j] != Y_refset_opened[j]
                dist += 1
            end
        end
        
        for k = 1:K 
            if Z_sol[k] != Z_refset[k]
                dist += 1
            end
        end

        distances[r] = dist
        if dist == 0
            distance_nul = true
        end
        #println("distance au refSet pour ",r," : ",dist)
    end

    #println("min dist = ",dist_to_refset," arg = ",argmin)

    #si la solution est deja dans le refset, on ne l'insere pas
    if distance_nul == true
        return false,refSet
    else
        #on retire la solution la moins distante parmi celles qui sont moins bonnes.
        min = 999999999
        argmin = 0
        for r in arg_worst_sol
            if distances[r] < min
                min = distances[r]
                argmin = r
            end
        end

        refSet[argmin] = ((X_sol,Y_sol,Z_sol),obj_value)
        return true,refSet
    end
end

function refSet_update(pop,refSet_obj1,refSet_obj2,J,K,beta)

    sol_added = false

    pop_remain = deepcopy(pop)

    new_refSet_obj1 = deepcopy(refSet_obj1)
    new_refSet_obj2 = deepcopy(refSet_obj2)

    max_refSet_obj1 = 0
    max_refSet_obj2 = 0

    for r = 1:beta
       ((),obj_value_refSet) = new_refSet_obj1[r]
        if obj_value_refSet > max_refSet_obj1
            max_refSet_obj1 = obj_value_refSet
        end
    end

    for r = 1:beta
        ((),obj_value_refSet) = new_refSet_obj2[r]
        if obj_value_refSet > max_refSet_obj2
            max_refSet_obj2 = obj_value_refSet
        end
    end

    # display(refSet_obj1)
    # println("refset 1 max : ",max_refSet_obj1)

    # display(refSet_obj2)
    # println("refset 2 max : ",max_refSet_obj2)

    #Tant que des solutions de la populations sont meilleurs qu'au moins une solution du refset
    while true

        if length(pop_remain) < 1 
            break
        end

        min = 99999999999
        argmin = 0

        for r = 1:length(pop_remain)
            ((),(obj1_value_pop,)) = pop_remain[r]
            if obj1_value_pop < min
                min = obj1_value_pop
                argmin = r
            end

        end

        #println("pop obj1 min = ",min,"argmin : ",argmin)

        if min >= max_refSet_obj1
            break
        else
            ((X,Y,Z),(obj_value,)) = pop_remain[argmin]
            inserted,refSet_obj1 = refSet_insertion(refSet_obj1,J,K,X,Y,Z,obj_value,beta)
            if inserted == true
                sol_added = true
            end
            deleteat!(pop_remain,argmin)
        end
    end

    pop_remain = deepcopy(pop)



    while true

        if length(pop_remain) < 1 
            break
        end

        min = 99999999999
        argmin = 0

        for r = 1:length(pop_remain)
            ((),(obj2_value_pop,)) = pop_remain[r]
            if obj2_value_pop < min
                min = obj2_value_pop
                argmin = r
            end

        end

        #println("pop obj1 min = ",min,"argmin : ",argmin)

        if min >= max_refSet_obj2
            break
        else
            ((X,Y,Z),(obj_value,)) = pop_remain[argmin]
            inserted,refSet_obj2 = refSet_insertion(refSet_obj2,J,K,X,Y,Z,obj_value,beta)
            if inserted == true
                sol_added = true
            end
            deleteat!(pop_remain,argmin)
        end

    end

    return sol_added,refSet_obj1,refSet_obj2

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