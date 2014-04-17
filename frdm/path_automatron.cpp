/*This function is used update the states of the path based on the condition in the nodes
*/

void path_automatron(int *path_para,char node_act_1,char node_act_2,char tempActArray[])
{
    char temp_act_1 = 0;
    char temp_act_2 = 0;
    char state  = path_para[0];
    switch(state)
    {
        case 1:
        { //idle
            //if activation comng from entry node
            if(node_act_1)
            {
                //antegrade conduction
                path_para[0] = 2;
            }
            //activation from exit node
            else if(node_act_2)
             {
                //retrograde conduction
                path_para[0] = 3;
            }
            break;
        }
        case 2: { //antegrade conduction
            //if activation from exit node
            if(node_act_2)
             {
                //double
                path_para[0] = 4;
            }
            else
            {
                //if timer running out
                if(path_para[3] == 0)
                {
                    //reset timer
                    path_para[3] = path_para[4];
                    //activate exit node
                    temp_act_2 = 1;
                    //go to conflict state
                    path_para[0] = 4;
                }
                else
                 {
                    //timer
                    path_para[3] = path_para[3] - 1;
                }
            }
            break;
        }
        case 3: //retro
            // if activation coming from entry node
        {
            if(node_act_1)
             {
                path_para[0] = 4; //conflict
            }
             else
            {
                //if timer runs out
                if(path_para[5] == 0)
                 {
                    //reset timer
                    path_para[5] = path_para[6];
                    //activate entry node
                    temp_act_1 = 1;
                    //change state to conflict
                    path_para[0] = 4;
                }
                else
                 {
                    //timer
                    path_para[5] = path_para[5] - 1;
                }
            }
            break;
        }
        case 4: //conflict
        {
            //use state 5 to delay 2 ms
            path_para[0] = 5;
            break;
        }
        case 5:
        {
            path_para[0] = 1;
            break;
        }
    }
    tempActArray[0] = temp_act_1;
    tempActArray[1] = temp_act_2;
}
