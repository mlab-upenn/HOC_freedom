function VHM_GUI
    try
        fclose(UT_GUI.udp_handle);
        clear(UT_GUI.udp_handle);
        clear all;
        close all;
        clc;
    catch
    end
    global UT_GUI nx px ok_to_display logging_in_progress update_in_progress
    ok_to_display=0;
    logging_in_progress=0;
    update_in_progress=0;
    UT_GUI.udp_handle = udp('192.168.90.90', 4950, 'LocalPort', 4951);
    set(UT_GUI.udp_handle,'DatagramTerminateMode','off');
    set(UT_GUI.udp_handle,'OutputBufferSize',2000);
    %set(UT_GUI.udp_handle, 'ReadAsyncMode', 'manual');
    set(UT_GUI.udp_handle, 'InputBufferSize', 2000);
    fopen(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'x');
    %Do not move clear and close to anywhere but right after function
    %declaration
    nx=4;
    px=3;
    UT_GUI.node_table=zeros(nx,7);
    UT_GUI.node_table(:,1)=ones(nx,1);
    UT_GUI.node_table(:,2:5)=999*ones(nx,4);
    UT_GUI.path_table=zeros(px,7);
    UT_GUI.path_table(:,1)=ones(px,1);
    UT_GUI.path_table(:,4:7)=999*ones(px,4);   
    UT_GUI.screen_size=get(0,'ScreenSize');
    UT_GUI.paths_handle=[];
    UT_GUI.nodes_added=0;
    UT_GUI.add_path_mode=0;
    UT_GUI.main_gui_handle=figure('Units', 'normalized'...
        ,'Position', [0 0 1 1]...
        ,'Resize','on'...
        ,'Name','Test Sample'...
        ,'NumberTitle','Off'...
        ,'CloseRequestFcn',@close_gui);
    UT_GUI.axes_handle=axes('Units','normalized'...
        ,'Position',[0,0.2,0.48,0.8]...
        ,'Xlim',[0 530]...
        ,'Ylim',[0 530]...
        ,'XTick',[]...
        ,'YTick',[]...
        ,'ZTick',[]...
        ,'NextPlot','add');
    uicontrol('Style','text','String','Number of Nodes'...
        ,'Units','normalized'...
        ,'Position',[0.85 0.95 0.1 0.025]...
        ,'ForegroundColor',[0 0 0]...
        ,'BackgroundColor',[0 0.9 0]...
        ,'FontUnits','normalized'...
        ,'FontSize',0.85...
        ,'FontWeight','demi');
    uicontrol('Style','text'...
        ,'String','Number of Paths'...
        ,'Units','normalized'...
        ,'Position',[0.85 0.920 0.1 0.025]...
        ,'ForegroundColor',[0 0 0]...
        ,'BackgroundColor',[0 0.9 0]...
        ,'FontUnits','normalized'...
        ,'FontSize',0.85...
        ,'FontWeight','demi');  
    UT_GUI.show_signals_handle=uicontrol('Style','pushbutton'...
        ,'String','Show signals'...
        ,'Units','normalized'...
        ,'Position',[0.0 0.14 0.07 0.05]...
        ,'Callback',@display_signals);   
    UT_GUI.view_history_handle=uicontrol('Style','pushbutton'...
        ,'String','Show heart history'...
        ,'Units','normalized'...
        ,'Position',[0.075 0.14 0.1 0.05]...
        ,'Callback',@display_log);   
    UT_GUI.add_path_handle=uicontrol('Style','pushbutton'...
        ,'String','Add path'...
        ,'Units','normalized'...
        ,'Position',[0.18 0.14 0.07 0.05]...
        ,'Callback',@add_path);
    UT_GUI.remove_node_handle=uicontrol('Style','pushbutton'...
        ,'String','Remove Node'...
        ,'Units','normalized'...
        ,'Position',[0.255 0.14 0.07 0.05]...
        ,'Callback',@remove_node);
    UT_GUI.remove_path_handle=uicontrol('Style','pushbutton'...
        ,'String','Remove Path'...
        ,'Units','normalized'...
        ,'Position',[0.33 0.14 0.07 0.05]...
        ,'Callback',@remove_path);
    UT_GUI.reset_button_handle=uicontrol('Style','pushbutton'...
        ,'String','Reset GUI'...
        ,'Units','normalized'...
        ,'Position',[0.405 0.14 0.07 0.05]...
        ,'Callback',@reset_gui); 
    UT_GUI.no_of_nodes_handle=uicontrol('Style','edit'...
        ,'String','4'...
        ,'Units','normalized'...
        ,'Position',[0.95 0.95 0.025 0.025]...
        ,'Callback',@create_table);
    UT_GUI.no_of_paths_handle=uicontrol('Style','edit'...
        ,'String','3'...
        ,'Units','normalized'...
        ,'Position',[0.95 0.92 0.025 0.025]...
        ,'Callback',@create_table);
    UT_GUI.load_table_handle=uicontrol('Style','pushbutton'...
        ,'String','Open saved Tables'...
        ,'Units','normalized'...
        ,'Position',[0.85 0.85 0.1 0.05]...
        ,'Callback',@load_saved_tables);  
    UT_GUI.updata_table_handle=uicontrol('Style','pushbutton'...
        ,'String','Update Tables'...
        ,'Units','normalized'...
        ,'Position',[0.85 0.79 0.1 0.05]...
        ,'Callback',@update_tables);
    UT_GUI.save_table_handle=uicontrol('Style','pushbutton'...
        ,'String','Save Tables'...
        ,'Units','normalized'...
        ,'Position',[0.85 0.73 0.1 0.05]...
        ,'Callback',@save_tables);    
    UT_GUI.node_table_handle = uitable('Units','normalized'...
        ,'Position',[0.5 0.525 0.35 0.475]...
        ,'Data',UT_GUI.node_table...
        ,'ColumnWidth','auto'...
        ,'ColumnEditable',[true true true true true true true true]...
        ,'ColumnName',{'Node State','Current ERP','ERP','Current Rest','Rest','Node activation status','path status'}...
        ,'CellEditCallback',@verify_table_data);
    UT_GUI.path_table_handle = uitable('Units','normalized'...
        ,'Position',[0.5 0.05 0.35 0.475]...
        ,'Data',UT_GUI.path_table...
        ,'ColumnWidth','auto'...
        ,'ColumnEditable',[true true true true true true true true]...
        ,'ColumnName',{'Path State','Source Node','Destination Node','current FC','Default FC','Current BC','Default BC'}...
        ,'CellEditCallback',@verify_table_data);
    UT_GUI.im=imread('heart.jpg');
    UT_GUI.im=image(UT_GUI.im);
    UT_GUI.nodes_position=[];
    UT_GUI.node_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r','HitTest','off');%,'ButtonDownFcn',@button_press);
    UT_GUI.selected_pos=scatter([],[],'LineWidth',5,'Marker','o','MarkerEdgeColor','g','MarkerFaceColor','g');
    set(UT_GUI.im,'HitTest','off');
    set(UT_GUI.axes_handle,'ButtonDownFcn',@button_press);
