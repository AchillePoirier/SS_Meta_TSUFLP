include("Misc.jl")

function tabu(I,J,K,C,B,S,X,Y,Z,tenure)
    
    #initialisation des listes tabus
    tabu_list_Y = zeros(Int,J)
    tabu_list_Z = zeros(Int,K)

    iteration = 1
    #----Drop----------------------------------------

    #Voisinnage drop concentrateurs nv1

    #On cherche dans le voisinnage drop seulement si il y a plus de 1 concentrateur ouvert.

    if (sum(sum(Y)) > 1)

        #Vecteur d'ouverture des concentrateurs_nv1
        Y_opened = zeros(Int,J)
        for j = 1:J
            Y_opened[j] = sum(Y[j])
        end

        j = 1
        improve = false

        obj_value = objective_value_1(I,J,K,C,B,S,X,Y,Z)

        Y_new = deepcopy(Y)
        #recherche de voisin en first-improving strategy
        while j < J && improve == false
            if (Y_opened[j] == 1 && tabu_list_Y[j] < iteration)
                Y_new[j] = zeros(Int,K)
                X_new = affectation_terminaux_obj1(I,J,C,Y_new)
                new_obj_value = objective_value_1(I,J,K,C,B,S,X_new,Y_new,Z)
                if new_obj_value > obj_value
                    improve = true
                end
            end
            j += 1
        end

    end
end

#Exemple

Z = [1,1,0]
Y = [
    [1,0,0],
    [0,0,0],
    [0,1,0],
    [0,0,0]
]
X = [
    [1, 0, 0, 0],
    [0, 0, 1, 0],
    [1, 0, 0, 0],
    [1, 0, 0, 0],
    [0, 0, 1, 0]
]

B = [
    [14,13,18],
    [15,12,14],
    [18,16,15],
    [12,14,18]
]

S = [26,33,30]

C = [
    [5,4,7,3],
    [9,7,6,4],
    [2,5,3,7],
    [5,4,8,6],
    [7,2,3,4]
]
#affectation_terminaux_obj1(5,4,C,Y)

tabu(5,4,3,C,B,S,X,Y,Z,4)