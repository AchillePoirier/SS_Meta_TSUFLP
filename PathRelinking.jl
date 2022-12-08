include("Misc.jl")
include("Skiplist.jl")

function pathRelinking(I,J,K,C,B,S,X1,Y1,Z1,X2,Y2,Z2)

    #X1,Y1,Z1 : solution de depart
    #X2,Y2,Z2 : solution d'arrivee

    #Vecteur d'ouverture des concentrateurs_nv1
    Y1_opened = zeros(Int,J)
    Y2_opened = zeros(Int,J)
    for j = 1:J
        Y1_opened[j] = sum(Y1[j])
        Y2_opened[j] = sum(Y2[j])
    end

    skl = skiplist_init()

    skl, = skiplist_insertion(skl,X1,Y1,Z1,objective_value_1(I,J,K,C,B,S,X1,Y1,Z1),objective_value_2(I,J,K,C,B,S,X1,Y1,Z1))
    skl, = skiplist_insertion(skl,X2,Y2,Z2,objective_value_1(I,J,K,C,B,S,X2,Y2,Z2),objective_value_2(I,J,K,C,B,S,X2,Y2,Z2))

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

    
    nb_move_left = length(Y_in) + length(Y_out) + length(Z_in) + length(Z_out)

    current_X = X1
    current_Y = Y1
    current_Z = Z1

    

    #tant qu'il reste des mouvement a faire
    while nb_move_left > 0

        Y1_opened = zeros(Int,J)
        Y2_opened = zeros(Int,J)
        for j = 1:J
            Y1_opened[j] = sum(current_Y[j])
            Y2_opened[j] = sum(Y2[j])
        end
    
        println("Y1 ",Y1_opened," Z1 ",current_Z)
        println("Y2 ",Y2_opened," Z2 ",Z2)
        println("Y_in ",Y_in," Y_out ",Y_out)
        println("Z_in ",Z_in," Z_out ",Z_out)

        move_found = false 

        #mouvement in sur y
        argmove = 1
        while argmove <= length(Y_in) && move_found == false && sum(sum(current_Y)) > 1

            new_X_obj1,new_Y_obj1,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'y',"in",Y_in[argmove],1)

            skl,dominated1 = skiplist_insertion(skl,new_X_obj1,new_Y_obj1,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z))

            if dominated1 == false
                println("mouvement dominant : y_in-",Y_in[argmove])
                current_X = new_X_obj1
                current_Y = new_Y_obj1
                current_Z = new_Z
                move_found = true
                deleteat!(Y_in,argmove)
                break
            end

            new_X_obj2,new_Y_obj2,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'y',"in",Y_in[argmove],2)

            skl,dominated2 = skiplist_insertion(skl,new_X_obj2,new_Y_obj2,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z))
            
            if dominated2 == false
                println("mouvement dominant : y_in-",Y_in[argmove])
                current_X = new_X_obj2
                current_Y = new_Y_obj2
                current_Z = new_Z
                move_found = true
                deleteat!(Y_in,argmove)
                break
            end

            #Les deux solutions sont domines
            argmove += 1
        end
        
        #mouvement out sur y
        argmove = 1
        while argmove <= length(Y_in) && move_found == false

            new_X_obj1,new_Y_obj1,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'y',"out",Y_out[argmove],1)

            skl,dominated1 = skiplist_insertion(skl,new_X_obj1,new_Y_obj1,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z))

            if dominated1 == false
                println("mouvement dominant : y_out-",Y_out[argmove])
                current_X = new_X_obj1
                current_Y = new_Y_obj1
                current_Z = new_Z
                move_found = true
                break
            end

            new_X_obj2,new_Y_obj2,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'y',"out",Y_out[argmove],2)


            skl,dominated2 = skiplist_insertion(skl,new_X_obj2,new_Y_obj2,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z))
            
            if dominated2 == false
                println("mouvement dominant : y_out-",Y_out[argmove])
                current_X = new_X_obj2
                current_Y = new_Y_obj2
                current_Z = new_Z
                move_found = true
                break
            end

            #Les deux solutions sont domines
            argmove += 1
        end
        #mouvement in sur Z
        argmove = 1
        while argmove <= length(Y_in) && move_found == false

            new_X_obj1,new_Y_obj1,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'z',"in",Z_in[argmove],1)

            skl,dominated1 = skiplist_insertion(skl,new_X_obj1,new_Y_obj1,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z))

            if dominated1 == false
                println("mouvement dominant : z_in-",Z_in[argmove])
                current_X = new_X_obj1
                current_Y = new_Y_obj1
                current_Z = new_Z
                move_found = true
                break
            end

            new_X_obj2,new_Y_obj2,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'z',"out",Z_in[argmove],2)

            skl,dominated2 = skiplist_insertion(skl,new_X_obj2,new_Y_obj2,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z))
            
            if dominated2 == false
                println("mouvement dominant : z_in-",Z_in[argmove])
                current_X = new_X_obj2
                current_Y = new_Y_obj2
                current_Z = new_Z
                move_found = true
                break
            end

            #Les deux solutions sont domines
            argmove += 1
        end
        #mouvement out sur Z
        argmove = 1
        while argmove <= length(Y_in) && move_found == false && sum(current_Z) > 1

            println("current Y ",current_Y)
            println("current Z ",current_Z)
            new_X_obj1,new_Y_obj1,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'z',"out",Z_out[argmove],1)

            skl,dominated1 = skiplist_insertion(skl,new_X_obj1,new_Y_obj1,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj1,new_Y_obj1,new_Z))

            if dominated1 == false
                println("mouvement dominant : z_out-",Z_out[argmove])
                current_X = new_X_obj1
                current_Y = new_Y_obj1
                current_Z = new_Z
                move_found = true
                break
            end

            new_X_obj2,new_Y_obj2,new_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'z',"out",Z_out[argmove],2)

            skl,dominated2 = skiplist_insertion(skl,new_X_obj2,new_Y_obj2,new_Z,objective_value_1(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z),objective_value_2(I,J,K,C,B,S,new_X_obj2,new_Y_obj2,new_Z))
            
            if dominated2 == false
                println("mouvement dominant : z_out-",Z_out[argmove])
                current_X = new_X_obj2
                current_Y = new_Y_obj2
                current_Z = new_Z
                move_found = true
                break
            end

            #Les deux solutions sont domines
            argmove += 1
        end

        #si aucun mouvement ne donne une solution non domine, selection d'un mouvement arbitraire.
        if length(Y_in) > 0
            current_X,current_Y,current_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'y',"in",Y_in[1],rand(1:2))
            deleteat!(Y_in,1)
        elseif length(Y_out) > 0
            current_X,current_Y,current_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'y',"out",Y_out[1],rand(1:2))
            deleteat!(Y_out,1)
        elseif length(Z_in) > 0
            current_X,current_Y,current_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'z',"in",Z_in[1],rand(1:2))
            deleteat!(Z_in,1)
        else
            current_X,current_Y,current_Z = move(I,J,K,C,B,S,current_X,current_Y,current_Z,'z',"in",Z_out[1],rand(1:2))
            deleteat!(Z_out,1)
        end

        println("Pas de solution non dominees, mouvement arbitraire")

        nb_move_left -= 1
    end

    println("Fin ! ")
    Y1_opened = zeros(Int,J)
    Y2_opened = zeros(Int,J)
    for j = 1:J
        Y1_opened[j] = sum(current_Y[j])
        Y2_opened[j] = sum(Y2[j])
    end

    println("Y1 ",Y1_opened," Z1 ",current_Z)
    println("Y2 ",Y2_opened," Z2 ",Z2)
    println("Y_in ",Y_in," Y_out ",Y_out)
    println("Z_in ",Z_in," Z_out ",Z_out)

    skl_display(skl)
end

function move(I,J,K,C,B,S,X,Y,Z,y_z,in_out,ind_move,objective)

    new_Z = deepcopy(Z)
    new_Y = deepcopy(Y)

    if y_z == 'y'
        if in_out == "in"
            new_Y[ind_move][1] = 1
        elseif in_out == "out"
            new_Y[ind_move] = zeros(Int,J)
        end
    elseif y_z == 'z'
        if in_out == "in"
            new_Z[ind_move] = 1
        elseif in_out == "out"
            new_Z[ind_move] = 0
        end
    end

    if objective == 1

        new_Y = reaffectation_concentrateurs_obj1(J,K,B,S,new_Y,new_Z)
        new_X = affectation_terminaux_obj1(I,J,C,new_Y)
    elseif objective == 2
        new_Y = reaffectation_concentrateurs_obj2(J,K,B,S,new_Y,new_Z)
        new_X = affectation_terminaux_obj2(I,J,C,new_Y)
    end

    return new_X,new_Y,new_Z

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