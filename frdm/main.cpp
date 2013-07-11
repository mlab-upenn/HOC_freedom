//#include "mbed.h"
#include "heartmodel.h"
#include "node_automatron.h"
#include "common.h"
#include <time.h>
#include "stdio.h"
#include "stdlib.h"

int** makeNodeTable(int row, int column);
int** makePathTable(int row, int column);
void loadData(int** node_table, int** path_table);

//Timer t;
 
int main()
{
    int t = 0;
    int nx = 4;
    int ny = 7;
    int px = 3;
    int py = 7;
    //DigitalOut led(LED_GREEN);
//    DigitalOut led1(LED_RED);
//    DigitalOut gpo(PTB8);
//    led1 = 0; // on
    //Pointers to 2d Arrays.
     //pc.printf("\nHello World!\n");
    int** node_table = makeNodeTable(nx, ny);
    int** path_table = makePathTable(px, py);
    int tempArray[2];
    loadData(node_table, path_table);
    while(1) {
        t=t+1;
        //this function is called every 1 ms.
//        t.start();
        heart_model(node_table,path_table,nx,ny,px,py,&tempArray[0]);
        //test();
//        gpo = 1;
//        t.stop();
//        printf("done: %f \n", t.read());
        for (int j = 0; j<7; j++) {
            printf("node (%d,%d) :%d\n",0,j, path_table[1][j]);
        }
        //printf("node %d", node_table[0][6]);
        if(node_table[2][5] == 1)
            break;
    }
    printf("\nHello World!\n");
    
}

int** makeNodeTable(int row, int column)
{
    int** theArray;
    theArray = (int**) malloc(row*sizeof(int*));
    for (int i = 0; i < row; i++)
        theArray[i] = (int*) malloc(column*sizeof(int));
    return theArray;
}

int** makePathTable(int row, int column)
{
    int** theArray;
    theArray = (int**) malloc(row*sizeof(int*));
    for (int i = 0; i < row; i++)
        theArray[i] = (int*) malloc(column*sizeof(int));
    return theArray;
}


/* NOTE: indices have to be checked... 
 path has to less than no. of rows*/
void loadData(int** node_table, int** path_table)
{
     node_table[0][0] = 1; node_table[0][1] = 131; node_table[0][2] = 220; node_table[0][3] = 700; node_table[0][4] = 700; node_table[0][5] = 0; node_table[0][6] = 0;
     node_table[1][0] = 1; node_table[1][1] = 320; node_table[1][2] = 400; node_table[1][3] = 9209; node_table[1][4] = 9999; node_table[1][5] = 0; node_table[1][6] = 0;
     node_table[2][0] = 1; node_table[2][1] = 320; node_table[2][2] = 350; node_table[2][3] = 9209; node_table[2][4] = 9999; node_table[2][5] = 0; node_table[2][6] = 0;
     node_table[3][0] = 1; node_table[3][1] = 320; node_table[3][2] = 450; node_table[3][3] = 9209; node_table[3][4] = 9999; node_table[3][5] = 0; node_table[3][6] = 0;
    
     path_table[0][0] = 1; path_table[0][1] = 0; path_table[0][2] = 1; path_table[0][3] = 57; path_table[0][4] = 57; path_table[0][5] = 29; path_table[0][6] = 57;
     path_table[1][0] = 1; path_table[1][1] = 1; path_table[1][2] = 2; path_table[1][3] = 57; path_table[1][4] = 85; path_table[1][5] = 85; path_table[1][6] = 85;
     path_table[2][0] = 1; path_table[2][1] = 2; path_table[2][2] = 3; path_table[2][3] = 57; path_table[2][4] = 85; path_table[2][5] = 85; path_table[2][6] = 85;

}