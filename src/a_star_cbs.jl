# %%
using LightGraphs
using MetaGraphs
using DataStructures:PriorityQueue, enqueue!, dequeue!,nil,MutableLinkedList
import LightGraphs:a_star
# using Graphs
using Logging
include("warehouse.jl")

# %%
function reconstruct_path!(total_path, # a vector to be filled with the shortest path
    came_from, # a vector holding the parent of each node in the A* exploration
    end_idx, # the end vertex
    g) # the graph

    E = edgetype(g)
    curr_idx = end_idx
    while came_from[curr_idx] != curr_idx
        if typeof(g) <: MetaDiGraph
            pushfirst!(total_path, E(g[came_from[curr_idx],:id][2], g[curr_idx,:id][2])) #time-space graph
        else
            pushfirst!(total_path, E(came_from[curr_idx], curr_idx)) #original
        end
        curr_idx = came_from[curr_idx]
    end
end

function a_star(g::AbstractGraph{U},  # the g
    s::Integer,                       # the start vertex
    t::Integer,    
    constraints:: Dict{Int,MutableLinkedList
    }=Dict{Int,MutableLinkedList}(),
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=n -> zero(T)) where {T, U, ET}                    

    E = Edge{eltype(g)}

    # if we do checkbounds here, we can use @inbounds in a_star_impl!
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))

    open_set = PriorityQueue{Integer, T}()
    enqueue!(open_set, s, 0)

    closed_set = zeros(Bool, nv(g))

    g_score = fill(Inf, nv(g))
    g_score[s] = 0

    f_score = fill(Inf, nv(g))
    f_score[s] = heuristic(s)

    came_from = -ones(Integer, nv(g))
    came_from[s] = s

    a_star_impl!(g, t, open_set, closed_set, g_score, f_score, came_from, distmx, heuristic,constraints)
end

function a_star_impl!(g, # the graph
    goal, # the end vertex
    open_set, # an initialized heap containing the active vertices
    closed_set, # an (initialized) color-map to indicate status of vertices
    g_score, # a vector holding g scores for each node
    f_score, # a vector holding f scores for each node
    came_from, # a vector holding the parent of each node in the A* exploration
    distmx,
    heuristic,
    constraints)

    E = edgetype(g)
    total_path = Vector{E}()

    @inbounds while !isempty(open_set)
        current = dequeue!(open_set)

        if current == goal
            reconstruct_path!(total_path, came_from, current, g)
            return total_path
        end

        closed_set[current] = true

        for neighbor in LightGraphs.outneighbors(g, current)
            current != neighbor && closed_set[neighbor] && continue

            tentative_g_score = g_score[current] + distmx[current, neighbor]

            # if tentative_g_score < g_score[neighbor]
            if !(tentative_g_score in keys(constraints) 
                && neighbor in [x.dst for x in constraints[tentative_g_score]]
                && current in [x.src for x in constraints[tentative_g_score]]
                )  && tentative_g_score < g_score[neighbor]
                g_score[neighbor] = tentative_g_score
                priority = tentative_g_score + heuristic(neighbor)
                open_set[neighbor] = priority
                came_from[neighbor] = current
            end
        end
    end
    return total_path
end


"""
    a_star(g, s, t[, distmx][, heuristic])

Return a vector of edges comprising the shortest path between vertices `s` and `t`
using the [A* search algorithm](http://en.wikipedia.org/wiki/A%2A_search_algorithm).
An optional heuristic function and edge distance matrix may be supplied. If missing,
the distance matrix is set to [`LightGraphs.DefaultDistance`](@ref) and the heuristic is set to
`n -> 0`.
"""



