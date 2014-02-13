/**** This function keeps track of time in order to cause regular activation of some or all of the nodes
if the first row of the trigger table is non-zero, then the node corresponding to the column number of the non zero element
is considered to be scheduled to be triggered every x ms where x is the value of the second of row of the same column

Activation by pacing doesn't trigger this scheduled activation****/

#define _(x) 

void periodic_trigger(char* temp_act,int** trigger_table,char nx)
{
    for(char i=0;i<nx;i++)
    {
        _(invariant \forall j:j<i && trigger_table[0][j]!=0 && 
        temp_act[j]?    trigger_table[1][j]=trigger_table[0][j]
        :               trigger_table[1][j]==max(\old(trigger_table[1][j])-1,0))
        _(invariant \forall j:j<i && trigger_table[0][j]!=0 && !trigger_table[1][j] ==>temp_act[j]==1)
        if(trigger_table[0][i]!=0)
        {
            if(temp_act[i])
            {
                trigger_table[1][i]=trigger_table[0][i];
            }
            else
            {
                trigger_table[1][i]--;
            }
            if(trigger_table[1][i]==0)
            {
                temp_act[i]|=1;
                trigger_table[1][i]=trigger_table[0][i];
            }
        }
    }
}