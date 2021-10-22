using Warehouse
using Random
using Agents
using CSV
using Logging,Dates

ed = ed_cbs17x15_10_5 
edir ="/home/datalab/projects/agents/warehouse/experiments/$(ed.identifier)/"  
if !isdir(edir)
    mkdir(edir)
end


#%%
# seed=1
for seed in 9:10
    @info "$(now()) Begin seed $(seed)"
    Random.seed!(seed)
    name =  get_experiment_name(ed,seed)
    warehouse, plot_warehouse = init_warehouse_with_plot(ed.warehouse_definition;seed=seed)
    tsk = @async  adf, mdf = run!(warehouse, ed.robot_step,ed.waMillisecond(1000)rehouse_step,terminate_warehouse_sim; adata=adata,mdata=mdata,agents_first=true)
    Base.schedule(tsk)
    sleeped =  0
    interupted = false
    while !istaskdone(tsk)
        sleep(5)
        sleeped +=  5
        if sleeped > 10
            interupted = true
            Base.throwto(tsk, InterruptException())
            display("Seed $(seed) interupted")
        end
    end
       
    if !interupted
        adf,mdf = fetch(tsk)


        CSV.write("$(edir)$(name)_adata.csv",adf)
        CSV.write("$(edir)$(name)_mdata.csv",mdf)
    end
    @info "$(now()) End seed $(seed)"
end