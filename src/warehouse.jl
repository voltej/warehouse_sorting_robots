using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs, Dates


function generate_warehouse_t1(sizes::Dict;d_start::Int=2,graph_type=SimpleDiGraph)
    m = sizes["m"]
    n = sizes["n"]
    w = graph_type() #warehouse graph
    n_m = 2 * m + 1
    n_n = 2 * n + 1
    n_m_n = n_m*n_n
    
    add_vertices!(w,n_m*n_n)
    # p = zeros(Int,nv(w),2) #positions
    p = zeros(Float64,nv(w),2) #positions
    d = zeros(Int,(m-d_start+1)*n)
    v = 1
    for i in 1:n_m
        for j in 1:n_n
            p[v,:] = [((v -1)÷ n_n +1); ((v-1) % n_n +1)]
            v += 1
        end
    end
    for i in 1:4:n_n #nahoru
        jj = Array(i:n_n:n_m_n)
        for j in 1:length(jj)-1
            # show([jj[j],jj[j+1]])
            add_edge!(w,jj[j],jj[j+1])
        end
    end
    for i in 3:4:n_n #dolu
        jj = Array(i:n_n:n_m_n)
        for j in 1:length(jj)-1
            # show([jj[j],jj[j+1]])
            add_edge!(w,jj[j+1],jj[j])
        end
    end
    
    for i in 1:4*n_n:(n_n)*n_m #doleva
        # show(i)
        jj = Array(i:i+n_n-1)
        for j in 1:length(jj)-1
            # show([jj[j+1],jj[j]])
            add_edge!(w,jj[j+1],jj[j])
        end
    end

    for i in 2*n_n+1:4*n_n:(n_n)*n_m #doprava
        jj = Array(i:i+n_n-1)
        for j in 1:length(jj)-1
            add_edge!(w,jj[j],jj[j+1])
        end
    end
    v=1
    for i in 2*(n_n+(d_start-1)*n_n)+2:2*n_n:(n_n)*n_m #drop locations
        for j in i:2:i+n_n-2
            d[v] = j
            v += 1
        end
    end

    dest_spot_grid = d.-(2*n+1)

    return w,p,d, dest_spot_grid

end

mutable struct Robot <: AbstractAgent
    id::Int
    pos::Int
    dest::Int
    head::Int
    path::Vector{LightGraphs.SimpleGraphs.SimpleEdge{Int64}}
    moved::Int
    waited::Int
end

function get_load_spot(model)
    n_spots = length(model.load_spot)
    if model.last_spot == n_spots
        model.last_spot = 1
    else
        model.last_spot += 1
    end
    model.used_load_spots[model.last_spot] +=1
    return model.load_spot[model.last_spot]
end

# function robot_step!(robot,model)
    
#     move_now = true    

#     # if isempty(nearby_ids(robot,model))
#     # if !(robot.dest in [robot.pos for robot in nearby_agents(robot,model)])
    
#         if robot.dest == 0 # nema naklad
#             # robot.dest = model.load_spot[1]
#             robot.dest = get_load_spot(model)
#             robot.path = []
#         elseif (robot.pos in model.load_spot) & (robot.dest in model.load_spot) & !isempty(model.package_list)
#             next_package_dest = popfirst!(model.package_list)
#             robot.dest = model.dest_spot[next_package_dest]
#             move_now = false
#             robot.path = []
#         elseif isempty(model.package_list) & (robot.pos in model.load_spot) & (robot.dest in model.load_spot)
#             move_now=false
#         elseif robot.dest == robot.pos# muze vykladat
#             robot.dest = 0
#             robot.path = []
#             move_now = false
#         end
            
