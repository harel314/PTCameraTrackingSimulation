%%
clear, clc, close all; 
%% setup 

CI = [0.2; 0.3; 0.6];  % camera origin frame
f = 0.2; %focal length
w = 1.28; %width resolution
h = 0.76; % height resolution
S = [0; pi-pi/36; 0 ; 0]; % [ psi; phi; psi_dot ;phi_dot] 
Tc = [0;0]; % target origin
Tc_v = [0;0];
TIs = createDiamond(Tc,0.2); % create diamond target
rTVs = CameraMeasurements(TIs,Tc_v,CI,f,S);
[XI,YI,ZI,xI,yI,zI,wI,qcI] = CameraFov(CI,w,h,f,S);

figure(1);
clf
subplot(121)
hold on
scatter3(CI(1),CI(2),CI(3));
plot3([CI(1),qcI(1)],[CI(2),qcI(2)],[CI(3),qcI(3)])

fill3(wI(1,:),wI(2,:),wI(3,:),'r','FaceAlpha',0.3)
% plot3([CI(1), TI(1)], [CI(2), TI(2)], [CI(3), TI(3)], 'r', 'LineWidth', 2); % Line plot
plotFOV(CI,Tc,TIs,xI,yI,zI,wI)
%add floor
[xf, yf] = meshgrid(-2:0.1:2); % Generate x and y data
zf = zeros(size(xf, 1)); % Generate z data
surf(xf, yf, zf,'FaceAlpha',0.5) % Plot the surface

hold off
view(45,45)
xlabel("x",'Interpreter','latex','FontSize',13)
ylabel("y",'Interpreter','latex','FontSize',13)
zlabel("z",'Interpreter','latex','FontSize',13)
title("(a)")
subplot(122)
hold on
scatter(rTVs(1,5),rTVs(2,5))

fill(rTVs(1,1:4),rTVs(2,1:4),'b','FaceAlpha',0.3)
xlim([-w/2,w/2])
ylim([-h/2,h/2])
set(gca,'xtick',[])
set(gca,'ytick',[])
xlabel("x",'Interpreter','latex','FontSize',13)
ylabel("y",'Interpreter','latex','FontSize',13)
title("(b)")
hold off

%% ================== main simulation ========================== %%
f = 0.2; %focal length
w = 1.28; %width resolution
h = 0.76; % height resolution
CI = [0; 0; 0.6];  % camera origin frame
Tc = [0;0]; % target origin
Tc_v = [-0.003;0.003]; % target speed for straight walking
Tf = 8;
dt = 0.1;
b1 = pi/180*100;
b2 = pi/180*100;
psi_l = pi/180*100;
phi_l = pi/180*100;
A_mat = A(dt);
B = [0 0;
     0 0;
     b1 0;
     0 b2];
u = [0;0];
S = [3*pi/4; pi; 0; 0 ];%initial 

k=1;
Stot = [];
u_accumulated = zeros(2,1);
v = VideoWriter('hidden2.avi');
v.FrameRate = 10;
open(v);
u_tot = [];
e = [];
at = 1;
random_err = randi(Tf-1);
thetas = linspace(0,2*pi,length(0:dt:Tf));
for t = 0:dt:Tf
    figure(3)
    clf
    theta = thetas(k); %circling
    % Random walk
    % theta = rand(1)*2*pi;
    Tc_v = 0.006 * [cos(theta);sin(theta)];
    if t > random_err && t<(random_err+1)
        disp("camera shutdown")
        at = at+1;
    else
        Tc = Tc + Tc_v*at*t;
        at = 1;
    end
    subplot(121)
    hold on
    TIs = createDiamond(Tc,0.2); % create diamond target
    rTVs = CameraMeasurements(TIs,Tc_v,CI,f,S);
    [u,e] = PID(rTVs(:,5),S,dt,u,u_accumulated,b1,b2,f,CI,e);
    u_accumulated =u_accumulated + u;
    u_tot = [u_tot,u];
    [XI,YI,ZI,xI,yI,zI,wI] = CameraFov(CI,w,h,f,S);

    if t < random_err || t > (random_err+1)
        fill3(wI(1,:),wI(2,:),wI(3,:),'r','FaceAlpha',0.3)
    end
    plotFOV(CI,Tc,TIs,xI,yI,zI,wI)
    scatter3(CI(1),CI(2),CI(3));
    %add floor
    [xf, yf] = meshgrid(-2:0.1:2); % Generate x and y data
    zf = zeros(size(xf, 1)); % Generate z data
    surf(xf, yf, zf,'FaceAlpha',0.5) % Plot the surface
    hold off
    view(45,45)
    xlabel("x",'Interpreter','latex','FontSize',13)
    ylabel("y",'Interpreter','latex','FontSize',13)
    zlabel("z",'Interpreter','latex','FontSize',13)
    title("(a)")
    subplot(122)
    draw = true;
    if t > random_err && t<(random_err+1)
        draw = false;
    end
    hold on
    
    for ix = 1:size(rTVs,2)
        rTV = rTVs(1:2,ix);
        x_out = false;
        y_out = false;
        if rTV(1)> w/2 || rTV(1) < -w/2
            x_out = true;
        end
        if rTV(2)> h/2 || rTV(2) < -h/2
            y_out = true;
        end
        if x_out && y_out
            draw = false;
        end
    end
    if draw
        if size(rTVs,2) == 1
        scatter(rTVs(1),rTVs(2))
        else
        fill(rTVs(1,1:4),rTVs(2,1:4),'b','FaceAlpha',0.3)
        end
    end
    hold off
    xlabel("x",'Interpreter','latex','FontSize',13)
    ylabel("y",'Interpreter','latex','FontSize',13)
    title("(b)")
    xlim([-w/2,w/2])
    ylim([-h/2,h/2])
    frame = getframe(gcf) ;
    drawnow
    writeVideo(v,frame);
    oldS = S;

    S = A_mat*S+B*u;
    S = BoundTest(S,psi_l,phi_l);
    Stot = cat(2,Stot,S);
    k=k+1;
end
close(v);
figure;
subplot(121)
plot(u_tot(1,:))
hold on
plot(u_tot(2,:))
legend(["Voltage Level 1","Voltage Level 2"])
title("Voltage levels",'Interpreter','latex')
xlabel("t[s]",'Interpreter','latex','FontSize',13)
ylabel("voltage[V]",'Interpreter','latex','FontSize',13)
grid("on")
xlim([0,Tf/dt])
ylim([-1.1,1.1])
subplot(122)
plot(e(1,:))
hold on
plot(e(2,:))
grid("on")
legend(["\psi error","\phi error"])
title("errors",'Interpreter','latex')
xlabel("t[s]",'Interpreter','latex','FontSize',13)
ylabel("error[rad]",'Interpreter','latex','FontSize',13)