function h = plot_G_2( nodessparsematrix, nodes, usernodes, usernodes_ids, ma_nodes, ma_nodes_ids, mid_points, closest_nodes, plottitle, ...
    draw_circle, coordinates, draw_mid_points, draw_manodes, draw_anodes, r, h)
%PLOT_G Summary of this function goes here
%   Detailed explanation goes here

%Number of total nodes including usernodes and agentnodes.
nnodes = size(nodes,1);
nusernodes = length(usernodes_ids);

%Usernodes IDs without ma_nodes
%usernodes_ids = 1:nusernodes;
%usernodes_ids(ma_nodes_ids) = [];

global sim_time_progress;

global attack;

if nargin < 16
    h = figure;
else
    clf(h);
    figure(h);
    %hold off;
end
title([plottitle ' -- Sim. time: ' num2str(sim_time_progress)]);
hold on;
for i=1:size(usernodes,1),
    
    if(isempty(find(i == ma_nodes_ids)))
        
        h_un = plot(gca,usernodes(i,1), usernodes(i,2),'bo');
        set(h_un,'XData',usernodes(i,1),'YData', usernodes(i,2));
        set(h_un,'Marker','o');
        set(h_un,'MarkerFaceColor','black');
        text(usernodes(i,1) + 0.10, usernodes(i,2) - 0.10,num2str(usernodes_ids(i)));
        if(coordinates)
            text(usernodes(i,1), usernodes(i,2) - 0.15,['[' num2str(usernodes(i,1)) ', ' num2str(usernodes(i,2)) ']']);
        end
        if(draw_circle)
            circle(usernodes(i,1),usernodes(i,2),r,[0 0 0],':');
        end
    end
end

axis([0 6.6 0 5.4]);
%axis([0 5 0 5]);

index = find(nodessparsematrix);

for i=1:length(index),
    
    [row col] = ind2sub(size(nodessparsematrix),index(i));
    
    %Plot a line between both nodes row and col, origin and destination
    %respectively.
    %First get the coordinates of both nodes
    
    x_1 = nodes(row,1);
    y_1 = nodes(row,2);
    
    x_2 = nodes(col,1);
    y_2 = nodes(col,2);
    
    % Draw the circle
    %circle(x_1,y_1,r);
    
    % Draw the line
    line('XData',[x_1 x_2],'YData',[y_1 y_2],'Color','b','LineWidth',1,'LineStyle','-.');
    
end

if draw_mid_points,
    % Plot the attraction points ...
    nmids_points = size(mid_points,1);
    
    for i=1:nmids_points,
        h_mid_p = plot(mid_points(i,1),mid_points(i,2),'k');
        set(h_mid_p,'Marker','v');
        set(h_mid_p,'MarkerFaceColor','green');
        %line('XData',[closest_nodes(i,1) closest_nodes(i,3)],'YData',[closest_nodes(i,2) closest_nodes(i,4)],'Color','r','LineWidth',1,'LineStyle',':');
    end
end


if (draw_anodes),

    if isempty(usernodes),
        anodes_ids = 1:nnodes;
    else
        anodes_ids = 1:nnodes - size(usernodes,1);
    end

    k=1;
    for i=nusernodes + 1:nnodes,
        h_an = plot(gca,nodes(i,1), nodes(i,2),'k');
        set(h_an,'XData',nodes(i,1),'YData', nodes(i,2));
        set(h_an,'Marker','s');
        set(h_an,'MarkerFaceColor','g');
        text(nodes(i,1) + 0.10, nodes(i,2) - 0.10,['RN' num2str(anodes_ids(k))]);
        if(coordinates)
            text(nodes(i,1), nodes(i,2) - 0.15,['[' num2str(nodes(i,1)) ', ' num2str(nodes(i,2)) ']']);
        end
        if(draw_circle)
            circle(nodes(i,1),nodes(i,2),r,[0 1 0],'-');
        end
        k = k+1;
    end
end
% Draw all pending things in current figure.
drawnow;

xlabel('x(m)');
ylabel('y(m)');

end

