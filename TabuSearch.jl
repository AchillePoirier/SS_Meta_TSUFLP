function tabu(I,J,K,C,B,S,X,Y,Z)
    



end

x_init = [0,0,1,1,1,0]
c = [2,5,3,1,3,5]

    
function proto_tabu(c,x_init)
    #test de recherche tabu simplifiee avec un voisinnage add swap
    #contrainte : nb de x=1 <= 3, objectif : max c.x
    x = zeros(Int,6)
    x= x_init

    nb_iter-tabu = 6
    tabu = [0,0,0,0,0,0]
    iter = 1

    #-----------add-------------------------------
    for i = 1:6
        if x[i] == 0
            new_x = deepcopy(x)
            if 
        



end

function ctr(x)
    return sum(x)>=3
end

function obj_value(x,c)
    res = 0
    for i = 1:6
        res += x[i]*c[i]
    end
    return res
end


