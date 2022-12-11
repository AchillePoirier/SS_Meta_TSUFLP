include("Misc.jl")


mutable struct skl_element
    previous::Union{skl_element,Nothing}
    next::Union{skl_element,Nothing}
    up::Union{skl_element,Nothing}
    down::Union{skl_element,Nothing}
    obj1::Float64
    obj2::Float64
    X::Union{Vector{Vector{Int}},Nothing}
    Y::Union{Vector{Vector{Int}},Nothing}
    Z::Union{Vector{Int},Nothing}
end



function skiplist_init()
    infinity = 999999999999
    upLeft = skl_element(nothing,nothing,nothing,nothing,-infinity,infinity,nothing,nothing,nothing)
    upRight = skl_element(upLeft,nothing,nothing,nothing,infinity,-infinity,nothing,nothing,nothing)
    upLeft.next = upRight

    bottomLeft = skl_element(nothing,nothing,upLeft,nothing,-infinity,infinity,nothing,nothing,nothing)
    bottomRight = skl_element(bottomLeft,nothing,upRight,nothing,infinity,-infinity,nothing,nothing,nothing)
    bottomLeft.next = bottomRight

    upLeft.down = bottomLeft
    upRight.down = bottomRight

    return upLeft
end

function skiplist_insertion(skl_head,X_sol,Y_sol,Z_sol,obj1_sol,obj2_sol)
    dominated = false
    current = skl_head
    location_to_insert_next = Vector{skl_element}(undef,0)
    new_elem = skl_element(nothing,nothing,nothing,nothing,obj1_sol,obj2_sol,X_sol,Y_sol,Z_sol)

    #do while
    while true

        #Si il est domine, pas d'insertion
        if current.obj2 <= obj2_sol || (current.next.obj1 == obj1_sol && current.next.obj2 <= obj2_sol)
            #println("dominé")
            dominated = true
            return skl_head,dominated
        end

        #recherche de la place du nouvel element
        if current.next.obj1 < obj1_sol
            current = current.next
        else
            #Descente si il y a un niveau inferieur
            if current.down != nothing
                push!(location_to_insert_next,current)
                current = current.down
            else
                #insertion du nouvel element et reaffectation des pointeurs
                new_elem.previous = current
                new_elem.next = current.next
                current.next = new_elem
                new_elem.next.previous = new_elem
                #fin de la boucle
                break
            end
        end
    end
    new_skl_head = skl_head

    #Tant que l'on tombe sur face
    new_elem_bottom = new_elem
    while rand(Bool)
        
        n = length(location_to_insert_next)
        #Si il y a assez de niveaux, ajout du nouvel element au niveau et reaffectation des pointeurs
        if n > 1
            current = location_to_insert_next[n]

            new_elem_up = skl_element(current,current.next,nothing,new_elem_bottom,obj1_sol,obj2_sol,X_sol,Y_sol,Z_sol)
            current.next = new_elem_up
            new_elem_up.next.previous = new_elem_up
            new_elem_bottom.up = new_elem_up

            new_elem_bottom = new_elem_up
            deleteat!(location_to_insert_next,n)
        else #sinon, creation d'un nouveau niveau, et reaffectation des pointeurs
            #println("nouvelle row")
            
            infinity = 999999999999
            upLeft = skl_element(nothing,nothing,nothing,nothing,-infinity,infinity,nothing,nothing,nothing)
            upRight = skl_element(upLeft,nothing,nothing,nothing,infinity,-infinity,nothing,nothing,nothing)
            upLeft.next = upRight

            current = new_skl_head
            current.up = upLeft
            upLeft.down = current

            current = current.next
            current.up = upRight
            upRight.down = current

            new_skl_head = upLeft

            current = new_skl_head.down
            new_elem_up = skl_element(current,current.next,nothing,new_elem_bottom,obj1_sol,obj2_sol,X_sol,Y_sol,Z_sol)
            current.next = new_elem_up
            new_elem_up.next.previous = new_elem_up
            new_elem_bottom.up = new_elem_up

            new_elem_bottom = new_elem_up
        end

    end

    #Retrait des solutions domines

    #tant que la solution inseree domine son successeur
    while new_elem.obj2 <= new_elem.next.obj2

        dominated = new_elem.next
        #suppression de la solution dominee
        new_elem.next = dominated.next
        new_elem.next.previous = new_elem

        #suppression de la solution a tous les niveaux
        while dominated.up != nothing

            dominated = dominated.up

            current = dominated.previous
            current.next = dominated.next
            current.next.previous = dominated.previous
        end
            

    end

    return new_skl_head,dominated
end

function skiplist_solution_vector(skl_head)
    solutions = []

    current = skl_head
    while current.down != nothing
        current = current.down
    end

    current = current.next
    
    while current.next != nothing
        push!(solutions,((current.X,current.Y,current.Z),(current.obj1,current.obj2)))
        current = current.next
    end

    return solutions
end

function skl_display(skl_head::skl_element)

    current = skl_head
    row_left = skl_head
    while true
        print("(",current.obj1,",",current.obj2,")")
        if current.next == nothing && row_left.down == nothing
            break
        elseif current.next == nothing
            current = row_left.down
            row_left = row_left.down
            print("\n")
        else
            current = current.next
        end
    end
    print("\n\n")
end

#exemple

# I = 5
# J = 4
# K = 3

# B = [
#     [14,13,18],
#     [15,12,14],
#     [10,16,15],
#     [12,14,18]
# ]

# S = [26,33,30]

# C = [
#     [5,4,7,3],
#     [9,7,6,4],
#     [2,5,3,7],
#     [5,4,8,6],
#     [7,2,3,4]
# ]

# Z1 = [0,1,1]
# Y1 = [
#     [0,0,0],
#     [0,0,1],
#     [0,1,0],
#     [0,0,0]
# ]
# X1 = affectation_terminaux_obj1(5,4,C,Y1)

# Z2 = [0,0,1]
# Y2 = [
#     [0,0,0],
#     [0,0,1],
#     [0,0,1],
#     [0,0,1]
# ]
# X2 = affectation_terminaux_obj2(5,4,C,Y2)

# println("------------------------------------------------------------------------")
# skl = skiplist_init()
# skl, = skiplist_insertion(skl,nothing,nothing,nothing,3,15)
# skl, = skiplist_insertion(skl,nothing,nothing,nothing,12,3)
# skl, = skiplist_insertion(skl,nothing,nothing,nothing,6,9)
# skl, = skiplist_insertion(skl,nothing,nothing,nothing,8,6)
# skl, = skiplist_insertion(skl,nothing,nothing,nothing,1,18)

# skl_display(skl)
# skl, = skiplist_insertion(skl,nothing,nothing,nothing,6,8)


# skl_display(skl)

# skiplist_solution_vector(skl)
