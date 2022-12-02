
function objective_value_1(I,J,K,C,B,H,S,X,Y,Z)

    res_x = 0
    for i = 1:I
        for j = 1:J
            res_x += X[i][j]*C[i][j]
        end
    end

    res_y = 0
    for j = 1:J
        for j = 1:K
            res_y += Y[j][k]*(B[j][k]+H[j])
        end
    end

    res_z = 0

    for k = 1:K
        res_z += Z[k]*S[k]
    end

    return res_x + res_y + res_z
 
end

function objective_value_2(I,J,K,C,B,H,S,X,Y,Z)

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
            res_y += Y[j][k]* abs(B[i][j]-moy_y)
        end
    end
 
end

function affectation_terminaux_obj1(I,J,Z1)

    X = Vector{Vector{Int}}(undef,I)
    for i = 1:I
        X[i] = zeros(Int,J)
    end

    

    return X
end

function affectation_terminaux_obj2(I,J,Z1)
end

affectation_terminaux_obj1(4,3,[1,0,0])




