function vit_all = rpgm_movements( nusernodes, bonn_motion_mov_file, sim_time, UN_velocity )
% Parses and computes the node movements obtained from BonnMotion mobility
% generation tool (http://sys.cs.uos.de/bonnmotion/).
%
% NOTE: Currently this function has been only tested with RPGM movement
% pattern.
%
% INPUT:
%   - nusernodes: # of user nodes implied.
%   - bonn_motion_mov_file: *.movements file
%   - sim_time: total time of simulation (per repetition)
%   - UN_velocity: UN velocity in m/s
%
% OUTPUT:
%   - vit_all: matrix contains all the node positions at each time step.
%     vit_all -> nusernodes x sim_time

% Contains all the unser node movements
vit_all = zeros(nusernodes, 2*sim_time);


% Para the bonn motion file into a matrix.
all_movs = parse_motion(nusernodes,bonn_motion_mov_file);
%all_movs = importdata(bonn_motion_mov_file);

% Replace zeros by NaN to be detected. NaN are holes that are not useful ;)
all_movs(all_movs(:,1:end)==0) = nan;
all_movs(:,1) = 0;%Restablish the time 0 s

% Obtain the times of RPGM pattern in which the nodes change its directions.
times = all_movs(:,1:3:size(all_movs,2));
times = round(times);
all_movs(:,1:3:size(all_movs,2)) = [];

% Matrix with all x,y positions of the nodes
pos_x = all_movs(:,1:2:size(all_movs,2));
pos_y = all_movs(:,2:2:size(all_movs,2));

% contains the last point reached when the node could not reach its target
% point
not_reached = 0;

% Loop for making the neccesary points between the specific times from
% the boon motion file. It depends on the stablished simulation time.
for i=1:nusernodes,
    not_reached = 0;
    for j=1:size(times,2) - 1,
        
        % If no more times for this node
        if (~isnan(pos_x(i,j+1)) && (pos_x(i,j) ~= pos_x(i,j+1))) 
            % Start point and end point of node at this time interval
            
            x = pos_x(i,[j j+1]);
            y = pos_y(i,[j j+1]);
            
            if not_reached
                x(1) = xx(end);
                y(1) = yy(end);
            end                                        
            
            if(sim_time == times(i,j))
                break;
            end
            
            % Get the number of intervals according to a predefined user
            % node velocity
            t1 = abs(times(i,j+1)-times(i,j));
            if t1 ~= 0
            d1 = sqrt((x(1) - x(2))^2 + (y(1) - y(2))^2);
            
            intervals = d1/UN_velocity;
            d2 = abs(x(1) - x(2))/intervals;
            intervals = floor(intervals);
            
            %             if pos_x(i,j) < pos_x(i,j+1)
            %                 last_point_limit = pos_x(i,j) + d2*UN_velocity;
            %             else
            %                 last_point_limit = pos_x(i,j) - intervals*UN_velocity;
            %             end
            
            xx = zeros(1,intervals+1);
            
            % intermediate X points
            for inter=1:intervals,
                
                %if pos_x(i,j) < pos_x(i,j+1)
                if x(1) < x(2)
                    %xx(inter+1) = pos_x(i,j) + inter*d2;
                    xx(inter+1) = x(1) + inter*d2;
                else
                    xx(inter+1) = x(1) - inter*d2;
                end
                
                
            end
            
            %xx(1) = pos_x(i,j);
            xx(1) = x(1);
            xx(end) = x(2);
            
            %d2 = (UN_velocity * d1)/t1;
            
            %intervals = d1/d2;
            
            %xx = linspace(pos_x(i,j),pos_x(i,j+1),intervals);
            
            %if(pos_x(i,j) ~= pos_x(i,j+1))
                
                % Get the node intermediate positions between the start and end
                % point. X positions
                %xx = linspace(pos_x(i,j),last_point_limit,intervals+1);
                
                if intervals < t1
                    xx = [xx ones(1,t1-intervals-1)*pos_x(i,j+1)];
                    not_reached = 0;
                else
                    xx = xx(1:t1);
                    not_reached = 1;
                end
                
                % If the following time is higher than the sim_time,
                % we can not evaluate this points beyong the sim_time. For
                % this reason we need to limit to the sim_time stablished.
                if(times(i,j+1) > sim_time)
                    xx = xx(1:(sim_time-times(i,j)));
                    times_n = sim_time;
                else
                    times_n = times(i,j+1);
                end                                                
                
                if intervals == 0
                    % Fill the output vector
                    vit_all(i,2*times(i,j)+1:2:2*abs(times_n-times(i,j))+2*times(i,j)) = x(end);                    
                    vit_all(i,2*times(i,j)+2:2:2*abs(times_n-times(i,j))+2*times(i,j)) = y(end);
                    xx = x(end);
                    yy = y(end);
                else
                    
                    % Get the node intermediate positions between the start and end
                    % point. Y positions
                    
                    yy = interp1(x,y,xx);
                    
                    
                    yyaux = yy(~isnan(yy));
                    yy = [yyaux ones(1,length(yy) - length(yyaux))*yyaux(end)];
                    
                    % Fill the output vector
                    vit_all(i,2*times(i,j)+1:2:2*abs(times_n-times(i,j))+2*times(i,j)) = xx;
                    vit_all(i,2*times(i,j)+2:2:2*abs(times_n-times(i,j))+2*times(i,j)) = yy;
                end
                
                
                % If it is already computed and the next times is higher
                % than the stablished sim_time, we don't have any more
                % positions to compute
                if(times(i,j+1) > sim_time)
                    break;
                end
            %end
            end
        end
    end
    
    % If sim_time is higher than the last time generated for the node
    % through the boon motion application, an empty positions will appear.
    % So we need to manage them in this case by establishing in these
    % empty positions the last correctly computed. So the node has stopped.
    aux_vit_all = vit_all(i,:);
    n_ceros =  length(aux_vit_all(1,aux_vit_all(1,:)==0));
    aux_vit_all(end-n_ceros+1:2:end) = xx(end);
    aux_vit_all(end-n_ceros+2:2:end) = yy(end);
    
    vit_all(i,:) = aux_vit_all;
end



end

