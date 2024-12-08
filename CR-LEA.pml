# define N  5       /* number of processes in the ring */
# define L  N*2     /* size of buffer (>= 2*N) */
byte I;             /* will be used in init for assigning ids to nodes */

mtype = { msg, res };                   /* symb . Msg . Names */
chan q[N] = [L] of { mtype , byte };    /* asynchronous channels */

proctype nnode (chan inp, out; byte id)
{   byte m;

    xr inp;     /* channel assertion: exclusive recv access to channel in */ 
    xs out;     /* channel assertion: exclusive send access to channel out */

    out!msg(id);
end:    do
    :: inp?msg(m) ->
        if
        :: m == id ->
            out!res(id);
            break;
        :: m > id ->
            out!msg(m);
        :: m < id ->
            skip;
        fi;
    :: inp?res(m) ->
        out!res(m);
        break;
    od;
    printf("I am node %d and I know the leader is %d\n", id, m);
}

init {
    byte proc;
    byte Ini[6];    /* N <= 6 randomize the process numbers */
    atomic {
        I = 1;      /* pick a number to be assigned 1..N */
        do
        :: I <= N ->
            if      /* non-deterministic choice */
            :: Ini[0] == 0 && N >= 1 -> Ini[0] = I
            :: Ini[1] == 0 && N >= 2 -> Ini[1] = I
            :: Ini[2] == 0 && N >= 3 -> Ini[2] = I
            :: Ini[3] == 0 && N >= 4 -> Ini[3] = I
            :: Ini[4] == 0 && N >= 5 -> Ini[4] = I
            :: Ini[5] == 0 && N >= 6 -> Ini[5] = I  /* works for up to N = 6 */
            fi;
            I++
        :: I > N -> /* assigned all numbers 1..N */
            break
        od;
        
        /* start all nodes in the ring */
        proc = 1;
        do
        :: proc <= N ->
            run nnode(q[proc-1], q[proc%N], Ini[proc-1]);
            proc++
        :: proc > N ->
            break
        od
    }
}
