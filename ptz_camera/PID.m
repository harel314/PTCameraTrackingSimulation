function [u,e] = PID(z,S,dt,u_prev,u_accumulated,b1,b2,f,CI,e)
%=============================================================================%
% This is an implementation of the PID controller, it calculates the
% difference between the current angle and the pixel angle, and try to
% match between them in order to keep the target on frame.
%=============================================================================%
PandT = getAngle(z,S,f,CI);
PandT(1,1)=mod(PandT(1,1),2*pi);
delpsi = PandT(1,1)-S(1);
delphi=  PandT(2,1)-S(2);

% biasing current error to the current derivative
% and normalizing according to the max voltage
u_now1 = (delpsi/dt - S(3))/b1;
u_now2 = (delphi/dt - S(4))/b2;

u_now=[u_now1 , u_now2]';
e_now=[delpsi , delphi]';
dudt = (u_now - u_prev)/dt;
%add constants
kp1 = 0.6;
kp2 = 0.6;
kd1 = 0.06;
kd2 = 0.05;
ki1 = 0.005;
ki2 = 0.005;

u1 = kp1*u_now(1) + kd1*dudt(1)+ki1*u_accumulated(1);
u2 = kp2*u_now(2) + kd2*dudt(2)+ki2*u_accumulated(2);
e = [e,abs(e_now)];
% saturate the control
u1 = min(1,max(-1,u1));
u2 = min(1,max(-1,u2));
u = [u1;u2];
end

