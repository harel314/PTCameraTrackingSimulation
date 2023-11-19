function TIs = createDiamond(Tc,rate)
TIs = [];
TIs(:,1) = [Tc(1)-rate,Tc(2),0]'; %some target in world frame
TIs(:,2) = [Tc(1),Tc(2) + rate,0]'; %some other target in world frame
TIs(:,3) = [Tc(1)+rate,Tc(2),0]'; %some other target in world frame
TIs(:,4) = [Tc(1),Tc(2) - rate,0]';
TIs(:,5) = [Tc',0]';
end

