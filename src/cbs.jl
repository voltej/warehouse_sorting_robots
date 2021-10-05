using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs, Random
include("warehouse.jl")
include("a_star_cbs.jl")

# function warehouse_step!(model)

#     replan = false
    
#     #TODO collision test
    
#     for robot in allagents(model)
# #         display(robot)
#         if robot.dest == 0
#             replan = true
#             if robot.pos in model.load_spot && !isempty(model.package_list)# nalozeni
#                 next_package_dest = popfirst!(model.package_list)
#                 robot.dest = model.dest_spot[next_package_dest]
#             elseif robot.pos in model.dest_spot || model.step == 1 #vylozeni
#                 robot.dest = get_load_spot(model)                
#             end                                                                        
#         end
# #         display(robot)
#     end
    
#     if replan
         
#         et = edgetype(model.graph)
#         n_agents = nagents(model)

#         constraints = init_constraints(n_agents,et)
#         paths = [a_star(model.graph, robot.pos,robot.dest) for robot in [getindex(model,idx) for idx in 1:n_agents]]
#         root= CBSNode(constraints,paths,length.(paths))

#         solution = cbs(root,model.graph)
#         for i in 1:n_agents
#             robot = getindex(model,i)
#             robot.path = solution[i]
#         end
# #         display(solution)

#     end
    
#     model.step += 1
#     display(model.step)
# end;

# function robot_step!(robot,model)    
#     if !isempty(robot.path)        
#         next_step = robot.path[1].dst
#         move_agent!(robot,next_step,model)
#         popfirst!(robot.path)
#     end
    
#     if robot.dest == robot.pos || robot.pos in model.load_spot
#         robot.dest = 0        
#     end
# end;

function robot_step_cbs!(robot,model)    
    if !isempty(robot.path)        
        next_step = robot.path[1].dst
        move_agent!(robot,next_step,model)
        robot.moved +=1
        popfirst!(robot.path)
    end
    
    if robot_in_destination(robot, model)
        robot.dest = 0      
        if  !(robot.pos in model.load_spot)
            model.packages_delivered += 1
        end 
    end
end;

function warehouse_step_cbs!(model)

    replan = false
    
    #TODO collision test
    
    for robot in allagents(model)
        if robot.dest == 0
            replan = true
            give_robot_destination(robot,model)                                                                      
        end
    end
    
    if replan
         
        et = edgetype(model.graph)
        n_agents = nagents(model)

        constraints = init_constraints(n_agents,et)
        paths = [a_star(model.graph, robot.pos,robot.dest) for robot in [getindex(model,idx) for idx in 1:n_agents]]
        root= CBSNode(constraints,paths,length.(paths))

        start = now()
        solution = cbs(root,model.graph,model.initialized)
        stop = now()
        if Warehouse.measure_execution_time
            println("CBS solver runtime:$(time_delta(start,stop))")
        end
        for i in 1:n_agents
            robot = getindex(model,i)
            robot.path = solution[i]
        end
#         display(solution)
        model.replaned +=1
    end
    
    model.step += 1
end;