#         if move_now == true #& ~isempty(robot.path)
#             if isempty(robot.path) & (robot.dest != 0 )
#                 robot.path = a_star(model.graph,robot.pos,robot.dest)
#             end
#             if !isempty(robot.path)
#                 next_step = robot.path[1].dst
#                 # next_step = popfirst!(robot.path).dst
#                 # pos = robot.pos
#                 if !(next_step in [robot.pos for robot in nearby_agents(robot,model)])
#                     move_agent!(robot,next_step,model)
#                     popfirst!(robot.path)
#                 end
#             end
#         end            
    
# end

# function terminate_warehouse_sim(model, step)
    
#     # for a in allagents(model)
#     #     if a.dest != 0
#     #         return false
#     #     end
#     # end    
#     # if isempty(model.package_list)
#     #     return true
#     # else
#     #     return false
#     # end
#     if isempty(model.package_list) & all([agent.dest in model.load_spot  for agent in allagents(model)])
#         return true
#     else
#         return false
#     end
# end

# function warehouse_step!(model)
# #     for a in allagents(model)
# #         a.old_opinion = a.new_opinion
# #     end
#     model.step += 1
# end

mutable struct PlotABM{AbstractSpace}
    args::Any
end

pl(model) = Vector(model.package_list);
adata = [:pos, :dest,:head]
mdata =[:last_spot,pl, :replaned,:packages_delivered];


function robot_colors_spots(robots,n,spots,dests,loads)
        
    # rc = Vector{RGBA{Float64}}(length(robots))
    # for robot in robots
    cg = cgrad(:inferno, 7, categorical = true)
    if !isempty(robots)
        return [robot.dest in spots ? cg[4] : cg[6]  for robot in robots]
    elseif n in loads
        return  cg[4]
    elseif n in dests
        return  cg[6]
    else
        # return "#765db4"
        return :grey
    end


    
    # return rc
end

# function robot_sizes_spots(robots,n,model,spots,robot_dests,dests,loads,factor)
#     if !isempty(robots)       
#         return factor
#     elseif n in spots .+1
#         return factor * 2
#     # elseif n in [robot.dest for robot in robots]
#     #     show("$n is a destination")
#     #     return factor * 2
#     elseif n in dests
#         idx = findall(x->x==n,dests)[1]
#         # rdi = typeof(robot_dests[idx])
#         # rda=typeof([robot.dest for robot in allagents(model)])
#         # test = robot_dests[idx] in [robot.dest for robot in allagents(model)]
#         if robot_dests[idx] in [robot.dest for robot in allagents(model)]
#             return factor * 2
#         else
#             return factor * 1
#         end
#     else
#         return 0
#     end

# end


function generate_plot()
    w,p,d = generate_warehouse_t1(17,15,d_start=2)
    graphplot(Matrix(adjacency_matrix(w)),x=p[:,2],y=p[:,1],size=(3000,3000),curves=false,arrow=true,names=1:nv(w),fontsize=20)

end

function get_load_spot(model)
    n_spots = length(model.load_spot)
    if model.last_spot == n_spots
        model.last_spot = 1
    else
        model.last_spot += 1
    end
    model.used_load_spots[model.last_spot] +=1
    return model.load_spot[model.last_spot]
end

# function robot_colors_spots(robots,n,spots,dests)
        
#     # rc = Vector{RGBA{Float64}}(length(robots))
#     # for robot in robots
#     cg = cgrad(:inferno, 7, categorical = true)
#     if !isempty(robots)
#         return [robot.dest in spots ? cg[4] : cg[6]  for robot in robots]
#     elseif n in spots .+1
#         return  cg[4]
#     elseif n in dests
#         return  cg[6]
#     else
#         # return "#765db4"
#         return :grey
#     end


    
#     # return rc
# end

function robot_sizes_spots(robots,n,model,spots,robot_dests,dests, spots_grid,factor)
    if !isempty(robots)       
        return factor
    # elseif n in spots .+1
    elseif n in spots_grid
        return factor * 2
    # elseif n in [robot.dest for robot in robots]
    #     show("$n is a destination")
    #     return factor * 2
    elseif n in dests
        idx = findall(x->x==n,dests)[1]
        # rdi = typeof(robot_dests[idx])
        # rda=typeof([robot.dest for robot in allagents(model)])
        # test = robot_dests[idx] in [robot.dest for robot in allagents(model)]
        if robot_dests[idx] in [robot.dest for robot in allagents(model)]
            return factor * 2
        else
            return factor * 1
        end
    else
        return 0
    end

