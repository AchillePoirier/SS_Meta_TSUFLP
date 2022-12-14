#instance didactique

I = 30 #client
J = 20 #site lvl 1
K = 10 #site lvl 2

inf_distance = 1
sup_distance = 40

inf_instal_nv1 = 50
sup_instal_nv1 = 200

inf_instal_nv2 = 400
sup_instal_nv2 = 600

# C : cout d'affectation entre un client et un concentrateur de niveau 1
# B : cout d'affectation d'un concentrateur de niveau 1 avec un cencentrateur de niveau 2
# H : cout d'installation d'un concentrateur de niveau
# S : cout d'installation d'un cencentrateur de niveau 1

function generation_instance(I,J,K,inf_distance,sup_distance,inf_instal_nv1,sup_instal_nv1,inf_instal_nv2,sup_instal_nv2)

    println("I = ",I)
    println("J = ",J)
    println("K = ",K)

    println("C = [")

    for i = 1:I
        print("[")
        for j = 1:J
            if j == J
                print(rand(inf_distance:sup_distance))
            else
                print(rand(inf_distance:sup_distance),", ")
            end
        end
        if i == I
            print("]\n")
        else
            print("],\n")
        end
    end
    println("]")


    println("B = [")

    for j = 1:J
        print("[")
        for k = 1:K
            if k == K
                print(rand(inf_distance:sup_distance)+rand(inf_instal_nv1:sup_instal_nv1))
            else
                print(rand(inf_distance:sup_distance)+rand(inf_instal_nv1:sup_instal_nv1),", ")
            end
        end
        if j == J
            print("]\n")
        else
            print("],\n")
        end
    end
    println("]")

    print("S = [")
    for k = 1:K
        if k == K
            print(rand(inf_instal_nv2:sup_instal_nv2))
        else
            print(rand(inf_instal_nv2:sup_instal_nv2),", ")
        end
    end
    print("]\n")


end


generation_instance(I,J,K,inf_distance,sup_distance,inf_instal_nv1,sup_instal_nv1,inf_instal_nv2,sup_instal_nv2)