function display_tables_v2point2(response,no_of_nodes,no_of_paths,node_table,path_table)
persistent node_activation_status nodes_states path_states;
data_fields=response;
node_act_data=find(data_fields=='!');%node activation data presence status, search for '!' in the matches array, if present, it means that node 
%activation data is present in this response
    if ~isempty(node_act_data)%if no new node activation data, don't change the previous value of node_activation_status
        temp_data=data_fields(1:node_act_data-1);
        data_fields(1:node_act_data)=[];
        node_activation_status=0;
        for i=size(temp_data,2):1
            node_activation_status=node_activation_status*90+temp_data(i)-36;
        end
    end
    node_sts_data=find(data_fields=='"');%nodes' status data presence status
    if ~isempty(node_sts_data)%if no node status change data, don't change the previous value of nodes_states
        temp_data=data_fields(1:node_sts_data-1);
        data_fields(1:node_sts_data)=[];
        nodes_states=0;
        for i=size(temp_data,2):1
            nodes_states=nodes_states*90+temp_data(i)-36;
        end
    end
    path_sts_data=find(data_fields=='#');%paths' status data presence status
    if ~isempty(path_sts_data)%if no node status change data, don't change the previous value of path_states
        temp_data=data_fields(1:path_sts_data-1);
        path_states=0;
        for i=size(temp_data,2):1
            path_states=path_states*90+temp_data(i)-36;
        end
    end
    temp_node_activation_status=node_activation_status;
    temp_nodes_states=nodes_states;
    temp_path_states=path_states;
    for j=1:no_of_nodes,
        %undo the encoding done by the board to retrieve information
        node_table(j,1)=mod(temp_nodes_states,4)+1;%convert the encoding from "0 to 1" to "1 to 2", this is the reason for addition by 1 
        node_table(j,6)=mod(temp_node_activation_status,2);
        temp_nodes_states=floor(temp_nodes_states/4);%since MATLAB represents data in floating numbers, round it off to integer values
        temp_node_activation_status=floor(temp_node_activation_status/2);%since MATLAB represents data in floating numbers, round it off to integer values
    end
    for j=1:no_of_paths,
        %undo the encoding done by the board to retrieve information
       path_table(j,1)=mod(temp_path_states,4)+1;%convert the encoding from "0 to 1" to "1 to 2", this is the reason for addition by 1
       temp_path_states=floor(temp_path_states/4);%since MATLAB represents data in floating numbers, round it off to integer values
    end
    clc
    node_table %print the node_table onto the command prompt
    path_table %print the path_table onto the command prompt
    
end