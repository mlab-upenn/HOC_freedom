try
    fclose(serialObj);
catch
end
%change here to change the configuration of the node table, this affects the display_tables function also
no_of_nodes=4;
no_of_paths=3;
no_of_cols=7;
node_table=ones(no_of_nodes,no_of_cols)*999;
path_table=ones(no_of_paths,no_of_cols)*999;
serialObj = serial('COM12', ...
                  'BaudRate', 115200, ...
                  'Parity', 'none', ...
                  'DataBits', 8, ...
                  'StopBits', 1);
serialObj.InputBufferSize=2048;
serialObj.OutputBufferSize=2048;
fopen(serialObj);
fwrite(serialObj,'i','async');
pause(0.0001);
response=fscanf(serialObj);
tries=0;
while((tries<4)&&(length(response)<=0))
length(response)
fwrite(serialObj,'i','async');
pause(0.001);
response=fscanf(serialObj);
tries=tries+1;
end
tic;
while(toc<500)
   display_tables(response,no_of_nodes,no_of_paths,node_table,path_table);
   response=fscanf(serialObj);
end

fwrite(serialObj,'s','async');
response=fscanf(serialObj);
while((length(response)~=1))
fwrite(serialObj,'s','async');
response=fscanf(serialObj);
end

while(1)
    if(strcmpi(serialObj.transferStatus,'idle'))
    fclose(serialObj);
    break;
    end
end