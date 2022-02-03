function A_mixed = calc_A_mixed(vertices, triangles)
    numv = size(vertices, 1);
    numt = size(triangles, 1);
    
    A_mixed = zeros(numv, numt);
    for i=1:numv
        % Check if any face contains the vetrex index 
        face_1 = triangles(:, 1) == i;
        face_2 = triangles(:, 2) == i;
        face_3 = triangles(:, 3) == i;

        faces_indices = find(face_1 | face_2 | face_3);
        
        % Get all the triangles with current vertex. 
        req_t = triangles(faces_indices, :);
        
        num_neighour_faces = size(req_t, 1);
        
        for j=1: num_neighour_faces
            tid = faces_indices(j);
                        
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
            
            area = get_heron_area(v0, v1, v2);

            vec_1 = v1 - v0; 
            vec_2 = v2 - v0;

            vec_1 = vec_1 / norm(vec_1);
            vec_2 = vec_2 / norm(vec_2);

            angle_at_x = acos(dot(vec_1, vec_2));

            
            % Obtuse angle
            if (angle_at_x > pi / 2)
                A_mixed(i, tid) =  area / 2;
                continue;
            end
            
            vec_1a = v0 - v1; 
            vec_2a = v2 - v1;

            vec_1a = vec_1a / norm(vec_1a);
            vec_2a = vec_2a / norm(vec_2a);

            angle_1 = acos(dot(vec_1a, vec_2a));

            if (angle_1 > pi / 2)
                A_mixed(i, tid) =  area / 4;
                continue;
            end

            vec_1b = v0 - v2; 
            vec_2b = v1 - v2;

            vec_1b = vec_1b / norm(vec_1b);
            vec_2b = vec_2b / norm(vec_2b);

            angle_2 = acos(dot(vec_1b, vec_2b));

            if (angle_2 > pi / 2)
                A_mixed(i, tid) =  area / 4;
                continue;
            end

            cot_1 = 1 / tan(angle_1);
            cot_2 = 1 / tan(angle_2);

            A_v_of_tid = 0.125 * (  (cot_1 * power(norm(v0 - v2, 2), 2)) + (cot_2 * power(norm(v0 - v1, 2), 2))     );
            
            A_mixed(i, tid) = A_v_of_tid;
        end 
    end
    
    A_mixed = sum(A_mixed, 2);
    A_mixed(find(A_mixed == 0)) = 1e-12;
end