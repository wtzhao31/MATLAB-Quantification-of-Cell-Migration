% Cell chemotaxis quantification method
% Normalize program: reformats imported spreadsheet to make it readable 
% Winfield Zhao
% 7/11/21

function [X_norm, Y_norm, X_first, Y_first, track_ID, slice_ID] = normalize(fileName, slices, tracks, slice_start)
    X_total = xlsread(fileName,'E:E'); % for manual tracking: X = C:C // for TrackMate: X = E:E
    Y_total = xlsread(fileName,'F:F'); % for manual tracking: Y = D:D // for TrackMate: Y = F:F
    track_ID_total = xlsread(fileName,'C:C');
    slice_ID_total = xlsread(fileName,'B:B'); % gets the slice ID
    
    slice_keep = slices - slice_start + 1; % number of slices that are going to be kept
    
    % INPUTTING VALUES FROM EXCEL FILE
    % creating 2D matrix for X & Y values separately
    % rows: position, columns: track/cell number
    X = zeros(slice_keep,tracks);
    Y = zeros(slice_keep,tracks);
    track_ID = zeros(slice_keep,tracks);
    slice_ID = zeros(slice_keep,tracks);

    % This for loop takes all the data and puts it into a 2D matrix
    % Position values: slices x track
    % X and Y are separate matrices
    for i = 1:tracks
        for j = slice_start:slices % slices
            track_ID(j-slice_start+1,i) = track_ID_total(slices * (i-1) + j);
            slice_ID(j-slice_start+1,i) = slice_ID_total(slices * (i-1) + j);
            X(j-slice_start+1,i) = X_total(slices * (i-1) + j);
            Y(j-slice_start+1,i) = Y_total(slices * (i-1) + j);
        end
    end

    % NORMALIZING
    X_norm = zeros(slice_keep,tracks);
    Y_norm = zeros(slice_keep,tracks);
    X_first = X(1,:); % the first X value of every track (ImageJ coordinates)
    Y_first = Y(1,:);
    for j = 1:slice_keep
        X_norm(j,:) = X(j,:) - X_first;
        Y_norm(j,:) = Y_first - Y(j,:);
    end
end
