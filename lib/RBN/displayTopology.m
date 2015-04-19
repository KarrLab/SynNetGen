function nodeUpdated = displayTopology(node, connectionMatrix, optionString, varargin)

% DISPLAYTOPOLOGY Visualize network topology, set xy-components and "ouput" field in node structure-array.
%   
%   DISPLAYTOPOLOGY(NODE, CONNECTIONMATRIX, OPTIONSTRING) displays the network topology defined by CONNECTIONMATRIX and updates
%   the x and y components in the node structure-array. OPTIONSTRING must be set to 'arrow' or 'line' and defines whether the
%   network connections are represented as arrows or as lines. For networks with nodes > 50 it is recommended to use 'line'.
%   Furthermore, the "output" field in the node structure-array is updated.
%
%   DISPLAYTOPOLOGY(NODE, CONNECTIONMATRIX, OPTIONSTRING, SAVEFLAG) displays the network topology defined by CONNECTIONMATRIX and updates
%   the x and y components in the node structure-array. OPTIONSTRING must be set to 'arrow' or 'line' and defines whether the
%   network connections are represented as arrows or as lines. For networks with nodes > 50 it is recommended to use 'line'.
%   Furthermore, the "output" field in the node structure-array is updated. If SAVEFLAG is set, the figure is saved to the disk.
%
%
%   Input:
%       node               -  1 x n structure-array containing node information
%       connectionMatrix   -  n x n adjacent matrix (defined as in graph theory)
%       optionString       -  must be set to either 'arrow' or 'line'
%       saveFlag           - (Optional) Flag: 1 - Figure will be saved to disk  0 - no saving

%
%   Output: 
%       node               -  1 x n structure-array containing updated node information ("output" field)


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 8.11.2002 LastModified: 20.01.2003


if(nargin == 3 | nargin == 4)
    
    if(nargin == 4)
        saveFlag = varargin{1};
    else
        saveFlag = 0;
    end
    
    if(length(connectionMatrix) ~= length(node))
        error('ConnectionMatrix does not correspond to NodeMatrix. Wrong dimension.')    
    end
    
    
    if((~strcmp(optionString, 'arrow')) & (~strcmp(optionString, 'line')))
        error('OptionString must be set to ''arrow'' or ''line'' ')    
    end;
    
    option = strcmp(optionString, 'arrow');
    
    n = length(connectionMatrix);

    % calculate coordinates of the nodes and the corresponding label 
    theta = 2*pi./n;
    angle = theta*(0:(n-1));
    
    radius = n* ones(1,length(angle));
    textRadius =  n*( ones(1,length(angle)) + 0.2);
    
    x = radius .* cos(angle);
    y = radius .* sin(angle);
    
    textX = textRadius .* cos(angle);
    textY =  textRadius .* sin(angle);
    
    nodeUpdated = node;
    fHandle = figure;
    figure(fHandle);
    
    str = sprintf('Network Topology for N = %d and K = %d', n, sum(connectionMatrix(:,1)));
    set(fHandle,'Color','w','Name', str);
    
    % display nodes: 0 (off) = black, 1 (on) = white
    for m = 1:n
        if(nodeUpdated(m).state == 0)
            h = rectangle('Position',[x(m)-0.5, y(m)-0.5, 1, 1], 'Curvature', [1,1], 'FaceColor','k');  
        else  
            h1 = rectangle('Position',[x(m)-0.5, y(m)-0.5, 1, 1], 'Curvature', [1,1], 'FaceColor','w');  
        end
    end
    
    
    grid off;
    colormap lines;
    cmap = colormap;
    colorbar('horiz'); 
    
    
    if(option)       % plot directed edges with arrow
        axis(axis);  % prevent axis redimensioning (trick)
        
        for j=1:n
            text(textX(j), textY(j), int2str(j),'Color','m');
            
            nodeUpdated(j).output = [];
            
            
            indices = find(connectionMatrix(j,:));
            
            for k=1:length(indices)
                multiplicity(k) = connectionMatrix(j,indices(k));    
            end
            
            for m=1:length(indices)
                nodeUpdated(j).output = [nodeUpdated(j).output repmat(indices(m),1,multiplicity(m))];        
                if(j == indices(m))
                    rectangle('Position',[x(j)-1.9, y(j)-1.5, 2, 2], 'Curvature', [1,1],'EdgeColor',cmap(multiplicity(m),:));                       
                end  
                arrow([x(j) y(j)] , [x(indices(m)) y(indices(m))],'FaceColor', cmap(multiplicity(m),:),'EdgeColor',cmap(multiplicity(m),:));
                
            end       
            
        end
        
        
    else          %plot directed edges as line only
        for j=1:n
            text(textX(j), textY(j), int2str(j),'Color','m');
            
            nodeUpdated(j).output = [];
            
            
            indices = find(connectionMatrix(j,:));
            for k=1:length(indices)
                multiplicity(k) = connectionMatrix(j,indices(k));    
            end
            
            for m=1:length(indices)
                nodeUpdated(j).output = [nodeUpdated(j).output repmat(indices(m),1,multiplicity(m))];        
                if(j == indices(m))
                    rectangle('Position',[x(j)-1.9, y(j)-1.5, 2, 2], 'Curvature', [1,1],'EdgeColor',cmap(multiplicity(m),:));                       
                else    
                    line([x(j) x(indices(m))] , [y(j) y(indices(m))],'Color', cmap(multiplicity(m),:));
                end 
            end       
            
        end
        
    end
    
    % display legend
    text(n,-n,'black = off (0)');
    text(n,-n*.9,'white = on (1)');
    text(-n*0.7,-n*2.2,'Number of connections')
    
    axis equal;
    axis off;
    cameratoolbar('Show');
    cameratoolbar('SetMode','zoom');
    
    if(saveFlag)
        saveFigure(gcf);
    end
    
    
    
else
    error('Wrong number of arguments. Type: help displayTopology')    
end
