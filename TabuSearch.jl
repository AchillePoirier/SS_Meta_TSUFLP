include("Misc.jl")

function tabu(I,J,K,C,B,S,X,Y,Z)
    
    #initialisation des listes tabus
    tabu_list_Y = zeros(Int,J)
    tabu_list_Z = zeros(Int,K)

    #----Drop----------------------------------------

    #Voisinnage drop concentrateurs nv1

    #On cherche dans le voisinnage drop seulement si il y a plus de 1 concentrateur ouvert.

    if (sum(sum(Y)) > 1)

        #Vecteur d'ouverture des concentrateurs_nv1
        Y_opened = zeros(Int,J)
        for j = 1:J
            Y_opened[j] = sum(Y[j])
        end

        i = 1
        improve = false
        move = 0

        while i < I && improve == false
            Y_new = deepcopy(Y)
            
        end


end



Z = [1,1,0]
Y = [
    [1,0,0],
    [0,0,0],
    [0,1,0],
    [0,0,0]
]



