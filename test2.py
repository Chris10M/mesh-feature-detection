import numpy as np
import sys
import csv
import polyscope as ps


def read_off(file):
    """ Referece: https://stackoverflow.com/questions/31129968/off-files-on-python """
    if 'OFF' != file.readline().strip():
        raise('Not a valid OFF header')

    n_verts, n_faces, n_dontknow = tuple(
        [int(s) for s in file.readline().strip().split(' ')])
    verts = [[float(s) for s in file.readline().strip().split(' ')]
             for i_vert in range(n_verts)]
    faces = [[int(s) for s in file.readline().strip().split(' ')][1:]
             for i_face in range(n_faces)]
    return np.array(verts, dtype=np.float64), np.array(faces, dtype=np.int64)


def get_area(a,b,c): # area of triangle using heron's formula
    v1 = get_vector(a,b)
    v2 = get_vector(a,c)
    v3 = get_vector(b,c)
    
    x = np.linalg.norm(v1)
    y = np.linalg.norm(v2)
    z = np.linalg.norm(v3)
    s = (x+y+z)/2.0

    area = (s*(s-x)*(s-y)*(s-z))**0.5
    return area

def check_obtuse(triangle,vertices,index): # checks if triangle is obtuse
    flag=0
    x = vertices[index]
    ind_arr = []
    ind_arr.append(index)
    
    arr = different_elements(tuple(triangle),tuple(ind_arr))
    y = vertices[int(arr[0])]
    z = vertices[int(arr[1])]

    v1 = get_vector(x,y)
    v2 = get_vector(x,z)
    angle = get_angle(v1,v2)
    if angle>np.pi/2.:
        flag=1
    v1 = get_vector(y,z)
    v2 = get_vector(y,x)
    angle = get_angle(v1,v2)
    if angle>np.pi/2.:
        flag=2
    v1 = get_vector(z,x)
    v2 = get_vector(z,y)
    angle = get_angle(v1,v2)
    if angle>np.pi/2.:
        flag=2

    return flag

def get_vector(x,y): # returns vector from x to y
    return y-x

def get_angle(x,y): # return tan of angle between vectors x and y
    x = x/np.linalg.norm(x,2)
    y = y/np.linalg.norm(y,2)
    cos = np.dot(x,y)
    
    return np.arccos(cos)

def get_neighbors(index,triangles): # get 1 ring neighborhood for ith vertex
    ring_neighbors = []
    for tri in triangles:
        if index in tri:
            ring_neighbors.append(tri)

    return np.array(ring_neighbors)

def common_elements(list1, list2): # get common elements of list1 and list2
    return list(set(list1) & set(list2))

def different_elements(list1, list2): # get uncommon elements of list1 and list2
    return list(set(list1) ^ set(list2))

def A_mixed(i,vertex,neighbors,vertices,triangles):

    A_mixed = 0

    if neighbors.dtype==object:
        return '#'

    summation = 0
    for j in range(neighbors.shape[0]):
        triangle = neighbors[j]

        flag1 = check_obtuse(triangle,vertices,i)

        if flag1==0: # not obtuse
        
            arr = np.delete(triangle,np.where(triangle==np.float64(i)))
            
            x1 = vertex
            x2 = vertices[int(arr[0])]
            x3 = vertices[int(arr[1])]

            v1 = get_vector(x1,x2)
            v2 = get_vector(x1,x3)
            v3 = get_vector(x2,x3)
            cot_alpha = 1.0/np.tan(get_angle(-v1,v3))

            cot_beta = 1.0/np.tan(get_angle(-v2,-v3))

            summation += (cot_alpha*np.linalg.norm(v2,2)**2 + cot_beta*np.linalg.norm(v1,2)**2)/8.0

        elif flag1==1:
            area = get_area(vertices[triangle[0]],vertices[triangle[1]],vertices[triangle[2]])
            summation += area/2.0
        else:
            area = get_area(vertices[triangle[0]],vertices[triangle[1]],vertices[triangle[2]])
            summation += area/4.0

    A_mixed += summation

    # print('A_mixed', A_mixed)
    return A_mixed

