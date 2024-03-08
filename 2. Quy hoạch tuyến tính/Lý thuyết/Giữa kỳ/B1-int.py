import time
import pulp

# Khai báo bài toán
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