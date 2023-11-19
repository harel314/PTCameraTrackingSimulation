function [XI,YI,ZI,xI,yI,zI,wI,qcI] = CameraFov(CI,w,h,f,S)
q_points_B =  [[w/2;h/2;f],[w/2;-h/2;f],[-w/2;-h/2;f],[-w/2;h/2;f],[0;0;f]];
xI =[];
yI =[];
zI =[];
wI = [];
rho14 = -CI(3)/ ((h/2)*sin(S(2))+f*cos(S(2)));
rho23 = -CI(3)/ (-(h/2)*sin(S(2))+f*cos(S(2)));
for ix=1:4
    q = BodyToWorld(q_points_B(:,ix),S(2),S(1));
    qb = q+CI;
    xI = [xI;qb(1)];
    yI = [yI;qb(2)];
    zI = [zI;qb(3)];
    if ix == 1 || ix ==4
        wI = [wI,rho14*q+CI];
    else
        wI = [wI,rho23*q+CI];
    end
end

qcI = BodyToWorld(q_points_B(:,5),S(2),S(1))+CI;
si = scatteredInterpolant(xI,yI,zI);
[XI,YI]=meshgrid(xI,yI);
ZI = si(XI,YI);


end

