#%%
using Agents, Plots, LightGraphs, GraphRecipes, MetaGraphs, Random

include("src/warehouse.jl")
include("src/highway.jl");
include("src/definitions.jl")



# %%
# pl(model) = Vector(model.package_list);
# adata = [:pos, :dest,:head]
# mdata =[:last_spot,pl];

#%%

ed = ed_hw17x15
#%% 
warehouse,plot_warehouse = init_experiment(ed);
n_agents = nagents(warehouse)
m,n = ed.m,ed.n
name =  "nowait_warehouse_$(m)_$(n)_$(n_agents).mp4"
plot_warehouse()

#%%
# animate_warehouse(;warehouse=warehouse,
#     robot_step=robot_step_highway_nowait!,
#     warehouse_step = warehouse_step_highway!,
#     terminate_warehouse_sim=terminate_warehouse_sim,
#     name=name,
#     plot_fn=plot_warehouse)


#%%
warehouse,plot_warehouse = init_experiment(ed);
adf, mdf = run!(warehouse, robot_step_highway_nowait!,warehouse_step_highway!,terminate_warehouse_sim; 
    adata=adata,mdata=mdata,agents_first=true)
display(warehouse.step)