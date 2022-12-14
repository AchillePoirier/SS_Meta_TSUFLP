
include("Misc.jl")

#On ouvre d'abord les concentrateurs_nv2
function RCL_init_Z_obj1(K,S,alpha)

    indice_S_sorted_obj1 = sortperm(S)


    #println(indice_S_sorted_obj1)
    
    min = S[indice_S_sorted_obj1[1]]
    max = S[indice_S_sorted_obj1[K]]

    limit = min + (1 - alpha)*(max-min)

    #println("min = ",min," max = ",max," limit = ",limit)

    cut = 1
    while true
        if cut >= K
            break
        elseif S[indice_S_sorted_obj1[cut+1]] > limit
            break
        else
            cut += 1
        end
    end

    return indice_S_sorted_obj1[1:cut]
end

function RCL_init_Z_obj2(K,S,alpha)

    #moyenne des couts de S
    moyenne = 0
    for k = 1:K
        moyenne += S[k]
    end
    moyenne = moyenne/K

    #println("moyenne : ",moyenne)

    #distance a la moyenne pour chaque cout de S
    distance = Vector{Float64}(undef,K)
    for k = 1:K
        distance[k] = abs(moyenne-S[k])
    end

    #println("distance : ",distance)

    indice_S_sorted_obj2 = sortperm(distance)

    #println(indice_S_sorted_obj2)
    
    min = distance[indice_S_sorted_obj2[1]]
    max = distance[indice_S_sorted_obj2[K]]

    limit = min + (1 - alpha)*(max-min)

    #println("min = ",min," max = ",max," limit = ",limit)

    cut = 1
    while true
        if cut >= K
            break
        elseif distance[indice_S_sorted_obj2[cut+1]] > limit
            break
        else
            cut += 1
        end
    end


    return indice_S_sorted_obj2[1:cut]
end


#on initialise Y a partir d'un Z deja fixe
function RCL_init_Y_obj1(J,K,B,Z,alpha)
    
    #indice du concentrateur_nv2 coutant le moins cher a affecter au concentrateurs_nv1
    bestCost_Y = zeros(Int,J)

    for j = 1:J
        argmin = 0
        min = 9999999999999
        for k = 1:K
            if Z[k] == 1
                if B[j][k] < min
                    argmin = k
                    min = B[j][k]
                end
            end
        end
        bestCost_Y[j] = min
    end
    #println(bestCost_Y)

    indice_B_sorted_obj1 = sortperm(bestCost_Y)


    min = bestCost_Y[indice_B_sorted_obj1[1]]
    max = bestCost_Y[indice_B_sorted_obj1[J]]

    limit = min + (1 - alpha)*(max-min)

    #println("min = ",min," max = ",max," limit = ",limit)

    cut = 1
    while true
        if cut >= J
            break
        elseif bestCost_Y[indice_B_sorted_obj1[cut+1]] > limit
            break
        else
            cut += 1
        end
    end


    

    return indice_B_sorted_obj1[1:cut]
end

