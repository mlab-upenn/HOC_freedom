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
response=fscanf(serialObj);
tries=0;
while((tries<4)&&(length(response)<=0))
length(response)
fwrite(serialObj,'i','async');
response=fscanf(serialObj);
tries=tries+1;
end
if(length(response)<=0)
    fread(serialObj,serialObj.BytesAvailable);
    disp('Could not initiate transmission, try again');
    return;
end
tic;
while(toc<1000)
   display_tables_v2point2(response,no_of_nodes,no_of_paths,node_table,path_table);
   response=fscanf(serialObj);
end

fwrite(serialObj,'s','async');
while((length(response)~=1))
    try
        fread(serialObj,serialObj.BytesAvailable);
    catch
        break;
    end
    try
        fwrite(serialObj,'s','async');
    catch
    end
end

% while(serialObj.BytesAvailable>0)
%     fread(serialObj,serialObj.BytesAvailable);
% end

while(1)
    if(strcmpi(serialObj.transferStatus,'idle'))
        fclose(serialObj);
        break;
    end
end