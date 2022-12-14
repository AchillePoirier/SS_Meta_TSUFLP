include("Misc.jl")

using JuMP
using GLPK
using vOptGeneric
using Plots
using CPLEX

function solver(I,J,K,C,B,S,Ctr)

    TSUFLP = vModel( CPLEX.Optimizer  )
    set_silent(TSUFLP)

    X = []

    for i = 1:I
        Xi = []
        for j = 1:J
            x = @variable(TSUFLP, binary = true) 
            push!(Xi,x)
        end
        push!(X,Xi)
    end

    Y = []

    for j= 1:J
        Yj = []
        for k = 1:K
            y = @variable(TSUFLP, binary = true) 
            push!(Yj,y)
        end
        push!(Y,Yj)
    end

    Z = []
    for k = 1:K
        z = @variable(TSUFLP, binary = true) 
        push!(Z,z)
    end

    #variables de linearisation de la valeur absolue
    U = []

    for i = 1:I
        Ui = []
        for j = 1:J
            u = @variable(TSUFLP) 
            push!(Ui,u)
        end
        push!(U,Ui)
    end

    V = []

    for j= 1:J
        Vj = []
        for k = 1:K
            v = @variable(TSUFLP) 
            push!(Vj,v)
        end
        push!(V,Vj)
    end

    #varaibles de linearisation de la moyenne

    sigma = @variable(TSUFLP)

    MU = []

    for j = 1:J
        MU_i = []
        for k = 1:K
            mu = @variable(TSUFLP) 
            push!(MU_i,mu)
        end
        push!(MU,MU_i)
    end

    moy_x = 0
    for i = 1:I
        for j = 1:J
            moy_x += X[i][j]*C[i][j]
        end
    end
    moy_x = moy_x/I

    max_B = 0
    for j = 1:J
        for k = 1:K
            if B[j][k] > max_B
                max_B = B[j][k]
            end
        end
    end
    
    @addobjective( TSUFLP, Min, sum(U[i][j] for i in 1:I for j in 1:J) + sum(V[j][k] for j in 1:J for k in 1:K ) )

    @addobjective( TSUFLP, Min, objective_value_1(I,J,K,C,B,S,X,Y,Z))

    Mx = 17
    My = 97
    
    #Contraintes de linearisation pour la valeur absolue
    @constraint( TSUFLP , [i = 1:I , j = 1:J] , U[i][j]  >= C[i][j] - moy_x - (1-X[i][j])*Mx)
    @constraint( TSUFLP , [i = 1:I , j = 1:J] , U[i][j]  >= moy_x - C[i][j] - (1-X[i][j])*Mx)

    @constraint( TSUFLP , [j = 1:J , k = 1:K] , V[j][k]  >=  B[j][k] - sigma - (1-Y[j][k])*My)
    @constraint( TSUFLP , [j = 1:J , k = 1:K] , V[j][k]  >= sigma - B[j][k] - (1-Y[j][k])*My)

    @constraint( TSUFLP , [i = 1:I , j = 1:J] , U[i][j]  >= 0)
    @constraint( TSUFLP , [j = 1:J , k = 1:K] , V[j][k]  >= 0)


    # @constraint( TSUFLP , [j = 1:J , k = 1:K] , Vy[j][k]  >= My)

    # @constraint( TSUFLP , [i = 1:I , j = 1:J] , U[i][j]  <= Mx)
    # @constraint( TSUFLP , [j = 1:J , k = 1:K] , V[j][k]  <= My)

    # @constraint( TSUFLP , [i = 1:I , j = 1:J] , Ux[i][j]  <= U[i][j] - (1-X[i][j])*Mx )
    # @constraint( TSUFLP , [j = 1:J , k = 1:K] , Vy[j][k]  <= V[j][k] - (1-Y[j][k])*My )

    #Contraintes de linearisation pour la moyenne de y


    @constraint( TSUFLP , sum(MU[j][k] for j in 1:J for k in 1:K) == sum(Y[j][k]*B[j][k] for j in 1:J for k in 1:K ))
    @constraint( TSUFLP , [j = 1:J , k = 1:K] , MU[j][k] <= MU[j][k]*My)
    @constraint( TSUFLP , [j = 1:J , k = 1:K] , MU[j][k] <= sigma)
    @constraint( TSUFLP , [j = 1:J , k = 1:K] , MU[j][k] >= sigma - My*(1-Y[j][k]))


    @constraint( TSUFLP , [i = 1:I] , sum(X[i][j] for j in 1:J) == 1 ) #contrainte (2)
    @constraint( TSUFLP , [i = 1:I , j = 1:J] , X[i][j] <= sum(Y[j][k] for k in 1:K )) #contrainte (3)
    @constraint( TSUFLP , [j = 1:J , k = 1:K] , Y[j][k] <= Z[k])#contrainte (4)
    @constraint( TSUFLP , [j = 1:J] , sum(Y[j][k] for k in 1:K) <= 1 )#contrainte (5)

    #@constraint( TSUFLP, sum(Y[j][k] for j in 1:J for k in 1:K ) <= Ctr )
    println("balise 1")
    vSolve(TSUFLP, method=:epsilon, step = 500.0)
    println("balise 2")

    points = getY_N(TSUFLP)
    println("balise 3")

    println(points)
    
    plot_axe1 = []
    plot_axe2 = []

    for s in points
        obj1_value = s[1]
        obj2_value = s[2]
        push!(plot_axe1,obj1_value)
        push!(plot_axe2,obj2_value)
    end

    printX_E(TSUFLP)

    scatter(plot_axe1,plot_axe2)
