File: Readme
Author: Jeroen De Vlieger
Creation Date: 2012/11/16

# Effect of conditional constraint generation.

The glpk solver has a pre-process step which is very effective at 
reducing the number of constraints and variables. There are however 
cases where it falls short. Careful crafting of constraint predicates 
allows the generate of constraints only in certain conditions.  Enabling 
the explicit elimination of constraints in certain situations where the 
pre-process step should fail to do so automatically. This can 
potentially have a significant effect on the required computational time 
to solve the problem even if the number of eliminated constraints may 
seem marginal.



## A failing pre-processing step

### case1.sh

case1.dat describes a rather normal situation where all cost parameters 
related to model.9 are nonzero.

    param ReserveChoiceCost  := 1;
    param UnbalancedLoadCost := 1;
    param OverbookingCost 	 := 1;

case1.mod is a model equal to model 9 but with different output 
processing.

Note that when invoking the solver it will report some stats of the 
created model and do so again after pre-processing. This results in the 
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

### case2.sh

case2.dat describes the same problem but now all but the overbooking 
costs are set to zero.

    param ReserveChoiceCost  := 0;
    param UnbalancedLoadCost := 0;
    param OverbookingCost 	 := 1;

This will have the effect that the model will minimize the total number 
of people that are overbooked.

Running the same model on case2.dat gives:

    $ bash case2.sh
    ...
    Model has been successfully generated
    GLPK Integer Optimizer, v4.45
    14152 rows, 8724 columns, 41322 non-zeros
    8664 integer variables, all of which are binary
    ...
    Preprocessing...
    2225 rows, 2213 columns, 8782 non-zeros
    2166 integer variables, all of which are binary
    ...

Note how the problem has the same number of constraints and variables 
both before and after the pre-processing as in case 1!

The model that we are using however includes some constraints 
responsible for computing the SessionLoadDifference variable, which is a 
derived results used for session load balancing. It is however no longer 
needed because the cost associated with an unbalance is set to zero in 
this particular case.  Hence these constraints aren't needed but the 
pre-process step failed to eliminate them.


## Constraint predicates

### case3.sh

case2.mod is a slightly modified version of case1.mod:
  
    $ diff case1.mod case2.mod -U 1
    --- case1.mod	2012-11-19 08:21:21.119175548 +0100
    +++ case2.mod	2012-11-19 08:21:21.195175499 +0100
    @@ -158,6 +158,6 @@
     
    -SessionLoadDifferencesAbs1{w in W}:
    +SessionLoadDifferencesAbs1{w in W:UnbalancedLoadCost > 0}:
         SessionLoadDifference[w] >= assigned[w,1]-assigned[w,2];
     
    -SessionLoadDifferencesAbs2{w in W}:
    +SessionLoadDifferencesAbs2{w in W: UnbalancedLoadCost > 0}:
         SessionLoadDifference[w] >= assigned[w,2]-assigned[w,1];

The only difference is that the two constraints responsible for 
computing the SessionLoadDifference variable between session 1 and 2 of 
each workshop are now supplied with a predicate. The predicate states 
that the constraint should only be generated if the cost associated with 
an unbalance is greater then 0.

Running case2.mod against case2.dat now results in a smaller initial 
model that is also smaller after pre-processing:

    $ bash case3.sh
    ...
    Model has been successfully generated
    GLPK Integer Optimizer, v4.45
    14128 rows, 8712 columns, 41250 non-zeros
    8664 integer variables, all of which are binary
    ...
    Preprocessing...
    2188 rows, 2188 columns, 7947 non-zeros
    2166 integer variables, all of which are binary

Compared to case2 the initial model has 24 constraints and 12 variables 
less. Note that there are 12 workshops in case2.dat and two constraints 
and one variable per workshop were explicitly eliminated using the added 
constraint predicates. Hence this is perfectly within expectation.

After pre-processing there are however 37 less constraints and 25 less 
variables compared to case2. So it would seem that in this particular 
case the pre-process step of the solver itself also benefited from our 
explicit optimization and was able to reduce more compared to case2.

This relatively small optimization of 37 less constraints also appears 
to have a huge impact on computation time:

    $ time bash case2.sh > /dev/null
    real	0m5.506s

    $ time bash case3.sh > /dev/null
    real	0m0.776s

Note however that the relation between model size and computation time 
isn't straight forward. Hence this significant gain compared to the 
marginal reduction can only be considered good luck on our part and it 
won't always be so for other problem cases. But we can conclude that 
useless constraints can however *significantly* influence the 
computation time. Explicitly eliminate them *might* thus be worth the 
effort.

Also note that the reported solution in case 3 is not identical to the 
one in case 2. The number of overbookings that they both minimize is the 
same though. So they are both optimal solutions from the solvers point 
of view.


## Conclusion

A high level language like gnu MathPog allows easy modelling of a 
problem making abstraction of practical considerations related to 
solving the constructed model. A pre-process step has the task of 
transforming that easy to understand human model into a model that is 
easy to solve by a computer. Removing the burden of optimization from 
the modeller.

The pre-process step is very important. It is capable of significant 
problem reductions using algebraic reduction techniques. It might 
however fall short though in some situations failing to detect certain 
optimization opportunities which are obvious to the user from it high 
level perspective, but not to the pre-processor form an algebraic 
perspective. 

The relation between model constraints and computation time is very 
complex. As illustrated few constraints might be the origin of most 
computation time. Hence there might be an acceptable trade-of between 
manual optimizations and increased model complexity.


 vim: fo=awqn
