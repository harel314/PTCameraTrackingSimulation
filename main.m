%% Initiate
clear
close all
clc

addpath("utils");
addpath("models");
addpath("ptz_camera");
if ~exist("./data", 'dir')
    mkdir("data");
end
if ~exist("./res", 'dir')
    mkdir("res");
end
%% PARAMETERS
% ENVIRONMENT
frame_width = 60;
frame_height = 40;
frame_depth = 40;
speed_limit = 5;

% CARS
car = struct('position', [],'velocity',[],'width',[],'height',[],'depth',[], 'color', [],'pts', [],'pts_in',[]);
num_cars = 7; % Number of cars
width = 2;
height = 6;
depth = 2;
color_selection = [0.5,0.5,0.5;0.5,0.0,0.5;0.5,0.5,0.0; ...
    1.,0.,0.;0.,0.,1.;0.,0.5,0.;1.,1.,1.]; % gray,yellow,purple,red,blue,green,white

% CAMERA
CI = [40; 20; 25]; % Center of the camera
f = 9; % Focal length of the camera
w = 12.8; % Width resolution
h = 7.6; % Height resolution
S = [3*pi/2; pi-pi/8; 0 ; 0]; % Initial Position and Velocity [psi; phi; psi_dot ;phi_dot]
                              % Note: 0<psi<2*pi , pi/2<phi<pi
camera_height = 76;
camera_width = 128;

% TRACKING
target = struct('id',[],'tracker',[],'missing',0,'updated',0,'last_pos',[], ...
    'est_vs',[],'mean_v',0.0,'label',[],'violation' , 0);
tracking = 1; % Decides if to activate track or not
id_cnt=1; % Initialize the ID count of the targets
not_assigned_th = 1; % Maximum distance to decide if detection belongs to one
                     % of the already tracked targets or belong to a new target

% SIMULATION
dt = 0.5; % Time step
N = 50; % Number of steps in simulation
vid = 1; % Decide if to save the simulation video or not
vidName = "res/simulation.avi"; % Video name
camera_vid = 1; % Decide if to save the camera footage or not
cameraVidName = "res/camera_footage.avi"; % Camera video name
data_extract = 1; % if bigger then 0 -> will save to data folder some of the camera frames

%% CREATE ENVIRONMENT

[pmX,pmY,pmZ,pmC] = set_platform(frame_width,frame_height);

%% CARS INITIALIZATIONS

areas = sampleNonOverlappingAreas([frame_width,frame_height], [10,10], [8,8]);
cars  =[];
for i = 1:num_cars

    given_area = areas(i,1:2);
    car_position = [given_area,0.];

    cars(i).position = car_position;
    cars(i).color = color_selection(randsample(1:size(color_selection,1),1),:);
    cars(i).height = randi([width,width+1]);
    cars(i).width = randi([height-4,height]);
    cars(i).depth = randi([depth,depth+1]);

    % assign velocities
    if given_area(2) == 31
        cars(i).velocity = [1,0,0];
    elseif given_area(2) ==21
        cars(i).velocity = [2,0,0];
    elseif given_area(2) ==11
        cars(i).velocity = [3,0,0];
    else
        cars(i).velocity = [4,0,0];
    end
end

%% Load network

load models/yolov4_det.mat;
detector = trainedDetector;

%% Simulation
% initialize variable
camera_frames = cell(1, N);
targets_bank = [];
TIs = zeros(num_cars,3);
bboxes = [];
targets = [];
k=1;

% videoWriters

if vid == 1
    v = VideoWriter(vidName);
    v.FrameRate = 10;
    open(v);
end
if camera_vid == 1
    cv = VideoWriter(cameraVidName);
    cv.FrameRate = 30;
    open(cv)
end

