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
# This file contains the mathematical description of the model of the
# aforementioned problem. The actual data of the problem is provided in a
# separate data file.
#
#
## History
# based on model.9 but extended to work also for NbSessions>2
#
# It will ensure a roughly even distribution of participants in all sessions 
# and attempt to respect the First Come First Serve (FcFs) principle.
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

# There are three main goal function paramters.
#  + a scale factor of a reserve choice cost function
#  + the cost of an overbooking.
#  + a cost associated with an uneven distribution of session participants
param ReserveChoiceCost, default  0;
param OverbookingCost, default 1;
param UnbalancedLoadCost, default 0;


# N(p) is the number of preferred choices for person p
# it is the number of workshops that the person will be assinged to.
param N{p in P} >= 0, := sum{w in W} preferred[w,p];



#==============================================================================
# the decision variables of the problem
#==============================================================================
# the primary variable is the assignment matrix!
# All others are derived from this.
# 	assign(w,s,p) = 1: assign person p to shop w in session s
# 	assign(w,s,p) = 0: do not assign person p to shop w in session s
var assign{w in W, s in S, p in P} binary, >= 0, <=1;


# overbooked(w,s)
# the number of people assigned to a session s of shop w beyond its official 
# capcity
var overbooked{w in W, s in S} >= 0;


# assigned(w,s)
# the number of people assigned to session s of shop w
var assigned{w in W, s in S } >= 0;


# SessionLoadDifference[w,s]
# the difference in number of participants of worksshop w between session s and 
# session s+1.  Its a positive number!
var SessionLoadDifference{w in W, s in S} >= 0;

# TotalSessionLoadDifference[w]
# A measure of the unevenness of the distribution of participants over all 
# sessions for a specific workshop by summming the SessionLoadDifference[w,s] 
# over all sessions 1..(NbSessions -1)
var TotalSessionLoadDifference{w in W} >=0 ;






#==============================================================================
# goal function
#==============================================================================

# minimize the cost of reserve choices and overbookings
minimize obj:
	sum{w in W, s in S, p in P}
  assign[w,s,p]*reserve[w,p]*(NbPeople-p+1)*ReserveChoiceCost
  + sum{w in W, s in S}
    overbooked[w,s]*OverbookingCost
  + sum{w in W}
    TotalSessionLoadDifference[w]*UnbalancedLoadCost;


#==============================================================================
# model constraints
#==============================================================================


# each person p should be assigned to N(p) sessions
_Assignments{p in P}: N[p] = sum{w in W, s in S} assign[w,s,p];

# shops that aren't choosen by a person can't be assigned!;
_UnChoosenWorkShops{w in W, s in S, p in P}:
	if preferred[w,p] = 0 and reserve[w,p] = 0 then assign[w,s,p] = 0;

# A person can only follow a shop once
# no point in following a shop for several sessions
_OnlyFollowOnce{p in P,w in W}:
    sum{s in S} assign[w,s,p] <= 1;

# a person can only follow one workshop per session
_SinlgeShopPerSession{s in S, p in P}:
	sum{w in W} assign[w,s,p] <= 1;


# compute the number of people assigned to a shop w in session s;
_Assigned{w in W, s in S}:
    assigned[w,s] = sum{p in P} assign[w,s,p];

# compute the with how much people a session is overbooked;
_Overbooked{w in W, s in S}:
    overbooked[w,s] >= -Capacity[w,s] + assigned[w,s];

# SessionLoadDifference[w,s] = abs(assigned[w,s]-assigned[w,s+1])
_SessionLoadDifference1{w in W, s in 1..(NbSessions-1)}:
    SessionLoadDifference[w,s] >= assigned[w,s]-assigned[w,s+1];
_SessionLoadDifference2{w in W, s in 1..(NbSessions-1)}:
    SessionLoadDifference[w,s] >= assigned[w,s+1]-assigned[w,s];

# computation of TotalSessionLoadDifference
_TotalSessionLoadDifference{w in W}:
    TotalSessionLoadDifference[w] = sum{s in S} SessionLoadDifference[w,s];

#==============================================================================
# data check
# note: data section is provided in a seperate file!
#==============================================================================

# a workshop can either be the first choice, the second choice or unchoosen but
# it can't be both the first and second choice.
check{w in W, p in P} : preferred[w,p] + reserve[w,p] <=1;

# a person can't have more first choices then there are sessions.
for{p in P: N[p] > NbSessions}{
  printf: 'person %i has %i preferred choices\n',p,N[p];
}
check{p in P} : N[p] <= NbSessions;



#==============================================================================
# print solution
#==============================================================================

solve;

printf: 'objective value: %30.20e\n\n', obj.val;

# print stats on the nb of assignments
param NbExpectedAssignments := sum{w in W, p in P} preferred[w,p];
printf: 'NbExpectedAssignments: %5i\n', NbExpectedAssignments ;
param TotalCapacity := sum{w in W, s in S} Capacity[w,s];
printf: 'total Capacity: %5i\n', TotalCapacity;

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
printf: 'number of particspants of each workshop and session\n';
for {w in W}{
  printf: 'workshop %3i:', w;
  for {s in S}{
    printf: ' %2i/%2i,', assigned[w,s],Capacity[w,s];
  }
  printf: '\n';
}


# print assign variables that are not integer valued
# this should never happen and would indicate a serious problem!
param NbNonIntAssignVars :=
	sum{w in W, s in S, p in P: assign[w,s,p] != 0 && assign[w,s,p] !=1} 1;
printf{1..2:NbNonIntAssignVars >0}: '\nnon integer valued assign variables: %i\n', NbNonIntAssignVars;
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
