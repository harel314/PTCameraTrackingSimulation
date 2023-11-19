% Create a figure
function pt_set = drawCar(carWidth,carLength1,carHeight1,color,pos)
% Car body
% Define car body points
% Car body
carLength2 = 0.5; % Shorter cube
carHeight2 = 0.5; % Shorter cube
carLength = carLength1+carLength2;

% Define car body points
carBody1 = [
    0, 0, 0;
    0,carWidth,0;% Front-left corner
    0, 0, carHeight1;       % Front-left corner (top)
    0, carWidth, carHeight1; % Back-left corner (top)
    carLength1-0.5, 0, carHeight1;% Front-right corner (top)
    carLength1-0.5, carWidth, carHeight1; % Back-right corner (top)
    
];

carBody2 = [
 
    carLength2, 0, 0;       % Front-right corner
    carLength2, carWidth, 0; % Back-right corner
    0, 0, carHeight2;       % Front-left corner (top)
    0, carWidth, carHeight2; % Back-left corner (top)
    carLength2, 0, carHeight2;% Front-right corner (top)
    carLength2, carWidth, carHeight2; % Back-right corner (top)
    -0.5,0,0; % Middle Right
    -0.5,carWidth,0; %Middle Left
    
]+repmat([carLength1, 0, 0],8,1);

carBody = [carBody1;carBody2]+[0,0,0.15]+pos;
faces = [
    1, 2, 8;    %bottom
    1,7,8;
    1, 2, 4;    %back
    1,3,4;
    9, 10, 12;    % top front face
    9,11,12;
    11, 12, 8;    %front
    11,7,8;
    4,2,14;
    4,6,14;
    3,1,13;
    3,5,13;
    5,7,13;
    6,8,14;
    10,8,12;
    9,7,11;
    5, 6, 10;    % shield
    5,9,10;
    3, 4, 6;   % top back face
    3,5,6;
    
];
%%%%%

% Visualize the point cloud
pt_set = [];
for ix = 1:length(faces)
    vs = carBody(faces(ix,:),:);
    g = faceGrid(vs(1,:),vs(2,:),vs(3,:));
    if all((faces(ix,:) == [5,6,10]) | (faces(ix,:) == [5,9,10]))
        c = zeros(length(g),3);
        g = [g,c];
    else
        c = color.*ones(length(g),3);
        g = [g,c];
    end
    pt_set = [pt_set;g];
    % 5,9,10;
% pt_set = [pt_set;faceGrid(vs(1,:),vs(2,:),vs(3,:)),0.7,0.7,0.7];
end

%%%%%%
% Define wheel positions
wheelRadius = 0.15;
wheelWidth = 0.1;

wheel1 = [wheelRadius, wheelRadius, 0.15]+pos;                   % Front-left wheel
wheel2 = [carLength - wheelRadius, wheelRadius, 0.15]+pos;       % Front-right wheel
wheel3 = [carLength - wheelRadius, carWidth - wheelRadius-wheelWidth, 0.15]+pos; % Back-right wheel
wheel4 = [wheelRadius, carWidth - wheelRadius-wheelWidth, 0.15]+pos;       % Back-left wheel


%wheels
[x1, y1, z1] = cylinder(wheelRadius, 20);
z1 = z1 * wheelWidth;
surf(x1 + wheel1(1), z1 + wheel1(2), y1 + wheel1(3), 'FaceColor', 'k', 'EdgeColor', 'none'); % Front-left wheel

[x2, y2, z2] = cylinder(wheelRadius, 20);
z2 = z2 * wheelWidth;
surf(x2 + wheel2(1), z2 + wheel2(2), y2 + wheel2(3), 'FaceColor', 'k', 'EdgeColor', 'none'); % Front-right wheel

[x3, y3, z3] = cylinder(wheelRadius, 20);
z3 = z3 * wheelWidth;
surf(x3 + wheel3(1), z3 + wheel3(2), y3 + wheel3(3), 'FaceColor', 'k', 'EdgeColor', 'none'); % Back-right wheel

[x4, y4, z4] = cylinder(wheelRadius, 20);
z4 = z4 * wheelWidth;
surf(x4 + wheel4(1), z4 + wheel4(2), y4 + wheel4(3), 'FaceColor', 'k', 'EdgeColor', 'none'); % Back-left wheel
%% AID FUNCTIONS %%
% Given vertices of a triangle in 3D space
function pts = faceGrid(v1,v2,v3)

% Number of points on each side of the triangle
numPoints = 20;

% Generate coordinates for a regular grid on the triangle's surface
u = linspace(0, 1, numPoints);
v = linspace(0, 1, numPoints);

[uGrid, vGrid] = meshgrid(u, v);

% Ensure the points lie within the bounds of the triangle
mask = uGrid + vGrid <= 1;
uGrid = uGrid(mask);
vGrid = vGrid(mask);

% Convert barycentric coordinates to Cartesian coordinates
wGrid = 1 - uGrid - vGrid;
xGrid = uGrid * v1(1) + vGrid * v2(1) + wGrid * v3(1);
yGrid = uGrid * v1(2) + vGrid * v2(2) + wGrid * v3(2);
zGrid = uGrid * v1(3) + vGrid * v2(3) + wGrid * v3(3);
pts = [xGrid(:), yGrid(:), zGrid(:)];
% Create a point cloud

end


end

