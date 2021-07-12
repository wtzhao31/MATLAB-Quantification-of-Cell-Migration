% Cell chemotaxis quantification method
% Track class
% Winfield Zhao
% 7/11/21

classdef Track
    properties
        slices
        tracks
        interval
        
        sliceNum
        x
        y
        xIJ
        yIJ
        trackID
        sliceID
        
        indDist
        indAngle
        accuDist
        speed
        euDist
        runsTumbles % runs and tumbles (difference in eu dist between adjacent slices)
        accuRunsPercent % NEW: stores the accumulated runs percentage of each slice
        angles
        directionality
        xFMI
        yFMI
        vectorPolar
        vectorCartesian
        
        all % Dimensions: slices x 19
        
        % Final values: double values
        accuDistFinal
        speedAvgFinal % just the average speed of the Cell
        euDistFinal
        angleFinal
        directionalityFinal
    end
    
    methods
        % Constructor
        function obj = Track(x,y,xIJ,yIJ,track_ID,slice_ID,sliceNum,slices,tracks,interval)
            obj.slices = slices;
            obj.tracks = tracks;
            obj.interval = interval;
            
            obj.sliceNum = sliceNum;
            obj.x = x; % x and y will already be normalized
            obj.y = y;
            obj.xIJ = xIJ;
            obj.yIJ = yIJ;
            obj.trackID = track_ID;
            obj.sliceID = slice_ID;
            [obj.indDist,obj.indAngle,obj.accuDist,obj.speed,obj.euDist,obj.angles,obj.directionality,obj.xFMI,obj.yFMI,obj.vectorPolar,obj.vectorCartesian,obj.runsTumbles,obj.accuRunsPercent] = everything(obj);
            obj.all = [obj.sliceNum,obj.trackID,obj.x,obj.y,obj.xIJ,obj.yIJ,obj.indDist,obj.indAngle,obj.accuDist,obj.speed,obj.euDist,obj.runsTumbles,obj.accuRunsPercent,obj.angles,obj.directionality,obj.xFMI,obj.yFMI,obj.vectorPolar,obj.vectorCartesian];
            obj.accuDistFinal = obj.accuDist(slices);
            obj.speedAvgFinal = sum(obj.speed) / (slices - 1); % calculates average speed
            obj.euDistFinal = obj.euDist(slices);
            obj.angleFinal = obj.angles(slices);
            obj.directionalityFinal = obj.directionality(slices);
        end
        function [individual_dist,individual_angle,accumulated_dist,speed,euclidean_dist,angles,directionality,x_FMI,y_FMI,vector_polar,vector_cart,runTumbleVector,accuRunsVector] = everything(obj)
            individual_dist = zeros(obj.slices,1);
            accumulated_dist = zeros(obj.slices,1);
            individual_angle = zeros(obj.slices,1);
            angles = zeros(obj.slices,1);
            directionality = zeros(obj.slices,1);
            x_FMI = zeros(obj.slices,1);
            y_FMI = zeros(obj.slices,1);
            vector_polar = zeros(obj.slices,2);
            vector_cart = zeros(obj.slices,2);
            runTumbleVector = zeros(obj.slices,1);
            accuRunsVector = zeros(obj.slices,1);
            
            % calculating individual distance
            vector_cart(2:end,1) = obj.x(2:end)-obj.x(1:end-1); % difference between successive x and y coordinates
            vector_cart(2:end,2) = obj.y(2:end)-obj.y(1:end-1);
            individual_dist(2:end) = sqrt(vector_cart(2:end,1).^2+vector_cart(2:end,2).^2);
            euclidean_dist = sqrt((obj.x).^2 + (obj.y).^2);
            speed = individual_dist/obj.interval;
            
            % runs and tumbles (new implementation)
            temp_RT = euclidean_dist(2:end) - euclidean_dist(1:end-1); 
            runTumbleVector(2:end) = temp_RT > 0;
            
            for i = 2:obj.slices % loop to get accumulated distances and angles
                accumulated_dist(i) = sum(individual_dist(1:i));
                var = (obj.y(i) - obj.y(i-1)) / (obj.x(i) - obj.x(i-1));
                theta = atand(var);
                accuRunsVector(i) = sum(runTumbleVector(2:i)) / (i-1);
                if obj.x(i) < obj.x(i-1)
                    theta = theta + 180;
                elseif obj.x(i) > obj.x(i-1) && obj.y(i) < obj.y(i-1)
                    theta = theta + 360;
                end
                individual_angle(i) = theta; % set that angle value to theta
                angles(i) = atand(obj.y(i) / obj.x(i)); 
                if obj.x(i) < 0 % could potentially do some logical vector stuff here.
                    angles(i) = angles(i) + 180; % add by 180 if x < 0
                elseif obj.x(i) > 0 && obj.x(i) < 0
                    angles(i) = angles(i) + 360; % add by 360 if x > 0 and y < 0
                end
            end
            
            directionality(2:end,:) = euclidean_dist(2:end,:) ./ accumulated_dist(2:end,:);
            x_FMI(2:end,:) = obj.x(2:end,:) ./ accumulated_dist(2:end,:);
            y_FMI(2:end,:) = obj.y(2:end,:) ./ accumulated_dist(2:end,:);
            vector_polar(:,1) = individual_dist;
            vector_polar(:,2) = individual_angle;
        end
        
        % Origin Plot: just the lines
        function originPlot(obj)
            plot(obj.x,obj.y,'k','linewidth',1.5);
        end
        % Origin Plot: final endpoints and the trackID label
        function finalPoint(obj)
            plot(obj.x(end),obj.y(end),'.r','MarkerSize',15);
            disp('test');
            %label = int2str(obj.trackID(1));
            %text(obj.x(end),obj.y(end),label,'FontSize',12,'VerticalAlignment','bottom','HorizontalAlignment','right');
        end
        % Runs/tumbles plot: plots if the cell had a run or tumble at each time point
        function runsTumblesPlot(obj)
            plot(obj.x,obj.y,'k','linewidth',1.5);
            hold on;
            for j = 1:obj.slices % loop through slices
                if (obj.runsTumbles(j) == 0) % if the run/tumble is a 0 -> it tumbled
                    plot(obj.x(j),obj.y(j),'.m','linewidth',2);
                else
                    plot(obj.x(j),obj.y(j),'.g','linewidth',2);
                end
                hold on;
            end
        end
    end
end
