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
# number of primary choices. Overbooking of workshops and assigning people to a 
# secondary choice must be avoided if possible.
#
# This file contains the description of the Linear Programming model of the 
# aforementioned problem. The actual data of the problem is provided in a 
# separate data file.
#
#
## Modelling
# Based on model.4
# Ensuring that a person can only follow at most one workshop per session.
#
# But unlike model.4, this model will prefer to assign reserve choices to late 
# subscribers rather then early subscribers. This may come at the cost of more 
# overbookings though!!


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


# N(p) is the number of preferred choices for person p
param N{p in P} >= 0, := sum{w in W} preferred[w,p];

#==============================================================================
# the decision variables of the problem
#==============================================================================

# the primary variables if the assignment matrix!
# 	assign(w,s,p) = 1: assign person p to shop w in session s
# 	assign(w,s,p) = 0: do not assign person p to shop w in session s
var assign{w in W, s in S, p in P} binary, >= 0, <=1;

# overbooked(w,s): the number of people assigned to a session s of shop w
#                  beyond its official capcity
var overbooked{w in W, s in S} >= 0;


# assigned(w,s): the number of people assigned to session s of shop w
var assigned{w in W, s in S } >= 0;






#==============================================================================
# goal function
#==============================================================================

# minimize the cost of reserve choices and overbookings
minimize obj:
	sum{w in W, s in S, p in P}
		assign[w,s,p]*reserve[w,p]*(NbPeople-p)+
	sum{w in W, s in S}
		overbooked[w,s]*OverbookingCost;


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

# a person can only follow one workshop per session
SinlgeShopPerSession{s in S, p in P}:
	sum{w in W} assign[w,s,p] <= 1;


#compute the number of people assigned to a shop w in session s;
AssignedPeople{w in W, s in S}:
    assigned[w,s] = sum{p in P} assign[w,s,p];

# compute the with how much people a session is overbooked;
Overbookings{w in W, s in S}:
    overbooked[w,s] >= -Capacity[w,s] + assigned[w,s];



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

printf: 'objective value: %30.20e\n\n', obj.val;

# print stats on the nb of assignments
param NbExpectedAssignments := sum{w in W, p in P} preferred[w,p];
printf: 'NbExpectedAssignments: %5i\n', NbExpectedAssignments ;

param UnassignedFirstChoiceTotal :=
	sum{w in W, p in P: preferred[w,p] = 1 and sum{s in S}assign[w,s,p] != 1} 1;
printf: 'Nb of unassigned first choices: %i\n', UnassignedFirstChoiceTotal;

param OverbookedTotal := sum{w in W, s in S} overbooked[w,s];
printf: 'Nb of overbooking: %i\n', OverbookedTotal;

# print unassigned primary choices
printf: '\n\n';
printf: 'unassigned primary choices, total: %i\n', UnassignedFirstChoiceTotal;
printf: '--------------------------\n' ;
for {p in P,w in W: sum{s in S} assign[w,s,p] = 0 && preferred[w,p] = 1 } {
	printf: 'person %i, workshop %i\n', p, w ;
}

# print overbooked sessions
printf: '\n\n';
printf: 'overbooked sessions, total: %i \n', OverbookedTotal;
printf: '--------------------------\n' ;
for {w in W, s in S: overbooked[w,s] > 0 } {
	printf: 'workshop %i, session %i: amount %i\n', w, s, overbooked[w,s] ;
}

# print stats on participants of each session
printf: '\n';
printf: 'number of particpants of each workshop and session\n';
for {w in W}{
  printf: 'workshop %3i:', w;
  for {s in S}{
    printf: ' %3i,', assigned[w,s];
  }
  printf: '\n';
}


# print assign variables that are not integer valued
param NbNonIntAssignVars :=
	sum{w in W, s in S, p in P: assign[w,s,p] != 0 && assign[w,s,p] !=1} 1;
printf: '\nnon integer valued assign variables: %i\n', NbNonIntAssignVars;
printf {w in W, s in S, p in P: assign[w,s,p] > 0 && assign[w,s,p] < 0.5}:
	'%3i,%3i,%3i: 0 + %9.2e\n',w,s,p,assign[w,s,p].val;
printf {w in W, s in S, p in P: assign[w,s,p] < 1 && assign[w,s,p] > 0.5}:
	'%3i,%3i,%3i: 1 + %9.2e\n',w,s,p,assign[w,s,p]-1;




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
for {w in W, s in S: assigned[w,s] = 0 && Capacity[w,s] > 0} {
	printf: 'workshop %i, session %i\n', w, s ;
}


end;


# vim: ft=sh : fo=caqwnr
