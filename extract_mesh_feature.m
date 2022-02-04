function histograms = extract_mesh_feature(file_name)


[vertices, faces] = loadmesh(file_name);
vertices = vertices.';
faces = faces.';

% Center model
vertices = vertices() - mean(vertices);
% vertices = vertices()/max(abs(vertices(:)));

A_mixed = calc_A_mixed(vertices, faces);

K_H = get_mean_curvature(vertices, faces, A_mixed);
K_G = get_gaussian_curvature(vertices, faces, A_mixed);
[K_1, K_2 ]= get_principal_curvatures(K_H, K_G);


n_features = 128;

[hist1, x1] = hist(K_1, n_features);
[hist2, x2] = hist(K_2, n_features);

% METHOD 1: DIVIDE BY SUM
hist1 = hist1/sum(hist1);
hist2 = hist2/sum(hist2);

% METHOD 2: DIVIDE BY AREA
% hist1 = hist1/trapz(x1, hist1);
% hist2 = hist2/trapz(x2, hist2);


histograms = [hist1, hist2];

end

