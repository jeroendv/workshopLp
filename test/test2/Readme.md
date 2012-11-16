File: Readme
Author: Jeroen De Vlieger
Creation Date: 2012/11/15

Example case where the solver continues working but seems to stagnate.
The open question that we can't answer at the moment is:

    How to choose a reasonable time limit?

Note: Run *make* to run do run the test yourself, and *make clean* to clean
up afterwards.

# Dangers of to short time limits

To short a time limit can result in an infeasible solution!

Case 1 and Case 2 solve the problem with an explicit time limit of
respectively 1 and 5 second. This time limit is to short. In both cases
the returned solution has a all zero assignment matrix which is'n even
feasible. I.e. the returned solution is simply *Wrong*!!


    Time used:   1.4 secs
    Memory used: 13.7 Mb (14383150 bytes)

    overbooked sessions, total: 0 
    --------------------------

    number of particpants of each workshop and session
    workshop   1:   0,   0,
    workshop   2:   0,   0,
    workshop   3:   0,   0,
    workshop   4:   0,   0,
    workshop   5:   0,   0,
    workshop   6:   0,   0,
    workshop   7:   0,   0,
    workshop   8:   0,   0,
    workshop   9:   0,   0,
    workshop  10:   0,   0,
    workshop  11:   0,   0,
    workshop  12:   0,   0,
    Model has been successfully processed

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
seems ok as can be seen in the next extract of its output
  
    TIME LIMIT EXCEEDED; SEARCH TERMINATED
    Time used:   10.4 secs
    Memory used: 13.7 Mb (14383150 bytes)


    overbooked sessions, total: 100 
    --------------------------
    workshop 1, session 1: amount 15
    workshop 1, session 2: amount 15
    workshop 5, session 1: amount 7
    workshop 5, session 2: amount 7
    workshop 8, session 1: amount 1
    workshop 8, session 2: amount 1
    workshop 10, session 2: amount 25
    workshop 12, session 1: amount 14
    workshop 12, session 2: amount 15

    number of particpants of each workshop and session
    workshop   1:  35,  35,
    workshop   2:  14,  13,
    workshop   3:  25,  25,
    workshop   4:  43,  43,
    workshop   5:  32,  32,
    workshop   6:  33,  33,
    workshop   7:  29,  29,
    workshop   8:  31,  31,
    workshop   9:  35,  35,
    workshop  10:  25,  25,
    workshop  11:  25,  25,
    workshop  12:  34,  35,
    Model has been successfully processed

Remember though that I haven't explicitly checked if this
solution is actually feasible!

In case 4 the solver runs for 30 seconds instead of 10 without any
improvements. 

    TIME LIMIT EXCEEDED; SEARCH TERMINATED
    Time used:   30.4 secs
    Memory used: 15.2 Mb (15936169 bytes)


When inspecting the actual solutions, output3.txt and output4.txt it
turns out that the solution of case 3 and case 4 are in fact identical!!

This means that case 4 spended 20 extra second to improve the
solution without success. Meaning that you waited in vain for 20 extra
second.




