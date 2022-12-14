include("Misc.jl")

using JuMP
using GLPK
using vOptGeneric
using CPLEX
# ENV["CPLEX_STUDIO_BINARIES"] = "C:\\Program Files\\IBM\\ILOG\\CPLEX_Studio201\\cplex\\bin\\x64_win64"
# import Pkg
# Pkg.add("CPLEX")
# Pkg.build("CPLEX")

function solver(I,J,K,C,B,S,Ctr)

    TSUFLP = Model(CPLEX.Optimizer)
    #TSUFLP = Model(GLPK.Optimizer)
    #set_silent(TSUFLP)

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

    Ux = []

    for i = 1:I
        Uxi = []
        for j = 1:J
            ux = @variable(TSUFLP) 
            push!(Uxi,ux)
        end
        push!(Ux,Uxi)
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

    Vy = []

    for j= 1:J
        Vyj = []
        for k = 1:K
            vy = @variable(TSUFLP) 
            push!(Vyj,vy)
        end
        push!(Vy,Vyj)
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

    max_C = 0
    for i = 1:I
        for j = 1:J
            if C[i][j] > max_C
                max_C = C[i][j]
            end
        end
    end

    max_B = 0
    for j = 1:J
        for k = 1:K
            if B[j][k] > max_B
                max_B = B[j][k]
            end
        end
    end
    
    #@addobjective( TSUFLP, Max, sum(X[i]*P[i] for i in I) )

    # @variable( TSUFLP,X[1:I],Bin)
    # #@variable( TSUFLP,U[1:I] >= 0)
    # @variable( TSUFLP,MU[1:I] >= 0)
    # @variable(TSUFLP,sigma >= 0)

    moy_y = 40 #et merde hein

    @objective( TSUFLP, Min, sum(U[i][j] for i in 1:I for j in 1:J) + sum(V[j][k] for j in 1:J for k in 1:K ) )

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

    # @constraint( TSUFLP, [i = 1:I , j = 1:J] , Ux[i][j] >= 0)
    # @constraint( TSUFLP ,[j = 1:J , k = 1:K] , Vy[j][k] >= 0)

    println("balise 1")
    #vSolve(TSUFLP, method=:epsilon, step = 0.5)
    println("balise 2")

    #points = getY_N(TSUFLP)
    #println(points)
    println("balise 3")
    
    plot_axe1 = []
    plot_axe2 = []

    # for s in points
    #     obj1_value = s[1]
    #     obj2_value = s[2]
    #     push!(plot_axe1,obj1_value)
    #     push!(plot_axe2,obj2_value)
    # end

    optimize!(TSUFLP)

    println(" X = ")
    for i = 1:I
        for j = 1:J
            print(" ",JuMP.value(X[i][j]))
        end
        println("")
    end
    println(" Y = ")
    for j = 1:J
        for k = 1:K
            print(" ",JuMP.value(Y[j][k]))
        end
        println("")
    end
    println("Z = ")
    for k = 1:K
        print(" ",JuMP.value(Z[k]))
    end
    println("\n U = ")
    for i = 1:I
        for j = 1:J
            print(" ",JuMP.value(U[i][j]))
        end
        println("")
    end
    println(" V = ")
    for j = 1:J
        for k = 1:K
            print(" ",JuMP.value(V[j][k]))
        end
        println("")
    end

    println("\n Ux = ")
    for i = 1:I
        for j = 1:J
            print(" ",JuMP.value(Ux[i][j]))
        end
        println("")
    end
    println(" Vy = ")
    for j = 1:J
        for k = 1:K
            print(" ",JuMP.value(Vy[j][k]))
        end
        println("")
    end
    println("\nMU = ")
    for j = 1:J
        for k = 1:K
            print(" ",JuMP.value(MU[j][K]))
        end
        println("")
    end

    println("\nSigma : ",JuMP.value(sigma))
    println("objective value : ",objective_value(TSUFLP))
    #printX_E(TSUFLP)

    #scatter(plot_axe1,plot_axe2)
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

I = 5   
J = 4
K = 3
C = [
[3, 10, 3, 9],
[11, 2, 17, 3],
[17, 12, 2, 1],
[14, 3, 13, 8],
[7, 11, 12, 15]
]

B = [
[77, 97, 48],
[39, 39, 72],
[92, 76, 97],
[65, 42, 94]
]
S = [456, 490, 504]

Ctr = 3

solver(I,J,K,C,B,S,Ctr)

