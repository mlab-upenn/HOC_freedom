/****Send 'u' to the serial port to update table
Send 'd' to start the transmission of vital information through serial port
Send 'i' to start transmission of vital information through serial port in sync with heart model execution, this differs from 'd' mode in that
in 'd' mode, the transmission happens at a independant pace. In 'i' mode, the transmission happens every 1ms provided the display of data doesn't exceed
1ms
Send 's' to stop the transmission, note that you might need to send 's' several
times for successful cessation of transmission****/


/*********DATA ENCODING LOGIC***********
*****Node activation data encoding procedure*****
The node activation value for each node can be either 0 or 1 so
one bit is sufficient to encode this data. A variable,node_activation_status, accumulates
the node activation data for all nodes bit by bit with LSB containing the data for the first node

*****Path and Node status encoding procedure*****
Even though there are 5 possible values for the path status, only 3 are required for monitoring purposes,
these three values can be encoded into 2 bits. The variable paths_status hold the paths' status with the LSB and 
the next higher bit corresponding to the first path
Similar logic is followed to encode the Nodes' state and stored in nodes_status

This level of encoding and transmission is time consuming when the number of nodes and paths increase and causes 
delay in the schedule of heart model when the transmission and heart model execution takes more than 1ms collectively

To further optimise the transmission process, the various values mentioned above are sent only when there is a change from the previous value
Not all three variables change, i.e. node_activation_status,nodes_status and paths_status. Therefore, only the changed values are
transmitted. When only certain values are transmitted, it is difficult to determine what does the value recieved correspond to on the recieving end
To overcome this problem, every variable transmission is followed by a "delimiter" which indicates the data preceding it
'!' is used to indicate node_activation_status, '"' is used for nodes_status and '#' is used for paths_status

Even the above mentioned optimization proved time consuming for larger nodes. A newer strategy was adapted and implemented
After the variables are populated using the table values, the resulting values in the variables are converted to ASCII characters
by dividing the numbers by 90 (since there are 91 usable and displayable characters that are not used for other purposes) and converting the remainder
of each division to a ascii character and transmitting this character. The idea behind this conversion is that a two digit number can be converted to
a single character thereby reducing number of characters sent for the same numeric value and hence reducing transmission time.
****/
#include "mbed.h"
#include "heart_model.h"
/***Macro to convert the values to characters and print
The numbers are converted to characters by splitting them up to values between 0 and 89 and adding an offset of 36 to bring the numbers in the range of
36 and 126, these numbers are then converted to ascii characters and made into a string to be printed in one shot, the characters range from '$' to '~' ***/
#define CONVERT_AND_PRINT(x,symbol) \
do{\
    char s[7]={0,0,0,0,0,0,0};\
    char char_count=0;\
    do{\
        s[char_count]=((x)%90)+36;\
        (x)/=90;\
        char_count++;\
    }while((x)>0);\
    s[char_count]=(symbol);\
    char_count++;\
    s[char_count]=0;\
    pc.printf("%s",s);\
}while(0)

inline void displayData(char option);//function made inline mainly to increase execution speed in the heart interrupt routine
inline void displayData_e(char option);//display node activation data whenever there is a pace on any nodes
void changePathParams(char option);//function to change the path parameters of the heart, only the forward and reverse conduction values
void changeNodeParams(char option);//function to change the node parameters of the heart, only the ERP and RRP values
void updateTable();//function to update the node and path table upon request through serial communication
int** makeTable(char row, char column);/*even though some of these values can be converted to short to save memory, in the interest
of performance, they are left as int, int is supposed to be the natural data type of the computer and hence this would speed up execution*/
void freeTable(int** pointer,char row);//routine to free the memory allocated to 2d integer pointers
void loadTable();//this routine populates the node table and the path table with the default values
void heart_scheduler();//wrapper function that in turn calls the heart model every 1ms
void node1_pacer();//wrapper function to pace the first node by making the node activation signal for the node as 1
void node_last_pacer();//wrapper function to pace the last node in the same way as the previous function
inline void log_data();

