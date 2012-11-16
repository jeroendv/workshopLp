File: Readme
Author: Jeroen De Vlieger
Creation Date: 2012/11/16

# Effect of conditional constraint generation.

The glpk solver has a pre-process step which is very effective at 
reducing the number of constraints and variables. There are however 
cases where it falls short. Careful crafting of constraint predicates 
allows the generate of constraints only in certain conditions.  Enabling 
the explicit elimination of constraints in certain situations where the 
pre-process step fails. This can potentially have a significant effect 
on the required computational time to solve the problem even if the 
number of eliminated constraints may seem marginal.

## The pre-processing step

case1.dat describes a rather normal situation where all cost parameters 
related to model.9 are nonzero.

    param ReserveChoiceCost  := 1;
    param UnbalancedLoadCost := 1;
    param OverbookingCost 	 := 1;

Note that when invoking the solver it will report some stats of the 
created model and do so again after pre-processing. Running the problem 
through  case1.mod which is based on model 9 then results in the 
following model stats:

    $ bash case1.sh
    ...
    Model has been successfully generated
    GLPK Integer Optimizer, v4.45
    14152 rows, 8724 columns, 42054 non-zeros
    8664 integer variables, all of which are binary
    ...
    Preprocessing...
    2225 rows, 2213 columns, 8782 non-zeros
    2166 integer variables, all of which are binary
    ...
        
Notice how the pre-process step reduces the model from 14152 constraints 
and 8724 variables to 2225 constraints and 2213 variables.

case2.dat describes the same problem but now all but the overbooking 
costs are set to zero.

    param ReserveChoiceCost  := 0;
    param UnbalancedLoadCost := 0;
    param OverbookingCost 	 := 1;

 vim: fo=awqn
