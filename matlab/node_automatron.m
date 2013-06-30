function [temp,path_table]=node_automatron(node_para,path_ind,term_ind,path_table)
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
temp_act=0;
temp_path=0;

if node_para{9} % if node is activated
%     temp=node_para{10};
    switch node_para{2}
        
        case 1 %Rest
           
            % set ERP to longest
%             node_para{4}=temp(2);
            node_para{3}=node_para{4};%+round((rand-0.5)*0*node_para{4});
            
           
%             % reset path conduction speed
%             for i=1:length(path_ind)
%                 % if at terminal 1, only affect antegrade conduction; 2 for
%                 % retrograde conduction
%                 if term_ind(i)==1
%                     path_table{path_ind(i),9}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),6});
%                 else
%                     path_table{path_ind(i),11}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),7});
%                 end
%             end
     
            temp_path=1;
            % Reset Trest
            node_para{7}=node_para{8};%round(node_para{8}*(1+(rand-0.5)*0));
            % change state to ERP
            node_para{2}=2;
        case 2 %ERP
         
            % set ERP to the lowest
%             node_para{4}=temp(1);
      
%             % set conduction speed to the slowest
%             for i=1:length(path_ind)
%                 if term_ind(i)==1
%                     path_table{path_ind(i),9}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),6}*(node_para{12}+1));
%            
%                   
%                 else
%                     path_table{path_ind(i),11}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),7}*3);
%                    
%                 end
%             
%             end
        
            % reset TERP
            node_para{3}=node_para{4};%round((1+(rand-0.5)*0)*node_para{4});
%         case 3 %RRP
%             
%             % calculate the ratio of early activation
%             ratio=node_para{5}/node_para{6};
%            
%             % calculate the ERP timer for the next round
%             
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             % don't get mad Paja, only AV node has different response
%             % pattern. so just change the reaction function of node AV to
%             % the first one
%             if node_para{12}==1
%                 node_para{4}=temp(2)+round((1+(rand-0.5)*0)*(1-(1-ratio)^3)*(temp(1)-temp(2)));
%             else
%                 node_para{4}=temp(1)+round((1+(rand-0.5)*0)*(1-ratio^3)*(temp(2)-temp(1)));
%             end
%             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             
%             node_para{3}=round((1+(rand-0.5)*0)*node_para{4});
%             
%       
%             % change the conduction speed of connecting path
%             for i=1:length(path_ind)
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 % same here, only AV node has faster trend
%                 if node_para{12}==1
%                     if term_ind(i)==1
%                         path_table{path_ind(i),9}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),6}*(1+ratio*3));
% 
%                     else
%                         path_table{path_ind(i),11}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),7}*(1+ratio*3));
% 
%                     end
%                 else
%                     if term_ind(i)==1
%                         path_table{path_ind(i),9}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),6}*(1+ratio^2*3));
% 
%                     else
%                         path_table{path_ind(i),11}=round((1+(rand-0.5)*0)*path_table{path_ind(i),12}/path_table{path_ind(i),7}*(1+ratio^2*3));
% 
%                     end
%                     
%                 end
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%               
%             end
%             
%            
%             
%             % reset TRRP
%             node_para{5}=round((1+(rand-0.5)*0)*node_para{6});
%             % change state to ERP
%             node_para{2}=2;
    end
   
else % if node is not activated
    switch node_para{2}
        case 1 %Rest
            if node_para{7}==0 % self depolarize
                % change state to ERP
                node_para{2}=2;
                % reset Trest timer
                node_para{7}=node_para{8};%round((1+(rand-0.5)*0)*node_para{8});
                % activate the node
%                 temp_act=1;
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
%         case 3 % RRP
%             if node_para{5}==0 % timer running out
%                 % change state to rest
%                 node_para{2}=1;
%                 % reset TRRP timer
%                 node_para{5}=round((1+(rand-0.5)*0)*node_para{6});
%             else
%                 % timer
%                 node_para{5}=node_para{5}-1;
%             end
    end
end
%--------------------------------------
temp=[node_para(1:8),temp_act,node_para(10:11),temp_path];
%---------------------------------------
return