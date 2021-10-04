#%%
using Warehouse
using LightGraphs
using Agents


#%%
function init_robots_1x6x2_2(warehouse)
    add_agent!(Robot(1,7,0,1,[],0,0),7, warehouse)
    add_agent!(Robot(2,13,0,1,[],0,0),13, warehouse)
end

#%% HW
wh2_1x6x2_10_2_directed = WarehouseDefinition(Dict("b"=>1,"m"=>6,"n"=>2,"load_spots"=>[7,13]),10,2,SimpleDiGraph,generate_warehouse_t2,init_robots_1x6x2_2,[7,13])
ed2_hw_1x6x2_10_2 = ExperimentDefinition("hw1x6x2_10_2",wh2_1x6x2_10_2_directed,robot_step_highway_nowait!,warehouse_step_highway!)
ed = ed2_hw_1x6x2_10_2
seed = 1
name = get_experiment_name(ed,seed)

#%% cbs
wh2_1x6x2_10_2_undirected = WarehouseDefinition(Dict("b"=>1,"m"=>6,"n"=>2,"load_spots"=>[7,13]),10,2,SimpleGraph,generate_warehouse_t2,init_robots_1x6x2_2,[7,13])
ed2_cbs_1x6x2_10_2 = ExperimentDefinition("cbs1x6x2_10_2",wh2_1x6x2_10_2_undirected,robot_step_cbs!,warehouse_step_cbs!)
ed = ed2_cbs_1x6x2_10_2
seed = 2
name = get_experiment_name(ed,seed)


#%%
warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
plot_warehouse()

#%%

adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim; adata=adata,mdata=mdata,agents_first=true)

#%%
warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
animate_warehouse(;warehouse=warehouse, 
    robot_step=ed.robot_step,
    warehouse_step = ed.warehouse_step,
    terminate_warehouse_sim=terminate_warehouse_sim,
    name=name * ".mp4",
    plot_fn=plot_warehouse)