def mean_normal_curvature(i,vertex,A_mixed,neighbors,vertices,triangles):
    summation = np.array([0.,0.,0.])

    for j in range(neighbors.shape[0]):
        triangle = neighbors[j]
        
        arr = np.delete(triangle,np.where(triangle==np.float64(i)))
        
        x1 = vertex
        x2 = vertices[int(arr[0])]
        x3 = vertices[int(arr[1])]

        v1 = get_vector(x1,x2)
        v2 = get_vector(x1,x3)
        v3 = get_vector(x2,x3)
        cot_alpha = 1.0/np.tan(get_angle(-v1,v3))
        cot_beta = 1.0/np.tan(get_angle(-v2,-v3))

        summation += (cot_alpha*v2 + cot_beta*v1)

    K = summation/(2.0*A_mixed)
    return K

def gaussian_curvature(i,vertex,A_mixed,neighbors,vertices,triangles):

    summation = 0.
    for j in range(neighbors.shape[0]):
        triangle = neighbors[j]
        arr = np.delete(triangle,np.where(triangle==i))

        a = vertices[int(arr[0])]
        b = vertices[int(arr[1])]
        c = vertex

        v1 = get_vector(c,a)
        v2 = get_vector(c,b)

        theta = get_angle(v2,v1)

        summation += theta

    K_G = ((2.0*np.pi) - summation)/(A_mixed)
    return K_G

def mean_curvature(K):
    K_H = np.linalg.norm(K,2)/2.
    return K_H

def principal_curvature(K_H,K_G):
    delta = K_H*K_H - K_G
    
    if delta<0:
        delta=0

    K1 = K_H + delta**0.5
    K2 = K_H - delta**0.5

    return K1,K2



def compute(vertices, triangles):
    arr_K_G = []
    arr_K_H = []
    arr_K1 = []
    arr_K2 = []
    
    for i in range(len(vertices)):
        # print('\nVertex: ' + str(i))

        neighbors = get_neighbors(np.copy(i),np.copy(triangles))
        
        a_mixed = A_mixed(i,vertices[i],np.copy(neighbors),np.copy(vertices),np.copy(triangles))
        if a_mixed=='#' or a_mixed==0:
            # print('#')
            arr_K_G.append(0.)
            arr_K_H.append(0.)
            arr_K1.append(0.)
            arr_K2.append(0.)
            continue

        K_G = gaussian_curvature(np.copy(i),np.copy(vertices[i]),np.copy(a_mixed),np.copy(neighbors),np.copy(vertices),np.copy(triangles)) 
        K = mean_normal_curvature(np.copy(i),np.copy(vertices[i]),np.copy(a_mixed),np.copy(neighbors),np.copy(vertices),np.copy(triangles))
        K_H = mean_curvature(K)

        K1, K2 = principal_curvature(K_H,K_G)

        arr_K_G.append(K_G)
        arr_K_H.append(K_H)
        arr_K1.append(K1)
        arr_K2.append(K2)
    
    return np.array(arr_K_G), np.array(arr_K_H), np.array(arr_K1), np.array(arr_K2)


def main():
    ps.init()


    mesh_file = 'samplemeshes/hand.off'
    mesh_file = 'samplemeshes\sphere_coarse.off'
    mesh_file = 'samplemeshes/torus.off'

    f = open(mesh_file)
    vertices, faces = read_off(f)

    print(f'''
    vertices.shape: {vertices.shape}
    faces.shape: {faces.shape}''')
    
    K_G, K_H, K1, K2 = compute(vertices, faces)

    print(f'K_G {np.sum(K_G)}')
    print(f'K_H {np.sum(K_H)}')

    print(f'''
    K_H.shape: {K_H.shape}
    K_G.shape: {K_G.shape}''')

    print(f'K_1 {np.sum(K1)}')
    print(f'K_2 {np.sum(K2)}')


    ps.register_surface_mesh("my mesh", vertices, faces, smooth_shade=True)

    ps.get_surface_mesh("my mesh").add_scalar_quantity("Gaussian", K_G, defined_on='vertices')
    ps.get_surface_mesh("my mesh").add_scalar_quantity("Mean", K_H, defined_on='vertices')

    ps.show()


if __name__ == '__main__':
    main()