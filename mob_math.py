import numpy as np

def quadratic_from_points(p1, p2, p3):
    # Unpack points
    (x1, y1), (x2, y2), (x3, y3) = p1, p2, p3
    
    # Set up the system of equations: Ax = B
    A = np.array([
        [x1**2, x1, 1],
        [x2**2, x2, 1],
        [x3**2, x3, 1]
    ])
    
    B = np.array([y1, y2, y3])
    
    # Solve for [a, b, c]
    a, b, c = np.linalg.solve(A, B)
    
    return a, b, c

# Example usage:
# t1
p1 = (-0.2, 0)
p2 = (1, 10)
p3 = (2, 0)
# t2
# p1 = (0.5, 0)
# p2 = (1.5, 10)
# p3 = (5, 0)
a, b, c = quadratic_from_points(p1, p2, p3)
print(f"Quadratic function: y = floor({a:.2f}*x**2 + {b:.2f}*x + {c:.2f})")
