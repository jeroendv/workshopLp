
## solve case1

# set a max timelimit to 10 sec to prevent solver from stagnating.
glpsol -m case1.mod -d case1.dat --tmlim 10 | less
