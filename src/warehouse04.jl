##
# using RecipesBase
# using GraphRecipes
using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs
include("warehouse.jl")

## Functions


mutable struct Robot <: AbstractAgent
    id::Int
    pos::Int
    dest::Int
    head::Int
    path::Vector{LightGraphs.SimpleGraphs.SimpleEdge{Int64}}
end

function get_load_spot(model)
    n_spots = length(model.load_spot)
    if model.last_spot == n_spots
        model.last_spot = 1
    else
        model.last_spot += 1
    end
    return model.load_spot[model.last_spot]
end

function robot_step!(robot,model)
    
    move_now = true    

    if isempty(nearby_ids(robot,model))
        
    
        if robot.dest == 0 # nema naklad
            # robot.dest = model.load_spot[1]
            robot.dest = get_load_spot(model)
            robot.path = []
        elseif (robot.pos in model.load_spot) & (robot.dest in model.load_spot) & !isempty(model.package_list)
            next_package_dest = popfirst!(model.package_list)
            robot.dest = model.dest_spot[next_package_dest]
            move_now = false
            robot.path = []
        elseif robot.dest == robot.pos# muze vykladat
            robot.dest = 0
            robot.path = []
            move_now = false
        end
            
        if move_now == true #& ~isempty(robot.path)
            if isempty(robot.path) & (robot.dest != 0 )
                robot.path = a_star(model.graph,robot.pos,robot.dest)
            end
            if !isempty(robot.path)
                next_step = popfirst!(robot.path).dst
                # pos = robot.pos

                move_agent!(robot,next_step,model)
            end
        end            
    end
end

function terminate_warehouse_sim(model, step)
    
    # for a in allagents(model)
    #     if a.dest != 0
    #         return false
    #     end
    # end    
    # if isempty(model.package_list)
    #     return true
    # else
    #     return false
    # end
    if isempty(model.package_list) & all([agent.dest in model.load_spot  for agent in allagents(model)])
        return true
    else
        return false           

    end
end

function warehouse_step!(model)
#     for a in allagents(model)
#         a.old_opinion = a.new_opinion
#     end
end

mutable struct PlotABM{AbstractSpace}
    args::Any
end

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


    plotabm
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

function main(;animation=false)
    ## Simulation 
    m = 9
    n = 7
    n_packages = 10
    load_spots = collect(16:4:28)
    factor = 2
    # load_spots = [4]

    g,p,d = generate_warehouse_struct(m,n,d_start=2)
    package_list = rand(1:length(d),n_packages)

    warehouse_space = GraphSpace(g)
    model_props = Dict(:package_list=>package_list,
    :load_spot=>load_spots,
    :last_spot=> length(load_spots),
    :dest_spot=>d,
    :graph => g)
    warehouse = ABM(Robot, warehouse_space;properties= model_props)

    dest_spot_grid = model_props[:dest_spot].-(2*n+1)

    robot_colors = (x,y)-> robot_colors_spots(x,y,model_props[:load_spot],dest_spot_grid)
    robot_sizes = (x,y,z) -> robot_sizes_spots(x,y,z,model_props[:load_spot],model_props[:dest_spot],dest_spot_grid,factor)
    # add_agent!(Robot(1,1,0,1,[]),1, warehouse)
    # for (i,j) in enumerate(30:30:240)
    n_agents = 0
    for (i,j) in enumerate(30:30:270)
        add_agent!(Robot(i,j,0,1,[]),j, warehouse)
        n_agents += 1
    end

    cs=fill(0.05, nv(g), nv(g))
    plotabm(warehouse;am=(x,y)->:rect,as=robot_sizes,ac=robot_colors,x=p[:,2],y=p[:,1],curves=false,arrow=true,curvature_scalar=cs,size=(2000,2000),linealpha=0.5,markerstrokewidth=0.0)
    savefig("fig_$(m)_$(n)_$factor.png")
    # data, _ = run!(warehouse, robot_step!,warehouse_step!,terminate_warehouse_sim; adata)

    ## Animation    
    cs=fill(0.05, nv(g), nv(g))
    adata = [:pos, :dest,:head]
    
    if !animation
        data, _ = run!(warehouse, robot_step!,warehouse_step!,terminate_warehouse_sim; adata)
    else
        anim = @animate for i in 0:1000
            # p1 = plotabm(warehouse;am=(x,y)->:circle,as=robot_sizes,ac=robot_colors,x=p[:,2],y=p[:,1],curves=false,arrow=true,curvature_scalar=cs,size=(1000,1000))
            p1 = plotabm(warehouse;am=(x,y)->:rect,as=robot_sizes,ac=robot_colors,x=p[:,2],y=p[:,1],curves=false,arrow=true,curvature_scalar=cs,size=(2000,2000),linealpha=0.5,markerstrokewidth=0.0)
            display(i)    
            title!(p1, "step:$(i),packages to dispatch:$(length(warehouse.properties[:package_list]))")
            if terminate_warehouse_sim(warehouse,i)
                # gif(anim, "warehouse_$(m)_$(n)_$(n_agents).mp4", fps = 4)
                break
            end
            step!(warehouse, robot_step!,warehouse_step!, 1)
        end
        gif(anim, "warehouse_$(m)_$(n)_$(n_agents).mp4", fps = 4)
    end

    
end

##
main(animation=true)