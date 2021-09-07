
## Muzou byt chyby, na konci srpna jsem resil jen nowait verzi
function robot_step_highway!(robot,model)
    
    move_now = true    

    # if isempty(nearby_ids(robot,model))
    # if !(robot.dest in [robot.pos for robot in nearby_agents(robot,model)])
    
        if robot.dest == 0 # nema naklad
            # robot.dest = model.load_spot[1]
            robot.dest = get_load_spot(model)
            robot.path = []
        elseif (robot.pos in model.load_spot) & (robot.dest in model.load_spot) & !isempty(model.package_list)
            next_package_dest = popfirst!(model.package_list)
            robot.dest = model.dest_spot[next_package_dest]
            move_now = false
            robot.path = []
        elseif isempty(model.package_list) & (robot.pos in model.load_spot) & (robot.dest in model.load_spot)
            move_now=false
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
                next_step = robot.path[1].dst
                # next_step = popfirst!(robot.path).dst
                # pos = robot.pos
                if !(next_step in [robot.pos for robot in nearby_agents(robot,model)])
                    move_agent!(robot,next_step,model)
                    popfirst!(robot.path)
                end
            end
        end            
    
end

function warehouse_step_highway!(model)
    #     for a in allagents(model)
    #         a.old_opinion = a.new_opinion
    #     end
        model.step += 1
end;

function robot_step_highway_nowait!(robot,model)
    
    move_now = true    
#     println(model.step)
    # if isempty(nearby_ids(robot,model))
    # if !(robot.dest in [robot.pos for robot in nearby_agents(robot,model)])
    
    if robot_in_destination(robot,model)
        robot.dest = 0
        if !(robot.pos in model.load_spot)
            model.packages_delivered += 1
        end
    end
    
    if robot.dest == 0        
        give_robot_destination(robot,model)                                                     
    end
    
    if isempty(model.package_list) & (robot.pos in model.load_spot) & (robot.dest in model.load_spot)
        move_now=false
    end
    
      
            
    if move_now == true #& ~isempty(robot.path)
        if isempty(robot.path) & (robot.dest != 0 )
            robot.path = a_star(model.graph,robot.pos,robot.dest)
        end
        if !isempty(robot.path)
#             print("Hejbu se")
            next_step = robot.path[1].dst
            # next_step = popfirst!(robot.path).dst
            # pos = robot.pos
            if !(next_step in [robot.pos for robot in nearby_agents(robot,model)])
                move_agent!(robot,next_step,model)
                popfirst!(robot.path)
                robot.moved +=1
            end
        end
    end            
    
end          



