mutable struct koma
    na::String
    teban::Integer
    nari::Bool
    x::Integer
    y::Integer
    temochi::Bool
end

struct Vec2
    x # 縦方向
    y # 横方向
end

struct Move
    x # 縦方向
    y # 横方向
    nari
end

ban = [
    koma("ou",0,false,1,1,false), koma("ou",1,false,3,3,false),
    koma("fu",0,false,0,0,true), koma("fu",1,false,0,0,true),
    koma("gin",0,false,0,0,true), koma("gin",1,false,0,0,true),
]

ugoki = Dict(
    "ou" => [
        Vec2(0,1), Vec2(1,1), Vec2(-1,1), Vec2(1,0),
        Vec2(-1,0), Vec2(0,-1), Vec2(1,-1), Vec2(-1,-1)
    ],
    "fu" => [
        Vec2(1,0)
    ],
    "gin" => [
        Vec2(1,0), Vec2(1,1), Vec2(-1,1), 
        Vec2(1,-1), Vec2(-1,-1)
    ],
    "kin" => [
        Vec2(1,0), Vec2(1,1), Vec2(1,-1), Vec2(-1,0),
        Vec2(0,-1), Vec2(1,0)
    ],
)

function kanji(koma)
    if (koma.na=="ou" && koma.teban == 0 )
        return "王"
    elseif (koma.na=="ou" && koma.teban == 1)
        return "お"
    elseif (koma.na=="fu" && koma.teban == 0 && !koma.nari)
        return "歩"
    elseif (koma.na=="fu" && koma.teban == 1 && !koma.nari)
        return "ふ"
    elseif (koma.na=="fu" && koma.teban == 0 && koma.nari)
        return "ト"
    elseif (koma.na=="fu" && koma.teban == 1 && koma.nari)
        return "と"
    elseif (koma.na=="gin" && koma.teban == 0 && !koma.nari)
        return "銀"
    elseif (koma.na=="gin" && koma.teban == 1 && !koma.nari)
        return "ぎ"
    elseif (koma.na=="gin" && koma.teban == 0 && koma.nari)
        return "全"
    elseif (koma.na=="gin" && koma.teban == 1 && koma.nari)
        return "な"
    end
end

function isInside(x,y)
    if (x<=0 || x > 3) 
        return(false)
    end
    if ( y<=0 || y > 3) 
        return(false)
    end
    return(true)
end

        
function find(x,y,ban)
    for k in ban
        if (!k.temochi && x==k.x && y==k.y )
            return(k)
        end
    end
    return(nothing)
end

function findIndex(x,y,ban)
    for idx in 1:length(ban)
        if (x==ban[idx].x && y==ban[idx].y)
            return(idx)
        end
    end
    return(nothing)
end


function finished(ban)
    for k in ban
        if (k.na=="ou" && k.temochi)
            return(true)
        end
    end
    return(false)
end

function Ugoki(koma)
    if koma.nari 
        return get(ugoki,"kin",nothing)
    else
        return get(ugoki,koma.na,nothing)
    end
end


function ban2str(ban)
    banStr = fill("　", 3,3)
    used = fill(false, 3,3)
    temochiStr = ["",""]
    for k in ban
        if !k.temochi
            banStr[k.x, k.y]=kanji(k)
            if used[k.x,k.y]
                println("somethin wrong")
                println(ban)
            else
                used[k.x,k.y]=true
            end
        else 
            temochiStr[k.teban+1]=string(temochiStr[k.teban+1],kanji(k));
        end
    end
    str = ""
    str = string(str,temochiStr[0+1])
    str = string(str,"\n--------\n")
    for i in 1:3
        for j in 1:3
            str=string(str,banStr[i,j])
        end
        str=string(str, "\n")
    end
    str = string(str, "--------\n")
    str = string(str,temochiStr[1+1])
    str = string(str,"\n\n")
    return(str)
end

function banCode(ban,teban)
    code = teban
    for koma in ban
        code = string(code, koma.teban, koma.temochi, koma.x, koma.y)
    end
    return code