//the below 8 lines have declared variables as global to increase speed of operation and to facilitate use of interrupts.
const unsigned int node_op_table[4][6]=
{/*values loaded for option 0*//*values for option 1*//*values for option 2*/
        {200,     700,               400,     800,           500,     900},
        {350,    9999,               450,    9999,           550,    9999},
        {400,    9999,               500,    9999,           600,    9999},
        {450,    9999,               550,    9999,           650,    9999}};
        
const unsigned int path_op_table[3][6]=
{/*values loaded for option 0*//*values for option 1*//*values for option 2*/
        {20,     70,               40,    80,           50,    90},
        {35,     99,               45,    99,           55,    99},
        {40,     99,               50,    99,           60,    99}};
        
/*a non zero value in the first row indicates intention to schedule repetitive triggering of nodes and the value of the first row
indicates the repetition period in milliseconds*/
int** trigger_table;
char nx = 4;
char ny = 7;
char px = 3;
char py = 7;
int** node_table = makeTable(nx,ny);
int** path_table = makeTable(px,py);
long unsigned int node_activation_status,prev_node_activation_status=0;//variables which store the 6th column of the node table and transmit upon change
long unsigned int nodes_status,prev_nodes_status=0;//variables which encode the nodes' states for transmission
long unsigned int paths_status,prev_paths_status=0;//variables to store the paths' states for transmission
char enable_display=0;//indicate that asynchronous display is enabled
char change=0;//indicate a change in either the node activation column or the nodes' states or the paths' states
char immediate_display=0;//used to indicate that synchronous display is enabled
char start_display=0;/*formed using enable_display and immediate_display to indicate suitability to start display of values, this is done
by initiating transmission of various states when node 1 is activated*/
char sch_activation=0;//regular activation is enabled when sch_activation is 1
long double activation_history[2000];
unsigned int run_count=0,current_index;//overflow of run_count is acknowledged
DigitalOut asense(PTA4);//pin to transmit asense
InterruptIn npace_end(PTD4);//pin to trigger node activation for node4
InterruptIn npace1(PTA5);//pin to trigger node activation for node1
DigitalOut vsense(PTA12);//pin to transmit vsense
DigitalOut asense_ref(PTB8);
DigitalOut vsense_ref(PTB9);
Serial pc(USBTX, USBRX);
Ticker heart_trigger;
Timer pulse_timer;
long double LastA, LastV;//variables to record the time at which latest A event or V event occured
int main()
{
    pc.baud(115200);//set the baud of serial communication to 115200
    loadTable();//load default values to start heart execution
    wait(1);//wait introduced to let the signals settle down after a flash or reset.
    heart_trigger.attach(&heart_scheduler,0.001);//heart model set to execute every 1ms, the function heart_scheduler calls the function heart_model
    npace1.fall(&node1_pacer);//activate the first node upon a falling edge on pin npace1
    npace_end.fall(&node_last_pacer);//activate last node
    pulse_timer.start();
    //update_pin.fall(&req_generator);
    while(1)//infinite while loop
    {
        if(pc.readable())//if any character in the input buffer, check for the character
        {
            if(pc.getc()=='u')// to enable updation of the table, may need several attempts before acknowledged
            {
                __disable_irq();
                heart_trigger.detach();//stop heart model execution by detaching from the trigger while updating the table
                //free the tables used for the current configuration in preparation for the new configuration
                freeTable(node_table,nx);
                freeTable(path_table,px);
                updateTable();
                __enable_irq();
                heart_trigger.attach(&heart_scheduler,0.001);
            }
            else if(pc.getc()=='d')// to enable transmission of vitals via serial port, diplay occurs independant of the heart execution, needs several attempts to enable display
            {
                //set the previous values of variables to zero
                prev_node_activation_status=0;
                prev_nodes_status=0;
                prev_paths_status=0;
                immediate_display=0;//stop display routine in heart interrupt if this display mode is enabled
                enable_display=1;// enable 'd' mode
            }
            else if(pc.getc()=='i')// to enable display of the states in synchronous with the heart execution, sending an i disables 'd' mode if enabled previously
            {
                //set the previous values of variables to zero
                prev_node_activation_status=0;
                prev_nodes_status=0;
                prev_paths_status=0;
                enable_display=0;//stop asynchronous display if this form of display is enabled
                immediate_display=1;
            }
            else if(pc.getc()=='s')// to disable transmission of node activation signals
            {
                start_display=0;
                enable_display=0;//stop both forms of display
                immediate_display=0;
                pc.printf("k\n\r");
            }
        }
        if((enable_display)&&(start_display))
        {
            displayData(0);//call to transmit vitals via serial communication
        }
   }
}