end

function objective_value_2_linear(I,J,K,C,B,S,U,V,Z)

    res_x = 0
    for i = 1:I
        for j = 1:J
            res_x += U[i][j]
        end
    end

    res_y = 0
    for j = 1:J
        for k = 1:K
            res_y += V[j][k]
        end
    end

    return res_x + res_y
end

# I = 5   
# J = 4
# K = 3
# C = [
# [3, 10, 3, 9],
# [11, 2, 17, 3],
# [17, 12, 2, 1],
# [14, 3, 13, 8],
# [7, 11, 12, 15]
# ]

# B = [
# [77, 97, 48],
# [39, 39, 77],
# [92, 76, 97],
# [65, 42, 94]
# ]
# S = [456, 490, 504]

    I = 30  
    J = 20
    K = 10
    C = [ 
    [18, 6, 37, 1, 27, 23, 28, 10, 31, 2, 13, 12, 5, 32, 18, 6, 20, 39, 33, 18],   
    [21, 25, 33, 21, 8, 13, 36, 35, 28, 7, 28, 24, 7, 24, 36, 23, 26, 23, 38, 6],  
    [29, 9, 26, 17, 4, 38, 33, 40, 39, 13, 19, 15, 13, 33, 25, 28, 14, 17, 23, 21],
    [19, 5, 2, 19, 3, 33, 28, 34, 34, 21, 13, 40, 10, 20, 27, 37, 35, 24, 22, 22], 
    [21, 11, 37, 15, 30, 4, 40, 22, 34, 23, 31, 31, 5, 10, 31, 25, 23, 24, 20, 19],
    [19, 19, 21, 8, 13, 2, 19, 27, 39, 30, 38, 32, 8, 10, 37, 1, 21, 16, 17, 2],   
    [31, 10, 19, 23, 30, 36, 35, 32, 35, 15, 8, 2, 7, 36, 8, 15, 31, 2, 9, 36],    
    [1, 13, 8, 32, 7, 6, 11, 6, 26, 40, 8, 28, 17, 37, 8, 7, 40, 34, 31, 2],       
    [27, 11, 30, 31, 18, 10, 7, 38, 9, 7, 1, 6, 30, 31, 17, 16, 11, 7, 19, 24],    
    [29, 34, 38, 11, 20, 34, 24, 26, 26, 18, 36, 2, 23, 19, 33, 36, 35, 29, 9, 30],
    [1, 18, 32, 28, 5, 23, 2, 14, 34, 17, 23, 33, 11, 20, 25, 9, 29, 3, 10, 34],   
    [36, 22, 11, 2, 17, 33, 1, 5, 33, 40, 3, 20, 6, 28, 30, 7, 13, 38, 26, 28],    
    [8, 38, 36, 11, 35, 13, 33, 38, 5, 10, 13, 3, 20, 26, 2, 7, 35, 35, 33, 31],   
    [4, 33, 2, 29, 11, 40, 26, 11, 11, 28, 38, 18, 18, 39, 25, 21, 18, 14, 13, 23],
    [5, 11, 26, 15, 37, 16, 4, 14, 30, 11, 21, 28, 37, 12, 4, 6, 18, 16, 36, 9],   
    [15, 28, 27, 10, 26, 37, 38, 25, 18, 25, 14, 26, 35, 7, 33, 19, 2, 11, 27, 35],
    [13, 15, 35, 19, 33, 26, 20, 38, 17, 23, 19, 7, 28, 28, 39, 2, 29, 19, 26, 18],
    [12, 38, 11, 22, 39, 17, 24, 8, 40, 13, 9, 32, 23, 19, 19, 25, 17, 18, 13, 32],
    [7, 35, 8, 1, 40, 21, 10, 22, 13, 33, 24, 24, 32, 15, 25, 29, 14, 37, 28, 13], 
    [27, 29, 6, 6, 7, 31, 7, 21, 11, 15, 23, 25, 33, 32, 9, 20, 38, 34, 39, 38],   
    [14, 13, 36, 29, 20, 22, 32, 20, 36, 16, 28, 29, 29, 29, 9, 4, 39, 20, 39, 23],
    [9, 26, 1, 37, 5, 10, 23, 32, 8, 11, 35, 16, 11, 26, 6, 19, 38, 27, 7, 26],    
    [14, 34, 37, 2, 6, 40, 31, 15, 18, 32, 34, 8, 13, 18, 25, 4, 14, 35, 16, 21],  
    [40, 7, 35, 19, 14, 37, 38, 11, 16, 15, 21, 35, 25, 5, 16, 8, 17, 30, 32, 11], 
    [2, 35, 32, 35, 21, 22, 38, 9, 8, 26, 21, 15, 37, 36, 31, 27, 32, 11, 10, 9],  
    [35, 7, 30, 28, 12, 34, 16, 8, 14, 12, 24, 25, 25, 10, 16, 27, 40, 7, 31, 3],  
    [15, 23, 3, 37, 29, 35, 15, 38, 33, 10, 24, 15, 14, 33, 26, 9, 35, 27, 29, 27],
    [10, 37, 25, 11, 33, 5, 24, 25, 24, 27, 3, 40, 16, 12, 12, 19, 4, 37, 23, 39], 
    [36, 36, 3, 33, 19, 36, 14, 30, 7, 13, 22, 4, 38, 6, 13, 40, 37, 18, 6, 29],   
    [37, 4, 4, 21, 9, 33, 27, 4, 24, 8, 5, 6, 6, 33, 27, 35, 27, 17, 28, 11]       
    ]
    B = [
    [87, 98, 193, 93, 130, 194, 61, 229, 73, 201],
    [189, 101, 105, 106, 81, 69, 176, 202, 113, 144],
    [148, 134, 67, 195, 149, 189, 109, 159, 96, 177],
    [183, 198, 86, 100, 63, 113, 122, 118, 191, 141],
    [214, 110, 174, 125, 185, 146, 71, 120, 189, 57],
    [129, 138, 124, 206, 109, 112, 98, 68, 92, 166],   
    [99, 212, 196, 172, 145, 174, 169, 97, 82, 105],   
    [136, 201, 173, 154, 234, 190, 56, 180, 137, 152], 
    [97, 211, 229, 210, 152, 189, 195, 132, 187, 189], 
    [137, 147, 136, 102, 233, 102, 129, 158, 177, 93], 
    [85, 198, 135, 144, 93, 147, 125, 168, 214, 101],  
    [175, 216, 94, 91, 99, 127, 191, 217, 147, 88],    
    [131, 214, 146, 237, 138, 182, 189, 114, 149, 203],
    [68, 144, 170, 142, 213, 162, 167, 100, 121, 110], 
    [182, 139, 156, 204, 163, 108, 133, 152, 139, 118],
    [145, 195, 188, 152, 136, 104, 118, 175, 74, 203], 
    [140, 192, 193, 170, 142, 109, 166, 190, 111, 215],
    [224, 162, 92, 93, 162, 104, 85, 84, 147, 130],    
    [192, 180, 187, 112, 212, 147, 88, 74, 185, 195],  
    [211, 177, 91, 191, 210, 96, 197, 140, 72, 199]
    ]
    S = [459, 569, 490, 560, 497, 407, 463, 441, 507, 449]

Ctr = 3

solver(I,J,K,C,B,S,Ctr)

