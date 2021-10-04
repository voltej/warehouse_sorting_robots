#%%
using Warehouse
using LightGraphs
using Agents


#%%

#%%
function init_robots_1x6x2_2(warehouse)
    add_agent!(Robot(1,7,0,1,[],0,0),7, warehouse)
    add_agent!(Robot(2,13,0,1,[],0,0),13, warehouse)
end

wh2_1x6x2_10_2_directed = WarehouseDefinition(Dict("b"=>1,"m"=>6,"n"=>2),10,2,SimpleDiGraph,generate_warehouse_t2,init_robots_1x6x2_2,[7,13])
ed2_hw_1x6x2_10_2 = ExperimentDefinition("hw1x6x2_10_2",wh2_1x6x2_10_2_directed,robot_step_highway_nowait!,warehouse_step_highway!)
ed = ed2_hw_1x6x2_10_2
seed = 1

#%%
warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
plot_warehouse()