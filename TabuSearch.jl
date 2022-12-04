include("Misc.jl")

function tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,objectif)

    X_new = deepcopy(X)
    Y_new = deepcopy(Y)
    Z_new = deepcopy(Z)

    println("-------------------------------------------------------------")
    println("Solution initiale : ")
    println("Z = ",Z_new)
    println("Y = ",Y_new)
    println("X = ",X_new)
    if objectif == 1
        println("obj = ",objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
    elseif objectif == 2
        println("obj = ",objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
    end


    #----Swap----------------------------------------

    if objectif == 1
        best_sol = ((X_new,Y_new,Z_new),objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
    elseif objectif == 2
        best_sol = ((X_new,Y_new,Z_new),objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
    end

    salve = 1
    
    while true
        println("========================================salve ",salve,"==========================================================")
        global_improve = false
        # Swap Y

        #initialisation de la liste tabu
        tabu_list_Y = zeros(Int,J)

        iteration_Y = 1

        nb_non_improving_move_Y = 0

        #condition d'arret : nombre de mouvement non ameliorant > tolerance

        while nb_non_improving_move_Y <= tolerance
            println("-------------------iteration ",iteration_Y,"-------------------------")

            #recherche du mouvement a appliquer dans le voisinnage swap
            ((),best_obj_value) = best_sol
            available_move,improve,to_close,to_open = swap_Y(I,J,K,C,B,S,X_new,Y_new,Z_new,tabu_list_Y,iteration_Y,best_obj_value,objectif)

            #Application du swap
            if available_move == true

                Y_new[to_close] = zeros(Int,K)
                Y_new[to_open][1] = 1

                if objectif == 1
                    Y_new = reaffectation_concentrateurs_obj1(J,K,B,S,Y_new,Z_new)
                    X_new = affectation_terminaux_obj1(I,J,C,Y_new)
                elseif objectif == 2
                    Y_new = reaffectation_concentrateurs_obj2(J,K,B,S,Y_new,Z_new)
                    X_new = affectation_terminaux_obj2(I,J,C,Y_new)
                end

                if improve==true
                    nb_non_improving_move_Y = 0
                    
                    if objectif == 1
                        new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    elseif objectif == 2
                        new_obj_value = objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    end

                    ((X_best,Y_best,Z_best),best_obj_value) = best_sol
                    if best_obj_value > new_obj_value
                        best_sol = ((X_new,Y_new,Z_new),new_obj_value)
                        global_improve = true
                    end

                else
                    nb_non_improving_move_Y += 1
                end

                
                if objectif == 1
                    println("obj = ",objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
                elseif objectif == 2
                    println("obj = ",objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
                end

                println("Z = ",Z_new)
                println("Y = ",Y_new)
                println("X = ",X_new)

                #Actualisation de la liste tabu
                tabu_list_Y[to_open] = iteration_Y + tenure
                println("tabu list : ",tabu_list_Y)
            else
                nb_non_improving_move_Y += 1
            end
            iteration_Y += 1

            

        end

        ((X_new,Y_new,Z_new),) = best_sol

        
        #------------------------------------------------
        # Swap Z

        #initialisation de la liste tabu
        tabu_list_Z = zeros(Int,K)

        iteration_Z = 1
        nb_non_improving_move_Z = 0

        #condition d'arret : nombre de mouvement non ameliorant > tolerance
        while nb_non_improving_move_Z <= tolerance
            #((),best_obj_value) = best_sol
            println("-------------------iteration ",iteration_Z,"-------------------------")
                println("Z = ",Z_new)
                println("Y = ",Y_new)
                println("X = ",X_new)
                println("best obj value : ",best_obj_value)
                
            #recherche du mouvement a appliquer dans le voisinnage swap
            available_move,improve,to_close,to_open = swap_Z(I,J,K,C,B,S,X_new,Y_new,Z_new,tabu_list_Z,iteration_Z,best_obj_value,objectif)

            #Application du swap
            if available_move == true

                Z_new[to_close] = 0
                Z_new[to_open] = 1
                
                if objectif == 1
                    Y_new = reaffectation_concentrateurs_obj1(J,K,B,S,Y_new,Z_new)
                elseif objectif == 2
                    Y_new = reaffectation_concentrateurs_obj2(J,K,B,S,Y_new,Z_new)
                end

                
                if improve==true

                    nb_non_improving_move_Z = 0

                    if objectif == 1
                        new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    elseif objectif == 2
                        new_obj_value = objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    end

                    ((X_best,Y_best,Z_best),best_obj_value) = best_sol
                    if best_obj_value > new_obj_value
                        best_sol = ((X_new,Y_new,Z_new),new_obj_value)
                        global_improve = true
                    end
                else
                    nb_non_improving_move_Z += 1
                end

                
                if objectif == 1
                    println("obj = ",objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
                elseif objectif == 2
                    println("obj = ",objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
                end
                println("Z = ",Z_new)
                println("Y = ",Y_new)
                println("X = ",X_new)

                #Actualisation de la liste tabu
                tabu_list_Z[to_open] = iteration_Z + tenure
                println("tabu list : ",tabu_list_Z)
            else
                nb_non_improving_move_Z += 1
            end
            iteration_Z += 1

        end

        if global_improve == false
            break
        end

        ((X_new,Y_new,Z_new),) = best_sol

        salve += 1

    end


    ((X_best,Y_best,Z_best),best_obj_value) = best_sol
    println(best_sol)

    println("Solution finale : ")
    println("obj = ",best_obj_value)
    println("Z = ",Z_best)
    println("Y = ",Y_best)
    println("X = ",X_best)

    #----Drop----------------------------------------

#    Do While : tant qu'un drop_Y ou un Drop_Z est ameliorant, on continue a chercher dans le voisinnage Drop
    # while true
    #     has_improve = false
    #     println("ici ",X)
    #     #Voisinnage Drop_Y
    #     improve = drop_Y(I,J,K,C,B,S,X,Y,Z)
    #     if improve == true
    #         has_improve = true
    #     end
    #     while improve == true
    #         improve = drop_Y(I,J,K,C,B,S,X,Y,Z)
    #     end

    #     #Voisinnage Drop_Z
    #     improve = drop_Z(I,J,K,C,B,S,X,Y,Z)
    #     if improve == true
    #         has_improve = true
    #     end
    #     while improve == true
    #         improve = drop_Z(I,J,K,C,B,S,X,Y,Z)
    #     end

    #     if has_improve == false
    #         break
    #     end

    # end
end


function swap_Y(I,J,K,C,B,S,X,Y,Z,tabu_list,iteration,best_obj_value,objectif)

    #Vecteur d'ouverture des concentrateurs_nv1
    Y_opened = zeros(Int,J)
    for j = 1:J
        Y_opened[j] = sum(Y[j])
    end

    #indices des concentrateurs_nv1 ouverts
    Y_opened_arg = Vector{Int}(undef,0)

    #indices des concentrateurs_nv1 fermes
    Y_closed_arg = Vector{Int}(undef,0)

    for j = 1:J
        if Y_opened[j] == 1
            append!(Y_opened_arg,j)
        else
            append!(Y_closed_arg,j)
        end
    end

    #nombre de concentrateurs_nv1 ouverts
    nb_Y_opened = length(Y_opened_arg)
    #nombre de concentrateurs_nv1 fermes
    nb_Y_closed = J-nb_Y_opened

    #println("Opened : ",Y_opened_arg)
    #println("Closed : ",Y_closed_arg)
    
    #indice des concentrateurs a ouvrir et fermer pour faire le swap
    to_open = 0
    to_close = 0

    #iterateur sur les concentrateurs ouverts
    j_open = 1
    #indique si le voisinnage trouve est ameliorant
    improve = false


    if objectif == 1
        obj_value = objective_value_1(I,J,K,C,B,S,X,Y,Z)
    elseif objectif == 2
        obj_value = objective_value_2(I,J,K,C,B,S,X,Y,Z)
    end

    #println("obj value : ",obj_value)

    #initialisation de la meilleure solution non ameliorante
    #format : ((conc a fermer,conc a ouvrir),obj value resultant)
    best_non_improving_sol = ((0,0),9999999999999)

    #indique si il y a un mouvement possible dans le voisinnage
    available_move = false

    #recherche de voisin en first-improving strategy
    while j_open <= nb_Y_opened && improve == false

        #iterateur sur les concentrateurs fermes
        j_close = 1
        while j_close <= nb_Y_closed && improve == false
            Y_new = deepcopy(Y)
            #println("Swap Y : closing ",Y_opened_arg[j_open]," and opening ",Y_closed_arg[j_close])

            #fermeture du concentrateur_nv1 j_open
            Y_new[Y_opened_arg[j_open]] = zeros(Int,K)

            #Ouverture du concentrateur_nv1 j_close, et affectation arbitraire de celui ci au concentrateur_nv2 1.
            Y_new[Y_closed_arg[j_close]][1] = 1

            if objectif == 1
                #Reaffectation des concentraterus_nv1.
                Y_new = reaffectation_concentrateurs_obj1(J,K,B,S,Y_new,Z)
                #println("Y = ",Y_new)

                X_new = affectation_terminaux_obj1(I,J,C,Y_new)
                #println("X = ",X_new)

                new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z)
                #println("obj = ",new_obj_value)
            elseif objectif == 2
                #Reaffectation des concentraterus_nv1.
                Y_new = reaffectation_concentrateurs_obj2(J,K,B,S,Y_new,Z)
                #println("Y = ",Y_new)

                X_new = affectation_terminaux_obj2(I,J,C,Y_new)
                #println("X = ",X_new)

                new_obj_value = objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z)
                #println("obj = ",new_obj_value)
            end

            #Si le solution est ameliorante et si le concentrateur ferme que l'on souhaite ouvrir n'est pas tabu
            #OU si le critère d'aspiration est rempli 
            if (new_obj_value < obj_value && tabu_list[Y_closed_arg[j_close]] < iteration ) || (new_obj_value < best_obj_value)
                improve = true
                available_move = true
                to_open = Y_closed_arg[j_close]
                to_close = Y_opened_arg[j_open]
            else 
                ((a,b),non_improving_obj) = best_non_improving_sol
                #Si le solution non ameliorante est la meilleure des sol non ameliorante
                # ET Si le concentrateur ferme que l'on souhaite ouvrir n'est pas tabu
                if non_improving_obj > new_obj_value && tabu_list[Y_closed_arg[j_close]] < iteration
                    to_open = Y_closed_arg[j_close]
                    to_close = Y_opened_arg[j_open]
                    best_non_improving_sol = ((to_close,to_open),new_obj_value)
                    available_move = true
                end
            end

            #println("Improving : ",improve)
            j_close += 1
        end
        j_open += 1
    end

    if improve==true
        println("Improving swap : closing ",to_close," and opening ",to_open)
        return available_move,improve,to_close,to_open
    elseif available_move == true
        ((to_close,to_open),non_improving_obj) = best_non_improving_sol
        println("Best non improving swap : closing ",to_close," and opening ",to_open)
        return available_move,improve,to_close,to_open
    else
        println("No available move")
        return available_move,improve,to_close,to_open
    end
        
end

function swap_Z(I,J,K,C,B,S,X,Y,Z,tabu_list,iteration,best_obj_value,objectif)

    #Vecteur d'ouverture des concentrateurs_nv1
    Y_opened = zeros(Int,J)
    for j = 1:J
        Y_opened[j] = sum(Y[j])
    end

    #indices des concentrateurs_nv2 ouverts
    Z_opened_arg = Vector{Int}(undef,0)

    #indices des concentrateurs_nv2 fermes
    Z_closed_arg = Vector{Int}(undef,0)

    for k = 1:K
        if Z[k] == 1
            append!(Z_opened_arg,k)
        else
            append!(Z_closed_arg,k)
        end
    end

    #nombre de concentrateurs_nv2 ouverts
    nb_Z_opened = length(Z_opened_arg)
    #nombre de concentrateurs_nv2 fermes
    nb_Z_closed = K-nb_Z_opened

    # println("Opened : ",Z_opened_arg)
    # println("Closed : ",Z_closed_arg)
    
    #indice des concentrateurs a ouvrir et fermer pour faire le swap
    to_open = 0
    to_close = 0

    #iterateur sur les concentrateurs ouverts
    k_open = 1
    #indique si le voisinnage trouve est ameliorant
    improve = false


    if objectif == 1
        obj_value = objective_value_1(I,J,K,C,B,S,X,Y,Z)
    elseif objectif == 2
        obj_value = objective_value_2(I,J,K,C,B,S,X,Y,Z)
    end

    #initialisation de la meilleure solution non ameliorante
    #format : ((conc a fermer,conc a ouvrir),obj value resultant)
    best_non_improving_sol = ((0,0),9999999999999)

    #indique si il y a un mouvement possible dans le voisinnage
    available_move = false

    #recherche de voisin en first-improving strategy
    while k_open <= nb_Z_opened && improve == false

        #iterateur sur les concentrateurs fermes
        k_close = 1
        while k_close <= nb_Z_closed && improve == false
            Z_new = deepcopy(Z)
            #println("Swap Z : closing ",Z_opened_arg[k_open]," and opening ",Z_closed_arg[k_close])

            #fermeture du concentrateur_nv2 j_open
            Z_new[Z_opened_arg[k_open]] = 0

            #Ouverture du concentrateur_nv2 j_close
            Z_new[Z_closed_arg[k_close]] = 1



            if objectif == 1
                #Reaffectation des concentraterus_nv1.
                Y_new = reaffectation_concentrateurs_obj1(J,K,B,S,Y,Z_new)
                #println("Z = ",Z_new)

                new_obj_value = objective_value_1(I,J,K,C,B,S,X,Y_new,Z_new)
                #println("obj = ",new_obj_value)
            elseif objectif == 2
                #Reaffectation des concentraterus_nv1.
                Y_new = reaffectation_concentrateurs_obj2(J,K,B,S,Y,Z_new)
                #println("Z = ",Z_new)

                new_obj_value = objective_value_2(I,J,K,C,B,S,X,Y_new,Z_new)
                #println("obj = ",new_obj_value)
            end

            #Si le solution est ameliorante et si le concentrateur ferme que l'on souhaite ouvrir n'est pas tabu
            #OU si le critère d'aspiration est rempli 
            if (new_obj_value < obj_value && tabu_list[Z_closed_arg[k_close]] < iteration ) || (new_obj_value < best_obj_value)
                improve = true
                available_move = true
                to_open = Z_closed_arg[k_close]
                to_close = Z_opened_arg[k_open]
            else 
                ((a,b),non_improving_obj) = best_non_improving_sol
                #Si le solution non ameliorante est la meilleure des sol non ameliorante
                # ET Si le concentrateur ferme que l'on souhaite ouvrir n'est pas tabu
                if non_improving_obj > new_obj_value && tabu_list[Z_closed_arg[k_close]] < iteration
                    to_open = Z_closed_arg[k_close]
                    to_close = Z_opened_arg[k_open]
                    best_non_improving_sol = ((to_close,to_open),new_obj_value)
                    available_move = true
                end
            end

            #println("Improving : ",improve)
            k_close += 1
        end
        k_open += 1
    end

    if improve==true
        println("Improving swap : closing ",to_close," and opening ",to_open)
        return available_move,improve,to_close,to_open
    elseif available_move == true
        ((to_close,to_open),non_improving_obj) = best_non_improving_sol
        println("Best non improving swap : closing ",to_close," and opening ",to_open)
        return available_move,improve,to_close,to_open
    else
        println("No available move")
        return available_move,improve,to_close,to_open
    end
        
end



#Exemple
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

# Z = [0,1,1]
# Y = [
#     [0,0,0],
#     [0,0,1],
#     [0,0,1],
#     [0,0,0]
# ]
# X = affectation_terminaux_obj1(5,4,C,Y)



#affectation_terminaux_obj2(5,4,C,Y)
#affectation_concentrateurs_obj2(4,3,B,S,Y,Z)
# println("--------------------------------------------------------------")
#tabu(5,4,3,C,B,S,X,Y,Z,10,3,2)
# println("Solution finale : ")
# println("Z = ",Z)
# println("Y = ",Y)
# println("X = ",X)




# function drop_Y(I,J,K,C,B,S,X,Y,Z)

#     if (sum(sum(Y)) > 1)

#         #Vecteur d'ouverture des concentrateurs_nv1
#         Y_opened = zeros(Int,J)
#         for j = 1:J
#             Y_opened[j] = sum(Y[j])
#         end

#         j = 1
#         improve = false

#         obj_value = objective_value_1(I,J,K,C,B,S,X,Y,Z)
#         println("obj value : ",obj_value)

#         Y_new = deepcopy(Y)
#         X_new = deepcopy(X)
#         #recherche de voisin en first-improving strategy
#         while j < J && improve == false
#             if (Y_opened[j] == 1)
#                 println("Drop Y at ",j)
#                 Y_new_j = Y_new[j]
#                 Y_new[j] = zeros(Int,K)
#                 println("Y = ",Y_new)

#                 X_new = affectation_terminaux_obj1(I,J,C,Y_new)
#                 println("X = ",X_new)

#                 new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z)
#                 println("obj = ",new_obj_value)

#                 if new_obj_value < obj_value
#                     improve = true
#                 end
#                 Y_new[j] = Y_new_j

#                 println("Improving : ",improve)
#             end
#             j += 1
#         end
#         move = j-1

#         #Application du Drop
#         Y[move] = zeros(Int,K)
#         X = X_new

#         return improve
#     end
# end

# function drop_Z(I,J,K,C,B,S,X,Y,Z)

#     if (sum(Z) > 1)

#         k = 1
#         improve = false

#         obj_value = objective_value_1(I,J,K,C,B,S,X,Y,Z)
#         println("obj value : ",obj_value)

#         Z_new = deepcopy(Z)
#         Y_new = deepcopy(Y)
#         #recherche de voisin en first-improving strategy
#         while k < K && improve == false
#             if (Z[k] == 1)
#                 println("Drop Z at ",k)
#                 Z_new[k] = 0

#                 println("Z = ",Z_new)

#                 Y_new = reaffectation_concentrateurs_obj1(J,K,B,S,Y,Z_new)
#                 println("Y = ",Y_new)

#                 new_obj_value = objective_value_1(I,J,K,C,B,S,X,Y_new,Z_new)
#                 println("obj = ",new_obj_value)

#                 if new_obj_value < obj_value
#                     improve = true
#                 end
#                 Z_new[k] = 1

#                 println("Improving : ",improve)
#             end
#             k += 1
#         end
#         move = k-1

#         #Application du Drop
#         Z[move] = 0
#         Y = Y_new
#         println(" X Z = ",X)

#         return improve
#     end
# end