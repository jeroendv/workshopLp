todo: write a proper readme file

# The Problem

Given a number of courses each organized once or multiple times in a
number of sessions. For each session a course has a specific capacity
depending on its location. Also given is a group of people that have
listed which courses they are interested in and hence would like to
go to a session of that specific course.

Hence we need to assign people to specific courses in specific sessions in some
optimal fashion. Ideally everyone could follow the courses that he would
like to follow having a perfect match of demand and supply. Practical
considerations however necessarily entail that there will be some
mismatch between demand and supply. Meaning that some people won't be
able to be assigned to a specific course because their is not enough
capacity. E.g. only a limited  number of people can enter a lecture
room at once.  While other session might have room to spare.

To try and solve this problem, people are also requested to list some
secondary choices of courses they would like to follow in case they
can't be assigned to their preferred courses.

Several consideration might play a role in defining a good or optimal
distribution:
 + people would like to be assigned their first choice instead of their
second choice. So any distribution where less people are assigned their
second choice is preferred over any other.
 + people that list their preferences early should have a lower chance
of being assigned a second choice then people that list their
preferences later on.
 + the number of people attending a course should be relatively
similar over all sessions. No sense in having a full class room in
session 1 and only one person attending in session 2.
 + Obviously a person can't be assigned to more then one course in the
same session because one can only be in one place at a time.


# Modeling and solving tools

Such a problem is known in optimisation as an assignment problem and can
be modelled using Mixed Integer Programming (MIP) for which dedicated
solvers are available.

In this project we will make us of the Gnu MathProg modeling language to
model the problem which is part of the Gnu Linear Programming Kit or
[GLPK][glpk] for short. The GLPK also includes a solver which can be
used to actually solve the problem. Other solvers that support the Gnu
Mathprog modeling language could of course also be used to read and
solve the model files developed in this project.



# Overview of project
  - description of the models
  - structure of data files
  - organization of the project
  - example data file?
  - test cases?

# Example

???

[glpk]: http://www.gnu.org/software/glpk/
  
  


