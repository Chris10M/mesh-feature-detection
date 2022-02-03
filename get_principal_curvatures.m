function [K_1, K_2] = get_principal_curvatures(K_H, K_G)    
	delx = K_H .* K_H - K_G;
	
    delx(find(delx < 0)) = 0;

    delx_sqrt = power(delx, 0.5);

	K_1 = K_H + delx_sqrt;
	K_2 = K_H - delx_sqrt;
end