class_name GDBenchmark
extends RefCounted

func benchmark(f: Callable, args: Array = [], tries: int = 10) -> float:
	var times: Array[int] = []

	for i: int in tries:
		var start := Time.get_ticks_usec()
		f.callv(args)
		var end := Time.get_ticks_usec()
		times.append(end - start)
	
	times.sort()
	
	var mid := int(tries / 2.0)
	
	var lower_half: Array
	var upper_half: Array
	
	if tries % 2 == 0:
		lower_half = times.slice(0, mid)
		upper_half = times.slice(mid)
	else:
		lower_half = times.slice(0, mid)
		upper_half = times.slice(mid + 1)
	
	var q1: float = median(lower_half)
	var q3: float = median(upper_half)
	var iqr: float = q3 - q1
	
	var lower_bound: float = q1 - 1.5 * iqr
	var upper_bound: float = q3 + 1.5 * iqr
	
	var cleaned_times: Array = times.filter(func(t: int) -> bool:
		return lower_bound <= t and t <= upper_bound
	)
	
	return sum(cleaned_times) / float(len(cleaned_times)) if cleaned_times else 0.0

func median(list: Array[int]) -> float:
	var m := len(list)
	if m == 0:
		return 0
	
	if m == 1:
		return list[0]
	
	if m % 2 == 0:
		return (list[int(m / 2.0) - 1] + list[int(m / 2.0)]) / 2.0
	
	return list[int(m / 2.0)]

func sum(list: Array[int]) -> int:
	return list.reduce(func (f: int, s: int) -> int: return f + s, 0)
