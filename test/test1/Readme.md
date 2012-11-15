File: Readme
Author: Jeroen De Vlieger
Creation Date: 2012/11/15

If there is more demand then there is supply then overbooking sessions 
might be unavoidable. Here we explore the effect how the *optimal* 
solution behaves in such a case using model.9 as our problem 
description.


# case1.dat: minimizing overbooked sessions.

Setting the cost associated with a reserve choice or some unbalanced 
load to zero and only assigning a cost to an overbooking will result in 
a optimal solution where the total number of people that are overbooked 
is minimized. 

This is done in case1.dat. Running case1.sh shows that at least a 100 
people need to be overbooked to have a feasible solution.

    $ bash ./case1.sh
    ...
    INTEGER OPTIMAL SOLUTION FOUND
    Time used:   5.2 secs
    Memory used: 13.7 Mb (14383150 bytes)

    ReserveChoiceCost = 0
    OverbookingCost = 1
    UnbalancedLoadCost = 0

    objective value:     1.00000000000000000000e+02

    NbExpectedAssignments:   722
    total Capacity: 12273
    Nb of unassigned first choices: 253
    Nb of overbooking: 100


    overbooked sessions, total: 100 
    --------------------------
    workshop 1, session 1: amount 16
    workshop 1, session 2: amount 16
    workshop 5, session 1: amount 1
    workshop 5, session 2: amount 1
    workshop 8, session 1: amount 5
    workshop 8, session 2: amount 5
    workshop 10, session 2: amount 25
    workshop 12, session 1: amount 15
    workshop 12, session 2: amount 16

    number of particpants of each workshop and session
    workshop   1:  36,  36,
    workshop   2:  19,   7,
    workshop   3:  25,  25,
    workshop   4:  43,  43,
    workshop   5:  26,  26,
    workshop   6:  33,  33,
    workshop   7:  29,  29,
    workshop   8:  35,  35,
    workshop   9:  35,  35,
    workshop  10:  25,  25,
    workshop  11:  20,  31,
    workshop  12:  35,  36,
    Model has been successfully processed







