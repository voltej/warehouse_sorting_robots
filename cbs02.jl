#%%
using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs, Random
include("src/cbs.jl")
include("src/warehouse.jl")

#%%
pl(model) = Vector(model.package_list);
adata = [:pos, :dest,:head]
mdata =[:last_spot,pl];

#%%
ed02 = ExperimentDefinition(3,3,10,SimpleGraph,init_warehouse,init_robots_3x3_2,[8,12])

#%%
warehouse,plot_warehouse = init_experiment(ed02);
n_agents = nagents(warehouse)
m,n = ed02.m,ed02.n
name =  "cbs_warehouse_$(m)_$(n)_$(n_agents).mp4"
plot_warehouse()

#%%
animate_warehouse(;warehouse=warehouse,
    robot_step=robot_step_cbs!,
    warehouse_step = warehouse_step_cbs!,
    terminate_warehouse_sim=terminate_warehouse_sim,
    name=name,
    plot_fn=plot_warehouse)


#%%
warehouse,plot_warehouse = init_experiment(ed02);
adf, mdf = run!(warehouse, robot_step_cbs!,warehouse_step_cbs!,terminate_warehouse_sim;
    adata=adata,mdata=mdata,agents_first=true)
display(warehouse.step)