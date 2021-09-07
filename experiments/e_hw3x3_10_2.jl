#%%
using Warehouse
using Random
using Agents
using CSV

#%%
ed = ed_hw3x3_10_2 
edir ="/home/datalab/projects/agents/warehouse/experiments/$(ed.identifier)/"  
if !isdir(edir)
    mkdir(edir)
end


#%%
# seed=1
for seed in seeds
    Random.seed!(seed)
    name =  get_experiment_name(ed,seed)
    warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
    adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim; 
    adata=adata,mdata=mdata,agents_first=true)
    CSV.write("$(edir)$(name)_adata.csv",adf)
    CSV.write("$(edir)$(name)_mdata.csv",mdf)
    # animate_warehouse(;warehouse=warehouse, 
    # robot_step=robot_step_highway_nowait!,
    # warehouse_step = warehouse_step_highway!,
    # terminate_warehouse_sim=terminate_warehouse_sim,
    # name=name,
    # plot_fn=plot_warehouse)

end