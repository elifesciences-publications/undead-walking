% This script loads walking traces from .csv files, centres them to 0,
% plots them together and saves the image as an .eps file in the current
% folder

clear;
clearvars;
close all;

%% user-input variables

% scale image to real size
dist = 18; % because 1 mm = 18 pixels

% choose a figure title
figTitle = 'centred_traces';

%% load data

% choose files to analyse
inputFolder = uigetdir('','Find centroid data folder');
fileList = uigetfile('*.csv', 'MultiSelect','on'); % select files with centroid traces to plot together

% number of files
nFiles = length(fileList);
 
% import the data
walkingCods = cell(1,nFiles);
for i = 1:nFiles
    walkingCods{1,i} = readmatrix([inputFolder,'/',fileList{1,i}]);
end

%% centre the data

% loop through, take the start coordinate and subtract it from all cods
centredCods = cell(1,nFiles);
for i = 1:nFiles
    cods = walkingCods{1,i}...
        -repmat(walkingCods{1,i}(1,:),size(walkingCods{1,i},1),1);
    cods = cods/dist; % scale to real size
    centredCods{1,i} = cods;
end

%% plot centred data together and save image 

% choose a colourmap
cmap = colormap(hot(nFiles*2));

% loop through and plot
figure,
hold on
title(figTitle)
for i = 1:nFiles
   p = plot(centredCods{1,i}(:,1),centredCods{1,i}(:,2),...
        'color',cmap(i,:),'LineWidth',0.5)
end
xlabel 'X (mm)'
ylabel 'Y (mm)'
set(gca,'FontSize',25)
set(gca,'LineWidth',2)
grid on
axis square
xticks(-5:5:5)
yticks(-5:5:5)
ax = gca;

labelsx = string(ax.XAxis.TickLabels); % extract labels
labelsx(2:2:end) = nan; % remove every other one
ax.XAxis.TickLabels = labelsx; % replace X axis labels 
c = ax.LineWidth;
ax.LineWidth = 0.25;

labelsy = string(ax.YAxis.TickLabels); % extract labels
labelsy(2:2:end) = nan; % remove every other one
ax.YAxis.TickLabels = labelsy; % replace Y axis labels 
c = ax.LineWidth;
ax.LineWidth = 2;

hold off

% save plot as an eps image in current folder
print(figTitle,'-depsc','-r300'); 