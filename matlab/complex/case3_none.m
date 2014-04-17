global Config

VHM_SIM_init
load case3_noMS
%global clock
g_clock=0;
% running frequency of pacemaker
pace_inter=4;
% we need one more parameter:pace_para
w_c=0;
gdata=[];
edata=[];
egm=[];
sdata=[];
color_opt_node={[0 1 0],[1 0 0],[1 1 0]}; 
color_opt_path={'Blue','Green','Yellow','Black','Red'};
set(Config.node_pos,'XData',node_pos(:,1),'YData',node_pos(:,2));
if ~isempty(probe_pos)
set(Config.probe_pos,'XData',probe_pos(:,1),'YData',probe_pos(:,2));
end
% set(Config.path_1,'String',node_table(:,1));
% set(Config.path_2,'String',node_table(:,1));

for i=1:size(path_table,1)
    Config.path_path_plot(i)=line([node_pos(path_table{i,3},1),node_pos(path_table{i,4},1)],[node_pos(path_table{i,3},2),node_pos(path_table{i,4},2)],'LineWidth',3);
end

while(1)
    data=0;
%     if w_c==2000
probe_amp=zeros(1,size(probe_table,1));
if w_c==1
    node_table{25,9}=1;
    node_table{26,2}=2;
end
%     end
    % update the parameters for the heart 
       [node_table,path_table]=heart_model(node_table,path_table);
        % global clock+1
       g_clock=g_clock+1;
       
       w_c=w_c+1;
       if w_c>6000
           break;
       end
       
%        if w_c==6000
%            path_table{3,12}=Inf;
%             path_table{3,11}=Inf;
%        end
%         if g_clock>pace_inter
            %sensing
              egm_data(1)=node_table{22,9};
              egm_data(2)=node_table{15,9};
              % update pacemaker parameters
%               pace_para=pacemaker_VVI(pace_para, egm_data(1), egm_data(2), 1);
%               
% for i=1:size(node_table,1)
%     node_color(i,:)=color_opt_node{node_table{i,2}};
%     
% end
% 
% set(Config.node_pos,'CData',node_color);
% 
% for i=1:size(path_table,1)
%     set(Config.path_path_plot(i),'Color',color_opt_path{path_table{i,2}});
%     
%     
% end
              
              % mode data
              
%               sdata=[sdata,strcmp(pace_para{6,1},'DDD')];
              % pacing
              % a_pace
              if pace_para{1,5}
                  node_table{22,9}=1;
                  data=2;
              end
              % v_pace
              if pace_para{2,5}
                  node_table{15,9}=1;
                  data=-2;
              end
              % a_sense
              if pace_para{3,5}
                  data=1;
              end
              % v_sense
              if pace_para{4,5}
                  data=-1;
              end
              if pace_para{5,5}
                  data=0.5;
              end
              g_clock=0;
              
               egm_data=functional_sensing(node_pos,path_table,probe_pos,probe_table,probe_amp);
    egm_data=egm_data+probe_amp;
    double_ind=find(ismember(egm_table(:,3),'d'));
       
       for i=1:length(double_ind)
           temp=egm_table{double_ind(i),2};
          egm_data=[egm_data, egm_data(temp(2))-egm_data(temp(1))];
           
       end
       
              g_clock=0;
%         end
%         gdata=[gdata,data];
        egm=[egm;egm_data];
        
%         end
        gdata=[gdata,data];
        edata=[edata;node_table{1,9},node_table{6,9},node_table{15,9},node_table{3,4},path_table{9,9}];
        pause(0.01)
end
a={'RA','His','RV'};%,'AV_erp','AV_s'};
figure('Position',[200,200,650,500]);
subplot(3,1,1);
plot(egm(:,5));
set(gca,'Ylim',[-1,5]);
ylabel('Atrium');
subplot(3,1,2);
plot(egm(:,6));
set(gca,'Ylim',[-11,5]);
ylabel('Ventricle');
% figure
% for i=1:3
%     subplot(4,1,i);
%     plot(edata(:,i));
%     ylabel(a{i});
% end
subplot(3,1,3);

plot(gdata)
ylabel('pacemaker');
set(gca,'Ylim',[-2.5,2.5]);
hold on
AP=find(gdata==2);
VP=find(gdata==-2);
AS=find(gdata==1);
VS=find(gdata==-1);
AR=find(gdata==0.5);
if ~isempty(AP)
    text(AP,2*ones(1,length(AP)),'AP');
end
if ~isempty(AS)
    text(AS,1*ones(1,length(AS)),'AS');
end
if ~isempty(VP)
    text(VP,-2*ones(1,length(VP)),'VP');
end
if ~isempty(VS)
    text(VS,-1*ones(1,length(VS)),'VS');
end
if ~isempty(AR)
    text(AR,0.5*ones(1,length(AR)),'[AR]');
end

a=text(find(diff(sdata)),2*ones(1,length(find(diff(sdata)))),'MS','Color','Red');
