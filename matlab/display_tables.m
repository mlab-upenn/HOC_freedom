function display_tables(response,no_of_nodes,no_of_paths,node_table,path_table)
persistent node_activation_status nodes_states path_states;
[data_fields,matches]=strsplit(response,{'!','@','#'},'CollapseDelimiters',...
    false, 'DelimiterType','RegularExpression');%split the trace data line by line into values seperated by !, @ and # and also record their presence
%all_data=[all_data;data_fields];
node_act_data=find(strcmp(matches,'!'),1);%node activation data presence status
node_sts_data=find(strcmp(matches,'@'),1);%nodes' status data presence status
path_sts_data=find(strcmp(matches,'#'),1);%paths' status data presence status
    if ~isempty(node_act_data)%if no node activation data, just append the last known status to the array
        node_activation_status=str2double(data_fields(node_act_data));
    end
    if ~isempty(node_sts_data)%if no node state data, append previous value to the array
        nodes_states=str2double(data_fields(node_sts_data));
    end
    if ~isempty(path_sts_data)%if no path state data, append previous value to the array
        path_states=str2double(data_fields(path_sts_data));
    end
    temp_node_activation_status=node_activation_status;
    temp_nodes_states=nodes_states;
    temp_path_states=path_states;
    for j=1:no_of_nodes,
        %undo the encoding done by the board to retrieve information
        node_table(j,1)=mod(temp_nodes_states,4);
        node_table(j,6)=mod(temp_node_activation_status,2);
        temp_nodes_states=floor(temp_nodes_states/4);
        temp_node_activation_status=floor(temp_node_activation_status/2);
    end
    for j=1:no_of_paths,
        %undo the encoding done by the board to retrieve information
       path_table(j,1)=mod(temp_path_states,4);
       temp_path_states=floor(temp_path_states/4);
    end
    clc;
    node_table %print the node_table onto the command prompt
    path_table %print the path_table onto the command prompt
    
end