#%%
using Warehouse
using LightGraphs
using Agents
using Random
using CSV
using Logging,Dates

#%%
function init_robots_2x10x2_10(warehouse)seeds
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
edir ="/home/datalab/projects/agents/warehouse/experiments/$(ed.identifier)/"  
if !isdir(edir)
    mkdir(edir)
end


#%%
logio = open("$(ed.identifier).log","w+")
logger = SimpleLogger(logio)
global_logger(logger)

for seed in seeds
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



# adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim; adata=adata,mdata=mdata,agents_first=true)

# #%%
# warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
# animate_warehouse(;warehouse=warehouse, 
#     robot_step=ed.robot_step,
#     warehouse_step = ed.warehouse_step,
#     terminate_warehouse_sim=terminate_warehouse_sim,
#     name=name * ".mp4",
#     plot_fn=plot_warehouse)

seed2m = [2,6,7,8,9,10,12,14,15,16,19,20,21,22,24,25,26,28,29,30,31,32,35,36,37,39,40,46,47,48,49,50,51,52,54,57,61]