void heart_scheduler()//periodic function to call the heart model every 1ms
{
    asense_ref=1;
    heart_model(node_table,path_table,nx,ny,px,py,sch_activation,trigger_table);//heart_model function to update the table every 1ms
    log_data();
    run_count++;
    //char sig_sum=0;//accumulate the activation values of all the nodes
    asense=node_table[0][5];
    if(node_table[0][5])
    {
        LastA=pulse_timer.read_ms();
    }
    //asense_ref=node_table[0][5];
    vsense=node_table[nx-1][5];
    if(node_table[nx-1][5])
    {
        LastV=pulse_timer.read_ms();
    }
    vsense_ref=node_table[nx-1][5];
    start_display|=((enable_display|immediate_display)&node_table[0][5]);//if either display modes is enabled and node 1 activation occurs, start displaying values,
    //this gives a good reference point for interpreting values sent
    //once start_display is set, it can be reset only on disabling either of the display modes by sending 's', this will reset start_display to '0'
   if((immediate_display)&&(start_display))
    {
        displayData(1);//call inline function displayData, the argument 1 is not used
    }
    //performance_check=0;//set the pin to low to indicate end of routine
    asense_ref=0;
}

void node1_pacer()//this function is called when the first node of the heart is paced
{
    //pc.printf("pace on node1 detected\n\r");//this line can be commented, for testing purposes only
    node_table[0][5]|=1;//activate the first node
    //trigger_table[1][0]=trigger_table[0][0];//load fresh values to start another countdown whenever the node is activated
    LastA=pulse_timer.read_ms();
    log_data();
    displayData_e(1);
}

void node_last_pacer()//this function is called upon a pacing signal to the last node of the heart
{
    //pc.printf("pace on node%d detected\n\r",nx);//this line can be commented, for testing purposes only
    node_table[nx-1][5]|=1;//activate the last node
    //trigger_table[1][nx-1]=trigger_table[0][nx-1];//load fresh values to start another countdown whenever the node is activated
    LastV=pulse_timer.read_ms();
    log_data();
    displayData_e(1);
}

inline void log_data()
{
    current_index=run_count%1000;
    node_activation_status=0;
    for(char i=0;i<nx;i++)//combined 'for' loop to populate data from both the node table and the path table
    {
            //one bit of node_activation_status used for indication of each node's activation value, first node's data is the lowest bit
            node_activation_status=node_activation_status<<1;//multiplication by 2 has the effect of right shift, right shift is not allowed on float values, hence this workaround
            node_activation_status|=node_table[nx-i-1][5];//stuff last node first to get the first node's data in the least significant position
    }
    activation_history[current_index]=node_activation_status;    
}
    
inline void displayData_e(char option)
{
    node_activation_status=0;
    for(char i=0;(i<nx);i++)//combined 'for' loop to populate data from both the node table and the path table
    {
            //one bit of node_activation_status used for indication of each node's activation value, first node's data is the lowest bit
            node_activation_status=node_activation_status<<1;//multiplication by 2 has the effect of right shift, right shift is not allowed on float values, hence this workaround
            node_activation_status|=node_table[nx-i-1][5];//stuff last node first to get the first node's data in the least significant position
    }
    prev_node_activation_status=node_activation_status;
    CONVERT_AND_PRINT(node_activation_status,'!');//call a macro to split the resulting number into ASCII characters for efficient transmission
    fputc('\n',pc);
    //pc.printf("%d!\n",node_activation_status);
}

