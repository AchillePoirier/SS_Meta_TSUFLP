
#MONO OBJECTIF !!!
function RCL_init_Si(K,Si,alpha)

    indice_Si_sorted = sortperm(Si)
    #println(indice_Si_sorted)
    
    
    min = Si[indice_Si_sorted[1]]
    max = Si[indice_Si_sorted[K]]

    limit = min + (1 - alpha)*(max-min)

    #println("min = ",min," max = ",max," limit = ",limit)

    cut = 1
    while (Si[indice_Si_sorted[cut]] < limit) && (cut < K)
        cut+=1
    end

    if cut > 1
        cut -= 1
    end

    return indice_Si_sorted[1:cut]
end

#MONO OBJECTIF !!!
#on initialise Y comme si un seul concentrateur lvl 2 est ouvert
function RCL_init_Bi(k,J,B,alpha)
    Bi_k = zeros(Int,J)
    for j = 1:J
        Bi_k[j] = B[j][k]
    end
    #println(Bi_k)

    indice_Bi_sorted = sortperm(Bi_k)
    #println(indice_Bi_sorted)
    
    
    min = Bi_k[indice_Bi_sorted[1]]
    max = Bi_k[indice_Bi_sorted[J]]

    limit = min + (1 - alpha)*(max-min)

    #println("min = ",min," max = ",max," limit = ",limit)

    cut = 1
    while (Bi_k[indice_Bi_sorted[cut]] < limit) && (cut < J)
        cut+=1
    end

    if cut > 1
        cut -= 1
    end

    return indice_Bi_sorted[1:cut]
end


function population_generation(J,K,B,S,P,nb_obj,alpha)

    pop = []

    for o = 1:nb_obj

        RCL_Si = RCL_init_Si(K,S[o],alpha)
        n = length(RCL_Si)

        for p = 1:P

            k = rand(1:n)
            RCL_Bi = RCL_init_Bi(k,J,B[o],alpha)
            m = length(RCL_Bi)
            j = rand(1:m)

            z = zeros(Int,K)
            y = zeros(Int,J)

            z[k] = 1
            y[j] = 1
            
            append!(pop,[[y,z]])
        end
    end

    return pop
end


