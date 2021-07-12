% Cell chemotaxis quantification method
% main program
% Winfield Zhao
% 7/11/21

clc; clear; close all;

% DATA PARAMETERS
% A) Image Parameters (not customizable)
name = '20210706_6'; %20210309gelBowHSC was the previous name
fileName = strcat(name,'.xlsx');
slices = 13; % number of slices
tracks = 210; % number of tracks
interval = 5; % minutes

% B) Filtering parameters
sliceStart = 1; % which slice to start at
sliceDivide = 1; % Filter ever 'n' slices
sliceEnd = slices; % which slice to end at
sliceNum = length(sliceStart:sliceDivide:sliceEnd);

% C) Plotting parameters
plotNum = 25; % Number of tracks being plotted
plotRange = 140; % visual aesthetic: axes will be m x m

% D) PROGRAM OPTIONS - on/off switches
originPlot = 1; % plot Origin Plot
rosePlot = 0; % plot Rose Plot
exportPlot = 1; % export plots as .eps and .png files
eAT = 1; % export ALL tracks data
eAS = 1; % export ALL slices data
eFT = 0; % export FILTERED tracks data
eFS = 0; % export FILTERED slices data
ePT = 0; % export PLOTTED tracks dataa
ePS = 0; % export PLOTTED slices data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NORMALIZING DATA, CREATE TRACK OBJECTS FOR ALL TRACKS
[x,y,x_first,y_first,track_ID,slice_ID] = normalize3(fileName,slices,tracks,1); % start at first slice
allTracks = Track.empty(0,tracks); % all tracks, all slices
for i = 1:tracks
    allTracks(i) = Track(x(:,i),y(:,i),x(:,i)+x_first(i),y(:,i)+y_first(i),track_ID(:,i),slice_ID(:,i),(1:1:slices)',slices,tracks,interval);
end

% RECONSTRUCT TRACK OBJECTS FOR FILTERED TRACKS
filteredTracks = Track.empty(0,tracks); % all tracks, selected slices
for i = 1:tracks
    temp_Track = allTracks(i);
    xNew = temp_Track.x(sliceStart:sliceDivide:sliceEnd); % get the range of x and y values that you want
    yNew = temp_Track.y(sliceStart:sliceDivide:sliceEnd);
    xIJNew = temp_Track.xIJ(sliceStart:sliceDivide:sliceEnd);
    yIJNew = temp_Track.yIJ(sliceStart:sliceDivide:sliceEnd);
    filteredTracks(i) = Track(xNew-xNew(1),yNew-yNew(1),xIJNew,yIJNew,temp_Track.trackID(sliceStart:sliceDivide:sliceEnd),temp_Track.sliceID(sliceStart:sliceDivide:sliceEnd),(sliceStart:sliceDivide:sliceEnd)',length(xNew),tracks,interval);
end

% FILTERING WHICH CELLS TO PLOT BASED ON USER CONDITIONS
% If you get an error, it's because the condition was too strict. Needs to
% be loosened
plottedTracks = Track.empty(0,plotNum); % selected tracks, selected slices
counter = 1;
index = 1;
while (counter < plotNum + 1) % filtering out the artifacts
    %if ((filteredTracks(index).euDistFinal < 2)) % restricting certain cells
        %if (total_cells(index).accumulated_dist_final > 30) && (total_cells(index).accumulated_dist_final < 60) % only plots cells that have moved a certain distance
        plottedTracks(counter) = filteredTracks(index);
        counter = counter + 1;
   % end
    index = index + 1;
end

% PLOTTING CELLS IN plottedCells LIST
if (originPlot == 1)
    originFig = figure(1);
    for i = 1:plotNum % plot the movements
        plottedTracks(i).originPlot;
        %plottedTracks(i).runsTumblesPlot;
        hold on;
    end
    for i = 1:plotNum % plot the end points and Track ID label
        plottedTracks(i).finalPoint;
        hold on;
    end
    titleName = strcat(name,' Origin Plot');
    title(titleName); xlabel('µm'); ylabel('µm');
    axis([(-1*plotRange) (plotRange) (-1*plotRange) (plotRange)]);
    pbaspect([1 1 1]); grid;
    if (exportPlot == 1)
        epsName = strcat(name,'_originPlot.eps'); exportgraphics(originFig,epsName,'ContentType','vector');
        pngName = strcat(name,'_originPlot.png'); saveas(originFig,pngName);
    end
end

speedMat = zeros(sliceNum,tracks);
directionalityMat = zeros(sliceNum,tracks);
euDistMat = zeros(sliceNum,tracks);
runsPercentMat = zeros(sliceNum,tracks);
runsTumblesMat = zeros(sliceNum,tracks);
xfmiMat = zeros(sliceNum,tracks);
yfmiMat = zeros(sliceNum,tracks);
for i = 1:tracks
    speedMat(:,i) = allTracks(i).speed;
    directionalityMat(:,i) = allTracks(i).directionality;
    euDistMat(:,i) = allTracks(i).euDist;
    runsPercentMat(:,i) = allTracks(i).accuRunsPercent;
    runsTumblesMat(:,i) = allTracks(i).runsTumbles;
    xfmiMat(:,i) = allTracks(i).xFMI;
    yfmiMat(:,i) = allTracks(i).yFMI;
end

% ROSE PLOT
if (rosePlot == 1)
    roseFig = figure(2);
    final_angles_rad = zeros(1,plotNum);
    for i = 1:plotNum
        final_angles_rad(i) = deg2rad(plottedTracks(i).angles(end));
    end
    polarhistogram(final_angles_rad,36);
    titleName = strcat(name,' Rose Plot');
    title(titleName);
    if (exportPlot == 1) % only export if this is turned on
        epsName = strcat(name,'_rosePlot.eps'); exportgraphics(gcf,epsName,'ContentType','vector');
        pngName = strcat(name,'_rosePlot.png'); saveas(gcf,pngName);
    end
end

% CONVERTING TRACKS TO SLICES
allSlices = tracks2Slices(allTracks,tracks,slices); % Master: contains all Slices in the og data
filteredSlices = tracks2Slices(filteredTracks,tracks,sliceNum); % all slices that have been filtered
plottedSlices = tracks2Slices(plottedTracks,plotNum,sliceNum); % all slices that have been plotted

% EXPORTING DATA OUT
if (eAT == 1) exportData(name,allTracks,tracks,'_allTracksDataNew.xls'); end
if (eFT == 1) exportData(name,filteredTracks,tracks,'_filteredTracksData.xls'); end
if (ePT == 1) exportData(name,plottedTracks,plotNum,'_plottedTracksData.xls'); end

if (eAS == 1) exportData(name,allSlices,slices,'_allSlicesDataNew.xls'); end
if (eFS == 1) exportData(name,filteredSlices,sliceNum,'_filteredSlicesData.xls'); end
if (ePS == 1) exportData(name,plottedSlices,sliceNum,'_plottedSlicesData.xls'); end

% FUNCTION: exporting data out, works for Tracks and Slices
function exportData(name,Data,loopNum,exportFileName)
    fileOutName = strcat(name,exportFileName);
    topLine = ['Slice Number','Track ID','X','Y','X_IJ','Y_IJ','Individual Distance','Invididual Angle','Accumulated Distance','Speed','Euclidian Distance','Runs/Tumbles','Runs Percent','Angles','Directionality','X FMI','Y FMI','VectorPolar: Distance','VectorPolar: Angle','VectorCartesian: X','VectorCartesian: Y'];
    for i = 1:loopNum % only exporting data that is being plotted
        writematrix(topLine,fileOutName,'sheet',i,'Range','A1:O1');
        writematrix(Data(i).all,fileOutName,'sheet',i,'Range','A2');
    end
end

% FUNCTION: Converting Track objects to Slice objects
% Parameters: pass in a Track list, number of tracks in that list, and the
% number of slices in that list
function SliceList = tracks2Slices(TrackList,trackNum,sliceNum)
    SliceList = Slice.empty(0,sliceNum);
    for j = 1:sliceNum
        sliceData = zeros(trackNum,21); % 21 pieces of data
        for i = 1:trackNum
            sliceData(i,:) = TrackList(i).all(j,:);
        end
        temp_slice = Slice(sliceData);
        SliceList(j) = temp_slice;
    end
end
