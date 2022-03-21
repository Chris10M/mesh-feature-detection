function K_G = get_gaussian_curvature(vertices, triangles, A_mixed)
    numv = size(vertices, 1);
    numt = size(triangles, 1);
    
    K_G = zeros(numv, 1);

    for i=1:numv
        theta_sum = 0;

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

            vec_1 = vec_1 / norm(vec_1);
            vec_2 = vec_2 / norm(vec_2);

            angle = acos(dot(vec_1, vec_2));
            theta_sum = theta_sum + angle;
        
        end
        K_G(i) = ((2 * pi) - theta_sum) / A_mixed(i);
    end
end