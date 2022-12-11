include("Misc.jl")

function tabu(I,J,K,C,B,S,X,Y,Z,tenure,tolerance,objectif)

    echo = false

    X_new = deepcopy(X)
    Y_new = deepcopy(Y)
    Z_new = deepcopy(Z)

    if echo == true
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
    end


    #----Swap----------------------------------------

    best_sol = Tuple{Tuple{Vector{Vector{Int}},Vector{Vector{Int}},Vector{Int}},Float64}

    if objectif == 1
        best_sol = ((deepcopy(X_new),deepcopy(Y_new),deepcopy(Z_new)),objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
    elseif objectif == 2
        best_sol = ((X_new,Y_new,Z_new),objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
    end
    
    salve = 1
    
    while true
        if echo == true
            println("========================================salve ",salve,"==========================================================")
        end
        global_improve = false
        # Swap Y

        #initialisation de la liste tabu
        tabu_list_Y = zeros(Int,J)

        iteration_Y = 1

        nb_non_improving_move_Y = 0

        #condition d'arret : nombre de mouvement non ameliorant > tolerance

        while nb_non_improving_move_Y <= tolerance
            if echo == true
                println("-------------------iteration ",iteration_Y,"-------------------------")
                println("Best sol :")
                ((X_best,Y_best,Z_best),best_obj_value) = best_sol
                println("Z = ",Z_best)
                println("Y = ",Y_best)
                println("X = ",X_best)
                println("obj value stock : ",best_obj_value)
                println("vrai obj value : ",objective_value_1(I,J,K,C,B,S,X_best,Y_best,Z_best))
                verif_sol(I,J,K,X_new,Y_new,Z_new)

            end
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
                    new_obj_value = 9999999999
                    
                    if objectif == 1
                        new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    elseif objectif == 2
                        new_obj_value = objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    end

                    ((),best_obj_value) = best_sol
                    if best_obj_value > new_obj_value
                        best_sol = ((deepcopy(X_new),deepcopy(Y_new),deepcopy(Z_new)),new_obj_value)
                        global_improve = true
                    end

                else
                    nb_non_improving_move_Y += 1
                end

                if echo == true
                    if objectif == 1
                        println("obj = ",objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
                    elseif objectif == 2
                        println("obj = ",objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
                    end

                    println("Z = ",Z_new)
                    println("Y = ",Y_new)
                    println("X = ",X_new)
                    verif_sol(I,J,K,X_new,Y_new,Z_new)
                end

                #Actualisation de la liste tabu
                tabu_list_Y[to_open] = iteration_Y + tenure
                if echo == true
                    println("tabu list : ",tabu_list_Y)
                end
            else
                nb_non_improving_move_Y += 1
            end
            iteration_Y += 1

            

        end

        ((X_new,Y_new,Z_new),) = deepcopy(best_sol)
        if echo == true
            println("passation")

            println("Z = ",Z_new)
            println("Y = ",Y_new)
            println("X = ",X_new)
            verif_sol(I,J,K,X_new,Y_new,Z_new)
            
        end




        
        #------------------------------------------------
        # Swap Z

        #initialisation de la liste tabu
        tabu_list_Z = zeros(Int,K)

        iteration_Z = 1
        nb_non_improving_move_Z = 0

        #condition d'arret : nombre de mouvement non ameliorant > tolerance
        while nb_non_improving_move_Z <= tolerance
            if echo == true
                println("-------------------iteration ",iteration_Z,"-------------------------")
                println("Z = ",Z_new)
                println("Y = ",Y_new)
                println("X = ",X_new)
                println("best obj value : ",best_obj_value)
                verif_sol(I,J,K,X_new,Y_new,Z_new)
            end
                
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
                    new_obj_value = 999999999999

                    if objectif == 1
                        new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    elseif objectif == 2
                        new_obj_value = objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new)
                    end

                    ((),best_obj_value) = best_sol
                    if best_obj_value > new_obj_value
                        best_sol = ((deepcopy(X_new),deepcopy(Y_new),deepcopy(Z_new)),new_obj_value)
                        global_improve = true
                    end
                else
                    nb_non_improving_move_Z += 1
                end

                if echo == true
                    if objectif == 1
                        println("obj = ",objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z_new))
                    elseif objectif == 2
                        println("obj = ",objective_value_2(I,J,K,C,B,S,X_new,Y_new,Z_new))
                    end
                    println("Z = ",Z_new)
                    println("Y = ",Y_new)
                    println("X = ",X_new)
                    verif_sol(I,J,K,X_new,Y_new,Z_new)
                end


                #Actualisation de la liste tabu
                tabu_list_Z[to_open] = iteration_Z + tenure
                if echo == true
                    println("tabu list : ",tabu_list_Z)
                end
            else
                nb_non_improving_move_Z += 1
            end
            iteration_Z += 1

        end

        if global_improve == false
            break
        end

        ((X_best,Y_best,Z_best),) = deepcopy(best_sol)
        X_new = deepcopy(X_best)
        Y_new = deepcopy(Y_best)
        Z_new = deepcopy(Z_best)

        salve += 1

    end


    ((X_best,Y_best,Z_best),best_obj_value) = best_sol

    if echo == true
        println(best_sol)

        println("Solution finale : ")
        println("obj = ",best_obj_value)
        println("Z = ",Z_best)
        println("Y = ",Y_best)
        println("X = ",X_best)
        verif_sol(I,J,K,X_best,Y_best,Z_best)
    end

    return deepcopy(best_sol)

end


function swap_Y(I,J,K,C,B,S,X,Y,Z,tabu_list,iteration,best_obj_value,objectif)

    echo = false

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


    obj_value = 99999999999999

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
        if echo == true
            println("Improving swap : closing ",to_close," and opening ",to_open)
        end
        return available_move,improve,to_close,to_open
    elseif available_move == true
        ((to_close,to_open),non_improving_obj) = best_non_improving_sol
        if echo == true
            println("Best non improving swap : closing ",to_close," and opening ",to_open)
        end
        return available_move,improve,to_close,to_open
    else
        if echo == true
            println("No available move")
        end
        return available_move,improve,to_close,to_open
    end
        
end

function swap_Z(I,J,K,C,B,S,X,Y,Z,tabu_list,iteration,best_obj_value,objectif)

    echo = false

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
        if echo == true
            println("Improving swap : closing ",to_close," and opening ",to_open)
        end
        return available_move,improve,to_close,to_open
    elseif available_move == true
        ((to_close,to_open),non_improving_obj) = best_non_improving_sol
        if echo == true
            println("Best non improving swap : closing ",to_close," and opening ",to_open)
        end
        return available_move,improve,to_close,to_open
    else
        if echo == true
            println("No available move")
        end
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

# println("--------------------------------------------------------------")
# ((X,Y,Z),obj_value) = tabu(5,4,3,C,B,S,X,Y,Z,10,3,2)
# println("Solution finale : ")
# println("Z = ",Z)
# println("Y = ",Y)
# println("X = ",X)