end

function terminate_warehouse_sim(model, step;timeout=900)
    if isempty(model.package_list) & all([!(agent.dest in model.dest_spot)  for agent in allagents(model)])
        return true
    elseif time_delta(now(), model.initialized) > timeout
        display("Timeout occured")
        return true        
    else
        return false
    end
end

function robot_in_destination(robot, model)
    return (robot.dest == robot.pos) && (robot.pos in model.dest_spot || (robot.pos in model.load_spot && !isempty(model.package_list)))
end

function give_robot_destination(robot,model)
    if robot.pos in model.load_spot && !isempty(model.package_list)# nalozeni
        next_package_dest = popfirst!(model.package_list)
        robot.dest = model.dest_spot[next_package_dest]
    elseif robot.pos in model.dest_spot || model.step == 1 #vylozeni
        robot.dest = get_load_spot(model)                
    end  
end

struct WarehouseDefinition{}
    sizes::Dict
    n_packages::Int
    n_robots::Int
    graph_type
    generator_function
    init_robots
    load_spots::Vector{Int64}  
end


struct ExperimentDefinition
    identifier::String
    warehouse_definition::WarehouseDefinition
    robot_step
    warehouse_step
end

function init_warehouse(g,p,d,n_packages,load_spots;seed=1234)
    Random.seed!(seed)

    
    package_list = rand(1:length(d),n_packages);

    warehouse_space = GraphSpace(g)
    model_props = Dict(:package_list=>package_list,
    :load_spot=>load_spots,
    :last_spot=> length(load_spots),
    :dest_spot=>d,
    :graph => g,
    :step => 1,
    :check_next_step => true,
    :used_load_spots=>zeros(Int,(length(load_spots))),
    :replaned => 0,
    :packages_delivered =>0,
    :initialized=>now())

    warehouse = ABM(Robot, warehouse_space;properties= model_props)

    return warehouse
end

function init_warehouse_with_plot(ed::WarehouseDefinition;seed=1234,factor=2)
    sizes,n_packages,graph_type,graph_generator,init_robots,load_spots = ed.sizes,ed.n_packages,ed.graph_type,ed.generator_function,ed.init_robots,ed.load_spots
    
    g,p,d, dest_spot_grid,load_spot_grid = graph_generator(sizes,graph_type=graph_type)
    
    warehouse= init_warehouse(g,p,d,n_packages,load_spots;seed=seed)
    init_robots(warehouse)
    
    model_props = warehouse.properties    
    # dest_spot_grid = model_props[:dest_spot].-(2*n+1)
    robot_colors = (x,y)-> robot_colors_spots(x,y,model_props[:load_spot],dest_spot_grid,load_spot_grid)
    robot_sizes = (x,y,z) -> robot_sizes_spots(x,y,z,model_props[:load_spot],model_props[:dest_spot],dest_spot_grid,load_spot_grid,factor)
    cs=fill(0.05, nv(g), nv(g));

    plot_arrows = (graph_type == SimpleDiGraph)
    plot_warehouse = ()-> plotabm(warehouse;am=(x,y)->:rect,as=robot_sizes,ac=robot_colors,x=p[:,2],y=p[:,1],curves=false,curvature_scalar=cs,size=(750,750),linealpha=0.5,markerstrokewidth=0.0,arrow=plot_arrows);
    
    return warehouse, plot_warehouse
end

