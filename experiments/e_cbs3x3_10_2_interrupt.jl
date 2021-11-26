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
function init_robots_3x3_3(warehouse)
    add_agent!(Robot(1,2,0,1,[],0,0),2, warehouse)
    add_agent!(Robot(2,6,0,1,[],0,0),6, warehouse)
    add_agent!(Robot(3,4,0,1,[],0,0),4, warehouse)
end
wh3x3_10_3_undirected = WarehouseDefinition(Dict("m"=>3,"n"=>3),10,2,SimpleGraph,generate_warehouse_t1,init_robots_3x3_3,[8,12])
ed_cbs3x3_10_3 = ExperimentDefinition("cbs3x3_10_3",wh3x3_10_3_undirected, robot_step_cbs!,warehouse_step_cbs!)

ed = ed_cbs3x3_10_3
     
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
adf, mdf = run!(warehouse, ed.robot_step,ed.warehouse_step,terminate_warehouse_sim;
    adata=adata,mdata=mdata,agents_first=true)



#%%
warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
animate_warehouse(;warehouse=warehouse, 
    robot_step=ed.robot_step,
    warehouse_step = ed.warehouse_step,
    terminate_warehouse_sim=terminate_warehouse_sim,
    name=name * ".mp4",
    plot_fn=plot_warehouse)
