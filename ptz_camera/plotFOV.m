function pyramid_vertices = plotFOV(CI,xI,yI,ZI,wI)

fill3(xI,yI,ZI,'r','FaceAlpha',0.3)
pyramid_vertices = [
    wI(1,1),  wI(2,1),  wI(3,1); % Vertex 1
    wI(1,2),  wI(2,2),  wI(3,2); % Vertex 2
    wI(1,3),  wI(2,3),  wI(3,3); % Vertex 3
    wI(1,4),  wI(2,4),  wI(3,4); % Vertex 4
    CI(1), CI(2), CI(3); % Apex Vertex 5
];

color = [0.8, 0.8, 0.8];
alpha = 0.5;
faces = [
    1, 2, 5; % Base face 1
    2, 3, 5; % Base face 2
    3, 4, 5; % Base face 3
    4, 1, 5; % Base face 4
];

patch('Vertices', pyramid_vertices, 'Faces', faces, 'FaceColor', color, 'FaceAlpha', alpha);

end

