%% Setup
vidReader = VideoReader('res/camera_footage.avi');
of = opticalFlowHS;
addpath("utils")

%%
h= figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);
k = 0;
c=45;
v = VideoWriter('optical_flow.avi');
v.FrameRate = 30;
open(v);
while hasFrame(vidReader)
    
    frameRGB = readFrame(vidReader);
    frameGray = im2gray(frameRGB);  
    flow = estimateFlow(of,frameGray);
    
    % get median magnitude:
    
    mags = flow.Magnitude;
    mean_mag = mean(mags(:)) * 6;
    
    % create a binary mask of magnitudes above the average
    % apply Median Filtering to remove scattered noise & 
    % perform Closing operation to remove small holes in blobs
    
    binary_mask = mags > mean_mag;
    median_filtered_mask = medfilt2(binary_mask, [5, 5]);
    se = strel('rectangle', [10, 4]);
    closed_mask = imclose(median_filtered_mask, se);
    
    % find connected components (blobs) in the binary mask
    
    cc = bwconncomp(closed_mask);
    stats = regionprops(cc, 'BoundingBox');
    imshow(frameRGB)
    hold on
    for i = 1:numel(stats)
        % extract the bounding box for the current blob and draw a rectangle around the blob
        bb = stats(i).BoundingBox;
        rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 1);
    end
    hold off
    vid_frame = getframe(gcf) ;
    writeVideo(v,vid_frame);
    pause(10^-3)
    k = k+1;
    % if k == c
    %     figure(2);
    %     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60)
    % end
end

close(v)