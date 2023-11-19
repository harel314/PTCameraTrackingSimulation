addpath("utils")
radius = 0.5; 

% Number of points
num_points = 100;

theta = linspace(0, 2*pi, num_points);
x_circle = radius * cos(theta); 
y_circle = radius * sin(theta); 

x_init = [x_circle(:,1);y_circle(:,1);0;0];
kf1 = myKalmanFilter(1/num_points*2,x_init,[0;0],1,0.001,0.001);

states = zeros(num_points,4);
for ix = 1:num_points
    
    kf1 = kf1.predict();
    if mod(ix,3) == 0
        kf1 = kf1.update([x_circle(:,ix);y_circle(:,ix)]);
    end
    states(ix,:) = kf1.x;
end
%%
% Plot circle trajectory
figure;
plot(x_circle, y_circle, 'b','LineWidth',3);
hold on
plot(states(:,1),states(:,2),'-or')
scatter(states(1,1),states(1,2),'filled','g');
hold off
grid;
legend(["True Traj","KF estimation","X initial"],'Interpreter','latex','FontSize',13);
xlabel('X-axis','Interpreter','latex','FontSize',13);
ylabel('Y-axis','Interpreter','latex','FontSize',13);
xlim([-1.2,1.2]);
ylim([-1.2,1.2]);