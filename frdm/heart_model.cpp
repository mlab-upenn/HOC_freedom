/*% The function update the parameters for nodes and paths in one time stamp
%
% Inputs:
% node_table: Cell array, each row contains parameters for one node
%
%    format: {node_state_index, TERP_current,
%            TERP_default, Trest_current,
%            Trest_default, node_activation,path_activation}
%
% path_para: Cell array, each row contains parameters for one path
%
%    format: {path_state_index, entry_node_index,
%            exit_node_index, forward_timer_current, forward_timer_default,
%            backward_timer_current, backward_timer_default}

*/
#include "heart_model.h"
#include "node_automatron.h"
#include "path_automatron.h"

void heart_model(int** node_table,int** path_table,char nx,char ny,char px,char py)
{

    char temp_act[nx];//array as large as the number of nodes to hold the activation values of all the nodes
    char tempActArray[2];//used to return the activation values for the end nodes of a path
    //initialize to zero for proper functioning
    tempActArray[0] = 0;
    tempActArray[1] = 0;

    for(char i = 0; i<nx; i++) {
        // update parameters for each node
        //update each row of the node_table in accordance with the node time parameters and node state
        node_automatron(node_table[i]); //check if update is done

        temp_act[i] = node_table[i][6];//copy activation data of each node for use in path data updation
    }
    for(char j = 0; j<px; j++) {
        //copy path table row in temp_node row before sending it.
        char node_act_1;
        char node_act_2;

        char temp1 = path_table[j][1];//copy source node information to temp1
        node_act_1 = node_table[temp1][6];//copy activation data of the source node
        char temp2 = path_table[j][2];//copy destination node information to temp2
        node_act_2 = node_table[temp2][6];//copy activation data of the destination node

        path_automatron(path_table[j],node_act_1,node_act_2,&tempActArray[0]);//update path table row wise

        //CHECK: Node activation!!
        temp_act[temp1] = (temp_act[temp1] || tempActArray[0]);
        temp_act[temp2] = (temp_act[temp2] || tempActArray[1]);
    }
    //Copy activation signal column.
    for(char h = 0; h<nx; h++) {
        node_table[h][5] = temp_act[h];
    }
}
