
function objective_value_1(I,J,K,C,B,S,X,Y,Z)

    res_x = 0
    for i = 1:I
        for j = 1:J
            res_x += X[i][j]*C[i][j]
        end
    end

    res_y = 0
    for j = 1:J
        for k = 1:K
            res_y += Y[j][k]*(B[j][k])
        end
    end

    res_z = 0

    for k = 1:K
        res_z += Z[k]*S[k]
    end

    return res_x + res_y + res_z
 
end

function objective_value_2(I,J,K,C,B,S,X,Y,Z)

    moy_x = 0
    for i = 1:I
        for j = 1:J
            moy_x += X[i][j]*C[i][j]
        end
    end
    moy_x = moy_x/I

    res_x = 0
    for i = 1:I
        for j = 1:J
            res_x += X[i][j]* abs(C[i][j]-moy_x)
        end
    end

    moy_y = 0
    nb_y = 0
    for j = 1:J
        for k = 1:K
            moy_y += Y[j][k]*B[j][k]
            nb_y += Y[j][k]
        end
    end
    moy_y = moy_y/nb_y

    res_y = 0
    for j = 1:J
        for k = 1:K
            res_y += Y[j][k]* abs(B[j][k]-moy_y)
        end
    end

    return res_x + res_y
 
end

function affectation_terminaux_obj1(I,J,C,Y)
    #Vecteur d'ouverture des concentrateurs_nv1
    Y_opened = zeros(Int,J)
    for j = 1:J
        Y_opened[j] = sum(Y[j])
    end

    #Initialisation de X
    X = Vector{Vector{Int}}(undef,I)
    for i = 1:I
        X[i] = zeros(Int,J)
    end

    #Affectation terminaux/concentrateur_nv1 de plus faible cout
    for i = 1:I
        argmin = 0
        min = 9999999999999
        for j = 1:J
            if Y_opened[j] == 1
                if C[i][j] < min
                    argmin = j
                    min = C[i][j]
                end
            end
        end
        X[i][argmin] = 1
    end

    return X
end

function affectation_terminaux_obj2(I,J,C,Y)

        #Vecteur d'ouverture des concentrateurs_nv1
        Y_opened = zeros(Int,J)
        for j = 1:J
            Y_opened[j] = sum(Y[j])
        end
        nb_Y_opened = sum(Y_opened)
    
        #Initialisation de X
        X = Vector{Vector{Int}}(undef,I)
        for i = 1:I
            X[i] = zeros(Int,J)
        end

        #calcul de la distance moyenne entre les terminaux et les concentrateurs_nv1 ouverts
        moyennes = zeros(I)
        for i = 1:I
            for j = 1:J
                if Y_opened[j] == 1
                    moyennes[i] += C[i][j]
                end
            end
            moyennes[i] = moyennes[i]/nb_Y_opened
        end
        #println(moyennes)

        distance_moyenne_total = sum(moyennes)/I
            
        #Affectation terminaux/concentrateur_nv1 de plus faible cout
        for i = 1:I
            min = 99999999999999
            argmin = 0
            for j = 1:J
                if Y_opened[j] == 1
                    distance = abs(C[i][j]-distance_moyenne_total)
                    if distance < min
                        argmin = j
                        min = distance
                    end
                end
            end
            X[i][argmin] = 1
        end
    
        return X

end

function reaffectation_concentrateurs_obj1(J,K,B,S,Y,Z)
    #Vecteur d'ouverture des concentrateurs_nv1
    Y_opened = zeros(Int,J)
    for j = 1:J
        Y_opened[j] = sum(Y[j])
    end

    #Initialisation de Y
    Y_new = Vector{Vector{Int}}(undef,J)
    for j = 1:J
        Y_new[j] = zeros(Int,K)
    end

    #Affectation concentrateur_nv1/concentrateurs_nv2 de plus faible cout
    for j = 1:J
        if Y_opened[j] == 1
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
            Y_new[j][argmin] = 1
        end
    end
    return Y_new
end

function reaffectation_concentrateurs_obj2(J,K,B,S,Y,Z)

    #Vecteur d'ouverture des concentrateurs_nv1
    Y_opened = zeros(Int,J)
    for j = 1:J
        Y_opened[j] = sum(Y[j])
    end
    nb_Y_opened = sum(Y_opened)
    nb_Z_opened = sum(Z)

    #Initialisation de Y
    Y_new = Vector{Vector{Int}}(undef,J)
    for j = 1:J
        Y_new[j] = zeros(Int,K)
    end

    #calcul de la distance moyenne entre les terminaux et les concentrateurs_nv1 ouverts
    moyennes = zeros(J)
    for j = 1:J
        if Y_opened[j] == 1
            for k = 1:K
                if Z[k] == 1
                    moyennes[j] += B[j][k]
                end
            end
            moyennes[j] = moyennes[j]/nb_Z_opened
        end
    end
    #println(moyennes)

    distance_moyenne_total =  0 
    for j = 1:J
        if Y_opened[j]==1
            distance_moyenne_total += moyennes[j]
        end
    end
    distance_moyenne_total = distance_moyenne_total/nb_Y_opened

    #println(distance_moyenne_total)

        
    #Affectation concentrateur_nv1/concentrateurs_nv2 de plus faible cout
    for j = 1:J
        if Y_opened[j] == 1
            min = 99999999999999
            argmin = 0
            for k = 1:K
                if Z[k] == 1
                    distance = abs(B[j][k]-distance_moyenne_total)
                    if distance < min
                        argmin = k
                        min = distance
                    end
                end
            end
            Y_new[j][argmin] = 1
        end
    end

    return Y_new

end


function verif_sol(I,J,K,X,Y,Z)
    verif = true
    Y_opened = zeros(Int,J)
    for j = 1:J
        Y_opened[j] = sum(Y[j])
    end

    for i = 1:I
        for j = 1:J
            if X[i][j] == 1 && Y_opened[j] == 0
                verif = false
            end
        end
    end

    for j = 1:J
        for k = 1:K
            if Y[j][k] == 1 && Z[k] == 0
                verif = false
            end
        end
    end
    if verif == false
        println("ALERT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    end
end

# Z = [0,1,1]
# Y = [
#     [0,0,0],
#     [0,0,1],
#     [0,0,1],
#     [0,1,0]
# ]
# X = [
#     [0,0,0,1],
#     [0,0,0,1],
#     [0,0,1,0],
#     [0,1,0,0],
#     [0,0,1,0]
# ]
# verif_sol(5,4,3,X,Y,Z)

#Exemple 
#
# Y = [
#     [0,1],
#     [0,0],
#     [0,1]
# ]

# C = [
#     [5,4,7],
#     [9,7,6],
#     [2,5,3],
#     [5,4,8]
# ]

# X = affectation_terminaux_obj2(4,3,C,Y)




