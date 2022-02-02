function K_H = get_mean_curvature(mean_curvature_normal_operator_vector)
    K_H = 0.5 * norm(mean_curvature_normal_operator_vector, 2);
