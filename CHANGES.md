# Changes in the paper model

Since this script uses JuMP to implement the model, some changes were made to improve
the performance and take advantage of the JuMP.

## Expressions over variables

The use of JuMP's expressions avoids unnecessary variable and reduce the size of the 
problem, increasing the performance. 

- All present value costs definitions were substituted by expressions, even the objective
function variable $c^{TPV}$ is an expression in this version.

- The variables $f^{l}_{srktb}$ and $g^{tr}_{srtb}$ were also replaced by expressions
since they are defined by the linearization of the losses.

## Removing the unserved demand

The paper uses $d^{U}_{srtb}$ to represent unserved demand. However, it is preferred to 
know that the current investment options are unfeasible, instead having the option of 
increasing the costs. Sets $d^{U}_{srtb} = 0$ avoid that and increase the performance.

## Avoid replacement of planned investment

The paper allows the replacement of planned investment, but this only increases the
costs. More recent papers avoid that (Eq. 22 - 24).

## Wind generators data

During the development of this model, we cannot find the Wind generators' data.
Thus, the data used is from [this reference](https://wind-turbine.com/download/101655/enercon_produkt_en_06_2015.pdf).


## Relative GAP

The paper uses 1% of relative gap. We use 0.01%.

## Other changes

Some other minor changes were made, but it is not expected to cause differences between 
this implementation and the model proposed by the paper. See the `model.jl` file.