#instance didactique

I = 10 #client
J = 7 #site lvl 1
K = 5 #site lvl 2

# C : cout d'affectation entre un client et un concentrateur de niveau 1
# B : cout d'affectation d'un concentrateur de niveau 1 avec un cencentrateur de niveau 2
# H : cout d'installation d'un concentrateur de niveau
# S : cout d'installation d'un cencentrateur de niveau 1

function generation_instance(I,J,K)

    println("C = [")

    for i = 1:I
        print("[")
        for j = 1:J
            if j == J
                print(rand(1:20))
            else
                print(rand(1:20),", ")
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
                print(rand(1:20))
            else
                print(rand(1:20),", ")
            end
        end
        if j == J
            print("]\n")
        else
            print("],\n")
        end
    end
    println("]")

    print("H = [")
    for j = 1:J
        if j == J
            print(rand(40:100))
        else
            print(rand(40:100),", ")
        end
    end
    print("]\n")

    print("S = [")
    for k = 1:K
        if k == K
            print(rand(40:100))
        else
            print(rand(40:100),", ")
        end
    end
    print("]\n")


end
