from scipy.optimize import linprog
import numpy as np


# Tạo ma trận A và vector b
A = np.array([[-140, -180], [4, 3], [8, 10]])
b = np.array([-1200, 31, 80])

# Tạo vector hệ số của hàm mục tiêu f
c = np.array([2, -3, 4, 1])

# Định nghĩa ràng buộc bên dưới và bên trên của x
bnd = [(0, float("inf")),(0, float("inf"))]

# Sử dụng hàm linprog để giải bài toán
result = linprog(c, A_ub=A, b_ub=b, bounds=bnd, int=True)

# In kết quả
print('Giá trị nhỏ nhất của hàm số f(x) là:', result.fun)
print('Giá trị của x1 và x2 tương ứng là:', result.x)