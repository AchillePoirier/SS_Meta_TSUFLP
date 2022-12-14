include("Misc.jl")

using JuMP
#using GLPK
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
    
    @addobjective( TSUFLP, Min, objective_value_1(I,J,K,C,B,S,X,Y,Z))
    @addobjective( TSUFLP, Min, sum(U[i][j] for i in 1:I for j in 1:J) + sum(V[j][k] for j in 1:J for k in 1:K ) )


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

# I = 20  
# J = 10
# K = 50
# C = [ 
# [25, 17, 39, 39, 10, 28, 15, 9, 25, 30], 
# [36, 4, 38, 39, 35, 7, 8, 13, 26, 30],   
# [26, 25, 3, 18, 37, 5, 24, 22, 18, 8],   
# [30, 25, 32, 18, 10, 11, 21, 1, 25, 13], 
# [19, 34, 15, 24, 39, 5, 16, 12, 36, 3],  
# [35, 17, 30, 2, 15, 20, 8, 24, 24, 11],  
# [20, 12, 40, 14, 30, 7, 39, 24, 25, 1],  
# [12, 1, 24, 9, 9, 29, 26, 3, 18, 9],     
# [32, 13, 39, 4, 10, 12, 32, 24, 13, 5],  
# [35, 28, 26, 38, 28, 38, 35, 12, 23, 12],
# [31, 40, 19, 21, 17, 15, 5, 24, 32, 30], 
# [9, 34, 37, 24, 10, 40, 5, 37, 29, 27],  
# [25, 13, 36, 25, 22, 25, 16, 15, 9, 4],  
# [38, 27, 4, 21, 18, 36, 20, 13, 23, 30], 
# [32, 37, 19, 22, 14, 34, 15, 25, 11, 29],
# [32, 14, 10, 19, 9, 33, 31, 38, 7, 38],  
# [1, 29, 18, 38, 2, 12, 10, 5, 9, 32],    
# [31, 36, 22, 21, 5, 37, 34, 17, 16, 24],
# [3, 36, 11, 22, 23, 12, 14, 35, 31, 20],
# [40, 37, 25, 6, 35, 15, 2, 40, 23, 38]
# ]
# B = [
# [116, 163, 183, 187, 93, 103, 62, 148, 221, 163, 89, 178, 151, 206, 153, 175, 67, 99, 172, 223, 67, 106, 194, 148, 170, 185, 129, 159, 211, 164, 171, 55, 78, 178, 105, 185, 109, 109, 224, 195, 89, 172, 166, 68, 89, 87, 197, 208, 235, 167],
# [78, 87, 230, 92, 131, 125, 122, 200, 119, 188, 109, 89, 165, 208, 191, 63, 212, 118, 125, 228, 93, 183, 178, 147, 164, 75, 186, 179, 151, 167, 128, 182, 90, 151, 109, 167, 122, 215, 193, 217, 159, 101, 119, 99, 161, 94, 166, 171, 117, 84],
# [73, 95, 135, 154, 102, 70, 163, 170, 184, 168, 101, 195, 188, 160, 196, 80, 106, 120, 
# 153, 102, 162, 144, 204, 73, 83, 76, 114, 219, 137, 156, 126, 121, 188, 147, 140, 172, 
# 93, 106, 112, 177, 101, 101, 127, 71, 88, 98, 132, 198, 74, 206],
# [151, 167, 118, 99, 94, 83, 209, 211, 127, 141, 189, 114, 221, 185, 98, 103, 156, 101, 
# 141, 126, 111, 124, 178, 128, 177, 83, 172, 201, 189, 89, 206, 163, 185, 176, 173, 139, 168, 144, 203, 214, 102, 112, 194, 143, 121, 198, 94, 143, 192, 107],
# [151, 178, 89, 164, 70, 202, 183, 58, 122, 156, 202, 181, 216, 173, 209, 215, 93, 122, 
# 128, 90, 99, 113, 185, 96, 104, 119, 198, 115, 203, 79, 99, 182, 202, 106, 117, 171, 134, 225, 108, 186, 80, 168, 107, 180, 214, 104, 216, 148, 191, 65],
# [65, 86, 126, 197, 94, 106, 214, 161, 110, 187, 107, 135, 97, 199, 117, 180, 100, 161, 
# 161, 184, 159, 221, 157, 130, 171, 201, 80, 185, 148, 146, 190, 173, 153, 71, 75, 66, 158, 237, 123, 143, 131, 173, 171, 163, 182, 132, 116, 195, 115, 227],
# [103, 97, 167, 82, 221, 188, 176, 96, 104, 143, 160, 181, 175, 71, 164, 83, 105, 178, 125, 94, 81, 177, 128, 191, 204, 165, 116, 155, 177, 121, 95, 171, 98, 106, 149, 214, 194, 105, 162, 194, 143, 128, 86, 176, 163, 171, 177, 119, 206, 205],
# [166, 200, 159, 162, 71, 95, 200, 111, 229, 147, 213, 192, 203, 147, 85, 194, 53, 203, 
# 64, 178, 233, 173, 192, 70, 119, 68, 180, 202, 170, 122, 100, 86, 101, 129, 140, 111, 127, 119, 164, 173, 126, 183, 195, 121, 195, 111, 142, 169, 135, 142],
# [145, 89, 108, 131, 194, 117, 76, 219, 179, 147, 159, 213, 165, 202, 130, 216, 115, 156, 171, 159, 194, 158, 82, 143, 174, 206, 183, 131, 182, 150, 119, 123, 182, 106, 115, 175, 112, 210, 104, 170, 91, 108, 61, 125, 104, 220, 188, 217, 153, 76],
# [193, 190, 142, 65, 118, 128, 109, 115, 149, 139, 184, 96, 233, 229, 185, 117, 179, 196, 202, 124, 211, 138, 127, 192, 95, 116, 148, 185, 210, 194, 147, 153, 199, 174, 156, 146, 88, 110, 186, 123, 224, 229, 191, 160, 217, 124, 86, 87, 127, 191]
# ]
# S = [589, 465, 524, 579, 500, 420, 593, 455, 584, 577, 539, 450, 554, 509, 573, 550, 436, 534, 582, 571, 565, 406, 508, 411, 529, 442, 501, 575, 402, 437, 441, 468, 403, 515, 410, 560, 585, 599, 585, 557, 432, 411, 586, 441, 400, 491, 589, 551, 559, 556]

Ctr = 3

solver(I,J,K,C,B,S,Ctr)

