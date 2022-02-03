function K_H = get_mean_curvature(vertices, triangles, A_mixed)
    numv = size(vertices, 1);
    numt = size(triangles, 1);
    
    K_N = zeros(numv, 3);

    for i=1:numv
        % Check if any face contains the vetrex index 
        face_1 = triangles(:, 1) == i;
        face_2 = triangles(:, 2) == i;
        face_3 = triangles(:, 3) == i;

        faces_indices = face_1 | face_2 | face_3;
        
        % Get all the triangles with current vertex. 
        req_t = triangles(faces_indices, :);
        
        num_neighour_faces = size(req_t, 1);
        for j=1: num_neighour_faces            
            % Get the adjacent vertices.
            nbhr = [];
            for k=1: 3
                vid = req_t(j, k);
            
                if (vid ~= i)
                    nbhr(end+1) = vid;
                end
            end

            v0 = vertices(i, :);
            v1 = vertices(nbhr(1), :);
            v2 = vertices(nbhr(2), :);
            
            vec_1 = v1 - v0; 
            vec_2 = v2 - v0;
            vec_3 = v2 - v1;

            norm_1 = norm(vec_1);
            norm_2 = norm(vec_2);
            norm_3 = norm(vec_3);

            cot_alpha = 1 / tan(acos(dot(-vec_1/norm_1, vec_3/norm_3)));
            cot_beta = 1 / tan(acos(dot(-vec_2/norm_2, -vec_3/norm_3)));
    
            K_N(i, :) = K_N(i, :) + (cot_alpha * vec_2 + cot_beta * vec_1);        
        end
        K_N(i, :) = K_N(i, :) / (2 * A_mixed(i));
    end
    K_H = 0.5 * vecnorm(K_N, 2, 2);

end
