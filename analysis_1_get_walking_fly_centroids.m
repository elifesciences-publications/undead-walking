% This script loads .mp4 videos of individual walking flies, extracts the
% body centroid from each frame, saves its XY coordinates as a .csv file
% and saves a grayscale .avi movie at 1 fps for each fly with the centroid
% marked as a red circle

clear;
clearvars; 
close all;

%% user-input variables

% select beginning and end of movie
startFrame = 1; 
stopFrame = 1250;

% specify standard deviation to use for 2-D Gaussian smoothing
sigma = 4;

% to establish which n-th frame to take for saving the tagged fly as avi with centroid
divFactor = 25;

%% load data

% opens GUI to select MP4 videos from which to extract centroids
inputFolder = uigetdir('','Find walking data folder');
fileList = uigetfile('*.MP4','MultiSelect','on');

% number of files
nFiles = length(fileList);


%% extract walking trace

%create vector to store XY centroid coordinates in
centroids = zeros([stopFrame 2]);

for i=1:nFiles

inputFile = ([inputFolder,'/',fileList{1,i}]);
[path, name] = fileparts(inputFile);

flyVideo = VideoReader(inputFile);
fps = flyVideo.FrameRate;
video_rows = flyVideo.Height;
video_columns = flyVideo.Width;

%create array to store flybody and taggedFly in
taggedFly = zeros([video_rows video_columns 1 stopFrame]); 


% user-established threshold to generate binary image
currentFrame = read(flyVideo, 1); % takes 1st frame of movie
grayFrame = rgb2gray(currentFrame); % converts frame from rgb to grayscale
grayFrame_adapthisteq = adapthisteq(grayFrame); % enhances contrast
blurFrame = imgaussfilt(grayFrame_adapthisteq, sigma); % applies 2-D Gaussian smoothing with standard deviation sigma

figure, % plots smoothed image; requires user input: use the Figure Tool 'Data Tips' to identify a good threshold
hold on
imshow(blurFrame)
title('Find threshold on smoothed image')
pause;
thresh = input('set threshold '); % requires user input: type desired threshold in Command Window

% loop through movie and find centroid
for k = startFrame : stopFrame
    
    currentFrame = read(flyVideo, k); % takes each frame of movie
    grayFrame = rgb2gray(currentFrame); % converts frame from rgb to grayscale
    grayFrame_adapthisteq = adapthisteq(grayFrame); % enhances contrast
    blurFrame = imgaussfilt(grayFrame_adapthisteq, sigma); % applies 2-D Gaussian smoothing with standard deviation sigma
     
    % detect fly body and store it in array 
    threshBinay = imbinarize(blurFrame, thresh); % applies user-established threshold
    binaryMask1 = threshBinay == 0; % creates mask for fly body
    binaryMask = imfill(binaryMask1,'holes'); % fills holes in mask
    flybody = imclearborder(binaryMask); % excludes fly body connected to image border
   
    % get centroid 
    measurements = regionprops(flybody, {'Centroid'});
    centroids(k,1) = measurements.Centroid(1);
    centroids(k,2) = measurements.Centroid(2);  
    
    % store grayscale image of fly with marked centroid to use for screening later
    taggedFly(:,:,:,k) = grayFrame_adapthisteq;
    taggedFly(round(centroids(k,2)), round(centroids(k,1)),:,k) = 255; %replace centroid with white pixel
    
       
end

% saves centroid coordinates in csv file with same name as video
name_csv = strcat(name, '.csv');
writematrix(centroids,name_csv);

% check if centroid trace was extracted well
figure,
plot(centroids(:,1), centroids(:,2), 'k.-')
xlabel 'X'
ylabel 'Y'
pause; % requires user input: press any key to continue

% save tagged fly as avi with centroid marked as red dot
answer = input('save video with centroid? 1=yes/0=no '); % requires user input

if answer == 1     
    name_avi = strcat(name, '_1fps_centroid');
    v = VideoWriter(name_avi);
    v.FrameRate = fps/divFactor;

    open(v)
    for k = startFrame:divFactor:stopFrame
    img = uint8(taggedFly(:,:,k)); 
    img = insertShape(img,'FilledCircle',[round(centroids(k,1)) round(centroids(k,2)) 3], 'Color', 'red'); % draws red circle for centroid
    figure,
    imshow(img);
    xlim([0 video_rows])
    ylim([0 video_columns-1])
    drawnow
    F(k)= getframe(gca); 
    writeVideo(v, F(k));
    end 
    close(v)
   	 
else
    answer == 0
   clear all;
   close all;
      


clearvars -except inputFolder fileList nFiles;
close all;
end  	
