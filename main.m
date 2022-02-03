% function main
    clc;
    % basic interface
    
    % mesh_file = 'samplemeshes\sphere_dense.off';
    % mesh_file = 'samplemeshes\sphere_coarse.off';
    mesh_file = 'samplemeshes/torus.off';

    [vertices, faces] = loadmesh(mesh_file);
    vertices = vertices.';
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
    subplot(1,2,1); plotmesh(vertices, faces, options); colorbar;
    subplot(1,2,2); histogram(K_G);
    
    options.face_vertex_color = K_H;
    figure()
    plotmesh(vertices, faces, options);
    
    options.face_vertex_color = K_1;
    figure()
    plotmesh(vertices, faces, options);
    
    options.face_vertex_color = K_2;
    figure()
    plotmesh(vertices, faces, options);
    
    %% Ridges
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
