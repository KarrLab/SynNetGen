function  nodeXY = seeTopology(node, connectionMatrix, optionString)
%SEETOPOLOGY Visualize network topology and set xy-components in node structure-array
%   
%   SEETOPOLOGY(NODE, CONNECTIONMATRIX, OPTIONSTRING) displays the network topology defined by CONNECTIONMATRIX and updates
%   the x and y components in the node structure-array. OPTIONSTRING must be set to 'arrow' or 'line' and defines whether the
%   network connections are represented as arrows or as lines. For networks with nodes > 50 it is recommended to use 'line'.
%
%   Inputs:
%       node               -  1 x n structure-array containing node information
%       connectionMatrix   -  n x n adjacent matrix (defined as in graph theory)
%       optionString       -  must be set to either 'arrow' or 'line'
%
%   Output: 
%       nodeXY               - 1 x n sturcture-array with updated node information (xy-components)
%


%   Author: Christian Schwarzer - SSC EPFL
%   CreationDate: 8.11.2002 LastModified: 11.11.2002


if(nargin == 3)
    
    if(length(connectionMatrix) ~= length(node))
      error('ConnectionMatrix does not correspond to NodeMatrix. Wrong dimension.')    
    end
 
 
   if((~strcmp(optionString, 'arrow')) & (~strcmp(optionString, 'line')))
      error('OptionString must be set to ''arrow'' or ''line'' ')    
   end;
   
    option = strcmp(optionString, 'arrow');
    
    n = length(connectionMatrix);
    
    theta = 2*pi./n;
    angle = theta*(0:(n-1));
    
    radius = n* ones(1,length(angle));
    textRadius =  n*( ones(1,length(angle)) + 0.2);
    
    x = radius .* cos(angle);
    y = radius .* sin(angle);
         
    textX = textRadius .* cos(angle);
    textY =  textRadius .* sin(angle);
    
    nodeXY = node;
    
    for i=1:n
        nodeXY(i).x = x(i);
        nodeXY(i).y = y(i);
    end        
    
    nodeXY = assocNeighbours(nodeXY, connectionMatrix);
        
    fHandle = figure;
    figure(fHandle);
    set(fHandle,'Color','w','Name','Network Topology');

    %Display Nodes: 0 (off) = black, 1 (on) = white
    for m = 1:n
        if(nodeXY(m).state == 0)
          h = rectangle('Position',[nodeXY(m).x-0.5, nodeXY(m).y-0.5, 1, 1], 'Curvature', [1,1], 'FaceColor','k');  
        else  
          h1 = rectangle('Position',[nodeXY(m).x-0.5, nodeXY(m).y-0.5, 1, 1], 'Curvature', [1,1], 'FaceColor','w');  
        end
    end

      
    grid off;
  
    
    if(option)      %plot directed edges with arrow
        axis(axis);% prevent axis redimensioning (trick)
       
        for j=1:n
         text(textX(j), textY(j), int2str(j),'Color','m');
             for k=1:length(nodeXY(j).output)
                 if(j == nodeXY(j).output(k))
                    rectangle('Position',[nodeXY(j).x-1.9, nodeXY(j).y-1.5, 2, 2], 'Curvature', [1,1],'EdgeColor','b');      
                 end
                 arrow([nodeXY(j).x nodeXY(j).y] , [nodeXY(nodeXY(j).output(k)).x nodeXY(nodeXY(j).output(k)).y],'FaceColor','b','EdgeColor','k');
            end
        end
       
        
    else          %plot directed edges as line only
        for j=1:n
         text(textX(j), textY(j), int2str(j),'Color','m');
             for k=1:length(nodeXY(j).output)
               if(j == nodeXY(j).output(k))
                 rectangle('Position',[nodeXY(j).x-1.9, nodeXY(j).y-1.5, 2, 2], 'Curvature', [1,1],'EdgeColor','b');                       
               else                
                 line([nodeXY(j).x nodeXY(nodeXY(j).output(k)).x] , [nodeXY(j).y nodeXY(nodeXY(j).output(k)).y],'Color','b');
              end 
             end
        end
    end
    
    % display legend
    text(n,-n,'black = off (0)');
    text(n,-n*.9,'white = on (1)')
    
    axis equal;
    axis off;
     
    
   
else
    error('Wrong number of arguments. Type: help seeTopology')    
end
