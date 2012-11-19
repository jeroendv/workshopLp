
## solve case3

# set a max timelimit to 10 sec to prevent solver from stagnating.
glpsol -m case2.mod -d case2.dat --tmlim 10 | less
