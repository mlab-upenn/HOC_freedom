function VHM_GUI
    try
        fclose(u);
        clear u;
        clear all;
        close all;
        clc;
    catch
    end
    global UT_GUI
    UT_GUI.udp_handle=[];
    assignin('base','u',UT_GUI.udp_handle);
    UT_GUI.ok_to_display=0;
    UT_GUI.logging_in_progress=0;
    UT_GUI.update_in_progress=0;
    UT_GUI.nx=0;
    UT_GUI.px=0;
    UT_GUI.node_table=[];
    UT_GUI.path_table=[];
    UT_GUI.trigger_table=[];
    UT_GUI.log={'Started GUI'};
    UT_GUI.screen_size=get(0,'ScreenSize');
    UT_GUI.paths_handle=[];
    UT_GUI.add_path_mode=0;
    UT_GUI.pause=0;
    UT_GUI.time_display=0;
    UT_GUI.main_gui_handle=figure('Units', 'normalized'...
        ,'Position', [0 0 1 1]...
        ,'Resize','on'...
        ,'Name','Test Sample'...
        ,'NumberTitle','Off');
        %,'CloseRequestFcn',@close_gui);
    UT_GUI.axes_handle=axes('Units','normalized'...
        ,'Position',[0,0.2,0.48,0.8]...
        ,'Xlim',[0 530]...
        ,'Ylim',[0 530]...
        ,'XTick',[]...
        ,'YTick',[]...
        ,'ZTick',[]...
        ,'NextPlot','add');
    UT_GUI.show_signals_handle=uicontrol('Style','pushbutton'...
        ,'String','Show signals'...
        ,'Units','normalized'...
        ,'Position',[0.0 0.14 0.07 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@display_signals);   
    UT_GUI.view_history_handle=uicontrol('Style','pushbutton'...
        ,'String','Show heart history'...
        ,'Units','normalized'...
        ,'Position',[0.075 0.14 0.09 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@display_log);   
    UT_GUI.add_path_handle=uicontrol('Style','pushbutton'...
        ,'String','Add path'...
        ,'Units','normalized'...
        ,'Position',[0.17 0.14 0.05 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@add_path);
    UT_GUI.remove_node_handle=uicontrol('Style','pushbutton'...
        ,'String','Remove Node'...
        ,'Units','normalized'...
        ,'Position',[0.225 0.14 0.07 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@remove_node);
    UT_GUI.remove_path_handle=uicontrol('Style','pushbutton'...
        ,'String','Remove Path'...
        ,'Units','normalized'...
        ,'Position',[0.30 0.14 0.07 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@remove_path);
    UT_GUI.run_button_handle=uicontrol('Style','pushbutton'...
        ,'String','Run Model'...
        ,'Units','normalized'...
        ,'Position',[0.375 0.14 0.05 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@run_model); 
    UT_GUI.pause_button_handle=uicontrol('Style','pushbutton'...
        ,'String','Pause'...
        ,'Units','normalized'...
        ,'Position',[0.43 0.14 0.05 0.05]...
        ,'BackgroundColor','w'...
        ,'Enable','off'...
        ,'Callback',@pause_model); 
    UT_GUI.reset_button_handle=uicontrol('Style','pushbutton'...
        ,'String','Reset GUI'...
        ,'Units','normalized'...
        ,'Position',[0.11 0.085 0.05 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@reset_gui); 
    UT_GUI.load_model_handle=uicontrol('Style','pushbutton'...
        ,'String','Load Model'...
        ,'Units','normalized'...
        ,'Position',[0 0.085 0.05 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@load_model);  
    UT_GUI.save_model_handle=uicontrol('Style','pushbutton'...
        ,'String','Save Model'...
        ,'Units','normalized'...
        ,'Position',[0.055 0.085 0.05 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@save_model);    
    UT_GUI.load_trigger_table_handle=uicontrol('Style','pushbutton'...
        ,'String','Upload Trigger Table'...
        ,'Units','normalized'...
        ,'Position',[0.165 0.085 0.1 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@upload_trigger_table);
    UT_GUI.node_table_handle = uitable('Units','normalized'...
        ,'Position',[0.50 0.53 0.25 0.47]...
        ,'Data',UT_GUI.node_table...
        ,'RowName',[]...
        ,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric','numeric','numeric'}...
        ,'ColumnWidth','auto'...
        ,'ColumnEditable',[true true true true true true true]...
        ,'ColumnName',{'Node State','Current ERP','ERP','Current Rest','Rest','Node activation status','path status'});
        %,'CellEditCallback',@verify_table_data);
    UT_GUI.path_table_handle = uitable('Units','normalized'...
        ,'Position',[0.5 0.05 0.25 0.475]...
        ,'Data',UT_GUI.path_table...
        ,'RowName',[]...
        ,'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric','numeric','numeric'}...
        ,'ColumnWidth','auto'...
        ,'ColumnEditable',[true true true true true true true true]...
        ,'ColumnName',{'Path State','Source Node','Destination Node','current FC','Default FC','Current BC','Default BC'});
        %,'CellEditCallback',@verify_table_data);
    UT_GUI.trigger_table_handle = uitable('Units','normalized'...
        ,'Position',[0.755 0.53 0.22 0.47]...
        ,'Data',UT_GUI.trigger_table...
        ,'ColumnFormat',{'numeric','numeric'}...
        ,'ColumnWidth','auto'...
        ,'ColumnEditable',[true true]...
        ,'ColumnName',{'Trigger Type', 'Trigger Interval'}...
        ,'CellEditCallback',@update_meaning...
        ,'TooltipString','Nothing to say');
    UT_GUI.log_handle=uicontrol('Units','normalized','Style','text','String','','Position',[0.755 0.425 0.22 0.1]);
    UT_GUI.node_pace_button=uicontrol('Style','pushbutton'...
        ,'String','Pace Node(s)'...
        ,'Units','normalized'...
        ,'Position',[0.755 0.37 0.09 0.05]...
        ,'BackgroundColor','w'...
        ,'Enable','off'...
        ,'Callback',@pace_nodes);
    UT_GUI.nodes_list=uicontrol('Style','edit'...
        ,'String','Enter comma seperated Node number(s)'...
        ,'Units','normalized'...
        ,'Position',[0.845 0.37 0.13 0.05]...
        ,'BackgroundColor','w'...
        ,'Callback',@pace_nodes);
    UT_GUI.im=imread('H:\VHM\HOC_freedom\HOC_freedom\new_codes\EP.jpg');
    UT_GUI.im=image(UT_GUI.im);
    UT_GUI.nodes_position=[];
    UT_GUI.node_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','HitTest','off');%,'ButtonDownFcn',@button_press);
    UT_GUI.selected_node_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','g','MarkerFaceColor','g');
    UT_GUI.activated_node_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','y','MarkerFaceColor','y','HitTest','off','Visible','off');
    UT_GUI.excited_node_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','g','MarkerFaceColor','g','HitTest','off','Visible','off');
    UT_GUI.relaxed_node_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','HitTest','off','Visible','off');
    UT_GUI.activated_nodes_position=zeros(1,2);
    UT_GUI.excited_nodes_position=zeros(1,2);
    UT_GUI.relaxed_nodes_position=zeros(1,2);
    set(UT_GUI.activated_node_pos,'XDataSource','UT_GUI.activated_nodes_position(:,1)','YDataSource','UT_GUI.activated_nodes_position(:,2)');
    set(UT_GUI.excited_node_pos,'XDataSource','UT_GUI.excited_nodes_position(:,1)','YDataSource','UT_GUI.excited_nodes_position(:,2)');
    set(UT_GUI.relaxed_node_pos,'XDataSource','UT_GUI.relaxed_nodes_position(:,1)','YDataSource','UT_GUI.relaxed_nodes_position(:,2)');
    set(UT_GUI.im,'HitTest','off');
    set(UT_GUI.axes_handle,'ButtonDownFcn',@button_press);
    update_status;
end

function DatagramReceivedCallback(hObject,eventdata)
global UT_GUI
persistent option
    [UT_GUI.current_nodes_states,UT_GUI.current_node_activation_status,UT_GUI.current_path_states]=data_decoder(fscanf(UT_GUI.udp_handle),UT_GUI.nx,UT_GUI.px);
    if(UT_GUI.pause==0)
        if(UT_GUI.ok_to_display==1)
            signals_display(option,UT_GUI.current_node_activation_status,UT_GUI.nx);
            option=mod((option+1),2)+1;
        else 
            pause(0.000001);
            option=0;
        end
        colorcodes='bgrc';
        UT_GUI.activated_nodes_position=zeros(1,2);
        UT_GUI.excited_nodes_position=zeros(1,2);
        UT_GUI.relaxed_nodes_position=zeros(1,2);
        for i=1:UT_GUI.nx
            if(UT_GUI.current_nodes_states(i)==2)
                UT_GUI.excited_nodes_position(end+1,:)=UT_GUI.nodes_position(i,:);
            else
                UT_GUI.relaxed_nodes_position(end+1,:)=UT_GUI.nodes_position(i,:);
            end
            if(UT_GUI.current_node_activation_status(i)==1)
                UT_GUI.activated_nodes_position(end+1,:)=UT_GUI.nodes_position(i,:);
            end
        end
        UT_GUI.activated_nodes_position(1,:)=[];
        UT_GUI.excited_nodes_position(1,:)=[];
        UT_GUI.relaxed_nodes_position(1,:)=[];
        refreshdata(UT_GUI.relaxed_node_pos,'caller');
        refreshdata(UT_GUI.excited_node_pos,'caller');
        refreshdata(UT_GUI.activated_node_pos,'caller');
        for i=1:UT_GUI.px
            set(UT_GUI.paths_handle(i),'Color',colorcodes(UT_GUI.current_path_states(i)));
        end
    end
end

function pace_nodes(hObject,eventdata)
    global UT_GUI
        user_data=get(UT_GUI.nodes_list,'String');
        nodes_list=str2double(strsplit(user_data,','));
        for i=nodes_list
            if(i>0)&&(i<=UT_GUI.nx)
            num_string=sprintf('p%d',(i-1));
            fprintf(UT_GUI.udp_handle,num_string);
            end
        end
end

function update_status
global UT_GUI
    UT_GUI.log={strcat('Number of Nodes: ',num2str(UT_GUI.nx)) strcat('Number of Paths: ',num2str(UT_GUI.px))...
                strcat('Node Table size:',num2str(size(UT_GUI.node_table,1))) strcat('Path Table size:',num2str(size(UT_GUI.path_table,1)))...
                strcat('Trigger Table size: ',num2str(size(UT_GUI.trigger_table,1)))};
            set(UT_GUI.log_handle,'String',UT_GUI.log);
end

function run_model(hObject,eventdata)
global UT_GUI
persistent button_states
    if(config_check~=1)
        return;
    end
    if(strcmp(get(hObject,'String'),'Run Model'))
        comp_result=compare_model;
        if(comp_result==0)
            response=update_tables(hObject,eventdata);
        else
            response=1;
        end
        if(response==1)
             set(hObject,'String','stop');
            button_states.view_history=get(UT_GUI.view_history_handle,'Enable');
            button_states.add_path=get(UT_GUI.add_path_handle,'Enable');
            button_states.remove_node=get(UT_GUI.remove_node_handle,'Enable');
            button_states.remove_path=get(UT_GUI.remove_path_handle,'Enable');
            button_states.load_model=get(UT_GUI.load_model_handle,'Enable');
            button_states.save_model=get(UT_GUI.save_model_handle,'Enable');
            button_states.node_table=get(UT_GUI.node_table_handle,'Enable');
            button_states.path_table=get(UT_GUI.path_table_handle,'Enable');
            button_states.upload_trigger_table=get(UT_GUI.load_trigger_table_handle,'Enable');
            set(UT_GUI.view_history_handle,'Enable','off');
            set(UT_GUI.add_path_handle,'Enable','off');
            set(UT_GUI.remove_node_handle,'Enable','off');
            set(UT_GUI.remove_path_handle,'Enable','off');
            set(UT_GUI.load_model_handle,'Enable','off');
            set(UT_GUI.save_model_handle,'Enable','off');
            set(UT_GUI.pause_button_handle,'Enable','on');
            set(UT_GUI.node_table_handle,'Enable','off');
            set(UT_GUI.path_table_handle,'Enable','off');
            set(UT_GUI.load_trigger_table_handle,'Enable','off');
            set(UT_GUI.trigger_table_handle,'Enable','off');
            set(UT_GUI.activated_node_pos,'Visible','on');
            set(UT_GUI.excited_node_pos,'Visible','on');
            set(UT_GUI.relaxed_node_pos,'Visible','on');
            set(UT_GUI.node_pace_button,'Enable','on');
            set(UT_GUI.axes_handle,'ButtonDownFcn','');
            UT_GUI.udp_handle = udp('192.168.90.90', 4950, 'LocalPort', 4950);
            set(UT_GUI.udp_handle,'DatagramTerminateMode','on');
            set(UT_GUI.udp_handle, 'ReadAsyncMode', 'continuous');
            UT_GUI.udp_handle.DatagramReceivedFcn=@DatagramReceivedCallback;
            fopen(UT_GUI.udp_handle);
            fprintf(UT_GUI.udp_handle,'x');
        else
            errordlg('Could not run model','error','modal');
            return;
        end
    else
        flushinput(UT_GUI.udp_handle);
        UT_GUI.udp_handle.DatagramReceivedFcn='';
        fclose(UT_GUI.udp_handle);
        clear UT_GUI.udp_handle;
        set(UT_GUI.activated_node_pos,'Visible','off');
        set(UT_GUI.excited_node_pos,'Visible','off');
        set(UT_GUI.relaxed_node_pos,'Visible','off');
        set(UT_GUI.view_history_handle,'Enable',button_states.view_history);
        set(UT_GUI.add_path_handle,'Enable',button_states.add_path);
        set(UT_GUI.remove_node_handle,'Enable',button_states.remove_node);
        set(UT_GUI.remove_path_handle,'Enable',button_states.remove_path);
        set(UT_GUI.load_model_handle,'Enable',button_states.load_model);
        set(UT_GUI.save_model_handle,'Enable',button_states.save_model);
        set(UT_GUI.pause_button_handle,'Enable','off','BackgroundColor','w');
        UT_GUI.pause=0;
        set(UT_GUI.node_table_handle,'Enable',button_states.node_table);
        set(UT_GUI.path_table_handle,'Enable',button_states.path_table);
        set(UT_GUI.load_trigger_table_handle,'Enable',button_states.upload_trigger_table);
        set(UT_GUI.trigger_table_handle,'Enable','on');
        set(UT_GUI.node_pace_button,'Enable','off');
        set(UT_GUI.axes_handle,'ButtonDownFcn',@button_press);
        set(hObject,'String','Run Model');
    end
end

function pause_model(hObject,eventdata)
    global UT_GUI
    UT_GUI.pause=mod((UT_GUI.pause+1),2);
    if(UT_GUI.pause==1)
        set(hObject,'BackgroundColor','c');
    else
        set(hObject,'BackgroundColor','w');
    end
end

function display_signals(hObject,eventdata)
    global UT_GUI
    if(config_check~=1)
        return;
    end
    if(strcmp(get(UT_GUI.run_button_handle,'String'),'Run Model'))
        errordlg('Model not running','error','modal');
        return;
    end
    
    if((UT_GUI.logging_in_progress==1)||(UT_GUI.update_in_progress==1))
        errordlg('Close other Windows before continuing','Multiple windows open!','modal');
        return;
    end
    UT_GUI.ok_to_display=1;
end

function result=compare_model
    global UT_GUI
    result=1;
    UT_GUI.udp_handle = udp('192.168.90.90', 4950, 'LocalPort', 4950);
    set(UT_GUI.udp_handle,'DatagramTerminateMode','off');
    fopen(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'a');
    pause(1);
    fprintf(UT_GUI.udp_handle,'c');
    pause(1);
    flushinput(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'OK');
    data=fscanf(UT_GUI.udp_handle);
    number_of_nodes=str2double(data(1:find(data==',')-1));
    number_of_paths=str2double(data(find(data==',')+1:end));
    if((UT_GUI.nx~=number_of_nodes)||(UT_GUI.px~=number_of_paths))
        for i=1:(number_of_nodes*2+number_of_paths*4)
            fprintf(UT_GUI.udp_handle,'OK');
        end
        flushinput(UT_GUI.udp_handle);
        result=0;
    else
        count=0;
        UT_GUI.node_table=get(UT_GUI.node_table_handle,'Data');
        UT_GUI.path_table=get(UT_GUI.path_table_handle,'Data');
        for i=1:number_of_nodes
            for j=[3 5]
                fprintf(UT_GUI.udp_handle,'OK');
                data=str2double(fscanf(UT_GUI.udp_handle));
                if(UT_GUI.node_table(i,j)~=data)
                    result=0;
                end
                count=count+1;
            end
        end
        for i=1:number_of_paths
            for j=[2 3 5 7]
                fprintf(UT_GUI.udp_handle,'OK');
                data=str2double(fscanf(UT_GUI.udp_handle));
                if((UT_GUI.path_table(i,j)-1+1*floor(j/4))~=data)
                    result=0;
                end
                count=count+1;
            end
        end
    end
    fclose(UT_GUI.udp_handle);
    clear UT_GUI.udp_handle;
end

function display_log(hObject,eventdata)
    global UT_GUI
    global node_activation_status nodes_states path_states start_time;
    global duration current_range x_range xlimits;
    global Heart_log;
    global click_count;
    if(config_check~=1)
        return;
    end
    UT_GUI.logging_in_progress=1;
    current_range=zeros(1000,UT_GUI.nx);
    if((UT_GUI.ok_to_display==1)||(UT_GUI.update_in_progress==1))
        errordlg('Close other Windows before continuing','Multiple windows open!','modal');
        UT_GUI.logging_in_progress=0;
        return;
    end
    set(hObject,'String','Gathering data...');
    UT_GUI.udp_handle = udp('192.168.90.90', 4950, 'LocalPort', 4950);
    set(UT_GUI.udp_handle,'DatagramTerminateMode','off');
    
    fopen(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'x');
    pause(1);
    fprintf(UT_GUI.udp_handle,'l');
    pause(1);
    flushinput(UT_GUI.udp_handle);
    fscanf(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'ok');
    data=fscanf(UT_GUI.udp_handle);
    Log_plot_helper(0,data,UT_GUI.nx,UT_GUI.px);
    while(1)
      fprintf(UT_GUI.udp_handle,'ok');%send acknowledgement for every datagram received, without this, heart won't continue sending data
      data=fscanf(UT_GUI.udp_handle);
      if(~isempty(find(data=='e',1)))
          break;
      end
      Log_plot_helper(1,data,UT_GUI.nx,UT_GUI.px);
    end
    fclose(UT_GUI.udp_handle);
    clear UT_GUI.udp_handle;
    duration=size(node_activation_status,1);
    Heart_log.figure_handle=figure('Units', 'normalized'...
        ,'Position', [0 0 1 1]...
        ,'Resize','on'...
        ,'Name','Test Sample'...
        ,'NumberTitle','Off');
    Heart_log.axes_handle=axes('Units','normalized'...
        ,'Parent',Heart_log.figure_handle...
        ,'YTick',[]...
        ,'NextPlot','add'...
        ,'Position',[0.1 0.2 0.8 0.75]);
    uicontrol('Style','text','String','0s'...
        ,'Units','normalized'...
        ,'Position',[0.125 0.125 0.025 0.025]);
    Heart_log.slider1_handle=uicontrol('Style','slider'...
        ,'Min',1,...
        'Max',duration...
        ,'Value',1,...
        'Units','normalized'...
        ,'Position',[0.15 0.15 0.70 0.025]...
        ,'SliderStep',[0.0001 0.001]...
        ,'Callback',@replot);
    Heart_log.slider2_handle=uicontrol('Style','slider'...
        ,'Min',1,...
        'Max',duration...
        ,'Value',1000,...
        'Units','normalized'...
        ,'Position',[0.15 0.125 0.70 0.025]...
        ,'SliderStep',[0.0001 0.001]...
        ,'Callback',@replot);
    uicontrol('Style','text','String',strcat(num2str(duration/1000),'s')...
        ,'Units','normalized'...
        ,'Position',[0.85 0.15 0.03 0.025]);
    whitebg(Heart_log.figure_handle,'k');
    Heart_log.interval_text_handle=text('Units','data','Position',[0 0],'String','','HitTest','off');
    set(Heart_log.axes_handle,'ButtonDownFcn',@set_time_interval);
    x_range=(1:1000)';
    click_count=0;
    color_string='ymcrgb';
    hold on;
    for i=1:UT_GUI.nx
        current_range(:,i)=node_activation_status(1:1000,i)+1.5*(UT_GUI.nx-i);
        temp_string=strcat('Node ',num2str(i));
        Heart_log.label_handle(i)=text('Units','data','Position',[500,1.5*(UT_GUI.nx-i)+0.75],'String',temp_string,'HitTest','off');
        Heart_log.plot_handle(i)=plot(current_range(:,i));
        colorcode=color_string(mod(i,6)+1);
        set(Heart_log.plot_handle(i),'XDataSource','x_range','Color',colorcode);
        set(Heart_log.plot_handle(i),'YDataSource','current_range(:,i)','HitTest','off');
    end
    hold off;
    set(Heart_log.axes_handle,'YTickLabel',[]);
    set(Heart_log.axes_handle,'box','off');
    ylim([0 1.5*UT_GUI.nx]);
    set(hObject,'String','Show heart history');
    UT_GUI.logging_in_progress=0;
end

function replot(hObject,eventdata)
    global Heart_log node_activation_status current_range UT_GUI x_range xlimits
    lower_limit=uint64(get(Heart_log.slider2_handle,'Value'));
    higher_limit=uint64(get(Heart_log.slider1_handle,'Value'));
    if(lower_limit>higher_limit)
        temp=lower_limit;
        lower_limit=higher_limit;
        higher_limit=temp;
    end
    x_range=(lower_limit:higher_limit)';
    current_range=zeros(higher_limit-lower_limit+1,UT_GUI.nx);
    %sum(current_range)
    for i=1:UT_GUI.nx
        current_range(:,i)=node_activation_status(lower_limit:higher_limit,i)+1.5*(UT_GUI.nx-i);
        set(Heart_log.label_handle(i),'Position',[(higher_limit+lower_limit)/2,1.5*(UT_GUI.nx-i)+0.75]);
        refreshdata(Heart_log.plot_handle(i),'caller');
    end
end

function set_time_interval(hObject,eventdata)
    global Heart_log node_activation_status click_count UT_GUI
    persistent start_position end_position
    mark_pt=round(get(hObject,'CurrentPoint'));
    if(click_count>1)
        delete(Heart_log.start_marker_handle);
        delete(Heart_log.end_marker_handle);
        set(Heart_log.interval_text_handle,'String','');
        click_count=0;
    end
    if(click_count==0)
        hold on;
        click_count=1;
        start_position=mark_pt;
        Heart_log.start_marker_handle=stem(Heart_log.axes_handle,mark_pt(1,1),1.5*UT_GUI.nx,'Color',[1 0.5 0],'LineStyle',':','Marker','<');
    else
        click_count=2;
        end_position=mark_pt;
        Heart_log.end_marker_handle=stem(Heart_log.axes_handle,mark_pt(1,1),1.5*UT_GUI.nx,'Color',[1 0.5 0],'LineStyle',':','Marker','>');
        if(start_position(1)>end_position(1))
            pos=end_position(1)+(start_position(1)-end_position(1))/2;
        else
            pos=start_position(1)+(end_position(1)-start_position(1))/2;
        end
        set(Heart_log.interval_text_handle,'String',strcat(num2str(abs(start_position(1)-end_position(1))),'ms'),'Position',[pos 1.5*UT_GUI.nx]);
        hold off;
    end        
end

function upload_trigger_table(hObject,eventdata)
    global UT_GUI
    if(size(get(UT_GUI.trigger_table_handle,'Data'),1)~=UT_GUI.nx)
        errordlg('Trigger Table does not have the same number of nodes as the heart configuration','Configuration Mismatch','modal');
        return;
    end
    UT_GUI.trigger_table=get(UT_GUI.trigger_table_handle,'Data');
    for i=1:UT_GUI.nx,
        for j=1:2,
            if((round(UT_GUI.trigger_table(i,j))~=UT_GUI.trigger_table(i,j))||(UT_GUI.trigger_table(i,j)<0))
                errordlg('Invalid data found in the table','Data error','modal');
                return;
            end
            if((j==1)&&(UT_GUI.trigger_table(i,j)>2))
                errordlg('Undefined Trigger Type in the table','Data error','modal');
                return;
            end
        end
    end
    edited_trigger_table=[UT_GUI.trigger_table(:,1) zeros(UT_GUI.nx,1) UT_GUI.trigger_table(:,2)]';
    nx_string=num2str(UT_GUI.nx);
    ny_string=num2str(7);
    %commas seperate every number sent to the board
    transmit=strcat(nx_string,',',ny_string);
    for i=1:3,
        for j=1:UT_GUI.nx,
            transmit=strcat(transmit,',',num2str(edited_trigger_table(i,j)));
        end
    end
    %The character 'z' indicates end of transmission
    transmit=strcat(transmit,',z');
    UT_GUI.udp_handle = udp('192.168.90.90', 4950, 'LocalPort', 4950);
    set(UT_GUI.udp_handle,'DatagramTerminateMode','off');
    fopen(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'a');
    pause(1);
    fprintf(UT_GUI.udp_handle,'t');
    pause(1);
    flushinput(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,transmit);
    in=str2double(fscanf(UT_GUI.udp_handle));
    if(in==size(transmit))
        msgbox('Update Complete!','Success');
    else
        %msgbox('Update Failed, please try again','Error','error');
    end
    fclose(UT_GUI.udp_handle);
    clear UT_GUI.udp_handle;
end

function update_meaning(hObject,eventdata)
    edited_cell=eventdata.Indices(1,:);
    if(edited_cell(2)==1)
        if((eventdata.EditData<0)||(eventdata.EditData)>2)
            errordlg('Invalid number for this field','Wrong Entry','modal');
            
        else
            update_tooltip;
        end
    end
end

function update_tooltip
    global UT_GUI
    hint_string='';
    temp_data=get(UT_GUI.trigger_table_handle,'Data');
    for i=1:UT_GUI.nx
        if(temp_data(i,1)==0)
        temp_string=strcat('Node ',num2str(i),' is never triggered');
        else
            if(temp_data(i,1)==1)
                temp_string=strcat('Node ',num2str(i),' is triggered once');
            else
                temp_string=strcat('Node ',num2str(i),' is periodically triggered');
            end
        end
        hint_string=sprintf('%s\n%s',hint_string,temp_string);
    end
    set(UT_GUI.trigger_table_handle,'TooltipString',hint_string);
end

function load_model(hObject,eventdata)
    global UT_GUI
    [fname,path] = uigetfile('*.mat', 'Load VHM Model');
    load([path fname]);
    UT_GUI.node_table=node_table;
    UT_GUI.path_table=path_table;
    UT_GUI.trigger_table=trigger_table;
    UT_GUI.nx=size(UT_GUI.node_table,1);
    UT_GUI.px=size(UT_GUI.path_table,1);
    set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
    %set(UT_GUI.no_of_nodes_handle,'String',num2str(UT_GUI.nx));
    set(UT_GUI.path_table_handle,'Data',UT_GUI.path_table);
    %set(UT_GUI.no_of_paths_handle,'String',num2str(UT_GUI.px));
    set(UT_GUI.trigger_table_handle,'Data',UT_GUI.trigger_table);
    UT_GUI.nodes_position=node_pos;
    set(UT_GUI.node_pos,'XData',node_pos(:,1),'YData',node_pos(:,2));
    try
        delete(UT_GUI.paths_handle);
    catch
    end
    UT_GUI.paths_handle=[];
    for i=1:UT_GUI.px
        UT_GUI.paths_handle(end+1)=line([node_pos(path_table(i,2),1) node_pos(path_table(i,3),1)],[node_pos(path_table(i,2),2) node_pos(path_table(i,3),2)],'LineWidth',5);
    end
    update_status;
    update_tooltip;
end

function response=update_tables(hObject,eventdata)
    global UT_GUI
    if(config_check~=1)
        return;
    end
    UT_GUI.update_in_progress=1;
    UT_GUI.node_table=get(UT_GUI.node_table_handle,'Data');
    UT_GUI.path_table=get(UT_GUI.path_table_handle,'Data');
    %%%Check for correctness of entries first%%%
    response=0;
    if(sum(sum((round(UT_GUI.node_table)~=UT_GUI.node_table)))||sum(sum(round(UT_GUI.path_table)~=UT_GUI.path_table)))
        errordlg('decimal values found in the table(s)','Decimal values not allowed!!!','modal');
        UT_GUI.update_in_progress=0;
        return;
    end
    display_string1='Node table Entries:';
    error1=0;
    for i=1:UT_GUI.nx,
        skiplist=[];
        for j=1:7,
            if(UT_GUI.node_table(i,j)<0)
                error1=1;
                skiplist=[skiplist,j];
                display_string1=[display_string1,'(',num2str(i),',',num2str(j),')::'];
            end
        end
        if(UT_GUI.node_table(i,1)>2)
            error1=1;
            if(isempty(find(skiplist==1)))
                display_string1=[display_string1,'(',num2str(i),',1)::'];
            end
        end
        if(UT_GUI.node_table(i,3)<UT_GUI.node_table(i,2))
            error1=1;
            if(isempty(find(skiplist==2)))
                display_string1=[display_string1,'(',num2str(i),',2)::'];
            end
        end
        if(UT_GUI.node_table(i,5)<UT_GUI.node_table(i,4))
            error1=1;
            if(isempty(find(skiplist==4)))
                display_string1=[display_string1,'(',num2str(i),',4)::'];
            end
        end
        if(UT_GUI.node_table(i,6)>1)
            error1=1;
            if(isempty(find(skiplist==6)))
                display_string1=[display_string1,'(',num2str(i),',6)::'];
            end
        end
        if(UT_GUI.node_table(i,7)>1)
            error1=1;
            if(isempty(find(skiplist==7)))
                display_string1=[display_string1,'(',num2str(i),',7)::'];
            end
        end
    end
    error2=0;
    display_string2='Path table Entries:';
    for i=1:UT_GUI.px,
        skiplist=[];
        for j=1:7,
            if(UT_GUI.path_table(i,j)<=0)
                error2=1;
                skiplist=[skiplist,j];
                display_string2=[display_string2,'(',num2str(i),',',num2str(j),')::'];
            end
        end
        if(UT_GUI.path_table(i,5)<UT_GUI.path_table(i,4))
            error2=1;
            if(isempty(find(skiplist==4)))
                display_string2=[display_string2,'(',num2str(i),',4)::'];
            end
        end
        if(UT_GUI.path_table(i,7)<UT_GUI.path_table(i,6))
            error2=1;
            if(isempty(find(skiplist==6)))
                display_string2=[display_string2,'(',num2str(i),',6)::'];
            end
        end
        if(UT_GUI.path_table(i,2)>UT_GUI.nx)
            error2=1;
            if(isempty(find(skiplist==2)))
                display_string2=[display_string2,'(',num2str(i),',2)::'];
            end
        end
        if(UT_GUI.path_table(i,3)>UT_GUI.nx)
            error2=1;
            if(isempty(find(skiplist==2)))
                display_string2=[display_string2,'(',num2str(i),',3)::'];
            end
        end
    end    
    if((error2>0)&&(error1>0))
        display_string=strcat(display_string1,display_string2);
        errordlg(display_string,'Invalid Entries Found!!!','modal');
        UT_GUI.update_in_progress=0;
        return;
    else if(error1>0)
            errordlg(display_string1,'Invalid Entries Found!!!','modal');
            UT_GUI.update_in_progress=0;
            return;
        else if(error2>0)
            errordlg(display_string2,'Invalid Entries Found!!!','modal');
            UT_GUI.update_in_progress=0;
            return; 
            end
        end
    end
    %%%END of correctness checking%%%
    %%%Transmission of the updated tables to board%%%
    %the number of rows and columns in the node table is converted to string to
    %be sent to the board
    nx_string=num2str(UT_GUI.nx);
    ny_string=num2str(7);
    %commas seperate every number sent to the board
    transmit=strcat(nx_string,',',ny_string);
    for i=1:UT_GUI.nx,
        for j=1:7,
            transmit=strcat(transmit,',',num2str(UT_GUI.node_table(i,j)));
        end
    end
    %'x' seperates the node table data from the path table data
    transmit=strcat(transmit,',','x,');
    %number of rows and columns of the path table converted to string to be
    %appended to the data sent to the board
    px_string=num2str(UT_GUI.px);
    py_string=num2str(7);
    transmit=strcat(transmit,px_string,',',py_string);
    for i=1:UT_GUI.px,
        for j=1:7,
            if((j==2)||(j==3))
                %*******IMPORTANT*******%
                %The table used for matlab considers the first node to be
                %number 1 but in C, first element of the array is indexed 0,
                %hence the path source and destination nodes should be reduced
                %by 1 to make sense in C
                transmit=strcat(transmit,',',num2str(UT_GUI.path_table(i,j)-1));
            else
                transmit=strcat(transmit,',',num2str(UT_GUI.path_table(i,j)));
            end
        end
    end
    %The character 'z' indicates end of transmission
    transmit=strcat(transmit,',z');
    UT_GUI.udp_handle = udp('192.168.90.90', 4950, 'LocalPort', 4950);
    set(UT_GUI.udp_handle,'DatagramTerminateMode','off');
    fopen(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'a');
    pause(1);
    fprintf(UT_GUI.udp_handle,'u');
    pause(1);
    flushinput(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,transmit);
    in=(fscanf(UT_GUI.udp_handle));
    if(strcmp(in,[num2str(transmit) '\n']))
        msgbox('Update Complete!','Success');
    else
        %msgbox('Update Failed, please try again','Error','error');
    end
    fclose(UT_GUI.udp_handle);
    clear UT_GUI.udp_handle;
    UT_GUI.update_in_progress=0;
    response=1;
end

function response=config_check
global UT_GUI
    response=0;
    if((size(UT_GUI.node_table,1)<1)||(size(UT_GUI.node_table,2)<7)||(size(UT_GUI.path_table,1)<1)||(size(UT_GUI.path_table,2)<7)...
            ||(UT_GUI.nx<1)||(UT_GUI.px<1)||(size(UT_GUI.node_table,1)~=UT_GUI.nx)||(size(UT_GUI.path_table,1)~=UT_GUI.px))
        errordlg('Tables not loaded correctly','Check Tables','modal');
    else
        response=1;
    end
end
    

function save_model(hObject,eventdata)
    global UT_GUI
    if(config_check~=1)
        return;
    end
    [fname,path] = uiputfile('*.mat', 'Save VHM Model');
    dir=[path fname];
    node_table=get(UT_GUI.node_table_handle,'Data');
    path_table=get(UT_GUI.path_table_handle,'Data');
    node_pos(:,1)=get(UT_GUI.node_pos,'XData');
    node_pos(:,2)=get(UT_GUI.node_pos,'YData');
    trigger_table=get(UT_GUI.trigger_table_handle,'Data');
    save(dir,'node_table','path_table','node_pos','trigger_table');
end

function button_press(hObject,eventdata)
global UT_GUI
persistent press_count start_point end_point source_node dest_node
    tolerance=7;
    pt=round(get(hObject,'CurrentPoint'));
    if(UT_GUI.add_path_mode==0)
        press_count=0;
        UT_GUI.nodes_position(end+1,:)=[pt(1,1) pt(1,2)];
        set(UT_GUI.node_pos,'XData',UT_GUI.nodes_position(:,1),'YData',UT_GUI.nodes_position(:,2));
        set_node_configuration(pt(1,1:2),size(UT_GUI.nodes_position,1));
    else
        x_coordinate_match=find(abs(UT_GUI.nodes_position(:,1)-pt(1,1))<tolerance);%this value of 5 is based on the width of the marker in the scatter plot
        if(~isempty(x_coordinate_match))
            for i=1:size(x_coordinate_match)
                y_coordinate_match=find(abs(UT_GUI.nodes_position(x_coordinate_match(i),2)-pt(1,2))<tolerance);
                if(~isempty(y_coordinate_match))                   
                    if(press_count==0)
                        start_point=UT_GUI.nodes_position(x_coordinate_match(i),:);
                        set(UT_GUI.selected_node_pos,'XData',start_point(1),'YData',start_point(2));
                        source_node=x_coordinate_match(i);
                    else
                        end_point=UT_GUI.nodes_position(x_coordinate_match(i),:);
                        set(UT_GUI.selected_node_pos,'XData',[],'YData',[]);
                        UT_GUI.paths_handle(end+1)=line([start_point(1) end_point(1)],[start_point(2) end_point(2)],'LineWidth',5);
                        dest_node=x_coordinate_match(i);
                        set_path_configuration(source_node,dest_node,end_point,size(UT_GUI.paths_handle,1));
                        start_point=[];
                        end_point=[];
                        source_node=[];
                        dest_node=[];
                        press_count=-1;
                    end
                    press_count=press_count+1;
                    break;
                end
            end
        end 
    end  
end

function add_path(hObject,eventdata)
global UT_GUI
    UT_GUI.add_path_mode=mod((UT_GUI.add_path_mode+1),2);
    if(UT_GUI.add_path_mode==1)
        set(hObject,'BackgroundColor','c');
    else
        set(hObject,'BackgroundColor','w');
    end
%     set(UT_GUI.main_gui_handle,'KeyPressFcn',@get_key);
%     set(UT_GUI.main_gui_handle,'
    
end

function set_node_configuration(position,node_count)
global current_node_config
    current_node_config.figure_handle=figure('Units', 'Pixels'...
    ,'Position', [position(1) position(2) 400 100]...
    ,'Resize','on'...
    ,'Name',strcat('Node ',num2str(node_count),' Settings')...
    ,'NumberTitle','Off');
    current_node_config.node_number=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','1','Position',[30,50,100,20],'BackgroundColor','white');
    current_node_config.current_erp=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','current ERP','Position',[135,50,80,20],'BackgroundColor','white');
    current_node_config.erp=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','ERP','Position',[220,50,30,20],'BackgroundColor','white');
    current_node_config.current_rest=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','Current Rest','Position',[255,50,80,20],'BackgroundColor','white');
    current_node_config.rest=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','Rest','Position',[340,50,30,20],'BackgroundColor','white');
    uicontrol('Parent',current_node_config.figure_handle,'Style','pushbutton','Position',[120,20,80,30],'String','OK','Callback',@read_node_data);
    uicontrol('Parent',current_node_config.figure_handle,'Style','pushbutton','Position',[205,20,80,30],'String','Cancel','Callback',@remove_last_node);
end

function read_node_data(hObject,eventdata)
global current_node_config UT_GUI
    temp=[str2num(get(current_node_config.node_number,'String')) str2num(get(current_node_config.current_erp,'String')) str2num(get(current_node_config.erp,'String'))...
        str2num(get(current_node_config.current_rest,'String')) str2num(get(current_node_config.rest,'String')) 0 0];
    %set(UT_GUI.no_of_nodes_handle,'String',num2str(size(UT_GUI.node_table,1)));
    if(size(temp,2)~=7)
        errordlg('Invalid Entries for node!!!','Check values','modal');
        return;
    end
    UT_GUI.node_table(UT_GUI.nx+1,:)=temp;
    UT_GUI.nx=UT_GUI.nx+1;
    set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
    close(current_node_config.figure_handle);
    set(UT_GUI.trigger_table_handle,'Data',[get(UT_GUI.trigger_table_handle,'Data');zeros(1,2)]);
    update_status;
    update_tooltip;
end

function remove_last_node(hObject,eventdata)
global UT_GUI
    UT_GUI.nodes_position(end,:)=[];
    try
        set(UT_GUI.node_pos,'XData',UT_GUI.nodes_position(:,1),'YData',UT_GUI.nodes_position(:,2));
    catch
    end
    close(get(hObject,'Parent'));
end

function set_path_configuration(source_node,dest_node,position,path_count)
global current_path_config
    current_path_config.figure_handle=figure('Units', 'Pixels'...
    ,'Position', [position(1) position(2) 400 100]...
    ,'Resize','on'...
    ,'Name','Path Settings'...
    ,'NumberTitle','Off');
    current_path_config.path_number=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String',num2str(path_count),'Position',[20,50,25,20],'BackgroundColor','white');
    current_path_config.source_node=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String',num2str(source_node),'Position',[50,50,25,20],'BackgroundColor','white');
    current_path_config.dest_node=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String',num2str(dest_node),'Position',[80,50,25,20],'BackgroundColor','white');
    current_path_config.current_fc=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String','current FC','Position',[110,50,60,20],'BackgroundColor','white');
    current_path_config.def_fc=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String','Default FC','Position',[175,50,60,20],'BackgroundColor','white');
    current_path_config.current_bc=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String','current BC','Position',[240,50,60,20],'BackgroundColor','white');
    current_path_config.def_bc=uicontrol('Parent',current_path_config.figure_handle,'Style','edit','String','Default BC','Position',[305,50,60,20],'BackgroundColor','white');
    uicontrol('Parent',current_path_config.figure_handle,'Style','pushbutton','Position',[120,20,80,30],'String','OK','Callback',@read_path_data);
    uicontrol('Parent',current_path_config.figure_handle,'Style','pushbutton','Position',[205,20,80,30],'String','Cancel','Callback',@remove_last_path);
end

function read_path_data(hObject,eventdata)
global current_path_config UT_GUI
    temp=[str2num(get(current_path_config.path_number,'String')) str2num(get(current_path_config.source_node,'String')) str2num(get(current_path_config.dest_node,'String'))...
        str2num(get(current_path_config.current_fc,'String')) str2num(get(current_path_config.def_fc,'String')) str2num(get(current_path_config.current_bc,'String')) str2num(get(current_path_config.def_bc,'String'))];
    %set(UT_GUI.no_of_paths_handle,'String',num2str(size(UT_GUI.path_table,1)));
    if(size(temp,2)~=7)
        errordlg('Invalid Entries for Path!!!','Check values','modal');
        return;
    end
    UT_GUI.path_table(UT_GUI.px+1,:)=temp;
    UT_GUI.px=UT_GUI.px+1;
    set(UT_GUI.path_table_handle,'Data',UT_GUI.path_table);
    close(current_path_config.figure_handle);
    update_status;
end

function remove_last_path(hObject,eventdata)
global UT_GUI
    delete(UT_GUI.paths_handle(end));
    UT_GUI.paths_handle(end)=[];
    close(get(hObject,'Parent'));
end

function remove_node(hObject,eventdata)
global UT_GUI
    UT_GUI.node_table(end,:)=[];
    %set(UT_GUI.no_of_nodes_handle,'String',num2str(size(UT_GUI.node_table,1)));
    set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
    if(UT_GUI.nx>0)
        UT_GUI.nx=UT_GUI.nx-1;
        temp_data=get(UT_GUI.trigger_table_handle,'Data');
        set(UT_GUI.trigger_table_handle,'Data',temp_data(1:end-1,:));
    end
    if(size(UT_GUI.nodes_position,1)>0)
        UT_GUI.nodes_position(end,:)=[];
    end
    set(UT_GUI.node_pos,'XData',UT_GUI.nodes_position(:,1),'YData',UT_GUI.nodes_position(:,2));
    update_status;
    update_tooltip;
end

function remove_path(hObject,eventdata)
global UT_GUI
    UT_GUI.path_table(end,:)=[];
    %set(UT_GUI.no_of_paths_handle,'String',num2str(size(UT_GUI.path_table,1)));
    set(UT_GUI.path_table_handle,'Data',UT_GUI.path_table);
    if(UT_GUI.px>0)
        UT_GUI.px=UT_GUI.px-1;
    end
    try
        delete(UT_GUI.paths_handle(end));
        UT_GUI.paths_handle(end)=[];
    catch
    end
    update_status;
end

function reset_gui(hObject,eventdata)
    global UT_GUI
    try
        close_gui(UT_GUI.main_gui_handle,eventdata);
        VHM_GUI
    catch
    end
end

function close_gui(hObject,eventdata)
global UT_GUI
    try
        fclose(UT_GUI.udp_handle);
        delete(hObject);
        clear all;
        close all;
    catch
    end
end