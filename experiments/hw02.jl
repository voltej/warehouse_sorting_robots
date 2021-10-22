#%%
using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs, Random

include("src/warehouse.jl")
include("src/highway.jl");


# %%
pl(model) = Vector(model.package_list);
adata = [:pos, :dest,:head]
mdata =[:last_spot,pl];

#%%
ed01 = ExperimentDefinition(3,3,10,SimpleDiGraph,init_warehouse,init_robots_3x3_2,[8,12])

#%% 
warehouse,plot_warehouse = init_experiment(ed01);
n_agents = nagents(warehouse)
m,n = ed01.m,ed01.n
name =  "nowait_warehouse_$(m)_$(n)_$(n_agents).mp4"
plot_warehouse()

#%%
animate_warehouse(;warehouse=warehouse,
    robot_step=robot_step_highway_nowait!,
    warehouse_step = warehouse_step_highway!,
    terminate_warehouse_sim=terminate_warehouse_sim,
    name=name,
    plot_fn=plot_warehouse)


#%%
warehouse,plot_warehouse = init_experiment(ed01);
adf, mdf = run!(warehouse, robot_step_highway_nowait!,warehouse_step_highway!,terminate_warehouse_sim; 
    adata=adata,mdata=mdata,agents_first=true)
display(warehouse.step)