function a_star_time(g::AbstractGraph{U},  # the g
    s::Integer,                       # the start vertex
    t::Integer,    
    constraints:: Dict{Int,MutableLinkedList
    }=Dict{Int,MutableLinkedList}(),
    distmx::AbstractMatrix{T}=weights(g),
    heuristic::Function=n -> zero(T)) where {T, U, ET}                    

    E = Edge{eltype(g)}
    reconstruct_path!
    # if we do checkbounds here, we can use @inbounds in a_star_impl!
    checkbounds(distmx, Base.OneTo(nv(g)), Base.OneTo(nv(g)))

    open_set = PriorityQueue{Vector{Integer}, T}()
    enqueue!(open_set, [s,1,0], 0)

    # closed_set = zeros(Bool, nv(g))
    closed_set = MutableLinkedList{Vector{Integer}}

    g_score = fill(Inf, nv(g))
    g_score[s] = 0

    f_score = fill(Inf, nv(g))
    f_score[s] = heuristic(s)

    came_from = -ones(Integer, nv(g))
    came_from[s] = s

    a_star_time_impl!(g, t, open_set, closed_set, g_score, f_score, came_from, distmx, heuristic,constraints)
end


#%%
mutable struct CBSNode{T<:LightGraphs.AbstractEdge}
    constraint::Vector{Dict{Int,MutableLinkedList}}
    path::Vector{Vector{T}}
    cost::Vector{Int}
end
#%%
function first_conflict(node::CBSNode)
    
    max_len = maximum(length.(node.path))
    n_agents = length(node.cost)

    node_conflict = false
    agents_in_conflict = []

    for t in 1:max_len
        for ai in 1:n_agents
            if !node_conflict && t <= length(node.path[ai]) 
                for aj in ai+1:n_agents
                    if t <= length(node.path[aj])
                        if node.path[ai][t].dst == node.path[aj][t].dst
                            if !node_conflict
                                push!(agents_in_conflict,ai)
                                node_conflict = true
                            end
                            push!(agents_in_conflict,aj)

                        end
                        if !node_conflict
                            #edge_conflict search
                            if node.path[ai][t].src == node.path[aj][t].dst && node.path[ai][t].dst == node.path[aj][t].src
                                return [ai,aj], t
                            end
                        end
                    end
                end
            end
            if node_conflict
                return agents_in_conflict, t
            end
        end
    end

    return agents_in_conflict, nothing


end


#%%
function node_cost(node::CBSNode)
    return maximum(node.cost)
end

function add_constraint!(constraints,ai,time,edge)
    et=typeof(edge)
    if !isassigned(constraints,ai) 
        constraints[ai] = Dict(time=>MutableLinkedList{et}(edge))
    elseif !(time in keys(constraints[ai]))
        constraints[ai][time] = MutableLinkedList{et}(edge)
    else
        append!(constraints[ai][time],edge)
    end
end
#%%
function cbs(root::CBSNode,graph::AbstractGraph,initialized::DateTime)
    CBSTree = PriorityQueue{CBSNode,Float64}(Base.Order.Forward)
    enqueue!(CBSTree,root,node_cost(root))
    
    while !isempty(CBSTree)
        best_node = dequeue!(CBSTree)
        agents_in_conflict,conflict_time = first_conflict(best_node)
        if isempty(agents_in_conflict) || minimum(best_node.cost) < conflict_time
            return best_node.path
        end

        for ai in agents_in_conflict
            # if time_delta(initialized,now()) > Warehouse.timeout                       
            #     println("CBS timeout")
            #     global_logger()
            #     @info "CBS timeout"
            #     return best_node.path
            # end
            ai_node = deepcopy(best_node)
            add_constraint!(ai_node.constraint,ai,conflict_time,ai_node.path[ai][conflict_time])
            tsg, tsg_dest = create_time_space_graph(graph,ai_node.path[ai][1].src,ai_node.path[ai][end].dst,ai_node.constraint[ai])
            ai_node.path[ai] = a_star(tsg,1,tsg_dest,ai_node.constraint[ai])
            if !isempty(ai_node.path[ai])
                ai_node.cost[ai] = length(ai_node.path[ai])
                enqueue!(CBSTree,ai_node,node_cost(ai_node))
            end
        end

    end

    
    
