#%%
using Warehouse
using Random
using Agents
using CSV
using Logging,Dates
using LightGraphs


#%%
function init_robots_51x51_100(warehouse)
    for (i,j) in enumerate(103:103:10300)
        add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
end

load_spots_51x51 = collect(104:4:206);


# wh51x51_300_100_undirected = WarehouseDefinition(Dict("m"=>51,"n"=>51),300,100,SimpleGraph,generate_warehouse_t1,init_robots_51x51_100,load_spots_51x51)
wh51x51_300_100_directed = WarehouseDefinition(Dict("m"=>51,"n"=>51),300,100,SimpleDiGraph,generate_warehouse_t1,init_robots_51x51_100,load_spots_51x51)
# ed_cbs51x51_300_100 = ExperimentDefinition("cbs51x51_300_100",wh51x51_300_100_undirected, robot_step_cbs!,warehouse_step_cbs!)
ed_hw51x51_300_100 = ExperimentDefinition( "hw51x51_300_100",wh51x51_300_100_directed,robot_step_highway_nowait!,warehouse_step_highway!)

ed = ed_hw51x51_300_100
     
edir ="experiments/$(ed.identifier)/"  
if !isdir(edir)
    mkdir(edir)
end
#%%
logio = open("$(ed.identifier).log","w+")
logger = SimpleLogger(logio)
global_logger(logger)

#%%
# seed=1
if isempty(ARGS)
    seed_start = 1
    seed_end = 100
else
    seed_start = parse(Int,ARGS[1])
    seed_end = parse(Int,ARGS[2])
end

for seed in seed_start:seed_end
    @info "$(now()) Begin seed $(seed)"
    flush(logio)
    Random.seed!(seed)
    name =  get_experiment_name(ed,seed)
    warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
    adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim; 
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


flush(logio)
# animate_warehouse(;warehouse=warehouse, 
# robot_step=robot_step_highway_nowait!,
# warehouse_step = warehouse_step_highway!,
# terminate_warehouse_sim=terminate_warehouse_sim,
# name=name,
# plot_fn=plot_warehouse)
