function UniversalFileConvert
%This code written for the purpose of creating a code capeable of
%efficiently intaking and converting imaris data to the standard matlab
%format
%Zachary Neronha: Modification History
%Version 1.0 09:23 7 August 2017 Basic Functionality
%Version 1.1 11:56 7 August 2017 Scaling option added
%Version 2.0 14:13 7 August 2017 Branched for 10x experiment functionality
%only
% [2:6 19:23 26:30 43:47 50:54 67:71 74:78 91:95

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOTE TO THE USER: While most of the code is designed to run by itself, the
%input file paths present a slightly different issue, and will need to be
%changed manually for each dataset
%Furthermore the user should take care to upload the POSITION and VELOCITY
%files for the 10x experiments and Vesicles_Nuclei_Position and
%Vesicles_Nuclei_Velocity for the 20x experiments

%Basic Variables to Save: X,Y positions and Velocities
%[2:6 19:23 26:30 43:47 50:54 67:71 74:78 91:95]


clearvars
close all
clc

%select an output folder
outputfolder = uigetdir('Z:\ENG_BBCancer_Shared','Where would you like to store the converted data?');
%select wells to process
prompt = 'What wells would you like to process?\n';
wells = input(prompt);
%name the outputfiles
prompt = 'What name handle would you like to use? (Well(number).mat will be added automatically)\n (enter inside single quotes)\n';
outputname = input(prompt);
% %get dimensions to load
% prompt = 'Enter sequentially in a matrix the column numbers of x position, y position,positionframe trackID position\n,xVelocity y velocity,velocity frame trackID velocity\n';
% dimenstioncheck = input(prompt);
dimensioncheck = [1 2 6 7 1 2 6 7];

%If rescaling is needed determine the ranges
prompt = 'Would you like to rescale the position data? (1(yes) 0 (no))\n';
rescaleID = input(prompt);
if rescaleID == 1
%    prompt = 'Input final x width\n';
%    xbounds = input(prompt);
%    prompt = 'Input final y height\n';
%    ybounds = input(prompt);    
    xbounds = [382 1282];
    ybounds = [252 1152];
    disp('HARD CODED VALUES USED TO SCALE TO 900x900');
end
tic
for well = wells
    
    %CHANGE THE FILE PATHS HERE IF NECESSARY!!!!!!!!!!!!!!%%%%%%%%%%%%%%%%%
    %load the position data
%     filetoload = strcat('Z:\ENG_BBCancer_Shared\group\Zach\Cluster data\EGF (E4) Data\Raw Data\w',...
%         num2str(well),'_Statistics\w',num2str(well),'_Vesicles_Nuclei_Position.csv');
%     data1 = xlsread(filetoload);
% 
%     %load the velocity data
%     filetoload = strcat('Z:\ENG_BBCancer_Shared\group\Zach\Cluster data\EGF (E4) Data\Raw Data\w',...
%         num2str(well),'_Statistics\w',num2str(well),'_Vesicles_Nuclei_Velocity.csv');
%     data2 = xlsread(filetoload);
    



    filetoload = strcat('Z:\ENG_BBCancer_Shared\group\0Zach\OctoberClean\well',...
        num2str(well),'_Statistics\well',num2str(well),'_Position.csv');
    data1 = xlsread(filetoload);

    %load the velocity data
    filetoload = strcat('Z:\ENG_BBCancer_Shared\group\0Zach\OctoberClean\well',...
        num2str(well),'_Statistics\well',num2str(well),'_Velocity.csv');
    data2 = xlsread(filetoload);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %account for the birth/death issue
    if data1(1,7) == 900
        posframes = round(data1(:,dimensioncheck(3)+1)./900);
        velframes = round(data2(:,dimensioncheck(7)+1)./900);
        Xposition = data1(:,dimensioncheck(1));
        Yposition = data1(:,dimensioncheck(2));        
        posTrackID = data1(:,dimensioncheck(4)+1);
        Xvel = data2(:,dimensioncheck(5));
        Yvel = data2(:,dimensioncheck(6));
        velTrackID = data2(:,dimensioncheck(8)+1);
        disp('Converted from Birth Death Mode');
    else
        %relabel and extract as directed by the user
        Xposition = data1(:,dimensioncheck(1));
        Yposition = data1(:,dimensioncheck(2));
        posframes = data1(:,dimensioncheck(3));
        posTrackID = data1(:,dimensioncheck(4));
        Xvel = data2(:,dimensioncheck(5));
        Yvel = data2(:,dimensioncheck(6));
        velframes = data2(:,dimensioncheck(7));
        velTrackID = data2(:,dimensioncheck(8));

    end

    %rescale the data
    posTrackID = (posTrackID-min(posTrackID))+1;
    velTrackID = (velTrackID-min(velTrackID))+1;
    Xposition = Xposition - min(Xposition);
    Yposition = Yposition - min(Yposition);
    
    %get rid of extremely transient cells
    m = isnan(posTrackID) == 0; 
    Xposition = Xposition(m);
    Yposition = Yposition(m);
    posTrackID = posTrackID(m);
    
    if rescaleID == 1
        %determine if the x value violates our bounds
        m = (Xposition < xbounds(1))|(Xposition > xbounds(2))|...
            (Yposition < ybounds(1))|(Yposition > ybounds(2));
        m = ~m; %convert logical operator
        %keep only the values that don't violate our standards
        Xposition = Xposition(m);
        Yposition = Yposition(m);
        Xvel = Xvel(m);
        Yvel = Yvel(m);
        posTrackID = posTrackID(m);
        velTrackID = velTrackID(m);
        posframes = posframes(m);
        velframes = velframes(m);
        
        %rescale the data one final time
        Xposition = Xposition - xbounds(1);
        Yposition = Yposition - ybounds(1);
    end
    
    %now store the data in a convienent format
    storeX = NaN(max(posTrackID),max(posframes));
    storeY = NaN(max(posTrackID),max(posframes));
    storevelX = NaN(max(velTrackID),max(velframes));
    storevelY = NaN(max(velTrackID),max(velframes));
    
   %store the data in the appropriate location
    for columnloop = 1:size(Xposition,1)
       storeX(posTrackID(columnloop),posframes(columnloop)) = Xposition(columnloop); 
       storeY(posTrackID(columnloop),posframes(columnloop)) = Yposition(columnloop); 
       storevelX(velTrackID(columnloop),velframes(columnloop)) = Xvel(columnloop); 
       storevelY(velTrackID(columnloop),velframes(columnloop)) = Yvel(columnloop); 
    end
   
    savename = strcat(outputfolder,'\',outputname,'well',num2str(well),'.mat');
    save(savename,'storeX','storeY','storevelX','storevelY');
    fprintf('Well %d is now complete!\n',well);
    beep
end
toc
disp('CONVERSION COMPLETE');
end