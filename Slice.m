% Slice class
% Winfield Zhao
% 2/16/21

classdef Slice
    properties
        sliceNum
        ID
        x % Dimensions: slices x 1
        y
        x_IJ
        y_IJ
        individual_dist % individual distance between every slice
        individual_angle
        accumulated_dist
        speed
        euclidian_dist
        runsTumbles
        accuRunsPercent
        angles
        directionality
        x_FMI
        y_FMI
        vector_polar_dist
        vector_polar_angle
        vector_cartesian_x
        vector_cartesian_y
        
        all
    end
    
    methods
        function obj = Slice(slice_data)
            obj.sliceNum = slice_data(:,1);
            obj.ID = slice_data(:,2);
            obj.x = slice_data(:,3);
            obj.y = slice_data(:,4);
            obj.x_IJ = slice_data(:,5);
            obj.y_IJ = slice_data(:,6);
            obj.individual_dist = slice_data(:,7);
            obj.individual_angle = slice_data(:,8);
            obj.accumulated_dist = slice_data(:,9);
            obj.speed = slice_data(:,10);
            obj.euclidian_dist = slice_data(:,11);
            obj.runsTumbles = slice_data(:,12);
            obj.accuRunsPercent = slice_data(:,13);
            obj.angles = slice_data(:,14);
            obj.directionality = slice_data(:,15);
            obj.x_FMI = slice_data(:,16);
            obj.y_FMI = slice_data(:,17);
            obj.vector_polar_dist = slice_data(:,18);
            obj.vector_polar_angle = slice_data(:,19);
            obj.vector_cartesian_x = slice_data(:,20);
            obj.vector_cartesian_y = slice_data(:,21);
            obj.all = [obj.sliceNum,obj.ID,obj.x,obj.y,obj.x_IJ,obj.y_IJ,obj.individual_dist,obj.individual_angle,obj.accumulated_dist,obj.speed,obj.euclidian_dist,obj.runsTumbles,obj.accuRunsPercent,obj.angles,obj.directionality,obj.x_FMI,obj.y_FMI,obj.vector_polar_dist,obj.vector_polar_angle,obj.vector_cartesian_x,obj.vector_cartesian_y];
        end
    end
end
