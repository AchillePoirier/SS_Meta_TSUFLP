include("Misc.jl")
include("Skiplist.jl")

function pathRelinking(I,J,K,C,B,S,X1,Y1,Z1,X2,Y2,Z2)

    #Vecteur d'ouverture des concentrateurs_nv1
    Y1_opened = zeros(Int,J)
    Y2_opened = zeros(Int,J)
    for j = 1:J
        Y1_opened[j] = sum(Y1[j])
        Y2_opened[j] = sum(Y2[j])
    end

    skl = skiplist_init()

    skl = skiplist_insertion(skl,X1,Y1,Z1,objective_value_1(I,J,K,C,B,S,X1,Y1,Z1),objective_value_2(I,J,K,C,B,S,X1,Y1,Z1))
    skl = skiplist_insertion(skl,X2,Y2,Z2,objective_value_1(I,J,K,C,B,S,X2,Y2,Z2),objective_value_2(I,J,K,C,B,S,X2,Y2,Z2))

    skl_display(skl)

    Y_in = Vector{Int}(undef,0)
    Y_out = Vector{Int}(undef,0)

    for j = 1:J
        if Y1_opened[j] == 1 && Y2_opened[j] == 0
            push!(Y_out,j)
        elseif Y1_opened[j] == 0 && Y2_opened[j] == 1
            push!(Y_in,j)
        end
    end

    Z_in = Vector{Int}(undef,0)
    Z_out = Vector{Int}(undef,0)

    for k = 1:K
        if Z1[k] == 1 && Z2[k] == 0
            push!(Z_out,k)
        elseif Z1[k] == 0 && Z2[k] == 1
            push!(Z_in,k)
        end
    end

    println("Y1 ",Y1_opened," Z1 ",Z1)
    println("Y2 ",Y2_opened," Z2 ",Z2)
    println("Y_in ",Y_in," Y_out ",Y_out)
    println("Z_in ",Z_in," Z_out ",Z_out)

    



    

end

I = 5
J = 4
K = 3

B = [
    [14,13,18],
    [15,12,14],
    [10,16,15],
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

Z1 = [0,1,0]
Y1 = [
    [0,0,0],
    [0,1,0],
    [0,1,0],
    [0,0,0]
]
X1 = affectation_terminaux_obj1(5,4,C,Y1)

Z2 = [0,0,1]
Y2 = [
    [0,0,1],
    [0,0,0],
    [0,0,0],
    [0,0,1]
]
X2 = affectation_terminaux_obj1(5,4,C,Y2)

pathRelinking(I,J,K,C,B,S,X1,Y1,Z1,X2,Y2,Z2)