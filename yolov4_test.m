%% Setup
vidReader = VideoReader('res/camera_footage.avi');
load("models/yolov4_det.mat");
detector = trainedDetector;
addpath("utils")
%%
h= figure;
movegui(h);
hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
hPlot = axes(hViewPanel);
k = 0;
c=45;
v = VideoWriter('yolov4.avi');
v.FrameRate = 30;
open(v);
while hasFrame(vidReader)
    
    frameRGB = readFrame(vidReader);
    [bboxes,scores,labels] = detect(detector,frameRGB,'MiniBatchSize',1);
    frame_detected = plotDetections(frameRGB,bboxes,scores,labels);
    imshow(frame_detected)
    writeVideo(v,frame_detected);
    pause(10^-3)
    k = k+1;
    % if k == c
    %     figure(2);
    %     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60)
    % end
end

close(v)