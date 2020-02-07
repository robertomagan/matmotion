function matrix = parse_motion(nnodes,file)

fileID = fopen(file);
C = textscan(fileID,'%f','Delimiter',' ','CollectOutput', true);
fclose(fileID);

M = cell2mat(C);

index = find(M==0);

max_a = [];

for i=1:length(index),
    
    %Cual es la m�xima diferencia
    if i < length(index),
        max_a = [max_a (index(i+1) - index(i))];
    end
    
end

max_a = max(max_a);
matrix = zeros(nnodes,max_a);
matrix(:) = nan;

for i=1:length(index),
    if i < length(index),
        matrix(i,1:length(index(i):index(i+1)-1)) = M(index(i):index(i+1)-1)';
    else
        matrix(i,1:length(M(index(i):end))) = M(index(i):end)';
    end
end
