%global handles;

windowSize = [1200 400];

input_directory = '../output/refs/';

handles.linewidth = 1;
handles.scale = 100;
handles.movmean_window1 = 100;
handles.movmean_window2 = 500;
handles.nb_values = 500;

% import data
listing = dir(input_directory);
listing(1:2)=[];
is_dir = zeros(numel(listing),1);
for i = 1:numel(listing)
    is_dir(i) = listing(i).isdir;
end

listing = listing(is_dir==0);

T = readtable([input_directory listing(1).name],'ReadVariableNames',true,'VariableNamingRule','preserve');
nb_steps = size(T,1)-1;

data.fish_stock = zeros(numel(listing),nb_steps);
data.capture = zeros(numel(listing),nb_steps);
data.income = zeros(numel(listing),nb_steps);
data.nb_trawlers = zeros(numel(listing),1);
data.price = zeros(numel(listing),nb_steps);
data.maintenance = zeros(numel(listing),nb_steps);

for i=1:numel(listing) 
    filename = listing(i).name;
    T = readtable([input_directory filename],'ReadVariableNames',true,'VariableNamingRule','preserve');
    T(1,:)=[];
    data.nb_trawlers(i) = T{1,'nb_trawlers'};
    data.fish_stock(i,:) = table2array(T(:,'fish_stock'))';
    data.capture(i,:) = movmean(table2array(T(:,'capture'))',handles.movmean_window2);
    data.income(i,:) = movmean(table2array(T(:,'income'))',handles.movmean_window2);
    data.price(i,:) = table2array(T(:,'price'))';
    data.maintenance(i,:) = table2array(T(:,'fleet_maintenance_cost'))';
end

[data.nb_trawlers, index_sort_by_fleet_size] = sort(data.nb_trawlers);
%data.name = data.name(index_sort_by_fleet_size);
data.fish_stock = data.fish_stock(index_sort_by_fleet_size,:);
data.capture = data.capture(index_sort_by_fleet_size,:);
data.income = data.income(index_sort_by_fleet_size,:);
data.price = data.price(index_sort_by_fleet_size,:);
data.maintenance = data.maintenance(index_sort_by_fleet_size,:);
for i = 1: numel(listing)
    data.name{i} = ['Scn. ', num2str(i), ' (', num2str(data.nb_trawlers(i)), ' ships)'];
end

handles.current_scenario = 1;

handles.panel_bg_color = [1 1 1];

% handles.colorlist.incidence = [44, 151, 223]/255;
% handles.colorlist.v_fill = [219 231 251]/255;
% handles.colorlist.v_edge = [200 211 231]/255;
% handles.colorlist.v = [44, 151, 223]/255;
% handles.colorlist.CHI = [241, 196, 15]/255;
% handles.colorlist.GRI = [39, 174, 96]/255;
% handles.colorlist.stringency = [211, 84, 0]/255;
%s = [uistyle('FontColor',handles.colorlist.GRI), uistyle('FontColor',handles.colorlist.CHI), uistyle('FontColor',handles.colorlist.stringency)];


% close and create an uifig called 'Charts'
exisiting_uifig = findall(0, 'type', 'figure','Name','Reference charts');
close(exisiting_uifig)

fig = uifigure('Name','Reference charts');
Pix_SS = get(0,'screensize');
fig.Position = [(Pix_SS(3)-windowSize(1))/2   (Pix_SS(4)-windowSize(2))/2   windowSize(1) windowSize(2)];




% grid layout

g = uigridlayout(fig);
g.RowHeight = {'1x'};
g.ColumnWidth = {150,'1x'};

p = uipanel(g);
p.Title = "Scenario";
p.Layout.Row = 1;
p.Layout.Column = 1;

p_axes = uipanel(g);
p_axes.Layout.Row = 1;
p_axes.Layout.Column = 2;

g_axes = uigridlayout(p_axes);
g_axes.BackgroundColor = handles.panel_bg_color;
g_axes.RowHeight = {'1x'};
g_axes.ColumnWidth = {'1x','1x','1x'};
% Create axes

handles.ax_stock = uiaxes(g_axes);
handles.ax_stock.Layout.Row = 1;
handles.ax_stock.Layout.Column = 1;
plot_stock(handles.ax_stock,data,handles);

handles.ax_result = uiaxes(g_axes);
handles.ax_result.Layout.Row = 1;
handles.ax_result.Layout.Column = 2;
plot_result(handles.ax_result,data,handles)

handles.ax_ref = uiaxes(g_axes);
handles.ax_ref.Layout.Row = 1;
handles.ax_ref.Layout.Column = 3;
plot_ref(handles.ax_ref,data,handles);

% UI groups

gp = uigridlayout(p);
gp.RowHeight = {20,'1x'};
gp.ColumnWidth = {'1x'};

% Range drop-down
handles.dd = uidropdown(gp,'Items',data.name);
handles.dd.ValueChangedFcn = @(dd,event) ddChanged(dd,data.name,data,handles);
handles.dd.Layout.Row = 1;


clear;



%%%%%%%%%%%%%%%%%%%%%%%
% auxiliary functions %
%%%%%%%%%%%%%%%%%%%%%%%


function ddChanged(dd,name,data,handles)
    handles.current_scenario = find(strcmp(name, dd.Value));   
    plot_stock(handles.ax_stock,data,handles);
    plot_result(handles.ax_result,data,handles);
end

%%%%%%%%%%%%%%%%%%
% plot functions %
%%%%%%%%%%%%%%%%%%

function plot_stock(ax,data,handles)
    cla(ax);
    hold(ax,'on');
    vals = movmean(data.fish_stock(handles.current_scenario,:),handles.movmean_window1);
    plot(ax,1:numel(vals),vals,'-');%,'Color',handles.colorlist.incidence);
    ylim(ax,"auto");
 %   y = ylim(ax);
    
    h=get(ax,'Children');
    uistack(h(end),'top');
    title(ax,'Fish stock');
end


function plot_result(ax,data,handles)
    cla(ax);

    yyaxis(ax,'left'); 
    hold(ax,'off');
    vals = movmean(data.capture(handles.current_scenario,:),handles.movmean_window2);
    plot(ax,1:numel(vals),vals,'-');%,'Color',handles.colorlist.incidence);
    ylim(ax,"auto");

    yyaxis(ax,'right');
    vals = movmean(data.income(handles.current_scenario,:) ...
        -data.maintenance(handles.current_scenario,:),handles.movmean_window2);
    plot(ax,1:numel(vals),vals,'-');%,'Color',handles.colorlist.incidence);
    ylim(ax,"auto");
    
