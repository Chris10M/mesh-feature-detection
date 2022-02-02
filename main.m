function main
    clc;
    % basic interface for manipulating control polygons and curves
    % you need to call
    
    % create a new figure 
    % figure('Name','Fun with Curves','NumberTitle','off','color','white')
    
    mesh_file = 'samplemeshes\sphere_dense.off';

    [vertices, faces] = loadmesh(mesh_file);
    vertices = vertices.';
    faces = faces.';

    [A_mixed, mean_curvature_normal_operator] = calc_A_mixed(vertices, faces);

    K_H = get_mean_curvature(mean_curvature_normal_operator);
    K_G = get_gaussian_curvature(vertices, faces, A_mixed);

    disp(size(K_G));
    
    % [K_1, K_2 ]= get_principal_curvatures(K_H, K_G);

    options.face_vertex_color = K_G;
    plotmesh(vertices, faces, options);

%    options.face_vertex_color = 


    %% define variables used and store them in handle 
    % myhandles=[];
    
    %-------------------User Variables--------------------%
    % File containing the original noisy data
    % myhandles.file_path = 'ExampleData/CamelHeadSilhouette.txt';
    % myhandles.file_path = 'ExampleData/MaxPlanckSilhouette.txt';
    % myhandles.file_path = 'ExampleData/SineRandom.txt';
    
    % Number of control points to be loaded from file
    % myhandles.default_num_control_pts = 34; %can be changed
    % Number of samples in the resulting curve
    % myhandles.num_samples = 500;
    % myhandles.normalize_curvature = false;
    % %-----------------------------------------------------%
    
    % %System variables
    % myhandles.num_control_pts = myhandles.default_num_control_pts;
    % myhandles.tsampling=linspace(0,1,myhandles.num_samples)';% number of parameter values used for drawing the curves 
    % myhandles.controlPts=zeros(0,2);
    % myhandles.control_polygon=0;
    % myhandles.curve=0;
    % myhandles.originalCurve=0;
    % myhandles.dragStyle=0;
    % myhandles.dragedControPoint=0;
    % myhandles.axis=0;
    % myhandles.checked=0;
    % myhandles.intermediate_plot = 0;
    % myhandles.control_pts_input = 0;
    
    % %% design a basic  interface
    % % seup axis with a grid layout for drawing 
    % hax = gca; %get handle of current axes
    % set(hax,'Unit','normalized','Position',[0 0 1 1]); % make axis fill figure
    % axis manual; % disable automatic resizing of axis
    % grid on 
    % grid minor; % draw a fine grid 
    
    % hold on; % keep waiting for more input in the figure
    
    % myhandles.axis=hax;
    % %guidata(gcf,myhandles) 
    
    
    % % Imput: request for num control points
    % myhandles.control_pts_input = uicontrol('Units','normalized', ...
    %   'BackgroundColor',get(gcf,'Color'), ...
    %     'position',[.31 .05 .34 .05],...
    %   'Callback',@imput_number_callback,...
    %   'Style','edit');
    
    % % Text for displaying hte value of the num control on the figure
    % myhandles.control_pts_input_text=uicontrol('Units','normalized', ...
    %   'HorizontalAlignment','center', ...
    %   'Position',[.31 .12 .34 .05],...
    %   'String',sprintf('Current number of control points: %i',myhandles.num_control_pts), ...
    %   'Style','text');
    
    % % listbox for path
    % myhandles.path_selector = uicontrol('Units','normalized', ...
    %   'BackgroundColor',get(gcf,'Color'), ...
    %     'position',[.65 .05 .19 .05],...
    %     'string', {'Sine','Max Planck','Camel Head'},...
    %   'Callback',@path_select_callback,...
    %   'Style','popupmenu');
    
    % %CHECKBOX , when checked the slider for drawing de intermediate steps of
    % %the algorithm at time t given by the slider
    % checkboxTag = sprintf('Show Curvature');
    % myhandles.t_slider_chekbox=uicontrol('Units','normalized', ...
    %   'BackgroundColor','white', ...
    %   'HorizontalAlignment','center', ...
    %   'Position',[.27 .055 .04 .04],...
    %     'TooltipString',checkboxTag,... 
    %   'Style','checkbox','Callback',@checkbox_Callback);
    
    % %checkbox text
    % uicontrol('Units','normalized', ...
    %   'HorizontalAlignment','center', ...
    %     'BackgroundColor','white', ...
    %   'Position',[.17 .032 .1 .08],...
    %   'String','Show curve details', ...
    %   'Style','text');
    
    % % help text 
    % uicontrol('Units','normalized', ...
    %   'BackgroundColor','white', ...
    %     'ForegroundColor',[.94,.5,.94],...
    %   'HorizontalAlignment','center', ...
    %   'FontWeight','bold', ...
    %   'Position',[.15,.0,.7,.03],...
    %   'String','mouse button left=drags, right=Adds, middle = removes, control points', ...
    %   'Style','text');
    
    % % reset clear the screen and re-initialize data
    % uicontrol('Units','normalized', ...
    %   'BackgroundColor','white', ...
    %     'ForegroundColor','red',...
    %   'String','Reset', ...
    %   'Position',[.9,.0,.1,.04], ...
    %   'Callback',@reset,...
    %   'Style','pushbutton');
    
    % %save myhandle using guidata 
    
    % guidata(gcf,myhandles) 
    
    
    % %d%efine Mouse callbacks
    % set(gcf,'WindowButtonDownFcn',@mousePress);
    % set(gcf,'WindowButtonMotionFcn',@mouseDrag);
    % set(gcf,'WindowButtonUpFcn',@mouseRelease);
    
    
    
    
    % %%% Callback Functions %%%
    
    
    % %imput number callback
    % function imput_number_callback(varargin) 
    % myhandles = guidata(gcbo);
    
    % %% Read value
    % val = myhandles.control_pts_input.String;
    % myhandles.num_control_pts = str2double(val);
    % if isnan(myhandles.num_control_pts)
    %     myhandles.num_control_pts = myhandles.default_num_control_pts; %default to 30
    %     set(myhandles.control_pts_input,'String',num2str(myhandles.default_num_control_pts)); 
    % end
    
    % %% reset plot
    % guidata(gcbo,myhandles) 
    % reset;
    
    
    
    % function path_select_callback(src,event)
    % myhandles = guidata(gcbo);
    % val = myhandles.path_selector.Value;
    
    % if val == 2
    %     myhandles.file_path = 'ExampleData/MaxPlanckSilhouette.txt';
    % elseif val == 3
    %     myhandles.file_path = 'ExampleData/CamelHeadSilhouette.txt';
    % else
    %     myhandles.file_path = 'ExampleData/SineRandom.txt';
    % end
    
    % %% reset plot
    % guidata(gcbo,myhandles) 
    % reset;
    
    
    % % Reset button callback
    % function reset(varargin) 
    % %global myhandles;
    % myhandles = guidata(gcbo);
    
    % myhandles.controlPts=zeros(0,2);
    % myhandles.dragStyle=0;
    % myhandles.dragedControPoint=0;
    
    % set(myhandles.t_slider_chekbox,'Value', get(myhandles.t_slider_chekbox,'Min'))
    
    % %deletes curve from figure
    % if myhandles.curve~=0
    %     delete(myhandles.curve)
    %     myhandles.curve=0;
    % end
    
    % %deletes control polygon from figure
    % if myhandles.control_polygon~=0
    %     delete(myhandles.control_polygon)
    %     myhandles.control_polygon=0;
    % end
    
    % %deletes original polygon from figure
    % if myhandles.originalCurve~=0
    %     delete(myhandles.originalCurve)
    %     myhandles.originalCurve=0;
    % end
    
    
    % guidata(gcbo,myhandles)
    
    % updatePlot;
    % %%
    
    % %checkbox callback
    % function checkbox_Callback(hObject, eventdata, handles)
    % % hObject    handle to checkbox1 (see GCBO)
    % % eventdata  reserved - to be defined in a future version of MATLAB
    % % handles    structure with handles and user data (see GUIDATA)
    
    % % Hint: get(hObject,'Value') returns toggle state of checkbox1
    
    % myhandles = guidata(gcbo);
    % if (get(hObject,'Value') == get(hObject,'Max'))
    %     myhandles.checked=1;
    % else
    %     myhandles.checked=0;
    % end
    % guidata(gcbo,myhandles) 
    % updatePlot;
    
    
    % %%=======================================================================%%
    % %%                            Mouse actions                              %%
    % %%=======================================================================%%
    
    
    % %% Mouse button pressed
    % function mousePress(varargin)
    
    % % get the variables stored in handles
    % myhandles = guidata(gcbo);
    % closeEnough=.02;
    
    % %decide action based on which mouse button is pressed
    % %case 1
    % if strcmp(get(gcf,'SelectionType'),'alt') % right button: new control point being added 
    %   currentpos=get(myhandles.axis,'CurrentPoint'); %get the location of the current mouse position
    %   currentpos=currentpos(1,1:2);   % keep only what we need (see matlab help for currentpoint under figure properties)
    %   if min(currentpos) >= 0 & max(currentpos) <=1  % within the axis
    %     minVec = (currentpos(1)-myhandles.controlPts(:,1)).^2+(currentpos(2)-myhandles.controlPts(:,2)).^2;
    %     [mindist,minindx]=min(minVec);
    %     if mindist < 0.05 % only update when the the user clicks near control points
    %         if minindx == size(myhandles.controlPts,1) %append at the end     
    %             myhandles.controlPts(end+1,:)=currentpos;% append to the tail of the array
    %             n=size(myhandles.controlPts,1);
    %             myhandles.dragStyle=1;
    %             myhandles.dragedControPoint=n;
    %         elseif minindx == 1 %append at the beginning
    %             myhandles.controlPts = [currentpos; myhandles.controlPts];% append to begining
    %             myhandles.dragStyle=1;
    %             myhandles.dragedControPoint=1;
    %         else % it is between two points
    %             %search for the closest neighbour
    %             if minVec(minindx-1) < minVec(minindx-1)
    %                 minindx2 = minindx-1;
    %             else
    %                 minindx2 = minindx+1;
    %             end
    %             if minindx2 < minindx %append before
    %                 myhandles.controlPts = [myhandles.controlPts(1:minindx2,:); currentpos; myhandles.controlPts(minindx2+1:end,:)];
    %                 myhandles.dragStyle=1;
    %                 myhandles.dragedControPoint=minindx;                
    %             else %append after
    %                 myhandles.controlPts = [myhandles.controlPts(1:minindx,:); currentpos; myhandles.controlPts(minindx+1:end,:)];
    %                 myhandles.dragStyle=1;
    %                 myhandles.dragedControPoint=minindx2;                
    %             end
    %             guidata(gcbo,myhandles) %update data in handles 
    %         end
    %     end
    %   end
    % end
    
    % % case 2
    % if strcmp(get(gcf,'SelectionType'),'normal') % left button: control point being dragged
    %   currentpos=get(myhandles.axis,'CurrentPoint');
    %   currentpos=currentpos(1,1:2);  
    %   if min(currentpos) >= 0 && max(currentpos) <=1 % within the axis
    %     % get closest control point to the current mous position
    %     [mindist,minindx]=min((currentpos(1)-myhandles.controlPts(:,1)).^2+(currentpos(2)-myhandles.controlPts(:,2)).^2);
    %     if mindist < closeEnough % only update when the the user clicks near control points
    %       myhandles.dragStyle=1; 
    %       myhandles.dragedControPoint=minindx;
    %       myhandles.controlPts(minindx,:)=currentpos;
          
    %       guidata(gcbo,myhandles)       % update data in handles
    %     end
    %   end
    % end
    
    % % case 3
    % if strcmp(get(gcf,'SelectionType'),'extend') % middle button: clocked point being deleted 
    %   currentpos=get(myhandles.axis,'CurrentPoint');
    %   currentpos=currentpos(1,1:2);  
    %   if min(currentpos) >= 0 && max(currentpos) <=1 % within the axis
    %     % get closest control point to the current mous position
    %     [mindist,minindx]=min((currentpos(1)-myhandles.controlPts(:,1)).^2+(currentpos(2)-myhandles.controlPts(:,2)).^2);
    %     if mindist < closeEnough 
    %       myhandles.controlPts(minindx,:)=[];
          
    %       guidata(gcbo,myhandles)  % update data in handles      
    %     end
    %   end
    % end
    % %% update the plot in the figure based on handles updates from the cases above
    % updatePlot;
    
    
    
    % % Mouse button released
    % function mouseRelease(varargin)
    % %global myhandles;
    % myhandles = guidata(gcbo);
    
    % myhandles.dragStyle=0;
    % myhandles.dragedControPoint=0;
    % guidata(gcbo,myhandles) 
    
    % % Mouse being moved (after clicking)
    % function mouseDrag(varargin)
    % %global myhandles;
    % myhandles = guidata(gcbo);
    
    % if myhandles.dragStyle
    %   p=get(myhandles.axis,'CurrentPoint');
    %   p=p(1,1:2);
    %   if min(p) >= 0 & max(p) <=1 
    %     myhandles.controlPts(myhandles.dragedControPoint,:)=p;
    %     guidata(gcbo,myhandles) 
    
    %     updatePlot;
    %   end 
    % end 
    
    
    % %%=======================================================================%%
    % %%                             update plot                               %%
    % %%=======================================================================%%
      
    % %%% Internal Functions %%%
    % function updatePlot
    % %global myhandles;
    % myhandles = guidata(gcbo);
    
    % ncp=size(myhandles.controlPts,1);%number of control points
    
    % %decide when to draw/update the control polygon and the curve
    % if ncp<=1
    %     % if no point exists, we load the poligon 
    %     [ogpoints, outPoints]= load_file(myhandles.file_path, myhandles.num_control_pts-1);
    %     myhandles.originalCurve = plot(ogpoints(:,1),ogpoints(:,2),'color',[.4,.4,.4],'Linewidth',1.5);
    %     myhandles.controlPts = outPoints;
        
    %     ncp=size(myhandles.controlPts,1); %new number of points
    %     myhandles.num_control_pts = ncp; %if the input was incorrect, this has to be updated
    % end
    
    % if ncp>0
        
    %   %Calculates the curve (and maybe control polygon)
    %   mycurve = spline2d(myhandles.controlPts, myhandles.num_samples);
      
    %   % draw polygon
    %   if myhandles.control_polygon==0 %draw polygon for the first time
    %     myhandles.control_polygon=plot(myhandles.controlPts(3:end,1),myhandles.controlPts(3:end,2),'o',...
    %         'color',[.4,.4,.8],...
    %         'LineWidth',0.5,...
    %     'MarkerSize',12,...
    %     'MarkerEdgeColor','green',...
    %     'MarkerFaceColor',[0.5,0.5,0.75]);
    %   else
    %     set(myhandles.control_polygon,'Xdata',myhandles.controlPts(3:end,1));
    %     set(myhandles.control_polygon,'Ydata',myhandles.controlPts(3:end,2));
    %   end
    
    %   if myhandles.curve==0 %draw curve for the first time  
    %     myhandles.curve=plot(mycurve(:,1),mycurve(:,2),'color',[25/255, 150/255, 1],'Linewidth',2);
    %   else %update curve
    %     set(myhandles.curve,'Xdata',mycurve(:,1));
    %     set(myhandles.curve,'Ydata',mycurve(:,2));
    %   end
      
    %   % If checkbox checked
    %   n= size(myhandles.tsampling, 1);
    %   if myhandles.checked
    %     % Set colour according to curvature
    %     curvature = compute_curvature(mycurve, myhandles.tsampling);
    %     if myhandles.normalize_curvature
    %         curvature_normalized = 2*curvature/(max(curvature-min(curvature))); %between -1 and 1
    %     else
    %         curvature_normalized = curvature; %not normalize
    %     end
            
    %     r = 255 - uint8(-curvature_normalized*255);
    %     g = 255 - (uint8(-curvature_normalized*255) + uint8(curvature_normalized*255));
    %     b = 255 - uint8(curvature_normalized*255);
    %     cd = [r g b zeros(n,1)]';
    %     set(myhandles.control_polygon,'LineStyle',"-");
    %   else
    %     cd = uint8([25*ones(n,1) 150*ones(n,1) 255*ones(n,1) zeros(n,1)]');
    %     set(myhandles.control_polygon,'LineStyle',"none");
    %   end
    %   set(myhandles.curve.Edge, 'ColorBinding','interpolated', 'ColorData',cd)
    % end
    
    % %% special cases for deleting points
    % if ncp<2
    %     if myhandles.curve~=0
    %         delete(myhandles.curve)
    %         myhandles.curve=0;
    %     end
    % end
    
    % if ncp<1
    %     if myhandles.control_polygon~=0
    %         delete(myhandles.control_polygon)
    %         myhandles.control_polygon=0;
    %     end
    % end
    
    % % display current num points value in the text box
    % set(myhandles.control_pts_input_text,'String',sprintf('Current number of control points: %i',size(myhandles.controlPts,1))); 
    
    % %update the handles data
    % guidata(gcbo,myhandles) 
    
     