inline void displayData(char option)
{
    //initialize status values to zero so that first multiplication operation won't change these variables
    node_activation_status=0;
    nodes_status=0;
    paths_status=0;
    for(char i=0;(i<nx);i++)//combined 'for' loop to populate data from both the node table and the path table
    {
            //one bit of node_activation_status used for indication of each node's activation value, first node's data is the lowest bit
            node_activation_status=node_activation_status<<1;//multiplication by 2 has the effect of right shift, right shift is not allowed on float values, hence this workaround
            //two bits of nodes_status for every node's state, the first node's data is the lowest two bits
            nodes_status=nodes_status<<2;
            node_activation_status|=node_table[nx-i-1][5];//stuff last node first to get the first node's data in the least significant position
            nodes_status|=(node_table[nx-i-1][0]-1);//stuff last node first for same reasons as previous operation,'or' operation could have yielded faster results but restricted to use '+' because of data type
    }
     for(char i=0;(i<px);i++)
    {
        //two bits per path for state information recording
        paths_status=paths_status<<2;
        paths_status|=path_table[px-i-1][0]>=4?0:(path_table[px-i-1][0]-1);//last path's information first to get the first path's information in the least significant position
    }
    if(prev_node_activation_status!=node_activation_status)//if the values have changed since previous execution, update and display new values
    {
        change=1;//indicates new value present, this variable used to print newline character if any new data sent
        prev_node_activation_status=node_activation_status;
        CONVERT_AND_PRINT(node_activation_status,'!');//call a macro to split the resulting number into ASCII characters for efficient transmission
        //pc.printf("%d!",node_activation_status);/*'!' identifies the preceding data as nodes' activation values
        //,the '!' symbol identifies which information is transmitted, useful when not all three variables are transmitted every time*/
    }
    if(prev_nodes_status!=nodes_status)//if the values have changed since previous execution, update and display new values
    {
        change=1;//indicates new value present, this variable used to print newline character if any new data sent
        prev_nodes_status=nodes_status;
        CONVERT_AND_PRINT(nodes_status,'"');//call a macro to split the resulting number into ASCII characters for efficient transmission
        //pc.printf("%d\"",nodes_status);//'"' to indicate the data preceding as nodes' state values
    }
    if(prev_paths_status!=paths_status)
    {
       change=1;//indicates new value present, this variable used to print newline character if any new data sent 
       prev_paths_status=paths_status;
       CONVERT_AND_PRINT(paths_status,'#');//call a macro to split the resulting number into ASCII characters for efficient transmission
       //pc.printf("%d#",paths_status);//'#' to indicate the data preceding as paths' state values
        //this method will be effective for large number of nodes, not for small counts
    }    
    if(change==1)//transmit newline character to indicate end of transmission
    {
        change=0;
        fputc('\n',pc);
    }
}

void updateTable()
{
    //These variables are limited to only this code
    char temp_char=0,no_of_rows=0,no_of_cols=0,table_no=0;
    int buffer=0,no_of_cmas=0,char_count=0;
    pc.printf("Enter new node and path tables\n\r");//indicate entry into this function for confidence in functionality
    while(1)//keep running the loop till exited upon encounter of character 'z' in the data stream
    {
        while(pc.readable())//continue reading data when present in input buffer
        {
            temp_char=pc.getc();//get the single character from the stream
            //pc.putc(temp_char);// for user confidence that the inputs are read, can be removed when data is fed automatically
            char_count++;
            if((temp_char>='0')&&(temp_char<='9')) {//if numbers are encountered, build up the numbers till a ',' is encountered
                buffer*=10;
                buffer+=(temp_char-'0');
            }
            else if(temp_char==',') {//used to indicate new values in the stream
                if(no_of_cmas<2)//first two numbers seperated by commas are the number of rows and columns in each table
                {
                    if(no_of_cmas==0)
                    {
                        no_of_rows=buffer;//firt number is the number of rows of the new table
                    }
                    else if(no_of_cmas==1)
                    {
                        no_of_cols=buffer;//second number is the number of columns in the new table, even though fixed at 7, included for symmetry
                        if(table_no==0)
                        {
                            
                            node_table=makeTable(no_of_rows,no_of_cols);//create a table based on the new row and column counts for node_table
                            nx=no_of_rows;
                            ny=no_of_cols;
                        }
                        else
                        {
                            path_table=makeTable(no_of_rows,no_of_cols);//create a table based on the new row and column counts for the path table
                            px=no_of_rows;
                            py=no_of_cols; 
                        }
                    }
                }
                if(no_of_cmas>=2)
                {
                    if(table_no==0)
                    {
                        node_table[(no_of_cmas-2)/ny][(no_of_cmas-2)%ny]=buffer;//assign the values to appropriate elements in the node table
                    }
                    else
                    {
                        path_table[(no_of_cmas-2)/py][(no_of_cmas-2)%py]=buffer;//assign the values to appropriate elements in the path table
                    }
                }
                no_of_cmas++;//increment the number of commas encountered
                buffer=0;//clear buffer upon every comma to build up new number
            }
            else if(temp_char=='x')// 'x' seperates the node table from the path table
            {
                //reset required values in preparation of next table population
                no_of_rows=0;
                no_of_cols=0;
                no_of_cmas=-1;
                table_no=1;
            }
            else if(temp_char=='z')// terminates the table update code
            {
                break;
            }
        }//end of while(pc.readable()) loop
        if(temp_char=='z')
        {
            pc.printf("%d\n",char_count);
            //pc.printf("\n");//sends termination character for Matlab to infer as end of transmission
            break;//exit from the tables updation loop
        }
    }//end of while(1) loop
    //displayData(0);
}

