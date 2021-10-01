using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs, Dates


function generate_warehouse_struct(m::Int,n::Int;d_start::Int=2,graph_type=SimpleDiGraph)
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



    return w,p,d

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


function robot_colors_spots(robots,n,spots,dests)
        
    # rc = Vector{RGBA{Float64}}(length(robots))
    # for robot in robots
    cg = cgrad(:inferno, 7, categorical = true)
    if !isempty(robots)
        return [robot.dest in spots ? cg[4] : cg[6]  for robot in robots]
    elseif n in spots .+1
        return  cg[4]
    elseif n in dests
        return  cg[6]
    else
        # return "#765db4"
        return :grey
    end


    
    # return rc
end

function robot_sizes_spots(robots,n,model,spots,robot_dests,dests,factor)
    if !isempty(robots)       
        return factor
    elseif n in spots .+1
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


function generate_plot()
    w,p,d = generate_warehouse_struct(17,15,d_start=2)
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

function robot_sizes_spots(robots,n,model,spots,robot_dests,dests,factor)
    if !isempty(robots)       
        return factor
    elseif n in spots .+1
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
    m::Int
    n::Int
    n_packages::Int
    n_robots::Int
    graph_type
    init_warehouse
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
    m,n,n_packages,graph_type,init_warehouse,init_robots,load_spots = ed.m,ed.n,ed.n_packages,ed.graph_type,ed.init_warehouse,ed.init_robots,ed.load_spots
    
    g,p,d = generate_warehouse_struct(m,n,graph_type=graph_type)
    
    warehouse= init_warehouse(g,p,d,n_packages,load_spots;seed=seed)
    init_robots(warehouse)
    
    model_props = warehouse.properties    
    dest_spot_grid = model_props[:dest_spot].-(2*n+1)
    robot_colors = (x,y)-> robot_colors_spots(x,y,model_props[:load_spot],dest_spot_grid)
    robot_sizes = (x,y,z) -> robot_sizes_spots(x,y,z,model_props[:load_spot],model_props[:dest_spot],dest_spot_grid,factor)
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

    return "$(ed.identifier)_$(ed.warehouse_definition.m)_$(ed.warehouse_definition.n)_$(ed.warehouse_definition.n_robots)_seed$(seed)"
end


function time_delta(start::DateTime,stop::DateTime)

    return (stop-start)/Millisecond(1000)
end
