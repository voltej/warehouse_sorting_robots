#%%
using Warehouse
using LightGraphs
using Agents


#%%
function init_robots_2x10x2_10(warehouse)
    for (i,j) in enumerate(11:20)
          add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
     end
 end
 
 
 function init_robots_3x10x2_20(warehouse)
    for (i,j) in enumerate(11:20)
          add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
     end
    for (i,j) in enumerate(51:60)
          add_agent!(Robot(i+10,j,0,1,[],0,0),j, warehouse)
    end
 end

#%% cbs
ed_sizes = Dict("b"=>3,"m"=>10,"n"=>2,"load_spots"=>[21,61,101],"d_start"=>3,"v_mod"=>false)
wh2_undirected = WarehouseDefinition(ed_sizes,100,20,SimpleGraph,generate_warehouse_t2,init_robots_2x10x2_10,[21,61,101])
ed2_cbs = ExperimentDefinition("ed2_cbs",wh2_undirected,robot_step_cbs!,warehouse_step_cbs!)
ed = ed2_cbs

#%%
seed = 1
name = get_experiment_name(ed,seed)
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