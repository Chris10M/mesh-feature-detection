% function main
clc;
% basic interface

% mesh_file = 'samplemeshes\sphere_dense.off';
% mesh_file = 'samplemeshes\sphere_coarse.off';
mesh_file = 'samplemeshes/torus.off';

[vertices, faces] = loadmesh(mesh_file);
vertices = vertices.';
%     vertices = (vertices+randn(size(vertices))).'; %noise
faces = faces.';

A_mixed = calc_A_mixed(vertices, faces);

K_H = get_mean_curvature(vertices, faces, A_mixed);
K_G = get_gaussian_curvature(vertices, faces, A_mixed);
[K_1, K_2 ]= get_principal_curvatures(K_H, K_G);

disp(sum(K_G));
disp(sum(K_H));
disp(sum(K_1));
disp(sum(K_2));

options.face_vertex_color = K_G;
figure()
plotmesh(vertices, faces, options); colorbar;
title("Gaussian curvature",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';

% figure()
% histogram(K_G,32);
% title("Gaussian curvature histogram",'FontSize', 16);


options.face_vertex_color = K_H;
figure()
plotmesh(vertices, faces, options); colorbar;
title("Mean curvature",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';

% figure()
% histogram(K_H,32);
% title("Mean curvature histogram",'FontSize', 16);


options.face_vertex_color = K_1;
figure()
plotmesh(vertices, faces, options); colorbar;
title("First principal curvature",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';

% figure()
% histogram(K_1,32);
% title("First principal curvature histogram",'FontSize', 16);


options.face_vertex_color = K_2;
figure()
plotmesh(vertices, faces, options); colorbar;
title("Second principal curvature",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';

% figure()
% histogram(K_2,32);
% title("Second principal curvature histogram",'FontSize', 16);



%% "Ridges" (noise and anisotropic smoothing)
% Load everything:
mesh_file = 'samplemeshes/fandisk.off';
noiseScale = 0.01;
noiseRatio = 50;

[vertices, faces] = loadmesh(mesh_file);
verticesClean = vertices.';
temp = randi(100,1,size(vertices,2)); rI = temp;
rI(temp>noiseRatio) = 0; rI(temp<=noiseRatio) = 1;
rI = [rI; rI; rI];
vertices = (vertices+randn(size(vertices)).*rI*noiseScale).'; %noise
faces = faces.';

figure()
plotmesh_lighting(verticesClean, faces);
title("Original Mesh",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';

figure()
plotmesh_lighting(vertices, faces);
title("Noisy Mesh",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';


A_mixed = calc_A_mixed(vertices, faces);

K_H = get_mean_curvature(vertices, faces, A_mixed);
K_G = get_gaussian_curvature(vertices, faces, A_mixed);
[K_1, K_2 ]= get_principal_curvatures(K_H, K_G);


% weights for the theoretical smoothing
w = zeros(size(K_H));

% parameter defining edges
T=0.5;

abs_K_1 = abs(K_1);
abs_K_2 = abs(K_2);
abs_K_H = abs(K_H);
min_K = min(min(abs_K_1,abs_K_2),abs_K_H);

cond1 = min_K == abs_K_1;
cond2 = min_K == abs_K_2;
cond3 = min_K == abs_K_H;

% edges
w(cond1) = K_1(cond1)./K_H(cond1);
w(cond2) = K_2(cond2)./K_H(cond2);
% rest (noise)
w(cond3) = 1;

for i = 1:size(w)
    if abs_K_1(i)<=T && abs_K_2(i)<=T % noise
        w(i) = 1;
    elseif abs_K_1(i)>T && abs_K_2(i)>T && (K_1(i)*K_2(i))>0 % neither edge nor noise
        w(i) = 0;
    end
end

figure()
options.face_vertex_color = w;
plotmesh(vertices, faces, options); colorbar;
title("Smoothing factor",'FontSize', 16);
zoom(2); ax = gca; ax.Clipping = 'off';
    



%% Classification - getting the histograms
clc;

base_path = 'samplemeshes/';

fileList = dir(append(base_path, '*.off'));

hists = zeros(size(fileList,1),256);
for k = 1:size(fileList,1)
    file_name = fileList(k).name;
    file_path = append(base_path, file_name);

    fprintf(1, 'Now reading %s\n', file_name);

    hists(k,:) = extract_mesh_feature(file_path);
end

%% Classification - Comparing histograms
clc;
% Distance mode
d = 1;
%select one random model
index = 1;
% index = randi([1,size(hists,1)]);

fprintf(1, 'Selected %s\n\n', fileList(index).name);
currentH = hists(index);

dists = zeros(size(hists,1),1);
for k = 1:size(hists,1)
    distance = ws_distance(currentH, hists(k),d);
    dists(k) = distance;
    fprintf(1, 'Comparing %s with %s, distance: %f\n', fileList(index).name, fileList(k).name,distance);
end

% best match
[mv, mi] = min(dists);

fprintf(1, '\nBest match with %s, distance: %f\n', fileList(mi).name, mv);


%% Classification - every comparison + Noise
clc;
% Distance mode
d = 1;
% percentage of faces maintained
pertPer = 100;

%Obtaining Noisy histograms
noisyHists = zeros(size(fileList,1),256);
for k = 1:size(fileList,1)
    file_name = fileList(k).name;
    file_path = append(base_path, file_name);
    fprintf(1, 'Now reading %s\n', file_name);
    noisyHists(k,:) = extract_mesh_feature(file_path, false, true, pertPer);
end

clc;

correct = 0;
CompleteDistances = zeros(size(hists,1));
for i = 1:size(noisyHists,1)
    
    currentH = noisyHists(i);
    
    for j = 1:size(hists,1)
        CompleteDistances(i,j) = ws_distance(currentH, hists(j),d);
    end
    
    % best match
    [mv, mi] = min(CompleteDistances(i,:)');
    fprintf(1, '%s best match: %s, distance: %f',fileList(i).name, fileList(mi).name, mv);
    if strcmp(fileList(i).name,fileList(mi).name)
        correct = correct+1;
        fprintf(1, ' Correct!');
    end
    fprintf(1, '\n');
end

fprintf(1, '\nCorrect guesses: %i\n',correct);


% disp(CompleteDistances)

%% Show perturbated mesh
pert_file_path = 'samplemeshes/pig.off';
extract_mesh_feature(pert_file_path, true); title("Original mesh");
extract_mesh_feature(pert_file_path, true, true, 90); title("Corrupted mesh");

%% Classification into groups

Categories = ["Sphere", "Cube", "Torus"]';
CatFiles = ["sphere.off","cube_tri.off","torus.off"]';

fprintf(1,'\n');
CatHists = zeros(size(Categories,1),256);
for k = 1:size(Categories,1)
    file_path = append(base_path, CatFiles(k));
    CatHists(k,:) = extract_mesh_feature(file_path);
end

distances = zeros(size(CatHists,1),1);
for i = 1:size(hists,1)
    for j = 1:size(CatHists,1)
        distances(j) = ws_distance(hists(i), CatHists(j),d);
    end
    [mv, mi] = min(distances);
    fprintf(1, '%s classified as %s, distance: %f\n', fileList(i).name,Categories(mi), mv);
end
    