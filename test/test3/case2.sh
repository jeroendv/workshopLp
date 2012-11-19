
## solve case2

# set a max timelimit to 10 sec to prevent solver from stagnating.
glpsol -m case1.mod -d case2.dat --tmlim 10 | less
