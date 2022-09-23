# Changes in the paper model

Since this script uses JuMP to implement the model, some changes were made to improve
the performance and take advantage of the JuMP.

## Expressions over variables

The use of JuMP's expressions avoids unnecessary variable and reduce the size of the 
problem, increasing the performance. 

- All present value costs definitions were substituted by expressions, even the objective
function variable $c^{TPV}$ is an expression in this version.

- The variables $f_{srktb}^{l}$ and $g_{srtb}^{tr}$ were also replaced by expressions
since they are defined by the linearization of the losses.

## Removing the unserved demand

The paper uses $d_{srtb}^{U}$ to represent unserved demand. However, it is preferred to 
know that the current investment options are unfeasible, instead having the option of 
increasing the costs. Sets $d_{srtb}^{U} = 0$ avoid that and increase the performance.

## Avoid replacement of planned investment

The paper allows the replacement of planned investment, but this only increases the
costs. More recent papers avoid that (Eq. 22 - 24).

## Wind generators data

During the development of this model, we cannot find the Wind generators' data.
Thus, the data used is from [this reference](https://wind-turbine.com/download/101655/enercon_produkt_en_06_2015.pdf).

## Separe renewables and dispatchable generators

In this model, we divide the generators into two different sets.
The $RW$ is related to the renewables generators.
The $D$ is related to the dispatchable generators.
In the paper, the authors use just wind and diesel generators.
Different from paper, renewable generators cannot be dispatchable.

We also simulate the case where the renewables are not injecting power into the distribution system.
This consideration adds the index $h$ to the problem.

## Radiality

We simplify the radiality constraints. But it is not expected to change the results.

## Other changes

Some other minor changes were made, but it is not expected to cause differences between 
this implementation and the model proposed by the paper. See the `src/model.jl` file.