%     h=get(ax,'Children');
%     uistack(h(end),'top');
    title(ax,'Capture, Profit');
end

function plot_ref(ax,data,handles)
    cla(ax);
    hold(ax,'on');
    x_vals = data.nb_trawlers;
    maintenance_vals = data.maintenance(:,end);
    sales_value = mean(data.capture(:,end-handles.nb_values:end) .* data.price(:,end-handles.nb_values:end),2);
    scatter(ax,x_vals,sales_value,'Marker','.');%,'CData',color);
    plot(ax,x_vals,maintenance_vals,'-');%,'Color',handles.colorlist.incidence);
  %  plot(ax,1:numel(vals),vals,'-');%,'Color',handles.colorlist.incidence);
  %  ylim(ax,"auto");
  %  y = ylim(ax);
    
    h=get(ax,'Children');
    uistack(h(end),'top');
    title(ax,'Reference');
end


% function plot_lockdown(ax,r,handles)
%     if handles.show_lockdown
%         if size(handles.T_lock,1)>0
%             for i = 1:size(handles.T_lock,1)
%                 X = [handles.T_lock.start_date(i) handles.T_lock.end_date(i) handles.T_lock.end_date(i) handles.T_lock.start_date(i)];
%                 Y = [r(1) r(1) r(2) r(2)];
%                 fill(ax,X,Y, [219 231 251]/255,'EdgeColor','none','FaceAlpha',0.4);
%             end
%         end
%     end
%end


