import os
import numpy as np
import random
from scipy.stats import wasserstein_distance


from mesh_utils import read_off, calc_A_mixed, get_mean_curvature, get_gaussian_curvature, get_principal_curvatures


def get_features(vertices, faces, n_features=128):
    A_mixed, mean_curvature_normal_operator_vec = calc_A_mixed(
        vertices, faces)

    K_H = get_mean_curvature(mean_curvature_normal_operator_vec)
    K_G = get_gaussian_curvature(vertices, faces, A_mixed)
    K_1, K_2 = get_principal_curvatures(vertices, faces, K_H, K_G)


    # feature extraction 128 + 128, 256 features stacked.
    hist1, _ = np.histogram(K_1, n_features, density=True) # pdf
    hist2, _ = np.histogram(K_2, n_features, density=True) # pdf

    features = np.hstack([hist1, hist2])

    return features


def load_mesh(mesh_file):
    f = open(mesh_file)
    vertices, faces = read_off(f)

    # preproces_mesh (normalize)
    center = np.mean(vertices, 0)  
    vertices = vertices - center

    return vertices, faces


def main():
    file_paths = list()
    for root, _, filenames in os.walk('../../samplemeshes'):
        file_paths.extend([os.path.join(root, filename) for filename in filenames])
    
    mesh_weights = dict()
    for mesh_file in file_paths:
        print(f'Processing {mesh_file}')
        
        # using try..catch as some .off are corrupted and cannot be read, so read_off throws an error.
        try:
            mesh = load_mesh(mesh_file)
            mesh_weights[mesh_file] = get_features(*mesh)
        except:
            print('OFF file not readable')
            continue


    test_mesh_file = random.choice(file_paths)
    test_mesh = load_mesh(test_mesh_file)
    query_mesh_features = get_features(*test_mesh)


    distances = list()
    for mesh_file, features in mesh_weights.items():
        distance = wasserstein_distance(query_mesh_features, features)

        distances.append([mesh_file, distance])

    distances = sorted(distances, key=lambda d: d[1])
    min_distance = distances[0]

    print(f'predictions: {distances}')

    print(f'''
    Query Mesh: {test_mesh_file}
    Predicted Mesh: {min_distance[0]}
    distance: {min_distance[1]}
    ''')


if __name__ == '__main__':
    main()
