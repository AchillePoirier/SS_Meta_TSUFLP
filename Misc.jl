
#A finir, je sais pas si c'est vraiment utile
objective_values(I,J,K,C,B,S,X,Y,Z,nb_objectif)

    res = zeros(nb_objectif)

    for o = 1:nb_objectif
        for i = 1:I
            for j = 1:J
                res[o] += X[i][j]*C[o][i][j]
            end
        end
 
end

