#%%
using Warehouse
using Random
using Agents
using CSV
using Logging,Dates
using LightGraphs

#%%
function init_robots_17x15_60(warehouse)
    for (i,j) in enumerate(31:31:620)
        add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
    for (i,j) in enumerate(29:31:618)
        add_agent!(Robot(i+20,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
    for (i,j) in enumerate(27:31:616)
        add_agent!(Robot(i+40,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
    # for (i,j) in enumerate(25:31:614)
    #     add_agent!(Robot(i+60,j,0,1,[],0,0),j, warehouse)
    #     # n_agents += 1
    # end
end
load_spots_17x15 = collect(32:4:60);
wh17x15_1000_60_directed = WarehouseDefinition(Dict("m"=>17,"n"=>15),1000,20,SimpleDiGraph,generate_warehouse_t1,init_robots_17x15_60,load_spots_17x15)
ed_hw17x15_1000_60 = ExperimentDefinition( "hwd17x15_1000_60",wh17x15_1000_60_directed, robot_step_highway_nowait!,warehouse_step_highway!)



ed = ed_hw17x15_1000_60
     
edir ="experiments/$(ed.identifier)/"  
if !isdir(edir)
    mkdir(edir)
end
#%%
logio = open("$(ed.identifier).log","w+")
logger = SimpleLogger(logio)
global_logger(logger)

#%%
if isempty(ARGS)
    seed_start = 1
    seed_end = 100
else
    seed_start = parse(Int,ARGS[1])
    seed_end = parse(Int,ARGS[2])
end
# seed=1
for seed in seed_start:seed_end
    display(seed)
    @info "$(now()) Begin seed $(seed)"
    flush(logio)
    Random.seed!(seed)
    name =  get_experiment_name(ed,seed)
    warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
    adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim; 
    adata=adata,mdata=mdata,agents_first=true)
    CSV.write("$(edir)/$(name)_adata.csv",adf)
    CSV.write("$(edir)/$(name)_mdata.csv",mdf)
    @info "$(now()) End seed $(seed)"
    flush(logio)
    # animate_warehouse(;warehouse=warehouse, 
    # robot_step=robot_step_highway_nowait!,
    # warehouse_step = warehouse_step_highway!,
    # terminate_warehouse_sim=terminate_warehouse_sim,
    # name=name,
    # plot_fn=plot_warehouse)

end


