function histograms = extract_mesh_feature(file_name, display, perturbation, pertRatio)

if nargin<2
    display = false;
end
if nargin<3
    perturbation = false;
end
if nargin<4
    pertRatio = 80;
end


[vertices, faces] = loadmesh(file_name);
vertices = vertices.';
faces = faces.';


%applied if perturbation
if perturbation
    rI = randi(100,size(faces,1),1);
    faces = faces(rI<=pertRatio,:);
end

% Center model
vertices = vertices() - mean(vertices);
% vertices = vertices()/max(abs(vertices(:)));

if display
    figure()
    plotmesh_lighting(vertices, faces);
    title("Mesh",'FontSize', 16);
    zoom(2); ax = gca; ax.Clipping = 'off';
end


A_mixed = calc_A_mixed(vertices, faces);

K_H = get_mean_curvature(vertices, faces, A_mixed);
K_G = get_gaussian_curvature(vertices, faces, A_mixed);
[K_1, K_2 ]= get_principal_curvatures(K_H, K_G);


n_features = 128;

[hist1, x1] = hist(K_1, n_features);
[hist2, x2] = hist(K_2, n_features);

% METHOD 1: DIVIDE BY SUM
% hist1 = hist1/sum(hist1);
% hist2 = hist2/sum(hist2);

% METHOD 2: DIVIDE BY AREA
% hist1 = hist1/trapz(x1, hist1);
% hist2 = hist2/trapz(x2, hist2);


histograms = [hist1, hist2];

% METHOD 3: DIVIDE BY SUM everything
histograms = histograms/sum(histograms);

% METHOD 4: DIVIDE BY AREA everything
% histograms = histograms/trapz([x1,x2], histograms);

end