end

function isLastMove(p, teban, ban)
    dest = find(p.x, p.y, ban)
    if isnothing(dest)
        return false
    end
    if dest.na == "ou"
        return true
    else
        return false
    end
end

function possiblePosition(k, teban, ban)
    positions = []

    if k.teban != teban
        return []
    end

    dir = (teban==0 ? +1 : -1)
    if k.temochi
        for x in 1:3
            for y in 1:3
                #if isnothing(find(x,y,ban)) && (k.na!="fu" || isInside(x+dir,y)) && !(k.na=="fu" && !isnothing(find(x+dir,y,ban)) && find(x+dir,y,ban).na=="ou" && find(x+dir,y,ban).teban==k.teban)
                if isnothing(find(x,y,ban)) && (k.na!="fu" || isInside(x+dir,y)) 
                    push!(positions,Vec2(x,y))
                end
            end
        end
    else
        for delta in Ugoki(k)
            nx = dir*delta.x+k.x
            ny = dir*delta.y+k.y
            if (!isInside(nx,ny))
                continue
            end
            p = find(nx, ny, ban)
            if isnothing(p)
                push!(positions,Vec2(nx,ny))
            elseif (p.teban != k.teban)
                push!(positions,Vec2(nx,ny))
            end
        end
    end
    return(positions)
end


visited=Set()
function visit(ban,teban)
    if finished(ban)
        return
    end
    if lpad([ban,teban],0) in visited
    #if hash([ban,teban]) in visited
        return
    else
        push!(visited, lpad([ban,teban],0))
        #push!(visited, hash([ban,teban]))
    end
    for i in 1:6
        if ban[i].teban!=teban
            continue
        end
        for p in possiblePosition(ban[i],teban,ban)
            if isLastMove(p, teban, ban)
                return
            end
        end
    end
    backup = deepcopy(ban)
    for i in 1:length(ban) # すべての駒について
        if ban[i].teban!=teban
            continue
        end
        for p in possiblePosition(ban[i],teban,ban)
            if isnothing(find(p.x,p.y,ban))
                setfield!(ban[i],:x, p.x)
                setfield!(ban[i],:y, p.y)
                if ban[i].temochi
                    setfield!(ban[i],:temochi, false)
                elseif ban[i].na=="fu" && ((p.x == 3 && teban == 0) || (p.x == 1 && teban == 1)) 
                    setfield!(ban[i],:nari, true)
                end
            elseif !ban[i].temochi
                tekiidx = findIndex(p.x,p.y,ban)
                setfield!(ban[i],:x, p.x)
                setfield!(ban[i],:y, p.y)
                setfield!(ban[tekiidx], :temochi, true)
                setfield!(ban[tekiidx], :teban, 1-ban[tekiidx].teban)
                setfield!(ban[tekiidx], :x, 0)
                setfield!(ban[tekiidx], :y, 0)
                setfield!(ban[tekiidx], :nari, false)
                if ban[i].na=="fu" && ((p.x == 3 && teban == 0) || (p.x == 1 && teban == 1)) 
                    setfield!(ban[i],:nari, true)
                end
            else
                continue
            end
            visit(ban,1-teban)            
            ban = deepcopy(backup)
        end
    end
end
        
    
ban = [
    koma("ou",0,false,1,1,false), koma("ou",1,false,3,3,false),
    koma("fu",0,false,0,0,true), koma("fu",1,false,0,0,true),
    koma("gin",0,false,0,0,true), koma("gin",1,false,0,0,true),
]
visited=Set()
visit(ban,0)
println(length(visited))

#ban=[koma("ou", 0, false, 2, 2, false), koma("ou", 1, false, 3, 3, false),
#     koma("fu", 0, false, 0, 0, true), koma("fu", 1, false, 0, 0, true),
#     koma("gin", 0, false, 0, 0, true), koma("gin", 1, false, 0, 0, true)]
#print(ban2str(ban))
#println(possiblePosition(ban[3],0,ban))



