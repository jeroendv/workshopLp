# gnu MathProg model
#
## The problem
#
# Find an optimal distribution of people over a number of workshops.
#
# Each workshop has a limited capacity but can organized multiple times over
# the span of several sessions. All the participants provided a selection of
# workshops that they would like to follow. Each participant is also asked to
# select some additional workshops to create some leeway to find an optimal
# distribution.
#
# Each participant must be assigned to a number of workshops equal to their
# number of primary choices. Overbooking of workshops and assigning people to
# a secondary choice must be avoided if possible.
#
#
## Modelling
# This file contains the description of the Linear Programming model of the
# aforementioned problem. The actual data of the problem is provided in a
# separate data file.
#
# Due to the nature of the assignment problem we don't actually have to solve
# an MIP problem as the solution of the LP problem is always of integer type.
#
# To solve the problem, invoke the following command
#
# 	% glpsol --model <modelFile> --data <dataFile> --output <outputFile>
#
#


#==============================================================================
# the problem has 3 sets:
#  + people 	(P)
#  + Workshops 	(W)
#  + sessions 	(S)
# for which parameters and variables are defined
#==============================================================================

param NbPeople;
param NbWorkshops;
param NbSessions;

set P := 1..NbPeople;
set W := 1..NbWorkshops;
set S := 1..NbSessions;
set T := 1..50;



#==============================================================================
# the parameters of the problem
#==============================================================================

# the capacity of each workshop w in session s is an integer
# '0' is assigned by default, unless otherwise specified in the data section
param Capacity{w in W, s in S} integer, default 0, >= 0;

# the choices of each person are represented as a binary value.
# 	preferred(w,p) = 1 if a person p chooses a certain shop w
# 	preferred(w,p) = 0 if a person p does not choose a shop w
#
# 	reserve(w,p) = 1 if a person p chooses a certain shop w as reserve
# 	reserve(w,p) = 0 if a person p does not choose a shop w as reserve
#
# '0' is assigned by default, unless otherwise specified in the data section
param preferred{w in W, p in P} binary, default 0;
param reserve{w in W, p in P} binary, default 0;

param ReserveChoiceCost;
param OverbookingCost;
param OverbookingsThresholds{i in T} :=  i;


# N(p) is the number of preferred choices for person p
param N{p in P} >= 0, := sum{w in W} preferred[w,p];

#==============================================================================
# the decision variables of the problem
#==============================================================================

# the primary variables if the assignment matrix!
# 	assign(w,s,p) = 1: assign person p to shop w in session s
# 	assign(w,s,p) = 0: do not assign person p to shop w in session s
var assign{w in W, s in S, p in P} >= 0, <=1;

# overbooked(w,s): the number of people assigned to a session s of shop w
#                  beyond its official capcity
var overbooked{w in W, s in S} >= 0;


# assigned(w,s): the number of people assigned to session s of shop w
var assigned{w in W, s in S }  >= 0;

var OverbookingsThresholdAchieved{w in W, s in S, t in T} binary;






#==============================================================================
# goal function
#==============================================================================

# minimize the cost of reserve choises and overbookings
minimize obj:
	sum{w in W, s in S, p in P}
		assign[w,s,p]*reserve[w,p]*ReserveChoiceCost + 
	sum{w in W, s in S, t in T}
		OverbookingsThresholdAchieved[w,s,t]*OverbookingCost*OverbookingsThresholds[t];


#==============================================================================
# model constraints
#==============================================================================


# each person p should be assigned to N(p) sessions
Assignments{p in P}: N[p] = sum{w in W, s in S} assign[w,s,p];

# shops that aren't choosen by a person can't be assigned!;
UnChoosenWorkShops{w in W, s in S, p in P}:
	if preferred[w,p] = 0 and reserve[w,p] = 0 then assign[w,s,p] = 0;

# A person can only follow a shop once
# no point in following a shop for several sessions
OnlyFollowOnce{p in P,w in W}:
    sum{s in S} assign[w,s,p] <= 1;


#compute the number of people assigned to a shop w in session s;
AssignedPeople{w in W, s in S}:
    assigned[w,s] = sum{p in P} assign[w,s,p];

# compute the with how much people a session is overbooked;
Overbookings{w in W, s in S}:
    overbooked[w,s] >=  -Capacity[w,s] + assigned[w,s];

_OverBookingsThresholds{w in W, s in S, t in T}:
	OverbookingsThresholdAchieved[w,s,t]*10000>= overbooked[w,s]-OverbookingsThresholds[t];




#==============================================================================
# data check
# note: data section is provided in a seperate file!
#==============================================================================

# a workshop can either be the first choice, the second choice or unchoosen but
# it can't be both the first and second choice.
check{w in W, p in P} : preferred[w,p] + reserve[w,p] <=1;



#==============================================================================
# print solution
#==============================================================================

solve;

# print participants of non-empty sessions
for {w in W, s in S: sum{p in P} assign[w,s,p] > 0} {
	printf: '\nworkshop %i, session %i\n', w, s ;
	printf: '--------------------------\n' ;
	printf{p in P: assign[w,s,p] = 1 and reserve[w,p] = 0}: 'person %i\n',p ;
	printf{p in P: assign[w,s,p] = 1 and reserve[w,p] = 1}: 'person %i (reserve)\n',p ;
}

# print empty sessions
printf: '\n\n';
printf: 'empty sessions:\n';
printf: '--------------------------\n' ;
for {w in W, s in S: assigned[w,s] =  0  &&  Capacity[w,s] > 0} {
	printf: 'workshop %i, session %i\n', w, s ;
}


# print overbooked sessions
param OverbookedTotal := sum{w in W, s in S} overbooked[w,s];
printf: '\n\n';
printf: 'overbooked sessions, total: %i \n', OverbookedTotal;
printf: '--------------------------\n' ;
for {w in W, s in S: overbooked[w,s] >  0 } {
	printf: 'workshop %i, session %i: amount %i\n', w, s, overbooked[w,s] ;
}

# print reserve choices
param ReserveChoicesTotal := 
	sum{w in W, s in S, p in P} assign[w,s,p]*reserve[w,p];
printf: '\n\n';
printf: 'reserve choices, total: %i\n',ReserveChoicesTotal;
printf: '--------------------------\n' ;
for {w in W, p in P: sum{s in S} assign[w,s,p] = 1 && reserve[w,p] = 1 } {
	printf: 'person %i, workshop %i\n', p, w ;
}

# print unassigned primary choices
param UnassignedFirstChoiceTotal := 
	sum{w in W, p in P: preferred[w,p] = 1 and sum{s in S}assign[w,s,p] != 1} 1;
printf: '\n\n';
printf: 'unassigned primary choices, total: %i\n', UnassignedFirstChoiceTotal;
printf: '--------------------------\n' ;
for {w in W, p in P: sum{s in S} assign[w,s,p] = 0 && preferred[w,p] = 1 } {
	printf: 'person %i, workshop %i\n', p, w ;
}

end;


# vim: ft=sh