function RCL_init_Y_obj2(J,K,B,Z,alpha)

    #calcul de la distance moyenne entre les concentrateurs_nv1 et les concentrateurs_nv2 ouverts
    moyenne_total = 0
    for j = 1:J
        moyenne = 0
        for k = 1:K
            if Z[k] == 1
                moyenne += B[j][k]
            end
        end
        moyenne_total += moyenne/sum(Z)
        #println("moyenne : ",moyenne/sum(Z))
    end
    moyenne_total = moyenne_total/J
    #println("moyenne total : ",moyenne_total)

    distance = Vector{Vector{Float64}}(undef,J)
    for j = 1:J
        distance[j] = zeros(K)
        #Des valeurs sont quand meme mises dans les colonne des concentrateur_nv2 fermes afin d'avoir une matrice de meme dimensions que B
        #Ces valeurs sont erronnees puisque ces concentrateur_nv2 fermes n'ont pas ete prit en compte lors du calcul de la moyenne
        for k=1:K
            distance[j][k] = abs(B[j][k]-moyenne_total)
        end
    end

    #display(distance)
        
    #indice du concentrateur_nv2 coutant le moins cher a affecter au concentrateurs_nv1
    bestCost_Y = zeros(J)

    for j = 1:J
        min = 99999999999999
        argmin = 0
        for k = 1:K
            if Z[k] == 1
                if distance[j][k] < min
                    argmin = k
                    min = distance[j][k]
                end
            end
        end
        bestCost_Y[j] = min
    end

    #println(bestCost_Y)

    indice_B_sorted_obj2 = sortperm(bestCost_Y)


    min = bestCost_Y[indice_B_sorted_obj2[1]]
    max = bestCost_Y[indice_B_sorted_obj2[J]]

    limit = min + (1 - alpha)*(max-min)

    #println("min = ",min," max = ",max," limit = ",limit)

    
    cut = 1
    while true
        if cut >= J
            break
        elseif bestCost_Y[indice_B_sorted_obj2[cut+1]] > limit
            break
        else
            cut += 1
        end
    end


    return indice_B_sorted_obj2[1:cut]
end


function population_generation(I,J,K,C,B,S,P,alpha,Ctr)

    pop_obj1 = []
    pop_obj2 = []


    #plus ou moins 1
    half_P = floor(P/2) 

    println(half_P)

    RCL_Z_obj1 = RCL_init_Z_obj1(K,S,alpha)
    RCL_Z_obj2 = RCL_init_Z_obj2(K,S,alpha)

    nb_Z_obj1 = length(RCL_Z_obj1)
    nb_Z_obj2 = length(RCL_Z_obj2)

    for p = 1:P

        nb_Z_open = 0

        if p <= half_P
            nb_Z_open = rand(1:nb_Z_obj1)
            RCL_Z = RCL_Z_obj1
        else
            nb_Z_open = rand(1:nb_Z_obj2)
            RCL_Z = RCL_Z_obj2
        end

        Z = zeros(Int,K)
        # println("RCL Z : ",RCL_Z)

        for k = 1:nb_Z_open
            Z[RCL_Z[k]] = 1
        end

        # println("rnd = ", nb_Z_open)
        # println("Z = ",Z,"\n")

        RCL_Y = Vector{Int}

        if p <= half_P
            RCL_Y = RCL_init_Y_obj1(J,K,B,Z,alpha)
        else
            RCL_Y = RCL_init_Y_obj2(J,K,B,Z,alpha)
        end

        borne_nb_Y_open = min(Ctr,length(RCL_Y))

        nb_Y_open = rand(1:borne_nb_Y_open)
        # println("RCL Y : ",RCL_Y)
        # println("rnd : ",nb_Y_open)
        Y = Vector{Vector{Int}}(undef,J)
        for j = 1:J
            Y[j] = zeros(Int,K)
        end
        for j = 1:nb_Y_open
            Y[RCL_Y[j]][1] = 1
        end
        

        if p <= half_P
            Y = reaffectation_concentrateurs_obj1(J,K,B,S,Y,Z)
            X = affectation_terminaux_obj1(I,J,C,Y)
            push!(pop_obj1,(X,Y,Z))
        else
            Y = reaffectation_concentrateurs_obj2(J,K,B,S,Y,Z)
            X = affectation_terminaux_obj2(I,J,C,Y)
            push!(pop_obj2,(X,Y,Z))
        end

        # println("Y = ",Y)
    end

    return pop_obj1,pop_obj2
end

#Exemple

# I = 5   
# J = 4
# K = 3
# C = [
# [3, 10, 3, 9],
# [11, 2, 17, 3],
# [17, 12, 2, 1],
# [14, 3, 13, 8],
# [7, 11, 12, 15]
# ]
# B = [
# [77, 59, 48],
# [39, 39, 77],
# [92, 76, 97],
# [45, 42, 94]
# ]
# S = [456, 480, 504]

# Z = [0,1,1]


# display(population_generation(I,J,K,C,B,S,10,0)[1])
