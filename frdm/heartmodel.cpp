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
#include "stdio.h"
//#include "mbed.h"
#include "heartmodel.h"
#include "node_automatron.h"
#include "path_automatron.h"
#include "stdlib.h"
//Serial pc1(USBTX,USBRX);
void test()
{
}

void heart_model(int** node_table,int** path_table,int nx,int ny,int px,int py,int tempArray[])
{
    //local temp node and path table
    int** temp_node = makeTempTable(nx,ny); 
    int** temp_path = makeTempTable(px,py);
    //array for activation signal
    
    int temp_act[4];
    int tempActArray[2];
    tempActArray[0] = 0;
    tempActArray[1] = 0;
    //pc1.printf("\nHello World!2\n");
    
    for(int i = 0; i<nx; i++)
    {
        //danger!!!
        //copy node table row in temp_node row before sending it.
        for(int k = 0; k< ny; k++)
            temp_node[i][k] = node_table[i][k];
        
        //  ---------------------------------
        // update parameters for each node
        
        node_automatron(temp_node[i]); //check if update is done
        
        //CHECK: temp_act
        //printf("node act:%d",temp_node[i][6]);
        temp_act[i] = temp_node[i][6];      
    }
    //pc1.printf("\nHello World!3\n");
    for(int j = 0;j<px; j++)
    {
        //copy path table row in temp_node row before sending it.
        int node_act_1;
        int node_act_2;
        
        int temp1 = path_table[j][1];
        node_act_1 = node_table[temp1][6];
        int temp2 = path_table[j][2];
        node_act_2 = node_table[temp2][6];
        //printf("node act:%d",node_act_1);
        for(int k = 0; k< py; k++)
            temp_path[j][k] = path_table[j][k];
            
        path_automatron(temp_path[j],node_act_1,node_act_2,&tempActArray[0]);
        
        //CHECK: Node activation!!
        temp_act[temp1] = (temp_act[temp1] || tempActArray[0]);
        temp_act[temp2] = (temp_act[temp2] || tempActArray[1]);
    }
    //Copy activation signal column.
    for(int h = 0; h<nx; h++)
    {
        temp_node[h][5] = temp_act[h];
        //printf("act %d:%d\n",h,temp_node[h][5]);
    }
    
    //CHECK: UPDATE NODE AND PATH TABLE
    //int** tbDelNodeTble = node_table;
    //int** tbDelPathTble = path_table;
    //tempArray[0] = **temp_node;
    
    node_table[0] = temp_node[0];
    path_table[0] = temp_path[0];
    node_table[1] = temp_node[1];
    path_table[1] = temp_path[1];
    node_table[2] = temp_node[2];
    path_table[2] = temp_path[2];
    node_table[3] = temp_node[3];
    
    /*
    for (int i = 0; i < nx; i++)
    {  
        free(node_table[i]);  
    }  
    free(node_table);
     
    for (int l = 0; l < px; l++)
    {  
        free(path_table[l]);
    }  
    free(path_table);
    node_table = temp_node;
    path_table = temp_path;*/
    //pc1.printf("\nHello World!4\n");
}

int** makeTempTable(int row, int column)
{
    int** theArray;
    theArray = (int**) malloc(row*sizeof(int*));
    for (int i = 0; i < row; i++)
        theArray[i] = (int*) malloc(column*sizeof(int));
    return theArray;
}

