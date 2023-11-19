function img = plotDetections(img,bboxes,scores,labels)
    colors = [];
    for ix =1:length(labels)
        str = string(getColor(labels(ix)));
        colors = [colors,str];
    end
    %bbox is [x,y,width,height] where (x,y) is the top right corner of the
    if(~isempty(bboxes))
        % combine lables with scores: [string(labels)+":"+num2str(scores,3)]
        img = insertObjectAnnotation(img,'rectangle',bboxes,"",LineWidth=1, ...
            Color=colors);
    end
end