using JuMP
using HiGHS # Instal this package first.
import MunozDelgado2014
MD14 = MunozDelgado2014

optimizer =  HiGHS.Optimizer

path2main = "dados/54bus_1stage"
model = MD14.build_model(path2main, optimizer; is_direct=true)
optimize!(model)

MD14.save_results(model, "54bus_1stage")