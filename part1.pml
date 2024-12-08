# define N  5   /* number of processes in the ring */
# define L  10  /* size of buffer (>= 2*N) */
byte I;         /* will be used in init for assigning ids to nodes */

mtype = { one, two, winner };           /* symb . Msg . Names */
chan q[N] = [L] of { mtype , byte };    /* asynchronous channels */

proctype nnode (chan inp, out; byte mynumber)
{   bit Active = 1, know_winner = 0;
    byte nr, maximum = mynumber, neighbourR;
    
    xr inp;     /* channel assertion: exclusive recv access to channel in */ 
    xs out;     /* channel assertion: exclusive send access to channel out */

    printf("MSC: %d\n", mynumber);
    out!one(mynumber);
end:    do
    :: inp?one(nr) -> 
        if
        :: Active ->
            if
            :: nr != maximum ->
                out!two(nr);
                neighbourR = nr
            :: else ->
                know_winner = 1;
                out!winner,nr;
            fi
        :: else ->
            out!one(nr)
        fi

    :: inp?two(nr) ->
        if
        :: Active ->
            if
            :: neighbourR > nr && neighbourR > maximum ->
                maximum = neighbourR;
                out!one(neighbourR)
            :: else ->
                Active = 0
            fi
        :: else ->
            out!two(nr)
        fi
    :: inp?winner,nr ->
        if
        :: nr != mynumber ->
            printf("MSC: LOST\n");
        :: else -> 
            printf("MSC: LEADER\n");
        fi;
        if
        :: know_winner
        :: else -> out!winner,nr
        fi;
        break
    od
}