end

function display_signals(hObject,eventdata)
    global ok_to_display UT_GUI nx px
    set(hObject,'String','Display in progress...');
    data=fscanf(UT_GUI.udp_handle);
    udp_table_display_helper(0,data,nx,px);
    ok_to_display=1;
    while(ok_to_display==1)
        data=fscanf(UT_GUI.udp_handle);
        udp_table_display_helper(1,data,nx,px);
    end
    ok_to_display=0;
    set(hObject,'String','Show signals');
end

function display_log(hObject,eventdata)
    global nx px UT_GUI ok_to_display logging_in_progress update_in_progress;
    global node_activation_status nodes_states path_states start_time;
    global duration current_range x_range xlimits;
    global Heart_log;
    logging_in_progress=1;
    if((ok_to_display==1)||(update_in_progress==1))
        errordlg('Close other Windows before continuing','Multiple windows open!','modal');
        logging_in_progress=0;
        return;
    end
    set(hObject,'String','Gathering data...');
    fprintf(UT_GUI.udp_handle,'l');
    pause(1);
    flushinput(UT_GUI.udp_handle);
    fscanf(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,'ok');
    data=fscanf(UT_GUI.udp_handle);
    Log_plot_helper(0,data,nx,px);
    while(1)
      fprintf(UT_GUI.udp_handle,'ok');%send acknowledgement for every datagram received, without this, heart won't continue sending data
      data=fscanf(UT_GUI.udp_handle);
      if(~isempty(find(data=='e',1)))
          break;
      end
      Log_plot_helper(1,data,nx,px);
    end
    duration=size(node_activation_status,1);
    duration_int=floor(duration);
    Heart_log.figure_handle=figure('Units', 'normalized'...
        ,'Position', [0 0 1 1]...
        ,'Resize','on'...
        ,'Name','Test Sample'...
        ,'NumberTitle','Off');
    Heart_log.axes_handle=axes('Units','normalized'...
        ,'Parent',Heart_log.figure_handle...
        ,'YTick',[]...
        ,'Position',[0.1 0.2 0.8 0.75]);
    uicontrol('Style','text','String','0s'...
        ,'Units','normalized'...
        ,'Position',[0.1 0.125 0.05 0.025]);
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
        ,'Position',[0.85 0.15 0.05 0.025]);
    x_range=(1:1000)';
    color_string='ymcrgb';
    hold on;
    for i=1:nx
        current_range(:,i)=node_activation_status(1:1000,i)+1.5*(i-1);
        Heart_log.plot_handle(i)=plot(current_range(:,i));
        colorcode=color_string(mod(i,6)+1);
        set(Heart_log.plot_handle(i),'XDataSource','x_range','Color',colorcode);
        set(Heart_log.plot_handle(i),'YDataSource','current_range(:,i)');
    end
    hold off;
    set(Heart_log.axes_handle,'YTickLabel',[]);
    set(Heart_log.axes_handle,'box','off');
    ylim([0 1.5*nx]);
    set(hObject,'String','Show heart history');
    logging_in_progress=0;