end

# function add_numbered_vertex!(g::AbstractGraph,t,id)
#     nvg = nv(g)
#     add_vertex!(g)
#     nvg += 1
#     set_props!(g,nvg,Dict(:t=>t, :id => id))
#     return nvg
# end

function init_constraints(n_agents,et)
    constraints = Vector{Dict{Int,MutableLinkedList}}(undef,n_agents)
    for i in 1:n_agents
        constraints[i]=Dict(1=>MutableLinkedList{et}())
        empty!(constraints[i])
    end
    return constraints
end

function add_numbered_vertex!(g::AbstractGraph;t::Int64,id::Int64)
    nvg = nv(g)
    add_vertex!(g)
    nvg += 1
    set_prop!(g,nvg,:id,(t,id))
    return nvg
end

function create_time_space_graph(g, src, dst, constraints)
    t = 0
    tsg = MetaDiGraph() #time-space graph
    set_indexing_prop!(tsg,:id)
    nvg = add_numbered_vertex!(tsg,t=0,id=src)
    # set_props!(tsg,nv,Dict(:t=>t, :id => src))
    expand_next = [nvg]
    expanded_to_dst = src !=dst ? false : true
    expanded_dst = dst
    et = edgetype(g)

    while !expanded_to_dst && !isempty(expand_next)
        t += 1
        expand = expand_next
        expand_next = []
        for v_tsg in expand
            v_tsg_id = get_prop(tsg,v_tsg,:id)[2]
            neigs = neighbors(g,v_tsg_id)
            for v_neig in vcat(neighbors(g,v_tsg_id),v_tsg_id)
                if !(t in keys(constraints))  || !(et(v_tsg_id,v_neig) in constraints[t])
                    if !((t,v_neig) in keys(tsg[:id]))
                        v_tsg_new = add_numbered_vertex!(tsg,t=t,id=v_neig)
                         push!(expand_next,v_tsg_new)
                    end
                    add_edge!(tsg,tsg[(t-1,v_tsg_id),:id],tsg[(t,v_neig),:id])
        #             display("$t,$v_tsg/$v_tsg_id,$v_tsg_new/$v_neig")
                    if v_neig == dst && !expanded_to_dst
                        expanded_to_dst = true
                        expanded_dst = tsg[(t,v_neig),:id]
        #                 print("$t,$v_tsg_new,$v_tsg_id,$v_neig\n")
    #                     tsg_from = tsg[(t-1,v_tsg_id),:id]
    #                     tsg_to = tsg[(t,v_neig),:id]
    #                     print("$t, $tsg_from,$tsg_to,$v_tsg_id,$v_neig\n")
    #                     print( "$expanded_dst\n")
                    end
                end

            end

        end
    end
    return tsg, expanded_dst

end;


##

function main()
##
    g = SimpleGraph(12)
    add_edge!(g,1,2)
    add_edge!(g,3,4)
    add_edge!(g,4,5)
    add_edge!(g,5,6)
    add_edge!(g,7,8)
    add_edge!(g,8,9)
    add_edge!(g,9,10)
    add_edge!(g,11,12)

    add_edge!(g,3,7)
    add_edge!(g,1,4)
    add_edge!(g,4,8)
    add_edge!(g,8,11)
    add_edge!(g,2,5)
    add_edge!(g,5,9)
    add_edge!(g,9,12)
    add_edge!(g,6,10)

    n_agents = 2
    et = edgetype(g)
    constraints = undef
    constraints = init_constraints(n_agents,et)
    paths = [a_star(g,1,12),a_star(g,3,10)]
    display(paths)
    root= CBSNode(constraints,paths,length.(paths))
    fc = first_conflict(root)
 
    solution = cbs(root,g)
    display(solution)
end    

# main()