% Initiate simulation
for t=1:dt:N*dt
    clf
    figure(1);
    %--------------3D WORLD ---------------%
    subplot(131)
    axis([0 frame_width 0 frame_height 0 frame_depth]);
    for ix = 1:num_cars
        TIs(ix,:) = cars(ix).position;
    end
    [XI,YI,ZI,xI,yI,zI,wI,qcI] = CameraFov(CI,w,h,f,S);
    hold on;
    surf(pmX, pmY, pmZ, 'FaceColor', pmC, 'EdgeColor', 'none');
    pyramid_vertices = plotFOV(CI,xI,yI,zI,wI);
    scatter3(CI(1),CI(2),CI(3));
    % update position
    for i = 1:num_cars
        cars(i).position = cars(i).position+cars(i).velocity*dt;
        cars(i).position(1) = mod(cars(i).position(1),60);
    end
    % draw
    for i = 1:num_cars
        cars(i).pts = drawCar(cars(i).height,cars(i).width,cars(i).depth,cars(i).color,cars(i).position);
        cars(i).pts_in =isCarInFov(cars(i),pyramid_vertices);
        scatter3(cars(i).pts(:,1),cars(i).pts(:,2),cars(i).pts(:,3),1,cars(i).pts(:,4:6),'filled')
    end
    grid()
    hold off;
    view(25,30)

    xlabel("x",'Interpreter','latex','FontSize',13)
    ylabel("y",'Interpreter','latex','FontSize',13)
    zlabel("z",'Interpreter','latex','FontSize',13)
    title("(a)")
    %--------------camera FOV ---------------%
    hSub2 = subplot(132);
    ax = gca;
    ax.Color = pmC;
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    xlim([-w/2,w/2])
    ylim([-h/2,h/2])
    hold on

    for i=1:num_cars
        pts = cars(i).pts(cars(i).pts_in,:);
        if isempty(pts)
            continue
        end
        pts_x = pts(:,1)';
        pts_y = pts(:,2)';
        pts_z  = pts(:,3)';
        ptsFixed = [pts_x;pts_y;pts_z];
        rTV = cameraPosMeasurement(ptsFixed,CI,f,S);
        if isempty(rTV)
            continue
        end
        pts_X = rTV(1,:);
        pts_Y = rTV(2,:);
        scatter(pts_X',pts_Y',[],cars(i).pts(cars(i).pts_in(:),4:6),'filled');
    end

    camera_frame = imnoise(capture(subplot(132),camera_height,camera_width),'poisson');

    if ~isempty(targets)
        for ix =1:length(targets)
            targets(ix).updated = 0;
        end
    end
    %--------------TRACKING ---------------%
    if tracking ==1
        [bboxes,scores,labels] = detect(detector,camera_frame,'MiniBatchSize',1 ...
            ,'Threshold',0.7);

        if (~isempty(bboxes))
            for ix=1:size(bboxes,1)
                idx= bboxes(ix,1:2)+bboxes(ix,3:4)/2;
                [corx,cory] = indexToCoordinate(idx(1), idx(2), w, h, camera_height, camera_width);
                cor = [corx,cory];
                [targets,id_cnt] = updateTargetsTracking(targets,cor,labels(ix),dt,not_assigned_th,id_cnt,target);

            end
        end
        if ~isempty(targets)
            del_ix = [];
            for ix=1:length(targets)
                if targets(ix).updated ~=1
                    targets(ix).last_pos = targets(ix).tracker.x;
                end
                targets(ix).tracker = targets(ix).tracker.predict();
                vel = getVelocity(targets(ix).last_pos(1:2),targets(ix).tracker.x(1:2),S(2),S(1),f,CI,dt);
                targets(ix).est_vs = [targets(ix).est_vs;vel];
                targets(ix).mean_v = mean(targets(ix).est_vs);
                if targets(ix).mean_v(1) > speed_limit
                    disp("Target " + num2str(targets(ix).id) + " classified as " ...
                        + string(targets(ix).label) + " violated the speed limit !!!\n" + ...
                        "detected speed was "+ num2str(targets(ix).mean_v(1)) + " m/s")
                    targets(ix).violation = 1;
                end
                if targets(ix).updated == 0
                    targets(ix).missing = targets(ix).missing+1;
                end
                if targets(ix).missing >= 4
                    del_ix = [del_ix,ix];
                    targets_bank = [targets_bank,targets(del_ix)];
                end
            end
            targets(del_ix) = [];
        end

        for ix=1:length(targets)
            if targets(ix).violation == 0
                scatter(targets(ix).tracker.x(1),targets(ix).tracker.x(2),'cyan','filled')
            else
                scatter(targets(ix).tracker.x(1),targets(ix).tracker.x(2),'magenta','filled')
            end
        end
    end
    %--------------END TRACKING ---------------%
    hold off
    xlabel("x",'Interpreter','latex','FontSize',13)
    ylabel("y",'Interpreter','latex','FontSize',13)
    title("(b)")
    %--------------IMAGE FRAMES ---------------%
    subplot(133)
    if ~isempty(bboxes)
        camera_detected_frame = plotDetections(camera_frame,bboxes,scores,labels);
    else
        camera_detected_frame = camera_frame;
    end
    imshow(camera_detected_frame)
    xlabel("x",'Interpreter','latex','FontSize',13)
    ylabel("y",'Interpreter','latex','FontSize',13)
    ax = gca;
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    title("(c)")
    camera_frames{k} = camera_frame;
    %--------------SAVE FRAMES ---------------%
    if data_extract >= 1
        if mod(k-1,5) ==0
            imwrite(camera_frame,"data/im_"+num2str(k)+ ...
                "_test_"+num2str(data_extract)+".png")
        end
    end
    drawnow;
    %--------------WRITE VIDEOS ---------------%
    if vid == 1
        vid_frame = getframe(gcf) ;
        writeVideo(v,vid_frame);
    end
    if camera_vid == 1
        writeVideo(cv,camera_frame);
    end
    k=k+1;
