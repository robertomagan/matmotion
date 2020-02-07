function [ network ] = makenetwork( nodes, r )
%MAKENETWORK
%   Make entire network conectivity. Returns a lower triangular matrix,
%   containing the euclidean distance of each pair of nodes i,j with a
%   euclidean distance equal or greater than the coverage range of a node.
%   
%INPUT:
%   - usernodes: struct of user nodes.
%   - r: coverage range
%
%OUTPUT:
%   - network: matrix with 
%   Example of network matrix:
%   
%   0   0   0   0   0   
%   1.5 0   0   0   0   (2,1)= 1.5 (Euclidean distance between node 2 and 1)
%   1.2 1.3 0   0   0   (3,1)= 1.2 (Euclidean distance between node 3 and 1)
%   1.1 1.9 1.5 0   0   ...
%   1.0 0.7 0.7 1.7 0   (4,3)= 1.5 (Euclidean distance between node 4 and 3)
%
%   NOTE: zero in any lower matrix position means that there is no link
%   between the correponding nodes.

% Number of usernodes
nnodes = size(nodes,1);

% Low triangular matrix to conform a matrix with link cost edges as
% euclidean distance ...
network = zeros(nnodes);

for i=1:nnodes,
    for j=i+1:nnodes,
        %If the range of a node is greater or equal than the euclidean
        %distante between both nodes.
        %norm(nodes(i).x_y - nodes(j).x_y)
        
        % Get the 6 firts decimals
        %d = redondeo(norm(nodes(i,:) - nodes(j,:)),6);
        %d = norm(nodes(i,:) - nodes(j,:));
        
        d = sqrt((nodes(i,1) - nodes(j,1))^2 + (nodes(i,2) - nodes(j,2))^2);
        %d = single(d);
        
        if ((d - r) <= 0.00001)
            network(j,i)=d;
        end
    end
end

end