end

function replot(hObject,eventdata)
    global Heart_log node_activation_status current_range nx x_range xlimits
    lower_limit=uint64(get(Heart_log.slider2_handle,'Value'));
    higher_limit=uint64(get(Heart_log.slider1_handle,'Value'));
    if(lower_limit>higher_limit)
        temp=lower_limit;
        lower_limit=higher_limit;
        higher_limit=temp;
    end
    x_range=(lower_limit:higher_limit)';
    current_range=zeros(higher_limit-lower_limit+1,nx);
    %sum(current_range)
    for i=1:nx
        current_range(:,i)=node_activation_status(lower_limit:higher_limit,i)+1.5*(i-1);
        refreshdata(Heart_log.plot_handle(i),'caller');
    end
end

function verify_table_data(hObject,eventdata)
    global UT_GUI
    edited_row=eventdata.Indices(1);
    edited_column=eventdata.Indices(2);
    switch hObject
        case UT_GUI.node_table_handle
            switch edited_column
                case 1
                    if((eventdata.NewData>2)||(eventdata.NewData<1))
                        errordlg('Invalid data for this column','Invalid Entry','modal');
                        UT_GUI.node_table=get(hObject,'Data');
                        UT_GUI.node_table(edited_row,edited_column)=1;
                        set(hObject,'Data',UT_GUI.node_table);
                    end
                case {6,7}
                    if((eventdata.NewData>1)||(eventdata.NewData<0))
                        errordlg('Invalid data for this column','Invalid Entry','modal');
                        UT_GUI.node_table=get(hObject,'Data');
                        UT_GUI.node_table(edited_row,edited_column)=0;
                        set(hObject,'Data',UT_GUI.node_table);
                    end
            end
        case UT_GUI.path_table_handle
            switch edited_column
                case 1
                    if((eventdata.NewData>3)||(eventdata.NewData<1))
                        errordlg('Invalid data for this column','Invalid Entry','modal');
                        UT_GUI.path_table=get(hObject,'Data');
                        UT_GUI.path_table(edited_row,edited_column)=1;
                        set(hObject,'Data',UT_GUI.path_table);
                    end
                case {2,3}
                    if((eventdata.NewData>nx)||(eventdata.NewData<1))
                        errordlg('Invalid data for this column','Invalid Entry','modal');
                        UT_GUI.path_table=get(hObject,'Data');
                        UT_GUI.path_table(edited_row,edited_column)=0;
                        set(hObject,'Data',UT_GUI.path_table);
                    end
            end
    end
end

function create_table(hObject, eventdata, handles)
    global UT_GUI nx px
    switch hObject
        case UT_GUI.no_of_nodes_handle
            nx=str2double(get(hObject,'string'));
            UT_GUI.node_table=zeros(nx,7);
            UT_GUI.node_table(:,1)=ones(nx,1);
            UT_GUI.node_table(:,2:5)=999*ones(nx,4);
            set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
        case UT_GUI.no_of_paths_handle
            px=str2double(get(hObject,'string'));
            UT_GUI.path_table=zeros(px,7);
            UT_GUI.path_table(:,1)=ones(px,1);
            UT_GUI.path_table(:,4:7)=999*ones(px,4);
            set(UT_GUI.path_table_handle,'Data',UT_GUI.path_table);
    end
end

function load_saved_tables(hObject,eventdata)
    global UT_GUI nx px
    [fname,path] = uigetfile('*.mat', 'Load VHM Model');
    load([path fname]);
    UT_GUI.node_table=node_table;
    UT_GUI.path_table=path_table;
    nx=size(UT_GUI.node_table,1);
    px=size(UT_GUI.path_table,1);
    set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
    set(UT_GUI.no_of_nodes_handle,'String',num2str(nx));
    set(UT_GUI.path_table_handle,'Data',UT_GUI.path_table);
    set(UT_GUI.no_of_paths_handle,'String',num2str(px));    
