function PandT = getAngle(z,S,f,CI)
%=============================================================================%
% This function takes the current pixel from the virtual frame and given
% the camera intrinsics it calculates the angle between the real target and
% the camera. 
%=============================================================================%
px = z(1);
py = z(2);
pz = CI(3);

p = [px,py];
q = pz*[px/f;py/f;1];
r = BodyToWorld(q,S(2),S(1));
xT = r+CI;

pan = pi/2 + atan2(xT(2),xT(1));
tilt = pi/2 + atan2(4,sqrt(xT(1)^2+xT(2)^2));
PandT = [pan; tilt];

end

