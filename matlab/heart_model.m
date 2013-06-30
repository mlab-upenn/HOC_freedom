function [node_table,path_table]=heart_model(node_table,path_table)
% The function update the parameters for nodes and paths in one time stamp
%
% Inputs:
% node_table: Cell array, each row contains parameters for one node
%
%    format: {'node name', node_state_index, TERP_current,
%            TERP_default, TRRP_current, TRRP_default, Trest_current,
%            Trest_default, node_activation,[Terp_min,Terp_max],index_of_path_activate_the_node} 
%
% path_para: Cell array, each row contains parameters for one path
%
%    format: {'path_name',path_state_index, entry_node_index,
%            exit_node_index, amplitude_factor, forward_speed,
%            backward_speed, forward_timer_current, forward_timer_default,
%            backward_timer_current, backward_timer_default, path_length,
%            path_slope}

       % local temp node & path table
       temp_node={};
       temp_path={};
       
       %**************************************************
       % a temp path table that can be updated by node automata
       temp_path_node=path_table;
       %***************************************************
       
       for i=1:size(node_table,1)
           %---------------------------------
           % find paths connecting to the node
           [path_ind,term_ind]=ind2sub([size(path_table,1),2],find(cell2mat(path_table(:,3:4))==i));
           
           % exclude the path which activated the node
           if ismember(node_table{i,11},path_ind)
               path_ind=path_ind(path_ind~=node_table{i,11});
               %*********************************************
               term_ind=term_ind(path_ind~=node_table{i,11});
           end
           % reset
           node_table{i,11}=0;
           %---------------------------------
           % update parameters for each node
           [temp_node(i,:),temp_path_node]=node_automatron(node_table(i,:),path_ind,term_ind,temp_path_node);
           
           % create local variables for node activation signals
           temp_act{i}=temp_node{i,9};       
       end
       
      
       for i=1:size(path_table,1)
           % update parameters for each path
           [temp_path(i,:),node_act_1,node_act_2]=path_automatron(path_table(i,:),node_table{path_table{i,3},12},node_table{path_table{i,4},12});
%             if i==34
%                 2
%             end
           %            if node_act_1
%            1
%            end
%            if node_act_2
%                2
%            end
           % update the local node activation signals of the two nodes
           % connecting to the path by using "OR" operation
%            if node_table{path_table{i,3},2}~=2
%                 temp_act{path_table{i,3}}=temp_act{path_table{i,3}} || node_act_1;
%                 %-------------------------------------
%                 % store the path that activated the node
%                 if node_act_1==1
%                     temp_node{path_table{i,3},11}=i;
%                 end
%                 %-------------------------------------
%            else
%                temp_act{path_table{i,3}}=false;
%                 node_table{path_table{i,3},3}=node_table{path_table{i,3},4};
%            end
%            
%            if node_table{path_table{i,4},2}~=2
%                 temp_act{path_table{i,4}}=temp_act{path_table{i,4}} || node_act_2;
%                 %-------------------------------------
%                 % store the path that activated the node
%                 if node_act_2==1
%                     temp_node{path_table{i,4},11}=i;
%                 end
%                 %-------------------------------------
%            else
%                temp_act{path_table{i,4}}=false;
%                node_table{path_table{i,4},3}=node_table{path_table{i,4},4};
%            end
            temp_act{path_table{i,3}}=temp_act{path_table{i,3}} || node_act_1;
            temp_act{path_table{i,4}}=temp_act{path_table{i,4}} || node_act_2;

       end
       % update the parameters to global variables
       node_table=[temp_node(:,1:8),temp_act',temp_node(:,10:12)];
       
       %*******************************************************************
       % find changes in the default antegrade conduction of the path table
       ind=find(cell2mat(temp_path_node(:,9))~=cell2mat(temp_path(:,9)));
       for i=1:length(ind)
           % update the value
          temp_path{ind(i),9}=temp_path_node{ind(i),9};
          % if the path is still in idle state, also update the current
          % value
          if temp_path_node{ind(i),2}==1
              temp_path{ind(i),8}=temp_path{ind(i),9};
          end
       end
       % find changes in the default retrograde conduction of the path table
       ind=find(cell2mat(temp_path_node(:,11))~=cell2mat(temp_path(:,11)));
       for i=1:length(ind)
          temp_path{ind(i),11}=temp_path_node{ind(i),11};
          if temp_path_node{ind(i),2}==1
              temp_path{ind(i),10}=temp_path{ind(i),11};
          end
       end
       path_table=temp_path;