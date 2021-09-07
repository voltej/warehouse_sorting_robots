# Global
seeds = 1:100

# Warehouse 17x15
load_spots_17x15 = collect(32:4:60)

function init_robots_17x15_35(warehouse)
    for (i,j) in enumerate(31:31:1085)
        add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
end

# Warehouse 3x3
function init_robots_3x3_2(warehouse)
    add_agent!(Robot(1,2,0,1,[],0,0),2, warehouse)
    add_agent!(Robot(2,6,0,1,[],0,0),6, warehouse)
end

# Warehouse definitions
wh3x3_10_2_directed = WarehouseDefinition(3,3,10,2,SimpleDiGraph,init_warehouse,init_robots_3x3_2,[8,12])
wh3x3_10_2_undirected = WarehouseDefinition(3,3,10,2,SimpleGraph,init_warehouse,init_robots_3x3_2,[8,12])

wh17x15_1000_35_directed = WarehouseDefinition(17,15,1000,35,SimpleDiGraph,init_warehouse,init_robots_17x15_35,load_spots_17x15)
wh17x15_1000_35_undirected = WarehouseDefinition(17,15,1000,35,SimpleGraph,init_warehouse,init_robots_17x15_35,load_spots_17x15)


# Experiment definitions
ed_hw3x3_10_2 = ExperimentDefinition("hw3x3_10_2",wh3x3_10_2_directed,robot_step_highway_nowait!,warehouse_step_highway!)
ed_cbs3x3_10_2 = ExperimentDefinition("cbs3x3_10_2",wh3x3_10_2_undirected, robot_step_cbs!,warehouse_step_cbs!)

ed_hw17x15_1000_35 = ExperimentDefinition("hw17x15_1000_35",wh17x15_1000_35_directed,robot_step_highway_nowait!,warehouse_step_highway!)
ed_cbs17x15_1000_35 = ExperimentDefinition("cbs17x15_1000_35",wh17x15_1000_35_undirected, robot_step_cbs!,warehouse_step_cbs!)
ed_cbsd17x15_1000_35 = ExperimentDefinition("cbsd17x15_1000_35",wh17x15_1000_35_directed, robot_step_cbs!,warehouse_step_cbs!)


# 17x5 10 5 debugging
function init_robots_17x15_5(warehouse)
    for (i,j) in enumerate(31:31:155)
        add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
end
load_spots_17x15 = collect(32:4:60);
wh17x15_10_5_undirected = WarehouseDefinition(17,15,10,5,SimpleGraph,init_warehouse,init_robots_17x15_5,load_spots_17x15)
ed_cbs17x15_10_5 = ExperimentDefinition("cbs17x15_10_5",wh17x15_10_5_undirected, robot_step_cbs!,warehouse_step_cbs!)