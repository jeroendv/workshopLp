File: Readme
Author: Jeroen De Vlieger
Creation Date: 2012/11/15

Example case where the solver continues working but seems to stagnate.
The open question that we can't answer at the moment is:

    How to choose a reasonable time limit?

# Dangers of to short time limits

To short a time limit can result in an infeasible solution!

Case 1 and Case 2 solve the problem with an explicit time limit of
respectively 1 and 5 second. This time limit is to short. In both cases
the returned solution has a all zero assignment matrix which is'n even
feasible. I.e. the returned solution is simply *Wrong*!!

In this case it is fairly obvious to see that the returned solution is
wrong because nobody is assigned to anything. It is however conceivable
that the solver would return a solution that seems to correspond to a
solution, e.g., a lot of people get assigned and sessions are fairly
full, while the returned solution is still infeasible! The only way to
detect this would be to explicitly check if the solution is feasible
in a post processing step! Something that is not done  at the moment.

# To large time limit

The danger of choosing to large a time limit would be that you might be
waiting unnecessarily long for a solution that was found fairly quickly.

In case 3 for example the solver reports a solution after 10 second that
seems ok.  Remember though that I haven't explicitly checked if this
solution is feasible!

In case 4 the solver runs for 30 seconds instead of 10 without any
noticeable improvements. The number of overbooked people remains
unchanged. And the load in each session is identical. This indicates
that case 4 spended 20 extra second to improve the solution without
success. Meaning that you waited in vain for 20 extra second.