int** makeTable(char row, char column)
{
    int** theArray;
    theArray = (int**) malloc(row*sizeof(int*));
    for (char i = 0; i < row; i++)
        theArray[i] = (int*) malloc(column*sizeof(int));
    if(theArray==NULL)
    {
        pc.printf("Not enough memory\n\r");//if not able to allocate memory, indicate via serial port
        exit(1);
    }
    return theArray;

}

void freeTable(int** pointer,char row)
{
    for(char i=0;i<row;i++)
    {
        free(pointer[i]);
        pointer[i]=NULL;
    }
    free(pointer);
    pointer=NULL;
}
/* NOTE: indices have to be checked...
 path has to less than no. of rows*/
void loadTable()//function to load the default values to the variables
{
     node_table[0][0] = 1; node_table[0][1] = 131; node_table[0][2] = 220; node_table[0][3] = 700; node_table[0][4] = 700; node_table[0][5] = 0; node_table[0][6] = 0;
     node_table[1][0] = 1; node_table[1][1] = 320; node_table[1][2] = 400; node_table[1][3] = 9209; node_table[1][4] = 9999; node_table[1][5] = 0; node_table[1][6] = 0;
     node_table[2][0] = 1; node_table[2][1] = 320; node_table[2][2] = 350; node_table[2][3] = 9209; node_table[2][4] = 9999; node_table[2][5] = 0; node_table[2][6] = 0;
     node_table[3][0] = 1; node_table[3][1] = 320; node_table[3][2] = 450; node_table[3][3] = 9209; node_table[3][4] = 9999; node_table[3][5] = 0; node_table[3][6] = 0;

     path_table[0][0] = 1; path_table[0][1] = 0; path_table[0][2] = 1; path_table[0][3] = 57; path_table[0][4] = 57; path_table[0][5] = 29; path_table[0][6] = 57;
     path_table[1][0] = 1; path_table[1][1] = 1; path_table[1][2] = 2; path_table[1][3] = 57; path_table[1][4] = 85; path_table[1][5] = 85; path_table[1][6] = 85;
     path_table[2][0] = 1; path_table[2][1] = 2; path_table[2][2] = 3; path_table[2][3] = 57; path_table[2][4] = 85; path_table[2][5] = 85; path_table[2][6] = 85;

}

void changeNodeParams(char option)
{
    for(char i=0;i<nx;i++)
    {
        node_table[i][2]=node_op_table[i][option*2];//op_table contains the alternate parameters to be loaded
        node_table[i][4]=node_op_table[i][option*2+1];
    }
}

void changePathParams(char option)
{
    for(char i=0;i<px;i++)
    {
        path_table[i][4]=path_op_table[i][option*2];//op_table contains the alternate parameters to be loaded
        path_table[i][6]=path_op_table[i][option*2+1];
    }
}