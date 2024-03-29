module Warehouse

include("warehouse.jl")
include("highway.jl");
include("cbs.jl")
include("definitions.jl")

export get_experiment_name,init_warehouse_with_plot,terminate_warehouse_sim, animate_warehouse
export adata,mdata

export ed_hw3x3_10_2,ed_hw17x15_1000_35, ed_cbs17x15_1000_35,ed_cbsd17x15_1000_35,ed_cbs3x3_10_2
export ed_cbs17x15_10_5
export ed_cbs17x15_1000_20,ed_hw17x15_1000_20,ed_cbsd17x15_1000_20
export ed_hw119x5_100_20, ed_cbsd119x5_100_20, ed_cbs119x5_100_20
export ed_hw5x19_100_20, ed_cbs5x19_100_20,ed_cbsd5x19_100_20
export ed_cbs19x5_100_20

export time_delta
export WarehouseDefinition, ExperimentDefinition, init_warehouse, generate_warehouse_t1, generate_warehouse_t2
export robot_step_highway_nowait!,warehouse_step_highway!,robot_step_cbs!, warehouse_step_cbs!,Robot

measure_execution_time = true
timeout = 36000

end 