end

function update_tables(hObject,eventdata)
    global UT_GUI nx px update_in_progress
    update_in_progress=1;
    UT_GUI.node_table=get(UT_GUI.node_table_handle,'Data');
    UT_GUI.path_table=get(UT_GUI.path_table_handle,'Data');
    set(hObject,'String','Checking...');
    %%%Check for correctness of entries first%%%
    if(sum(sum((round(UT_GUI.node_table)~=UT_GUI.node_table)))||sum(sum(round(UT_GUI.path_table)~=UT_GUI.path_table)))
        errordlg('decimal values found in the table(s)','Decimal values not allowed!!!','modal');
        set(hObject,'String','Update Tables');
        update_in_progress=0;
        return;
    end
    display_string1='Node table Entries:';
    error1=0;
    for i=1:nx,
        skiplist=[];
        for j=1:7,
            if(UT_GUI.node_table(i,j)<0)
                error1=1;
                skiplist=[skiplist,j];
                display_string1=[display_string1,'(',num2str(i),',',num2str(j),')::'];
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
    end
    error2=0;
    display_string2='Path table Entries:';
    for i=1:px,
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
        if(UT_GUI.path_table(i,2)>nx)
            error2=1;
            if(isempty(find(skiplist==2)))
                display_string2=[display_string2,'(',num2str(i),',2)::'];
            end
        end
        if(UT_GUI.path_table(i,3)>nx)
            error2=1;
            if(isempty(find(skiplist==2)))
                display_string2=[display_string2,'(',num2str(i),',3)::'];
            end
        end
    end    
    if((error2>0)&&(error1>0))
        display_string=strcat(display_string1,display_string2);
        h=errordlg(display_string,'Invalid Entries Found!!!','modal');
        set(hObject,'String','Update Tables');
        update_in_progress=0;
        return;
    else if(error1>0)
            h=errordlg(display_string1,'Invalid Entries Found!!!','modal');
            set(hObject,'String','Update Tables');
            update_in_progress=0;
            return;
        else if(error2>0)
            h=errordlg(display_string2,'Invalid Entries Found!!!','modal');
            set(hObject,'String','Update Tables');
            update_in_progress=0;
            return; 
            end
        end
    end
    %%%END of correctness checking%%%
    set(hObject,'String','Updating...');
    %%%Transmission of the updated tables to board%%%
    %the number of rows and columns in the node table is converted to string to
    %be sent to the board
    nx_string=num2str(nx);
    ny_string=num2str(7);
    %commas seperate every number sent to the board
    transmit=strcat(nx_string,',',ny_string);
    for i=1:nx,
        for j=1:7,
            transmit=strcat(transmit,',',num2str(UT_GUI.node_table(i,j)));
        end
    end
    %'x' seperates the node table data from the path table data
    transmit=strcat(transmit,',','x,');
    %number of rows and columns of the path table converted to string to be
    %appended to the data sent to the board
    px_string=num2str(px);
    py_string=num2str(7);
    transmit=strcat(transmit,px_string,',',py_string);
    for i=1:px,
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
    pause(1);
    fprintf(UT_GUI.udp_handle,'u');
    pause(1);
    flushinput(UT_GUI.udp_handle);
    fprintf(UT_GUI.udp_handle,transmit);
    in=(fscanf(UT_GUI.udp_handle));
    in(1:(end-1))
    if(length(transmit)==str2double(in(1:(end-1))))
        msgbox('Update Complete!','Success');
    else
        msgbox('Update Failed, please try again','Error','error');
    end
    update_in_progress=0;
    set(hObject,'String','Update Tables');
end

function save_tables(hObject,eventdata)
    global UT_GUI
    [fname,path] = uiputfile('*.mat', 'Save VHM Model');
    dir=[path fname];
    node_table=get(UT_GUI.node_table_handle,'Data');
    path_table=get(UT_GUI.path_table_handle,'Data');
    save(dir,'node_table','path_table');
end

