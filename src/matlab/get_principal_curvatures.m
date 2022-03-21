function [K_1, K_2] = get_principal_curvatures(K_H, K_G)
    delta = K_H.*K_H - K_G;
    delta(delta<0) = 0;

    K_1 = K_H + sqrt(delta);
    K_2 = K_H - sqrt(delta);

end