#%%
using Warehouse
using Random
using Agents
using CSV
using Logging,Dates
using LightGraphs

# function init_constraints(n_agents,et)
#     constraints = Vector{Dict{Int,MutableLinkedList}}(undef,n_agents)
#     for i in 1:n_agents
#         constraints[i]=Dict(1=>MutableLinkedList{et}())
#         empty!(constraints[i])
#     end
#     return constraints
# end


# mutable struct CBSNode{T<:LightGraphs.AbstractEdge}
#     constraint::Vector{Dict{Int,MutableLinkedList}}
#     path::Vector{Vector{T}}
#     cost::Vector{Int}
# end

# %%
function init_robots_35x45_100(warehouse)
    for (i,j) in enumerate(71:71:5041)
        add_agent!(Robot(i,j,0,1,[],0,0),j, warehouse)
        # n_agents += 1
    end
end

load_spots_35x35 = collect(72:4:142);


wh35x35_1000_100_undirected = WarehouseDefinition(Dict("m"=>35,"n"=>35),1000,100,SimpleGraph,generate_warehouse_t1,init_robots_35x45_100,load_spots_35x35)
ed_cbs35x35_1000_100 = ExperimentDefinition("cbs35x35_1000_100",wh35x35_1000_100_undirected, robot_step_cbs!,warehouse_step_cbs!)

ed = ed_cbs35x35_1000_100
     
#%%


#%%
seed=1
warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)

#%%
# et = edgetype(model.graph)
# n_agents = nagents(model)

# constraints = init_constraints(n_agents,et)
# paths = [a_star(model.graph, robot.pos,robot.dest) for robot in [getindex(model,idx) for idx in 1:n_agents]]
# root= CBSNode(constraints,paths,length.(paths))


#%%
warehouse.initialized = now()
adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim;
    adata=adata,mdata=mdata,agents_first=true)



#%%
# warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
# animate_warehouse(;warehouse=warehouse, 
#     robot_step=ed.robot_step,
#     warehouse_step = ed.warehouse_step,
#     terminate_warehouse_sim=terminate_warehouse_sim,
#     name=ed.identifier * ".mp4",
#     plot_fn=plot_warehouse)
