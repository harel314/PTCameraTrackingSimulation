function rTV = cameraPosMeasurement(TIs,CI,f,S)
rTV=[];
for ix=1:size(TIs,2)
    % get the point
    TI = TIs(:,ix);
    rTI = [TI(1:2);0] - CI;
    qTB = WorldToBody(rTI,S(2),S(1));%qTB = [qx;qy;qz]
    rTV = [rTV,BodyToVirtual(qTB,f)];
end
end

