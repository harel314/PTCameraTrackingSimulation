function autoLabels = AutomationFunction(I)

% One-time initialization of the detector. A one-time initialization saves
% time on subsequent runs.
persistent trainedDetector
if isempty(trainedDetector)
    load("yolov4_det.mat");
end
 
% Run the detector on the input image, I.
[bboxes,scores,labels] = detect(trainedDetector,I);
 
% Create and fill the autoLabels structure with the predicted bounding box
% locations. The Name and Type of ROI returned by the automation function
% must match one of the labels defined in the labeling app.
autoLabels = struct("Name",{},"Type",{},"Position",{});
for i = 1:size(bboxes,1)
    autoLabels(i).Name = string(labels(i));
    autoLabels(i).Type = labelType.Rectangle;
    autoLabels(i).Position = bboxes(i,:);
end