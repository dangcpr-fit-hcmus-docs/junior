import time
import pulp

problem = pulp.LpProblem("Linear Programming", pulp.LpMaximize)

# Khai báo biến
x1 = pulp.LpVariable('x1', 0, None, cat='Continious')
x2 = pulp.LpVariable('x2', 0, None, cat='Continious')
x3 = pulp.LpVariable('x3', 0, None, cat='Continious')
x4 = pulp.LpVariable('x4', 0, None, cat='Continious')

# Hàm mục tiêu
problem += 2 * x1 - 3 * x2 + 4 * x3 + x4
# Ràng buộc bất phương trình
problem += x1 + x2 + 3 * x3 == 25
problem += -x2 + x3 + x4 <= 10
problem += 2 * x2 + x3 + 5 * x4 <= 16

start_time = time.time()
# Giải bài toán
status = problem.solve()
end_time = time.time()
elapsed_time = end_time - start_time

# Kết quả
print("Giá trị nhỏ nhất của hàm mục tiêu: ", pulp.value(problem.objective))
print("x1 = ", pulp.value(x1))
print("x2 = ", pulp.value(x2))
print("x3 = ", pulp.value(x3))
print("x4 = ", pulp.value(x4))
print("Elapsed time: ", elapsed_time, " seconds")

#Bài toán đối ngẫu
# Khai báo bài toán
dual_model = pulp.LpProblem("DualExample", pulp.LpMinimize)

# Khai báo biến
y1 = pulp.LpVariable('y1', None , None, cat='Continuous')
y2 = pulp.LpVariable('y2', 0, None, cat='Continuous')
y3 = pulp.LpVariable('y3', 0, None, cat='Continious')

# Hàm mục tiêu
dual_model += 25 * y1 + 10 * y2 + 16 * y3
# Ràng buộc bất phương trình
dual_model += y1 >= 2
dual_model += y1 - y2 + 2 * y3 >= -3
dual_model += 3 * y1 + y2 +  y3 >= 4
dual_model += y2 + 5 * y3 >= 1

start_time = time.time()
# Giải bài toán
status = dual_model.solve()
end_time = time.time()
elapsed_time = end_time - start_time

# Kết quả
print("Giá trị nhỏ nhất của hàm mục tiêu dual_model: ", pulp.value(dual_model.objective))
print("y1 = ", pulp.value(y1))
print("y2 = ", pulp.value(y2))
print("y3 = ", pulp.value(y3))
print("Elapsed time: ", elapsed_time, " seconds")

# Tính giá trị độ lệch bù
duality_gap = pulp.value(problem.objective) - pulp.value(dual_model.objective)
print("Duality gap = {}".format(duality_gap))