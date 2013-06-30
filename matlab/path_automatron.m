function [path_para,temp_act_1,temp_act_2]=path_automatron(path_para,node_act_1,node_act_2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function update the status of a single path
%
% Inputs:
% path_para: Cell array, parameters for the paths
%
%            format: {'path_name',path_state_index, entry_node_index,
%            exit_node_index, amplitude_factor, forward_speed,
%            backward_speed, forward_timer_current, forward_timer_default,
%            backward_timer_current, backward_timer_default, path_length,
%            path_slope}
% node_act_1: boolean, activation status of the entry node
% node_act_2: boolean, activation status of the exit node
%
% Outputs:
% temp_act_1: boolean, local temporary node activation of the entry node
% temp_act_2: boolean, local temporary node activation of the exit node
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp_act_1=0;
temp_act_2=0;
switch path_para{2}
    case 1 % Idle
        % if activation coming from entry node
        if node_act_1
            % Antegrade conduction
            path_para{2}=2;
        % if activation coming from exit node
        else if node_act_2
                % Retrograde conduction
                path_para{2}=3;
            end
        end
    case 2 % Antegrade conduction
        % if activation coming from exit node
        if node_act_2
            % double
            path_para{2}=4;
%             % reset timer
%             path_para{8}=path_para{9};
        else
            % if timer running out
            if path_para{8}==0
                % reset timer
                path_para{8}=path_para{9};
                % activate exit node
                temp_act_2=1;
                % go to conflict state
                path_para{2}=4;
            else
                % timer
                path_para{8}=path_para{8}-1;
            end
        end
            
    case 3 % Retro
        % if activation coming from entry node
        if node_act_1
            % conflict
            path_para{2}=4;
%             % reset timer
%             path_para{10}=path_para{11};
        else
            % if timer runs out
            if path_para{10}==0
                % reset timer
                path_para{10}=path_para{11};
                % activate the entry node
                temp_act_1=1;
                % change state to conflict
                path_para{2}=4;
            else
                % timer
                path_para{10}=path_para{10}-1;
            end
        end
    case 4 % Conflict
        % go to Idle state
        path_para{2}=5;
    case 5
        path_para{2}=1;
%     case 5 % double
%                
%         if path_para{10}==0
%                 % reset timer
%                 path_para{10}=path_para{11};
%                 % activate the entry node
%                 temp_act_1=1;
%                 % change state to conflict
%                 path_para{2}=2;
%                 return
%         end
%         if path_para{8}==0
%                 % reset timer
%                 path_para{8}=path_para{9};
%                 % activate exit node
%                 temp_act_2=1;
%                 % go to conflict state
%                 path_para{2}=3;
%                 return
%         end
%         if abs(1-path_para{8}/path_para{9}-path_para{10}/path_para{11})<0.9/min([path_para{9},path_para{11}])
%                 path_para{10}=path_para{11};
%                 path_para{8}=path_para{9};
%                 path_para{2}=4;
%                 
%         else
%             
%             path_para{8}=path_para{8}-1;
%             path_para{10}=path_para{10}-1;
%         end
        
end

