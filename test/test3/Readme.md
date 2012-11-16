File: Readme
Author: Jeroen De Vlieger
Creation Date: 2012/11/16

# Explore effect of conditional constraint generation.

> the glpk solver has a pre-process step which is very effective at
> reducing the number of constraints and variables. There are however
> cases where it falls short. Careful crafting of constraint predicates
> allows the generate of constraints only in certain conditions.
> Enabling the explicit elimination of constraints in certain situations
> where the pre-process step fails.

Case1.dat describes a situation where only the cost associated with
overbooked people is non zero.

    ReserveChoiceCost = 0
    OverbookingCost = 1
    UnbalancedLoadCost = 0

The effect will be that the model will try to minimize the total number
of overbooked people.

