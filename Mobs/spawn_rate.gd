class_name SpawnRate extends RefCounted
const MAX_DIFF = 3.5
static func get_max_diff() -> float:
	return MAX_DIFF
static func t1(x : float) -> int :
	return  floor(-8.33*x**2 + 15.00*x + 3.33)
	
static func t2(x : float) -> int:
	return floor(-10.00*x**2 + 30.00*x + -12.50)
	
static func t3(x : float) -> int:
	return floor(-10.00*x**2 + 40.00*x + -30.00)
	
static func t4(x : float) -> int:
	return (-10.00*x**2 + 50.00*x + -52.50)
	
static func t5(x : float) -> int:
	return (-10.00*x**2 + 60.00*x + -80.00)
	
static func t6(x : float) -> int:
	return (-10.00*x**2 + 70.00*x + -112.50)