function button_press(hObject,eventdata)
global UT_GUI
persistent press_count start_point end_point
    if(UT_GUI.nodes_added==0)
        UT_GUI.node_table=[];
        UT_GUI.path_table=[];
    end
    tolerance=7;
    pt=round(get(hObject,'CurrentPoint'));
    if(UT_GUI.add_path_mode==0)
        press_count=0;
        UT_GUI.nodes_position(end+1,:)=[pt(1,1) pt(1,2)];
        UT_GUI.nodes_added=UT_GUI.nodes_added+1;
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
                        set(UT_GUI.selected_pos,'XData',start_point(1),'YData',start_point(2));
                    else
                        end_point=UT_GUI.nodes_position(x_coordinate_match(i),:);
                        set(UT_GUI.selected_pos,'XData',[],'YData',[]);
                        UT_GUI.paths_handle(end+1)=line([start_point(1) end_point(1)],[start_point(2) end_point(2)],'MarkerSize',5);
                        set_path_configuration(end_point,size(UT_GUI.paths_handle,1));
                        start_point=[];
                        end_point=[];
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
        set(hObject,'ForegroundColor','r');
    else
        set(hObject,'ForegroundColor','k');
    end
%     set(UT_GUI.main_gui_handle,'KeyPressFcn',@get_key);
%     set(UT_GUI.main_gui_handle,'
    
end

function set_node_configuration(position,node_count)
global current_node_config
    current_node_config.figure_handle=figure('Units', 'Pixels'...
    ,'Position', [position(1) position(2) 400 100]...
    ,'Resize','on'...
    ,'Name','Node Settings'...
    ,'NumberTitle','Off');
    current_node_config.node_number=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String',num2str(node_count),'Position',[30,50,100,20],'BackgroundColor','white');
    current_node_config.current_erp=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','current ERP','Position',[135,50,80,20],'BackgroundColor','white');
    current_node_config.erp=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','ERP','Position',[220,50,30,20],'BackgroundColor','white');
    current_node_config.current_rest=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','Current Rest','Position',[255,50,80,20],'BackgroundColor','white');
    current_node_config.rest=uicontrol('Parent',current_node_config.figure_handle,'Style','edit','String','Rest','Position',[340,50,30,20],'BackgroundColor','white');
    uicontrol('Parent',current_node_config.figure_handle,'Style','pushbutton','Position',[120,20,80,30],'String','OK','Callback',@read_user_data);
    uicontrol('Parent',current_node_config.figure_handle,'Style','pushbutton','Position',[205,20,80,30],'String','Cancel','Callback',@remove_last_entry);
end

function read_user_data(hObject,eventdata)
global current_node_config UT_GUI
    UT_GUI.node_table(end+1,:)=[str2num(get(current_node_config.node_number,'String')) str2num(get(current_node_config.current_erp,'String')) str2num(get(current_node_config.erp,'String'))...
        str2num(get(current_node_config.current_rest,'String')) str2num(get(current_node_config.rest,'String')) 0 0];
    set(UT_GUI.no_of_nodes_handle,'String',num2str(size(UT_GUI.node_table,1)));
    set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
    close(current_node_config.figure_handle);
end

function remove_last_entry(hObject,eventdata)
global UT_GUI
    UT_GUI.nodes_added=UT_GUI.nodes_added-1;
    UT_GUI.nodes_position(end,:)=[];
    try
        set(UT_GUI.node_pos,'XData',UT_GUI.nodes_position(:,1),'YData',UT_GUI.nodes_position(:,2));
    catch
    end
    close(get(hObject,'Parent'));
end
function set_path_configuration(position,path_count)
end
function remove_node(hObject,eventdata)
global UT_GUI
    UT_GUI.node_table(end,:)=[];
    set(UT_GUI.no_of_nodes_handle,'String',num2str(size(UT_GUI.node_table,1)));
    set(UT_GUI.node_table_handle,'Data',UT_GUI.node_table);
    if(size(UT_GUI.nodes_position,1)>0)
        UT_GUI.nodes_position(end,:)=[];
    end
    set(UT_GUI.node_pos,'XData',UT_GUI.nodes_position(:,1),'YData',UT_GUI.nodes_position(:,2));
end

function remove_path(hObject,eventdata)
global UT_GUI
    try
        delete(UT_GUI.paths_handle(end));
        UT_GUI.paths_handle(end)=[];
    catch
    end
end

function reset_gui(hObject,eventdata)
    global UT_GUI
    close_gui(UT_GUI.main_gui_handle,eventdata);
    VHM_GUI;
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

function [bottom,height]=position_adjust(rows)
    bottom=(0.975-0.045*rows);
    height=0.045*rows;
    if((bottom<0.075)||(height>0.90))
        bottom=0.075;
        height=0.9;
    else if(height<0.1)
            height=0.1;
            bottom=0.875;
        end
    end
end


function outHtml = colText(inText, inColor)
% return a HTML string with colored font
outHtml = ['<html><font color="', ...
      inColor, ...
      '">', ...
      inText, ...
      '</font></html>'];
end