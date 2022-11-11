#instance didactique

I = 10 #client
J = 7 #site lvl 1
K = 5 #site lvl 2

# C : cout d'affectation entre un client et un concentrateur de niveau 1
# B : cout d'affectation d'un concentrateur de niveau 1 avec un cencentrateur de niveau 2 + cout d'installation du concentrateur de niveau 2
# S : cout d'installation d'un cencentrateur de niveau 1

function generation_instance(I,J,K)

    println("C1 = [")

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

    println("C2 = [")

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

    println("B1 = [")

    for j = 1:J
        print("[")
        opening = rand(40:100)
        for k = 1:K
            if k == K
                print(rand(1:20)+opening)
            else
                print(rand(1:20)+opening,", ")
            end
        end
        if j == J
            print("]\n")
        else
            print("],\n")
        end
    end
    println("]")

    println("B2 = [")

    for j = 1:J
        print("[")
        opening = rand(40:100)
        for k = 1:K
            if k == K
                print(rand(1:20)+opening)
            else
                print(rand(1:20)+opening,", ")
            end
        end
        if j == J
            print("]\n")
        else
            print("],\n")
        end
    end
    println("]")

    print("S1 = [")
    for k = 1:K
        if k == K
            print(rand(40:100))
        else
            print(rand(40:100),", ")
        end
    end
    print("]\n")

    print("S2 = [")
    for k = 1:K
        if k == K
            print(rand(40:100))
        else
            print(rand(40:100),", ")
        end
    end
    print("]\n")

    println("C = [C1,C2]")
    println("B = [B1,B2]")
    println("S = [S1,S2]")

end
