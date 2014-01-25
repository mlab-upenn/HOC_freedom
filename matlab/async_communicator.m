%unclosed serial port in previous execution of this file is closed before
%proceeding, since this is not the case always, it is put under a try and
%catch block
try
    fclose(serialObj);
catch
end
switch(str2double(input('Enter table option: ','s')))%ask the user to choose the table to load
    case 0
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n2p1.mat');
    case 1
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n4p3.mat');
    case 2
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n6p5.mat');
    case 3
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n8p7.mat');
    case 4
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n9p8.mat');
    case 5
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n10p9.mat');
    case 6
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\aflutter_simp.mat');
    otherwise
        disp('Correct option not entered, defaulting to 4 nodes and 3 path table');
        load('H:\VHM\HOC_freedom\HOC_freedom\new_codes\n4p3.mat');
end
%the number of rows and columns in the node table is converted to string to
%be sent to the board
nx=num2str(size(node_table,1));
ny=num2str(size(node_table,2));
%commas seperate every number sent to the board
transmit=strcat(nx,',',ny);
for i=1:(size(node_table,1)),
    for j=1:size(node_table,2),
        transmit=strcat(transmit,',',num2str(node_table(i,j)));
    end
end
%'x' seperates the node table data from the path table data
transmit=strcat(transmit,',','x,');
%number of rows and columns of the path table converted to string to be
%appended to the data sent to the board
px=num2str(size(path_table,1));
py=num2str(size(path_table,2));
transmit=strcat(transmit,px,',',py);
for i=1:(size(path_table,1)),
    for j=1:size(path_table,2),
        if((j==2)||(j==3))
            %*******IMPORTANT*******%
            %The table used for matlab considers the first node to be
            %number 1 but in C, first element of the array is indexed 0,
            %hence the path source and destination nodes should be reduced
            %by 1 to make sense in C
            transmit=strcat(transmit,',',num2str(path_table(i,j)-1));
        else
            transmit=strcat(transmit,',',num2str(path_table(i,j)));
        end
    end
end
%The character 'z' indicates end of transmission
transmit=strcat(transmit,',z');
%Serial communication configured to baud rate of 115200, this should be
%same as that on the mbed board, please check and comply
serialObj = serial('COM12', ...
                  'BaudRate', 115200, ...
                  'Parity', 'none', ...
                  'DataBits', 8, ...
                  'StopBits', 1);
serialObj.InputBufferSize=2048;
serialObj.OutputBufferSize=2048;
fopen(serialObj);
%asynchronous writing is the to success of this script,
%the function call, fwrite, returns control to matlab command line right
%after writing to the serial buffer so that matlab can continue
%DO NOT CHANGE THE WRITE MODE, PLEASE KEEP IT THIS WAY
%'u' indicates a request to update the node table and path table to the
%board
fwrite(serialObj,'u','async');
pause(0.001);
response=fscanf(serialObj);
tries=0;
while((tries<4)&&(length(response)<=1))
length(response)
fwrite(serialObj,'u','async');
pause(0.001);
response=fscanf(serialObj);
tries=tries+1;
end
fwrite(serialObj, transmit,'async');
response=fscanf(serialObj);
%The serial port cannot be closed right away in 'async' write mode, the
%port is continuously polled to check its status, if the port is idle,
%which is indicated by transferStatus field of the serial port object, the
%port is closed
while(1)
    if(strcmpi(serialObj.transferStatus,'idle'))
    fclose(serialObj);
    break;
    end
end
%check for proper write onto the board, the data echoed by the board is
%compared against written data and status indicated on the MATLAB command prompt
if(strcmp(transmit,response(2:end-1)))
    disp('Updation successful');
else
    disp('Data transmission error, try again');
end