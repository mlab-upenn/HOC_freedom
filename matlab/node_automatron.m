function [temp]=node_automatron(node_para)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function update the  status of a single node by considering the current status of
% the node
%
% Inputs:
% node_para: Cell array, parameters for the nodes
%
%            format: {'node name', node_state_index, TERP_current,
%            TERP_default, TRRP_current, TRRP_default, Trest_current,
%            Trest_default, activation,[Terp_min,Terp_max],index_of_path_activate_the_node}
% path_ind: paths connecting to the node except the one activated the node
% term_ind: which terminal the node connecting to the paths(1 or 2)
%
% Outputs:
% The same as inputs, just updated values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Activate node
temp_act=0;
% Activate path
temp_path=0;

if node_para{9} % if node is activated
%     temp=node_para{10};
    switch node_para{2}
        
        case 1 %Rest
           
            % reset ERP 

            node_para{3}=node_para{4};
            % Activate paths
            temp_path=1;
            % Reset Trest
            node_para{7}=node_para{8};
            % change state to ERP
            node_para{2}=2;
        case 2 %ERP
         
            % reset TERP
            node_para{3}=node_para{4};
    end
else % if node is not activated
    switch node_para{2}
        case 1 %Rest
            if node_para{7}==0 % self depolarize
                % change state to ERP
                node_para{2}=2;
                % reset Trest timer
                node_para{7}=node_para{8};
                % activate the node
                temp_path=1;
                temp_act=1;
            else
                % timer
                node_para{7}=node_para{7}-1;
            end
        case 2 %ERP
            if node_para{3}==0 %timer running out
                % change state to RRP
                node_para{2}=1;
                % reset TERP timer
                node_para{3}=round((1+(rand-0.5)*0)*node_para{4});
            else
                % timer
                node_para{3}=node_para{3}-1;
            end

    end
end
%--------------------------------------
temp=[node_para(1:5),temp_act,temp_path];
%---------------------------------------
return