end
%--------------SAVE ALL TARGETS ---------------%
targets_bank = [targets_bank,targets];
%--------------CLOSE VIDEOS ---------------%
if vid ==1
    close(v)
end
if camera_vid == 1
    close(cv)
end
%% --------------------- LOCAL FUNCTIONS -----------------------------------

function pts_in = isCarInFov(car,pyramid_vertices)
car_points = car.pts;
pts_in = inhull(car_points(:,1:3),pyramid_vertices);
tot_pts_in = sum(pts_in);
percentage_inside_fov = (tot_pts_in / length(car_points)) * 100;
% disp(['Percentage of car points inside FOV: ' num2str(percentage_inside_fov) '%']);
end

function car_points= carToGrid(car)
car_center = car.position;
num_points_x = 50; % Number of points along the X-axis
num_points_y = 50; % Number of points along the Y-axis
num_points_z = 5; % Number of points along the Z-axis

% Create a mesh of points within the car's volume
[x, y, z] = meshgrid(linspace(car_center(1) - car.width/2, car_center(1) + car.width/2, num_points_x), ...
    linspace(car_center(2) - car.height/2, car_center(2) + car.height/2, num_points_y), ...
    linspace(car_center(3), car_center(3) + car.depth/2, num_points_z));
car_points = [x(:), y(:), z(:)];
end

function sampleAreas = sampleNonOverlappingAreas(totalArea, gridSize, sampleSize)

% Calculate the number of grids in each dimension
numGridsX = floor(totalArea(1) / gridSize(1));
numGridsY = floor(totalArea(2) / gridSize(2));

% Initialize the sampled areas array
sampleAreas = [];

% Loop through each grid cell and sample a non-overlapping area
for i = 1:numGridsX
    for j = 1:numGridsY
        % Calculate the starting point of the sampled area within the current grid
        startX = (i - 1) * gridSize(1) + 1;
        startY = (j - 1) * gridSize(2) + 1;

        % Add the sampled area to the result
        sampleAreas = [sampleAreas; [startX, startY, sampleSize(1), sampleSize(2)]];
    end
end

sampleAreas = sampleAreas(randperm(size(sampleAreas, 1)), :);
end

function frame = capture(subplotToCapture,camera_height,camera_width)
frameSize = [camera_height, camera_width];
iframe = getframe(subplotToCapture);
frameData = iframe.cdata;
frame = imresize(frameData, frameSize);
end

function [pmX,pmY,pmZ,pmC] = set_platform(frame_width,frame_height)

% Define the size of the platform
x = linspace(0, frame_width, 100);
y = linspace(0, frame_height, 100);
[pmX, pmY] = meshgrid(x, y);
pmC = [0.7, 0.7, 0.7];
% Define the height of the platform (Z-axis)
pmZ = zeros(size(pmX));
end