function animate_warehouse(;warehouse,robot_step, warehouse_step,terminate_warehouse_sim,name,plot_fn,fps=4)
    n_agents = nagents(warehouse)
    anim = @animate for i in 0:1e6
        p1 = plot_fn()
        title!(p1, "step:$(i),packages to dispatch:$(length(warehouse.properties[:package_list]))")
    
        if terminate_warehouse_sim(warehouse,i)
            break
        end
        step!(warehouse, robot_step,warehouse_step, 1,true)
    end
    gif(anim, name, fps = fps);
end

function get_experiment_name(ed::ExperimentDefinition,seed::Int)

    return "$(ed.identifier)_$(join(["$(k)_$(v)" for (k,v) in ed.warehouse_definition.sizes if k !="load_spots"],"_"))_a$(ed.warehouse_definition.n_robots)_seed$(seed)"
end


function time_delta(start::DateTime,stop::DateTime)

    return (stop-start)/Millisecond(1000)
end


function generate_warehouse_t2(sizes;d_start::Int=4,graph_type=SimpleDiGraph,v_start = 0)
    b = sizes["b"]
    m = sizes["m"]
    n = sizes["n"]
    load_spots = sizes["load_spots"]
    if d_start in keys(sizes)
        d_start = sizes["d_start"]
    end
    if h_start in keys(sizes)
        v_start = sizes["v_start"]
    end
    g = graph_type() #warehouse graph
    
    real_n = n+2
    n_block_vertices = m*real_n
    total_n = real_n * b
    
    
    add_vertices!(g,b*n_block_vertices+length(load_spots))
    
    p = zeros(Float64,nv(g),2) #positions
    d_grid = Int[]
    d = Int[]
    l_grid=Int[]
    
    v_all=1
    for k in 1:b
        #positions
        v_start = v_all -1 
        for j in 1:n+2
            for i in 1:m

                p[v_all,:] = [i;j+(k-1)*real_n]
                v_all +=1
                
            end
        end
        #destinations & spots to unload
        left_grid =  v_start + d_start                  : v_start +              m
        left_dest =  v_start + d_start +              m : v_start +          2 * m
        right_grid = v_start + d_start + (real_n-1) * m : v_start +   (real_n) * m
        right_dest = v_start + d_start + (real_n-2) * m : v_start + (real_n-1) * m                
        append!(d_grid,left_grid,right_grid)
        append!(d, left_dest,right_dest)                
    end
    
    # horizontal edges
    # even ->
    for i in 1:2:m
        j_left = i
        for j_right in i+m:m:i+m*(total_n-1)
#             println(j_left," ",j_right)
            if !(j_left in d_grid || j_right in d_grid)
                add_edge!(g,j_left,j_right)
            end
            j_left = j_right
            
        end        
    end
    # odd <-
    for i in 2:2:m
        j_left = i
        for j_right in i+m:m:i+m*(total_n-1)
#             println(j_left," ",j_right)
            if !(j_left in d_grid || j_right in d_grid)
                add_edge!(g,j_right,j_left)
            end
            j_left = j_right
            
        end

        
    end
    
    # vertical edges
    # up
    for i in 1:2*m:m*(total_n)
        j_left = i
        for j_right in i+1:i+m-1
#             println(j_left," ",j_right)
            if !(j_left in d_grid || j_right in d_grid)
                add_edge!(g,j_left,j_right)
            end
            j_left = j_right
            
        end        
    end
    # down
    for i in m+1:2*m:m*(total_n)
        j_left = i
        for j_right in i+1:i+m-1
#             println(j_left," ",j_right)
            if !(j_left in d_grid || j_right in d_grid)
                add_edge!(g,j_right,j_left)                   
            end
            j_left = j_right
        end        
    end
    
    for (i,v) in enumerate(load_spots)
        l_grid_id = b*n_block_vertices+i
        p[l_grid_id,:] = p[v,:] + [-1,0]
        append!(l_grid,l_grid_id)
    end

    add_edge!(g,nv(g),nv(g)) # Fix to plot bug

    return g,p,d,d_grid,l_grid
end