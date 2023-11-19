%% Load training data
load("labeled_data.mat")
[imds,bxds] = objectDetectorTrainingData(gTruth);
cds = combine(imds,bxds);
augmentedTrainingData = transform(cds,@augmentData);
load("classes.mat","Classes")
%% Upload Yolov4 & Find Anchors
yolov4ObjectDetector("tiny-yolov4-coco");
numAnchors = 9;
[anchors, meanIoU] = estimateAnchorBoxes(cds,numAnchors);
area = anchors(:,1).*anchors(:,2);
[~,idx] = sort(area,"descend");
anchors = anchors(idx,:);
anchorBoxes = {anchors(1:3,:);anchors(4:6,:)};
yolov4 = yolov4ObjectDetector("tiny-yolov4-coco",Classes,anchorBoxes);
%% set options
options = trainingOptions("sgdm", ...
    InitialLearnRate=0.0005, ...
    Momentum = 0.9, ...
    MiniBatchSize=16,...
    MaxEpochs=40, ...
    BatchNormalizationStatistics="moving",...
    ResetInputNormalization=false,...
    VerboseFrequency=30);
%% Train 
[trainedDetector,info] = trainYOLOv4ObjectDetector(augmentedTrainingData,yolov4,options);
save yolov4_det.mat trainedDetector
%% Test
img = [];
testImage = imread('test_im.png');
[bboxes, scores, labels] = detect(trainedDetector,testImage,'Threshold',0.5);
colors = [];
for ix =1:length(labels)
    str = string(getColor(labels(ix)));
    colors = [colors,str];
end
%draw boxes
if(~isempty(bboxes))
    img = insertObjectAnnotation(testImage,'rectangle',bboxes,[string(labels)+":"+num2str(scores,3)],LineWidth=1, ...
        Color=colors,FontSize=9);
end
figure(1);
imshow(img);

%% Load validation data
load("validation_data.mat")
[imds,bxds] = objectDetectorTrainingData(gTruth);
cds = combine(imds,bxds);

%% Evaluate AP,RECALL & PRECISION for each class
results = detect(trainedDetector, imds,'Threshold',0.05,'MiniBatchSize',1,'Threshold',0.5);
[ap, recall, precision] = evaluateDetectionPrecision(results, bxds);
figure(2);
for ix= 1:num_classes
    subplot(2,4,ix)
    plot(recall{ix}, precision{ix},"LineWidth",2);
    title(string(detector.ClassNames(ix)) + " Ap = " + num2str(ap(ix)),'Interpreter','latex','FontSize',13)
    xlabel("Recall",'Interpreter','latex','FontSize',13)
    ylabel("Precision",'Interpreter','latex','FontSize',13)
    grid on
    xlim([0,1])
    ylim([0 1])
end