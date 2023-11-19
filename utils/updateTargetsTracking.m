
function [targets,id_cnt] = updateTargetsTracking(targets,cor,det_label,dt,th,id_cnt,target_struct)
    target = target_struct;
    no_match = 1;
    % Assign First target
    if isempty(targets)
        target.tracker =  myKalmanFilter(dt,[cor';0;0.1],[0;0],0.5,0.01,0.01);
        target.id = id_cnt;
        id_cnt =id_cnt+1;
        targets = [targets,target];
    else
    % Assign to closest target
        for ix=1:length(targets)
            dist = pdist2(targets(ix).tracker.x(1:2)',cor);
            if dist < th
                targets(ix).last_pos = targets(ix).tracker.x;
                targets(ix).tracker=targets(ix).tracker.update(cor');
                targets(ix).label = det_label;
                targets(ix).updated = 1;
                targets(ix).missing=0;
                no_match = 0;
            end
        end
    end
    % Create New target if no match was found
    if no_match
        target.tracker =  myKalmanFilter(dt,[cor';0;-0.1],[0;0],1.0,0.1,0.1);
        if ~isempty(targets)
            target.id = id_cnt+1;
            id_cnt = id_cnt+1;
        else
            target.id =1;   
        end
        targets = [targets,target];
    end

    % Merge similar targets
    if ~isempty(targets)
        mergedTargets = targets(1); % Start with the first structure
        for i = 2:numel(targets)
            foundSimilar = false;
            for j = 1:numel(mergedTargets)
                dist = pdist2(targets(i).tracker.x(1:2)',targets(j).tracker.x(1:2)');
                if dist<th
                    foundSimilar = true;
                    break;
                end
            end
            if ~foundSimilar
                mergedTargets(end+1) = targets(i);
            end
        end
    end
    targets = mergedTargets;
    disp("currently tracking "+num2str(length(targets))+ " targets")
end
