function VHM_main
clc
clear global Config
clear global node_table
clear global path_table
% clear all


%%%%%%%%%%%%%%%%%%%%%%%%
% initialize GUI
%%%%%%%%%%%%%%%%%%%%%%%%
VHM_SIM_init

% global variables to communicate with the GUI
global Config
global node_table
global path_table
global probe_table
global probe_pos
global node_pos
global pace_para
global egm_table
global pace_panel_para
global data
global node_path

% aviobj=avifile('test.avi','fps',5);
% test=0;

% global clock for the heart model
g_clock=0;

% running frequency for the heart model
heart_freq=1000;

% delay time between each time stamps to observe the parameters changes easily
Config.delay=0.1;

Config.data_fig=[];


% a pause in order to show the figure
pause(0.01);

data=[];
node_path.node=[];
node_path.path=[];
while(1)
    % a pause in order to be able to check the togglebutton
    pause(0.01);
    
    % if the Run button has been pressed
   while(get(Config.Run,'Value'))
       % update the parameters for the heart 
       [node_table,path_table]=heart_model(node_table,path_table);
       
       % global clock+1
       g_clock=g_clock+1;
       
       
       % Clock interval for pacemaker
       pace_inter=round(heart_freq/sscanf(get(Config.pace_freq,'String'),'%d'));
      
       
       
       if get(Config.formal_flag,'Value')
            [egm_data,probe_amp]=formal_interface(Config,node_pos,path_table,probe_pos,probe_table,pace_para);
       else
           [egm_data,probe_amp]=functional_interface(Config,node_pos,path_table,probe_pos,probe_table);
       end

       if get(Config.pacemaker_on,'Value')
            pace_para=pacemaker_automata(pace_para, egm_data(1), egm_data(3), pace_inter);
       end

      % heart react to pacing
       path_table=heart_react_pace(probe_table,path_table,probe_pos,node_pos,probe_amp);
       
       
       % display EGM
       data=disp_EGM(Config,data,egm_table,egm_data);
       
       node_path.node=[node_path.node,cell2mat(node_table(:,2))];
       node_path.path=[node_path.path,cell2mat(path_table(:,2))];
            
       % update GUI
       update_GUI;
       

       % pause for easy-observing
       pause(Config.delay);
             
   end
    
    
    
end
end