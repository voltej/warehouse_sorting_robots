#%%
using Warehouse
using Random
using Agents
using CSV
using Logging,Dates

#%%
ed = ed_cbs5x19_100_20
edir ="$(@__DIR__)/$(ed.identifier)/"  
if !isdir(edir)
    mkdir(edir)
end
#%%
logio = open("$(ed.identifier).log","w+")
logger = SimpleLogger(logio)
global_logger(logger)


#%%
# seed=1
# quick_seeds = sort(collect(setdiff(Set(1:100),Set([1,11,14,46,56,59,77,80]))))
quick_seeds = 93:100
for seed in quick_seeds
    @info "$(now()) Begin seed $(seed)"
    display(seed)
    Random.seed!(seed)
    name =  get_experiment_name(ed,seed)
    warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
    @time adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim; 
    adata=adata,mdata=mdata,agents_first=true)
    CSV.write("$(edir)$(name)_adata.csv",adf)
    CSV.write("$(edir)$(name)_mdata.csv",mdf)
    @info "$(now()) End seed $(seed)"
    flush(logio)
    # animate_warehouse(;warehouse=warehouse, 
    # robot_step=robot_step_highway_nowait!,
    # warehouse_step = warehouse_step_highway!,
    # terminate_warehouse_sim=terminate_warehouse_sim,
    # name=name,
    # plot_fn=plot_warehouse)

end


