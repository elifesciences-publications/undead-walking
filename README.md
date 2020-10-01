# undead-walking
Supporting code for Pop et al., 2020, https://doi.org/10.7554/eLife.59566.

Matlab scripts for extracting centroid coordinates of individual walking flies and plotting them as a trace

The first script loads .mp4 videos of individual walking flies, extracts the body centroid from each frame, saves its XY coordinates as a .csv file and saves a grayscale .avi movie at 1 fps for each fly with the centroid marked as a red circle.

The second script loads walking traces from .csv files, centres them to 0, plots them together and saves the image as an .eps file in the current folder.
